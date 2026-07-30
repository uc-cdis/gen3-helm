# Running Gen3 on OpenShift: what actually breaks, and how we fixed it

We set out to answer a simple question: does the latest `gen3` Helm chart
actually work on OpenShift, using a `Route` instead of an `Ingress`? Rather
than take that on faith, we tore down an existing deployment, reinstalled
from scratch against a clean values file, and pushed it end to end — login,
and a real data submission via `gen3-sdk`. Along the way we hit five
distinct, reproducible problems. None of them are exotic; all of them are the
kind of thing that quietly breaks a "it works on my Kubernetes cluster"
deployment the moment it lands on OpenShift.

This post is both a report of what we found and a runbook for reproducing a
working deployment yourself. The full values file is at
[`examples/openshift_values.yaml`](../../examples/openshift_values.yaml);
the reference doc with copy-pasteable commands is
[`docs/openshift.md`](../openshift.md).

## TL;DR — five gotchas

1. **`global.hostname` must match your Route host, exactly.** Leave it at
   the chart default (`localhost`) and every OAuth/OIDC redirect, the JWT
   issuer claim, and the CSP header get built from the wrong URL. The portal
   loads fine; login silently redirects to `https://localhost/...`. This was
   the actual root cause behind "the login button doesn't work" — not a
   login-provider misconfiguration.
2. **Your namespace's `LimitRange` can break things two different ways.**
   A default CPU *limit* of `200m` (common on shared OpenShift clusters)
   caused `postgresql`'s pod to fail to schedule entirely (its default
   *request* of `250m` exceeds that limit — an outright rejection with a
   clear error), and separately caused `fence` to silently throttle to
   8–24 second response times under real traffic, with zero errors in the
   logs, because it inherited the same `200m` limit with no override.
3. **`bitnamilegacy/postgresql` image tags now 401.** Bitnami moved most of
   its historical tags behind registry auth. Use the chart's own default
   image instead of pinning to the old Bitnami path.
4. **The OpenShift router's TLS cert won't match a made-up hostname.**
   `curl -k` hides this; `gen3-sdk` has no equivalent flag and will refuse
   to talk to your Route with a `SSLCertVerificationError` unless your Route
   host is under the cluster's real wildcard domain.
5. **SCC matters, and it's not always `restricted-v2`.** Some projects
   already carry an `anyuid` grant (`restricted-v2-anyuid`), which is why
   fixed `runAsUser` values in the values file work even outside the
   namespace's assigned UID range — worth checking before you assume you
   need to request elevated permissions.

Everything below is the narrative version, with the actual commands and
error text we hit.

---

## Setting the stage

Target: an existing OpenShift namespace on a shared cluster, Route enabled
(`revproxy.openshiftRoute.enabled: true`), no Ingress. Rather than patch the
existing 55-day-old release in place, we did a full `helm uninstall` /
`helm install` cycle against a fresh values file, on the theory that a
clean install is a much more honest test of "does this chart work" than
incrementally patching whatever state a namespace has drifted into over two
months of ad hoc changes.

We also swapped the default `portal` frontend for the newer
`frontend-framework` chart (`gen3ff`), since that's the direction new
deployments are heading:

```yaml
global:
  hostname: "gen3.apps-crc.testing"
  frontendRoot: "gen3ff"

portal:
  enabled: false

frontend-framework:
  enabled: true
  securityContext:
    capabilities:
      drop: ["ALL"]
    runAsNonRoot: true
    runAsUser: 1000
```

`global.frontendRoot` isn't cosmetic. It flips a `perl_set` directive in
revproxy's nginx config that decides which upstream serves `/`, and gates
blocks in the umbrella chart's `global-manifest.yaml`. Set the flag without
enabling the matching chart and you get a Route that resolves fine but
502s at `/`.

## Gotcha #1: login was broken, but not because of the login provider

The obvious first move for testing login without wiring up real Google
OAuth is `fence`'s mock-auth mode:

```yaml
fence:
  FENCE_CONFIG:
    MOCK_GOOGLE_AUTH: true
```

That flag alone should be enough — `LOGIN_OPTIONS` and `DEFAULT_LOGIN_IDP`
already default to `google` in the chart. But the login button still didn't
work. Pulling the live fence config out of the cluster showed why:

```
BASE_URL: https://localhost/user
```

The Route's actual host was `gen3.apps-crc.testing`. `BASE_URL` is built
from `global.hostname`, which the values file being used had simply never
set — it silently inherited the chart default of `localhost`. Every
OIDC redirect URL, `OAUTH2_JWT_ISS`, and `FRAME_ANCESTORS` in the CSP header
is templated from `BASE_URL`, so login worked in the sense that fence issued
a valid session — it just redirected the browser back to `localhost`,
which doesn't exist from the browser's point of view.

The fix is one line, but it has to be the exact host the Route uses:

```yaml
global:
  hostname: "gen3.apps-crc.testing"
```

After that, `BASE_URL` rendered correctly and the full mock-login flow
worked: `GET /user/login/google` → `302` with a valid session cookie →
`GET /user/user` → `200` with the mock user's identity, `iss` claim
correctly pointing at the real host.

## Gotcha #2 (twice): the namespace `LimitRange` you didn't know was there

OpenShift projects often carry a `LimitRange` that injects default resource
limits on any container that doesn't specify its own:

```
limits:
  default:
    cpu: 200m
    memory: 256Mi
  defaultRequest:
    cpu: 10m
    memory: 64Mi
  type: Container
```

This bit the deployment twice, in two different failure modes.

**First: a pod that never even schedules.** The `postgresql` subchart's
upstream default sets `primary.resources.requests.cpu: 250m` with no
explicit `limits`. Combine that with the LimitRange's `200m` default limit
and Kubernetes rejects the pod outright — a *request* can't exceed its
*limit*:

```
Warning  FailedCreate  statefulset/gen3-postgresql
create Pod gen3-postgresql-0 in StatefulSet gen3-postgresql failed error:
Pod "gen3-postgresql-0" is invalid: spec.containers[0].resources.requests:
Invalid value: "250m": must be less than or equal to cpu limit of 200m
```

`kubectl get pods` shows nothing — there's no pod to show, just a
StatefulSet quietly retrying `FailedCreate` forever. You have to check
`kubectl describe statefulset` or `kubectl get events` to see it at all.
Fix: give postgresql an explicit limit above its request.

**Second: a service that's just... slow, for no visible reason.** `fence`
had no `resources` block in the values file at all, so it inherited the
LimitRange's `200m` default *limit* (which is internally consistent, so
nothing rejects it — it just schedules and runs). Once we started
exercising the login flow, `kubectl top pod` showed fence sitting at
`161m` of its `200m` ceiling. That's Linux's CFS scheduler throttling the
process once it's burned its CPU-time allotment for the period — and it
manifests as **8 to 24 second response times** on `/user/login/google` and
`/user/user`, with nothing resembling an error anywhere in fence's logs.
From the outside it looks like "fence is flaky." It isn't; it's CPU-starved
by a default nobody set on purpose.

```yaml
fence:
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 100m
      memory: 256Mi
```

After that change, the same requests dropped to 0.6–0.7 seconds. We gave
`revproxy` similar headroom, since it's the single point all traffic flows
through and was subject to the same silent default.

**Lesson:** on any OpenShift namespace, run `kubectl get limitrange -o yaml`
before you deploy, and give an explicit `resources` block to at least the
services on your request hot path (proxy + auth), even if you think the
defaults are "probably fine."

## Gotcha #3: Bitnami moved the cheese

The values file we started from pinned `postgresql.image.repository` to
`bitnamilegacy/postgresql`. That tag now returns a flat `401`:

```
Failed to pull image "quay.io/bitnamilegacy/postgresql:16.6.0-debian-12-r2":
unauthorized: access to the requested resource is not authorized
```

Bitnami restructured its free image distribution in 2025, and a lot of
previously-public "legacy" tags now require registry auth. The umbrella
chart's own default (`quay.io/cdis/docker-bitnami-pgvector:16`, a
CDIS-maintained mirror with the pgvector extension baked in) is unaffected
— the fix was simply to stop overriding the image and let the chart default
apply.

## Gotcha #4: gen3-sdk and the Route's certificate

Once login worked, the next test was a real submission via `gen3-sdk`
(`Gen3Auth` + `Gen3Submission`). First call:

```
ssl.SSLCertVerificationError: [SSL: CERTIFICATE_VERIFY_FAILED]
certificate verify failed: Hostname mismatch, certificate is not valid
for 'gen3.apps-crc.testing'
```

The Route's host, `gen3.apps-crc.testing`, was chosen to match a local
`/etc/hosts` entry — but this is a real OpenShift cluster, and its router's
actual TLS certificate covers the cluster's real wildcard domain
(`*.apps.<cluster-domain>`), not an arbitrary name we picked. `curl -k`
papers over this without complaint; `gen3-sdk`'s HTTP layer (plain
`requests`) has no equivalent flag exposed through `Gen3Auth`.

For a disposable dev/test cluster, the workaround is to disable `requests`
verification for the whole session:

```python
import urllib3, requests
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
_orig = requests.Session.request
requests.Session.request = lambda self, *a, **kw: _orig(self, *a, **{**kw, "verify": False})
```

For anything that isn't a throwaway environment, the real fix is to put the
Route under the cluster's actual router domain (or bring your own
certificate for the custom host) so verification works the normal way.

## Gotcha #5: check which SCC you actually have

`docs/openshift.md` already documented the classic `restricted-v2` problem
— arbitrary non-root UIDs, all capabilities dropped, and an `nginx: Operation
not permitted` failure the first time an image tries to bind a privileged
port or write somewhere UID-specific. The existing values file carries
fixed `runAsUser`/`fsGroup` values for `portal`/`revproxy`/`postgresql`/
`elasticsearch` to work around exactly that.

What we hadn't checked was *which* SCC this particular namespace actually
uses:

```
$ kubectl get pod <pod> -o jsonpath='{.metadata.annotations.openshift\.io/scc}'
restricted-v2-anyuid
```

Not plain `restricted-v2` — an `anyuid`-flavored variant. That's why fixed
UIDs outside the namespace's assigned range
(`openshift.io/sa.scc.uid-range: 1000950000/10000`, per the namespace
annotation) worked without complaint: the `anyuid` grant permits running as
whatever UID the pod spec asks for, not just the namespace's assigned range.
Worth checking before assuming you need to request elevated SCC access —
you might already have it.

## Proving it end to end: a real submission

Login working is necessary but not sufficient — the actual point of a data
commons is submitting and reading data. With mock auth in place, we tested
the full path: mint a mock identity with real authorization, get an API
key the way `gen3-sdk` expects, and submit through the standard Program →
Project → Record hierarchy.

**Picking the right mock user.** `MOCK_GOOGLE_AUTH` lets fence authenticate
any username via a `dev_login` cookie, but *authorization* comes from
`user.yaml` (loaded into the `useryaml` ConfigMap by a Job at install time).
The chart's sample `user.yaml` only grants submitter policies to
`username1@gmail.com` — logging in as the default mock user
(`test@example.com`) gets you read-only `open_data_reader` and nothing else.
Sanity-check what's actually loaded:

```
kubectl get cm useryaml -o jsonpath='{.data.useryaml}'
```

**Minting an API key without a browser.** The portal's "Create an API Key"
button just calls `POST /user/credentials/api` while authenticated. For
scripting, the same thing can be done from inside the fence pod:

```
kubectl exec deploy/fence-deployment -- fence-create token-create \
  --type access --username username1@gmail.com \
  --scopes openid,user,data,admin,credentials
```

The first attempt without `credentials` in the scope list failed with a
clear, useful error (`token is missing required scopes: {'credentials'}`)
— worth calling out only because it's exactly the kind of error message
you want and don't always get. Exchange that access token for a long-lived
API key:

```
curl -k -X POST "https://gen3.apps-crc.testing/user/credentials/api" \
  -H "Authorization: bearer <access-token>" -H "Content-Type: application/json" -d '{}'
# => {"api_key": "<refresh-token-jwt>", "key_id": "..."}
```

Save that as `credentials.json` and hand it to `Gen3Auth(refresh_file=...)`.

**Programs and projects aren't real until you create them.** `user.yaml`'s
policy for `MyFirstProgram`/`MyFirstProject` pre-authorizes that path, but
doesn't create the underlying sheepdog nodes. A GraphQL query for existing
programs came back empty even though the authz block listed
`/programs/MyFirstProgram/projects/MyFirstProject`. Bootstrapping them is
a normal `gen3-sdk` call:

```python
from gen3.auth import Gen3Auth
from gen3.submission import Gen3Submission

auth = Gen3Auth(endpoint="https://gen3.apps-crc.testing", refresh_file="credentials.json")
sub = Gen3Submission("https://gen3.apps-crc.testing", auth)

sub.create_program({"type": "program", "name": "MyFirstProgram",
                     "dbgap_accession_number": "MyFirstProgram"})
sub.create_project("MyFirstProgram", {"type": "project", "code": "MyFirstProject",
                    "dbgap_accession_number": "MyFirstProject", "name": "MyFirstProject"})
sub.submit_record("MyFirstProgram", "MyFirstProject", {
    "type": "experiment", "submitter_id": "test-experiment-1",
    "projects": [{"code": "MyFirstProject"}],
})
```

All three calls succeeded on the first try once the API key and TLS
workaround were in place, and a GraphQL read against peregrine confirmed
the record was actually persisted:

```
{"data":{"experiment":[{"project_id":"MyFirstProgram-MyFirstProject","submitter_id":"test-experiment-1"}]}}
```

## Where this leaves us

Every one of these issues was fixable with a values-file change, not a
chart-code change — which is the right outcome, but it also means none of
them are visible unless you actually deploy and exercise the thing. A chart
that renders cleanly with `helm template` and even installs successfully
can still have a completely broken login flow (hostname mismatch), a pod
that silently never starts (LimitRange), or a service that "works" but is
unusable under load (LimitRange again, different failure mode). The fix in
every case was small; finding it required actually clicking the login
button and running a submission, not just checking that pods reached
`Running`.

The working reference values are in
[`examples/openshift_values.yaml`](../../examples/openshift_values.yaml),
and the full gotcha list with copy-pasteable commands lives in
[`docs/openshift.md`](../openshift.md).

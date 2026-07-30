# 🧪 Running Gen3 / Indexd Locally on OpenShift (CRC)

## 🚀 Setup OpenShift Local (CRC)

Follow the official guide to install and start CRC:

👉 https://www.redhat.com/en/blog/install-openshift-local

---

## ⚙️ Configure CRC Resources (Do this BEFORE first `crc start`)

CRC defaults are small. Increase them for Gen3 before starting:

    crc config set disk-size 80
    crc config set memory 16384
    crc config set cpus 6

Then start CRC:

    crc start

---

## 🔑 Initialize CLI Access

    eval $(crc oc-env)
    oc login -u developer https://api.crc.testing:6443

## 🔑 If you get any permissions errors

    oc login -u kubeadmin https://api.crc.testing:6443



---

## 🧰 Optional: Enable `kubectl`

If you prefer using `kubectl`:

    export KUBECONFIG="$HOME/.crc/machines/crc/kubeconfig"

    kubectl get nodes

---

## 📦 Deploy with Helm

    oc new-project openshift-gen3
    helm dependency update helm/gen3
    helm upgrade --install gen3 helm/gen3 -f examples/openshift_values.yaml -n openshift-gen3

Watch the rollout:

    kubectl get pods -n openshift-gen3 -w

---

## 🌐 Set the Route host to something you actually control

`examples/openshift_values.yaml` sets `revproxy.openshiftRoute.host` and
**must also set `global.hostname` to the exact same value**. `global.hostname`
drives `BASE_URL` in fence's config (`https://{{hostname}}/user`), which in
turn drives every OAuth/OIDC redirect URL, `OAUTH2_JWT_ISS`, and the CSP
`FRAME_ANCESTORS` header. If `global.hostname` is left at its default
(`localhost`) while the Route uses a different host, login will silently
redirect to the wrong place — the portal loads fine, but clicking "Login"
sends you to `https://localhost/...`.

Add your `/etc/hosts` entry to match:

    <cluster-ip-or-router-ip>  gen3.apps-crc.testing

⚠️ **If your Route host isn't under the cluster's real router wildcard
domain** (check with `oc get ingresses.config/cluster -o
jsonpath='{.spec.domain}'`), the router's default TLS certificate won't have
a matching SAN, and browsers/`curl` will need `-k`/"proceed anyway" to reach
it. This is fine for a disposable local/dev deployment; for anything
resembling production, use a Route host under the real router domain (or
bring your own cert) so verification works normally. See the gen3-sdk
section below for what this means for tooling that can't skip verification.

---

## 🖥️ Which frontend: portal vs frontend-framework

The umbrella chart can serve either the legacy `portal` chart or the newer
`frontend-framework` (gen3ff) chart at `/`. This is controlled by
**`global.frontendRoot`**, which must agree with which chart is enabled:

    global:
      frontendRoot: "gen3ff"   # or "portal"

    portal:
      enabled: false           # disable whichever one you're not using

    frontend-framework:
      enabled: true
      securityContext:
        capabilities:
          drop: ["ALL"]
        runAsNonRoot: true
        runAsUser: 1000        # match your project's allowed UID / anyuid grant

`global.frontendRoot` isn't just cosmetic — it also switches a `perl_set` in
revproxy's nginx config that decides which upstream service `/` and related
paths are proxied to, and toggles blocks in `helm/gen3/templates/global-manifest.yaml`.
Setting the flag without actually enabling the matching chart (or vice versa)
gets you a working Route with a 502 at `/`.

---

# 🔐 Security Context Constraints (SCC) Notes

## ❗ Why we could NOT use the `default` namespace

I originally tried deploying into the `default` namespace, but ran into SCC issues.

Key reasons:

- The `default` namespace has stricter or preconfigured SCC bindings
- It is harder to safely modify without impacting other workloads
- OpenShift applies SCCs based on **service accounts + namespace context**
- Changing SCCs globally can have unintended side effects

Instead, I created and used a **dedicated namespace** for deployment (for example, `openshift-gen3`), which let me safely control SCC behavior.

---

## ✅ Grant SCC to a Namespace (Service Accounts)

    oc adm policy add-scc-to-group restricted-v3 system:serviceaccounts:<namespace>

Example:

    oc adm policy add-scc-to-group restricted-v3 system:serviceaccounts:openshift-gen3

### What this does

- Grants the `restricted-v3` SCC to **all service accounts in that namespace**
- Ensures pods run under modern OpenShift security constraints

---

# ⚠️ NGINX + SCC Gotcha

## 🧨 Error we saw without additional permissions

When running without elevated SCC permissions, the pod fails with:

    /indexd/dockerrun.bash: line 3: /usr/sbin/nginx: Operation not permitted
    /indexd/dockerrun.bash: line 4: poetry: command not found

---

## 🧨 Why things broke

When running under `restricted-v2` or `restricted-v3`:

- Containers run as a **random non-root UID**
- **All capabilities are dropped**
- `allowPrivilegeEscalation = false`
- Filesystem access must be UID-agnostic

Our image (for example, `indexd`) is **not fully arbitrary-UID compatible**, which caused nginx to fail at startup.

---

## 🛠️ Workaround used for local dev

    oc adm policy add-scc-to-user anyuid -z default -n <project>

Example:

    oc adm policy add-scc-to-user anyuid -z default -n openshift-gen3

---

## 🤔 What this command does

- Grants the `anyuid` SCC to the `default` service account in the namespace
- Allows containers to run as the **UID defined in the image**
- Avoids OpenShift’s random UID enforcement for that service account

### Why this fixes things

- nginx expects specific filesystem permissions and runtime behavior
- `anyuid` lets it run as intended by the image author

---

## ❓ Does this affect all the other policies or just the UID?

Mostly the UID-related restriction.

It does **not** mean everything else is bypassed. You still keep other OpenShift and Kubernetes controls like:

- SELinux enforcement
- seccomp defaults
- network policies
- other SCC behavior that still applies

But it **does make the pod less secure**, because it can run as a fixed UID from the image rather than a random namespace-assigned UID.

Some projects instead have an `anyuid`-flavored SCC already bound
(`restricted-v2-anyuid` rather than plain `restricted-v2`) — check with:

    oc get pod <pod> -o jsonpath='{.metadata.annotations.openshift\.io/scc}'

If you see `restricted-v2-anyuid`, fixed `runAsUser` values (like the
`1000`/`1000660001`/`1000950000` values in `examples/openshift_values.yaml`)
will work even outside the namespace's assigned UID range
(`openshift.io/sa.scc.uid-range` annotation on the namespace) — the `anyuid`
grant is what makes that safe, not the values file alone.

---

# 💥 Resource limits: the namespace `LimitRange` gotcha

Many OpenShift projects have a `LimitRange` that silently injects a default
CPU **limit** (commonly `200m`) on any container that doesn't request its
own. This bit us twice in the same deployment, in two different ways:

**1. Pod fails to schedule at all.** The `postgresql` subchart's upstream
default sets `primary.resources.requests.cpu: 250m` with no explicit
`limits`. The LimitRange then injects a `200m` default limit — and Kubernetes
rejects a pod whose *request* exceeds its *limit*:

    Pod "gen3-postgresql-0" is invalid: spec.containers[0].resources.requests:
    Invalid value: "250m": must be less than or equal to cpu limit of 200m

The StatefulSet just sits there retrying forever (`FailedCreate` events) with
no pod even created — easy to miss if you're only watching `kubectl get
pods`. Check `kubectl describe statefulset/<name>` or `kubectl get events`
when a pod never appears.

**2. Service becomes extremely slow, with no errors.** `fence` had no
explicit `resources` block at all, so it silently inherited the `200m`
default *limit*. Under real login/token traffic it was using ~160m/200m CPU —
close enough to the ceiling that the Linux CFS scheduler throttles it, which
shows up as **8-24 second response times** on endpoints that should be
sub-second (`/user/user`, `/user/login/google`), with no errors anywhere in
the logs. `kubectl top pod` showing a container pinned near its limit is the
tell; the fix is just giving it a realistic explicit limit:

    fence:
      resources:
        limits:
          cpu: 1000m
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 256Mi

Check your namespace's LimitRange before deploying:

    kubectl get limitrange -o yaml

and give `fence` and `revproxy` (the two services actually on the request
hot path) explicit resource blocks rather than relying on the namespace
default — see `examples/openshift_values.yaml` for the values used here.

---

# 🐘 Bitnami image registry changes

`postgresql.image.repository: bitnamilegacy/postgresql` (a value carried
over from an earlier version of `examples/openshift_values.yaml`) now
returns `401 unauthorized` on pull — Bitnami moved most historical tags
behind registry auth. Don't override the image at all; the umbrella chart's
own default (`quay.io/cdis/docker-bitnami-pgvector:16`, a CDIS-maintained
mirror) works without credentials and includes the pgvector extension.

---

# 🔑 Mock auth, API keys, and gen3-sdk submission

With `fence.FENCE_CONFIG.MOCK_GOOGLE_AUTH: true` set, you can log in as any
username without real Google credentials by setting the `dev_login` cookie
before hitting the login endpoint:

    curl -k -c cookies.txt -b "dev_login=username1@gmail.com" \
      "https://gen3.apps-crc.testing/user/login/google?redirect=/"

The username you pick matters: fence just authenticates it, but
**authorization comes from `user.yaml`** (loaded by the `useryaml` Job into
the `useryaml` ConfigMap). The chart's default sample `user.yaml` only grants
submitter policies (`MyFirstProject_submitter`, `sheepdog-admin`, etc.) to
`username1@gmail.com` — logging in as the default mock user
(`test@example.com`) gets you `open_data_reader` only, which can't create
programs/projects/records. Check what's actually loaded with:

    kubectl get cm useryaml -o jsonpath='{.data.useryaml}'

## Minting an API key for scripted access

The portal/frontend "Create an API Key" button calls
`POST /user/credentials/api` while authenticated — that's the normal path
for a human. For scripting or CI, you can mint a token directly inside the
fence pod without a browser:

    # access token (short-lived, for one-off calls) - needs the "credentials"
    # scope specifically if you're about to call /user/credentials/api with it
    kubectl exec deploy/fence-deployment -- fence-create token-create \
      --type access --username username1@gmail.com \
      --scopes openid,user,data,admin,credentials

    # exchange that token for a long-lived API key (refresh token)
    curl -k -X POST "https://gen3.apps-crc.testing/user/credentials/api" \
      -H "Authorization: bearer <access-token-from-above>" \
      -H "Content-Type: application/json" -d '{}'
    # => {"api_key": "<refresh-token-jwt>", "key_id": "..."}

Save that response as `credentials.json` for `gen3-sdk`'s
`Gen3Auth(refresh_file=...)`.

## gen3-sdk and the Route's TLS certificate

If your Route host isn't under the cluster's real router wildcard domain
(see the Route section above), `gen3-sdk`'s `Gen3Auth`/`Gen3Submission` will
fail with `SSLCertVerificationError` — unlike `curl -k`, the SDK has no
built-in flag to skip verification. For a disposable dev cluster, the
practical workaround is to globally disable `requests` verification for the
session (never do this against a real endpoint):

    import urllib3, requests
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    _orig = requests.Session.request
    requests.Session.request = lambda self, *a, **kw: _orig(self, *a, **{**kw, "verify": False})

## End-to-end submission

Programs and projects declared in `user.yaml`'s `policies` block don't
actually exist as sheepdog nodes until you create them — the policy just
pre-authorizes the path. A full bootstrap looks like:

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

Verify with a GraphQL read against peregrine:

    curl -k "https://gen3.apps-crc.testing/api/v0/submission/graphql" \
      -H "Authorization: bearer <access-token>" -H "Content-Type: application/json" \
      -d '{"query":"{ experiment { submitter_id project_id } }"}'

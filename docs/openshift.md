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
    helm upgrade --install gen3 gen3 -f ../examples/openshift_values.yaml -n openshift-gen3

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

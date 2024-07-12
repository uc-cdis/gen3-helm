{{- define "common.jwt_public_key_setup_sa" -}}

apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Chart.Name }}-jwt-public-key-patch-sa

---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ .Chart.Name }}-jwt-public-key-patch-role
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["*"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ .Chart.Name }}-jwt-public-key-patch-rolebinding
subjects:
- kind: ServiceAccount
  name: {{ .Chart.Name }}-jwt-public-key-patch-sa
  namespace: {{ .Release.Namespace }}
roleRef:
  kind: Role
  name: {{ .Chart.Name }}-jwt-public-key-patch-role
  apiGroup: rbac.authorization.k8s.io


{{- end }}

---

{{- define "common.create_public_key_job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Chart.Name }}-create-public-key
  labels:
    app: gen3job
spec:
  template:
    spec:
      serviceAccountName: {{ .Chart.Name }}-jwt-public-key-patch-sa
      containers:
      - name: public-key-gen
        image: bitnami/kubectl:latest
        env:
          - name: PRIVATE_KEY_PEM
            valueFrom:
              secretKeyRef:
                name: {{ .Chart.Name }}-jwt-keys
                key: jwt_private_key.pem
                optional: false
          - name: SERVICE
            value: {{ .Chart.Name }}
        command: ["/bin/sh", "-c"]
        args:
          - |
            set -e

            echo "SERVICE=$SERVICE"

            # Read the private key from the secret
            private_key=$(kubectl get secret $SERVICE-jwt-keys -o jsonpath='{.data.jwt_private_key\.pem}' | base64 --decode)

            # Create a temporary file for the private key
            echo "${private_key}" > /tmp/private_key.pem

            # Generate the public key from the private key
            openssl rsa -in /tmp/private_key.pem -pubout -out /tmp/public_key.pem

            # Base64 encode the public key
            public_key=$(base64 -w 0 /tmp/public_key.pem)

            # Update the secret with the public key
            kubectl patch secret $SERVICE-jwt-keys -p="{\"data\": {\"jwt_public_key.pem\": \"${public_key}\"}}"
        
      restartPolicy: OnFailure
{{- end }}
---

{{/*
Create k8s secrets for creating jwt key pairs
*/}}
# JWT key Secrets
{{- define "common.jwt-key-pair-secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $.Chart.Name }}-jwt-keys
type: Opaque
data:
  jwt_private_key.pem: {{ genPrivateKey "rsa" | b64enc | quote }}
{{- end }}
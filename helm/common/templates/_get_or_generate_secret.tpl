{{/*
Helper function to generate or retrieve a secret value.

This function takes the following parameters:
- `value` (optional): The secret value to use if it's not empty. If this parameter is set, the function will return this value without looking up or generating a new one.
- `secretName` (optional): The name of the secret that contains the value. If `value` is not set, the function will attempt to retrieve the value from this secret. If this parameter is not set or the secret does not exist, a new value will be generated.
- `secretKey` (optional): The key in the secret that contains the value. If `value` is not set and `secretName` is set, the function will attempt to retrieve the value from this key in the secret. If this parameter is not set or the key does not exist in the secret, a new value will be generated.
- `secretLength` (optional, default 20): The length of the value to generate if it needs to be generated.

Usage:
{{ include "common.getOrGenSecret" (list "mysecretvalue" "mysecret" "mysecretkey" 16 .) }}
*/}}
{{- define "common.getOrGenSecret" -}}
{{- $value := index . 0 -}}
{{- $secretName := index . 1 -}}
{{- $secretKey := index . 2 -}}
{{- $secretLength := index . 3 -}}
{{- $nameSpace := index . 4 -}}
{{- if $value -}}
{{- $value = $value | b64enc -}}
{{- end -}}
{{- if not $value -}}
  {{- if $secret := lookup "v1" "Secret" $nameSpace $secretName -}}
    {{- if hasKey $secret.data $secretKey -}}
        {{- $value = index $secret.data $secretKey  -}}
    {{- end -}}
  {{- end -}}
  {{- if not $value -}}
    {{- $value = randAlphaNum $secretLength -}}
    {{- $value = $value | b64enc -}}
  {{- end -}}
{{- end -}}
{{- $value -}}
{{- end -}}

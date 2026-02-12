{{ define "common.cronjob" -}}
{{- $root := . }}

{{- with .Values.cronjobs }}
{{- range . }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ .name }}
spec:
  schedule: {{ .schedule | default "*/5 * * * *" | quote }}
  successfulJobsHistoryLimit: {{ .successfulJobsHistoryLimit | default 2 }}
  failedJobsHistoryLimit: {{ .failedJobsHistoryLimit | default 2 }}
  concurrencyPolicy: {{ .concurrencyPolicy | default "Forbid" }}
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: "gen3job"
        spec:
          {{- if .affinityOverride }}
          affinity:
{{ toYaml .affinityOverride | indent 12 }}
          {{- else }}
          affinity:
            nodeAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
                - weight: 100
                  preference:
                    matchExpressions:
                      - key: karpenter.sh/capacity-type
                        operator: In
                        values:
                          - on-demand
                - weight: 99
                  preference:
                    matchExpressions:
                      - key: eks.amazonaws.com/capacityType
                        operator: In
                        values:
                          - ONDEMAND
          {{- end }}

          automountServiceAccountToken: {{ .automountServiceAccountToken | default false }}

          containers:
            - name: {{ .containerName | default $root.Chart.Name }}
              image: "{{ ((default dict .image).repository | default $root.Values.image.repository) }}:{{ ((default dict .image).tag | default (default $root.Values.image.tag $root.Chart.AppVersion)) }}"
              imagePullPolicy: {{ (default dict .image).pullPolicy | default "Always" }}

              env:
                {{- if .envFromApp | default true }}
                {{- with $root.Values.env }}
                {{- toYaml . | nindent 16 }}
                {{- end }}
                {{- end }}
                {{- with .extraEnv }}
                {{- toYaml . | nindent 16 }}
                {{- end }}
                {{- if $root.Values.dbService  }}
                {{ include "common.db-env" $root | nindent 16}}
                {{- end }}

              command:
                {{- range .command | default (list "sh") }}
                - {{ . | quote }}
                {{- end }}

              args:
                {{- range .args | default (list "-c" "/go/src/github.com/uc-cdis/arborist/jobs/delete_expired_access") }}
                - {{ . | quote }}
                {{- end }}

          restartPolicy: {{ .restartPolicy | default "Never" }}

          dnsPolicy: {{ .dnsPolicy | default "ClusterFirst" }}
          {{- with .dnsConfig }}
          dnsConfig:
{{ toYaml . | indent 12 }}
          {{- end }}
{{- end }}
{{- end }}
{{- end }}
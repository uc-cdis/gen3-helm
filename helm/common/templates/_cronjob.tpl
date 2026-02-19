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
            app: gen3job
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
            {{- if (.envFromApp | default true) }}
            {{- with $root.Values.env }}
            {{ toYaml . | nindent 12 -}}
            {{- end }}
            {{- end }}

            {{- with .extraEnv }}
            {{ toYaml . | nindent 12 -}}
            {{- end }}
            {{- if $root.Values.dbService }}
            {{ include "common.db-env" $root | nindent 12 -}}
            {{- end }}
            command:
              {{- if .command }}
              {{- range .command }}
              - {{ . | quote }}
              {{- end }}
              {{- end }}
            args:
              {{- if .args }}
              {{- range .args }}
              {{- if contains "\n" . }}
              - |-
{{ . | nindent 16 -}}
              {{- else }}
              - {{ . | quote }}
              {{- end }}
              {{- end }}
              {{- end }}
          restartPolicy: {{ .restartPolicy | default "Never" }}
          {{- with .dnsConfig }}
          dnsConfig:
{{ toYaml . | indent 12 }}
          {{- end }}
          dnsPolicy: {{ .dnsPolicy | default "ClusterFirst" }}
{{- end }}
{{- end }}
{{- end }}
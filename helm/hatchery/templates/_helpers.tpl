{{/*
Expand the name of the chart.
*/}}
{{- define "hatchery.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hatchery.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hatchery.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hatchery.labels" -}}
{{- if .Values.commonLabels }}
    {{- with .Values.commonLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.commonLabels" .)}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hatchery.selectorLabels" -}}
{{- if .Values.selectorLabels }}
    {{- with .Values.selectorLabels }}
    {{- toYaml . }}
    {{- end }}
{{- else }}
  {{- (include "common.selectorLabels" .)}}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hatchery.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hatchery.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the jupyter namespace
*/}}
{{- define "hatchery.jupyterNamespace" -}}
{{- $defaultVal := printf "jupyter-pods-%s" .Release.Namespace }}
{{- default $defaultVal .Values.jupyterNamespace}}
{{- end }}


{{/*
  Stata g3 Auto Secrets Manager Name
*/}}
{{- define "stata-workspace-gen3-license" -}}
{{- default "stata-workspace-gen3-license" .Values.externalSecrets.stataG3auto }}
{{- end }}

{{/*
JSON list of the workspace images the hot-node prepullers pull. Resolved from the same inputs as
the manifest-hatchery ConfigMap so the prepuller doesn't have to look them up when its pod starts.
*/}}
{{- define "hatchery.prepullImages" -}}
{{- $containers := list -}}
{{- if .Values.hatchery.json -}}
  {{- $manifest := .Values.hatchery.json | fromJson -}}
  {{- if hasKey $manifest "Error" -}}
    {{- fail (printf "hatchery.json is not valid JSON: %s" $manifest.Error) -}}
  {{- end -}}
  {{- $containers = $manifest.containers | default list -}}
{{- else -}}
  {{- $containers = tpl (.Values.hatchery.containers | toJson) . | fromJsonArray -}}
{{- end -}}
{{- $images := list -}}
{{- range $containers -}}
  {{- if .image -}}
    {{- $images = append $images .image -}}
  {{- end -}}
{{- end -}}
{{- $images | uniq | toJson -}}
{{- end }}

{{/*
Job that pulls every workspace image onto the node it is pinned to. Takes a dict of:
  root:        the chart's root context
  app:         value of the `app` label
  tolerations: list of tolerations for the node group
Everything is rendered here except $JOB_NAME and $NODE_NAME, which the hot-node init container
fills in with envsubst, so the ConfigMap holding this (and its hash) only changes when the chart
inputs change.
*/}}
{{- define "hatchery.prepullJob" -}}
{{- $images := include "hatchery.prepullImages" .root | fromJsonArray -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
  labels:
    app: {{ .app }}
spec:
  template:
    metadata:
      labels:
        app: {{ .app }}
    spec:
      nodeName: $NODE_NAME
      restartPolicy: Never
      tolerations:
        {{- toYaml .tolerations | nindent 8 }}
      terminationGracePeriodSeconds: 0
      automountServiceAccountToken: false
      containers:
      - name: pause
        image: busybox:latest
        command:
          - /bin/sh
          - -c
          - exit 0
      {{- with $images }}
      initContainers:
        {{- range $i, $image := . }}
      - name: image-{{ $i }}
        image: {{ $image | quote }}
        imagePullPolicy: IfNotPresent
        command:
          - /bin/sh
          - -c
          - echo 'Pulling complete'
        {{- end }}
      {{- end }}
{{- end }}
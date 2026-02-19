{{ define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.name" . }}-deployment
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
      {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
        {{- $metricsEnabled := .Values.metricsEnabled }}
      {{- if eq $metricsEnabled nil }}
        {{- $metricsEnabled = .Values.global.metricsEnabled }}
      {{- end }}
      {{- if eq $metricsEnabled nil }}
        {{- $metricsEnabled = true }}
      {{- end }}

      {{- if $metricsEnabled }}
        {{- include "common.grafanaAnnotations" . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "common.extraLabels" . | nindent 8 }}
        {{- include "app.selectorLabels" . | nindent 8 }}
    spec:
      {{- if .Values.global.topologySpread.enabled }}
      {{- include "common.TopologySpread" . | nindent 6 }}
      {{- end }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "app.serviceAccountName" . }}-sa
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path  | default "/_status" }}
              port: http
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds | default 30 }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 60 }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds | default 10 }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path | default "/_status" }}
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- toYaml .Values.env | nindent 12 }}
          {{- if .Values.dbService }}
          {{ include "common.db-env" . | nindent 12}}
          {{- end }}
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml .Values.volumeMounts | nindent 12 }}
          {{- end }}
          command:
            {{- if .Values.command}}
            - {{ .Values.command | quote }}
            {{- end }}
          args:
            {{- if .Values.args }}
            {{- if kindIs "string" .Values.args }}
            {{- if contains "\n" .Values.args }}
            - |-
{{ .Values.args | nindent 14 -}}
            {{- else }}
            - {{ .Values.args | quote }}
            {{- end }}
            {{- else }}
{{ toYaml .Values.args | nindent 12 }}
            {{- end }}
            {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
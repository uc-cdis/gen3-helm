{{/*
    Gen3 Karpenter Topology Spread Constraints
    This will help spread pods across topology domains such as zones to improve availability.
    Will use the subchart's name.
*/}}
{{- define "common.TopologySpread" -}}
topologySpreadConstraints:
  - maxSkew: {{ .Values.global.topologySpread.maxSkew | default 1 }}
    topologyKey: {{ .Values.global.topologySpread.topologyKey | default "topology.kubernetes.io/zone" }}
    whenUnsatisfiable: {{ .Values.global.topologySpread.whenUnsatisfiable | default "ScheduleAnyway" }}
    labelSelector:
      matchLabels:
        app: {{ .Chart.Name }}
{{- end }}

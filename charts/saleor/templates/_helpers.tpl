{{- define "saleor.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{- define "saleor.labels" -}}
{{ include "saleor.selectorLabels" . }}
app.kubernetes.io/component: {{ .component }}
app.kubernetes.io/part-of: acdp
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .root.Chart.Name .root.Chart.Version }}
{{- end }}

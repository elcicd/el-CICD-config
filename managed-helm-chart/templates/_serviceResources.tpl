{{/*
Service
*/}}
{{- define "elCicdChart.service" }}
{{- $ := index . 0 }}
{{- $svcValues := index . 1 }}
{{- if or $svcValues.prometheusPort $.Values.usePrometheus }}
  {{- $_ := set $svcValues "annotations" ($svcValues.annotations  | dict) }}
  {{- $_ := set $svcValues.annotations "prometheus.io/path" ($svcValues.prometheusPath | default $.Values.defaultPrometheusPath) }}
  {{- $_ := set $svcValues.annotations "prometheus.io/port" ($svcValues.prometheusPort | default $.Values.defaultPrometheusPort) }}
  {{- $_ := set $svcValues.annotations "prometheus.io/scheme" ($svcValues.prometheusScheme | default $.Values.defaultPrometheusScheme) }}
  {{- $_ := set $svcValues.annotations "prometheus.io/scrape" ($svcValues.prometheusScrape | default $.Values.defaultPrometheusScrape) }}
{{- end }}
{{- if or $svcValues.use3Scale $.Values.use3Scale }}
  {{- $_ := set $svcValues "annotations" ($svcValues.annotations  | dict) }}
  {{- $_ := set $svcValues.annotations "discovery.3scale.net/path" ($svcValues.3ScalePort | default $svcValues.port | default $.Values.defaultPort) }}
  {{- $_ := set $svcValues.annotations "discovery.3scale.net/port" ($svcValues.3ScalePath | default $.Values.default3ScalePath) }}
  {{- $_ := set $svcValues.annotations "discovery.3scale.net/scheme" ($svcValues.3ScaleScheme | default $.Values.default3ScaleScheme) }}
  {{- $_ := set $svcValues "labels" ($svcValues.labels  | dict) }}
  {{- $_ := set $svcValues.labels "discovery.3scale.net" true }}
{{- end }}
---
{{- $_ := set $svcValues "kind" "Service" }}
{{- $_ := set $svcValues "apiVersion" "v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  selector:
    {{- include "elCicdChart.selectorLabels" $ | nindent 4 }}
    app: {{ $svcValues.appName }}
  ports:
  {{- if $svcValues.servicePorts }}
    {{- $svcValues.servicePorts | toYaml | indent 2}}
  {{- else }}
  - port: {{ $svcValues.port | default $.Values.defaultPort }}
    targetPort: {{ $svcValues.port | default $.Values.defaultPort }}
    protocol: {{ $svcValues.serviceProtocol | default $.Values.defaultProtocol }}
  {{- end }}
  {{- if or $svcValues.prometheusPort $.Values.usePrometheus }}
      - name: {{ $svcValues.appName }}-prometheus-port
        port: {{ $svcValues.prometheusPort | default $.Values.defaultPrometheusPort }}
        targetPort: {{ $svcValues.prometheusPort | default $.Values.defaultPrometheusPort }}
        protocol: {{ $svcValues.prometheusProtocol | default $.Values.defaultPrometheusProtocol }}
  {{- end
{{- end }}

{{/*
Ingress
*/}}
{{- define "elCicdChart.ingress" }}
{{- $ := index . 0 }}
{{- $ingressValues := index . 1 }}
---
{{- $_ := set $ingressValues "kind" "Ingress" }}
{{- $_ := set $ingressValues "apiVersion" "networking.k8s.io/v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  {{- if $ingressValues.defaultBackend }}
  defaultBackend: {{ $ingressValues.defaultBackend | toYaml | nindent 4 }}
  {{- end }}
  {{- if $ingressValues.ingressClassName }}
  ingressClassName: {{ $ingressValues.ingressClassName }}
  {{- end }}
  {{- if $ingressValues.rules }}
  rules: {{ $ingressValues.rules | toYaml | nindent 4 }}
  {{- else }}
  rules:
  - host: {{ $ingressValues.host | default $.Values.defaultIngressHost }}
    http:
      paths:
      - path: {{ $ingressValues.path | default $.Values.defaultIngressRulePath }}
        pathType: {{ $ingressValues.pathType | default $.Values.defaultIngressRulePathType }}
        backend:
          service:
            name: {{ $ingressValues.appName }}
            port:
              number: {{ $ingressValues.port | default $.Values.defaultPort }}
  {{- end }}
  {{- if $ingressValues.tls }}
  tls: {{ $ingressValues.tls | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
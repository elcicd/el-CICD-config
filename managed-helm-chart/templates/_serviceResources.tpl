{{/*
Service
*/}}
{{- define "elCicdChart.service" }}
{{- $ := index . 0 }}
{{- $svcValues := index . 1 }}
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
  - host: {{ $ingressValues.host | $.Values.defaultIngressHost }}
    http:
      paths:
      - path: {{ $ingressValues.path | $.Values.defaultIngressRulePath }}
        pathType: {{ $ingressValues.pathType | $.Values.defaultIngressRulePathType }}
        backend:
          service:
            name: {{ $ingressValues.appName }}
            port:
              number: {{ $ingressValues.port | $.Values.defaultPort }}
  {{- end }}
  {{- if $ingressValues.tls }}
  tls: {{ $ingressValues.tls | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
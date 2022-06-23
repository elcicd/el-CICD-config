{{- define "elCicdChart.deploymentService" }}
  {{- include "elCicdChart.deployment" . }}
  {{- include "elCicdChart.service" . }}
{{- end }}

{{- define "elCicdChart.deployment" }}
{{- $ := index . 0 }}
{{- $template := index . 1 }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ if not $template.generateAppName }}{{ $template.appName }}{{- end }}
  generateName: {{ $template.generateAppName }}
  labels:
    {{- include "elCicdChart.labels" $ | nindent 4 }}
    app: {{ $template.appName }}
    {{- if $template.labels}}{{- $template.labels | indent 4 }}{{- end }}
    {{- if $.Values.labels}}{{- $.Values.labels | indent 4 }}{{- end }}
  annotations: 
    {{- if $template.annotations}}{{- $template.annotations | indent 4 }}{{- end }}
    {{- if $.Values.annotations}}{{- $.Values.annotations | indent 4 }}{{- end }}
spec:
  replicas: {{ $template.replicas | default $.Values.defaultReplicas }}
  minReadySeconds: {{ $template.minReadySeconds | default $.Values.minReadySeconds }}
  selector:
    matchExpressions:
    - key: projectid
      operator: Exists
    - key: microservice
      operator: Exists
    - key: app
      operator: Exists
    matchLabels:
      {{- include "elCicdChart.selectorLabels" $ | nindent 6 }}
      app: {{ $template.appName }}
  strategy:
    rollingUpdate:
      maxSurge: {{ $template.rollingUpdateMaxSurge }}
      maxUnavailable: {{ $template.rollingUpdateMaxUnavailable }}
    type: {{ $template.strategyType }}
  template:
    metadata:
      labels:
        {{- include "elCicdChart.labels" $ | nindent 8 }}
        app: {{ $template.appName }}
        {{- if $template.labels }}{{- $template.labels | indent 8 }}{{- end }}
        {{- if $.Values.labels }}{{- $.Values.labels | indent 8 }}{{- end }}
    spec:
      containers:
        {{- $_ := set $template "sidecars" ($template.sidecars | default list) }}
        {{- $containers := prepend $template.sidecars $template }}
        {{- include "elCicdChart.container" (list $ $containers) | trim | nindent 6 }}
      volumes: {{ include "elCicdChart.mergeLists"  (list $template "volumes") | indent 4 }}
      restartPolicy: {{ $template.restartPolicy }}
      imagePullSecrets:
      - name: {{ $.Values.pullSecret }}
{{- end }}

{{- define "elCicdChart.service" }}
  {{- $ := index . 0 }}
  {{- $template := index . 1 }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $template.appName }}
  annotations:
    {{- if ($template.prometheus).enabled }}{{- include "elCicdChart.prometheusAnnotations" $ | nindent 4 }}{{- end }}
    {{- if ($template.scale3).enabled }}{{- include "elCicdChart.scaleAnnotations" $ | nindent 4 }}{{- end }}
  labels:
    {{- include "elCicdChart.labels" $ | nindent 4 }}
    app: {{ $template.appName }}
    {{- if ($template.scale3).enabled }}
      {{- include "elCicdChart.scaleLabels" $ | nindent 4 }}
    {{- end }}
spec:
  selector:
    {{- include "elCicdChart.selectorLabels" $ | nindent 4 }}
    app: {{ $template.appName }}
  ports:
  - name:
    port: {{ $template.servicePort | default $.Values.defaultPort }}
    targetPort: {{ $template.servicePort | default $.Values.defaultPort }}
    protocol: {{ $template.portProtocol | default $.Values.defaultProtocol }}
{{- end }}
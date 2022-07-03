{{/*
Api Object Header and Metadata
*/}}
{{- define "elCicdChart.apiObjectHeader" }}
{{- $ := index . 0 }}
{{- $headerValues := index . 1 }}
apiVersion: {{ $headerValues.apiVersion }}
kind: {{ $headerValues.kind }}
{{- include "elCicdChart.apiMetadata" }}
{{- end }}

{{- define "elCicdChart.apiMetadata" }}
{{- $ := index . 0 }}
{{- $metadataValues := index . 1 }}
metadata:
  annotations:
    {{- $annotations := ($metadataValues.profileVals).annotations | default $metadataValues.annotations }}
    {{- if $annotations }}{{- $annotations | indent 4 }}{{- end }}
    {{- if $.Values.defaultAnnotations}}{{- $.Values.defaultAnnotations | toYaml | indent 4 }}{{- end }}
  labels:
    {{- include "elCicdChart.labels" $ | nindent 4 }}
    app: {{ $metadataValues.appName }}
    {{- if $metadataValues.labels}}{{- $metadataValues.labels | indent 4 }}{{- end }}
    {{- if $.Values.labels}}{{- $.Values.labels | indent 4 }}{{- end }}
  name: {{ required "Unnamed apiObject Name!" $metadataValues.appName }}
  namespace: {{ $.Values.namespace | default $.Release.Namespace}}
{{- end }}

{{/*
Deployment and Service combination
*/}}
{{- define "elCicdChart.deploymentService" }}
  {{- include "elCicdChart.deployment" (append . true)  }}
  {{- include "elCicdChart.service" . }}
{{- end }}

{{/*
el-CICD Selector
*/}}
{{- define "elCicdChart.workloadSelector" }}
{{- $ := index . 0 }}
{{- $workloadValues := index . 1 }}
selector:
  matchExpressions:
  - key: projectid
    operator: Exists
  - key: microservice
    operator: Exists
  - key: app
    operator: Exists
  matchLabels:
    {{- include "elCicdChart.selectorLabels" $ | nindent 4 }}
    app: {{ $workloadValues.appName }}
{{- end }}
      
{{/*
Container definition
*/}}
{{- define "elCicdChart.containers" }}
{{- $ := index . 0 }}
{{- $containers := index . 1 }}
{{- $hasService := false }}
{{- if eq (len .) 4 }}
  {{- $hasService = index . 3 }}
{{- end }}

{{- range $containerVals := $containers }}
  {{- range $profile := $.Values.profiles }}
    {{- include "elCicdChart.mergeProfile" (list $ $containerVals $profile) }}
  {{- end }}
- name: {{ $containerVals.appName }}
  image: {{ $containerVals.image | default (include "elCicdChart.microServiceImage" $) }}
 {{- if $containerVals.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $containerVals.activeDeadlineSeconds | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.args }}
  args: {{ $containerVals.args | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.command }}
  command: {{ $containerVals.command | toYaml | nindent 2 }}
  {{- end }}
  imagePullPolicy: {{ $containerVals.imagePullPolicy | default $.Values.defaultImagePullPolicy }}
  {{- if $containerVals.env }}
  env: {{ $containerVals.env | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.envFrom }}
  envFrom: {{ $containerVals.envFrom | toYaml | nindent 2 }}
  {{- end }}
  {{- if or $hasService $containerVals.containerPorts }}
  ports:
  {{- if $containerVals.containerPorts }}
    {{- $containerVals.containerPorts | toYaml | nindent 2 }}
  {{- else if (eq $hasService true)}}
    {{- $hasService = false }}
  - containerPort: {{ $containerVals.port | default $.Values.defaultPort }}
    protocol: {{ $containerVals.protocol | default $.Values.defaultProtocol }}
  {{- end }}
  {{- end }}
  {{- if $containerVals.readinessProbe }}
  readinessProbe: {{ $containerVals.readinessProbe | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.startupProbe }}
  startupProbe: {{ $containerVals.startupProbe | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.livenessProbe }}
  livenessProbe: {{ $containerVals.livenessProbe | toYaml | nindent 2 }}
  {{- end }}
  resources:
    limits:
      cpu: {{ (($containerVals.resources).limits).cpu | default $.Values.defaultLimitsCpu }}
      memory: {{ (($containerVals.resources).limits).memory | default $.Values.defaultLimitsMemory }}
    requests:
      cpu: {{ (($containerVals.resources).requests).cpu | default $.Values.defaultRequestsCpu}}
      memory: {{ (($containerVals.resources).requests).memory | default $.Values.defaultRequestsMemory }}
  {{- if $containerVals.volumeMounts }}
  volumeMounts: {{ $containerVals.volumeMounts | toYaml | nindent 2 }}
  {{- end }}
  {{- if or ($containerVals.profileVals).workingDir $containerVals.defaultWorkingDir }}
  workingDir: {{ ($containerVals.profileVals).workingDir | default $containerVals.defaultWorkingDir }}
  {{- end }}
  {{- if $containerVals.supplemental }}
    {{- $containerVals.supplemental | toYaml | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Default image definition
*/}}
{{- define "elCicdChart.microServiceImage" }}
{{- $.Values.imageRepository }}/{{- $.Values.projectId }}-{{- $.Values.microService }}:{{- $.Values.imageTag }}
{{- end }}

{{/*
HorizontalPodAutoscaler Metrics
*/}}
{{- define "elCicdChart.hpaMetrics" }}
{{- $ := index . 0 }}
{{- $metrics := index . 1 }}
metrics:
{{- range $metric := $metrics }}
- type: {{ $metric.type }}
  {{- lower $metric.type | indent 2 }}:
    metric:
      name: {{ $metric.name }}
      {{- if $metric.selector }}
      selector: {{ $metric.selector | toYaml | nindent 6}}
      {{- end }}
    target: {{- $metric.target | toYaml | nindent 4 }}
    {{- if $metric.describedObject }}
    describedObject: {{- $metric.describedObject | toYaml | nindent 4 }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Pod Template
*/}}
{{- define "elCicdChart.podTemplate" }}
{{- $ := index . 0 }}
{{- $podValues := index . 1 }}
{{- $hasService := index . 2 }}
{{- include "elCicdChart.apiMetadata" . }}
spec:
  {{- if $podValues.restartPolicy }}
  restartPolicy: {{ $podValues.restartPolicy }}
  {{- end }}
  imagePullSecrets:
  - name: {{ $.Values.pullSecret }}
  {{- if $podValues.pullSecrets }}
  {{- range $secretName := $podValues.pullSecrets }}
  - name: {{ $secretName }}
  {{- end }}
  {{- end }}
  containers:
    {{- $containers := prepend ($podValues.sidecars | default list) $podValues }}
    {{- include "elCicdChart.containers" (list $ $containers $hasService) | trim | nindent 2 }}
  {{- if $podValues.volumes }}
  volumes: {{- $podValues.volumes | toYaml | nindent 6 }}
  {{- end }}
{{- end }}

{{/*
Job Template
*/}}
{{- define "elCicdChart.jobTemplate" }}
{{- $ := index . 0 }}
{{- $jobValues := index . 1 }}
  {{- if $jobValues.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $jobValues.activeDeadlineSeconds }}
  {{- end }}
  {{- if $jobValues.activeDeadlineSeconds }}
  backoffLimit: {{ $jobValues.activeDeadlineSeconds }}
  {{- end }}
  {{- if $jobValues.completionMode }}
  completionMode: {{ $jobValues.completionMode }}
  {{- end }}
  {{- if $jobValues.completions }}
  completions: {{ $jobValues.completions }}
  {{- end }}
  {{- if $jobValues.manualSelector }}
  manualSelector: {{ $jobValues.manualSelector }}
  {{- end }}
  {{- if $jobValues.parallelism }}
  parallelism: {{ $jobValues.parallelism }}
  {{- end }}
  {{- if $jobValues.selector }}
  selector: {{ $jobValues.selector | toYaml | nindent 4 }}
  {{- end }}
  {{- if $jobValues.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ $jobValues.ttlSecondsAfterFinished }}
  {{- end }}
  template:
    {{- include "elCicdChart.podTemplate" list ($ $jobValues false) | indent 6 }}
{{- end }}

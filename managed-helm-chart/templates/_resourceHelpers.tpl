{{/*
Deployment [Short name]
*/}}
{{- define "elCicdChart.deploy" }}
  {{- include "elCicdChart.deployment" . }}
{{- end }}

{{/*
Deployment and Service combination
*/}}
{{- define "elCicdChart.deploymentService" }}
  {{- include "elCicdChart.deployment" (append . true)  }}
  {{- include "elCicdChart.service" . }}
{{- end }}

{{/*
CronJob [Short name]
*/}}
{{- define "elCicdChart.cj" }}
  {{- include "elCicdChart.cronjob" . }}
{{- end }}

{{/*
Stateful Set [Short name]
*/}}
{{- define "elCicdChart.sts" }}
  {{- include "elCicdChart.statefulset" . }}
{{- end }}

{{/*
HorizontalPodAutoscaler [Short name]
*/}}
{{- define "elCicdChart.hpa" }}
  {{- include "elCicdChart.horizontalPodAutoscaler" . }}
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
Job Template
*/}}
{{- define "elCicdChart.jobTemplate" }}
{{- $ := index . 0 }}
{{- $jobValues := index . 1 }}
{{- include "elCicdChart.apiMetadata" . }}
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
  selector: {{ include "elCicdChart.selector" (list $ $jobValues.appName) | indent 4 }}
  template: {{ include "elCicdChart.podTemplate" list ($ $jobValues false) | nindent 4 }}
  {{- if $jobValues.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ $jobValues.ttlSecondsAfterFinished }}
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
  {{- if $podValues.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $podValues.activeDeadlineSeconds }}
  {{- end }}
  {{- if $podValues.affinity }}
  affinity: {{ $podValues.affinity | toYaml | nindent 4 }}
  {{- end }}
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
  {{- if $podValues.ephemeralContainers }} 
  ephemeralContainers:
    {{- include "elCicdChart.ephemeralContainers" (list $ $podValues.ephemeralContainers false) | trim | nindent 2 }}
  {{- end }}
  {{- if $podValues.initContainers }} 
  initContainers:
    {{- include "elCicdChart.initContainers" (list $ $podValues.initContainers false) | trim | nindent 2 }}
  {{- end }}
  containers:
    {{- $containers := prepend ($podValues.sidecars | default list) $podValues }}
    {{- include "elCicdChart.containers" (list $ $containers $hasService) | trim | nindent 2 }}
  {{- if $podValues.volumes }}
  volumes: {{- $podValues.volumes | toYaml | nindent 2 }}
  {{- end }}
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
  {{- if $containerVals.lifecycle }}
  lifecycle: {{ $containerVals.lifecycle | toYaml | nindent 4 }}
  {{- end }}}
  {{- if $containerVals.livenessProbe }}
  livenessProbe: {{ $containerVals.livenessProbe | toYaml | nindent 2 }}
  {{- end }}
  {{- if or $containerVals.containerPort $hasService }}
  ports:
    {{- if or $containerVals.containerPort }}
      {{- $containerVals.containerPorts | toYaml | nindent 2 }}
    {{- else }}
      {{- $hasService = false }}
  - containerPort: {{ $containerVals.port | default $.Values.defaultPort }}
    protocol: {{ $containerVals.protocol | default $.Values.defaultProtocol }}
    {{- end }}
    {{- if $containerVals.prometheusPort }}
  - containerPort: {{ $containerVals.prometheusPort | default $.Values.defaultPrometheusPort }}
    protocol: {{ $containerVals.prometheusProtocol | default $.Values.defaultPrometheusProtocol }}
    {{- end }}
  {{- end }}
  {{- if $containerVals.readinessProbe }}
  readinessProbe: {{ $containerVals.readinessProbe | toYaml | nindent 2 }}
  {{- end }}
  resources:
    limits:
      cpu: {{ (($containerVals.resources).limits).cpu | default $.Values.defaultLimitsCpu }}
      memory: {{ (($containerVals.resources).limits).memory | default $.Values.defaultLimitsMemory }}
    requests:
      cpu: {{ (($containerVals.resources).requests).cpu | default $.Values.defaultRequestsCpu}}
      memory: {{ (($containerVals.resources).requests).memory | default $.Values.defaultRequestsMemory }}
  {{- if $containerVals.startupProbe }}
  startupProbe: {{ $containerVals.startupProbe | toYaml | nindent 2 }}
  {{- end }}
  {{- if $containerVals.stdin }}
  stdin: {{ $containerVals.stdin }}
  {{- end }}
  {{- if $containerVals.stdinOnce }}
  stdinOnce: {{ $containerVals.stdinOnce }}
  {{- end }}
  {{- if $containerVals.tty }}
  tty: {{ $containerVals.tty }}
  {{- end }}
  {{- if $containerVals.volumeDevices }}
  volumeDevices: {{ $containerVals.volumeDevices | toYaml | nindent 2 }}
  {{- end }}
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
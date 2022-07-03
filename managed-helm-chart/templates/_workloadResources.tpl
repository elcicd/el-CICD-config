

{{/*
Deployment [Short name]
*/}}
{{- define "elCicdChart.deploy" }}
  {{- include "elCicdChart.deployment" . }}
{{- end }}

{{/*
Deployment
*/}}
{{- define "elCicdChart.deployment" }}
{{- $ := index . 0 }}
{{- $deployValues := index . 1 }}
{{- $hasService := (((len .) | eq 3) | and (index . 2)) }}
---
{{- $_ := set $deployValues "kind" "Deployment" }}
{{- $_ := set $deployValues "apiVersion" "apps/v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  replicas: {{ $deployValues.replicas | default $.Values.defaultReplicas }}
  minReadySeconds: {{ $deployValues.minReadySeconds | default $.Values.minReadySeconds }}
  {{- include "elCicdChart.workloadSelector" (list $ $deployValues) | indent 2 }}
  {{- if $deployValues.strategyType }}
  strategy:
    {{- if (eq $deployValues.strategyType "RollingUpdate") }}
    rollingUpdate:
      maxSurge: {{ $deployValues.rollingUpdateMaxSurge | default $.Values.defaultRollingUpdateMaxSurge }}
      maxUnavailable: {{ $deployValues.rollingUpdateMaxUnavailable | default $.Values.defaultRollingUpdateMaxUnavailable }}
    {{- end }}
    type: {{ $deployValues.strategyType }}
    {{- end }}
    template:
    {{- include "elCicdChart.podTemplate" (list $ $deployValues $hasService) | indent 6 }}
  {{- if $deployValues.deploySupplemental }}
    {{- $deployValues.deploySupplemental | toYaml | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Job
*/}}
{{- define "elCicdChart.job" }}
{{- $ := index . 0 }}
{{- $jobValues := index . 1 }}
---
{{- $_ := set $jobValues "kind" "Job" }}
{{- $_ := set $jobValues "apiVersion" "batch/v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
{{- include "elCicdChart.jobTemplate" }}
{{- end }}

{{/*
CronJob [Short name]
*/}}
{{- define "elCicdChart.cj" }}
  {{- include "elCicdChart.cronjob" . }}
{{- end }}

{{/*
CronJob
*/}}
{{- define "elCicdChart.cronjob" }}
{{- $ := index . 0 }}
{{- $cjValues := index . 1 }}
---
{{- $_ := set $cjValues "kind" "CronJob" }}
{{- $_ := set $cjValues "apiVersion" "batch/v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  {{- if $cjValues.concurrencyPolicy }}
  concurrencyPolicy: {{ $cjValues.concurrencyPolicy }}
  {{- end }}
  {{- if $cjValues.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $cjValues.failedJobsHistoryLimit }}
  {{- end }}
  jobTemplate:
  {{- include "elCicdChart.jobTemplate" }}
  schedule: {{ $cjValues.schedule }}
  {{- if $cjValues.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ $cjValues.startingDeadlineSeconds }}
  {{- end }}
  {{- if $cjValues.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ $cjValues.successfulJobsHistoryLimit }}
  {{- end }}
{{- end }}

{{/*
Stateful Set [Short name]
*/}}
{{- define "elCicdChart.sts" }}
  {{- include "elCicdChart.statefulset" . }}
{{- end }}


{{/*
Stateful Set
*/}}
{{- define "elCicdChart.statefulset" }}
{{- $ := index . 0 }}
{{- $stsValues := index . 1 }}
{{- $hasService := (((len .) | eq 3) | and (index . 2)) }}
---
{{- $_ := set $stsValues "kind" "StatefulSet" }}
{{- $_ := set $stsValues "apiVersion" "apps/v1" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  template:
  {{- include "elCicdChart.workloadSelector" (list $ $stsValues) | indent 2 }}
  {{- include "elCicdChart.podTemplate" (list $ $stsValues $hasService) | indent 6 }}
{{- end }}



{{/*
HorizontalPodAutoscaler [Short name]
*/}}
{{- define "elCicdChart.hpa" }}
  {{- include "elCicdChart.horizontalPodAutoscaler" . }}
{{- end }}

{{/*
HorizontalPodAutoscaler
*/}}
{{- define "elCicdChart.horizontalPodAutoscaler" }}
{{- $ := index . 0 }}
{{- $hpaValues := index . 1 }}
---
{{- $_ := set $hpaValues "kind" "HorizontalPodAutoscaler" }}
{{- $_ := set $hpaValues "apiVersion" "autoscaling/v2" }}
{{- include "elCicdChart.apiObjectHeader" . }}
spec:
  {{- if or $hpaValues.scaleDownBehavior $hpaValues.scaleDownUp }}
  behavior:
  {{- if or $hpaValues.scaleDownBehavior}}
    scaleDown: {{- $hpaValues.scaleDownBehavior | toYaml | nindent 6 }}
  {{- end }}
  {{- if or $hpaValues.scaleDownUp }}
    scaleUp: {{- $hpaValues.scaleDownUp | toYaml | nindent 6 }}
  {{- end }}
  {{- end }}
  maxReplicas: {{ required "Missing maxReplicas!" ($hpaValues.maxReplicas | default $.Values.defaultHpaMaxReplicas) }}
  {{- if $hpaValues.minReplicas }}
  minReplicas: {{ $hpaValues.minReplicas }}
  {{- end }}
  {{- if $hpaValues.metrics }}
  metrics:
  {{- range $metric := $hpaValues.metrics }}
  - type: {{ $metric.type }}
    {{ lower $metric.type }}:
      metric:
        name: {{ $metric.name }}
        {{- if $metric.selector }}
        selector: {{ $metric.selector | toYaml | nindent 8}}
        {{- end }}
      target: {{- $metric.target | toYaml | nindent 8 }}
      {{- if $metric.describedObject }}
      describedObject: {{- $metric.describedObject | toYaml | nindent 8 }}
      {{- end }}
  {{- end }}
  {{- end }}
  scaleTargetRef:
    apiVersion: {{ $hpaValues.scaleTargetRef.apiVersion }}
    kind: {{ required "Missing kind!" $hpaValues.scaleTargetRef.kind }}
    name: {{ required "Missing name!" $hpaValues.scaleTargetRef.name }}
{{- end }}

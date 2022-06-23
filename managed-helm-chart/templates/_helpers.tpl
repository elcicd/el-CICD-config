

{{/*
Expand the name of the chart.
*/}}
{{- define "elCicdChart.name" -}}
{{- default $.Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "elCicdChart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $.Chart.Name .Values.nameOverride }}
{{- if contains $name $.Release.Name }}
{{- $.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "elCicdChart.chart" -}}
{{- printf "%s-%s" $.Chart.Name $.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "elCicdChart.labels" -}}
{{ include "elCicdChart.selectorLabels" $ }}
git-repo: {{ .Values.gitRepoName }}
src-commit-hash: {{ .Values.srcCommitHash }}
deployment-branch: {{ .Values.deploymentBranch | default $.UNDEFINED }}
deployment-commit-hash: {{ .Values.deploymentCommitHash }}
release-version: {{ .Values.releaseVersionTag | default $.UNDEFINED }}
release-region: {{ .Values.releaseRegion | default $.UNDEFINED }}
build-number: {{ .Values.buildNumber | quote }}
helm.sh/chart: {{ include "elCicdChart.chart" $ }}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: el-cicd
{{- end }}

{{/*
Selector labels
*/}}
{{- define "elCicdChart.selectorLabels" -}}
projectid: {{ required "Missing projectId!" $.Values.projectId }}
microservice: {{ required "Missing microservice name!" $.Values.microService }}
{{- end }}

{{/*
Prometheus Annotations
*/}}
{{- define "elCicdChart.prometheusAnnotations" -}}
{{/* prometheus.io/path: {{ PROMETHEUS_PATH }}
prometheus.io/port: {{ PROMETHEUS_PORT }}
prometheus.io/scheme: {{ PROMETHEUS_SCHEME }}
prometheus.io/scrape: {{ PROMETHEUS_SCRAPE */}}
{{- end }}

{{/*
Scale3 Annotations
*/}}
{{- define "elCicdChart.scale3Annotations" -}}
{{/*discovery.3scale.net/path: {{ THREE_SCALE_PATH }}
discovery.3scale.net/port: {{ SVC_PORT }}
discovery.3scale.net/scheme: {{ THREE_SCALE_SCHEME */}}
{{- end }}

{{/*
Scale3 Labels
*/}}
{{- define "elCicdChart.scale3Labels" -}}
{{/* discovery.3scale.net: {{ THREE_SCALE_NET */}}
{{- end }}

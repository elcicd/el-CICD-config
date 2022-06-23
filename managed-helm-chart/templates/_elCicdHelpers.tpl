
{{/*
Container definition
*/}}
{{- define "elCicdChart.container" }}
{{- $ := index . 0 }}
{{- $containers := index . 1 }}
{{- range $index, $container := $containers }}
{{- if not $container.sdlcValues }}
  {{- $_ := set $container "sdlcValues" (get $container $.Values.sdlcEnv | default dict) }}
{{- end }}
- activeDeadlineSeconds: {{ ($container.sdlcValues).activeDeadlineSeconds | default $container.activeDeadlineSeconds }}
  args: {{ if ($container.sdlcValues).args | or $container.args }}{{ ($container.sdlcValues).args | default $container.args | toYaml | nindent 2 }}{{- end }}
  command: {{ if ($container.sdlcValues).command | or $container.command }}{{ ($container.sdlcValues).command | default $container.command | toYaml | nindent 2 }}{{- end }}
  name: {{ $container.appName }}
  image: {{ if $container.image }} {{ $container.image }}{{- else }}{{ $.Values.imageRepository }}/{{- $.Values.projectId }}-{{- $.Values.microService }}:{{- $.Values.imageTag }}{{- end }}
  imagePullPolicy: {{ $container.imagePullPolicy | default "Always" }}
  env: {{ include "elCicdChart.mergeLists" (list $container "env") }}
  envFrom: {{ include "elCicdChart.mergeLists"  (list $container "envFrom") }}
  ports:
  {{- $portList := ($container.sdlcValues).ports | default  $container.ports }}
  {{- if $portList }}
    {{- $container.sdlcValues.ports | default $container.ports | indent 4}}
  {{- else }}
  - containerPort: {{ ($container.sdlcValues).servicePort | default ($container.servicePort | default $.Values.defaultPort) }}
    protocol: {{ ($container.sdlcValues).serviceProtocol | default ($container.serviceProtocol | default $.Values.defaultProtocol) }}
  {{- end }}
  readinessProbe:  {{ ($container.sdlcValues).readinessProbe | default $container.readinessProbe }}
  startupProbe:  {{ ($container.sdlcValues).startupProbe | default $container.startupProbe }}
  livenessProbe:  {{ ($container.sdlcValues).livenessProbe | default $container.livenessProbe }}
  resources:
    limits:
      cpu: {{ (($container.resources).limits).cpu | default $.Values.defaultLimitsCpu }}
      memory: {{ (($container.resources).limits).memory | default $.Values.defaultLimitsMemory }}
    requests:
      cpu: {{ (($container.resources).requests).cpu | default $.Values.defaultRequestsCpu}}
      memory: {{ (($container.resources).requests).memory | default $.Values.defaultRequestsMemory }}
  volumeMounts: {{ include "elCicdChart.mergeLists" (list $container "volumeMounts") }}
  workingDir: {{ ($container.sdlcValues).workingDir | default $container.workingDir }}
{{- end }}
{{- end }}

{{- define "elCicdChart.mergeLists" }}
  {{- $template := index . 0 }}
  {{- $templateKey := index . 1 }}
  {{- $mergeKey := "name" }}
  {{- if eq (len .) 3 }}
    {{- $mergeKey := index . 2 }}
  {{- end }}
  {{- $srcList := get $template.sdlcValues $templateKey | default list }}
  {{- $destList := get $template $templateKey | default list }}
  {{- $srcMap := dict }}
  {{- range $element := $srcList }}
    {{- $name := get $element $mergeKey }}
    {{- $_ := set $srcMap $name $element }}
  {{- end }}
  {{- $destMap := dict }}
  {{- range $element := $destList }}
    {{- $name := get $element $mergeKey }}
    {{- $_ := set $destMap $name $element }}
  {{- end }}
  {{- range $key,$value := $srcMap }}
    {{- $_ := set $destMap $key $value }}
  {{- end }}
  {{- if $destMap }}
    {{- values $destMap | toYaml | nindent 2 }}
  {{- end }}
{{- end }}

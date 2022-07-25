{{- define "elCicdChart.initParameters" }}
  {{- if kindIs "slice" $.Values.profiles }}
    {{- $sdlcEnv := first $.Values.profiles }}
    {{- $_ := set $.Values.parameters "SDLC_ENV" $sdlcEnv }}
    {{- include "elCicdChart.resolveProfileParameters" (list $ $.Values.parameters $.Values) }}
  {{- end }}
  
  {{- if $.Values.projectId }}
    {{- $_ := set $.Values.parameters "PROJECT_ID" $.Values.projectId }}
  {{- end }}
  {{- if $.Values.microService }}
    {{- $_ := set $.Values.parameters "MICROSERVICE_NAME" $.Values.microService }}
  {{- end }}
  {{- if $.Values.imageRepository }}
    {{- $_ := set $.Values.parameters "IMAGE_REPOSITORY" $.Values.imageRepository }}
  {{- end }}
  {{- if $.Values.imageTag }}
    {{- $_ := set $.Values.parameters "IMAGE_TAG" $.Values.imageRepository }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.resolveProfileParameters" }}
  {{- $ := index . 0 }}
  {{- $parameters := index . 1 }}
  {{- $profileParamMaps := index . 2 }}
  
  {{- range $profile := $.Values.profiles }}
    {{- $profileParameters := get $profileParamMaps (printf "parameters-%s" $profile) }}
    {{- include "elCicdChart.mergeMapInto" (list $ $profileParameters $parameters) }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.interpolateTemplateParameters" }}
  {{- $ := index . 0 }}
  {{- $templates := index . 1 }}
  {{- $parameters := index . 2 }}
  
  {{- range $templateValues := $templates }}
    {{- $_ := set $parameters "APP_NAME" $templateValues.appName }}
    {{- $templateParams := deepCopy $parameters }}
    
    {{- include "elCicdChart.mergeMapInto" (list $ $templateValues.parameters $templateParams) }}
    {{- include "elCicdChart.resolveProfileParameters" (list $ $templateParams $templateValues) }}
    {{- include "elCicdChart.interpolateParameters" (list $templateValues $templateParams) }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.interpolateParameters" }}
  {{- $ := index . 0 }}
  {{- $parameters := index . 1 }}
  
  {{- range $key, $value := $ }}
    {{- if or (kindIs "slice" $value) (kindIs "map" $value) }}
      {{- include "elCicdChart.interpolateParameters" (list $value $parameters) }}
    {{- else if (kindIs "string" $value) }}
        {{- include "elCicdChart.interpolateParameter" (list $ $parameters $key false) }}
    {{- end  }}
    
    {{- if (kindIs "string" $key) }}
      {{- include "elCicdChart.interpolateParameter" (list $ $parameters $key true) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.interpolateParameter" }}
  {{- $template := index . 0 }}
  {{- $parameters := index . 1 }}
  {{- $key := index . 2 }}
  {{- $interpolateKey := index . 3 }}
  
  {{- $value := get $template $key }}
  {{- $matches := list }}
  {{- if $interpolateKey }}
    {{- $matches = regexFindAll "[\\$][\\{][\\w]+?[\\}]" $key -1 }}
  {{- else if (kindIs "string" $value) }}
    {{- $matches = regexFindAll "[\\$][\\{][\\w]+?[\\}]" $value -1 }}
  {{- end }}
  
  {{- range $paramRef := $matches }}
    {{- $param := regexReplaceAll "[\\$][\\{]([\\w]+?)[\\}]" $paramRef "${1}" }}
    {{- $paramVal := get $parameters $param }}
    {{- if not $paramVal }}
      {{- $_ := unset $template $key }}
      {{- $matches = list }}
    {{- else if $interpolateKey }}
      {{ $_ := unset $template $key }}
      {{- $key = replace $paramRef (toString $paramVal) $key }}
      {{- $_ := set $template $key $value }}
    {{- else if (kindIs "string" $paramVal) }}
      {{- $value = replace $paramRef (toString $paramVal) $value }}
      {{- $_ := set $template $key $value }}
    {{- else }}
      {{- if (kindIs "map" $paramVal) }}
        {{- $paramVal = deepCopy $paramVal }}
      {{- else if (kindIs "slice" $paramVal) }}
        {{- if (kindIs "map" (first $paramVal)) }}
          {{- $newList := list }}
          {{- range $el := $paramVal }}
            {{- $newList = append $newList (deepCopy $el) }}
          {{- end }}
          {{- $paramVal = $newList }}
        {{- end }}
      {{- end }}
      {{- $_ := set $template $key $paramVal }}
      {{- if or (kindIs "slice" $paramVal) (kindIs "map" $paramVal) }}
        {{- include "elCicdChart.interpolateParameters" (list $paramVal $parameters) }}
      {{- end }}
    {{- end }}
  {{- end }}
  
  {{- if $matches }}
    {{- include "elCicdChart.interpolateParameter" (list $template $parameters $key $interpolateKey) }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.mergeMapInto" }}
  {{- $ := index . 0 }}
  {{- $srcMap := index . 1 }}
  {{- $destMap := index . 2 }}
  
  {{- if $srcMap }}
    {{- range $key, $value := $srcMap }}
      {{- $_ := set $destMap $key $value }}
    {{- end }}
  {{- end }}
{{- end }}

{{ define "elCicdChart.skippedTemplate" }}
# EXCLUDED BY PROFILES: {{ index . 0 }} -> {{ index . 1 }}
{{- end }}

{{- define "elCicdChart.mergeProfileTemplateData" }}
  {{- $ := . }}
  
  {{- $templatesPrefix := "templates" }}
  {{- $templateMap := dict }}
  {{- include "elCicdChart.populateTemplateMap" (list $ $.Values.templates $templateMap) }}
  
  {{- range $profile := $.Values.profiles }}
    {{- $profileSuffix := printf "-%s" $profile }}
    {{- range $key, $profileTemplates := $.Values }}
      {{- if and (hasPrefix $templatesPrefix $key) (hasSuffix $profileSuffix $key) }}
        {{- include "elCicdChart.mergeProfileIntoTemplates" (list $ $templateMap $profileTemplates) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.populateTemplateMap" }}
  {{- $ := index . 0 }}
  {{- $templates := index . 1 }}
  {{- $templateMap := index . 2 }}
  {{- range $template := $templates }}
    {{- $key := printf "%s-%s" ($template.appName | default $.Values.microService) $template.templateName }}
    {{- $_ := set $templateMap $key $template }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.mergeProfileIntoTemplates" }}
  {{- $ := index . 0 }}
  {{- $templateMap := index . 1 }}
  {{- $profileTemplates := index . 2 }}

  {{- range $profileTemplate := $profileTemplates }}
    {{- $profileTemplateKey := printf "%s-%s" ($profileTemplate.appName | default $.Values.microService) $profileTemplate.templateName }}
    {{- $defaultTemplate := (get $templateMap $profileTemplateKey) }}
    {{- if $defaultTemplate }}
      {{- include "elCicdChart.mergeProfileTemplateIntoTemplate" (list $ $defaultTemplate $profileTemplate) }}
    {{- else }}
      {{- $_ := set $templateMap $profileTemplateKey $profileTemplate }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.mergeProfileTemplateIntoTemplate" }}
  {{- $ := index . 0 }}
  {{- $template := index . 1 }}
  {{- $profileTemplate := index . 2 }}
  {{- range $key, $value := $profileTemplate }}
    {{- if (and (get $template $key) $value (kindIs "slice" $value) ) }}
      {{- if (kindIs "map" (first $value)) }}
        {{- if (get (first $value) "templateName") }}
          {{- $defaultTemplates := (get $template $key) }}
          {{- $subTemplateMap := dict }}
          {{- include "elCicdChart.populateTemplateMap" (list $ $defaultTemplates $subTemplateMap) }}
          {{- include "elCicdChart.mergeProfileIntoTemplates" (list $ $subTemplateMap $value) }}
          {{- $_ := set $template $key (values $subTemplateMap) }}
        {{- else }}
          {{- $mergeKey := get $template (printf "%s%sMergeKey" $template.templateName (title $key)) | default "name" }}
          {{- include "elCicdChart.mergeListOfMaps" (list $template $profileTemplate $key $mergeKey) }}
          {{- $_ := set $template $key (get $template "mergeListOfMapsResult") }}
        {{- end }}
      {{- else }}
        {{- $_ := set $template $key (get $profileTemplate $key) }}
      {{- end }}
    {{- else if (and (get $template $key) $value (kindIs "map" $value)) }}
      {{- $templateSubMap := get $template $key }}
      {{- range $subKey, $subValue := $value }}
        {{- $_ := set $templateSubMap $subKey $subValue }}
      {{- end }}
    {{- else }}
      {{- $_ := set $template $key (get $profileTemplate $key) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.mergeListOfMaps" }}
  {{- $template := index . 0 }}
  {{- $profileTemplate := index . 1 }}
  {{- $templateKey := index . 2 }}
  {{- $mergeKey := index . 3 }}

  {{- $srcList := get $profileTemplate $templateKey }}
  {{- $destList := get $template $templateKey }}
  
  {{- $useMergeKey := (and $srcList $destList) }}
  {{- if $useMergeKey }}
    {{- range $el := $srcList }}
      {{- $useMergeKey = $useMergeKey | and (get $el $mergeKey) }}
    {{- end }}
  {{- end }}
  
  {{- $destMap := dict }}
  {{- if $useMergeKey }}
    {{- $srcMap := dict }}
    {{- range $element := $srcList }}
      {{- $name := get $element $mergeKey }}
      {{- $_ := set $srcMap $name $element }}
    {{- end }}
  
    {{- range $element := $destList }}
      {{- $name := get $element $mergeKey }}
      {{- $_ := set $destMap $name $element }}
    {{- end }}
    
    {{- include "elCicdChart.mergeMapInto" (list $ $srcMap $destMap) }}
  {{- end }}
  {{- $_ := set $template "mergeListOfMapsResult" ((values $destMap) | default $srcList | default $destList) }}
{{- end }}

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

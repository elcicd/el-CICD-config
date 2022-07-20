{{- define "elCicdChart.processProfiles" }}
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
  
    {{- range $key, $value := $srcMap }}
      {{- $_ := set $destMap $key $value }}
    {{- end }}
  {{- end }}
  {{- $_ := set $template "mergeListOfMapsResult" ((values $destMap) | default $srcList | default $destList) }}
{{- end }}

{{- define "elCicdChart.defineDefaultVars" }}
  {{- if kindIs "slice" $.Values.profiles }}
    {{- $sdlcEnv := first $.Values.profiles }}
    {{- $_ := set $.Values.templateVars "SDLC_ENV" $sdlcEnv }}
    {{- $profileTemplateVars := get $.Values (printf "templateVars-%s" $sdlcEnv) }}
    {{- if $profileTemplateVars }}
      {{- $_ := set $.Values "templateVars" (mergeOverwrite $.Values.templateVars $profileTemplateVars) }}
    {{- end }}
  {{- end }}
  
  {{- if $.Values.projectId }}
    {{- $_ := set $.Values.templateVars "PROJECT_ID" $.Values.projectId }}
  {{- end }}
  {{- if $.Values.microService }}
    {{- $_ := set $.Values.templateVars "MICROSERVICE_NAME" $.Values.microService }}
  {{- end }}
  {{- if $.Values.imageRepository }}
    {{- $_ := set $.Values.templateVars "IMAGE_REPOSITORY" $.Values.imageRepository }}
  {{- end }}
  {{- if $.Values.iamgeTag }}
    {{- $_ := set $.Values.templateVars "IMAGE_TAG" $.Values.imageRepository }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.interpolateValues" }}
  {{- $ := index . 0 }}
  {{- $templateVars := index . 1 }}
  
  {{- range $key, $value := $ }}
    {{- if or (kindIs "slice" $value ) (kindIs "map" $value ) }}
      {{- include "elCicdChart.interpolateValues" (list $value $templateVars) }}
    {{- else if (kindIs "string" $value) }}
      {{- $matches := regexFindAll "[\\$][\\{][\\w]+?[\\}]" $value -1 }}
      {{- if $matches }}
        {{- include "elCicdChart.interpolateVars" (list $ $templateVars $matches $key false) }}
      {{- end }}
    {{- end  }}
    
    {{- if (kindIs "string" $key) }}
      {{- $matches := regexFindAll "[\\$][\\{][\\w]+?[\\}]" $key -1 }}
      {{- if $matches }}
        {{- include "elCicdChart.interpolateVars" (list $ $templateVars $matches $key true) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.interpolateVars" }}
  {{- $ := index . 0 }}
  {{- $templateVars := index . 1 }}
  {{- $matches := index . 2 }}
  {{- $key := index . 3 }}
  {{- $interpolateKey := index . 4 }}
  
  {{- $value := get $ $key }}
  {{- range $varPattern := $matches }}
    {{- $var := regexReplaceAll "[\\$][\\{]([\\w]+?)[\\}]" $varPattern "${1}" }}
    {{- $varValue := get $templateVars $var }}
    {{- if not $varValue }}
      {{- required ( printf "%s is undefined!!" $var ) $varValue }}
    {{- end }}
    
    {{- if $interpolateKey }}
      {{ $_ := unset $ $key }}
      {{- $key = replace $varPattern (toString $varValue) $key }}
      {{- $_ := set $ $key $value }}
    {{- else if not (eq $value $varPattern) }}
      {{- $value = replace $varPattern (toString $varValue) $value }}
      {{- $_ := set $ $key $value }}
    {{- else }}
      {{- $_ := set $ $key $varValue }}
    {{- end }}
  {{- end }}
{{- end }}

{{ define "elCicdChart.skippedTemplate" }}
# EXCLUDED BY PROFILES: {{ index . 0 }} -> {{ index . 1 }}
{{- end }}

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

{{- define "elCicdChart.populateTemplateMap" }}
  {{- $ := index . 0 }}
  {{- $templates := index . 1 }}
  {{- $templateMap := index . 2 }}
  {{- range $template := $templates }}
    {{- $key := printf "%s-%s" ($template.appName | default $.Values.microService) $template.templateName }}
    {{- $_ := set $templateMap $key $template }}
  {{- end }}
{{- end }}

{{ define "elCicdChart.skippedTemplate" }}
# EXCLUDED BY PROFILES: {{ index . 0 }} -> {{ index . 1 }}
{{- end }}

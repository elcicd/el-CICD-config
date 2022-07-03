{{- define "elCicdChart.mergeProfile" }}
  {{- $ := index . 0 }}
  {{- $config := index . 1 }}
  {{- $profile := index . 2 }}
  {{- $profileValues := get $config $profile | default dict }}

  {{- include "elCicdChart.mergeProfileIntoConfig" (list $ $config $profileValues) }}
{{- end }}

{{- define "elCicdChart.mergeProfileIntoConfig" }}
  {{- $ := index . 0 }}
  {{- $config := index . 1 }}
  {{- $profileValues := index . 2 }}
  {{- range $key, $value := $profileValues }}
    {{- if (and $value (kindIs "slice" $value)) }}
      {{- if kindIs "map" (first $value) }}
        {{- $mergeKey := get $.Values (printf "%s%smergeKey" $config.templateName (title $key)) | default "name" }}
        {{- include "elCicdChart.mergeListOfMaps" (list $config $profileValues $key $mergeKey) }}
        {{- $_ := set $config $key (get $config "mergeListOfMapsResult") }}
      {{- else }}
        {{- $_ := set $config $key (get $profileValues $key) }}
      {{- end }}
    {{- else }}
      {{- $_ := set $config $key (get $profileValues $key) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "elCicdChart.mergeListOfMaps" }}
  {{- $config := index . 0 }}
  {{- $profileValues := index . 1 }}
  {{- $configKey := index . 2 }}
  {{- $mergeKey := index . 3 }}

  {{- $srcList := get $profileValues $configKey }}
  {{- $destList := get $config $configKey }}
  
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
  {{- $_ := set $config "mergeListOfMapsResult" ((values $destMap) | default $srcList | default $destList) }}
{{- end }}

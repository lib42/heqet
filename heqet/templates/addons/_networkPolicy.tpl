{{/* 
  Resolve project NetworkPolicies from rules and groups; then append config.networkPolicy.policies to project-hash
  Params:  
    dict:
      project: # Heqet project hash
      networkPolicy # NetworkPolicy Ressource Config
*/}}
{{- define "heqet.addon.networkPolicy" }}
  {{- if hasKey .project.config "networkPolicy" }}
    {{- if not (hasKey .project.config.networkPolicy "rules") }}
      {{- $_ := set .project.config.networkPolicy "rules" list }}
    {{- end }}

    {{- if not (hasKey .project.config.networkPolicy "config") }}
      {{- $_ := set .project.config.networkPolicy "config" .networkPolicy.config }}
    {{- end }}

    {{- $rules := .project.config.networkPolicy.rules }}
    {{- range $group := .project.config.networkPolicy.groups }}
      {{- if hasKey $.networkPolicy.groups $group }}
        {{- range $rule := (get $.networkPolicy.groups $group) }}
          {{- $rules = append $rules $rule }}
        {{- end }}
      	{{- $_ := set $.project.config.networkPolicy "rules" $rules }}
    {{- end }}
  {{- end }}
    
  {{/* Translate project networkPolicy.rules into NetworkPolicy */}}
  {{- $policies := dict }}
  	{{- range .project.config.networkPolicy.rules }}
    	{{- if hasKey $.networkPolicy.rules . }}
      	{{- $_ := set $policies . (get $.networkPolicy.rules .) }}
    	{{- end -}}
  	{{- end -}}
  {{- $_ := set .project.config.networkPolicy "policies" $policies -}}
  {{- end }}
{{- end }}

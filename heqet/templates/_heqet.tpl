{{/* Heqet Main Functions */}}

{{/* 
  Collect resource configs & saves them in $.resources
*/}}
{{- define "heqet.resources" }}
	{{- $resources := dict }}
	{{- range $path, $_ := $.Files.Glob (printf "%s/resources/*.y*ml" $.Values.userdata) }}
  	{{- $res := $.Files.Get $path | fromYaml | default dict }}
  	{{- $_ := deepCopy $res | merge $resources }}
	{{- end -}}
  {{- $_ := set $ "resources" $resources }}
{{- end -}}

{{/* 
  Collect project, app & resource configs. After that template yaml files 
*/}}
{{- define "heqet.apps" }}
	{{- range $path, $_ := .Files.Glob (printf "%s/projects/*/*.y*ml" $.Values.userdata) }}
  	{{- $project := $.Files.Get $path | fromYaml | default dict }}
    {{- $_ := set $project.config "name" ($project.config.name | default (base (dir $path))) -}}

    {{- if not (hasKey $project.config "spec") }}
      {{- $_ := set $project.config "spec" dict }}
    {{- end }}
    {{- $_ := deepCopy $.Values.projectDefaults | merge $project.config.spec }}

    {{/* Include manifests in project dir */}}
    {{- range $manifest, $_ := $.Files.Glob (printf "%s/manifests/*.y*ml" (dir $path)) }}
---
{{ $.Files.Get $manifest }}
     {{- end }}

    {{/* Generate ArgoCD project */}}
    {{- include "heqet.template.project" $project.config -}}

    {{/* Generate single project namespace */}}
  	{{- if not (hasKey $project.config "namespace") -}}
      {{- $_ := set $project.config "namespace" $project.config.name }}
  	{{- end -}}
  
    {{- if not (hasKey $project.config "existingNamespace") -}}
    	{{- include "heqet.template.namespace" $project.config -}}
  	{{- end -}}

    {{/* Collect project NetworkPolicies */}}
    {{- if hasKey $project.config "networkPolicy" }}
      {{- $data := dict "project" $project "networkPolicy" $.resources.networkPolicy }}
    	{{- include "heqet.addon.networkPolicy" $data -}}
    	{{- include "heqet.template.networkPolicy" $project -}}
    {{- end -}}

   	{{/* Generate App Configuration */}}
    {{- $currentScope := . -}}
    {{- range $app := $project.apps -}}

      {{/* Merge project & defaults config into app config */}}
      {{- $_ := deepCopy $project.config | merge $app }}
      {{- $_ := deepCopy $.Values.defaults | merge $app }}
      {{- $_ := set $app "project" ($project.config.name | default (base (dir $path))) }}
      {{- $_ := set $app "isApplication" true -}} 

      {{/* Resolve repoURL from repo name, if repoURL is not set */}}
      {{- if and (hasKey $app "repo") (not (hasKey $app "repoURL")) }}
        {{- if hasKey $.resources.repos $app.repo }}
          {{- $repo := (get $.resources.repos $app.repo) }}
          {{- $_ := set $app "repoURL" $repo.url }}
        {{- else }}
          {{- fail (printf "Repository with name '%s' could not be found in resource config." $app.repo) }}
        {{- end }}
      {{- end -}}

      {{/* Generate Namespace for app, if requested */}}
      {{- if and (not (hasKey $app "existingNamespace")) (ne $app.namespace $project.config.namespace) }}
      	{{- $_ := set $app "namespace" ($app.namespace | default $app.name) }}
        {{- include "heqet.template.namespace" $app }}
      {{- else if hasKey $app "existingNamespace" }}
      	{{- $_ := set $app "namespace" ($app.existingNamespace) }}
      {{- end -}}

      {{/* Declare empty values dict */}}
      {{- $_ := set $app "values" dict }}

      {{/* Include Snippets into $app.values */}}
      {{- if (hasKey $app "include") }}
        {{- range $snippet := $app.include }}
      	  {{- with $currentScope }}
  	      	{{- $code := $.Files.Get (printf "%s/resources/snippets/%s.yaml" $.Values.userdata $snippet) | fromYaml | default dict }}
          	{{- $_ := deepCopy $code | mergeOverwrite $app.values }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{/* Collect value file & merge values into app.values dict */}}
    	{{- range $value_file, $_ := $.Files.Glob (printf "%s/values/%s.y*ml" (dir $path) $app.name ) }}
      	{{- with $currentScope }}
        	{{- $values := $.Files.Get $value_file | fromYaml | default dict }}
          {{- $_ := deepCopy $values | mergeOverwrite $app.values }}
      	{{- end }}
    	{{- end -}}

      {{- include "heqet.template.app" $app }}
  	{{- end }}
	{{- end }}
{{- end }}

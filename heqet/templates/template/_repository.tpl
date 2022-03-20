{{- define "heqet.template.repository" }}
  {{- range $name, $config := $.resources.repos }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $config.type | default "helm" }}-repo-{{ $name }}
  namespace: {{ .argocdNamespace | default "argocd" }}
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: {{ $config.url }}
  type: {{ $config.type | default "helm" }}
	{{- end }}
{{- end }}

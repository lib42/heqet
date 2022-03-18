{{- define "heqet.template.project" }}
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ .name }}
  namespace: {{ .argocdNamespace | default "argocd" }}
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
spec:
  description: {{ .description | default "Application Project" }}
  {{- .spec | toYaml | nindent 2 }}
{{- end }}

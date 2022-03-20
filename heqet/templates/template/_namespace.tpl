{{/* for every app, or [if set] for one project: */}}
{{- define "heqet.template.namespace" }}
---
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .namespace | default .name | quote }}
  labels:
    {{- if .isApplication }}
    app.heqet.gnu.one/name: {{ .name }}
    {{- end }}
    app.heqet.gnu.one/project: {{ .project | default .name }}
    project.heqet.gnu.one/name: {{ .name }}
    {{- with .labels }}{{- toYaml . | nindent 4}}{{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: "-42"
    {{- with .annotations }}{{ toYaml . | nindent 4}}{{- end }}
{{- end -}}

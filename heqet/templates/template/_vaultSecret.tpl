{{/* Generate VaultSecrets */}}
{{- define "heqet.template.secrets" -}}
{{- $context := . }}
  {{- with $context }}
    {{- range .secrets }}
---
apiVersion: ricoberger.de/v1alpha1
kind: VaultSecret
metadata:
  name: {{ .name }}
  namespace: {{ $context.namespace | default $context.existingNamespace | default $context.name | quote }}
  labels:
    app.heqet.gnu.one/name: {{ $context.name }}
    app.heqet.gnu.one/project: {{ $context.project }}
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
  keys:
  {{- toYaml .keys | nindent 2}}
  path: heqet/{{ .fromApp | default $context.name }}/{{ .name }}
  type: {{ $context.type | default "Opaque" }}
    {{ end }}
  {{- end }}
{{- end }}

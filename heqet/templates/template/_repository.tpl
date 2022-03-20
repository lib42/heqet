{{- define "heqet.template.repository" }}
  {{- $repos := . }}
  {{-  if $.resources }}
    {{- $repos = $.resources.repos }}
  {{- end }}
  {{- range $name, $config := $repos }}
    {{- $repoType := ($config.type | default "helm") }} 
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
{{- if eq $repoType "helm" }}
kind: HelmRepository
{{- else }}
kind: GitRepository
{{- end }}
metadata:
  name: {{ $name }}
  namespace: {{ .fluxNamespace | default "flux-system" }}
  labels:
    repo.heqet.gnu.one/name: {{ $name }}
  {{-  if $config.app }}
    app.heqet.gnu.one/name: {{ $config.app }}
  annotations:
    repo.heqet.gnu.one/type: auto-created
  {{- end }}
spec:
  interval: {{ $config.interval | default "5m" }}
  url: {{ $config.url }}
  {{- if $config.branch }}
  ref:
    branch: {{ $config.branch }}
  {{- end }}
 {{- end }}
{{- end }}

{{/* Main Template generating FluxCD HelmReleases */}}
{{- define "heqet.template.app" }}
{{- $repoName := ( .repo | default (printf "%s-repo" .name)) }}
{{- if.repoURL }}
  {{- $repoDict := dict "url" .repoURL "app" .name }}
  {{- $repo := dict $repoName $repoDict  }}
  {{- include "heqet.template.repository" $repo }}
{{- end }}
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: {{ .name | quote }}
  namespace: {{ .fluxNamespace | default "flux-system" }}
  labels:
    app.heqet.gnu.one/name: {{ .name | quote }}
    app.heqet.gnu.one/project: {{ .project | quote }}
    app.kubernetes.io/name: {{ .name | quote }}
    app.kubernetes.io/part-of: heqet
    app.kubernetes.io/managed-by: helm
    meta.helm.sh/release-namespace: {{ .namespace | default .name }}
    meta.helm.sh/release-name: {{ .name }}
	{{- with .labels }}{{ toYaml . | nindent 4}}{{ end }}
  annotations:
    fluxcd.io/automated: "true"
	{{- with .annotations }}
    {{- toYaml . | nindent 4}}
  {{- end }}
spec:
  releaseName: {{ .name }}
  interval: {{ .interval | default "5m" }}
  {{- if .dependsOn }}
  dependsOn:
  - name: {{ .dependsOn }}
  {{- end }}
  chart:
    spec:
      chart: {{ .chart | default .path }}
      version: {{ .targetRevision }}
      sourceRef:
        kind: {{ include "heqet.fluxcd.repoType" . }}
        name: {{ $repoName }}
        namespace: {{ .fluxNamespace | default "flux-system" }}
      interval: {{ .interval | default "5m" }}
  {{- with .values }}
  values:
		{{- toYaml . | nindent 4 }}
  {{- end }}
{{- with .secrets }}{{- include "heqet.template.secrets" $ }}{{- end }}
{{- end }}

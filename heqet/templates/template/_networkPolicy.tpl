{{/* Generate NetworkPolicy Rules */}}
{{- define "heqet.template.networkPolicy" -}}
  {{- range $key, $value := $.config.networkPolicy.policies }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ $.config.name }}-{{ $key }}
  namespace: {{ $.config.namespace | default $.config.name }}
  labels:
    app.heqet.gnu.one/project: {{ $.config.name }}
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
    {{- $value | toYaml | nindent 2 }}
  {{- end -}}

	{{- if $.config.networkPolicy.config.allowNamespace }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-project-namespace-{{ $.config.name }}
  namespace: {{ $.config.namespace | default $.config.name }}
  labels:
    app.heqet.gnu.one/project: {{ $.config.name }}
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  egress:
    - to:
      - namespaceSelector: 
          matchLabels: 
            app.heqet.gnu.one/project: {{ $.config.name }}
  ingress:
    - from:
      - namespaceSelector: 
          matchLabels: 
            app.heqet.gnu.one/project: {{ $.config.name }}
  {{- end }}
{{- end }}

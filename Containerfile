# Very simple container for argo-cd plugin
FROM alpine/helm:latest

COPY conf/plugin.yaml /home/argocd/cmp-server/config/plugin.yaml
RUN helm plugin install https://github.com/lib42/helm-heqet

# Clear entrypoint & cmd
ENTRYPOINT
CMD [ "sh" ]

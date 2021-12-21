# Very simple container for argo-cd plugin
FROM alpine/helm:latest

RUN adduser argocd -h /home/argocd/ -D -u 999 -S -G ping
COPY conf/plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

USER argocd
RUN helm plugin install https://github.com/lib42/helm-heqet

# Clear entrypoint & cmd
ENTRYPOINT
CMD [ "sh" ]

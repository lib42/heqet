# Getting Started

## Argo-CD Configuration Management Plugin

Heqet is basically not more then a hacky helm-chart. But to make it's configuration easier & more structured, i needed a way to split the chart from your custom values [or "userdata"].

Since version 2.2.0 Argo-CD supports "Configuration Management Plugins" [CMP] using sidecar containers. Heqet is utilizing this feature by injecting a sidecar-container into Argo-CD's repo-server pod. The CMP will take care of keeping Heqets code and your userdata up-to-date.

Thanks to this great feature of Argo-CD, your custom configuration & heqet's helm chart can be updated independantly.

### Example Configuration using Argo-CD Helm-Chart

In this example we are using the official [Argo-CD Helm Chart](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd):

Here is a incomplere snippet from the `values.yaml`:

``` yaml
repoServer:
  # We'll need these for the sidecar injection to work:
  volumes:
  - name: var-files
    emptyDir: {}
  - name: plugins
    emptyDir: {}

  # Shared plugin directory
  volumeMounts:
  - mountPath: /home/argocd/cmp-server/plugins
    name: plugins

  # This copies the CMP-Server for the sidecar
  initContainers:
  - name: copy-cmp-server
    image: quay.io/argoproj/argocd:latest
    command:
    - cp
    - -n
    - /usr/local/bin/argocd
    - /var/run/argocd/argocd-cmp-server
    volumeMounts:
      - mountPath: /var/run/argocd
        name: var-files

  # Heqet Sidecar:
  extraContainers:
  - name: cmp-heqet
    command: [/var/run/argocd/argocd-cmp-server]
    image: lib42/heqet-cli:latest
    securityContext:
      runAsNonRoot: true
      runAsUser: 999
    volumeMounts:
      - mountPath: /var/run/argocd
        name: var-files
      - mountPath: /home/argocd/cmp-server/plugins
        name: plugins
      - mountPath: /tmp
        name: tmp-dir
```

Notice: Make sure the repo-server & sidecar use the same /tmp-volume!


## Creating your userdata git repository

When the CMP is setup, it's time to deploy your first app using heqet. For this you'll need a "userdata"-repo. 

For an example, check out my homelab config: [hive-apps](https://github.com/Nold360/hive-apps/)

One important file is the `Heqetfile`. It's required to make the CMP work & will be used to determine which heqet-version / branch to use.

Example Heqetfile:
``` bash
# Heqetfile
heqet_repo=https://github.com/lib42/heqet.git
heqet_revision=v3
heqet_path=charts/heqet
heqet_values=values.yaml
```

Normally you wouldn't need to change these options unless you want to use your own fork of heqet. See also [Heqetfile](/heqet/config/heqetfile)

## Creating a new project

Copy the `example/project` folder to `charts/heqet/projects/name-of-your-project`. It contains a template for the `project.yaml` and also the `values` directory.

In the `values` directory you can simple create a new .yaml file, this the name of the app it belongs to. [same name as defined in the `project.yaml` by you. 


# Overview

This page gives you a quick overview about the main components & terminology of heqet.

## Repo Structure

```
├── bootstrap.yaml            # Used for initial bootstrap of Heqet
├── Heqetfile                 # Required for Heqet to work
├── projects/
│   └── argocd/               # Every project has it's own folder
│       ├── project.yml       # Main project configuration
│       ├── manifests/        # Project related static yaml manifests
│       └── values/
│           └── argocd.yaml   # Every app can get it's own values file
├── README.md
├── renovate.json             # Preconfigured renovatebot for heqet config
├── resources/
│   ├── manifests/            # Your static manifests go here
│   │   └── foobar.yaml       
│   ├── networkpolicy.yml     # NetworkPolicies & create groups of policies
│   ├── repos.yml             # Helm Chart Repositories aliases
│   └── snippets/             # Value Snippets can be included into apps
│       └── tmpdirs.yaml      # They will be merged with all other app values 
└── values.yaml               # Defaults & main config for heqet
```


## Apps

Apps are Helm-Charts to deploy. Every app is part of a Project & needs to be listed in the `apps`-list inside the `project.yaml`. Every app will become an Argo-CD `Application`-CRD. The `Application`s configuration can be changed on a global base inside the `values.yaml`, at project level inside the `project.yaml` or on app level inside the app definition.

## Projects

Projects are collections of Apps. Every project will become a `Namespace` and a Argo-CD Project. The name of the project, namespace and project will depend on the name of the project-directory but can also be configured in the `project.yaml`.

Projects can also contain `NetworkPolicies` and static manifests usind the `manifests` folder inside the project directory.


## Resources

Resources or also called "Addons" or "Generators" are additional helper functions that can create additinal Kubernetes resources like `NetworkPolicy`s or `VaultSecrets`.

Eg. NetworkPolicies can be predefined, grouped & later applied in multiple apps.


### NetworkPolicies [networkpolicy.yaml]

The NetworkPolicy-Addon has a few global configuration options. Like which polcies to apply by default & if the communication inside a Namespace should always be allowed.

``` yaml
networkPolicy:
  config:
    # Generate NetworkPolicy to allow communication inside of the project namespace?
    # Only gets applied when other networkpolices are active on the project
    allowNamespace: true

    default:
      groups: []
      rules: []
```

#### Policies

NetworkPolicies are defined in the Kubernetes spec, but inside a dict `networkPolicy.rules`:

``` yaml
networkPolicy:
  rules:
    allow-dns:
      podSelector: {}
      policyTypes:
      - Egress
      egress:
      - ports:
        - port: 53
          protocol: UDP
        to:
        - namespaceSelector: {}

    allow-ingress:
      podSelector: {}
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              app.heqet.gnu.one/name: ingress-external
```

Notice: Heqet will apply annotations to every namespace e.g. `app.heqet.gnu.one/name` containing the name of the app. This way we can easily predefine policies that apply on a specific app.


#### Groups

Now comes the heqet magic! NetworkPolcies can be grouped and groups of NetworkPolcies can be applied to Projects.

``` yaml
networkPolicy:
  groups:
    internet:
      - allow-dns
      - allow-proxy
      - allow-ingress

  rules:
    allow-dns:
      [...]
    allow-proxy:
      [...]
    allow-ingress:
      [...]
```

#### Apply to Project

After defining your polcies you can assign them to one or multiple projects like this:

``` yaml
config:
  description: Project example with NetworkPolcies applied
  networkPolicy:
    groups:
    - internet
    rules:
    - allow-ssh
```

#### Value Snippets

Value snippets can be used, when multiple apps use the same value structure. A good example for this are the charts by the [K8s-at-home project](https://k8s-at-home.com/). 

Here's an example for `resources/snippets/noRoot.yaml`:

``` yaml
securityContext:
  runAsNonRoot: true
  privileged: false
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
```

Once create we can `include` this snippet into out app like this [`project.yaml`]:

``` yaml
config: 
  [...]

apps:
- name: my-app
  include:
  - noRoot
```

#### Repos

We can add Helm-Chart repositories to Argo-CD like this: [`resources/repos.yaml`]
``` yaml
# Parameters:
# name-of-repo:
#   url: https://...
#   type: [default: helm | git]
#
repos:
  argo:
    url: https://argoproj.github.io/argo-helm
  bitnami:
    url: https://charts.bitnami.com/bitnami
  k8s-at-home:
    url: https://k8s-at-home.com/charts
```

These repos can also be applied to projects or apps. In this example `my-app` uses the `bitnami`-repo, while `another-app` uses the projects default repo `k8s-at-home`.

[`project.yaml`]:
``` yaml
config:
  repo: k8s-at-home

apps:
- name: my-app
  repo: bitnami
  ...
- name: another-app
```


## Addons

Heqet "special" features are called "addons" - [Addons Documentation](https://lib42.github.io/heqet/addons/)

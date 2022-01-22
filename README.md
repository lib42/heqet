# Heqet

*Heqet (Egyptian ḥqt, also ḥqtyt "Heqtit") is an Egyptian goddess of fertility.*

Heqet is my attempt to make Kubernetes GitOps Deployments as easy as possible. It's goal is to reduce the need of redundant configuration in a GitOps environment, by generating the required Kubernetes resource definitions for you. Heqet heavily relies on a Helm-Chart which will generate all [ArgoCD]*(https://argo-cd.readthedocs.io/en/stable/)-Applications, -Projects, Namespaces & more using Argo-CDs [App-of-Apps-Pattern](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/).

## What problem does heqet solve?

Kubernetes allows declarative infrastructure which can be stored in git easily. Argo-CD is used to deploy those configurations. With Argo-CD it's simple to deploy Helm-Charts. But you still need to write a lot of redundant yaml-files.

Heqet reduces the configuration required to deploy Helm-chart-based applications to the bare minimum:

 * What's the name of your app?
 * Which Chart to deploy? 
 * Which values to apply?
 * Deploy it!

Making GitOps based deployments simple while keeping kubernetes power & customizability.

## Keyfeatures

 * Easy Setup [Just requires Kubernetes + Argo-CD]
 * Simple / DRY application definition & configuration
 * Follows the GitOps principles
 * Deploy a whole application environment or cluster from a singe git-repo
 * Addons for simple generation of `VaultSecret` and `NetworkPolicy` resources
 * Include reuseable resources like value snippets & NetworkPolicies into your app
 * Inheritance of configuration options [defaults -> project -> app]


## Overview

![Heqet Overview](https://lib42.github.io/heqet/assets/heqet-overview.jpg)

## Components & Configuration

Core component is `Argo-CD` which will deploy Heqet & also your apps! All you need is a git-repo & k8s cluster.

The heqet Configuration-Management-Plugin [CMP] will generate ArgoCD-Applications & -Projects, Namespaces and if required `VaultSecret`s, `NetworkPolicies`, Argo-CD Repositories and more. 


### Filestructure

Heqet is highly opinionated about it's structure. It helps you keeping multiple projects organized. The user configuration is organized like this:

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
│       └── tmpdirs.yaml      #   \ They will be merged with all other app values 
└── values.yaml               # Defaults & main config for heqet
```

For more see: [Filestructure](https://lib42.github.io/heqet/filestructure/)

## Installation

Installing heqet is quite simple:
 - Install [Argo-CD](https://argo-cd.readthedocs.io/en/stable) [Version >= 2.2.0] on your Kubernetes cluster
 - Configure the Heqet Argo-CD Configuration-Management-Plugin [Getting Started](https://lib42.github.io/heqet/getting-started/)
 - Create your heqet userdata git repository - [Example Configuration](#example-configuration)
 - Deploy your first app to [bootstrap Heqet](https://github.com/lib42/heqet-apps/blob/main/bootstrap.yaml): `kubectl apply -f bootstrap.yaml`
 - Deploy apps to your userdata repo & Enjoy Argo-CD!


## Example Configuration

|- Name -|- Description -|
|----------------------------------------------------|--------------------------|
| [Heqet-Apps](https://github.com/lib42/heqet-apps)  | Official Example Repo    |
| [Hive-Apps](https://github.com/Nold360/hive-apps/) | My Homelab configuration |

## Docs

Check out the full documentation: [here](https://lib42.github.io/heqet)

Any problems? Open an issue. [Contributions welcome](https://github.com/lib42/heqet)

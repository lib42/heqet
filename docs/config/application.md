# Application Config
## Required

| Parameter | Type   | Example | Description |
|-----------|--------|---------|-------------|
| name      | string | `"argocd"`                         | Name of your application & namespace [if not specified] | 
| repoURL   | string | `"https://github.com/lib42/heqet"` | URL to git or Helmchart repo |      
| or `repo` | string | `"heqet"`                          | Name of a predefinied Helm/Git-Repo [see addons/repos](/heqet/addons/repos/) |      
| path      | string | `"charts/heqet"`                   | Path to chart if using git as source repo |
| chart     | string | `"heqet"`                          | Chart name [ only use either `path` or `chart` ] |
| targetRevision | string | `"1.2.3"` or `"master"`       | Version of Helm-Chart or Branch/Tag of git |

## Optional 

| Parameter         | Type   | Default | Example | Description |
|-------------------|--------|---------|---------|-------------|
| existingNamespace | string | none | `"default"` | Don't create namespace, instead use an existing one |
| namespace         | string | Namespace of project | `"superns"` | Name of application namespace |
| annotations       | hash   |         | `my.anno.org/stuff: is-awesome` | Kubernetes Resource annotations |
| syncWave          | string | `"0"`    | `"-2" | ArgoCD SyncWave | 
| server            | string | `"https://kubernetes.default.svc"` | `https://my.external.cluster:8443` | K8s Cluster to deploy to |
| syncPolicy        | dict   | `{}` | See [values.yaml](https://github.com/lib42/heqet/blob/v3/charts/heqet/values.yaml#L12) | ArgoCD automatic syncPolicy |
| ignoreDiff        | array  |     | See ArgoCD docs | ArgoCD [ignoreDifferences](https://argoproj.github.io/argo-cd/user-guide/diffing/)
| parameters        | array  |     |- name: ingress.host<br>value: awesome.url | Parameters override values of app |
| include           | array  |     | - value-snippet  | Include a values snippet from `resources/snippets` |

## Full Example

Check out my [Homelab config](https://github.com/nold360/hive-apps)

# Project Definition

Here is a list of available configuration options inside the `apps` array of heqets `values.yaml`.

## Project Config

Project configuration parameters will be merged into application parameters. So basically all application parameters can be used here.

Special project parameters: 

| Parameter | Type   | Default | Example | Description |
|-----------|--------|---------|---------|-------------|
| name      | string | Name of project directory | my-project | Name of project in Argo-CD |
| namespace | string | Name of project | myspace | Name of default Namespace of projects apps |
| description | string | None | "My great project" | Description of project in Argo-CD |
| networkPolicy | dict | None | See [addons/networkpolicy](/addons/networkpolicy) |

## Project Defaults

There is a dedicated hash for all ArgoCD `AppProject` CRDs getting created. It's called `projectDefaults` and all values inside it get directly applied to all AppProjects.

[See values.yaml](https://github.com/lib42/heqet/blob/v3/charts/heqet/values.yaml#L32)


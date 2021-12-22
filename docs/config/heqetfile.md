# Heqetfile

The `Heqetfile` is a control file for the ArgoCD/helm Plugin and crutial to make heqet work.

Mostly it defines which heqet version to use and which `values.yaml` as default values for your projects.

## Example

Here is a simple yet complete example of a `Heqetfile`. Make sure to place it in the root directory of your git repository.

``` bash
# Heqetfile
#
# repo & branch/tag of heqet to use
heqet_repo=https://github.com/lib42/heqet.git
heqet_revision=v3

# Path to the heqet chart inside of the repo
heqet_path=charts/heqet

# Values file for defaults
heqet_values=values.yaml
``` 

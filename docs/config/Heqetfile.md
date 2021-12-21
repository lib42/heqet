# Heqetfile

The `Heqetfile` is a control file for the ArgoCD/helm Plugin and crutial to make heqet work.

Mostly it defines which heqet version to use and which `values.yaml` as default values for your projects.

## Example

Here is a simple yet complete example of a `Heqetfile`. Make sure to place it in the root directory of your git repository.

``` bash
# Heqetfile
#
# _repo & _revision define the source & branch/tag to checkout
# _path is the path to the heqet chart inside of the repo
#
heqet_repo=https://github.com/lib42/heqet.git
heqet_revision=v3
heqet_path=charts/heqet
heqet_values=values.yaml
``` 

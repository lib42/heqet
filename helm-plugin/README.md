# helm-heqet

A helm3 plugin for templating heqet configuration into kubernetes resources. It can also be used to validate your configuration.

## Installation

```sh
> helm plugin install https://github.com/lib42/heqet.git
```

## Usage

Important: All commands must be executed inside your heqet project & a `Heqetfile` in the current working directory!

* `helm heqet setup`: Clones heqet & insert your configuration
* `helm heqet update`: Updates heqet after setup
* `helm heqet template`: Templates the Heqet Chart with your config
* `helm heqet validate`: Simple syntax validation test
* `helm heqet generate`: Combination of update & template [for CI/CD usage]
* `helm heqet help`: print help

## Example

```sh
> helm heqet setup
> helm heqet template
```

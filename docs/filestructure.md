# Configuration Filestructure

Heqet is highly opinionated about the filestructure of the userdata repository. Here is a quick overview how it should look like:

This is a quick overview how your "userdata" repository needs to be structured:
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

* `Heqetfile` - Important config file for ArgoCD/heqet. See [Heqetfile](/heqet/config/heqetfile)
* `projects/` - This directory contains all your Application/Project config
  * `name-of-project/` - This directory name represents the name of our project
    * `project.yaml` - The most important config, containing all our applications of this project
    * `values/` - Every app in our project can have it's own `values.yaml` here, named: `name-of-app.yaml`
      * `name-of-app.yaml` - Values file for the application "name-of-app"
    * `manifests/` - Static YAML-files for the project
* `resources/` - This directory contains all global config, like NetworkPolcies, Repos 
   * `manifests/` - Can be used for static YAML-Manifests
   * `snippets/` - Value snippets that can be included using `include`-Array in apps

## Overview

![Heqet Overview](https://lib42.github.io/heqet/assets/heqet-directory-overview.jpg)

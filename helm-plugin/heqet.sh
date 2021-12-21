#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

set -e

usage() {
cat << EOF
Setup, update & template heqet application configuration.

All commands need to be executed with Heqetfile in current working directory.

Available Commands:
  helm heqet setup       Setup heqet for current working directory. Requires Heqetfile.
  helm heqet update      Update heqet after setup
  helm heqet template    Template heqet configuration
  helm heqet validate    Validate heqet configuration
  helm heqet generate    Combination of update and template [for CI/CD usage]
  helm heqet help        Show this message
EOF
}

# Heqet Config
if [ -f Heqetfile ] ; then
  . Heqetfile
else
  echo "Error: Couldn't find Heqetfile in current working directory."
  exit 1
fi

HEQET_REPO="${heqet_repo:-https://github.com/lib42/heqet.git}"
HEQET_REVISION="${heqet_revision:-v3}"
HEQET_PATH="${heqet_path:-charts/heqet}"
HEQET_VALUES="${heqet_values:-values.yaml}"
USERDATA_REPO=$(pwd)
#USERDATA_REVISION=

HEQET_TMPDIR="${HEQET_TMPDIR:-${HELM_DATA_HOME}/heqet}"

# Clone Heqet-Code & add current directory as userdata submodule
function setup {
  if [ ! -d ${HEQET_TMPDIR} ] ; then
		git clone -b ${HEQET_REVISION} ${HEQET_REPO} ${HEQET_TMPDIR}
		ln -s ${USERDATA_REPO} ${HEQET_TMPDIR}/${HEQET_PATH}/userdata
    return $?
  elif [ -L ${HEQET_TMPDIR}/${HEQET_PATH}/userdata ] ; then
    rm -f ${HEQET_TMPDIR}/${HEQET_PATH}/userdata
    ln -s ${USERDATA_REPO} ${HEQET_TMPDIR}/${HEQET_PATH}/userdata
    update
    return $?
  else
    echo "ERROR: Directory '$HEQET_TMPDIR' exists, but '${HEQET_TMPDIR}/${HEQET_PATH}/userdata' is not a softlink."
    return 1
  fi
}

# Pull heqet git repo
function update {
  if [ -d ${HEQET_TMPDIR}/.git ] ; then
  	git -C ${HEQET_TMPDIR} fetch --all -v
    git -C ${HEQET_TMPDIR} pull --rebase
    git -C ${HEQET_TMPDIR} checkout ${HEQET_REVISION}
    return $?
  else
    echo "ERROR: Directory '${HEQET_TMPDIR}' doesn't seem to be a git repo. Did you call 'helm heqet setup'?"
    return 1
  fi
}

# Template Helm-Chart
function template {
  if [ -f ${HEQET_TMPDIR}/${HEQET_PATH}/Chart.yaml ] ; then
    helm template $@ ${HEQET_TMPDIR}/${HEQET_PATH} -f ${HEQET_VALUES}
    return $?
  else
    echo "ERROR: Couldn't find Chart.yaml in $HEQET_TMPDIR/${HEQET_PATH}. Did you call 'helm heqet setup'?"
    return 1
  fi
}

# Very basic validation to find yaml errors
function validate {
  if template 2>&1 | grep -E -B10 'error converting YAML to JSON|^Error:' ; then
    echo " --> Validation failed"
    return 1
  else
    echo " --> Validation successfull"
    return 0
  fi
}

COMMAND="$1"
case ${COMMAND} in
  "setup") setup; exit $? ;;
  "update") update; exit $? ;;
  "template") template $@; exit $? ;;
  "validate") validate; exit $? ;;
  # This is used by the ArgoCD CM-Plugin:
  "generate") update &>/dev/null && template 2>/dev/null; exit $? ;;
  *) usage; exit 0 ;;
esac
exit 0

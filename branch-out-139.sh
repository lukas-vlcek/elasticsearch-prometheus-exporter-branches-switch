#!/usr/bin/env bash

set -euxo pipefail

function usage() {
    cat <<EOF
Usage: $0
This script converts clone of elasticsearch-prometheus-exporter repository into
branches as discussed in https://github.com/vvanholl/elasticsearch-prometheus-exporter/issues/139

In the beginning it will make a fresh clone of "Elasticsearch" and "ES Prometheus plugin" repositories
into local folder, alternatively, you can set the following variables:

ESPP_REPO_PATH - path where the Elasticsearch Prometheus Plugin repo is cloned into
                 (defaults to ./elasticsearch-prometheus-exporter).
                 Any existing folder at this part is deleted first when this script starts.

ES_REPO_PATH - path where the Elasticsearch repo is cloned into (defaults to ./elasticsearch).
               Any existing folder at this part is deleted first when this script starts.

SKIP_ESPP_DOWNLOAD - skip cloning ES Prometheus plugin source code. Assuming local copy is used (defaults to 0).
                     This is useful to locally debug the code.

SKIP_ES_DOWNLOAD - skip cloning Elasticsearch code. Assuming local copy is used (defaults to 0).
                   This is useful to locally debug the code.

EOF
}

echo Versions used
git --version #TODO: check we have git version >= 2.0, https://stackoverflow.com/a/14273595
grep --version

SCRIPT_HOME=`pwd`

ESPP_REPO_NAME=elasticsearch-prometheus-exporter
ESPP_REPO_URL=https://github.com/vvanholl/${ESPP_REPO_NAME}.git
SKIP_ESPP_DOWNLOAD=${SKIP_ESPP_DOWNLOAD:-0}

ES_REPO_NAME=elasticsearch
ES_REPO_URL=https://github.com/elastic/${ES_REPO_NAME}.git
SKIP_ES_DOWNLOAD=${SKIP_ES_DOWNLOAD:-0}

case "${1:-}" in
--h*|-h*) usage ; exit 1 ;;
esac

# grep options use different syntax depending on host type
# https://ponderthebits.com/2017/01/know-your-tools-linux-gnu-vs-mac-bsd-command-line-utilities-grep-strings-sed-and-find/
function bsd_or_gnu_grep_switch() {
    local switch="dunno"
    # BSD or GNU?
    if date -v 1d > /dev/null 2>&1; then
      #BSD
      switch='-Eo'
    else
      # GNU
      switch='-Po'
    fi
    echo ${switch}
}

function clone_repo() {
    local repo_url="$1"
    local repo_path="$2"
    shift; shift
    local args=( "${@:-}" )

    if [[ -d ${repo_path} ]] ; then
      rm -rf ${repo_path}
    fi
    git clone ${repo_url} ${repo_path}
}

export ESPP_REPO_PATH=${ESPP_REPO_PATH:-$SCRIPT_HOME/$ESPP_REPO_NAME}
       ES_REPO_PATH=${ES_REPO_PATH:-$SCRIPT_HOME/$ES_REPO_NAME}
       SKIP_ESPP_DOWNLOAD=${SKIP_ESPP_DOWNLOAD:-0}
       SKIP_ES_DOWNLOAD=${SKIP_ES_DOWNLOAD:-0}

declare -a es_versions=("2" "5" "6")
#declare -a es_versions=("5" "6") # let's skip branch 2x for now...

if [[ "${SKIP_ESPP_DOWNLOAD:-0}" = 0  ]] ; then
    clone_repo ${ESPP_REPO_URL} ${ESPP_REPO_PATH}
fi
if [[ "${SKIP_ES_DOWNLOAD:-0}" = 0  ]] ; then
    clone_repo ${ES_REPO_URL} ${ES_REPO_PATH}
fi

# Print all relevant release tags of ES Prometheus plugin
pushd ${ESPP_REPO_PATH}
  for es_ver in "${es_versions[@]}"
    do
      echo "Found ES Prometheus plugin releases for v${es_ver}"
      git tag --sort=v:refname 2>/dev/null | grep $(bsd_or_gnu_grep_switch) "^${es_ver}\.\d+\.\d+\.\d+$"
    done
popd

# Print all relevant release tags of Elasticsearch
pushd ${ES_REPO_PATH}
  for es_ver in "${es_versions[@]}"
    do
      echo "Found Elasticsearch releases for v${es_ver}"
      git tag --sort=v:refname 2>/dev/null | grep $(bsd_or_gnu_grep_switch) "^v${es_ver}\.\d+\.\d+$" # skipping alpha, beta, rc, ...
    done
popd

#!/usr/bin/env bash

set -euxo pipefail

usage() {
    local bn=$( basename $0 )
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

SKIP_ESPP_DOWNLOAD - skip cloning ES Prometheus plugin source code. Assuming local copy is used.
                     This is useful to locally debug the code.

SKIP_ES_DOWNLOAD - skip cloning Elasticsearch code. Assuming local copy is used.
                   This is useful to locally debug the code.

EOF
}


SCRIPT_HOME=`pwd`

ESPP_REPO_NAME=elasticsearch-prometheus-exporter
ESPP_REPO_URL=https://github.com/vvanholl/${ESPP_REPO_NAME}.git
SKIP_ESPP_DOWNLOAD=0 # false

ES_REPO_NAME=elasticsearch
ES_REPO_URL=https://github.com/elastic/${ES_REPO_NAME}.git
SKIP_ES_DOWNLOAD=0 # false

case "${1:-}" in
--h*|-h*) usage ; exit 1 ;;
esac

export ESPP_REPO_PATH=${ESPP_REPO_PATH:-$SCRIPT_HOME/$ESPP_REPO_NAME}
       ES_REPO_PATH=${ES_REPO_PATH:-$SCRIPT_HOME/$ES_REPO_NAME}
       SKIP_ESPP_DOWNLOAD=${SKIP_ESPP_DOWNLOAD:-0}
       SKIP_ES_DOWNLOAD=${SKIP_ES_DOWNLOAD:-0}

# ----------------------------------
# Clone Plugin code locally
# ----------------------------------
if [[ "${SKIP_ESPP_DOWNLOAD:-0}" = 1  ]] ; then
    if [[ -d ${ESPP_REPO_PATH} ]] ; then
      rm -rf ${ESPP_REPO_PATH}
    fi
    git clone ${ESPP_REPO_URL} ${ESPP_REPO_PATH}
fi
pushd ${ESPP_REPO_PATH}
  ls -la
  git fetch
  git branch -a
popd

# ----------------------------------
# Clone Elasticsearch code locally
# ----------------------------------
if [[ "${SKIP_ES_DOWNLOAD:-0}" = 1  ]] ; then
    if [[ -d ${ES_REPO_PATH} ]] ; then
      rm -rf ${ES_REPO_PATH}
    fi
    git clone ${ES_REPO_URL} ${ES_REPO_PATH}
fi

declare -a es_versions=("2" "5" "6")
#declare -a es_versions=("5" "6")
pushd ${ES_REPO_PATH}
  ls -la
  git fetch
  for es_ver in "${es_versions[@]}"
    do
      echo "Found Elasticsearch releases for v${es_ver}"
      git tag 2>/dev/null | grep "^v${es_ver}\.\d\.\d$" # skipping alpha, beta, rc, ...
    done
popd

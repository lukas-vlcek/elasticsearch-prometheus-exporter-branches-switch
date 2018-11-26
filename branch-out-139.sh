#!/usr/bin/env bash

set -euxo pipefail

usage() {
    local bn=$( basename $0 )
    cat <<EOF
Usage: $0
This script converts elasticsearch-prometheus-exporter repository into
branches as discussed in https://github.com/vvanholl/elasticsearch-prometheus-exporter/issues/139

In the beginning it will make a fresh clone of the original repository
into local folder, alternatively, you can set the following variables:

ESPP_REPO_PATH - path where the Elasticsearch Prometheus Plugin repo is cloned into
                 (defaults to ./elasticsearch-prometheus-exporter).
                 Any existing folder at this part is deleted first when this script starts.

EOF
}


SCRIPT_HOME=`pwd`
REPO_NAME=elasticsearch-prometheus-exporter
ESPP_REPO_URL=https://github.com/vvanholl/${REPO_NAME}.git

case "${1:-}" in
--h*|-h*) usage ; exit 1 ;;
esac

export ESPP_REPO_PATH=${ESPP_REPO_PATH:-$SCRIPT_HOME/$REPO_NAME}

if [ -d ${ESPP_REPO_PATH} ] ; then
  rm -rf ${ESPP_REPO_PATH}
fi

git clone ${ESPP_REPO_URL} ${ESPP_REPO_PATH}
pushd ${ESPP_REPO_PATH}
  ls -la
  git fetch
  git branch -a
popd


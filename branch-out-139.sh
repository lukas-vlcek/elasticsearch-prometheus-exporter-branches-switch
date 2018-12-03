#!/usr/bin/env bash

#set -euxo pipefail

function usage() {
    cat <<EOF
Usage: $0

Example: $0 1> branching.log 2> error.log

This script converts elasticsearch-prometheus-exporter repository into
branches as discussed in https://github.com/vvanholl/elasticsearch-prometheus-exporter/issues/139

In the beginning it will make a fresh clone of "Elasticsearch" and "ES Prometheus plugin" repositories
into local folders, alternatively, you can set the following variables:

DRY_RUN - if true then no changes are made to local plugin repo clone (defaults to true).

PUSH_CHANGES_BACK - if false then no branches are pushed to plugin origin repo (defaults to false).

ESPP_REPO_URL - defaults to https://github.com/vvanholl/elasticsearch-prometheus-exporter.git

ESPP_CLONE_PATH - local path where the Elasticsearch Prometheus Plugin repo is cloned into
                  (defaults to ./elasticsearch-prometheus-exporter).
                  Any existing folder at this path is deleted first when this script starts.

SKIP_ESPP_CLONE - skip cloning ES Prometheus plugin source code. Assuming local copy is used (defaults to false).
                  This is useful to locally debug the code.

ES_REPO_URL - defaults to https://github.com/elastic/elasticsearch.git

ES_CLONE_PATH - local path where the Elasticsearch repo is cloned into (defaults to ./elasticsearch).
                Any existing folder at this path is deleted first when this script starts.

SKIP_ES_CLONE - skip cloning Elasticsearch code. Assuming local copy is used (defaults to false).
                This is useful to locally debug the code.
EOF
}

#echo Versions used
#git --version #TODO: check we have git version >= 2.0, https://stackoverflow.com/a/14273595
#grep --version

SCRIPT_HOME=`pwd`
DRY_RUN=${DRY_RUN:-true}
PUSH_CHANGES_BACK=${PUSH_CHANGES_BACK:-false}

ESPP_REPO_NAME=elasticsearch-prometheus-exporter
ESPP_REPO_URL=${ESPP_REPO_URL:-https://github.com/vvanholl/${ESPP_REPO_NAME}.git}
SKIP_ESPP_CLONE=${SKIP_ESPP_CLONE:-false}
ESPP_CLONE_PATH=${ESPP_CLONE_PATH:-$SCRIPT_HOME/$ESPP_REPO_NAME}

ES_REPO_NAME=elasticsearch
ES_REPO_URL=${ES_REPO_URL:-https://github.com/elastic/${ES_REPO_NAME}.git}
SKIP_ES_CLONE=${SKIP_ES_CLONE:-false}
ES_CLONE_PATH=${ES_CLONE_PATH:-$SCRIPT_HOME/$ES_REPO_NAME}

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

# argument is major ES version number (like "2")
function list_es_releases() {
    local es_major_ver="$1"
    shift
    local args=( "${@:-}" )

    pushd ${ES_CLONE_PATH} > /dev/null
    # pull all git tags for given major version; skipping alpha, beta, rc, ...
    local -a array=($(git tag --sort=v:refname 2>/dev/null | grep $(bsd_or_gnu_grep_switch) "^v${es_major_ver}\.\d+\.\d+$"))
    popd > /dev/null
    # get rid of the "v" prefix
    for ix in ${!array[*]} ; do echo "${array[$ix]}" | cut -c 2-20 ; done
}

# argument is ES release version number (like "2.4.2")
function list_plugin_releases() {
    local es_release_ver="$1"
    shift
    local args=( "${@:-}" )

    pushd ${ESPP_CLONE_PATH} > /dev/null
#    git tag --sort=v:refname 2>/dev/null | grep $(bsd_or_gnu_grep_switch) "^${es_major_ver}\.\d+\.\d+\.\d+$"
    git tag --sort=v:refname 2>/dev/null | grep $(bsd_or_gnu_grep_switch) "^${es_release_ver}\.\d+$"
    popd > /dev/null
}

if [[ "false" == "${SKIP_ESPP_CLONE}" = 0  ]] ; then
    clone_repo ${ESPP_REPO_URL} ${ESPP_CLONE_PATH}
fi
if [[ "false" == "${SKIP_ES_CLONE}" = 0  ]] ; then
    clone_repo ${ES_REPO_URL} ${ES_CLONE_PATH}
fi

# Which major ES releases we are going to process
declare -a es_major_versions=("2" "5" "6")

for es_major_ver in "${es_major_versions[@]}"
do
  echo "Processing Elasticsearch releases for v${es_major_ver}.x:"
  releases=$(list_es_releases ${es_major_ver})
  for es_release in ${releases}
  do
     # Print all relevant release tags of ES Prometheus plugin
    echo "  - ES v${es_release}"
    release_branches=($(list_plugin_releases ${es_release}))
    rb_Len=${#release_branches[@]}
    if [[ $rb_Len = 0 ]] ; then
      (>&2 echo "    - No plugin releases found for ES ${es_release}; you might want to fix this manually")
    else
      echo "    - Create and populate new branch ${es_release} to include tags:"
      for new_branch in "${release_branches[@]}"
      do
        echo "      - ${new_branch}"
      done
      commands="git checkout ${release_branches[${#release_branches[@]}-1]}"
      commands="${commands}; git checkout -b ${es_release}"
#      if [[ "true" == "${PUSH_CHANGES_BACK}" ]] ; then
#        commands="${commands}; git push origin ${es_release}"
#      fi
      commands="${commands}; git checkout master"
      echo "      \$ ${commands}"
      if [[ "false" == "${DRY_RUN}" ]] ; then
        pushd ${ESPP_CLONE_PATH} > /dev/null
        eval ${commands}
        popd > /dev/null
      fi
    fi
  done
done

if [[ "true" == "${PUSH_CHANGES_BACK}" ]] ; then
  commands="git push origin --all"
  echo "\$ ${commands}"
  if [[ "false" == "${DRY_RUN}" ]] ; then
    pushd ${ESPP_CLONE_PATH} > /dev/null
    eval ${commands}
    popd > /dev/null
  fi
fi

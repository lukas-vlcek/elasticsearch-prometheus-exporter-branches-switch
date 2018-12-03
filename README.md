# elasticsearch-prometheus-exporter-branches-switch

[![Build Status](https://travis-ci.org/lukas-vlcek/elasticsearch-prometheus-exporter-branches-switch.svg?branch=master)](https://travis-ci.org/lukas-vlcek/elasticsearch-prometheus-exporter-branches-switch)

Supporting scripts to migrate [elasticsearch-prometheus-exporter](https://github.com/vvanholl/elasticsearch-prometheus-exporter)
project to new branching model. See https://github.com/vvanholl/elasticsearch-prometheus-exporter/issues/139 for general discussion and further details.

## How to use this script

**IMPORTANT: This script can push new branches to origin repository!** However, in practice you need to enable two different
environment variables to make this really happen, so it is save to run this script OOB on local machine.


First of all, let's get familiar with tweaking options:
```bash
$ ./branch-out-139.sh --help
Usage: ./branch-out-139.sh

Example: ./branch-out-139.sh 1> branching.log 2> error.log

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
```


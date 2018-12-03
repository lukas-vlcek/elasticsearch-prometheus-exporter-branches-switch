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

I would recommend using this script in few stages:

### Just dry run

```bash
./branch-out-139.sh
```

This will clone both the Elasticsearch and Prometheus plugin into local folders and then it will print what changes would
be done in local copy of the plugin repo but none of them is actually made. I suggest going though the output first.

### Speed thing up a bit

```bash
SKIP_ES_CLONE=true ./branch-out-139.sh
```

Creating a fresh clone of Elasticsearch repo can take some time. It is not necessary to create it again and again.
It is enough to have it cloned once. We do not expect important changes being committed into ES while using this script.

### Missing plugin releases

```bash
SKIP_ES_CLONE=true ./branch-out-139.sh 2> error.log
cat error.log
```

Believe it or not but for some ES releases this plugin does not have a release. This script does not address missing
releases in any, we are only taking this opportunity to identify them.

### Better try it on plugin repository copy

```bash
export SKIP_ES_CLONE=true
export ESPP_REPO_URL=https://github.com/lukas-vlcek/elasticsearch-prometheus-exporter-branching-test.git
./branch-out-139.sh
```

By default the script will use the production plugin repository, however, if you create a copy of it you can
provide repo URL. This way we can test things a bit more before running it on production repository.

### Create new branches locally only

```bash
export SKIP_ES_CLONE=true
export ESPP_REPO_URL=https://github.com/lukas-vlcek/elasticsearch-prometheus-exporter-branching-test.git
export DRY_RUN=false
./branch-out-139.sh
cd elasticsearch-prometheus-exporter
git branch
```

This will actually create new branches in local copy of the plugin repository.

### Push new branches into GitHub

```bash
export SKIP_ES_CLONE=true
export ESPP_REPO_URL=https://github.com/lukas-vlcek/elasticsearch-prometheus-exporter-branching-test.git
export DRY_RUN=false
export PUSH_CHANGES_BACK=true
./branch-out-139.sh
```

This will actually push all the new branches into remote plugin repository. Notice, that in this example
we are still using copy of the production repository. Should we leave out the `ESPP_REPO_URL` param then
the changes would be pushed to production plugin repo (which also assumes use has repo push privilege).

You can also leave out (or **unset** if they are already set!!!) both the `ESPP_REPO_URL` and `PUSH_CHANGES_BACK` params 
which will allow you to push all the changes manually into production repo, like:

```bash
export SKIP_ES_CLONE=true
export DRY_RUN=false
./branch-out-139.sh
cd elasticsearch-prometheus-exporter
git push origin --all
```

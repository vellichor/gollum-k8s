#!/bin/bash
# WD must be git repo
pushd /wiki-data
git pull
git push
popd
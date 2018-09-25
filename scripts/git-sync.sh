#!/bin/bash
# WD must be git repo
pushd /wiki-data > /dev/null
git pull -q
git push -q
popd > /dev/null
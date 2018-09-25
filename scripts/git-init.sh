#!/bin/bash

# get the ssh keypair from the secret mount
# this is idempotent
SSH_ROOT=/root/.ssh
mkdir -p $SSH_ROOT
cp /git-secret/id_rsa* $SSH_ROOT
chmod 700 $SSH_ROOT/id_rsa

# the WD should be the place we are expecting a git repo
# if nothing is there, nuke and clone.
# WARNING DESTRUCTIVE don't mount anything here you care about.
if [[ ! -d .git ]]; then
  rm -rf * # this directory has to be empty, WARNING THIS NUKES FROM ORBIT.
  git clone $GOLLUM_GIT_REPO .
fi

# make sure things are (and stay) up to date for us
git fetch
git pull
cp /var/share/gollum/post-commit .git/hooks/post-commit

# start cron and poll for changes every minute.
cron
# cron only installs a new crontab when this directory changes,
# so move the script AFTER cron has started or nothing will happen.
sleep 5
cp /var/share/gollum/crontab /etc/cron.d/git-sync-cron
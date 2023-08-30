#!/bin/sh
set -e

# workaround for mounted volume ssh key permissions
# https://nickjanetakis.com/blog/docker-tip-56-volume-mounting-ssh-keys-into-a-docker-container
cp -R /tmp/.ssh /root/.ssh
chmod 600 -R /root/.ssh
chmod 700 /root/.ssh
# https://askubuntu.com/a/889348
find /root/.ssh -type f -iname "*.pub" -exec chmod 644 {} \;

exec "$@"

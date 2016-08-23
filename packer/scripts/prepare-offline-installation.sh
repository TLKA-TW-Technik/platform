#!/bin/sh

# Preparations for offline installations:
#
# * Download debian packages into the local package cache
# * Pull required docker images
#

REGULAR_PACKAGES="
git
dnsmasq
mariadb-server
mariadb-client
python-mysqldb
keepalived
nginx-light
python-redis
redis-tools
redis-server
nfs-kernel-server
rpcbind
glusterfs-server
glusterfs-client
nfs-common
"

BACKPORTS_PACKAGES="
python-docker
"

DOCKER_IMAGES="
teamwire/backend
teamwire/web-screenshot-server
teamwire/notification-server
"

if [ -z "$offline_installation" ] ; then
	echo "Not preparing for offline installation."
	exit
fi

echo "Preparing for offline installation."

# This file will be checked by the Ansible scripts; if it exists,
# the apt cache will not be updated.
sudo touch /etc/offline_installation

echo "Step 1: caching packages"
echo "========================"

sudo apt-get install -qyd $REGULAR_PACKAGES
sudo apt-get install -t jessie-backports -qyd $BACKPORTS_PACKAGES

echo "Step 2: Getting Docker containers"
echo "================================="
# We need to use sudo as the teamwire user is apparently not yet updated
sudo docker login -u "$dockerhub_username" -p "$dockerhub_password"
for IMAGE in $DOCKER_IMAGES ; do
	sudo docker pull "$IMAGE":prod
done
sudo rm -rf /root/.docker

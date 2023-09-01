#!/bin/bash

set -e

FOLDER_ID=$(yc config list | grep folder-id | awk '{print $2}')

yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory 2 \
  --cores 2 \
  --core-fraction 20 \
  --preemptible \
  --create-boot-disk image-folder-id=${FOLDER_ID},image-family=reddit-full,size=10GB \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --ssh-key ~/.ssh/appuser.pub

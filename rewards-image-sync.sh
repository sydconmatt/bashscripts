#!/usr/bin/env bash

#
#          name: rewards-image-sync.sh
#        author: Matthew Draper
#   description: Syncs/Copies rewards admin images to rewards images.
# last modified: 03/22/2019
#

# Probably could set up an ssh key from the admin to live to remove intermediate downloads step
# Not a good idea to use personal ssh key on admin server. If compromised it would grant attacker
# access to all NGC servers you have access to.

# This is my personal ssh hostname for new-admin1
REWARDS_ADMIN_SSH='production-ngc-admin' # <- CHANGE THE TO YOUR HOSTNAME IN YOUR SSH CONFIG FOR NEW ADMIN 1
REWARDS_ADMIN_IMG_PATH='/var/www/images'
REWARDS_ADMIN_TMP='/tmp/rewards-images-admin' # <- CHANGE THIS TO THE HOSTNAME IN YOUR SSH CONFIG FOR NEW WEB 1
# This is my personal ssh hostname for new-web1
REWARDS_LIVE_SSH='production-ngc'
REWARDS_LIVE_IMG_PATH='/var/www/rewards/images'
REWARDS_LIVE_TMP='/tmp/rewards-images-live'

mkdir -p /tmp/rewards-images-admin /tmp/rewards-images-live
# Save all the admin files in you /tmp folder
rsync -azP $REWARDS_ADMIN_SSH:$REWARDS_ADMIN_IMG_PATH/ $REWARDS_ADMIN_TMP/
# Backup the live images as well
rsync -azP $REWARDS_LIVE_SSH:$REWARDS_LIVE_IMG_PATH/ $REWARDS_LIVE_TMP/
# Copy all of the images from the admin tmp folder that are updated or not on the live server
ssh $REWARDS_LIVE_SSH << EOF
  sudo chmod 0660 -R "${REWARDS_LIVE_IMG_PATH}"/*
  sudo chmod 0770 "${REWARDS_LIVE_IMG_PATH}"/ie6
  sudo chown $(whoami):www-data -R "${REWARDS_LIVE_IMG_PATH}"/*
  sudo chown $(whoami):www-data "${REWARDS_LIVE_IMG_PATH}"
EOF
rsync -azP $REWARDS_ADMIN_TMP/ $REWARDS_LIVE_SSH:$REWARDS_LIVE_IMG_PATH/
# SSH and change the owner and group to apache and only allow apache read and write privileges
ssh $REWARDS_LIVE_SSH << EOF
  sudo chmod 0660 -R "${REWARDS_LIVE_IMG_PATH}"/*
  sudo chmod 0770 "${REWARDS_LIVE_IMG_PATH}"/ie6
  sudo chown apache:www-data -R "${REWARDS_LIVE_IMG_PATH}"/*
  sudo chmod 0770 "${REWARDS_LIVE_IMG_PATH}"
  sudo chown apache:www-data "${REWARDS_LIVE_IMG_PATH}"
EOF
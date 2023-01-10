#!/bin/bash

# Workaround for https://github.com/kwk/docker-registry-frontend/issues/159
# Remove apache2.pid left over from previous dirty exit
if [ -f /var/run/apache2/apache2.pid ]
then
  echo "Removing /var/run/apache2/apache2.pid"
  rm /var/run/apache2/apache2.pid
fi

# Now run start command from https://github.com/kwk/docker-registry-frontend/blob/v2/Dockerfile
$START_SCRIPT
#!/bin/bash

docker run -d --name cockpit -p 8080:80 agentejo/cockpit

# http://localhost:8080/install
# Create your container by running

# docker run -d --name cockpit -p 8080:80 agentejo/cockpit
# To complete the setup, open http://localhost:8080/install and follow the instructions there.
# http://localhost:8080/collections

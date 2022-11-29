FROM ubuntu:latest

# Update the base packages
RUN apt update -y && apt upgrade -y && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    curl jq wget build-essential libssl-dev libffi-dev python-is-python3 python3 python3-venv python3-dev python3-pip \
    nano vim gcc git dos2unix ffmpeg libsm6 libxext6 libgl1 ca-certificates gnupg gnupg2 lsb-release zip unzip \
    software-properties-common apt-transport-https
RUN curl -fsSL https://get.docker.com | sh
RUN apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
RUN python -m pip install --upgrade pip
RUN python -m pip install pytest repository-manager build twine geniusbot

# Permissions to Docker
RUN chmod 666 /var/run/docker.sock

# Add user
RUN useradd -m dockercli
RUN usermod -a -G docker dockercli
RUN usermod -a -G sudo dockercli

# Github runner version
ARG RUNNER_VERSION="2.299.1"

# Set PyPi Credentials
# ARG PYPI_USERNAME="__token__"
# ARG PYPI_PASSWORD="PASSWORD"
# ENV PYPI_USERNAME=${PYPI_USERNAME}
# ENV PYPI_PASSWORD=${PYPI_PASSWORD}
RUN echo -e "[pypi]\nusername = ${PYPI_USERNAME}\npassword = ${PYPI_PASSWORD}\n" | tee $HOME/.pypirc

# cd into the user directory. download and unzip the github actions runner
RUN cd /home/dockercli && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install additional dependencies
RUN chown -R dockercli ~dockercli && /home/dockercli/actions-runner/bin/installdependencies.sh

# Copy the start.sh script
COPY start.sh start.sh

# Script executable
RUN chmod +x start.sh

# Since the config and run script for actions are not allowed to be run by root,
# set the user to "dockercli" so all subsequent commands are run as the dockercli user
USER dockercli

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
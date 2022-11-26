# base
FROM ubuntu:latest

# update the base packages and add a non-sudo user
RUN apt update -y && apt upgrade -y && apt install -y nano vim gcc git dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq wget build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip
RUN curl -sSL https://get.docker.com/ | sh
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pytest repository-manager build
RUN useradd -m docker

# set the github runner version
ARG RUNNER_VERSION="2.299.1"

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
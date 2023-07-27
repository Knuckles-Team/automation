FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    software-properties-common \
    pandoc \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y python3.10 python3.10-dev python3-dev libpython3.10-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY requirements.txt requirements.txt
COPY reqs_optional reqs_optional
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
RUN python3.10 -m pip install -r requirements.txt
RUN python3.10 -m pip install -r reqs_optional/requirements_optional_langchain.txt
RUN python3.10 -m pip install -r reqs_optional/requirements_optional_gpt4all.txt
RUN python3.10 -m pip install -r reqs_optional/requirements_optional_langchain.gpllike.txt
RUN python3.10 -m pip install -r reqs_optional/requirements_optional_langchain.urls.txt

COPY . .
ENTRYPOINT [ "python3.10"]

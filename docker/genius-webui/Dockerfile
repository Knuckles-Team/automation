FROM python:3.11-slim AS ubuntu
WORKDIR  /genius
RUN DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y \
    && apt install unzip gcc g++ curl gnupg ca-certificates -y \
    && pip install --upgrade pip \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=20 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update && apt install nodejs -y
COPY ./requirements.txt requirements.txt
RUN pip install --upgrade --no-cache-dir reflex && pip install --no-cache-dir -r requirements.txt
COPY ./assets ./webui ./rxconfig.py /genius
RUN reflex init && reflex db init && reflex db makemigrations && reflex db migrate
CMD [ "reflex", "run", "--frontend-port", "8099" ]
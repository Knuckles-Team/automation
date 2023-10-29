FROM python:3.11-slim AS ubuntu
#ARG OPENAI_API_KEY="NA"
#ARG OPENAI_API_BASE="http://localhost:8080/v1"
#ARG WEBUI_API_URL="http://localhost:8000"
WORKDIR  /genius_assimilator
RUN DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y \
    && apt install unzip -y \
    && pip install --upgrade pip \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=20 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update && apt install nodejs -y
COPY ./genius_assimilator/requirements.txt requirements.txt
RUN pip install --upgrade --no-cache-dir reflex && pip install --no-cache-dir -r requirements.txt
COPY ./genius_assimilator/ /genius_webui
#CMD [ "reflex", "run", "--frontend-port", "8099" ]
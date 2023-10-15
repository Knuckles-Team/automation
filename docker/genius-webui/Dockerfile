FROM ubuntu:latest AS ubuntu
RUN apt update && apt upgrade && apt install python3 python3-pip python-is-python3 ca-certificates curl gnupg -y
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN NODE_MAJOR=20 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update && apt install nodejs -y
RUN python -m pip install --upgrade pip && python -m pip install genius-chatbot
WORKDIR /genius
COPY ./ ./
RUN npm install
RUN genius-chatbot --assimilate "/genius/documents"
CMD ["node", "server.js"]
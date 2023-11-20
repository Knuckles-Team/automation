FROM nodejs:latest AS ubuntu
WORKDIR /genius
COPY ./ ./
RUN npm install
CMD ["node", "server.js"]
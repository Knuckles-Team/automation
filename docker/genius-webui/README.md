node server.js

curl -X POST -H "Content-Type: application/json" -d '{"parameter": "What is XSS?"}' http://localhost:8099/prompt



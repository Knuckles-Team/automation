#!/usr/bin/python

import gitlab_api

token = "glpat-JMKXyGxqzn3BFjrgrfsc"
gitlab_url = "http://localhost:8080/"
client = gitlab_api.Api(url=gitlab_url, token=token)

#print(client.get_users())


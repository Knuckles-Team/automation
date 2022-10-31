#!/usr/bin/python

import gitlab_api
from pprint import pprint

token = "glpat-JMKXyGxqzn3BFjrgrfsc"
gitlab_url = "http://localhost:8080/api/v4"
client = gitlab_api.Api(url=gitlab_url, token=token)

pprint(f"Users: {client.get_users()}\n\n")

pprint(f"Projects: {client.get_projects()}\n\n")

response = client.get_runners(runner_type='instance_type', all_runners=True)
pprint(f"Runners: {response}")

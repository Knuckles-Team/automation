#!/usr/bin/python

import gitlab_api

token = ";aslkdfj;alskjdf;alksjdf;alksjd"
gitlab_url = "<GITLAB_URL>"
client = gitlab_api.Api(url=gitlab_url, token=token)

print(client.get_users())


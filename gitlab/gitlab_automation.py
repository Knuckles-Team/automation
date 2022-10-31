#!/usr/bin/python

import gitlab_api

token = ";aslkdfj;alskjdf;alksjdf;alksjd"
client = gitlab_api.Api(token=token)

print(client.get_users())


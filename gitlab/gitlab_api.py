#!/usr/bin/python

import requests
import urllib3
from base64 import b64encode
from decorators import require_auth
from exceptions import (AuthError, UnauthorizedError, ParameterError, MissingParameterError)


class Api(object):

    def __init__(self, url=None, username=None, password=None, token=None, verify=True):
        if url is None:
            raise MissingParameterError

        self._session = requests.Session()
        self.url = url
        self.headers = None
        self.verify = verify

        if self.verify is False:
            urllib3.disable_warnings(urllib3.exceptions.InsecureRequestsWarning)

        if token:
            self.headers = {
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            }
        elif username and password:
            user_pass = f'{username}:{password}'.encode()
            user_pass_encoded = b64encode(user_pass).decode()
            self.headers = {
                'Authorization': f'Basic {user_pass_encoded}',
                'Content-Type': 'application/json'
            }
        else:
            raise MissingParameterError

        r = self._session.get(f'{self.url}/me/', headers=self.headers, verify=self.verify)

        if r.status_code == 403:
            raise UnauthorizedError
        elif r.status_code == 401:
            raise AuthError
        elif r.status_code == 404:
            raise ParameterError

    # Branch API
    @require_auth
    def get_branches(self, project_id=None):
        if project_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/branches',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_branch(self, project_id=None, branch=None):
        if project_id is None or branch is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/branches/{branch}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def create_branch(self, project_id=None, branch_name=None, reference=None):
        if project_id is None or branch_name is None or reference is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/'
                               f'branches?branch={branch_name}&ref={reference}',
                               headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def delete_branch(self, project_id=None, branch_name=None):
        if project_id is None or branch_name is None:
            raise MissingParameterError
        r = self._session.delete(f'{self.url}/projects/{project_id}/repository/branches?branch={branch_name}',
                                 headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_total_user_pages(self):
        r = self._session.get(f'{self.url}/users?per_page=100&x-total-pages',
                              headers=self.headers, verify=self.verify)
        return int(r.headers['X-Total-Pages'])

    @require_auth
    def get_users(self, max=0, order="updated"):
        r = []
        pages = self.get_total_user_pages()
        if order == "updated":
            order_by = "updated_at"
        else:
            order_by = "updated_at"
        if max == 0:
            max = len(pages)
        else:
            max = (max / 100) + 1
        for page in range(0, max):
            r_page = self._session.get(f'{self.url}/users?per_page=100&page={page}&order_by={order_by}',
                                       headers=self.headers, verify=self.verify)
            r = r + r_page
        return r

    @require_auth
    def get_user(self, user_id=None, sudo=False):
        if user_id is None:
            raise MissingParameterError
        if sudo:
            user_url = f"?sudo={user_id}"
        else:
            user_url = f"/{user_id}"
        r = self._session.get(f'{self.url}/users{user_url}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_total_runner_pages(self):
        r = self._session.get(f'{self.url}/runners?per_page=100&x-total-pages',
                              headers=self.headers, verify=self.verify)
        return int(r.headers['X-Total-Pages'])

    @require_auth
    def get_runners(self, max=0, order="updated"):
        r = []
        pages = self.get_total_runner_pages()
        if order == "updated":
            order_by = "updated_at"
        else:
            order_by = "updated_at"
        if max == 0:
            max = len(pages)
        else:
            max = (max / 100) + 1
        for page in range(0, max):
            r_page = self._session.get(f'{self.url}/runners?per_page=100&page={page}&order_by={order_by}',
                                       headers=self.headers, verify=self.verify)
            r = r + r_page
        return r

    @require_auth
    def get_runner(self, runner_id=None):
        if runner_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/runners/{runner_id}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_total_project_pages(self):
        r = self._session.get(f'{self.url}/projects?per_page=100&x-total-pages',
                              headers=self.headers, verify=self.verify)
        return int(r.headers['X-Total-Pages'])

    @require_auth
    def get_projects(self, max=0, order="updated"):
        r = []
        pages = self.get_total_runner_pages()
        if order == "updated":
            order_by = "updated_at"
        else:
            order_by = "updated_at"
        if max == 0:
            max = len(pages)
        else:
            max = (max / 100) + 1
        for page in range(0, max):
            r_page = self._session.get(f'{self.url}/projects?per_page=100&page={page}&order_by={order_by}',
                                       headers=self.headers, verify=self.verify)
            r = r + r_page
        return r

    @require_auth
    def get_project(self, project_id=None):
        if project_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}', headers=self.headers, verify=self.verify)
        return r


"""MERGE RULES
https://docs.gitlab.com/ee/api/merge_request_approvals.html

Get project-level rules
GET /projects/:id/approval_rules

Get a single project-level rule
GET /projects/:id/approval_rules/:approval_rule_id

Create project-level rule
POST /projects/:id/approval_rules

Update project-level rule
PUT /projects/:id/approval_rules/:approval_rule_id

Delete project-level rule
DELETE /projects/:id/approval_rules/:approval_rule_id

Merge request-level MR approvals
GET /projects/:id/merge_requests/:merge_request_iid/approvals

Get the approval state of merge requests
GET /projects/:id/merge_requests/:merge_request_iid/approval_state

Get merge request level rules
GET /projects/:id/merge_requests/:merge_request_iid/approval_rules

Approve merge request
POST /projects/:id/merge_requests/:merge_request_iid/approve

Approve merge request
POST /projects/:id/merge_requests/:merge_request_iid/unapprove


BRANCHES
https://docs.gitlab.com/ee/api/branches.html

List repository branches
GET /projects/:id/repository/branches

Get single repository branch
GET /projects/:id/repository/branches/:branch

Create repository branch
POST /projects/:id/repository/branches

Delete repository branch
DELETE /projects/:id/repository/branches/:branch

PROTECTED BRANCHES
https://docs.gitlab.com/ee/api/protected_branches.html#protect-repository-branches

List protected branches
GET /projects/:id/protected_branches

Get a single protected branch or wildcard protected branch
GET /projects/:id/protected_branches/:name

Protect repository branches
POST /projects/:id/protected_branches

Unprotect repository branches
DELETE /projects/:id/protected_branches/:name

Require code owner approvals for a single branch
PATCH /projects/:id/protected_branches/:name

PROJECTS
https://docs.gitlab.com/ee/api/projects.html

List a project’s groups
GET /projects/:id/groups

Archive a project
POST /projects/:id/archive

Unarchive a project
POST /projects/:id/unarchive

Delete project
DELETE /projects/:id

List all projects
GET /projects

GROUPS
https://docs.gitlab.com/ee/api/groups.html

List groups
GET /groups

List a group’s subgroups
GET /groups/:id/subgroups

List a group’s descendant groups
GET /groups/:id/descendant_groups

List a group’s projects
GET /groups/:id/projects

"""
#!/usr/bin/python

import json
import requests
import urllib3
from base64 import b64encode
from decorators import require_auth, validate_data
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

    ####################################################################################################################
    #                                                 Branches API                                                     #
    ####################################################################################################################
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
    def delete_merged_branches(self, project_id=None):
        if project_id is None:
            raise MissingParameterError
        r = self._session.delete(f'{self.url}/projects/{project_id}/repository/merged_branches',
                                 headers=self.headers, verify=self.verify)
        return r

    ####################################################################################################################
    #                                                 Commits API                                                      #
    ####################################################################################################################
    @require_auth
    def get_commits(self, project_id=None):
        if project_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_commit(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_commit_references(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/refs',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def cherry_pick_commit(self, project_id=None, commit_hash=None, data=None):
        if project_id is None or commit_hash is None or data is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/cherry_pick',
                              headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def create_commit(self, project_id=None, data=None):
        if project_id is None or data is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits',
                               headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def revert_commit(self, project_id=None, commit_hash=None, data=None):
        if project_id is None or commit_hash is None or data is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/revert',
                              headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def get_commit_diff(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/diff',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_commit_comments(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/comments',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def create_commit_comment(self, project_id=None, commit_hash=None, data=None):
        if project_id is None or commit_hash is None or data is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/comments',
                               headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def get_commit_discussions(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/discussions',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_commit_statuses(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/statuses',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def post_build_status_to_commit(self, project_id=None, commit_hash=None, data=None):
        if project_id is None or commit_hash is None or data is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/statuses/{commit_hash}/',
                               headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def get_commit_merge_requests(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/merge_requests',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_commit_gpg_signature(self, project_id=None, commit_hash=None):
        if project_id is None or commit_hash is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/merge_requests',
                              headers=self.headers, verify=self.verify)
        return r

    ####################################################################################################################
    #                                                Deploy Tokens API                                                 #
    ####################################################################################################################
    @require_auth
    def get_deploy_tokens(self):
        r = self._session.get(f'{self.url}/deploy_tokens', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_project_deploy_tokens(self, project_id=None):
        if project_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/deploy_tokens',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_project_deploy_token(self, project_id=None, token=None):
        if project_id is None or token is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/deploy_tokens/{token}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def create_project_deploy_token(self, project_id=None, data=None):
        if project_id is None or data is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/projects/{project_id}/deploy_tokens',
                              headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def delete_project_deploy_token(self, project_id=None, token=None):
        if project_id is None or token is None:
            raise MissingParameterError
        r = self._session.delete(f'{self.url}/projects/{project_id}/deploy_tokens/{token}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_group_deploy_tokens(self, group_id=None):
        if group_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/groups/{group_id}/deploy_tokens',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_group_deploy_token(self, group_id=None, token=None):
        if group_id is None or token is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/groups/{group_id}/deploy_tokens/{token}',
                              headers=self.headers, verify=self.verify)
        return r

    @require_auth
    @validate_data
    def create_group_deploy_token(self, group_id=None, data=None):
        if group_id is None or data is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/groups/{group_id}/deploy_tokens',
                              headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def delete_group_deploy_token(self, group_id=None, token=None):
        if group_id is None or token is None:
            raise MissingParameterError
        r = self._session.delete(f'{self.url}/groups/{group_id}/deploy_tokens/{token}',
                              headers=self.headers, verify=self.verify)
        return r

    ####################################################################################################################
    #                                                Users API                                                         #
    ####################################################################################################################
    @require_auth
    def get_users(self, max_pages=0, per_page=100, order="updated"):
        r = self._session.get(f'{self.url}/users?per_page={per_page}&x-total-pages',
                              headers=self.headers, verify=self.verify)
        total_pages = int(r.headers['X-Total-Pages'])
        r = []
        if order == "updated":
            order_by = "updated_at"
        else:
            order_by = "updated_at"
        if max_pages == 0 or max_pages > total_pages:
            max_pages = total_pages
        for page in range(0, max_pages):
            r_page = self._session.get(f'{self.url}/users?per_page={per_page}&page={page}&order_by={order_by}',
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
        r = self._session.get(f'{self.url}/users{user_url}', headers=self.headers, verify=self.verify)
        return r

    ####################################################################################################################
    #                                                Runners API                                                       #
    ####################################################################################################################
    @require_auth
    def get_runners(self, type=None, status=None, paused=None, tag_list=None, all_runners=False):
        runner_filter = None
        if all_runners:
            runner_filter = "/all"
        if type:
            if runner_filter:
                runner_filter = f'{runner_filter}&type={type}'
            else:
                runner_filter = f'?type={type}'
        if status:
            if runner_filter:
                runner_filter = f'{runner_filter}&status={status}'
            else:
                runner_filter = f'?status={status}'
        if paused:
            if runner_filter:
                runner_filter = f'{runner_filter}&paused={paused}'
            else:
                runner_filter = f'?paused={paused}'
        if tag_list:
            if runner_filter:
                runner_filter = f'{runner_filter}&tag_list={tag_list}'
            else:
                runner_filter = f'?tag_list={tag_list}'
        r = self._session.get(f'{self.url}/runners{runner_filter}', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_runner(self, runner_id=None):
        if runner_id is None:
            raise MissingParameterError
        r = self._session.get(f'{self.url}/runners/{runner_id}', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def update_runner_details(self, runner_id=None, data=None):
        if runner_id is None or data is None:
            raise MissingParameterError
        r = self._session.put(f'{self.url}/runners/{runner_id}', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def pause_runner(self, runner_id=None, data=None):
        if runner_id is None or data is None:
            raise MissingParameterError
        r = self._session.put(f'{self.url}/runners/{runner_id}', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def get_runner_jobs(self, runner_id=None):
        if runner_id is None:
            raise MissingParameterError
        r = self._session.put(f'{self.url}/runners/{runner_id}/jobs', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_project_runners(self, project_id=None, type=None, status=None, paused=None, tag_list=None, all_runners=False):
        if project_id is None:
            raise MissingParameterError
        runner_filter = None
        if all_runners:
            runner_filter = "/all"
        if type:
            if runner_filter:
                runner_filter = f'{runner_filter}&type={type}'
            else:
                runner_filter = f'?type={type}'
        if status:
            if runner_filter:
                runner_filter = f'{runner_filter}&status={status}'
            else:
                runner_filter = f'?status={status}'
        if paused:
            if runner_filter:
                runner_filter = f'{runner_filter}&paused={paused}'
            else:
                runner_filter = f'?paused={paused}'
        if tag_list:
            if runner_filter:
                runner_filter = f'{runner_filter}&tag_list={tag_list}'
            else:
                runner_filter = f'?tag_list={tag_list}'
        r = self._session.get(f'{self.url}/projects/{project_id}/runners{runner_filter}',
                              headers=self.headers, verify=self.verify)
        return r
    @require_auth
    def enable_project_runner(self, project_id=None, runner_id=None):
        if project_id is None or runner_id is None:
            raise MissingParameterError
        data = json.dumps({'runner_id': runner_id}, indent=4)
        r = self._session.put(f'{self.url}/projects/{project_id}/runners', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def delete_project_runner(self, project_id=None, runner_id=None):
        if project_id is None or runner_id is None:
            raise MissingParameterError
        r = self._session.delete(f'{self.url}/projects/{project_id}/runners/{runner_id}', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def get_group_runners(self, group_id=None, type=None, status=None, paused=None, tag_list=None, all_runners=False):
        if group_id is None:
            raise MissingParameterError
        runner_filter = None
        if all_runners:
            runner_filter = "/all"
        if type:
            if runner_filter:
                runner_filter = f'{runner_filter}&type={type}'
            else:
                runner_filter = f'?type={type}'
        if status:
            if runner_filter:
                runner_filter = f'{runner_filter}&status={status}'
            else:
                runner_filter = f'?status={status}'
        if paused:
            if runner_filter:
                runner_filter = f'{runner_filter}&paused={paused}'
            else:
                runner_filter = f'?paused={paused}'
        if tag_list:
            if runner_filter:
                runner_filter = f'{runner_filter}&tag_list={tag_list}'
            else:
                runner_filter = f'?tag_list={tag_list}'
        r = self._session.get(f'{self.url}/groups/{group_id}/runners{runner_filter}',
                              headers=self.headers, verify=self.verify)
        return r
    @require_auth
    def register_new_runner(self, token=None, description=None, info=None, paused=None, locked=None, run_untagged=None,
                            tag_list=None, access_level=None, maximum_timeout=None, maintenance_note=None):
        if token is None:
            raise MissingParameterError
        data = {}
        if description:
            data['description'] = description
        if info:
            data['info'] = info
        if paused:
            data['paused'] = paused
        if locked:
            data['locked'] = locked
        if run_untagged:
            data['run_untagged'] = run_untagged
        if tag_list:
            data['tag_list'] = tag_list
        if access_level:
            data['access_level'] = access_level
        if maximum_timeout:
            data['maximum_timeout'] = maximum_timeout
        if maintenance_note:
            data['maintenance_note'] = maintenance_note
        data = json.dumps(data, indent=4)
        r = self._session.put(f'{self.url}/runners', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def delete_runner(self, runner_id=None, token=None):
        if runner_id is None and token is None:
            raise MissingParameterError
        if runner_id:
            r = self._session.delete(f'{self.url}/runners/{runner_id}', headers=self.headers, verify=self.verify)
        else:
            data = {'token': token}
            data = json.dumps(data, indent=4)
            r = self._session.delete(f'{self.url}/runners', headers=self.headers, data=data,
                                     verify=self.verify)
        return r

    ####################################################################################################################
    #                                                Projects API                                                      #
    ####################################################################################################################
    @require_auth
    def get_projects(self, max_pages=0, per_page=100, order="updated"):
        r = self._session.get(f'{self.url}/projects?per_page={per_page}&x-total-pages',
                              headers=self.headers, verify=self.verify)
        total_pages = int(r.headers['X-Total-Pages'])
        r = []
        if order == "updated":
            order_by = "updated_at"
        else:
            order_by = "updated_at"
        if max_pages == 0 or max_pages > total_pages:
            max_pages = total_pages
        for page in range(0, max_pages):
            r_page = self._session.get(f'{self.url}/projects?per_page={per_page}&page={page}&order_by={order_by}',
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
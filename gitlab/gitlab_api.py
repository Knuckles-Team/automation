#!/usr/bin/python

import json
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
    def cherry_pick_commit(self, project_id=None, commit_hash=None, branch=None, dry_run=None, message=None):
        if project_id is None or commit_hash is None or branch is None:
            raise MissingParameterError
        data = {}
        if branch:
            if not isinstance(branch, str):
                raise ParameterError
            data['branch'] = branch
        if dry_run:
            if not isinstance(dry_run, bool):
                raise ParameterError
            data['dry_run'] = dry_run
        if message:
            if not isinstance(message, str):
                raise ParameterError
            data['message'] = message
        data = json.dumps(data, indent=4)
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits/{commit_hash}/cherry_pick',
                              headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def create_commit(self, project_id=None, branch=None, commit_message=None, start_branch=None, start_sha=None,
                      start_project=None, actions=None, author_email=None, author_name=None, stats=None, force=None):
        if project_id is None or branch is None or commit_message is None or actions is None:
            raise MissingParameterError
        data = {}
        if branch:
            if not isinstance(branch, str):
                raise ParameterError
            data['branch'] = branch
        if commit_message:
            if not isinstance(commit_message, str):
                raise ParameterError
            data['commit_message'] = commit_message
        if start_branch:
            if not isinstance(start_branch, str):
                raise ParameterError
            data['start_branch'] = start_branch
        if start_sha:
            if not isinstance(start_sha, str):
                raise ParameterError
            data['start_sha'] = start_sha
        if start_project:
            if not isinstance(start_project, str) and not isinstance(start_project, int):
                raise ParameterError
            data['start_project'] = start_project
        if actions:
            if not isinstance(actions, list):
                raise ParameterError
            data['actions'] = actions
        if author_email:
            if not isinstance(author_email, str):
                raise ParameterError
            data['author_email'] = author_email
        if author_name:
            if not isinstance(author_name, str):
                raise ParameterError
            data['author_name'] = author_name
        if stats:
            if not isinstance(stats, bool):
                raise ParameterError
            data['stats'] = stats
        if force:
            if not isinstance(force, bool):
                raise ParameterError
            data['force'] = force
        data = json.dumps(data, indent=4)
        r = self._session.post(f'{self.url}/projects/{project_id}/repository/commits',
                               headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def revert_commit(self, project_id=None, commit_hash=None, branch=None, dry_run=None):
        if project_id is None or commit_hash is None or branch is None:
            raise MissingParameterError
        data = {}
        if branch:
            if not isinstance(branch, str):
                raise ParameterError
            data['branch'] = branch
        if dry_run:
            if not isinstance(dry_run, bool):
                raise ParameterError
            data['dry_run'] = dry_run
        data = json.dumps(data, indent=4)
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
    def create_commit_comment(self, project_id=None, commit_hash=None, note=None, path=None, line=None, line_type=None):
        if project_id is None or commit_hash is None or note is None:
            raise MissingParameterError
        data = {}
        if note:
            if not isinstance(note, str):
                raise ParameterError
            data['note'] = note
        if path:
            if not isinstance(path, str):
                raise ParameterError
            data['path'] = path
        if line:
            if not isinstance(line, int):
                raise ParameterError
            data['line'] = line
        if line_type:
            if line_type != "new" or line_type != "old":
                raise ParameterError
            else:
                data['line_type'] = line_type
        data = json.dumps(data, indent=4)
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
    def post_build_status_to_commit(self, project_id=None, commit_hash=None, state=None, reference=None, name=None,
                                    context=None, target_url=None, description=None, coverage=None, pipeline_id=None):
        if project_id is None or commit_hash is None or state is None:
            raise MissingParameterError
        data = {}
        if state:
            if state not in ["pending", "running", "success", "failed", "canceled"]:
                raise ParameterError
            else:
                data['state'] = state
        if reference:
            if not isinstance(reference, str):
                raise ParameterError
            data['ref'] = reference
        if name:
            if not isinstance(name, str):
                raise ParameterError
            data['name'] = name
        if context:
            if not isinstance(context, str):
                raise ParameterError
            data['context'] = context
        if target_url:
            if not isinstance(target_url, str):
                raise ParameterError
            data['target_url'] = target_url
        if description:
            if not isinstance(description, str):
                raise ParameterError
            data['description'] = description
        if coverage:
            if not isinstance(coverage, float):
                raise ParameterError
            data['coverage'] = coverage
        if pipeline_id:
            if not isinstance(pipeline_id, int):
                raise ParameterError
            data['pipeline_id'] = pipeline_id
        data = json.dumps(data, indent=4)
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
    def create_project_deploy_token(self, project_id=None, name=None, expires_at=None, username=None, scopes=None):
        if project_id is None or name is None or scopes is None:
            raise MissingParameterError
        data = {}
        if name:
            if not isinstance(name, str):
                raise ParameterError
            data['name'] = name
        if expires_at:
            if not isinstance(expires_at, str):
                raise ParameterError
            data['expires_at'] = expires_at
        if username:
            if not isinstance(username, str):
                raise ParameterError
            data['username'] = username
        if scopes:
            if scopes not in ["read_repository", "read_registry", "write_registry", "read_package_registry",
                              "write_package_registry"]:
                raise ParameterError
            else:
                data['scopes'] = scopes
        data = json.dumps(data, indent=4)
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
    def create_group_deploy_token(self, group_id=None, name=None, expires_at=None, username=None, scopes=None):
        if group_id is None or name is None or scopes is None:
            raise MissingParameterError
        data = {}
        if name:
            if not isinstance(name, str):
                raise ParameterError
            data['name'] = name
        if expires_at:
            if not isinstance(expires_at, str):
                raise ParameterError
            data['expires_at'] = expires_at
        if username:
            if not isinstance(username, str):
                raise ParameterError
            data['username'] = username
        if scopes:
            if scopes not in ["read_repository", "read_registry", "write_registry", "read_package_registry",
                              "write_package_registry"]:
                raise ParameterError
            else:
                data['scopes'] = scopes
        data = json.dumps(data, indent=4)
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
            if type not in ['instance_type', 'group_type', 'project_type']:
                raise ParameterError
            if runner_filter:
                runner_filter = f'{runner_filter}&type={type}'
            else:
                runner_filter = f'?type={type}'
        if status:
            if status not in ['online', 'offline', 'stale', 'never_contacted', 'active', 'paused']:
                raise ParameterError
            if runner_filter:
                runner_filter = f'{runner_filter}&status={status}'
            else:
                runner_filter = f'?status={status}'
        if paused:
            if not isinstance(paused, str):
                raise ParameterError
            if runner_filter:
                runner_filter = f'{runner_filter}&paused={paused}'
            else:
                runner_filter = f'?paused={paused}'
        if tag_list:
            if not isinstance(tag_list, list):
                raise ParameterError
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
    def update_runner_details(self, runner_id=None, description=None, active=None, paused=None, tag_list=None,
                              run_untagged=None, locked=None, access_level=None, maximum_timeout=None):
        if runner_id is None:
            raise MissingParameterError
        data = {}
        if description:
            if not isinstance(active, str):
                raise ParameterError
            data['description'] = description
        if active:
            if not isinstance(active, bool):
                raise ParameterError
            data['active'] = active
        if paused:
            if not isinstance(paused, bool):
                raise ParameterError
            data['paused'] = paused
        if tag_list:
            if not isinstance(tag_list, list):
                raise ParameterError
            data['tag_list'] = tag_list
        if run_untagged:
            if not isinstance(run_untagged, bool):
                raise ParameterError
            data['run_untagged'] = run_untagged
        if locked:
            if not isinstance(locked, bool):
                raise ParameterError
            data['locked'] = locked
        if access_level:
            if access_level not in ['not_protected', 'ref_protected']:
                raise ParameterError
            data['access_level'] = access_level
        if maximum_timeout:
            if not isinstance(maximum_timeout, int):
                raise ParameterError
            data['maximum_timeout'] = maximum_timeout
        data = json.dumps(data, indent=4)
        r = self._session.put(f'{self.url}/runners/{runner_id}', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def pause_runner(self, runner_id=None, active=None):
        if runner_id is None or active is None:
            raise MissingParameterError
        data = {'active': active}
        data = json.dumps(data, indent=4)
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

    @require_auth
    def verify_runner_authentication(self, token=None):
        if token is None:
            raise MissingParameterError
        data = {'token': token}
        data = json.dumps(data, indent=4)
        r = self._session.post(f'{self.url}/runners/verify', headers=self.headers, data=data, verify=self.verify)
        return r

    @require_auth
    def reset_gitlab_runner_token(self):
        r = self._session.post(f'{self.url}/runners/reset_registration_token', headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def reset_project_runner_token(self, project_id):
        if project_id is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/projects/{project_id}/runners/reset_registration_token',
                               headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def reset_group_runner_token(self, group_id):
        if group_id is None:
            raise MissingParameterError
        r = self._session.post(f'{self.url}/groups/{group_id}/runners/reset_registration_token',
                               headers=self.headers, verify=self.verify)
        return r

    @require_auth
    def reset_token(self, runner_id, token=None):
        if runner_id is None or token is None:
            raise MissingParameterError
        data = {'token': token}
        data = json.dumps(data, indent=4)
        r = self._session.post(f'{self.url}/runners/{runner_id}/reset_authentication_token',
                               headers=self.headers, data=data, verify=self.verify)
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

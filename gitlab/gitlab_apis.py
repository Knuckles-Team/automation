MERGE RULES
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


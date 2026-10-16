# P8-T1 PR-head CI run (issue #927)

Timestamp: 2026-10-16T13-29
Command: gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state open --json number,headRefOid
EXIT_CODE: 0
Output Summary: One open pull request (#961) whose headRefOid equals the branch head f82da3681f059f437573bf3b773f9a72a77b592b. The newest ci.yml run with event pull_request and headSha equal to that head is 38905372728 (completed, success).

Note: each `gh` command was run with `--repo drmoisan/drm-copilot` added; the result set is otherwise identical to the plan command.

## Command 1 output

`[{"headRefOid":"f82da3681f059f437573bf3b773f9a72a77b592b","number":961}]`

## Command 2

Command 2: git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927
EXIT_CODE_2: 0
BRANCH_HEAD: f82da3681f059f437573bf3b773f9a72a77b592b

## Command 3

Command 3: gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --json databaseId,event,status,conclusion,headSha --limit 10
EXIT_CODE_3: 0

| databaseId | event | status | conclusion | headSha |
|---|---|---|---|---|
| 38905372728 | pull_request | completed | success | f82da3681f059f437573bf3b773f9a72a77b592b |
| 38900960142 | workflow_dispatch | completed | success | 8259a11df659283c4c78c443be99a02ca7698098 |
| 38890377723 | workflow_dispatch | completed | success | 7b43fddd540dcb5243f0b888891c35d315d6c454 |
| 38876469175 | workflow_dispatch | completed | success | 7966e1564635b5e4f60c22eeac47932018ae264a |
| 38855083321 | workflow_dispatch | completed | success | 620a2e966129dd4b68e8aed9b6397c33bb0080ff |

PR_NUMBER: 961
PR_HEAD_REF_OID: f82da3681f059f437573bf3b773f9a72a77b592b
PR_HEAD_EQUALS_BRANCH_HEAD: true
HEAD_CI_RUN_ID: 38905372728
CI_STATUS: COMPLETED success

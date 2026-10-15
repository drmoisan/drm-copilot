# CI fail-first run (P1-T9) [expect-fail]

Timestamp: 2026-10-09T07-04 (T1 = 2026-10-09T07:01:5xZ, before dispatch)
Command: gh workflow run _shell-coverage.yml --ref bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 ; gh run list --workflow=_shell-coverage.yml --branch=bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 --limit=5 --json databaseId,headSha,url,createdAt,event ; gh run watch 37896730789 ; gh run view 37896730789 --json status,conclusion,headSha,url
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: workflow run completed with conclusion failure on head 36795b64b4daf8e84d3d6e8e8a1fb8e239a395ed (TEST_SHA). The mapped workflow outcome is 1 (failure), as expected before the fix.

GH_EXIT_CODE: 0 (gh workflow run)
GH_EXIT_CODE: 0 (gh run list)
GH_EXIT_CODE: 0 (gh run watch, no --exit-status)
GH_EXIT_CODE: 0 (gh run view)

FAILFIRST_RUN_ID: 37896730789
URL: https://github.com/drmoisan/drm-copilot/actions/runs/37896730789
headSha: 36795b64b4daf8e84d3d6e8e8a1fb8e239a395ed (equals TEST_SHA)
status: completed
conclusion: failure
event: workflow_dispatch (createdAt 2026-10-09T07:02:07Z)

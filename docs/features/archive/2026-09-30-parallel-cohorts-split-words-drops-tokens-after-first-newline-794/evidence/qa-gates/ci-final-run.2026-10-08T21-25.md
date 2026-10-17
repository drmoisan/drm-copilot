# CI final run (P4-T7)

Timestamp: 2026-10-09T07-20 (T2 = 2026-10-09T07:12:06Z)
Command: gh workflow run _shell-coverage.yml --ref bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 ; gh run list --workflow=_shell-coverage.yml --branch=bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 --limit=5 --json databaseId,headSha,url,createdAt,event ; gh run watch 37897674234 ; gh run view 37897674234 --json status,conclusion,headSha,url
EXIT_CODE: 0
Output Summary: run completed with conclusion success on head 5cbd8485e1b7397d63500d0a4f194b2176fc31f7 (equals FINAL_SHA).

FINAL_RUN_ID: 37897674234
URL: https://github.com/drmoisan/drm-copilot/actions/runs/37897674234
headSha: 5cbd8485e1b7397d63500d0a4f194b2176fc31f7
status: completed
conclusion: success
event: workflow_dispatch (createdAt 2026-10-09T07:12:10Z)

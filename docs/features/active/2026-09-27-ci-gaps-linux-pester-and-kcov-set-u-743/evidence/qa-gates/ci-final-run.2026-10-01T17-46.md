# Final Verification Run Dispatch (P7-T16)

Timestamp: 2026-10-01T17-46
Dispatch time (UTC): 2026-10-01T17:46:41Z

Command: gh workflow run ci.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: run https://github.com/drmoisan/drm-copilot/actions/runs/36901896617

Command: gh run list --workflow=ci.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: databaseId 36901896617, createdAt 2026-10-01T17:46:45Z (after dispatch time), headSha ecba8829604f6265dc491c74cf42546f9d5aab57 (equals CI_SHA), status queued.

RUN_ID: 36901896617
CI_SHA: ecba8829604f6265dc491c74cf42546f9d5aab57

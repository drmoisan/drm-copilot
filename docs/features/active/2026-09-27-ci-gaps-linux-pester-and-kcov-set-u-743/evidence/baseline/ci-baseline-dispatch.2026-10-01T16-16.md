# CI Baseline Dispatch (P0-T22)

Timestamp: 2026-10-01T16-16

Command: git push -u origin bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: `Everything up-to-date`; upstream tracking set. No force.

Command: git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: `7282fb31153adb4d3449e5653d64c6b50e09de75`, equal to the P0-T1 HEAD SHA.

Dispatch time (UTC): 2026-10-01T16:16:39Z

Command: gh workflow run _shell-coverage.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: run https://github.com/drmoisan/drm-copilot/actions/runs/36890790108

Command: gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: run https://github.com/drmoisan/drm-copilot/actions/runs/36890793420

Command: gh run list --workflow=_shell-coverage.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: databaseId 36890790108, createdAt 2026-10-01T16:16:49Z (after dispatch time), headSha 7282fb31153adb4d3449e5653d64c6b50e09de75, status in_progress.

Command: gh run list --workflow=_poshqc.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: databaseId 36890793420, createdAt 2026-10-01T16:16:51Z (after dispatch time), headSha 7282fb31153adb4d3449e5653d64c6b50e09de75, status queued.

Background watches started: `gh run watch 36890790108` and `gh run watch 36890793420`.

SHELL_COVERAGE_BASELINE_RUN_ID: 36890790108
POSHQC_BASELINE_RUN_ID: 36890793420

# CI Dispatch on the Branch Head (AC-25, branch part)

Timestamp: 2026-11-14T14-40
Command: gh workflow run ci.yml --repo drmoisan/drm-copilot --ref bug/parallel-close-records-pr-routing-receipt; gh run view 43606114877 --repo drmoisan/drm-copilot --json status,conclusion,headSha,jobs
EXIT_CODE: 0
Output Summary:
- Run identifier: 43606114877 (workflow CI, event workflow_dispatch), created 2026-11-14T14:40:47Z, completed 2026-11-14T15:07:04Z.
- Head the run used: 58ea02d60f294cef2d8861c700707d941a871547, equal to the local HEAD of bug/parallel-close-records-pr-routing-receipt when the run was dispatched and when it completed.
- Run conclusion: success. All 23 jobs completed with conclusion success.
- Required conclusions:
  - poshqc / PowerShell QC: success
  - poshqc / PowerShell hook suites (Linux): success (runs tests/scripts/claude-hooks, including the four new suites, on ubuntu-latest)
  - CI Required Gate: success
- Other jobs: Change scope, CI full run, docs-validation, build-check, shell-coverage, security-scan, quality-checks7 (3.11, 3.12, 3.13), poshqc / PowerShell QC static, poshqc / PowerShell QC shard 1/2/3, drm-copilot-extension-tests (ubuntu-latest, windows-latest), root-typescript-tests (ubuntu-latest, windows-latest), and NPM Audit Gate (three manifests): all success.
- AC-25 note: this run is on the branch head through workflow_dispatch. No pull request exists yet, so the "CI on the PR head" part of AC-25 stays unchecked as pending-CI until the orchestrator opens the pull request and its CI passes.

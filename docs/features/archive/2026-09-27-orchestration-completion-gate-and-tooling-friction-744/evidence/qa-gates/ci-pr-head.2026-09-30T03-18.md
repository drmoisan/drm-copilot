# CI Result on the PR Head (Post-CI Step 1)

Timestamp: 2026-10-02T03-11
Command: gh pr checks 817 --json name,state,bucket
EXIT_CODE: 0
Companion command (run first): gh pr view 817 --json headRefOid,state -> {"headRefOid":"5c4eb1a28e1ffc2e6e2ff5570fe4c738b83648cd","state":"OPEN"}
Output Summary:
- PR #817 (https://github.com/drmoisan/drm-copilot/pull/817), state OPEN, headRefOid 5c4eb1a28e1ffc2e6e2ff5570fe4c738b83648cd.
- CI workflow run: https://github.com/drmoisan/drm-copilot/actions/runs/36976529109 on that head.
- 20 checks, all bucket `pass` / state `SUCCESS`; 0 fail, 0 pending.
- `Code Quality & Tests` matrix: 3.10, 3.11, 3.12, 3.13 all pass (this job runs the full pytest suite, including `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, on a fresh checkout; authoritative for AC-16 per issue #510).
- `poshqc / PowerShell QC` pass (job https://github.com/drmoisan/drm-copilot/actions/runs/36976529109/job/110741455338); `poshqc / PowerShell hook suites (Linux)` pass. This is the evidence accepted under plan deviation D-PESTER-CI for the Pester suites.
- Other checks passing: build-check, docs-validation, drm-copilot Extension Tests (ubuntu, windows), Extension Tests (ubuntu, windows), Root TypeScript Tests (ubuntu, windows), security-scan, shell-coverage, NPM Audit Gate (., extensions/drm-copilot, packages/mcp-server), Publish to Marketplace.
- headRefOid equals ci_gate.head_sha recorded in the orchestrator checkpoint for this S9 pass.

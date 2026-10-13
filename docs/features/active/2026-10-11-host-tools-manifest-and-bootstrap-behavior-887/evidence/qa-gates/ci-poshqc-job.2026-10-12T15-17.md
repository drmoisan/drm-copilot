# CI PowerShell QC Job Evidence (P2-T10, AC-16)

Timestamp: 2026-10-12T15-17
Supplied-By: parallel-orchestrator (performed by item orchestrator under delegation)
Command: gh run view (performed by the orchestrator; gh is not in the atomic-executor allowlist); executor comparison: git rev-parse HEAD
EXIT_CODE: 0

## Supplied data (precondition (b))

- Workflow: CI (event pull_request), PR #919
- Run id: 38294481892
- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38294481892
- headSha: 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8
- Run status: completed (run conclusion success)
- Job whose name ends with `PowerShell QC`: `poshqc / PowerShell QC`
- Job conclusion: success

## Executor comparison

- P2-T9 HEAD: 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8
- `git rev-parse HEAD` at P2-T10: 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8
- `git rev-parse origin/bug/host-tools-manifest-and-bootstrap-behavior-887`: 59fa06a04f8b75dcf9dc43466f8758f2345bd2c8
- headSha equals P2-T9 HEAD: yes

## Output Summary:

PASS. The supplied headSha matches the P2-T9 head commit, the PR CI run status is completed, and the `poshqc / PowerShell QC` job concluded success. The CI job is the authoritative format, analyze, and test gate for AC-16. Downloaded artifact `poshqc-test-results` is present under SCRATCH/887/ci-pr-887 (powershell-coverage.xml, pester-junit.xml, powershell-coverage.koverage.xml), verified with the Glob tool.

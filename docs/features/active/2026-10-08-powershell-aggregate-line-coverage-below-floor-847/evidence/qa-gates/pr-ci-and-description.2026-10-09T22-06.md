# PR description and CI evidence (AC-14, AC-15)

Timestamp: 2026-10-09T22-06
Command: gh pr checks 871; gh pr view 871 --json headRefOid,statusCheckRollup (orchestrator-observed); file reads of artifacts/pr_body_847.md and docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md (executor-verified)
EXIT_CODE: 0
Output Summary:
- AC-14 (executor-verified by file read): `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md` exists and describes the missing `scripts/host-tools.manifest.json` (read by `bootstrap-host.ps1` via `HostBootstrap.psm1` and by `verify-host.ps1` via `HostVerification.psm1`) and the missing `scripts/bash/bootstrap-host.sh` named in the bootstrap non-Windows message. The PR #871 body file `artifacts/pr_body_847.md` references that entry under `## Follow-ups` (line 77).
- AC-15 (orchestrator-observed CI evidence; the executor cannot call gh): PR #871 head `3b2a33a15b2409c3ebf2915d2b27db9a417ae66c` (matches local branch HEAD, verified with `git rev-parse HEAD`). CI run 38014970447, job "poshqc / PowerShell QC" (job 114103106988) conclusion pass. All 17 checks in the PR statusCheckRollup pass.
- Result: AC-14 PASS, AC-15 PASS.

## Sources

- PR: https://github.com/drmoisan/drm-copilot/pull/871
- CI run: https://github.com/drmoisan/drm-copilot/actions/runs/38014970447

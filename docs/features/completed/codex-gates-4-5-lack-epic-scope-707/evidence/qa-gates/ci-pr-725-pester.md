# AC-16 CI Pester evidence (PR #725)

Timestamp: 2026-09-27T12-20
Command: gh run view 36317849720 --job 108615836563 --log
EXIT_CODE: 0
Output Summary: PR #725 head b7aff51dcab5becebe2a1f4a35dcda055139d4d0; job `poshqc / PowerShell QC` concluded SUCCESS; `Tests Passed: 5416, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`; all 19 PR checks concluded SUCCESS.

## Run identity

- Pull request: https://github.com/drmoisan/drm-copilot/pull/725
- Head SHA: b7aff51dcab5becebe2a1f4a35dcda055139d4d0 (branch rebased onto origin/main 736a5007)
- Workflow run: https://github.com/drmoisan/drm-copilot/actions/runs/36317849720
- Job: https://github.com/drmoisan/drm-copilot/actions/runs/36317849720/job/108615836563

## Suites named by AC-15 (new) and AC-14 (D10-modified)

Each container line below is reported by Pester with the `[+]` (passed) marker in the job log.

| Suite | CI result |
| --- | --- |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed |
| tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed |

## Checkpoint independence

`artifacts/` is gitignored, so the CI checkout contains no `artifacts/orchestration/*.json` file. The suites therefore passed with those checkpoints absent, and the local runs in `final-pester-coverage.md` passed with local checkpoint files present. Both states produced passing results.

## Runner discrepancy (recorded, not waived)

AC-16 describes the repository CI Pester run as running on a "Linux runner". The repository's only CI Pester run is the reusable workflow `.github/workflows/_poshqc.yml`, whose `poshqc` job declares `runs-on: windows-latest`; the job log paths begin `D:\a\`. No Linux Pester job exists in the repository CI. The operative requirement of AC-16 (the named suites pass in the repository CI Pester run on the pull request, independent of `artifacts/orchestration/*.json`) is verified above. The Linux portability of the suites is supported by the local hermeticity scan in `p5-hermeticity-scan.md` (no temp paths, no Windows-only paths, no `origin/main` ref, synthetic `/synthetic-worktrees/` roots) but was not executed on a Linux host. This discrepancy is recorded as a follow-up in `evidence/other/follow-ups.md`. Per the coordinator ruling of 2026-09-27, AC-16's runner wording was amended to "(windows-latest, the repository's only CI Pester job)" and recorded as spec decision D18.

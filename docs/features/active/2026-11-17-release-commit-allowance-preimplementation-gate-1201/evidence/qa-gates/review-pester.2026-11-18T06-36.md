# Reviewer PowerShell Gate Run (post-merge re-audit)

- Timestamp: 2026-11-18T06-36
- Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (item worktree, head `03174b419f79a68bddc359382b6933532eb8af74`; `Invoke-PoshQCParallelTest`, 8 workers)
- EXIT_CODE: 0
- Output Summary: started 2026-11-18T06:34:53Z, finished 2026-11-18T06:47:39Z, wall-clock 765.09 s; all 8 shards exited 0. Merged JUnit `artifacts/pester/pester-junit.xml`: 28216 tests, 0 failures, 0 errors. Merged coverage `artifacts/pester/powershell-coverage.xml`: 45487 of 47337 lines covered (96.09%). Branch files: `hook-release-allowance-context.ps1` 171/171 and `enforce-orchestration-preimplementation-gate-release.ps1` 32/32 in each surface copy; Claude gate 171/177; Codex gate 182/182. Files merged from `main` (#1204): `NpmAuditGate.psm1` 161/161, `Invoke-NpmAuditGate.ps1` 50/55.
- Reason for the run: the merge commit `03174b419` brings `*.ps1`/`*.psm1` files from `main`, so the 03-46 report (written 2026-11-18T03:43Z) predates the newest commit touching PowerShell files.

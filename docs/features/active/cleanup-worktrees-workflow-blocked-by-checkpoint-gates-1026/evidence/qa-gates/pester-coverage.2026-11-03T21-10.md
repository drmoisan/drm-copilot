# Final QA — Pester with Coverage (Fresh Single Process), Loop Pass 2

Timestamp: 2026-11-03T21-10
Command: sh SCRATCH/issue-1026-fullrun.sh final2 (fresh single-process PowerShell 7 on the Linux Codespace: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <item worktree> -ScanFolders tests/scripts)
EXIT_CODE: 255

## Loop history

- Pass 1 (2026-11-03T20-40, label `final`): 13910 tests, 13491 passed, 409 failed, 10 skipped. `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` was at 96.88% (62/64), below its 98.08% baseline. The uncovered new line was the defensive `catch` around the `Get-PrAuthorCleanupPublishedHead` call in K6. The P2-T3 test `denies a consolidation create when origin/documentationandmemories is missing with CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` gained a throwing-seam case that asserts the same sub-code, and the loop restarted at P5-T1 (`qa-gates/format.2026-11-03T20-44.md`, `qa-gates/pssa.2026-11-03T20-44.md`: unchanged, 0 findings).
- Pass 2 (this artifact): results below.

## Counts

- `artifacts/pester/pester-junit.xml` `testsuites` element: tests=13910, failures=409, errors=6, disabled=10.
- Pester console: Tests Passed: 13491, Failed: 409, Skipped: 10; Tests completed in 1019.39s; Covered 91.99% of 35,638 analyzed commands in 265 files.
- Exit 255 has the same cause as the baseline: Pester's JUnit export throws on a failure message from `activate.Tests.ps1`. Per-suite attribution comes from the console stack traces.

## Failing suites compared with the baseline

The per-suite failure counts (`SCRATCH/issue-1026-consolefail.ps1`) are identical to `remediation-baseline/pester-coverage.2026-11-03T19-56.md`:

- Inside `HOST_FAILURE_SUITES`: 89 failure lines in the same 17 suites with the same per-suite counts (89 is at most 89).
- Outside `HOST_FAILURE_SUITES`: the same 8 suites as the baseline (Resolve-CodexRouting.Parity, codex-bundle-hook-probe, codex-pretooluse-integration, codex-pretooluse-transport, epic-execution-gates, legacy-codex-hook-contracts, codex-detached-head-transport, enforce-parallel-drift-gate-helpers). All 8 are victims of the pre-existing PATH leak in `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (test `Add-DirectoryToPath handles paths with trailing separator`). Without the leaker in one process they pass 356 of 356, and none of them is in the cycle's diff. `legacy-codex-hook-contracts.Tests.ps1` also passed in the P1-T7 run (964/964).

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

Total: baseline 92.57% -> post-change 92.58% (21551 covered, 1728 missed).

| File | Baseline (P0-T5) | Post-change | Delta | >= 85% | Not below baseline |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.27% (155/161) | 96.27% (155/161) | 0.00 | yes | yes |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 95.32% (163/171) | 95.32% (163/171) | 0.00 | yes | yes |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 97.89% (139/142) | 98.06% (152/155) | +0.17 | yes | yes |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 90.14% (128/142) | 90.32% (140/155) | +0.18 | yes | yes |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 98.08% (51/52) | 98.44% (63/64) | +0.36 | yes | yes |

Output Summary: 13910 tests; 13491 passed, 409 failed, 10 skipped; total line coverage 92.58% (baseline 92.57%). All five changed files are at or above 85% and at or above their baselines. Failures are identical per suite to the baseline. Acceptance partly unmet: 89 failures inside HOST_FAILURE_SUITES (limit met), but 8 failing suites outside the set. All 8 are pre-existing PATH-leak victims outside this diff and fail identically at CYCLE_BASE. Re-running the loop cannot change them, so the task stays unchecked and is escalated.

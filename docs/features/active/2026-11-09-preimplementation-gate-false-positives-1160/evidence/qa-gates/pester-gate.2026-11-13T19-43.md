# Pester Gate (post-merge verification)

Timestamp: 2026-11-13T19-28
Command: sh SCRATCH/issue-1160-r4-gate.sh m1 (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode), then sh SCRATCH/issue-1160-r4-summary.sh (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml); then sh SCRATCH/issue-1160-leak-scan.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree>)
EXIT_CODE: 0
Output Summary: one Invoke-PoshQCParallelTest run with coverage on the merge head `ef082f4fa` (origin/main `eb73f1dff` merged into the cycle 2 head `0613920d6`), 8 workers, wall clock 864.85 s, 2026-11-13T19-28 to 2026-11-13T19-42, PARALLEL_EXIT=0. Merged JUnit (written 2026-11-13T19-42, so produced by this run): 22952 tests, 0 failures, 0 errors, 10 skipped (22942 passed). Repo-wide line coverage 95.86% (38934/40614) against cycle 2 95.86% (38163/39812): no drop. Gate files and sibling copies unchanged against cycle 2 (table below). Leak scan: `Leak scan: 771 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.`, LEAK_EXIT=0.

## Coverage against cycle 2

Cycle 2 figures are from `evidence/qa-gates/coverage-comparison.2026-11-13T19-19.md`.

| File | Cycle 2 | Post-merge | Threshold | Result |
|---|---|---|---|---|
| Repo-wide | 95.86% (38163/39812) | 95.86% (38934/40614) | >= 95.80% (Phase 0) | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 96.43% (162/168) | 96.43% (162/168) | >= 85% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 100.00% (178/178) | 100.00% (178/178) | >= 85% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 98.96% (95/96) | 98.96% (95/96) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 98.96% (95/96) | 98.96% (95/96) | >= 90% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |

The one missed line in each commands sibling is the same pre-existing `continue` of the Opaque NoPayload branch recorded in cycle 2. The bundle copies under `extensions/drm-copilot/resources/` are outside the coverage population and share SHA-256 `e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4` with both measured copies. The merge changed none of the four gate or commands files (`git diff --stat 0613920d6 ef082f4fa` over those paths is empty).

## Named rows and cases (merged JUnit)

| Selection | Test cases | Failed |
|---|---|---|
| `existing-denial row ED-` | 200 | 0 |
| `false-positive row FP-` | 68 | 0 |
| `non-goal row NG-` | 18 | 0 |
| `decision D16` | 40 | 0 |
| `decision D2 groups` | 2 | 0 |
| `decision D2 executing-option` | 2 | 0 |

The test count rose from 22305 to 22952 with the suites that origin/main brought in (#1157 owner-directive pass-down hooks, #1164 parallel-planner edge rule); none fails in combination with this item's files.

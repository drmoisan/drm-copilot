# Pester Coverage Gate at the Merged Head (remediation [P2-T4])

Timestamp: 2026-11-07T17-58
Command: sh SCRATCH/issue-1037-pester-parallel.sh remfinal (PowerShell 7; imports `scripts/powershell/PoshQC/PoshQC.psd1`, runs one `Invoke-PoshQCParallelTest -Root <worktree>`, exits with the returned `ExitCode`; counts from the merged `artifacts/pester/pester-junit.xml`, line coverage from the merged `artifacts/pester/powershell-coverage.xml`); sh SCRATCH/issue-1037-r-its.sh (per-suite and per-`It` counts from the same merged JUnit file)
EXIT_CODE: 0
Output Summary: ExitCode 0, 8 workers, wall clock 586.38 s, every shard exit 0; merged JUnit and coverage files written 17:57 UTC by this run at the merged head (merge of the integration tip plus the [P1-T3] commit). Total 18859, passed 18849, failed 0, skipped 10 (merged JUnit; the eight shard JUnit files give the same counts). Overall line coverage 95.40% (33835 covered, 1630 missed). Per-file line coverage: `.claude/hooks/docs-role-contract.ps1` 100.00% (79/79), `.claude/hooks/validate-docs-role-output.ps1` 100.00% (29/29), `.claude/hooks/enforce-docs-role-write-scope.ps1` 100.00% (68/68).

Owner directive 2026-11-07: parallel test gates only

## Named suites and tests

| Suite or test | Tests | Failed | Skipped |
|---|---|---|---|
| `docs-authoring-roles.Mirrors.Tests.ps1` (agent, skill, template and hook bundle pairs, 64 pairs) | 25 | 0 | 0 |
| `docs-authoring-roles.Registration.Tests.ps1` (settings pair, three routing copies, manifests) | 19 | 0 | 0 |
| `docs-authoring-roles.Skills.Tests.ps1` | 130 | 0 | 0 |
| `It` `keeps the three routing copies byte-identical` | 1 | 0 | 0 |
| `It` `contains the nine required dispatch rows and six defined docs tools` | 1 | 0 | 0 |
| `It` `reads nine dispatch rows and six defined docs tools` (replaced in [P1-T3]) | 0 | - | - |

## Comparison with the Pester baseline (`evidence/baseline/pester-coverage.2026-11-07T16-10.md`)

| Measure | Baseline | Merged head | Change |
|---|---|---|---|
| Total tests | 17177 | 18859 | +1682 (the feature's suites plus the suites brought in by the integration tip) |
| Failed | 0 | 0 | none |
| Skipped | 10 | 10 | none |
| Overall line coverage | 95.30% | 95.40% | +0.10 points |

Failure names absent from the baseline: none (the run has no failure). Acceptance: `ExitCode` 0, zero failed tests, each of the three hooks at least 85% line coverage (100% each), the Mirrors and Registration suites report zero failures, and the renamed dispatch-row `It` passes. No single-process, shuffle or reversed-order run was made.

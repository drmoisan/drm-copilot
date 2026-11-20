# Pester Coverage Gate (P7-T3)

Timestamp: 2026-11-07T17-06
Command: sh SCRATCH/issue-1037-pester-parallel.sh final (imports `scripts/powershell/PoshQC/PoshQC.psd1`, runs `Invoke-PoshQCParallelTest -Root <worktree>`, reads `ExitCode`; counts from the merged `artifacts/pester/pester-junit.xml`, line coverage from the merged `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary: ExitCode 0, 8 workers, wall clock 784.76 s, every shard exit 0, merged files written 17:06 UTC at head 654d45809 (after the [P7-T2] fixes). Total 17710, passed 17700, failed 0, skipped 10. Overall line coverage 95.32% (32964 covered, 1617 missed). Per-file line coverage: `.claude/hooks/docs-role-contract.ps1` 100.00% (79/79), `.claude/hooks/validate-docs-role-output.ps1` 100.00% (29/29), `.claude/hooks/enforce-docs-role-write-scope.ps1` 100.00% (68/68).

Owner directive 2026-11-07: parallel test gates only

## Comparison with the [P0-T5] baseline (`evidence/baseline/pester-coverage.2026-11-07T16-10.md`)

| Measure | Baseline | Final | Change |
|---|---|---|---|
| Total tests | 17177 | 17710 | +533 (new suites: 80 + 60 + 55 + 299, plus new guard rows for the two hooks) |
| Passed | 17167 | 17700 | +533 |
| Failed | 0 | 0 | none |
| Skipped | 10 | 10 | none |
| Overall line coverage | 95.30% (32788 / 34405) | 95.32% (32964 / 34581) | +0.02 points; missed lines unchanged at 1617 |

Acceptance: zero failed tests (the baseline listed no pre-existing failure, so there is no failure to exempt); each new hook file at least 85% (all three at 100%); overall line coverage not below the baseline; `config/poshqc-coverage.json` is unchanged on the branch and lists coverage roots only, with no exclusion, so no production file is excluded.

The task text names a fresh single-process `Invoke-PoshQCTest` run; under the owner directive the gate is this one `Invoke-PoshQCParallelTest` run with coverage.

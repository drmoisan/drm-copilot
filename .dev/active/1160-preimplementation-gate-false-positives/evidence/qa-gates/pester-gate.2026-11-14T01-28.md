# Final Pester Gate (cycle 3, [P3-T2])

Timestamp: 2026-11-14T01-28
Command: sh SCRATCH/issue-1160-r4-gate.sh c3p3 (one Invoke-PoshQCParallelTest run with coverage on the branch-current scripts/powershell/PoshQC/PoshQC.psd1); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by sh SCRATCH/issue-1160-r4-summary.sh and sh SCRATCH/issue-1160-c3r3-modelled-count.sh
EXIT_CODE: 0
Output Summary: 8 workers, wall clock 636.24 s, run 2026-11-14T01-18 to 2026-11-14T01-28, PARALLEL_EXIT=0. Merged JUnit written 2026-11-14T01-28 (produced by this run): 23215 tests, 0 failures, 0 errors, 10 skipped (23205 passed). Repo-wide line coverage 95.88% (39146/40828). Commands sibling `.claude/hooks` and `.codex/hooks` copies 99.01% (201/203) each.

## Named results

| Selection | Tests | Failed |
|---|---|---|
| `existing-denial row ED-` (ED-01 to ED-96, 2 tests x 2 runners) | 384 | 0 |
| of which ED-51 to ED-96 | 184 | 0 |
| `false-positive row FP-` (FP-01 to FP-17, 2 tests x 2 runners) | 68 | 0 |
| `non-goal row NG-` (NG-01 to NG-09, 1 test x 2 runners) | 18 | 0 |
| new suite `modelled-command rule (decision D17, issue #1160)`, Claude copy | 39 | 0 |
| new suite, Codex copy | 39 | 0 |
| `returns exactly the decision D2 executing-option exclusions` (both surfaces) | 2 | 0 |

ED-01 to ED-96, FP-01 to FP-17, and NG-01 to NG-09 pass in both classification runners, and the 39 cases of the new suite (36 classified cases and 3 guards) pass on both surfaces.

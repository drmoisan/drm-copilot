# Final Pester Gate ([P3-T2])

Timestamp: 2026-11-13T19-06
Command: sh SCRATCH/issue-1160-r4-gate.sh p3 (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode), then sh SCRATCH/issue-1160-r4-summary.sh (reads artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: one Invoke-PoshQCParallelTest run with coverage on head `38ac34e95a5d330c25effc19292ee642c35e7547` (tracked source identical to the [P2-T3] run), 8 workers, wall clock 765.76 s, 2026-11-13T19-06 to 2026-11-13T19-19. Merged JUnit (written 2026-11-13T19-19): 22305 tests, 0 failures, 0 errors, 10 skipped (22295 passed). Repo-wide line coverage 95.86% (38163/39812).

## Named rows and cases (merged JUnit)

| Selection | Test cases | Failed |
|---|---|---|
| `existing-denial row ED-01` to `ED-50` (classify and deny, Claude and Codex runners) | 200 | 0 |
| `false-positive row FP-01` to `FP-17` (classify and allow, both runners) | 68 | 0 |
| `non-goal row NG-01` to `NG-09` (both runners) | 18 | 0 |
| `decision D16` contexts: fifteen confirm cases and five guard cases, Claude and Codex surfaces | 40 | 0 |
| `returns exactly the decision D2 groups` (both surfaces) | 2 | 0 |
| `returns exactly the decision D2 executing-option exclusions` (both surfaces) | 2 | 0 |

ED-01 to ED-50, FP-01 to FP-17, and NG-01 to NG-09 pass in both runners; the two updated pins, the fifteen confirm cases, and the five guard cases of [P1-T3] pass on both surfaces.

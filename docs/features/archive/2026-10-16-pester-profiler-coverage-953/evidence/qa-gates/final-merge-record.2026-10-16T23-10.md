# Final merge record (#953, PR #959)

Timestamp: 2026-10-16T23-10
Recorded by: coordinator session 0f6aac23-6ea2-4759-9a9b-c826039d3306

## Final reviewed head

- Head: `5c4f4878d9ab90788d77b244d4135ef9432c4c14`, `fix(953): reject negative shard weights and weigh line-ending-normalized text`.
- CI run 38973602160 on that head: conclusion `success`. All 24 checks pass, and the run took 15 minutes.
- The commit that follows this record only merges `origin/main` and adds documentation. The operator merges PR #959 without waiting for a CI rerun on that commit (operator decision, 2026-10-16).

## PowerShell CI timings, run 38973602160

| Job | Job seconds | Test step seconds |
|---|---|---|
| poshqc / PowerShell QC static | 178 | n/a |
| poshqc / PowerShell QC shard 1 | 804 | 773 |
| poshqc / PowerShell QC shard 2 | 395 | 364 |
| poshqc / PowerShell QC shard 3 | 262 | 229 |
| poshqc / PowerShell QC (aggregator) | 62 | completeness check 35, coverage merge 2 |
| poshqc / PowerShell hook suites (Linux) | 435 | 417 |

- Baseline (run 38846579572): the single PowerShell QC job took 18.6 minutes, of which the `Test PowerShell` step took 15.5 minutes.
- Shard 1 is the longest shard. Its time is mostly `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (about 504 seconds on CI). The performance fix for that suite is assigned to the #935 follow-on pass.

## Acceptance-criteria status at merge

| Criterion | Status |
|---|---|
| AC-10 | Satisfied. The step and job seconds for the final head are recorded above, from `gh run view 38973602160 --json jobs`. |
| AC-11 | Satisfied. `T` exceeded 480 on the unsharded head (sharding-trigger evidence), and the sharding phase was executed. The final-head shard step seconds are recorded above. |
| AC-08, AC-09, AC-12 | Not verified against the final-head CI artifacts before merge. The final-head run is green and the local final QA records are under `evidence/qa-gates/r3-final-*`. The operator accepted the merge without this artifact comparison. |

## Order independence (operator ruling of 2026-10-16)

- Cycle 3 fixed the observed shard-order dependence on the victim side (`32229dbd1`, CR-21).
- The final-QA alone sweep is clean: 388 of 388 files pass, `FAILED_ALONE_COUNT=0` (`r3-final-alone-sweep.2026-10-16T22-59.md`).
- The seeded-shuffle sweep (AC-OI-1 to AC-OI-5: shuffled runs with recorded seeds, leaker-side and victim-side fixes for every dependency, and a seeded-shuffle CI step) was **not performed** in this PR. It remains required by the operator ruling. It carries forward to the #935 follow-on pass, which owns the same EpicStateIsolation suites, and to #964.

# Final QC: Pester (advisory-fix plan, P2-T2)

Timestamp: 2026-11-19T13-38
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest, 8 workers, integration and golden lanes excluded); counts from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (read with SCRATCH/issue-1050-pester-read.cjs)
EXIT_CODE: 0
Output Summary: 29242 tests, 0 failures, 0 errors, 18 skipped; Invoke-PoshQCParallelTest exit code 0, wall-clock 830.37s, first attempt (no queue timeout). Repo-wide line coverage 96.77% (47244 covered, 1576 missed) against the Phase 0 baseline 96.77% (47184/48759) and the prior final 96.77% (47235/48811): no drop. `scripts/ci/Set-CiRequiredChecks.ps1` 98.36% (60/61) against the 85% threshold and the prior final 98.08% (51/52): no drop.

## Comparison

| Measure | Phase 0 baseline (`baseline-pester.2026-11-19T08-55.md`) | Prior final (`final-pester.2026-11-19T11-46.md`) | This run |
| --- | --- | --- | --- |
| Tests | 29212 | 29237 | 29242 |
| Failures / errors | 0 / 0 | 0 / 0 | 0 / 0 |
| Repo-wide line | 96.77% (47184/48759) | 96.77% (47235/48811) | 96.77% (47244/48820) |
| `scripts/ci/Set-CiRequiredChecks.ps1` line | file did not exist | 98.08% (51/52) | 98.36% (60/61) |

- No new failing test against the baseline (0 failures in every run).
- The five added tests are the delta from 29237 to 29242.
- The one missed line of `Set-CiRequiredChecks.ps1` is the `-DataFilePath` default-value expression in the script `param` block, which a dot-source does not evaluate; it was also the missed line in the prior final run. Every new branch (paging, standard-error split, three failure messages, non-JSON list) is executed by a named test.

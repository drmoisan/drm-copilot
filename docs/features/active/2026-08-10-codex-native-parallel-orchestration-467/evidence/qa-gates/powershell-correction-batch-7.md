# PowerShell coverage correction batch 7

- Scope: one production owner and three existing focused test owners, within the 3+3 cap.
- Coverage-red attribution: the initial focused run passed 17/17 tests but measured the post-session owner at 148/175 lines. Existing injected command and persistence boundaries were sufficient, so no production change was required.
- Format: `run_poshqc_format` passed for all four owners.
- Analyze: `run_poshqc_analyze` passed with no findings.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 21/21 tests, with 0 failed and 0 skipped.

| Production owner | Full-suite pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/scripts/parallel-child-post-session.ps1` | 148/175 (84.5714%) | 159/175 (90.8571%) | +11 | PASS >=90% |

Production owner line count is 375. Test owner line counts are 122, 279, and 188; all scoped files remain below 500 lines.

# PowerShell coverage correction batch 6

- Scope: two production owners and three existing focused test owners, within the 3+3 cap.
- Coverage-red attribution: the initial focused run passed 47/47 tests but measured persistence at 20/98 and runtime at 59/110 lines. Persistence already exposed injectable I/O boundaries. Runtime startup constructed a concrete process, proving the need for one behavior-preserving `ProcessFactory` seam.
- Format: `run_poshqc_format` passed for all five owners.
- Analyze: `run_poshqc_analyze` passed with no findings.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 61/61 tests, with 0 failed and 0 skipped.
- Test owner sizes: attribution 400 lines, hardening 474 lines, and launcher 497 lines.

| Production owner | Full-suite pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/scripts/codex-child-launch-persistence.ps1` | 20/98 (20.4082%) | 91/98 (92.8571%) | +71 | PASS >=90% |
| `.codex/scripts/codex-child-launch-runtime.ps1` | 59/110 (53.6364%) | 105/111 (94.5946%) | +46 | PASS >=90% |

Production owner line counts are 256 and 248; all scoped files remain below 500 lines.

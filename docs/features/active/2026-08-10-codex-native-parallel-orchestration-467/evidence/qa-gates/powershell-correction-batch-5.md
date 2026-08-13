# PowerShell coverage correction batch 5

- Scope: two production owners and the existing attribution test owner, plus the existing focused resume owner used to preserve established reconciliation coverage.
- Coverage-red attribution: the initial focused combination passed 13/13 tests but measured the contract core at 7/147 and resume at 88/135 lines. The production files already exposed pure seams, so no production change was required.
- Format: `run_poshqc_format` passed for the two production owners and attribution owner.
- Analyze: `run_poshqc_analyze` passed with no findings after correcting two test-local automatic-variable names.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 21/21 tests, with 0 failed and 0 skipped.
- Test owner sizes: `powershell-attribution-batch-5.Tests.ps1` is 405 lines and `codex-child-launch-resume-core.Tests.ps1` is 203 lines.

| Production owner | Full-suite pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/scripts/codex-child-launch-contract-core.ps1` | 116/147 (78.9116%) | 141/147 (95.9184%) | +25 | PASS >=90% |
| `.codex/scripts/codex-child-launch-resume.ps1` | 88/135 (65.1852%) | 133/135 (98.5185%) | +45 | PASS >=90% |

Production owner line counts remain 351 and 461; all scoped files remain below 500 lines.

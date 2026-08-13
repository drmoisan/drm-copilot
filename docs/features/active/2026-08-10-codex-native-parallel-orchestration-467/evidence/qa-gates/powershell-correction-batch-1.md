# PowerShell coverage correction batch 1

- Scope: three production owners and one focused test owner.
- Format: `run_poshqc_format` passed for all four owners; the verification rerun was idempotent.
- Analyze: `run_poshqc_analyze` passed with no findings.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 20/20 tests, with 0 failed and 0 skipped.
- Test owner size: `tests/scripts/codex-hooks/powershell-attribution-batch-1.Tests.ps1` is 402 lines.

| Production owner | Pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/hooks/authorize-root-parallel-invocation.ps1` | 27/117 (23.0769%) | 116/126 (92.0635%) | +89 | PASS >=90% |
| `.codex/hooks/enforce-parallel-root-invocation.ps1` | 18/81 (22.2222%) | 76/83 (91.5663%) | +58 | PASS >=90% |
| `.codex/hooks/parallel-hook-common.ps1` | 16/51 (31.3725%) | 50/51 (98.0392%) | +34 | PASS >=90% |

Production owner line counts are 362, 266, and 220 respectively; all scoped files remain below 500 lines.

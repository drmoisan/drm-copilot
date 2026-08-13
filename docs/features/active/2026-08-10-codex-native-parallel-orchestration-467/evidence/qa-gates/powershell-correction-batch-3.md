# PowerShell coverage correction batch 3

- Scope: three production owners and one focused test owner.
- Coverage-red attribution: the first focused run passed 14/14 tests but left cohort and drift at 18/25 lines and agent output at 45/63 lines. All remaining misses were native entrypoint transport, proving the need for behavior-preserving injectable entrypoint seams.
- Format: `run_poshqc_format` passed for all four owners after the final correction.
- Analyze: `run_poshqc_analyze` passed with no findings after the helper verb was corrected from `New-*` to `ConvertTo-*`.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 19/19 tests, with 0 failed and 0 skipped.
- Test owner size: `tests/scripts/codex-hooks/powershell-attribution-batch-3.Tests.ps1` is 329 lines.

| Production owner | Pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/hooks/enforce-parallel-cohort-barrier.ps1` | 5/25 (20.0000%) | 26/28 (92.8571%) | +21 | PASS >=90% |
| `.codex/hooks/enforce-parallel-drift-gate.ps1` | 5/25 (20.0000%) | 26/28 (92.8571%) | +21 | PASS >=90% |
| `.codex/hooks/validate-parallel-agent-output.ps1` | 22/63 (34.9206%) | 72/76 (94.7368%) | +50 | PASS >=90% |

Production owner line counts are 143, 143, and 254 respectively; all scoped files remain below 500 lines.

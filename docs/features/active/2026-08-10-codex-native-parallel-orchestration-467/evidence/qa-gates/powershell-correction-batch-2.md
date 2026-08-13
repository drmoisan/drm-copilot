# PowerShell coverage correction batch 2

- Scope: three production owners and one focused test owner.
- Coverage-red attribution: the first targeted run passed 18/18 tests but left the owners at 19/26, 19/27, and 20/27 lines. The remaining native entrypoint lines could not be reached through safe dot-source testing, proving the need for behavior-preserving injectable entrypoint seams.
- Format: `run_poshqc_format` passed for all four owners; the final verification rerun was idempotent.
- Analyze: `run_poshqc_analyze` passed with no findings.
- Targeted test: `Invoke-PoshQCTest` with the repository Pester settings passed 25/25 tests, with 0 failed and 0 skipped.
- Test owner size: `tests/scripts/codex-hooks/powershell-attribution-batch-2.Tests.ps1` is 267 lines.

| Production owner | Pre-correction line coverage | Post-correction line coverage | Covered-line delta | Threshold |
| --- | ---: | ---: | ---: | ---: |
| `.codex/hooks/enforce-parallel-abandon-gate.ps1` | 6/26 (23.0769%) | 27/29 (93.1034%) | +21 | PASS >=90% |
| `.codex/hooks/enforce-parallel-child-worktree-binding.ps1` | 4/27 (14.8148%) | 27/30 (90.0000%) | +23 | PASS >=90% |
| `.codex/hooks/enforce-parallel-worktree-removal-gate.ps1` | 7/27 (25.9259%) | 27/30 (90.0000%) | +20 | PASS >=90% |

Production owner line counts are 134, 152, and 135 respectively; all scoped files remain below 500 lines.

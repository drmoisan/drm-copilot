# Test Isolation Checks (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-36
Command: sh SCRATCH/issue-1006-isolation.sh (node run-jest.cjs --randomize --seed=1006 in extensions/drm-copilot; then, one PowerShell 7 process per seed, SCRATCH/issue-1006-pester-files.ps1 -Seed <seed> over the five blast-radius suites under tests/scripts/claude-lib/blast-radius/, file order shuffled with System.Random(seed))
EXIT_CODE: 0
Output Summary: Jest seed 1006: 324 of 324 suites, 5257 of 5257 tests passed, 0 failures. Pester seeds 11, 23, 47: 172 of 172 passed for each seed, 0 failures.

## Seeded shuffled Jest run

- Seed: 1006
- Test Suites: 324 passed, 324 total
- Tests: 5257 passed, 5257 total
- EXIT_CODE: 0

## Seeded shuffled Pester file order (one process per seed)

Suites: `BlastRadius.TruthTable.Tests.ps1`, `BlastRadius.KeyPartition.Tests.ps1`, `BlastRadiusGenericContract.Tests.ps1`, `BlastRadiusExtraction.Path.Tests.ps1`, `BlastRadiusTokenShape.Tests.ps1`.

| Seed | File order | Result |
|---|---|---|
| 11 | BlastRadiusExtraction.Path, BlastRadiusTokenShape, BlastRadius.KeyPartition, BlastRadius.TruthTable, BlastRadiusGenericContract | 172 passed, 0 failed, EXIT_CODE 0 |
| 23 | BlastRadius.KeyPartition, BlastRadius.TruthTable, BlastRadiusTokenShape, BlastRadiusGenericContract, BlastRadiusExtraction.Path | 172 passed, 0 failed, EXIT_CODE 0 |
| 47 | BlastRadius.TruthTable, BlastRadiusExtraction.Path, BlastRadiusTokenShape, BlastRadiusGenericContract, BlastRadius.KeyPartition | 172 passed, 0 failed, EXIT_CODE 0 |

No order dependence was found, so no fix or re-run was needed. The reversed-order Python run is not applicable because this cycle changes no Python test module. The fresh single-process run over tests/scripts is recorded in qa-gates/pester-full.2026-10-31T09-35.md.

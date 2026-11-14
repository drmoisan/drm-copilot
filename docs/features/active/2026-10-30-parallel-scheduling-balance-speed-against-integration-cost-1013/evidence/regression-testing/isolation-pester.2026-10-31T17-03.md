# Isolation — Seeded Shuffled Pester File Order

Timestamp: 2026-10-31T17-03
Command: sh SCRATCH/issue-1013-pester-run.sh p9t11-s<seed> issue-1013-p9t11-tests.txt none <seed> for seeds 1013, 2026, and 31 (one PowerShell 7 process per seed; the file order is shuffled by System.Random seeded with the seed; counts from the JUnit file)
EXIT_CODE: 0
Output Summary: three seeds, each JUnit tests=204 failures=0 errors=0 skipped=0.

## Seed 1013

1. `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
2. `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1`
3. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`
4. `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1`
5. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`
6. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1`
7. `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`
8. `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`

Result: tests=204 failures=0.

## Seed 2026

1. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1`
2. `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`
3. `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
4. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`
5. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`
6. `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1`
7. `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`
8. `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1`

Result: tests=204 failures=0.

## Seed 31

1. `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1`
2. `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1`
3. `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`
4. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1`
5. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`
6. `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`
8. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`

Result: tests=204 failures=0.

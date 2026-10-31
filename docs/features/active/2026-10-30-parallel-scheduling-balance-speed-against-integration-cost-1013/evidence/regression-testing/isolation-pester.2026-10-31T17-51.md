# Pester shuffled file-order isolation (P3-T5)

Timestamp: 2026-10-31T17-51
Command: Invoke-Pester over the 26 suites in tests/scripts/claude-lib/blast-radius, file order shuffled with System.Random seeded 101, 202, 303, one process per seed (PowerShell 7 launched from a sh script under SCRATCH)
EXIT_CODE: 0
Output Summary: Each seed ran 755 tests with failures=0 errors=0 (JUnit), result Passed.

Seed 101 order: BlastRadiusConflict.PathOverlap, BlastRadiusScheduling.PairCost, BlastRadiusConflict.OverlappingPairs, BlastRadiusExtraction.Path, BlastRadius.TruthTable, BlastRadius.Manifest, BlastRadius, BlastRadiusNormalization, BlastRadiusScheduling, BlastRadiusExtraction, BlastRadiusConfig, BlastRadius.KeyPartition, BlastRadiusGlob.RegexCache, BlastRadiusGlob, BlastRadius.HistoricalRuns, BlastRadius.Validation, BlastRadiusWriteIntent, BlastRadius.Conflict, BlastRadiusAggregate, BlastRadiusTokenShape, BlastRadiusGenericContract, BlastRadiusScheduling.ContractWeight, BlastRadiusConflict, BlastRadiusCombination, BlastRadius.Parity, BlastRadius.Regression452

Seed 202 order: BlastRadius.Regression452, BlastRadius.HistoricalRuns, BlastRadiusCombination, BlastRadiusScheduling.PairCost, BlastRadiusGlob.RegexCache, BlastRadiusConfig, BlastRadiusExtraction.Path, BlastRadiusGenericContract, BlastRadius.Conflict, BlastRadiusConflict, BlastRadiusScheduling.ContractWeight, BlastRadius.Parity, BlastRadius, BlastRadiusWriteIntent, BlastRadiusTokenShape, BlastRadiusConflict.OverlappingPairs, BlastRadiusGlob, BlastRadiusConflict.PathOverlap, BlastRadiusScheduling, BlastRadiusNormalization, BlastRadius.Manifest, BlastRadiusAggregate, BlastRadiusExtraction, BlastRadius.TruthTable, BlastRadius.KeyPartition, BlastRadius.Validation

Seed 303 order: BlastRadiusAggregate, BlastRadius.Parity, BlastRadius.Conflict, BlastRadiusConfig, BlastRadiusConflict, BlastRadiusNormalization, BlastRadiusConflict.PathOverlap, BlastRadiusScheduling.ContractWeight, BlastRadiusScheduling.PairCost, BlastRadiusExtraction, BlastRadius.Manifest, BlastRadiusExtraction.Path, BlastRadius.Regression452, BlastRadiusTokenShape, BlastRadiusWriteIntent, BlastRadius.TruthTable, BlastRadius.Validation, BlastRadiusCombination, BlastRadius.KeyPartition, BlastRadiusGlob, BlastRadius, BlastRadius.HistoricalRuns, BlastRadiusGenericContract, BlastRadiusGlob.RegexCache, BlastRadiusScheduling, BlastRadiusConflict.OverlappingPairs

(Each name above is the file `<name>.Tests.ps1`.)

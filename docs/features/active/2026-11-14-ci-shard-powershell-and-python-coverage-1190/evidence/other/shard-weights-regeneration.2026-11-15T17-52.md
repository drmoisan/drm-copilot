# Shard weights regeneration (remediation cycle 1, P1-T1 to P1-T3)

Timestamp: 2026-11-15T17-52
Command: gh run download 43736520255 -p 'poshqc-test-results-shard-*' into SCRATCH/weights-input/ (six directories, one pester-junit.xml each, not committed); then sh SCRATCH/issue-1190-regenerate-weights.sh, which imports scripts/powershell/PoshQC/PoshQC.psd1 in PowerShell 7 and calls Export-PoshQCShardWeight -JunitPath <six files> -OutputPath config/poshqc-shard-weights.json, then projects shards with Select-PoshQCShardTestFile -ShardCount 6 over the 819 *.Tests.ps1 files under scripts, tests/powershell, and tests/scripts
EXIT_CODE: 0
Output Summary:
- Source run: CI run 43736520255 (the run recorded in evidence/other/ci-measurement.2026-11-15T17-20.md); six artifacts present and unexpired.
- New document: version 1, unit ms, 819 listed files (previous file listed 475), equal to the testsuite element count summed over the six JUnit files (819); keys are forward-slash relative paths in ordinal order; parses through ConvertFrom-PoshQCShardWeightJson without error; total 2767702 ms. File stored with LF endings.
- Projected per-shard sums over the 819 current test files, ShardCount 6, new weights (files, sum ms): shard 1 133 files 461255; shard 2 136 files 461254; shard 3 137 files 461307; shard 4 137 files 461294; shard 5 138 files 461286; shard 6 138 files 461306. Projected spread (largest/smallest) 1.000 (461307 / 461254).
- Same projection with the previous weights file read from HEAD (before regeneration), for reference: shard 1 1 file 188675; shards 2 to 6 163 to 164 files, 188420 to 188424 each; spread 1.001. The previous file measured balanced against its own units, and the six-shard CI run still spread 7.4 to 13.6 minutes, so the earlier data did not match real durations; the projection is not a prediction of wall-clock time.
- Finding: the projected spread is not larger than the old projected spread (both about 1.00). The projection balances only per-file Pester test time; per-shard fixed cost (module import, coverage instrumentation, artifact upload) is outside the weights, so the post-push CI run is the only proof of the wall-clock outcome.
- Files absent from the old data now carry measured weights; no listed file takes the median weight (819 of 819 current files are listed).

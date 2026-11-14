# PoshQC Configuration Check for the New Files (Issue #1074)

Timestamp: 2026-11-04T15-40
Task: [P3-T4]
Command: read config/poshqc-coverage.json, config/poshqc-scan.json, and config/poshqc-shard-weights.json; git diff MERGE_BASE -- config/
EXIT_CODE: 0
Output Summary:
- Finding 1: `config/poshqc-coverage.json` lists the root `scripts` in `roots`, so `scripts/ci/CiRequiredGate.psm1` and `scripts/ci/Invoke-CiRequiredGate.ps1` are in the CI coverage population without a configuration edit.
- Finding 2: `config/poshqc-scan.json` lists `tests/scripts` in `test.scanFolders`, so `tests/scripts/ci/CiRequiredGate.Tests.ps1`, `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`, and `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` are assigned to a shard automatically and counted by the shard completeness check.
- Finding 3: `config/poshqc-shard-weights.json` has no entry for the three new suites, and none is needed: an unlisted file is weighed by the median of the listed values (`SW02-UNLISTED-FILE-USES-MEDIAN` in `tests/scripts/powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1`).
- `git diff MERGE_BASE -- config/` printed nothing (0 bytes); no configuration file changed.

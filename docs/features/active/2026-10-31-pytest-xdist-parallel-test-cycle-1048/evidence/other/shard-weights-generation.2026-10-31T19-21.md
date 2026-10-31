# Shard weights generation (#1048, P7-T1)

Timestamp: 2026-10-31T19-21
Command: gh run download 41209645365 -n poshqc-test-results-shard-<i> -D SCRATCH/issue-1048-ci-junit/shard-<i> (i = 1, 2, 3); Export-PoshQCShardWeight -JunitPath SCRATCH/issue-1048-ci-junit/shard-<i>/pester-junit.xml (three files) -OutputPath config/poshqc-shard-weights.json (SCRATCH/issue-1048-weights.ps1)
EXIT_CODE: 0
Output Summary:
- Source run: 41209645365 (`ci.yml` on `main`, the P0-T5 baseline run, whose `CI full run` job succeeded); artifacts `poshqc-test-results-shard-1`, `-2`, and `-3`.
- Files listed in `config/poshqc-shard-weights.json`: 481, equal to the 481 `testsuite` elements in the three CI JUnit files. Sum of weights: 985111 ms.
- The document parses through `ConvertFrom-PoshQCShardWeightJson` without error (version 1, unit `ms`, non-negative integer values), and no key begins with `/` or contains `:` or `\` (0 such keys). The file is written with LF line endings.
- `PoshQC.ShardWeights.Tests.ps1` passes with the weights file present, as do `PoshQC.Shard.Tests.ps1` and `PoshQC.TestingShard.Tests.ps1` (30 passed, 0 failed).

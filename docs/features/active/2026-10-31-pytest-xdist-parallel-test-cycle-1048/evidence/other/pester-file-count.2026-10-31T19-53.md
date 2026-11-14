# Pester test-file count: 482 stated versus 436 local suites (#1048, P7-T7)

Timestamp: 2026-10-31T19-53
Command: SCRATCH/issue-1048-count.ps1 (default enumeration of *.Tests.ps1 under the scan folders of config/poshqc-scan.json with DefaultExcludedDirs applied, and testsuite counts of the P7-T3 JUnit files); git ls-files '*.Tests.ps1'
EXIT_CODE: 0
Output Summary:
- Default enumeration on the current tree: `scripts` 0 files, `tests/scripts` 485 files (`tests/powershell` is listed in `config/poshqc-scan.json` but does not exist), total 485.
- `testsuite` elements in the P7-T3 JUnit files: 485 in the serial run and 485 in the merged concurrent run.
- Tracked `*.Tests.ps1` files: 486. That is the 485 discoverable files plus `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, which sits outside the scan folders and is never run. Four of the 485 are the new suites of this item (`PoshQC.TestingOutputPath`, `PoshQC.ShardWeights`, `PoshQC.ParallelMerge`, `PoshQC.ParallelRunner`).

Explanation: before this item the repository tracked 482 `*.Tests.ps1` files, which is the issue's count. Of these, 481 were under the scan folders and one was the fixture under `tests/fixtures`. The P0-T3 baseline JUnit had exactly 481 `testsuite` elements, and the CI run 41209645365 shards together also had 481, so discovery and execution cover every scan-folder file. The 436 figure came from an older gitignored local JUnit file that predates about 45 test files added since, so it does not describe the current tree. The difference is therefore one fixture outside the scan folders plus a stale local artifact, not test files that discovery skips.

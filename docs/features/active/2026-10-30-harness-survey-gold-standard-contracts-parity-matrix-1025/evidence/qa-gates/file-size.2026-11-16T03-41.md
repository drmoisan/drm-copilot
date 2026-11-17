# File Size (P4-T5)

Timestamp: 2026-11-16T03-41
Command: read of the It `reports zero ratchet violations against config/file-size-baseline.json` (tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1) in the merged JUnit record of the P4-T2 run (SCRATCH/issue-1025-harness-files.ps1); wc -l on each added .psm1 and .Tests.ps1 (every file ends with one line terminator, so the count equals the logical line count)
EXIT_CODE: 0
Output Summary: the repository file-size It passed in the P4-T2 run. Every added code file is at or below 800 logical lines and the three unit-test files of P2-T2 to P2-T4 are at or below 700. One file is above the 500-line guidance tier: scripts/harness/HarnessInventory.psm1 (515), noted as guidance only; no file is at or above the 700-line advisory tier.

| File | Logical lines | Tier note |
| --- | --- | --- |
| scripts/harness/HarnessInventory.psm1 | 515 | above 500 (guidance); at or below 800 |
| scripts/harness/HarnessParityMatrix.psm1 | 255 | none |
| scripts/harness/HarnessSkillContract.psm1 | 147 | none |
| tests/scripts/harness/HarnessInventory.Tests.ps1 | 248 | at or below 700 |
| tests/scripts/harness/HarnessParityMatrix.Tests.ps1 | 302 | at or below 700 |
| tests/scripts/harness/HarnessSkillContract.Tests.ps1 | 146 | at or below 700 |
| tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 | 107 | none |

The added JSON and Markdown files are exempt from the file-size limit.

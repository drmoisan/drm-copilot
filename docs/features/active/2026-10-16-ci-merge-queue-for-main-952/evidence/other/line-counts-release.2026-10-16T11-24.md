# Line Counts: Release Flow (P5-T10)

Timestamp: 2026-10-16T11-24
Command: git grep -c -e "^" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1
EXIT_CODE: 0
Output Summary: five counts, each at or below 500; scripts/dev-tools/Invoke-FullReleaseFlow.ps1 = 446, equal to its projection of 446 (435 at P0-T7 plus 11)

Output (verbatim):
```
scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1:92
scripts/dev-tools/Invoke-FullReleaseFlow.ps1:446
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:100
tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1:252
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:439
```

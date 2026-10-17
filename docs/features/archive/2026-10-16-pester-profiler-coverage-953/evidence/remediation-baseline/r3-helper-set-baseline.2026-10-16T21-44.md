# r3 HELPER_SET Baseline, Pre-Fix Tree (P1-T6)

Timestamp: 2026-10-16T21-44
Command: (1) export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $root = (Get-Location).Path; [string[]] $set = @(Get-ChildItem -LiteralPath tests -Recurse -File -Filter *.Tests.ps1 | Where-Object { Select-String -LiteralPath $_.FullName -SimpleMatch -Pattern 'EpicStateIsolation.Baseline.Helpers.ps1' -Quiet } | ForEach-Object { [System.IO.Path]::GetRelativePath($root, $_.FullName) -replace '\\', '/' }); [System.Array]::Sort($set, [System.StringComparer]::Ordinal); Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-helper-set.txt') -Value $set -Encoding utf8; "HELPER_SET_COUNT=..."' (SCRATCH/issue-953-r3-p1-t6.sh); (2) RUN_SET(helper-set-before, issue-953-r3-helper-set.txt) in the background (SCRATCH/issue-953-r3-p1-t6-2.sh)
EXIT_CODE: 1
Output Summary:
- HELPER_SET_COUNT=110 CONTAINS_850=True HELPER_SET_SHA256=F8C3FC6887C5CA235FA43ABC3FE75BB8919A6D0379702B6A175F4DF80771EB1C
- RESULT={"files":110,"total":2805,"failed":1,"failedBlocks":0,"failedContainers":0,"watch":"Failed","watchMessage":"Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times","epicInstances":1,"runInstances":1,"staleRunInstance":"NO","failedTests":["issue #850 changed-file constraints.baseline mock interception probe"]}
- total=2805 failed=1 failedBlocks=0 failedContainers=0 watch=Failed
- Pre-fix state recorded: TARGET_SUITE also fails in the HELPER_SET order (it follows `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, the MINIMAL_SET file). The outcome does not gate this task.
- Result: PASS (HELPER_SET_COUNT >= 1, CONTAINS_850=True, exactly one RESULT= line).

R3_HELPER_SET_BASELINE_FAILED_TESTS: issue #850 changed-file constraints.baseline mock interception probe

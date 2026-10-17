# r3 PA-3 Reproduction, Fail-Before (P1-T4, expect-fail)

Timestamp: 2026-10-16T21-18
Command: (1) export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $m = Get-Content -Raw -LiteralPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') | ConvertFrom-Json; Set-Content -LiteralPath (Join-Path $S 'issue-953-r3-repro.txt') -Value @(@($m.selected)[0..40]) -Encoding utf8; "REPRO_FILES=..."' (SCRATCH/issue-953-r3-p1-t4.sh); (2) RUN_SET(repro-before, issue-953-r3-repro.txt): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; & (Join-Path $S 'issue-953-r3-run-set.ps1') -ListPath (Join-Path $S 'issue-953-r3-repro.txt') *> (Join-Path $S 'issue-953-r3-repro-before.log'); $code = $LASTEXITCODE; @(Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-repro-before.log') | Where-Object { $_.StartsWith('RESULT=') }); "EXIT_CODE=$code"; exit $code' (SCRATCH/issue-953-r3-p1-t4-2.sh)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- REPRO_FILES=41 (selected[0..40] of CI_MANIFEST, CI run 38936152953 shard 1)
- RESULT={"files":41,"total":1516,"failed":1,"failedBlocks":0,"failedContainers":0,"watch":"Failed","watchMessage":"Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times","epicInstances":1,"runInstances":1,"staleRunInstance":"YES","failedTests":["issue #850 changed-file constraints.baseline mock interception probe"]}
- total=1516 failed=1 failedBlocks=0 failedContainers=0
- watch=Failed
- watchMessage contains `Get-EpicScopeCheckpointText` and `but was called 0 times`
- staleRunInstance=YES
- failedTests: exactly WATCH_TEST
- Result: expected failure reproduced (exactly one RESULT= line; RUN_SET valid). The CI shard 1 failure reproduces on this host.

# r3 PA-3 Reproduction, Pass-After (P2-T3)

Timestamp: 2026-10-16T21-47
Command: RUN_SET(repro-after, issue-953-r3-repro.txt): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; & (Join-Path $S 'issue-953-r3-run-set.ps1') -ListPath (Join-Path $S 'issue-953-r3-repro.txt') *> (Join-Path $S 'issue-953-r3-repro-after.log'); $code = $LASTEXITCODE; @(Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-repro-after.log') | Where-Object { $_.StartsWith('RESULT=') }); "EXIT_CODE=$code"; exit $code' (SCRATCH/issue-953-r3-p2-t3.sh)
EXIT_CODE: 0
Output Summary:
- RESULT={"files":41,"total":1516,"failed":0,"failedBlocks":0,"failedContainers":0,"watch":"Passed","watchMessage":"","epicInstances":1,"runInstances":1,"staleRunInstance":"NO","failedTests":[]}
- total=1516 failed=0 failedBlocks=0 failedContainers=0 watch=Passed staleRunInstance=NO
- Fail-before total (latest r3-pa3-repro-fail-before.2026-10-16T21-18.md): 1516; equal.
- Result: PASS (the same 41-file CI shard 1 prefix that failed before the fix now passes).

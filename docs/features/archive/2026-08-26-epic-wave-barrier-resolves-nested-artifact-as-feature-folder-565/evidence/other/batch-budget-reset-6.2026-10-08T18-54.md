# Batch-Budget Reset 6 (QC remediation window: W07)

Timestamp: 2026-10-08T18-54
Command: $f = @(Get-ChildItem -LiteralPath .claude/state -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue); $f | ForEach-Object { 'REMOVED ' + $_.Name; Remove-Item -LiteralPath $_.FullName }; 'REMAINING ' + @(Get-ChildItem -LiteralPath .claude/state -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue).Count
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-RESET-6.ps1
EXIT_CODE: 0
Output Summary: REMAINING 0. Run per the standing rule before the iteration 2 remediation of W07: the trailing newline the P6-T2 Write had appended was removed, so the final `exit` line is byte-identical to the merge base and no longer a changed line. A test exercising the Get-FeatureFolderMissingFile -RequiredFile default was added to W30 (45 passed after the addition). The P6-T5 copy was re-run and printed MATCH.

```
REMAINING 0
```

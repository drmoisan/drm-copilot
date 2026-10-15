# Live-Hook Probe: enforce-feature-folder-order.ps1 After W07

Timestamp: 2026-10-08T19-08
Command: . ./.claude/hooks/enforce-feature-folder-order.ps1; $root = (Get-Location).Path -replace '\\', '/'; foreach ($rel in @('docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/plan.2026-10-08T13-52.md', 'docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md')) { $j = @{ tool_name = 'Edit'; tool_input = @{ file_path = ($root + '/' + $rel); old_string = 'a'; new_string = 'b' } } | ConvertTo-Json -Compress -Depth 5; 'PROBE ' + $rel + ' ' + (Invoke-FeatureFolderOrderDecision -ToolInputRaw $j).hookSpecificOutput.permissionDecision }
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P6-T3.ps1 (run immediately after the P6-T2 Write)
EXIT_CODE: 0
Output Summary: Both PROBE lines end in allow. This feature folder is full-bug with issue.md and spec.md present, so the now-gated timestamped plan file remains writable. No restore was needed.

```
PROBE docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/plan.2026-10-08T13-52.md allow
PROBE docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/spec.md allow
```

P6-T2 acceptance (same run window): the P5-T1 parse command against `.claude/hooks/enforce-feature-folder-order.ps1` printed `ParseErrors=0`, and `grep -c 'Get-FeatureFolderIssueContent'` printed 4.

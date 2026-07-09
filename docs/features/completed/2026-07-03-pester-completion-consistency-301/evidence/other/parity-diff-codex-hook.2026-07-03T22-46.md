# Parity Diff — `.codex/hooks/enforce-completion-consistency.ps1` vs `.claude/hooks/enforce-completion-consistency.ps1`

Timestamp: 2026-07-04T09-55

Command: `diff ".claude/hooks/enforce-completion-consistency.ps1" ".codex/hooks/enforce-completion-consistency.ps1"`

EXIT_CODE: 0 (diff reports no differences)

## Output Summary

No differences found. `.codex/hooks/enforce-completion-consistency.ps1` dot-sources `enforce-completion-helpers.ps1` via:

```
$script:CompletionHelpersPath = Join-Path $PSScriptRoot 'enforce-completion-helpers.ps1'
. $script:CompletionHelpersPath
```

and its `Invoke-CompletionConsistencyDecision` function returns the identical `hookSpecificOutput.permissionDecision` shape (`allow` / `deny` with `permissionDecisionReason`) as `.claude/hooks/enforce-completion-consistency.ps1`, because the two files are byte-for-byte identical. Expected result (no differences) confirmed; no edit is required for this file.

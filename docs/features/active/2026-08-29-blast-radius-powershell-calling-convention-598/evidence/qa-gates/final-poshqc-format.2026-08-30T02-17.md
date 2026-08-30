# Final PoshQC format pass — issue #598

Timestamp: 2026-08-30T02-17
Task: [P10-T1]

Command:
1. `mcp__drm-copilot__run_poshqc_format` against the workspace root
   `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path"`

Every recorded count and exit code below comes from command 2. Command 1 returned
`{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7'."}`
and carries no per-file output line and no exit code
(`extensions/drm-copilot/src/mcp-tools.ts:90-113`), so it is not the observation source.

EXIT_CODE: 0

Output Summary:

- Total output lines from command 2: 429
- Lines beginning `Formatted: `: 0
- Lines beginning `Already formatted: `: 429
- Lines matching neither prefix: 0

The counting filter used `-clike` rather than `-like`. PowerShell's `-like` is case-insensitive, so
the pattern `'Formatted: *'` also matches an `Already formatted: ` line and would have reported a
false rewrite count. The case-sensitive `-clike` form separates the two prefixes correctly.

The `[P0-T14]` post-merge baseline recorded 428 `Already formatted: ` lines. The final count is 429.
The increase of 1 is `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, the single
PowerShell file this feature created, authored by `[P8-T1]`. No other PowerShell file was added.

## Tree observation

`git status --porcelain` immediately BEFORE command 2:

```
 M docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-change-set-exclusion.2026-08-30T02-15.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-truthiness-verification.2026-08-30T02-14.md
```

`git status --porcelain` immediately AFTER command 2:

```
 M docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-change-set-exclusion.2026-08-30T02-15.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-truthiness-verification.2026-08-30T02-14.md
```

The two outputs are identical, line for line and in the same order. The three entries are the Phase 9
plan check-offs and the two Phase 9 evidence artifacts; none is a PowerShell source file. The
formatter therefore rewrote nothing, which is the tree observation that distinguishes a clean pass
from a repairing one. The exit code alone would not have distinguished them, because the formatter
exits 0 whether or not it rewrote files.

## Acceptance evaluation

- The `Formatted: ` count is `0`.
- The `Already formatted: ` count is `429`, which is greater than `0`.
- The porcelain output taken after the run is identical to the porcelain output taken immediately
  before it. Both are recorded above.

All three acceptance conditions hold. No restart of the `[P10-T1]` loop is required.

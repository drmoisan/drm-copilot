# PoshQC format baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T5]

Command:
1. `mcp__drm-copilot__run_poshqc_format` against the workspace root
   `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path"`

Every recorded count, path, and exit code below comes from command 2. Command 1 returned
`{"ok":true,"tool":"run_poshqc_format", ...}` and carries no per-file output line and no exit code
(`extensions/drm-copilot/src/mcp-tools.ts:90-113`), so it is not the observation source.

EXIT_CODE: 0

Output Summary:

- Total output lines from command 2: 422
- Lines beginning `Formatted: `: 0
- Lines beginning `Already formatted: `: 422
- Lines matching neither prefix: 0

PreExistingFormatterDrift: none

## Tree observation

`git status --porcelain` after command 2 reports the same two entries it reported at `[P0-T2]`:
the modified plan file and the untracked feature `evidence/` folder, both produced by this Phase 0
execution. No PowerShell source file was rewritten by the formatter, which is the observation that
distinguishes a clean formatter pass from a repairing one.

## Acceptance evaluation

- Both counts are recorded as integers: `Formatted: ` is 0, `Already formatted: ` is 422.
- The `Already formatted: ` count is greater than zero.
- `PreExistingFormatterDrift:` is present and holds `none`, consistent with a `Formatted: ` count of
  0. Tasks `[P9-T2]` and `[P10-T10]` read this field; it is complete and not truncated.

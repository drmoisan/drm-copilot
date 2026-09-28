# Post-merge PoshQC format baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T14]

Command:
1. `mcp__drm-copilot__run_poshqc_format` against the workspace root
   `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path"`

Every recorded count, path, and exit code below comes from command 2. Command 1 returned
`{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7","summary":"Ran bundled PoshQC format against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7'."}`
and carries no per-file output line and no exit code
(`extensions/drm-copilot/src/mcp-tools.ts:90-113`), so it is not the observation source.

EXIT_CODE: 0

Output Summary:

- Total output lines from command 2: 428
- Lines beginning `Formatted: `: 0
- Lines beginning `Already formatted: `: 428
- Lines matching neither prefix: 0

The pre-merge run recorded by `[P0-T5]` produced 422 `Already formatted: ` lines. The post-merge
count is 428; the increase of 6 is accounted for by the PowerShell files the merge added, which
include `.claude/lib/requirements/GeneratedDocumentCounters.psm1`, its bundle mirror, the three
merged hook scripts and their mirrors, and the merged test files.

PostMergeFormatterDrift: none

CombinedPreExistingFormatterDrift: none

`CombinedPreExistingFormatterDrift:` is the de-duplicated union of `PreExistingFormatterDrift:` from
`[P0-T5]` (`evidence/baseline/poshqc-format.2026-08-29T20-30.md:24`, value `none`) and
`PostMergeFormatterDrift:` recorded here (value `none`). Both source lists are `none`, so the union
is `none`. `[P9-T2]` and `[P10-T10]` read this combined field; it is complete and not truncated.

## Tree observation

`git status --porcelain` immediately after command 2 reports four entries, all produced by this
Phase 0 re-baseline execution:

```
 M docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/baseline/git-postmerge-baseline.2026-08-29T23-10.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/baseline/module-inventory-postmerge.2026-08-29T23-10.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/baseline/pytest-bundle-parity-postmerge.2026-08-29T23-10.md
```

No PowerShell source file was rewritten by the formatter, which is the tree observation that
distinguishes a clean formatter pass from a repairing one. The exit code alone would not have
distinguished them, because the formatter exits 0 whether or not it rewrote files.

## Effect on the `[P0-T12]` re-run condition

`PostMergeFormatterDrift:` is `none`, so it contains no path under `.claude/` and no path under
`extensions/drm-copilot/resources/claude-customizations/`. The `[P0-T12]` re-run condition therefore
does not fire, and `evidence/baseline/pytest-bundle-parity-postmerge.2026-08-29T23-10.md` remains
the recorded source of `PostMergeParityExitCode:`.

## Acceptance evaluation

- Both counts are recorded as integers: `Formatted: ` is `0`, `Already formatted: ` is `428`.
- The `Already formatted: ` count is greater than zero.
- `PostMergeFormatterDrift:` is present and holds `none`, consistent with a `Formatted: ` count of
  `0`.
- `CombinedPreExistingFormatterDrift:` is present and holds `none`, because both source lists are
  `none`.

All four acceptance conditions hold.

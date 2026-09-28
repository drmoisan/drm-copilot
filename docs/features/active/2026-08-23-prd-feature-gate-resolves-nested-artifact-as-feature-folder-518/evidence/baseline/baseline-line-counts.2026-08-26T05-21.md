# Pre-Change Line Counts — [P0-T2]

Timestamp: 2026-08-26T05-21

Task: [P0-T2]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: unmodified working tree at branch head
`bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518`.

Command:

```text
pwsh -NoProfile -Command "@('.claude/hooks/enforce-prd-feature-before-planner.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1','tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1') | ForEach-Object { '{0} = {1}' -f $_, (Get-Content -LiteralPath $_ | Measure-Object -Line).Lines }"
```

EXIT_CODE: 0

## Measured Line Counts

| File | Pre-change line count |
| --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 305 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 305 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 360 |

Output Summary: The command exited 0 and reported three numeric line counts. The self-hosted hook
`.claude/hooks/enforce-prd-feature-before-planner.ps1` is 305 lines. Its bundled mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
is also 305 lines, so the two copies are the same length before any change. The existing Pester test
file `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` is 360 lines. All
three files are below the 500-line limit set by `.claude/rules/general-code-change.md`.

## Input to the [P1-T1] Placement Decision

The plan's "Named regression cases" section declares 25 new `It` blocks. The existing test file is
360 lines, leaving 139 lines of headroom before the 500-line limit is reached (500 minus 360 equals
140; the limit is "may not exceed 500", so 500 is the highest permitted count and 140 lines could be
added at most).

139 lines of headroom across 25 new `It` blocks is 5.56 lines per block. The `It` blocks in the
existing file average well above that: the seven pre-existing blocks the plan enumerates with line
ranges span 8, 14, 13, 9, 16, 18, and 8 lines respectively, a mean of 12.3 lines per block. The new
cases are not structurally smaller than those; several require mocked
`Get-PrdFeatureIssueContent`, `Get-PrdFeatureFileExistence`, and `Get-PrdFeatureCheckpointFolder`
setup plus an in-line `ConvertTo-Json` envelope, which is at or above the existing average.

At the observed mean of 12.3 lines per block, 25 new blocks add approximately 308 lines, giving a
projected total of approximately 668 lines. Even at a conservative 8 lines per block the addition is
200 lines and the projected total is 560 lines. Both projections exceed 500.

Measured conclusion for [P1-T1]: the existing test file plus the 25 new `It` blocks WOULD reach or
exceed 500 lines. Under the [P1-T1] rule this directs the new cases into the companion file
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`. This
artifact records the measurement only; the decision itself is executed and recorded by [P1-T1].

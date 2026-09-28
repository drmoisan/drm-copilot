# Unbound-Target Composition Holds Across the Existing Decision-Level Cases

Timestamp: 2026-09-17T11-31

Command: `Import-Module Pester -MinimumVersion 5.0.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1','tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'); $cfg.Run.PassThru = $true; $cfg.Should.ErrorAction = 'Stop'; Invoke-Pester -Configuration $cfg`, then grouping the returned tests by their containing `Context`. Run from the worktree root through the scratchpad wrapper `sh runps.sh contexts.ps1`.

EXIT_CODE: 0

Output Summary — the four `Context` blocks this task names, all passing:

| `Context` | total | passed | failed |
| --- | --- | --- | --- |
| `decision equivalence and the reproduction differential` | 3 | 3 | 0 |
| `preserved gate behavior` | 5 | 5 | 0 |
| `indeterminate work-mode marker` | 6 | 6 | 0 |
| `block message` | 2 | 2 | 0 |

Every other `Context` in both suites also passes; the two files report 0 failures in total.

The three cases whose existence mock keys with `-eq` on a bare repo-relative path (`...FolderResolution.Tests.ps1`, the keyed mocks inside `decision equivalence and the reproduction differential`) pass unchanged. Their passing is the binding evidence for preamble ruling 8: none of them binds a resolved target, so the composition must emit the bare repo-relative spelling for them, and an implementation that prefixed unconditionally would fail all three at once.

Both files are unmodified apart from:

- the `BeforeAll` edit made by `[P1-T5]` (both files),
- the case `[P4-T13]` re-specifies in `enforce-prd-feature-before-planner.Tests.ps1`,
- the three cases `[P4-T14]` and `[P4-T15]` re-specify in `...FolderResolution.Tests.ps1`.

None of those edits lies inside the four `Context` blocks named above.

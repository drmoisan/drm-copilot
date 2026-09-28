# `Find-PrdFeatureFolderFromPrompt` Return Spelling Is Unchanged

Timestamp: 2026-09-17T11-32

Command: `Import-Module Pester -MinimumVersion 5.0.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1','tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'); $cfg.Run.PassThru = $true; $cfg.Should.ErrorAction = 'Stop'; Invoke-Pester -Configuration $cfg`, then reading each named case's result from the returned test list. Run from the worktree root through the scratchpad wrapper `sh runps.sh contexts.ps1`.

EXIT_CODE: 0

Output Summary — seven named cases, each observed individually, all **Passed**:

`Context 'Find-PrdFeatureFolderFromPrompt'` in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (4 of 4 passing):

1. `returns $null for empty prompt` — Passed
2. `returns $null when no docs/features/active path is present` — Passed
3. `returns the folder when one is present` — Passed. This case asserts `Should -Be 'docs/features/active/abc-1'`, an exact equality that fails the moment normalisation prefixes a root.
4. `strips .md suffix to a folder parent` — Passed. The same exact-equality form.

The three path-capture cases in the same file (3 of 3 passing):

5. `blocks when no feature folder is found in prompt and no checkpoint exists` — Passed
6. `prefers the prompt-derived folder over the checkpoint folder` — Passed, including its `Should -Not -Match 'checkpoint-folder'` discriminator
7. `Get-PrdFeatureCheckpointFolder returns $null when checkpoint is absent` — Passed

Both `[P4-T7]` and `[P4-T8]` modify `Find-PrdFeatureFolderFromPrompt`. This region is the second set of exact-equality pins on that function, covered by no other task: `[P4-T7]`'s own acceptance covers only the equivalent region in the FolderResolution suite. The function's return remains a bare repo-relative path for a single-candidate prompt, exactly as before, and returns `$null` for an unresolved multi-candidate tie so the caller can deny with the ambiguity code.

The file is unmodified apart from the `BeforeAll` edit made by `[P1-T5]` and the single case `[P4-T13]` re-specifies, neither of which lies in the seven cases above.

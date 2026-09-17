# Cross-File Mock Resolution Smoke Case

Timestamp: 2026-09-17T10-55

Command: `Import-Module Pester -MinimumVersion 5.0.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'; $cfg.Should.ErrorAction = 'Stop'; Invoke-Pester -Configuration $cfg`, run from the worktree root through the scratchpad wrapper `sh runps.sh onefile.ps1 -Path <suite>`.

EXIT_CODE: 0

Output Summary:

- `It` exercised: `observes a test-scope mock across the dot-source boundary`, in the `Context` named `cross-file mock resolution smoke`.
- Result: **passed**. `Tests Passed: 1, Failed: 0, Skipped: 0`.
- The case dot-sources both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` explicitly, registers `Mock -CommandName Get-PrdFeatureCheckpointFolder` (a function that remains in the parent), calls `Find-PrdFeatureFolderFromPrompt` (now declared in the sibling) with a single-candidate prompt, asserts the returned folder equals `docs/features/active/2026-09-13-smoke-1`, and asserts `Should -Invoke -CommandName Get-PrdFeatureCheckpointFolder -Times 0 -Exactly`.
- Halt gate not triggered: the case passes, so Pester resolves a test-scope mock of a parent-declared function from a function declared in the dot-sourced sibling. The assumption recorded as spec risk R4 holds, and the remaining functions may be moved in Phase 1.

## `[P0-T12]` `param(` match line text

`Select-String -SimpleMatch -Pattern 'param('` over `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` returns exactly **one** match:

- line 40: `    param(`

The matched line begins with whitespace (four spaces), which is the required qualifying property: it is the moved advanced function's own indented parameter block, not a file-scope declaration. A zero-match assertion would be invalid, because every advanced function in the moved code declares one.

Companion `[P0-T12]` observations recorded here:

- `Select-String -SimpleMatch -Pattern '#Requires'` over the sibling: 0 matches. Controls: `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` 2 matches (lines 1, 2) and `...FolderResolution.Tests.ps1` 2 matches (lines 1, 2).
- `Select-String -SimpleMatch -Pattern 'exit 0'` over the sibling: 0 matches. Control: the parent hook, 1 match at line 358 (line 448 before the extraction shortened the file).
- The sibling declares exactly one function, at line 18 (`function Find-PrdFeatureFolderFromPrompt`). A `-SimpleMatch` search for the token `function ` returns 2, the second being prose inside the verbatim-moved comment-based help at line 34 ("The function reads no file except through the existing checkpoint seam"), which is not a declaration.
- The parent no longer declares `Find-PrdFeatureFolderFromPrompt`: `Select-String -SimpleMatch -Pattern 'function Find-PrdFeatureFolderFromPrompt'` over the parent returns 0 matches.
- The parent's dot-source line `. (Join-Path $PSScriptRoot 'enforce-prd-feature-before-planner-helpers.ps1')` is present once, at line 79, immediately after the `Import-Module` line at line 78 and before the first function declaration.

# Blanket-Mock Guard for the Target-Resolution Matrix

Timestamp: 2026-09-17T11-33

Command:
- `Select-String -SimpleMatch -Pattern '-MockWith { $true }' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1'`
- `Select-String -SimpleMatch -Pattern '-MockWith { $true }' -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1'` (the control)

Both run from the worktree root through the scratchpad wrapper `sh runps.sh p4verify.ps1`. `-SimpleMatch` is mandatory here: without it `$` is a regex end-of-line anchor and `{` opens a quantifier, so the search would match nothing on any file content, including one carrying a blanket mock, and the assertion could not fail.

EXIT_CODE: 0

Output Summary:

- New suite (`...TargetResolution.Tests.ps1`): **0** matches. No row uses a blanket always-true existence mock.
- Control (`...FolderResolution.Tests.ps1`): **4** matches, at lines 327, 340, 353, and 366. The control is non-zero, so the zero result above is evidence of absence rather than of an unmatchable search.

Every existence mock in the new suite compares against a fully composed path. The forms used are `{ $Path -eq "<composed>/spec.md" }` and `{ $Path -in @("<composed>/spec.md", "<composed>/user-story.md") }`, and the work-mode rows key on a per-row `Present` list of fully composed paths supplied by the `-ForEach` binding. Every row of the `Context` named `target resolution matrix` is placed on the same resolved-target root, `/synthetic-worktrees/item-worktree`, and the rows differ only in whether the mock answers true for that exact composed path and in the marker the target folder carries.

This is the guard `spec.md` line 622 exists to establish: a row cannot pass on a probe that answers true regardless of where the gate looked, so an implementation that returned `allow` while probing the wrong root would fail the matrix rather than pass it.

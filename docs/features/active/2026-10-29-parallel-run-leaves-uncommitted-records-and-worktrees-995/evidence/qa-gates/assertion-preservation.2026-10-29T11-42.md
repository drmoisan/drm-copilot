# Assertion Preservation

Timestamp: 2026-10-29T11-42
Task: [P6-T7]
Command: git diff $(git merge-base origin/main HEAD) -- tests/scripts/claude-hooks tests/scripts/claude-lib tests/scripts/codex-hooks (removed lines filtered with grep '^-[^-]'); git status --porcelain -- tests/scripts
EXIT_CODE: 0
Output Summary: 15 pre-existing test files under the three folders differ from the merge base; across them exactly two lines are removed, and neither contains `Should` (count of removed lines containing Should: 0). No file under tests/scripts/codex-hooks changed. New test files are untracked and are not pre-existing.

## Removed lines in pre-existing PowerShell test files

| File | Removed line | Replacement and reason |
| --- | --- | --- |
| tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | `foreach ($case in ($script:DenyCases + $script:AllowCases + $script:PreservedFilesCases + $script:DuplicateCases)) {` | same loop with `+ $script:RelativeRecordCases` appended, so the new [P1-T5] case receives the default Clock and Command fields |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | `$siblings = foreach ($name in @('WorktreeResolution', 'WorktreeTargetResolution', 'WorktreeItemResolution')) {` | same line with `'WorktreeRunRecordPath'` added to the sibling-module list ([P2-T2] helper edit) |

All other edits to pre-existing files are additions: setup mocks ([P3-T4]), new It rows and data ([P1-T5]), and the new module entry in WorktreeResolution.Manifest.Tests.ps1 (loop pass 3).

Result: PASS. No removed line in a pre-existing PowerShell test file contains `Should`.

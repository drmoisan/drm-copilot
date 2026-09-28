# Mirror Identity — Hook Pair (P3-T1)

Timestamp: 2026-08-28T11-36

Task: [P3-T1]
Issue: #573
Acceptance criterion supported: AC-14 (first of three pairs)
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. `cp .claude/hooks/enforce-epic-worktree-removal-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
2. `Get-FileHash .claude/hooks/enforce-epic-worktree-removal-gate.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

EXIT_CODE: 0

A file-copy command was used, not an editor write, so the bundle copy is a byte-for-byte reproduction of the repository copy rather than an independently authored file that merely looks the same.

## Post-copy hashes

| Path | SHA-256 |
| --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `56C8FDB4AD1941C067677C52BE88F8E4CA641B321BF0651457E3F6AB7BE47C4A` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `56C8FDB4AD1941C067677C52BE88F8E4CA641B321BF0651457E3F6AB7BE47C4A` |

The two `Hash` values are **equal**, so the pair is byte-identical after the Phase 2 edit.

The hash differs from the pre-edit pair hash `FB986221CDACCC1CBEBB48A61013CA569E5254068EC09C9812D1BF71C35A872D` recorded in the [P0-T7] baseline, which confirms the copy carries this change rather than the pre-edit content.

Output Summary: PASS. `Get-FileHash` reports the identical value `56C8FDB4AD1941C067677C52BE88F8E4CA641B321BF0651457E3F6AB7BE47C4A` for both members of the hook pair, so the bundle mirror is byte-identical to the repository hook after the Phase 2 change. The hash differs from the [P0-T7] pre-edit value, confirming the mirrored content is the post-change content.

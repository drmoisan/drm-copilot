# Batch B copy-set parity — [P2-T7]

Timestamp: 2026-09-07T21-40

Task: `[P2-T7]` — mirror both merge-gate copies into the bundles and verify parity.

TOOLCHAIN_SUBSTITUTION: none required. `cp`, `cmp`, `sha256sum`, and `wc` are all available
directly. `cp` does not pass through the `Write|Edit` PreToolUse matcher, so mirroring consumes
no batch-budget slot, which is the reason the plan specifies `cp` for the mirrors.

## Commands

1. `cp .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` — EXIT_CODE: 0
2. `cp .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` — EXIT_CODE: 0
3. `cmp -s .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` — EXIT_CODE: 0
4. `cmp -s .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` — EXIT_CODE: 0
5. `sha256sum` over all four files — EXIT_CODE: 0
6. `wc -l` over all four files — EXIT_CODE: 0

EXIT_CODE: 0

## SHA-256 of all four files

| File | SHA-256 |
|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | `05feec2ae5ca73a8ea25314d4e7ca3219e3d023e1bbe8d2076e3905e5961d0e5` |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | `d87b543798a17508cccdbd7fcdeba2f8f77b2b67504024922e6fb83f3726aac3` |

Each canonical file equals its mirror. The Claude pair and the Codex pair differ from each
other, as they must: the two runtimes carry different idioms and are not copies of one another.

## Line counts

| File | `wc -l` |
|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 486 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 486 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 186 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 186 |

All four are at or under the 500-line cap. The Claude count of 486 matches the plan's stated
prediction exactly: 472 before the edit plus the 14 lines Edit 2 adds.

## Output Summary

Both `cp` operations exited 0 and both `cmp -s` comparisons exited 0. All four SHA-256 digests
are recorded and each canonical file's digest equals its mirror's. All four files are at or
under 500 lines.

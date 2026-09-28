# Batch C copy-set parity — [P3-T7]

Timestamp: 2026-09-07T21-55

Task: `[P3-T7]` — mirror the abandon gate and the pr-author helpers into the Claude bundle and
verify parity.

TOOLCHAIN_SUBSTITUTION: none required. `cp`, `cmp`, `sha256sum`, and `wc` are all available
directly. `cp` does not pass through the `Write|Edit` PreToolUse matcher, so mirroring consumes
no batch-budget slot, which is the reason the plan specifies `cp` for the mirrors.

## Commands

1. `cp .claude/hooks/enforce-parallel-abandon-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` — EXIT_CODE: 0
2. `cp .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` — EXIT_CODE: 0
3. `cmp -s .claude/hooks/enforce-parallel-abandon-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` — EXIT_CODE: 0
4. `cmp -s .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` — EXIT_CODE: 0
5. `sha256sum` over all four files — EXIT_CODE: 0
6. `wc -l` over all four files — EXIT_CODE: 0

EXIT_CODE: 0

## SHA-256 of all four files

| File | SHA-256 |
|---|---|
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | `827e81b951406df75eb8fa4a7a030063e9e0e6af116a8f8f4eef68946f266fed` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `b809a8b34ea1bb53ac4bd91e5bdb3cee8253379c3c95a58c93d3d9ef702fd54b` |

Each canonical file equals its mirror.

Both mirrors are the Claude bundle only. R-2.b and R-2.c are Claude-side instances; the Codex
runtime carries neither the parallel abandon gate nor the pr-author helpers, so no
`codex-and-agents-customizations` mirror exists for either file and none is created.

## Line counts

| File | `wc -l` | At or under 500 |
|---|---|---|
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 353 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 353 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 260 | yes |

The abandon gate moved from 331 to 353, an increase of 22 lines from Edit 4's three parts. The
pr-author helpers moved from 240 to 260, an increase of 20 lines from Edit 5's inserted block.

## Output Summary

Both `cp` operations exited 0 and both `cmp -s` comparisons exited 0. All four SHA-256 digests
are recorded and each canonical file's digest equals its mirror's. All four files are at or
under 500 lines.

# Workspace-Path Encoding Rule Confirmation — Issue #325 (P1-T1)

Timestamp: 2026-07-07T02-50

## Method

Listed the real, on-disk user-global Claude projects directory with `ls -la ~/.claude/projects/`
(resolves to `C:\Users\DanMoisan\.claude\projects\` on this Windows host) and inspected the
directory names against the absolute workspace `cwd` values known to have produced them.

## Confirmed Rule

Given an absolute workspace `cwd`, the encoded directory name is produced by replacing every
path separator (`\` or `/`) and every `:` with `-`. The drive-letter segment's case is not
normalized by Claude Code, so both an uppercase and a lowercase drive letter are observed on
disk for encodings of the same underlying path prefix. Per-worktree sibling folders are
additional sibling directories whose name is `<encoded-base>-wt-<suffix>` (and, for nested
worktrees, `<encoded-base>-wt-<suffix>-wt-<suffix2>`), i.e. the worktree suffix is appended
directly onto the encoded base name.

## On-Disk Example Folder Names (verbatim, cited from `ls -la ~/.claude/projects/`)

1. `c--Users-DanMoisan-repos-drm-copilot` — encodes `C:\Users\DanMoisan\repos\drm-copilot`
   with a lowercase drive-letter segment (`c--`).
2. `C--Users-DanMoisan-repos-drm-copilot-wt-2026-06-13-11-51` — encodes the per-worktree
   sibling for `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-13-11-51` with an uppercase
   drive-letter segment (`C--`), confirming the `<encoded>-wt-...` sibling-folder pattern.
3. `C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-06-22-28` — encodes the current
   execution workspace `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-06-22-28`, confirming
   the rule against the live workspace root used by this session.
4. `C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-03-16-18-wt-2026-07-03-22-30` — a nested
   worktree-of-a-worktree sibling, confirming the `-wt-<suffix>` segment is appended onto an
   already-encoded (and itself `-wt-`-suffixed) base name rather than only onto the bare
   repository-root encoding.

## Implication for Implementation

- `workspace-encoding.ts` (P1-T3) must replace both `\`, `/`, and `:` with `-` when encoding
  an absolute workspace path, and must compare the resulting encoded name against on-disk
  directory names case-insensitively on (at minimum) the drive-letter segment.
- Directory-name matching must also accept any sibling directory name that starts with
  `<encoded>-wt-` as a per-worktree candidate.

# Scope Invariants — Remediation Cycle 2 (C1)

Timestamp: 2026-11-13T16-05
Command: git diff --name-only <pre-cycle head> HEAD; git diff --ignore-all-space --stat <pre-cycle head> HEAD -- <three lockfiles and three package.json files>; git diff --name-only <merge base of origin/main and HEAD> HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: the cycle's changes outside the feature folder are exactly the three npm lockfiles. No `package.json` changed. No path under `src/`, `extensions/drm-copilot/src/`, `scripts/`, `.claude/`, `.github/`, or `tests/` appears in the cycle diff, and no `.py` file is added or modified. The working tree is clean.

Pre-cycle head (recorded in `remediation-baseline/npm-audit.root.2026-11-13T15-46.md`): 15d3af2d1a7072feea075b77b850f16fb27f677c.

## Cycle diff (pre-cycle head to HEAD), paths outside the feature folder

- extensions/drm-copilot/package-lock.json
- package-lock.json
- packages/mcp-server/package-lock.json

The other 22 cycle paths are under `docs/features/active/2026-11-09-hook-session-root-resolution-1163/` (the plan file and new evidence files).

## Forbidden-prefix and `.py` filter over the cycle diff

Filter `^(src/|extensions/drm-copilot/src/|scripts/|\.claude/|\.github/|tests/)|\.py$`: no match (grep exit 1).

## Whitespace-insensitive content diff

`git diff --ignore-all-space --stat` over the three lockfiles and three `package.json` files: 3 files changed, 18 insertions, 18 deletions; each lockfile changes 6 lines (the `version`, `resolved`, and `integrity` of `hono` 4.13.14 -> 4.13.18 and `@hono/node-server` 2.1.5 -> 2.1.8). No `package.json` appears, so no `overrides` block changed.

## Merge-base diff

168 paths from the merge base of origin/main and HEAD; 0 `.py` paths. The branch's earlier `.claude/` and `tests/` changes belong to the feature's own phases and are outside this cycle's diff.

## git status --porcelain

Empty (all cycle work committed and pushed).

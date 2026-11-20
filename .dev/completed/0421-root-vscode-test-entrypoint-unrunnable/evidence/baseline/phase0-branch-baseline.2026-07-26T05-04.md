# Phase 0 — Branch / Commit Baseline (#421)

Timestamp: 2026-07-26T05-04

Task: [P0-T2]

Command:

```
git branch --show-current
git rev-parse HEAD
git log --oneline fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD
git status --porcelain
```

EXIT_CODE: 0

## Raw Output

```
$ git branch --show-current
bug/vscode-test-integration-entrypoint

$ git rev-parse HEAD
9af4aff8d44600c49468b42a4f48110be4462d64

$ git log --oneline fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD
9af4aff8 docs(bug): clear plan preflight for issue 421
4d092a4c docs(bug): add atomic plan for issue 421
b340f5a8 docs(bug): add issue 421 feature folder and scope research

$ git status --porcelain
 M docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/
```

## Baseline Facts

- Branch: `bug/vscode-test-integration-entrypoint`
- HEAD SHA: `9af4aff8d44600c49468b42a4f48110be4462d64`
- Base commit (origin/main at branch creation): `fb483b8468204e4385b5583c3b3ec4c0a987eede`
- Commits ahead of base: 3, all documentation-only (feature folder, research, plan). No production, test, or workflow file has been modified relative to the base commit at Phase 0 start.
- Working tree at Phase 0 start: only the plan file (P0-T1 check-off) and the new evidence directory are modified/untracked. No source file is dirty.

## Worktree Path Constraint (#414 Condition 3)

Worktree path: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d`

This path contains the dot-directory component `.claude`. That component triggers the pre-existing jest `<rootDir>` glob-escape artifact recorded as issue #414 Condition 3: plain `npm test` / `npm run test:unit` in this worktree emits `No tests found, exiting with code 1` because the interpolated `<rootDir>` produces a malformed `testMatch` glob. `jest.config.cjs` and `run-jest.cjs` are forbidden files in this workstream, so the artifact cannot be repaired here.

Consequence for verification (plan Global Constraint 2): all local jest verification uses the path-independent, rootDir-free invocation:

```
node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"
```

The authoritative verification of a passing root `npm test` is the Phase 5 green CI run, whose checkout path contains no dot-directory component.

Output Summary: Branch `bug/vscode-test-integration-entrypoint` at HEAD `9af4aff8d44600c49468b42a4f48110be4462d64`, three documentation-only commits ahead of base `fb483b8468204e4385b5583c3b3ec4c0a987eede`. No source file dirty at Phase 0 start. Worktree path contains the `.claude` dot-directory, so #414 Condition 3 applies and the path-independent jest invocation is mandatory locally.

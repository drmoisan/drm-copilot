# TypeScript Formatter Baseline (P0-T7)

Timestamp: 2026-09-30T13-49
Task: [P0-T7]
Location: `extensions/drm-copilot` for npm commands (invoked from the worktree root as `npm --prefix extensions/drm-copilot ...`, which runs the package script in `extensions/drm-copilot`); git commands at the worktree root.

## Precondition

`extensions/drm-copilot/node_modules` was absent (`ls -d extensions/drm-copilot/node_modules` exited 2).

Command: npm --prefix extensions/drm-copilot ci
EXIT_CODE: 0
Output Summary: `added 452 packages, and audited 453 packages in 12s`; `found 0 vulnerabilities`. `node_modules` is gitignored, so the install does not change the diff scope.

## Porcelain before

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/
```

## Formatter

Command: npm --prefix extensions/drm-copilot run format   (script: `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`)
EXIT_CODE: 0
Output Summary: 475 file lines printed; all 475 end in `(unchanged)` (counted with `grep -c -F -e "(unchanged)"`; the only non-matching lines are the four npm script header lines). No file was rewritten.

## Porcelain after

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/
```

Result: the two listings are identical (both entries are this execution's own Phase 0 evidence writes). Every printed Prettier file line ended in `(unchanged)`. Rewritten list: none. Revert: none required.

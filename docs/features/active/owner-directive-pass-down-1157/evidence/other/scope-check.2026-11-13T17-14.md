# Scope Check - Remediation Cycle 2 (P2-T6)

Timestamp: 2026-11-13T17-14
Command: sh SCRATCH/issue-1157-c2-scope.sh (git diff --name-status <cycle-start commit>; git status --porcelain; node SCRATCH/issue-1157-c2-lockcmp.cjs <worktree root> <merge base> <lockfile> for the three lockfiles; git diff --stat <merge base> -- the three package.json files)
EXIT_CODE: 0
Output Summary: PASS on every check. Changed paths outside the feature folder in this cycle are exactly the three lockfiles; no .py, .ps1, .ts, workflow, or customization file changed; each lockfile keeps lockfileVersion 3 and an unchanged packages root entry, and its only changed keys are node_modules/@hono/node-server and node_modules/hono; no package.json changed.

The cycle-start commit is the single commit that added `remediation-plan.2026-11-13T16-30.md`, derived at run time with `git log --diff-filter=A --format=%H -- docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T16-30.md` (one line of output). The merge base is `git merge-base origin/main HEAD`, derived at run time.

## git diff --name-status <cycle-start commit>

Paths outside `docs/features/active/owner-directive-pass-down-1157/`:

- `M extensions/drm-copilot/package-lock.json`
- `M package-lock.json`
- `M packages/mcp-server/package-lock.json`

Paths inside the feature folder: the modified plan file (check-offs) and 33 added evidence files under `evidence/other/`, `evidence/qa-gates/`, and `evidence/remediation-baseline/` (including the two preflight-fix records written before execution).

## git status --porcelain

- `?? docs/features/active/owner-directive-pass-down-1157/evidence/other/task-check.P2-T5.2026-11-13T17-14.md`
- `?? docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/npm-audit-final.2026-11-13T17-14.md`

Both are new evidence files inside the feature folder.

## Lockfile comparison against the merge base (script output)

| Lockfile | lockfileVersion before / after | `packages[""]` unchanged | Changed keys | Versions |
|---|---|---|---|---|
| `package-lock.json` | 3 / 3 | true | `node_modules/@hono/node-server`, `node_modules/hono` | 2.1.5 -> 2.1.8; 4.13.14 -> 4.13.18 |
| `extensions/drm-copilot/package-lock.json` | 3 / 3 | true | `node_modules/@hono/node-server`, `node_modules/hono` | 2.1.5 -> 2.1.8; 4.13.14 -> 4.13.18 |
| `packages/mcp-server/package-lock.json` | 3 / 3 | true | `node_modules/@hono/node-server`, `node_modules/hono` | 2.1.5 -> 2.1.8; 4.13.14 -> 4.13.18 |

For each file the script printed `all changed keys under node_modules/=true` and `other top-level keys changed=none`.

## package.json ranges

`git diff --stat <merge base> -- package.json extensions/drm-copilot/package.json packages/mcp-server/package.json` printed nothing: no `package.json` changed, so no dependency or override range is wider than at the merge base. P1-T1 to P1-T3 recorded no `package.json` rewrite by `npm audit fix`.

## Checks

| Check | Result |
|---|---|
| Changed paths outside the feature folder are only the three lockfiles (plus a `package.json` recorded as rewritten; none was) | PASS |
| No `.py`, `.ps1`, `.ts`, workflow, or customization file changed in this cycle | PASS |
| Each lockfile keeps its `lockfileVersion` | PASS |
| Each lockfile has an unchanged `packages` root entry | PASS |
| Every changed key is a `node_modules/` entry | PASS |
| No `package.json` dependency or override range is wider than at the merge base | PASS |

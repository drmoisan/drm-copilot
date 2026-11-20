# Working-Tree Change-Set Assertion and mcp-server Isolation (#414, [P3-T3])

Timestamp: 2026-07-25T21-52

Scope note: at this point the committed range `main...HEAD` contains only excluded `docs/features/` paths (planning artifacts committed at branch creation), so `git diff --name-only main...HEAD` cannot yet confirm the four-file dependency change set. Per the plan, the working-tree form is used here; the committed-range form is performed post-commit in [P6-T2].

## Command 1 — `git status --porcelain`

Command: `git status --porcelain` (working directory: repository root)
EXIT_CODE: 0

```text
 M docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md
 M docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/spec.md
 M extensions/drm-copilot/package-lock.json
 M extensions/drm-copilot/package.json
 M package-lock.json
 M package.json
?? docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/
```

## Command 2 — `git diff --name-only`

Command: `git diff --name-only` (working directory: repository root)
EXIT_CODE: 0

```text
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/spec.md
extensions/drm-copilot/package-lock.json
extensions/drm-copilot/package.json
package-lock.json
package.json
```

## Assertion (a) — no reported path starts with `packages/mcp-server`

Result: PASS. Neither command reports any path under `packages/mcp-server`. `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` are unmodified, as `spec.md` requires. No `npm install` or `npm ci` has been run in that root at this point, so nothing could have altered its lockfile.

## Assertion (b) — remaining set after exclusions is exactly the four dependency files

Excluded per the plan: paths under `docs/features/` (feature documentation, including the plan checklist, the spec acceptance-criteria check-offs, and the untracked `evidence/` tree) and paths under `artifacts/orchestration/` (the orchestration checkpoint; none reported).

| Reported path | Disposition |
|---|---|
| `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md` | excluded (`docs/features/`) |
| `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/spec.md` | excluded (`docs/features/`) |
| `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/` (untracked) | excluded (`docs/features/`) |
| `extensions/drm-copilot/package-lock.json` | in change set (1 of 4) |
| `extensions/drm-copilot/package.json` | in change set (2 of 4) |
| `package-lock.json` | in change set (3 of 4) |
| `package.json` | in change set (4 of 4) |

Remaining set after exclusions: `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json` — exactly the four files, no more and no fewer.

Result: PASS.

Output Summary: Both assertions hold against the working tree. `git status --porcelain` and `git diff --name-only` report no path under `packages/mcp-server`, confirming that root is untouched. After excluding `docs/features/` and `artifacts/orchestration/`, the reported set is exactly the four authorized dependency files: `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`. No source file, workflow, or configuration file was modified.

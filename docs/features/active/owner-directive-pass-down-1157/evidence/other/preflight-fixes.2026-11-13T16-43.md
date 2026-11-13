# Preflight Fixes - Issue 1157, Cycle 2 Remediation Plan

Timestamp: 2026-11-13T16-43
Plan: docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T16-30.md
Inputs: docs/features/active/owner-directive-pass-down-1157/remediation-inputs.2026-11-13T16-30.md
Validator: Python CLI `plan` subcommand exit 0 before and after the fixes; installed MCP validator ok.

## Fixes (task text only; no task added, removed, or reordered)

1. `## CI Command Mirrored` (root TypeScript tests bullet) | incorrect context claim | The plan stated that the root suite needs the extension dependencies installed. `.github/workflows/_root-typescript-tests.yml` runs only `npm ci` at the root before `npm test`. The sentence now states that the root suite collects the extension tests and that the CI job installs only the root dependencies. No assertion changes.
2. P1-T5 acceptance | porcelain scope | `git status --porcelain` after P1-T5 also lists the evidence files that P1-T1 to P1-T5 write under `<FEATURE>/evidence/`, so "no file beyond those listed at the end of P1-T3" could not hold. The condition is scoped to paths outside `<FEATURE>/`. The intent (that `npm ci` rewrites no manifest or lockfile) is unchanged.
3. P2-T6 | diff anchor | `git diff --name-status` from the merge base lists the cycle 1 and feature changes (hooks, skills, agents, bundle copies), so "changed paths outside `<FEATURE>/` are only the three lockfiles" and "changed in this cycle" could not hold. The anchor is now the cycle-start commit, derived as the commit that added this plan file (`git log --diff-filter=A`). The lockfile comparison against the merge-base version is unchanged (the lockfiles are equal at the merge base and the cycle start).

## Observations recorded (no plan change)

- `origin/main` equals the merge base at preflight time, so the P0-T1 `origin/main` lockfile difference is currently empty.
- npm registry: `hono` 4.13.16 to 4.13.18 and `@hono/node-server` 2.1.6 to 2.1.8 are published, inside the `^4.12.27` and `^2.0.5` overrides of all three manifests, so the no-`package.json`-edit premise holds.
- Prettier `json-stringify` parser applies to `extensions/drm-copilot/package-lock.json`, which the extension `format` globs include; the current file passes the check.
- Extension and root ESLint exit 0 on sources identical to the worktree.
- Pester and pytest inputs are unchanged since the cycle 1 gates `pester-final.2026-11-13T15-48.md` and `pytest-final.2026-11-13T15-55.md`: every later commit changes only files under the feature folder.
- Root `format:check` exits 1 on three files under `tests/scripts/claude-lib/docs/fixtures/` (`config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`) with Prettier 3.9.10 and the worktree `.prettierignore`. This is returned as a substantive defect against P1-T6 and P2-T1, not fixed here.

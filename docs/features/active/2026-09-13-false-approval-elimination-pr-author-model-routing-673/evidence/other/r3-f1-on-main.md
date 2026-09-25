# Restated AC-21 Verification — F1 Is on `main` (issue #673)

Timestamp: 2026-09-19T17-39

Command: `git log --format=%H --diff-filter=A origin/main -- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`; `git merge-base --is-ancestor 81a31f1a553d9497e19c51b93b11513e6576a42f origin/main`; two `grep -c` counts of the module paths in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; testsuite values copied from `evidence/baseline/r3-phase0-pester-coverage.md`.

EXIT_CODE: 0

## Ancestry

| Item | Value |
| --- | --- |
| Commit that added `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | `81a31f1a553d9497e19c51b93b11513e6576a42f` |
| `git merge-base --is-ancestor <that SHA> origin/main` exit code | 0 |

Exit code 0 means the commit is an ancestor of `origin/main`, so F1 is merged to `main`. RS-9 restates AC-21's original wording — which assumed F1 would land on an epic integration branch — to this `main`-based form, because the epic integration branch already merged via PR #686.

## Pack-manifest registration counts

| Path | Occurrences in `core.json` |
| --- | --- |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 1 |
| `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | 1 |

Each appears exactly once, at `core.json:169` and `:170` respectively, as quoted in `evidence/other/r3-f1-binding-table.md` row 1.

## `WorktreeResolution.Manifest.Tests.ps1` result

Copied from the `[P0-T10]` baseline run recorded in `evidence/baseline/r3-phase0-pester-coverage.md`:

| Attribute | Value |
| --- | --- |
| `tests` | 7 |
| `failures` | 0 |
| `skipped` | 0 |
| `disabled` | 0 |
| passed | 7 |

Output Summary: All three acceptance conditions hold. The ancestry check exits 0, so F1 is on `origin/main`; each of the two F1 module paths occurs exactly once in `core.json`; and the manifest testsuite shows `failures 0` with a passed count of 7, which is greater than 0. AC-21 is satisfied in its restated form, confirmed before this plan's first hook edit — no commit on this branch has yet touched `.claude/hooks`, as `evidence/other/r3-reproduction-evidence-audit.md` records.

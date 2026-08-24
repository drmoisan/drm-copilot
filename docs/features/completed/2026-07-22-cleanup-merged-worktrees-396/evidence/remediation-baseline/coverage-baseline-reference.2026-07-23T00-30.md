# Remediation Baseline — Coverage Baseline Reference (Cycle 2 / CR-1), Issue #396

Timestamp: 2026-07-22T20-42

Command:

```
gh run view 29922832766 --repo drmoisan/drm-copilot --json headSha,headBranch,conclusion,displayTitle
git log --oneline 4851f3c98c45f86bc3ab2c079f557c96f57a5e6f..HEAD -- scripts/bash tests/shell
git status --porcelain scripts/bash tests/shell
```

EXIT_CODE: 0

## Provenance verification

- CI run 29922832766 (`_shell-coverage.yml`, `drm-copilot-wt-2026-07-21T21-57`) tested head commit `4851f3c98c45f86bc3ab2c079f557c96f57a5e6f`, conclusion `success`.
- `git log --oneline 4851f3c9..HEAD -- scripts/bash tests/shell` returned no commits: no file under `scripts/bash/` or `tests/shell/` changed after the baseline run's head commit.
- `git status --porcelain scripts/bash tests/shell` returned empty: the working tree has no uncommitted changes under those paths.
- Therefore the plan's primary branch applies (no fresh dispatch needed); run 29922832766 figures are cited as this cycle's coverage baseline.

## Baseline coverage figures (numeric, no placeholders)

| Metric | Value |
|---|---|
| Overall bash line coverage | 89.0% |
| `scripts/bash/cleanup_worktrees_lib.sh` | 88.5% |
| `scripts/bash/cleanup-worktrees.sh` | 100.0% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 89.8% |

Source artifact: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/qa-gates/coverage-delta.2026-07-22T09-01.md`.
Source run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29922832766

Output Summary: Baseline overall bash line coverage is 89.0% (>= 85% threshold). Per-file baselines: `cleanup_worktrees_lib.sh` 88.5%, `cleanup-worktrees.sh` 100.0%, `cleanup_worktrees_actions_lib.sh` 89.8%. Provenance confirmed: baseline run head equals the most recent shell-touching commit; no later change exists. `scripts/bash/cleanup_worktrees_enumerate_lib.sh` does not yet exist (created in Phase 1); its post-change coverage is measured in Phase 4.

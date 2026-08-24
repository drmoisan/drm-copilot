# Phase 0 — Cycle-3 Coverage Baseline Reference, Issue #396

Timestamp: 2026-07-22T21-42

Command:

```
git merge-base --is-ancestor 8ba4fb79e03f85163587c400cbfd881ea9642630 HEAD
git log --oneline 8ba4fb79e03f85163587c400cbfd881ea9642630..HEAD -- scripts/bash tests/shell
git rev-list --count 8ba4fb79e03f85163587c400cbfd881ea9642630..HEAD
```

EXIT_CODE: 0

## Provenance

The cycle-2 green run is the authoritative baseline. Source run:
`https://github.com/drmoisan/drm-copilot/actions/runs/29970805348` (green, headSha `8ba4fb79e03f85163587c400cbfd881ea9642630`).

Verification that the baseline is still valid for cycle 3:
- `8ba4fb79` is an ancestor of the current HEAD (`921b5c40`).
- Exactly one commit separates them, and `git log ... -- scripts/bash tests/shell` returns
  no results: no file under `scripts/bash/` or `tests/shell/` changed after the commit
  tested by the cycle-2 green run.
- Therefore the cycle-2 figures are cited as the cycle-3 baseline (no fresh dispatch
  required; the alternative branch authorized by P0-T4 was not taken).

## Baseline Coverage Figures (numeric, from cycle-2 green run 29970805348)

| Metric | Baseline value |
|---|---|
| Overall bash line coverage | 90.4% |
| `scripts/bash/cleanup-worktrees.sh` | 100.0% |
| `scripts/bash/cleanup_worktrees_lib.sh` | 90.2% |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 95.1% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 89.8% |

Source of per-file figures: `evidence/qa-gates/coverage-delta.2026-07-23T00-30.md`.
Branch coverage is not applicable (kcov reports line coverage only per `.claude/rules/shell.md`).

Output Summary: Cycle-3 line-coverage baseline is the cycle-2 green run 29970805348 (headSha 8ba4fb79), overall 90.4%. No shell file changed since that commit (verified by git log path filter over one intervening commit), so the cycle-2 numbers are authoritative for the cycle-3 no-regression comparison. Per-file baselines: cleanup-worktrees.sh 100.0%, cleanup_worktrees_lib.sh 90.2%, cleanup_worktrees_enumerate_lib.sh 95.1%, cleanup_worktrees_actions_lib.sh 89.8% — all >= 85%.

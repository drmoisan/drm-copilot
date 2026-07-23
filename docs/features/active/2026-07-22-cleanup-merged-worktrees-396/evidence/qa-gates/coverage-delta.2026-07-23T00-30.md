# Coverage Delta — Cycle 2 (CR-1), Issue #396

Timestamp: 2026-07-22T21-10

Command:

```
gh run download 29970805348 --name shell-coverage --dir artifacts/pester/kcov-ci
grep -oE '<coverage[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml   # overall
grep -oE '<class name="[^"]*" filename="[^"]*" ... line-rate="[0-9.]+">' artifacts/pester/kcov-ci/cov.xml  # per file
```

EXIT_CODE: 0

Source run: https://github.com/drmoisan/drm-copilot/actions/runs/29970805348 (green, headSha 8ba4fb79)
Baseline source: run 29922832766 (overall 89.0%), per `coverage-baseline-reference.2026-07-23T00-30.md`.

## Overall Coverage (line)

| Metric | Value |
|---|---|
| Baseline overall (run 29922832766) | 89.0% |
| Post-change overall (run 29970805348) | 90.4% |
| No-regression check | PASS (90.4% >= 89.0% baseline; >= 85% threshold) |

## Per-File Line Coverage

| File | Baseline | Post-change | >= 85% | No-regression |
|---|---|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 100.0% | 100.0% | PASS | PASS |
| `scripts/bash/cleanup_worktrees_lib.sh` | 88.5% (pre-split, combined) | 90.2% | PASS | PASS |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | n/a (new file, split from lib) | 95.1% | PASS | n/a |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 89.8% | 89.8% | PASS | PASS |

Values are the Cobertura `line-rate` attributes from the merged `cov.xml`
(`artifacts/pester/kcov-ci/cov.xml`), expressed as percentages.

## Notes

- `cleanup_worktrees_enumerate_lib.sh` is a new file created by the Phase 1 pure-move
  split of the enumeration/protection function group out of `cleanup_worktrees_lib.sh`.
  The pre-split combined `cleanup_worktrees_lib.sh` baseline was 88.5%; after the split
  the classification lib reports 90.2% and the enumerate lib reports 95.1%, both above
  the 85% threshold and the pre-split figure.
- Branch coverage is not applicable for bash (kcov reports line coverage only, per
  `.claude/rules/shell.md`); there is no bash branch-coverage gate.

## Outcome

PASS. Overall line coverage is 90.4% (>= 85% and not regressed below the 89.0%
baseline). Every production file in scope is >= 85% line coverage, with no per-file
regression.

Output Summary: All coverage comparisons PASS. Overall 90.4% (baseline 89.0%, +1.4pp). Per-file: cleanup-worktrees.sh 100.0%, cleanup_worktrees_lib.sh 90.2%, cleanup_worktrees_enumerate_lib.sh 95.1%, cleanup_worktrees_actions_lib.sh 89.8% — all >= 85%, none regressed.

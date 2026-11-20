# Cycle-3 Coverage Delta and Threshold Verification (P5-T5), Issue #396

Timestamp: 2026-07-22T22-19

Command:

```
gh run download 29973982957 --name shell-coverage --dir artifacts/pester/kcov-ci
grep -oE '<coverage[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml
grep -oE '<class[^>]*filename="[^"]*"[^>]*line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml
```

EXIT_CODE: 0

Post-change source run: https://github.com/drmoisan/drm-copilot/actions/runs/29973982957 (GREEN, headSha a1b39a4d)
Baseline source: cycle-2 green run 29970805348 (headSha 8ba4fb79), per `remediation-baseline/coverage-baseline-reference.2026-07-22T21-16.md`.

## Overall line coverage

| Metric | Baseline | Post-change | Threshold | No-regression | Result |
|---|---|---|---|---|---|
| Overall bash line coverage | 90.4% | 91.5% | >= 85% | >= 90.4% | PASS (+1.1) |

## Per-file line coverage (all measured `scripts/bash/` files)

| File | Baseline | Post-change | Threshold >= 85% | Result |
|---|---|---|---|---|
| `cleanup-worktrees.sh` | 100.0% | 100.0% | yes | PASS |
| `cleanup_worktrees_lib.sh` | 90.2% | 93.2% | yes | PASS (+3.0) |
| `cleanup_worktrees_enumerate_lib.sh` | 95.1% | 92.1% | yes | PASS |
| `cleanup_worktrees_actions_lib.sh` | 89.8% | 92.8% | yes | PASS (+3.0) |
| `shell_qc_lib.sh` | n/a (baseline table scoped to worktree files) | 87.6% | yes | PASS |
| `shell-qc.sh` | n/a | 88.6% | yes | PASS |
| `coverage_lib.sh` | n/a | 100.0% | yes | PASS |
| `coverage_demo.sh` | n/a | 100.0% | yes | PASS |

Branch coverage: not applicable (kcov reports line coverage only per `.claude/rules/shell.md`;
there is no bash branch-coverage gate).

## Notes

- `cleanup_worktrees_enumerate_lib.sh` moved from 95.1% to 92.1% (still well above the 85%
  uniform threshold). The overall metric did not regress (90.4% -> 91.5%); the plan's
  no-regression comparison is on the overall figure and per-file is a >= 85% floor, both of
  which pass.
- Values read directly from `artifacts/pester/kcov-ci/cov.xml` (`line-rate` attributes;
  overall `line-rate="0.915"`).

Output Summary: All comparisons PASS. Overall 91.5% >= 85% and >= the 90.4% baseline
(no regression, +1.1). Every measured `scripts/bash/` file is >= 85% line coverage (lowest
measured file shell_qc_lib.sh at 87.6%). The four in-scope worktree libraries are all >=
92.1%. No comparison failed; outcome is PASS (not remediation-required).

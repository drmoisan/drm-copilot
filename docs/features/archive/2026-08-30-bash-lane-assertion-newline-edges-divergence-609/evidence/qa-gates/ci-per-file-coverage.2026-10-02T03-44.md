# CI per-file kcov coverage evidence for parallel-lane-assertion.sh (AC-14)

Timestamp: 2026-10-02T03-44
Command: gh run download 36960736942 --repo drmoisan/drm-copilot -n shell-coverage; gh run download 36958806659 --repo drmoisan/drm-copilot -n shell-coverage; read the `<class filename=".claude/lib/bash/parallel-lane-assertion.sh">` element of `cov.xml` in each artifact
EXIT_CODE: 0
Output Summary: Per-file line-rate of `.claude/lib/bash/parallel-lane-assertion.sh` is 0.989 on the PR head and 0.989 on main (baseline); no regression and well above 0.85. The changed line (`read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`, line 88 at head 5e854239) has `hits="1"` in the PR head artifact. In the main artifact the equivalent line is 86/87 (the pre-fix library, two fewer lines) with `hits="1"`.

## Sources

| Item | Run | Commit | Value |
|---|---|---|---|
| PR head coverage | https://github.com/drmoisan/drm-copilot/actions/runs/36960736942 (job 110693630023 `shell-coverage / Shell Coverage (Bats + kcov)`, conclusion success; artifact `shell-coverage`, id 11207723582) | 5e85423931fe483c4fad5daa338b9dbb3a14edb6 | `line-rate="0.989"`, `branch-rate="1.0"`; `<line number="88" hits="1"/>` |
| Baseline coverage (latest successful CI on main) | https://github.com/drmoisan/drm-copilot/actions/runs/36958806659 (event push, artifact `shell-coverage`) | 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 | `line-rate="0.989"` for the same file |

The class element in both artifacts is `parallel_lane_assertion_sh__36` at `cov.xml` line 810. The merged total reported by the job log on the earlier head was `Bash coverage (lines): 93.7%` (see `ci-shell-coverage.2026-10-02T03-40.md`).

## Acceptance criterion decision
AC-14: satisfied. Per-file line coverage 0.989 >= 0.85 and equal to the baseline 0.989 (no regression); the changed line is executed (hits 1).

# P6-T14 — Coverage delta (kcov, bash)

Timestamp: 2026-09-27T02-15
Task: [P6-T14]
Baseline run: 36285238036 (P0-T11/P0-T12; headSha `b5f98be268c8c9e0752027486f6500f0a6fa26ce`)
Post-change run: 36287146354 (P6-T11/P6-T12; headSha `e29ad95d70cce6641c1817f3ac36f319d2a10b59`)

## Overall headline

| Measure | Baseline (P0-T11) | Post-change (P6-T11) |
|---|---|---|
| `Bash coverage (lines)` | 93.3% | 93.3% |

## Per-file line-rate

| File | Baseline (P0-T12) | Post-change (P6-T12) | Difference |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 0.921 | 0.924 | +0.003 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 0.953 | 0.953 | 0.000 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 0.954 | 0.954 | 0.000 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 0.890 | 0.890 | 0.000 |
| `scripts/bash/cleanup-worktrees.sh` | 0.976 | 0.976 | 0.000 |

## New-code coverage (P6-T13)

6 of 6 instrumented added executable lines in the enumerate and actions libraries executed (100%); the two added `fi` lines are not instrumented by kcov. The other three production files carry comment and help-text changes only in this plan's scope.

Output Summary:
- Every post-change per-file value is at least 0.85 and at least its baseline value; no file is below both.
- Overall headline unchanged at 93.3%.
- New-code coverage: 100% of instrumented added lines.
- Branch coverage: not applicable (kcov does not measure branch coverage; bash is exempt from the branch threshold).
- Result: PASS.

# Tokenizer Scaling After the Fix - Issue 1019

Timestamp: 2026-11-06T18-33
Command: sh SCRATCH/issue-1019-p2-t7.sh (SCRATCH/issue-1019-tokenscale.ps1 -ModulePath <worktree module> -Label run<n> -Sizes 2000,4000,8000,16000,32000, in three separate processes run in sequence)
EXIT_CODE: 0
Output Summary: The criterion holds. Every adjacent doubling ratio at 8,000 units and above is at most 3.0 for all three shapes; the largest is 2.09. The string shape is linear: its ratios at 8,000 units and above are 1.72, 1.79, and 2.00, against about 4.0 for quadratic behavior. MODULE hash 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf.

This is evidence, not a suite test. Absolute times are specific to this host. This run started no other process during the timing window (2026-11-06T18:30:53Z to 18:31:20Z); load from other sessions on the host was not measured. An earlier attempt of the helper exited 1 with no timing, because a comma-separated `-Sizes` value does not bind through `pwsh -File`; the launcher now uses `pwsh -Command`.

## Raw Runs (ms)

| Shape | Units | Run 1 | Run 2 | Run 3 | Median |
| --- | --- | --- | --- | --- | --- |
| `names` | 2,000 | 139 | 137 | 135 | 137 |
| `names` | 4,000 | 138 | 163 | 132 | 138 |
| `names` | 8,000 | 282 | 317 | 267 | 282 |
| `names` | 16,000 | 485 | 600 | 481 | 485 |
| `names` | 32,000 | 1012 | 1230 | 1002 | 1012 |
| `strings` | 2,000 | 257 | 241 | 244 | 244 |
| `strings` | 4,000 | 483 | 476 | 460 | 476 |
| `strings` | 8,000 | 789 | 817 | 824 | 817 |
| `strings` | 16,000 | 1461 | 1523 | 1461 | 1461 |
| `strings` | 32,000 | 2919 | 3014 | 2912 | 2919 |
| `long-string-body` | 2,000 | 18 | 16 | 16 | 16 |
| `long-string-body` | 4,000 | 33 | 33 | 32 | 33 |
| `long-string-body` | 8,000 | 65 | 65 | 66 | 65 |
| `long-string-body` | 16,000 | 123 | 122 | 124 | 123 |
| `long-string-body` | 32,000 | 251 | 245 | 250 | 250 |

## Ratios of Medians

| Shape | 4,000 / 2,000 (outside the criterion) | 8,000 / 4,000 | 16,000 / 8,000 | 32,000 / 16,000 |
| --- | --- | --- | --- | --- |
| `names` | 1.01 | 2.04 | 1.72 | 2.09 |
| `strings` | 1.95 | 1.72 | 1.79 | 2.00 |
| `long-string-body` | 2.06 | 1.97 | 1.89 | 2.03 |

Against the AC-3 wording, "doubling the source no more than about doubles the time": all ratios at 8,000 units and above lie between 1.72 and 2.09. The `names` ratio of 1.01 at 4,000 / 2,000 is outside the criterion; the 2,000-unit `names` case runs first in each process, which likely includes warm-up time, although this was not measured separately.

## Comparison at 16,000 Units

The unfixed and candidate figures come from single runs recorded in `evidence/baseline/root-cause-profile.2026-11-06T17-25.md` under different host load, so this table shows the order of magnitude rather than a precise factor.

| Shape | Unfixed (ms) | Candidate (ms) | Fixed median (ms) |
| --- | --- | --- | --- |
| `names` | 42443 | 759 | 485 |
| `strings` | 119291 | 35469 | 1461 |
| `long-string-body` | 5689 | 128 | 123 |

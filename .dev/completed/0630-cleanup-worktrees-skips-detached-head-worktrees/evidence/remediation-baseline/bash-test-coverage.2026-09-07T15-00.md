# Baseline Bash Test Coverage (CI-measured)

Timestamp: 2026-09-07T15-00
Task: [P0-T7]

`kcov` has no local route in this worktree (`command -v kcov` exits 1), so the coverage baseline is
produced by dispatching `.github/workflows/_shell-coverage.yml`, whose test step runs
`bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest` where bats and kcov are installed.
This is the same instrument that will produce the post-change figure in [P6-T4], so the two are
directly comparable.

## Commands

Command: `git fetch origin bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
EXIT_CODE: 0

Command: `git rev-parse HEAD`
EXIT_CODE: 0

```
65a56cb94352c2a19c381acf4008837fa84aee69
```

Command: `git rev-parse origin/bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
EXIT_CODE: 0

```
65a56cb94352c2a19c381acf4008837fa84aee69
```

The two shas are equal, so no push was required before dispatch.

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
EXIT_CODE: 0

Command: `gh run view 34136171946 --json status,conclusion,headSha,url,databaseId`
EXIT_CODE: 0

Command: `gh run download 34136171946 -n shell-coverage -D <scratch-dir>`
EXIT_CODE: 0

The artifact was downloaded to a scratch directory outside the repository.

Command: `gh run view 34136171946 --log`
EXIT_CODE: 0

## Run identity

- Run ID: `34136171946`
- Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34136171946>
- Run conclusion: `success`
- Head sha the run tested: `65a56cb94352c2a19c381acf4008837fa84aee69`

## Values read from the run

From the run log, step `Run shell-qc test with coverage`:

```
Bash coverage (lines): 92.9%
```

```
1..308
```

Count of log lines containing `not ok`: 0.

From the uploaded `shell-coverage` artifact, `cov.xml`:

```
<coverage ... line-rate="0.929" ...>
<class name="cleanup_worktrees_detached_lib_sh__22" filename="scripts/bash/cleanup_worktrees_detached_lib.sh" branch-rate="1.0" complexity="1.0" line-rate="0.806">
```

Per-file line rates for the five files this feature touches:

| File | Line rate |
|---|---|
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 0.806 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 0.933 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 0.933 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 0.921 |
| `scripts/bash/cleanup-worktrees.sh` | 1.000 |

Lines of `scripts/bash/cleanup_worktrees_detached_lib.sh` reported with `hits="0"` at baseline
(20 lines): 90, 91, 116, 117, 120, 121, 127, 128, 131, 132, 141, 142, 146, 147, 152, 153, 160, 190,
212, 213.

No branch-coverage figure is reported. kcov does not measure branch coverage for bash; the
`branch-rate="1.0"` attributes in the Cobertura report are fixed placeholders and reading a number
from them would be fabrication.

Output Summary: the baseline aggregate line coverage is **92.9%** and the baseline per-file line
rate for `scripts/bash/cleanup_worktrees_detached_lib.sh` is **0.806**. Both are measured values
read from run `34136171946`, which tested head sha
`65a56cb94352c2a19c381acf4008837fa84aee69` and concluded `success`. The run's TAP plan count is 308
with no `not ok` line.

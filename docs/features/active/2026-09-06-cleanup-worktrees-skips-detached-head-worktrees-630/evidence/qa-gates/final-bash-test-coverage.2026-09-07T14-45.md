# Final QC Stage 3 — Bash Test with Coverage (Issue #630)

Timestamp: 2026-09-07T14-45

Task: [P7-T3]

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`

EXIT_CODE: 0

Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34118811332>

Run conclusion: success

Tree under test: the feature branch `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`
at commit `fdd0fecf` — the complete change set, Phases 1 through 6.

Iteration: 1 of 1. No restart of the loop was required.

## Command Substitution

The plan's [P7-T3] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh test --coverage'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied and are recorded here.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`. The real
   worktree for this feature is `agent-adf4f49cbc48904be`. The plan's path is wrong and was
   not used.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard in this environment, and `kcov` has no local route on this
   machine. The wrapper was therefore replaced by the CI fallback workflow
   `.github/workflows/_shell-coverage.yml`, dispatched with `gh workflow run` against the
   feature branch. That workflow's test step executes
   `bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest` — the same script with
   the same argument the plan names, on a runner where `bats` and `kcov` are installed. CI is
   canonical where a local result and a CI result disagree. This is the same substitution
   recorded in the [P0-T6] baseline artifact, so the baseline and the post-change figure are
   produced by the same instrument and are directly comparable.

The same workflow run's earlier `Run shell-qc check` step also passed, which is consistent
with the [P7-T2] result obtained natively.

## Recorded Values

- TAP plan line: `1..308`
- Lines beginning `not ok`: 0
- Coverage headline: `Bash coverage (lines): 92.9%`

## TAP Plan Count Against the Phase 0 Baseline

| Measure | [P0-T6] baseline | This run | Difference |
|---|---|---|---|
| TAP plan count | 290 | 308 | +18 |
| Lines beginning `not ok` | 0 | 0 | 0 |
| Line coverage | 93.6% | 92.9% | -0.7 |

308 minus 290 is **18**, which is exactly the number of cases this feature adds: 1 CLI case
([P2-T19]), 3 deletion cases ([P2-T16] through [P2-T18]), and 14 detached cases ([P2-T2]
through [P2-T15]). That is this task's stated acceptance for the plan count, and it holds.
The same 18 cases are the ones recorded as `not ok` in the [P2-T20] fail-before artifact, so
every fail-before / pass-after pair in this feature closes here.

## Per-File Coverage from the Uploaded Report

Read from the run's uploaded Cobertura report `shell-coverage/cov.xml` (and the identical
`shell-coverage/kcov-merged/cov.xml`):

| File | Line coverage |
|---|---|
| overall (`line-rate="0.929"`) | 92.9% |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 80.6% |
| `scripts/bash/cleanup_worktrees_lib.sh` | 93.3% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 93.3% |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.1% |
| `scripts/bash/cleanup-worktrees.sh` | 100.0% |

Every one of these entries carries `branch-rate="1.0"`. That attribute is kcov's fixed
placeholder, not a measured branch figure; kcov does not measure branch coverage for bash.
No branch-coverage value is asserted from it here. The delta and threshold reading of these
figures is recorded in the [P7-T5] artifact.

Output Summary: The full suite exited **0**. (a) The TAP plan count is **308**, which is
**exactly 18 greater** than the [P0-T6] Phase 0 baseline count of **290**, matching the 18
cases added by [P2-T2] through [P2-T19] with no remainder. (b) **No output line begins with
`not ok`**, so every one of the 308 cases passed, including all 290 pre-existing cases and
all 18 new ones. (c) The line beginning `Bash coverage (lines):` reports **92.9** percent.
This is a measured numeric value, not a placeholder. This is the third clause of AC24 and the
pass-after half of AC1 through AC19 and AC22.

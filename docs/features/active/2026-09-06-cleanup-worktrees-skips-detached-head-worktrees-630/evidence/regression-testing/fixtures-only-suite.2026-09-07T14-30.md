# Regression — Fixtures-Only Suite Run (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P1-T11]

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`

EXIT_CODE: 0

Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34115246179>

Run conclusion: success

Tree under test: the feature branch at commit `bf0bf088` — Phase 1 fixture data only, with no
test-source and no production-source change.

## Command Substitution

The plan's [P1-T11] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh test'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree for this run is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard, and `bats` and `kcov` are not installed locally. The suite was
   run through the CI fallback workflow `.github/workflows/_shell-coverage.yml`, dispatched
   with `gh workflow run` against the feature branch. Its workflow step runs the same
   `scripts/bash/shell-qc.sh` script on a Linux runner with `bats` and `kcov` installed. CI
   is canonical where a local result and a CI result disagree.

Toolchain context: `bats` is invoked locally elsewhere in this plan as `npx --yes bats`,
reporting `Bats 1.13.0`; `shfmt` v3.12.0 and `shellcheck` 0.11.0 are on the Windows PATH;
`kcov` has no local route, so every TAP-plus-coverage figure comes from CI.

## Recorded Values

- TAP plan line: `1..290`
- Lines beginning `not ok`: 0
- Coverage headline: `Bash coverage (lines): 93.6%`

## Comparison Against the Phase 0 Baseline

| Measure | [P0-T6] baseline | This run | Verdict |
|---|---|---|---|
| TAP plan count | 290 | 290 | equal |
| `not ok` lines | 0 | 0 | equal |
| Line coverage | 93.6% | 93.6% | equal |

Output Summary: The run exited **0** with a TAP plan count of **290** and **no line
beginning `not ok`**. That count **equals the Phase 0 baseline count of 290** recorded in
[P0-T6], which is this task's stated acceptance: the Phase 1 fixture additions added no test
case and changed no existing behavior. Coverage is unchanged at 93.6 percent, which is
consistent with a fixture-only change. This run precedes the red window that Phase 2 opens.

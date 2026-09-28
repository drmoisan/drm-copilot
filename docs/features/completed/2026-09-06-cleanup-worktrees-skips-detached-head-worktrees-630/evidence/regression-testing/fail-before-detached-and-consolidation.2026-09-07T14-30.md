# Fail-Before — Detached Classification and Consolidation Guard (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P2-T20] [expect-fail]

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`

EXIT_CODE: 1

ExpectedExitCode: 1

Run URL: <https://github.com/drmoisan/drm-copilot/actions/runs/34116433495>

Run conclusion: failure — this is the expected outcome for this task.

Tree under test: the feature branch at commit `669e5b88` — Phases 1 and 2 only. The
production library `scripts/bash/cleanup_worktrees_detached_lib.sh` is absent at this
commit, and the consolidation tip-equality pre-check has not been added.

## Command Substitution

The plan's [P2-T20] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bash scripts/bash/shell-qc.sh test'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree for this run is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard, and `bats` and `kcov` are not installed locally. The full suite
   was run through the CI fallback workflow `.github/workflows/_shell-coverage.yml`,
   dispatched with `gh workflow run` against the feature branch at the Phase 2 commit. Its
   workflow step runs the same `scripts/bash/shell-qc.sh` script on a Linux runner. CI is
   canonical where a local result and a CI result disagree.

Toolchain context: `bats` is invoked locally elsewhere in this plan as `npx --yes bats`,
reporting `Bats 1.13.0`; `shfmt` v3.12.0 and `shellcheck` 0.11.0 are on the Windows PATH;
`kcov` has no local route, so every TAP-plus-coverage figure comes from CI.

## Recorded Values

- TAP plan line: `1..308` — the Phase 0 baseline of 290 plus the 18 cases added by [P2-T2]
  through [P2-T19].
- Lines beginning `not ok`: exactly **18**.
- Coverage headline: **none printed**. The run failed before reaching the coverage stage, so
  no line beginning `Bash coverage (lines):` was emitted. This is stated explicitly rather
  than recorded as a missing value.

## The 18 Failing Cases, Verbatim and in CI Report Order

```
not ok 205 --help documents the detached worktree record
not ok 218 a zero-commit consolidation branch is never deleted
not ok 219 verify_consolidation_merged returns NOT_ANCESTOR on tip equality
not ok 220 verify_consolidation_merged fails closed on an empty rev-parse
not ok 221 report emits one detached record with MERGED_CLEAN
not ok 222 report emits NOT_MERGED for an unmerged detached HEAD
not ok 223 is_detached_candidate flag matrix
not ok 224 branch-backed worktree records keep the four-field shape
not ok 225 apply removes a merged detached worktree without force
not ok 226 apply never touches an unmerged detached worktree
not ok 227 dirty detached worktree blocks with DIRTY lines
not ok 228 locked detached worktree yields BLOCKED-LOCKED and invokes no removal
not ok 229 prunable detached worktree is report-only
not ok 230 the caller's own detached worktree is PROTECTED_CURRENT
not ok 231 a hard git failure maps to ANCESTRY_ERROR with no removal
not ok 232 classify_detached_head returns MERGED_CLEAN for an ancestor HEAD
not ok 233 classify_detached_head returns 2 on a hard failure
not ok 234 reverify_detached_delete_eligible blocks on a flipped verdict
```

## Attribution of Each Failing Case to Its Adding Task

| Group | Count | Cases | Adding tasks |
|---|---|---|---|
| CLI suite | 1 | case 205 | [P2-T19] |
| Deletion suite | 3 | cases 218, 219, 220 | [P2-T16], [P2-T17], [P2-T18] |
| Detached suite | 14 | cases 221 through 234 | [P2-T2] through [P2-T15] |

1 + 3 + 14 = 18, which equals both the count of `not ok` lines and the difference between
this run's plan count of 308 and the Phase 0 baseline of 290.

Output Summary: The full suite exited **1**, the expected outcome for this `[expect-fail]`
task, with a TAP plan of **`1..308`** and **exactly 18** lines beginning `not ok`. Every
`not ok` case is named verbatim above. **All 14 detached-suite cases, all 3 deletion-suite
cases, and the 1 CLI case added by [P2-T2] through [P2-T19] are among them**, and the
attribution table accounts for all 18 with no remainder. **No pre-existing case failed**:
the 290 baseline cases all reported `ok`, and 308 minus 18 equals the 290 that passed. This
is the fail-before state for AC1 through AC19 and AC22. No coverage headline was printed
because the run failed before the coverage stage was reached.

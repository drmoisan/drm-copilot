# Pass-After — Detached Suite in Isolation (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P4-T9]

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P4-T9] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bats tests/shell/test_cleanup_worktrees_detached.bats'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard, and `bats` is not on the Windows PATH. `bats` was run locally
   as `npx --yes bats <target>`, which reports **Bats 1.13.0** — the same version the plan's
   WSL wrapper would have used. The target file argument is unchanged.

Toolchain context: `shfmt` v3.12.0 and `shellcheck` 0.11.0 are on the Windows PATH, so
`scripts/bash/shell-qc.sh check` and `format` run natively. `kcov` has no local route, so
every TAP-plus-coverage figure in this feature's evidence comes from the CI fallback
workflow `.github/workflows/_shell-coverage.yml`. This task asserts no coverage figure, so
no CI dispatch was required for it. CI is canonical where a local result and a CI result
disagree.

## TAP Output

TAP plan line: `1..14`

```
ok 1 report emits one detached record with MERGED_CLEAN
ok 2 report emits NOT_MERGED for an unmerged detached HEAD
ok 3 is_detached_candidate flag matrix
ok 4 branch-backed worktree records keep the four-field shape
ok 5 apply removes a merged detached worktree without force
ok 6 apply never touches an unmerged detached worktree
ok 7 dirty detached worktree blocks with DIRTY lines
ok 8 locked detached worktree yields BLOCKED-LOCKED and invokes no removal
ok 9 prunable detached worktree is report-only
ok 10 the caller's own detached worktree is PROTECTED_CURRENT
ok 11 a hard git failure maps to ANCESTRY_ERROR with no removal
ok 12 classify_detached_head returns MERGED_CLEAN for an ancestor HEAD
ok 13 classify_detached_head returns 2 on a hard failure
ok 14 reverify_detached_delete_eligible blocks on a flipped verdict
```

Output Summary: The detached suite exited **0** with a TAP plan of **`1..14`**, **14 `ok`
lines**, and **no line beginning `not ok`**. All 14 case names are reproduced verbatim above
in TAP order. These are the same 14 cases recorded as `not ok` in the [P2-T20] fail-before
artifact (cases 221 through 234 of that run), so the fail-before / pass-after pair is
complete for them. This is the pass-after evidence for AC1, AC2, AC3, AC4, AC7, AC8, AC9,
AC10, AC11, AC12, AC13, AC14, and AC15.

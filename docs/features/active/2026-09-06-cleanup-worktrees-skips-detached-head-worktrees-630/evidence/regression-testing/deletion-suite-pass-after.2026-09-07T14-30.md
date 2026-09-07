# Pass-After — Deletion Suite in Isolation (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P5-T2]

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_deletion.bats`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P5-T2] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bats tests/shell/test_cleanup_worktrees_deletion.bats'
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
every TAP-plus-coverage figure comes from the CI fallback workflow
`.github/workflows/_shell-coverage.yml`; this task asserts no coverage figure. CI is
canonical where a local result and a CI result disagree.

## TAP Output

TAP plan line: `1..9`

```
ok 1 a dirty worktree blocks removal, reports DIRTY lines, and never forces
ok 2 a candidate whose re-verification flips is blocked before any branch delete
ok 3 worktree removal is invoked strictly before branch deletion
ok 4 a merged branch with no worktree gets only a branch delete
ok 5 non-eligible states produce no destructive argv
ok 6 consolidated-content branch deletion is gated on the merge check
ok 7 a zero-commit consolidation branch is never deleted
ok 8 verify_consolidation_merged returns NOT_ANCESTOR on tip equality
ok 9 verify_consolidation_merged fails closed on an empty rev-parse
```

## The Pre-Existing Regression Guard

The pre-existing case named in this task's acceptance —
**`consolidated-content branch deletion is gated on the merge check`** — is reported
**`ok` as case 6**. That case is the Trap 1 regression guard: it was green before this
feature and had to stay green after the tip-equality pre-check was added. Its passing state
is the evidence that the two halves of the Trap 1 mitigation worked together: [P1-T9] added
`rev-parse.main.out` and `rev-parse.documentationandmemories.out` to the
`deletion/consolidated_merged/` fixture with distinct values, and [P5-T1] made an empty or
unresolvable `rev-parse` a hard failure rather than an equality match. Without either half,
this case would have failed.

Output Summary: The deletion suite exited **0** with a TAP plan of **`1..9`**, nine `ok`
lines, and **no line beginning `not ok`**. The **pre-existing case
`consolidated-content branch deletion is gated on the merge check` is reported `ok`**
(case 6). Cases 7, 8, and 9 are the three cases added by [P2-T16] through [P2-T18]; they
were reported `not ok 218`, `not ok 219`, and `not ok 220` in the [P2-T20] fail-before run
and are reported `ok` here, completing those pairs. The other five pre-existing cases are
unchanged and still pass. This is the pass-after evidence for AC16, AC17, and AC18.

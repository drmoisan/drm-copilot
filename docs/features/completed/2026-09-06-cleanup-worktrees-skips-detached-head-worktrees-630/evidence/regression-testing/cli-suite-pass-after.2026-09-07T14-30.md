# Pass-After — CLI Suite in Isolation (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P4-T10]

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P4-T10] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && bats tests/shell/test_cleanup_worktrees_cli.bats'
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

TAP plan line: `1..6`

```
ok 1 --help prints usage and exits 0
ok 2 an unknown argument prints usage to stderr and exits 2
ok 3 default report mode emits classification lines and performs no mutation
ok 4 apply mode emits ACTION lines and destructive argv only for eligible states
ok 5 sourcing the wrapper does not execute main (source-guard)
ok 6 --help documents the detached worktree record
```

## Report-Lines Paragraph Printed by the Help Output

Reproduced verbatim from `scripts/bash/cleanup-worktrees.sh --help`, so the documented
record shape is auditable without a wrap-fragile search:

```
Report lines (pipe-delimited, LC_ALL=C ordered): BRANCH|<name>|<state>;
COMMIT|<branch>|<sha>|<state>|<paths>|<author>|<date>;
WORKTREE|<path>|<branch>|<flags> for a branch-backed worktree registration;
WORKTREE|<path>|DETACHED|<state>|<flags> for a detached-HEAD worktree registration,
which is classified on its own HEAD SHA and whose fifth field preserves the porcelain
locked and prunable markers; WARN|main-divergence|<local>|<origin>;
DIRTY|<path>|<status>; ACTION|<verb>|<target>|<result> (apply mode).

Branch and detached-worktree states: MERGED_CLEAN, MERGED_CONTENT_NEUTRAL,
MERGED_EQUIVALENT, NOT_MERGED, HAS_UNIQUE_RESIDUALS, PROTECTED_CURRENT, and
ANCESTRY_ERROR. The first three are the delete-eligible allowlist; ANCESTRY_ERROR is a
hard git failure and never unlocks a destructive action.
```

Output Summary: The CLI suite exited **0** with a TAP plan of **`1..6`**, six `ok` lines,
and **no line beginning `not ok`**. Case 6, `--help documents the detached worktree
record`, is the case added by [P2-T19]; it was reported `not ok 205` in the [P2-T20]
fail-before run and is reported `ok` here, completing that pair. The report-lines paragraph
printed by the help output is reproduced verbatim above: it names both worktree record
shapes and all seven state tokens, including `ANCESTRY_ERROR`. The five pre-existing CLI
cases are unchanged and still pass. This is the pass-after evidence for AC6 and AC22.

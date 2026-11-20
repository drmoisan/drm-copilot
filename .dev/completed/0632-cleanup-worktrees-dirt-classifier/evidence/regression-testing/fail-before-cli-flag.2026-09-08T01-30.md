# P3-T7 [expect-fail] — CLI suite before the flag exists

Timestamp: 2026-09-08T01-30
Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Commit under test: `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Tree state at capture: `scripts/bash/cleanup-worktrees.sh` carries no `--clear-disposable`
pre-pass, no flag entry in its usage here-doc, and no `DIRTFILE|` or `DIRTSUM|` record
line.

Route: the bash toolchain is denied to the delegated `atomic-executor`, so the orchestrator
executed this gate from its own context per EA-4 and returned the measurement. The plan's
`wsl -d Ubuntu -- bash -lc` form against the preparation worktree is not used, per EA-1.
The full run record is `expect-fail-gates.2026-09-08T02-05.md` in this same folder.

Output Summary: exactly the four tests added by P3-T6 reported `not ok` and every
pre-existing test reported `ok`. The plan's acceptance requires exactly that split; a run
in which a pre-existing test also failed would mean P3-T6 edited more than it was
permitted to.

## The four new tests that reported `not ok`

- test 8 — `--clear-disposable without a mode argument prints usage to stderr and exits 2`
- test 9 — `report --clear-disposable prints usage to stderr and exits 2`
- test 10 — `--apply --clear-disposable and --clear-disposable --apply both dispatch to apply mode`
- test 11 — `--help output documents the new flag and both new record prefixes`

## The seven pre-existing tests that reported `ok`

- test 1 — `--help prints usage and exits 0`
- test 2 — `an unknown argument prints usage to stderr and exits 2`
- test 3 — `default report mode emits classification lines and performs no mutation`
- test 4 — `apply mode emits ACTION lines and destructive argv only for eligible states`
- test 5 — `sourcing the wrapper does not execute main (source-guard)`
- test 6 — `--help documents the detached worktree record`
- test 7 — `--help documents the apply-mode exit-code change for blocked detached removals`

## Recorded plan-to-tree drift

The plan text states five pre-existing tests and nine total, citing declarations at
`tests/shell/test_cleanup_worktrees_cli.bats:16`, `:22`, `:28`, `:41`, and `:53`. The
tracked file carries seven pre-existing tests and eleven total after the addition, with
declarations at `:18`, `:24`, `:30`, `:47`, `:60`, `:72`, and `:83`. The two additional
tests and the line shift were introduced by issue 631, which landed after this plan was
authored. This is locator and count drift, not a design change; the constraint the plan
enforces — that no pre-existing test is edited and the diff shows added lines only — is
applied unchanged to all seven. See `../other/plan-to-tree-drift.2026-09-08T01-30.md`.

The pass-after counterpart is P5-T11, whose acceptance count is correspondingly eleven
rather than the nine the plan text states.

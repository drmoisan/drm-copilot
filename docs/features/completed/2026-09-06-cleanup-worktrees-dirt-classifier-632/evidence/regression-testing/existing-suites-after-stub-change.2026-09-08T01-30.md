# P1-T10 — the five suites Phase 1 does not edit, after the stub-seam extension

Timestamp: 2026-09-08T01-30
Command: `npx --yes bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_consolidation.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_hard_failures.bats`
EXIT_CODE: 0
ExpectedExitCode: 0

Commit under test: `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`

Route: the bash toolchain is denied to the delegated `atomic-executor`, so the orchestrator
executed this gate from its own context per EA-4 and returned the measurement. The plan's
`wsl -d Ubuntu -- bash -lc` form against the preparation worktree is not used, per EA-1.
The full run record is `expect-fail-gates.2026-09-08T02-05.md` in this same folder.

Output Summary: 65 passed, 0 failed, no `not ok` line. The Phase 1 stub-seam extension is
therefore non-regressive against every suite Phase 1 does not edit. The extension consists
of the `GIT_INDEX_FILE` environment log line (P1-T1), the `--no-optional-locks` global
option strip arm (P1-T2), the range-free `rev-list` keying and the non-`--quiet` `diff`
keying (P1-T3, P1-T4), and the new `hash-object`, `log --find-object`, `diff-index`,
`reset` and `clean` subcommand arms (P1-T5 through P1-T9).

Each of those additions is keyed on a subcommand or option the five suites never exercise,
which is the mechanism that makes the extension non-regressive rather than merely observed
to be so on this run.

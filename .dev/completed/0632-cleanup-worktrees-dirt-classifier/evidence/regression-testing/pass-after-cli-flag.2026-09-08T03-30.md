# P5-T11 — CLI suite pass-after the flag is wired

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-28Z (nominal run-timestamp scheme, see the P5-T3 artifact).
Run by: atomic-executor, directly (`npx --yes bats`, bats 1.13.0).

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats`
EXIT_CODE: 0

## 11 ok / 0 not ok

Pre-existing tests (seven):

```
ok 1 --help prints usage and exits 0
ok 2 an unknown argument prints usage to stderr and exits 2
ok 3 default report mode emits classification lines and performs no mutation
ok 4 apply mode emits ACTION lines and destructive argv only for eligible states
ok 5 sourcing the wrapper does not execute main (source-guard)
ok 6 --help documents the detached worktree record
ok 7 --help documents the apply-mode exit-code change for blocked detached removals
```

New tests added by P3-T6 (four):

```
ok 8 --clear-disposable without a mode argument prints usage to stderr and exits 2
ok 9 report --clear-disposable prints usage to stderr and exits 2
ok 10 --apply --clear-disposable and --clear-disposable --apply both dispatch to apply mode
ok 11 --help output documents the new flag and both new record prefixes
```

Tests 8, 9 and 10 are the P5-T8 acceptance set; test 11 is the P5-T7 acceptance test. All four
report `ok`.

## Plan-to-tree drift recorded at this gate

The plan text for P5-T11 states "nine passing tests, naming the five pre-existing and the four
new tests". The measured pre-existing count is seven, not five: `--help documents the detached
worktree record` and `--help documents the apply-mode exit-code change for blocked detached
removals` were added by the sibling detached-worktree work that landed after this plan was
authored. Seven plus four is eleven, which is the count observed. The plan's absolute count is
stale in the same way the counts recorded in `evidence/other/plan-to-tree-drift.2026-09-08T01-30.md`
are stale; the semantic requirement — every pre-existing test still passes and all four new tests
pass — is satisfied and is what this artifact records.

## Known coverage gap recorded at this gate

Test 10 drives the wrapper with `--clear-disposable` against `merged_with_worktree`, which is a
clean worktree. No dirt exists there, so `clear_disposable_dirt` is never reached and the test
asserts dispatch only. No test in this suite observes that the flag pre-pass has any effect on
the clearing path. The gap was identified at the P7-T2 lint gate and is remediated in
`tests/shell/test_cleanup_worktrees_dirt_clear.bats`; see
`evidence/qa-gates/wrapper-clear-flag-mutation.<timestamp>.md`.

Output Summary: `EXIT_CODE: 0`, eleven passing tests, named above.

# Expect-fail and pre-implementation gates (plan tasks P3-T1, P3-T3, P3-T5, P3-T7, P1-T10)

Timestamp: 2026-09-08T02-05
Commit under test: `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Tree state at capture: `scripts/bash/cleanup_worktrees_dirt_lib.sh` does NOT exist. These gates
are strictly order-dependent and are recoverable only in this pre-Phase-4 state.

## Route taken (recorded per EA-1 and EA-4)

The bash toolchain is denied to the delegated `atomic-executor`, so per EA-4 the
orchestrator ran these gates from its own context. The plan's `wsl -d Ubuntu -- bash -lc`
form against the preparation worktree is not used, per EA-1.

Command form: `npx --yes bats <suite...>`
bats version: 1.13.0 (identical to the version the CI runner installs)
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Predictions declared before the run

`atomic-executor` recorded these predictions before any gate was executed, so a mismatch
is informative rather than absorbed. Recorded here verbatim alongside the measurement.

| Gate | Predicted | Measured | Match |
|---|---|---|---|
| P3-T3 classify `[expect-fail]` | exit 1, all 19 `not ok` | exit 1, 1 `ok` / 18 `not ok` | **NO** |
| P3-T5 clear `[expect-fail]` | exit 1, 10 of 11 `not ok`, test 9 passes | exit 1, 1 `ok` (test 9) / 10 `not ok` | yes |
| P3-T7 CLI `[expect-fail]` | exit 1, exactly the 4 new `not ok`, 7 pre-existing `ok` | exit 1, 7 `ok` / 4 `not ok` (tests 8-11) | yes |
| P3-T1 regression (must pass) | exit 0, 11 passing | exit 0, 11 `ok` / 0 `not ok` | yes |
| P1-T10 five suites | exit 0, no `not ok` | exit 0, 65 `ok` / 0 `not ok` | yes |

## P3-T3 — classifier suite `[expect-fail]`

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_classify.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: 18 of 19 tests `not ok`, as required for an expect-fail gate ahead of the
library. One test passed, which is a defect in that test rather than a surprise about the
implementation:

```
ok 12 dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths
```

### Why this pass is a finding

Test 12 asserts only the ABSENCE of lower-rung git reads (`hash-object`,
`diff --quiet main`, `log --find-object`) for the staged paths, which is how it intends to
prove that rung 1 precedes rungs 2 through 5. With no classifier library present, no
classification runs at all, so no lower-rung read is issued and the assertion holds
trivially. The test therefore passes in a state where the behavior it claims to prove does
not exist, and it would continue to pass if the classifier were deleted.

This is the same defect class `atomic-executor` had already identified and repaired twice
in its own work (clearing test 5 and CLI tests 1-2, commit `aa0d619d`): an absence-only
assertion with no positive control. This is a third instance, in a different suite, that
the executor's own pass did not reach.

It is load-bearing rather than cosmetic. Acceptance criterion AC-09 is stated as proving
that rung 1 precedes rungs 2 through 5, and this test is its evidence. A gate that cannot
fail is not evidence for that criterion.

Remediation required before Phase 4 lands: add a positive control asserting that the
`DIRTFILE|` record with verdict `STAGED_TREE_IS_COMMIT` IS emitted for those paths, so the
test fails both when the record is missing and when a lower-rung read is issued.

## P3-T5 — clearing suite `[expect-fail]`

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: 10 of 11 `not ok`. The single pass is
`ok 9 reverify_delete_eligible refuses a non-eligible branch under the unmerged fixture`,
which exercises pre-existing `reverify_delete_eligible` behavior rather than any new
clearing code, exactly as predicted.

## P3-T7 — CLI suite `[expect-fail]`

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: exactly the four new tests fail (8, 9, 10, 11) and all seven pre-existing
tests pass. The failing four are the `--clear-disposable` usage/exit-2 cases, the
argument-order-independence case, and the `--help` documentation case.

## P3-T1 — regression suite (must PASS, not expect-fail)

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
EXIT_CODE: 0

Output Summary: 11 passed, 0 failed. This pins that report-mode and apply-mode output for
the eight existing scenarios plus the two dirty-worktree apply scenarios is byte-identical
to the checked-in expected-output files BEFORE the change, which is what makes a later
difference attributable. Test 11 additionally pins that a worktree with zero status entries
emits neither a `DIRTFILE|` nor a `DIRTSUM|` record.

## P1-T10 — five pre-existing suites after the stub-seam extension

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_consolidation.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_hard_failures.bats`
EXIT_CODE: 0

Output Summary: 65 passed, 0 failed. The Phase 1 stub-seam extension
(`GIT_INDEX_FILE` logging, `--no-optional-locks` stripping, new subcommand arms) did not
regress any existing suite.

## Verdict

Four of five gates match their declared predictions exactly. The one mismatch is a genuine
defect in test 12 of the classifier suite and blocks Phase 4 until a positive control is
added.

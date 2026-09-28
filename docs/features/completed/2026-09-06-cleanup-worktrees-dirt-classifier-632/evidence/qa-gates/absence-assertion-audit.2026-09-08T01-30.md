# Absence-assertion audit — every negative-shaped test in the three new suites

Timestamp: 2026-09-08T01-30
Command: manual read of every `@test` body in the four suites this work creates or edits
EXIT_CODE: 0

Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Suites audited:

- `tests/shell/test_cleanup_worktrees_dirt_classify.bats` (19 tests)
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats` (11 tests)
- `tests/shell/test_cleanup_worktrees_dirt_regression.bats` (11 tests)
- `tests/shell/test_cleanup_worktrees_cli.bats` (4 tests added by P3-T6)

Output Summary: one defective test found and repaired (classifier test 12). Every other
absence-shaped test carries a positive control that fails in the pre-library state, which
the P3-T3, P3-T5 and P3-T7 gate measurements independently confirm.

## The defect class

An assertion that only checks the ABSENCE of something cannot distinguish "the code ran
and correctly did not do X" from "no code ran at all". A test built solely from such
assertions passes in a tree where the feature under test has been deleted, so it is not
evidence for the criterion it is cited against. The remedy is a positive control: an
assertion in the same test body that the expected observable output IS produced, so the
test fails in both directions.

Three instances of this class arose in this feature's test authoring. Two were found and
repaired during authoring and are already in commit `aa0d619d` (clearing test 5 and CLI
tests 8 and 9). The third was found by the P3-T3 gate measurement, recorded in
`../regression-testing/expect-fail-gates.2026-09-08T02-05.md`, and is repaired here.

## Instance 3 — classifier test 12

Test: `dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths`
Criterion it is cited against: AC-09, that rung 1 precedes rungs 2 through 5.

Measured at `aa0d619d`, with no classifier library present:

```
ok 12 dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths
```

The body asserted only that the stub argv log contains no `hash-object`, no
`--find-object`, and no `diff --quiet main --` for either staged path. With no classifier
present no classification runs, so no lower-rung read is issued and all four assertions
hold trivially. The test would also have passed with the classifier deleted outright.

Repair applied: two positive-control assertions were added at the top of the body,
requiring the rung-1 record to be emitted for both staged paths.

```
[[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/a.cs'* ]]
[[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs'* ]]
```

The controls are asserted over `$output` rather than over the filtered `$log`, because the
records are written to stdout while the stub argv log is written to stderr; the negative
assertions continue to read the filtered `$log` so that a path appearing in an emitted
record is not misread as a path named by a git invocation.

The test now fails in both directions: when the rung-1 verdict is not produced, and when a
lower-rung read is issued for a staged path.

Confirmation gate: a re-run of P3-T3 in the still-pre-library state must report all
nineteen tests `not ok`.

## Re-audit of every remaining absence-shaped test

Each row names the assertion of absence and the positive control that sits alongside it in
the same test body. A test whose control is a full record assertion cannot pass while the
classifier is absent, which is what the `not ok` column reports from the gate runs at
`aa0d619d`.

### `test_cleanup_worktrees_dirt_classify.bats`

| # | Test | Asserts absence of | Positive control in the same body | `not ok` at aa0d619d |
|---|---|---|---|---|
| 2 | `dirt_build_artifact: no find-object history walk runs for the classified project file` | `--find-object` | argv log contains a `diff` naming `src/Legacy/Legacy.csproj`, so rung 3's content read did run | yes |
| 5 | `dirt_session_artifact: no git invocation names the session artifact path` | the artifact path in any argv | argv log contains `status --porcelain`, so the classifier did run its one read | yes |
| 7 | `dirt_content_on_main: no find-object history walk runs` | `--find-object` | argv log contains `hash-object` naming `docs/copy.md` and `rev-parse main:docs/copy.md`, so both rung-4 reads did run | yes |
| 11 | `dirt_staged_tree_is_commit: the first rev-list entry is never probed` | `diff-index --cached --quiet dddd9999` | argv log contains `diff-index --cached --quiet eeee7777`, so the probe ran and reached the second entry | yes |
| 12 | `dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths` | `hash-object`, `--find-object`, `diff --quiet main --` per path | **added by this audit** — both `STAGED_TREE_IS_COMMIT` records | **no — repaired** |
| 18 | `dirt_quoted_path: a C-quoted path is UNIQUE and no unquoting is attempted` | the unquoted artifact path in any argv | the body first asserts the `UNIQUE` record and the `HAS_UNIQUE` aggregate are emitted, before it inspects the log | yes |

Tests 1, 3, 4, 6, 8, 9, 10, 13, 14, 16, 17 and 19 are record-shaped: each asserts a
`DIRTFILE|` or `DIRTSUM|` line is present. Their trailing `!=` assertions on near-miss
verdicts are paired with those present-assertions in the same body and are therefore not
absence-only. Test 15 pairs its membership check with `[ "$seen" -eq 17 ]`, which is a
count control against a vacuous empty union.

### `test_cleanup_worktrees_dirt_clear.bats`

| # | Test | Asserts absence of | Positive control in the same body | `not ok` at aa0d619d |
|---|---|---|---|---|
| 3 | `dirt_clear_all_disposable: no force flag and no ignored-file flag reaches git` | `--force`, `-x`, `-X`, `-ff`, `-fdx`, `-fdX` as whole tokens | argv log contains `clean -fd`, so the clearing sequence did run | yes |
| 5 | `dirt_mixed_unique_blocks: a refused clear runs no reset, no clean, and no second worktree remove` | `reset`, `clean`, a second `worktree remove` | the `ACTION\|dirt-clear\|/repo-wt/dirt\|REFUSED-UNIQUE` record, so the hook was reached and refused (added during authoring, instance 1 of this defect class) | yes |
| 7 | `dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal` | a second `worktree remove` | the `FAILED` record, plus argv log contains `clean -fd` | yes |
| 10 | `dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index` | `write-tree`, `stub-git-env`, `/index`, `reset`, `clean`, `worktree remove`, `branch -D`, `hash-object -w` | argv log contains `diff-index --cached --quiet`, so the staged-tree probe did run | yes |

Test 11 opens with `[ -n "$status_reads" ]`, which is a positive control on the set its
ratio assertion is computed over; without it the two `grep -c` values would both be zero
and the equality would hold vacuously. Tests 1, 2, 4, 6, 8 and 9 are record-shaped or
ordinal and assert presence directly.

### `test_cleanup_worktrees_dirt_regression.bats`

Test 11, `report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM
record`, is the only absence-shaped test in this suite. Its control is
`[[ "$output" == *"WORKTREE|/repo-wt/feat|feature-wt|"* ]]`, which requires the registration
whose status read returned nothing to be present in the output. This test is a pin rather
than an expect-fail gate: it passed at `aa0d619d` by design, and its control is what makes
that pass meaningful rather than vacuous. The other ten tests are byte-identity comparisons
against checked-in expected files.

### `test_cleanup_worktrees_cli.bats`

Tests 8 and 9 each assert `[[ "$output" == *"--clear-disposable"* ]]` on the usage text in
addition to the exit code, which distinguishes a deliberate rejection by the new flag
pre-pass from the wrapper's pre-existing unknown-argument arm — that arm produces the same
exit 2 and the same usage text for any unrecognised word, so the exit code alone could not
fail (added during authoring, instance 2 of this defect class). Test 9 additionally asserts
the absence of `stub-git:`, paired with those two presence assertions. Test 10 opens with
`[ -f "${DIRTLIB}" ]` as a precondition guard and then asserts an `ACTION|` record is
present. Test 11 is presence-only.

## Residual limitation

`DIRTLIB` is not yet defined in the `setup` of `tests/shell/test_cleanup_worktrees_cli.bats`,
so test 10's guard currently evaluates `[ -f "" ]` and fails. That is the correct
pre-implementation outcome and it is P5-T1 that defines the variable. The variable name in
that suite must be `DIRTLIB`, not `DLIB`, because `DLIB` already denotes
`cleanup_worktrees_detached_lib.sh` throughout this family of suites.

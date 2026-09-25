# Code Review — cleanup-worktrees-test-suite-blind-spots-660

- Issue: #660
- Branch: `bug/cleanup-worktrees-test-suite-blind-spots-660`
- Base: `origin/main` @ `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Timestamp: 2026-09-25T15-48

## Files Reviewed

| File | Change | Lines |
|---|---|---|
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | +51/-4 | 425 total |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | +34/-0 | 336 total |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | +30/-5 | 416 total |
| `tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/*` (10 files) | new | small fixtures |
| Docs/evidence under `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/` (11 files) | new | markdown, exempt from line limit |

No production file (anything under `scripts/`) is touched. This is a test-only change, as
the issue's "Implementation Intent" states.

## Correctness Review

### AC-1 / AC-2 — `dirt_typechange_delta` scenario and its negative control

`tests/shell/test_cleanup_worktrees_dirt_classify.bats` (new tests, lines 203-243 in the
current file):

- The positive test asserts `DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat` and
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` for the new `MT` fixture, and explicitly asserts the
  absence of `CONTENT_ON_MAIN`/`ALL_DISPOSABLE`.
- The negative control composes a mutated copy of `cleanup_worktrees_dirt_lib.sh` in a
  shell variable (`sed 's/\[MARCTU\]/[MARCU]/g'`), `eval`s it inside a `bash -c` child
  process, and asserts the verdict flips to `CONTENT_ON_MAIN` / `ALL_DISPOSABLE`. It then
  proves the production file was never touched on disk via
  `git diff origin/main -- "${DIRTLIB}"` and `git status --porcelain -- "${DIRTLIB}"`, both
  asserted empty.
- Independently verified: `grep -n "MARCTU" scripts/bash/cleanup_worktrees_dirt_lib.sh`
  returns exactly one line (297), containing the class token twice (once for the index
  column `x`, once for the worktree column `y`). The unanchored global `sed` substitution
  is therefore safe and unambiguous — there is no other occurrence it could corrupt.
- The `Y='T'` / `X='M'` pairing is deliberate and correctly reasoned: a lone `T ` (T paired
  with a space) cannot distinguish the mutation, because the space column already fails
  `[MARCTU]`/`[MARCU]` under both the correct and mutated class, so `bothloc` is `0` either
  way. Pairing `T` with a second content-bearing letter is the only construction that
  makes the class narrowing observable. This reasoning is stated in the research artifact
  and independently confirmed against the production source at line 297.

This is a well-targeted test: it exercises the exact character-class membership the issue
identifies as unpinned, and the negative control is constructed to fail specifically when
that membership regresses, not for an unrelated reason.

### AC-3 — Stub header accuracy

`tests/fixtures/cleanup_worktrees/stub-bin/git`'s header previously asserted "No arm is
defined for any subcommand that writes to the index or the object database" — false, since
an `add)` arm exists (added by a prior, unrelated change referenced in the issue as #637).
The new header replaces the false claim with a table naming every index/object-database
writing arm (`add`, `worktree add`, `worktree remove`, `cherry-pick`, `branch -D`,
`reset --hard`, `clean -fd`), each arm's production call site(s), and which wrapper mode
(`report`/`apply`/`preserve`) reaches each one. This is a comment-only change to a test
fixture; it carries no executable-behavior risk, and it directly closes the "stale header
contradicts the add arm" defect the issue describes.

### AC-4 / AC-5 — Widened non-mutation assertion and its negative control

`tests/shell/test_cleanup_worktrees_dirt_clear.bats`:

- The existing report-mode non-mutation test (lines 205-225) is extended with three new
  negative assertions: `add`, `commit`, `update-index` (in addition to the pre-existing
  `worktree remove`, `branch -D`, `hash-object -w`, and `write-tree` checks). This
  satisfies AC-4's stated requirement of asserting that `add`, `commit`, `write-tree`, and
  `update-index` never appear in the report-mode argv log (`write-tree` was already
  present; the task added the remaining three).
- The negative-control test (lines 227-256) injects a `cleanup_wt_git add -- ...` call
  immediately after `run_report() {` via a `sed` insertion into an in-memory copy of
  `cleanup_worktrees_lib.sh`, and asserts the widened assertion's negation
  (`[[ "$log" == *" add "* ]]`) — i.e., it proves the assertion the test above makes would
  fail if `run_report` regressed to calling `add`.
- **This test has a documented history worth calling out explicitly.** The
  branch's own evidence (`remediation-inputs.2026-09-25T15-13.md` and
  `final-shell-qc-test.2026-09-25T15-08.md`) records that an earlier version of this exact
  test used `>/dev/null 2>&1` on the injected line, which silenced the git stub's stderr
  argv-log echo — the same channel the test's own assertion reads — making the assertion
  fail unconditionally regardless of the mutation. This was caught by the branch's own
  Phase 2 final-QC run (a real `not ok` at test 297), diagnosed correctly as a plan defect
  rather than an execution error, and corrected in commit `dd32bf0e` by narrowing the
  redirect to `>/dev/null` (stdout only). The corrected test was re-run and passed
  (`final-shell-qc-test.2026-09-25T15-37.md`, test 297 `ok`). This is a good example of
  the "adversarial verification of test fixtures" practice — the negative control caught
  its own bug before merge, rather than being trusted on inspection alone.
- Independently re-read the corrected test body on disk: the injected line now reads
  `cleanup_wt_git add -- test-negative-control >/dev/null || true` (single redirect,
  stdout only). The stub's invocation echo is `printf 'stub-git: %s\n' "$*" >&2` (stderr),
  confirmed at `tests/fixtures/cleanup_worktrees/stub-bin/git:107`. With only stdout
  redirected, the stderr echo now reaches bats' merged `$output`, so the test's own
  `grep '^stub-git'` observation channel is intact. The fix is correct as applied.

### AC-6 / AC-7 — Scope and toolchain

- Re-derived directly (not merely trusted from the recorded evidence):
  `git diff origin/main --name-status -- scripts/` and
  `git status --porcelain -- scripts/` both produced empty output. AC-6 holds.
- Re-ran `sh scripts/bash/shell-qc.sh check` directly: exit 0, no output. Matches the
  recorded final-QC evidence.
- The full `npx --yes bats tests/shell` re-run did not complete within this review's
  session window (see `policy-audit.2026-09-25T15-48.md`, "Toolchain Verification"); the
  branch's own recorded evidence (`final-shell-qc-test.2026-09-25T15-37.md`) documents
  `EXIT_CODE: 0`, `1..463`, 463 `ok`, 0 `not ok`, and quotes all three new tests' exact `ok`
  lines by TAP line number.

## Best-Practice Observations (non-blocking)

- **Comment density and self-documentation are high and consistently applied.** Both
  modified `.bats` files carry inline comments explaining *why* an assertion is structured
  the way it is (e.g., the "positive control" comments that guard against a vacuously
  true negative assertion, and the ordinal-position rationale in
  `test_cleanup_worktrees_dirt_clear.bats`'s file-level comment block). This matches the
  project's existing convention in these files and improves long-term maintainability of
  fixture-driven bats suites, where a reader cannot infer intent from the production code
  alone.
- **The two negative-control tests both prove non-mutation of the production file they
  patch in memory**, via a `git diff`/`git status --porcelain` pair scoped to the single
  file under test. This is a stronger guarantee than asserting the test passed; it
  directly demonstrates the "no temporary files, no on-disk mutation" property the general
  unit test policy requires for the mutation-testing style used here.
- **The stub header rewrite (AC-3) is now the single source of truth for which git
  subcommand arms exist and why**, replacing a comment that had silently gone stale after
  an unrelated PR (#637) added the `add` arm outside any conflict region. Centralizing this
  in the stub's own header, rather than in a separate design doc, keeps the documentation
  next to the code most likely to change it next.
- **Minor, non-blocking:** the P1-T6 negative-control test's inline comment
  (`test_cleanup_worktrees_dirt_clear.bats:243-246`) quotes the AC-4 assertion literally
  for cross-reference. This is intentional per the plan (P1-T5's acceptance condition was
  written to expect exactly two occurrences of that literal string once P1-T6 landed) and
  is correctly reflected in the final file; flagging only so a future editor does not
  "clean up" the duplicate literal without checking the plan's stated acceptance condition
  first.

## Findings Requiring Remediation

None. No Blocking or Major finding was identified in this review.

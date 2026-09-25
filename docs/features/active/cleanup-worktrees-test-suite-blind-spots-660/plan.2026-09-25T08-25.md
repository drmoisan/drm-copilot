# cleanup-worktrees-test-suite-blind-spots (Plan)

- **Issue:** #660
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T08-25
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit

**Requirements source (sole AC source, minor-audit):** `issue.md`, section `## Acceptance
Criteria` (AC-1 through AC-7). `spec.md` and `user-story.md` are not required and are not
present in this feature folder; their absence is not a blocker under minor-audit.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact
tasks, and coverage-comparison tasks for each in-scope language when policy requires
coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact
is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each
evidence-producing task. Do not mark evidence-backed work complete without the artifact.

**Coverage applicability (bash/kcov).** This change is test-only: every task in Phase 1
touches only `tests/shell/*.bats` or `tests/fixtures/cleanup_worktrees/**`. AC-6 requires,
and Phase 2 task P2-T3 mechanically proves via an `origin/main`-anchored diff, that no path
under `scripts/` changes. kcov's include pattern is `tools/`, `scripts/`, and
`.claude/lib/bash/` (`.claude/rules/shell.md`, "Coverage Expectations"), and
`.claude/rules/general-unit-test.md` requires only that "Code changes or refactors must not
reduce coverage for the lines that were changed." With zero changed production lines
(structurally guaranteed by AC-6 and proven by P2-T3's diff), the changed-line coverage
obligation is satisfied vacuously and a repo-wide `kcov` percentage is a strictly weaker,
noisier proxy for the same fact the P2-T3 diff already proves directly. Per research
`docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/research/research.2026-09-25T12-30.md`
§6, kcov is CI-built from source and is not confirmed available in this Windows worktree;
this plan does not add a local `shell-qc.sh test --coverage` task, and instead relies on
the P2-T3 diff as the coverage-regression proof and on CI
(`.github/workflows/_shell-coverage.yml`) as the confirming gate. This is a documented
scope decision, not a skipped obligation.

**Command-route note.** `.claude/settings.json`'s `Bash` allowlist covers `git *`,
`poetry run *`, `pwsh *`, and three specific `.claude/lib/bash/*.sh` scripts; it does not
explicitly list `sh scripts/bash/shell-qc.sh ...`. Every task below therefore names an
`npx`-based route where one exists (bats is published to npm as `bats`, and
`find_bats_test_dirs()` in `scripts/bash/shell_qc_lib.sh` resolves only `tests/shell` in
this tree — `tests/bash` does not exist — so `npx --yes bats tests/shell` is functionally
identical to what the wrapper's `test` stage runs) and names `sh scripts/bash/shell-qc.sh
check` for the check stage, for which no `npx`/`git`/`poetry` equivalent exists. If a task's
named command is blocked by the executing agent's own tool permissions, or if `shfmt` or
`shellcheck` is not resolved on this Windows worktree (`run_check()` returns `127` in that
case — a genuine, honestly-observed environment gap, not a test failure), the task text
below explicitly authorizes recording that outcome honestly (command attempted, the real
`EXIT_CODE` and message as observed) and relying on CI (`.github/workflows/_build-check.yml`,
`.github/workflows/_shell-coverage.yml`) as the confirming gate, per issue.md's own
"Dependencies / Risks" section. This is an authorized substitution, not `EXIT_CODE:
SKIPPED`: the command must still be attempted and its real, observed outcome recorded. This
fallback applies only to the check-stage command (P0-T6, P2-T1); `run_test()` degrades
silently on a missing `bats` (see the next paragraph), so the test-stage tasks (P0-T7,
P2-T2) require the additional TAP-observation checks below rather than a tool-missing
fallback.

**`run_test()` silent-no-op hazard (independently verified against
`scripts/bash/shell_qc_lib.sh` lines 226-254, 236, 241).** When `bats` is not resolved,
`run_test()` prints the literal line `bats not installed; skipping shell tests.` and
returns `0` — a vacuous pass that runs zero tests. Every test-stage acceptance condition
below therefore requires observing the bats TAP output (`1..N` header, `ok`/`not ok`
lines) and confirming the literal string `bats not installed; skipping shell tests.` is
ABSENT from the captured output, not merely `EXIT_CODE: 0`. `run_check()`
(`scripts/bash/shell_qc_lib.sh` lines 164-202) does not have this hazard: a missing
`shfmt`/`shellcheck` returns `127`, a real failure, not a silent pass.

---

### Phase 0 — Context & Inputs

- [x] [P0-T1] Read `CLAUDE.md` in full (policy-compliance reading order, position 1).
  Acceptance: the file's "Policy Compliance Reading Order" and "Architecture" sections
  have been read; no file edit in this task.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full (position 2). Acceptance:
  the file's "Mandatory Toolchain Loop" and "File Size Limit" sections have been read; no
  file edit in this task.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full (position 3). Acceptance:
  the file's "Coverage Requirements," "External Dependencies" (temporary-file prohibition),
  and "Test File Location" sections have been read; no file edit in this task.
- [x] [P0-T4] Read `.claude/rules/shell.md` in full (language-specific, bash is the sole
  language in scope). Acceptance: the file's "Toolchain," "Discovery Contract," and
  "Coverage Expectations" sections have been read; no file edit in this task.
- [x] [P0-T5] Write `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/baseline/phase0-instructions-read.md`
  containing at minimum: `Timestamp: <ISO-8601, yyyy-MM-ddTHH-mm>`, `Policy Order: CLAUDE.md,
  .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md,
  .claude/rules/shell.md`, and the explicit list of the four files read in P0-T1 through
  P0-T4. Acceptance: the file exists at this exact path and contains all four required
  fields/lines.
- [x] [P0-T6] Run the baseline check-stage command `sh scripts/bash/shell-qc.sh check`
  (see "Command-route note" above for the permission-blocked or tool-missing fallback). Write
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/baseline/baseline-shell-qc-check.<ISO-8601 timestamp>.md`
  with `Timestamp:`, `Command: sh scripts/bash/shell-qc.sh check`, `EXIT_CODE:`, and
  `Output Summary:` recording whether `shfmt -d` and `shellcheck` reported any diagnostic
  lines (an empty diagnostic output plus `EXIT_CODE: 0` is a clean baseline; a nonzero
  `EXIT_CODE` or any diagnostic line must be recorded verbatim in the summary and is a
  pre-existing condition unrelated to this feature's own changes, none of which sit under
  `scripts/`, `tools/`, or `.claude/lib/bash/`). Acceptance: the artifact exists with all
  four required fields.
- [x] [P0-T7] Run the baseline test-stage command `npx --yes bats tests/shell` (or
  `sh scripts/bash/shell-qc.sh test` if the executor's tool permissions allow it; see
  "Command-route note"). Write
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/baseline/baseline-shell-qc-test.<ISO-8601 timestamp>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the TAP
  `1..N` header's `N` value (call this `N_baseline`) and confirming zero `not ok` lines and
  the ABSENCE of the literal string `bats not installed; skipping shell tests.` in the
  captured output (per the "silent-no-op hazard" note above; its presence means zero tests
  ran and the artifact must record that as a blocking baseline-capture failure, not as a
  pass). Acceptance: the artifact exists with all four required fields and a recorded
  `N_baseline` value.

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Create the fixture scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/` with exactly these 10
  files:
  - **Copy byte-for-byte** from
    `tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta/` (shared
    repo-shape baseline, reused verbatim per that directory's existing convention):
    `for-each-ref.out`, `merge-base.feature-dirt.rc`, `rev-parse.abbrev-ref-HEAD.out`,
    `rev-parse.show-toplevel.out`, `worktree-list.out`, `worktree-remove.rc`.
  - **Create new** with this exact content:
    - `status._repo-wt_dirt.out`: `MT src/typechange.dat\n`
    - `diff-quiet..src_typechange.dat.rc`: `0\n`
    - `rev-parse.verify.main_src_typechange.dat.rc`: `0\n`
    - `hash-object.src_typechange.dat.out`: `abcd1234\n`

  Key derivation (re-derived directly against
  `tests/fixtures/cleanup_worktrees/stub-bin/git`, not carried from research): the
  `diff --quiet main -- src/typechange.dat` call (stub lines 233-268) yields `spec=""`
  (no `..`/`...` token) and `path="src/typechange.dat"`, so its key is
  `diff-quiet.$(sanitize "").$(sanitize "src/typechange.dat")` =
  `diff-quiet..src_typechange.dat`, matching the double-dot filename above and the sibling
  fixture `dirt_index_and_worktree_delta/diff-quiet..src_a.cs.rc`. The
  `rev-parse --verify --quiet "main:src/typechange.dat"` call (stub lines 294-303) yields
  key `rev-parse.verify.$(sanitize "main:src/typechange.dat")` =
  `rev-parse.verify.main_src_typechange.dat` (`:` and `/` both sanitize to `_`).

  Acceptance: `find tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta -type f | wc -l`
  prints `10`; `cat tests/fixtures/cleanup_worktrees/scenarios/dirt_typechange_delta/status._repo-wt_dirt.out`
  prints exactly `MT src/typechange.dat`; a `diff` of each of the six copied files against
  its `dirt_index_and_worktree_delta` counterpart is empty.

- [x] [P1-T2] In `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, insert one new
  `@test` block immediately after the existing `dirt_unique` test's closing `}` (the block
  ending `[[ "$output" != *"ALL_DISPOSABLE"* ]]\n}` at the current line 201) and before the
  `dirt_classifier_read_error` test (current line 203). Anchor `old_string` on:
  ```
      [[ "$output" != *"CONTENT_ON_MAIN"* ]]
      [[ "$output" != *"CONTENT_IN_HISTORY"* ]]
      [[ "$output" != *"ALL_DISPOSABLE"* ]]
  }

  @test "dirt_classifier_read_error: a non-zero classifier read yields UNIQUE and HAS_UNIQUE" {
  ```
  Insert this exact new test between the closing `}` and the next `@test` line:
  ```bash
  @test "dirt_typechange_delta: an MT entry whose working-tree content is on main is UNIQUE" {
      dirt dirt_typechange_delta
      [ "$status" -eq 0 ]
      [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MT|src/typechange.dat'* ]]
      [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
      # Near-miss control: under the checked-in [MARCTU] class, T is content-bearing, so
      # bothloc=1 suppresses CONTENT_ON_MAIN at rung 4 even though the working-tree blob
      # equals main's blob at this path. The negative-control test below shows the
      # mutation that removes this suppression.
      [[ "$output" != *"CONTENT_ON_MAIN"* ]]
      [[ "$output" != *"ALL_DISPOSABLE"* ]]
  }
  ```
  Acceptance (named test): after Phase 2's `npx --yes bats tests/shell` run, the captured
  TAP output contains the single-line token
  `dirt_typechange_delta: an MT entry whose working-tree content is on main is UNIQUE`
  on an `ok` line and on no `not ok` line. AC-1.

- [x] [P1-T3] In `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, insert one further
  new `@test` immediately after the P1-T2 test's closing `}` (still before
  `dirt_classifier_read_error`). Insert this exact test:
  ```bash
  @test "dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)" {
      local mutated
      mutated="$(sed 's/\[MARCTU\]/[MARCU]/g' "${DIRTLIB}")"
      run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/dirt_typechange_delta" \
          bash -c '
              lib=$(cat)
              source "$1"
              source "$2"
              eval "$lib"
              classify_worktree_dirt "$3" 2>/dev/null
          ' _ "${ELIB}" "${LIB}" "${WT}" <<<"$mutated"
      [ "$status" -eq 0 ]
      # Under the mutation, T no longer matches the content-bearing class, so bothloc is 0
      # and rung 4 prints CONTENT_ON_MAIN instead of falling through to UNIQUE: the
      # positive-direction assertions in the test above would fail against this mutated
      # library.
      [[ "$output" == *'DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MT|src/typechange.dat'* ]]
      [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|'* ]]
      [[ "$output" != *"UNIQUE"* ]]
      [[ "$output" != *"HAS_UNIQUE"* ]]
      # The mutated source was composed into a shell variable and evaluated in a child
      # process; the production file on disk was never opened for writing.
      run git -C "${REPO_ROOT}" diff origin/main -- "${DIRTLIB}"
      [ "$status" -eq 0 ]
      [ -z "$output" ]
      run git -C "${REPO_ROOT}" status --porcelain -- "${DIRTLIB}"
      [ "$status" -eq 0 ]
      [ -z "$output" ]
  }
  ```
  `DIRTLIB`, `ELIB`, `LIB`, `STUB`, `SCEN`, `WT`, and `REPO_ROOT` are all already defined by
  this file's existing `setup()` (current lines 27-36); no setup change is required. The
  single occurrence of the literal `[MARCTU]` in `scripts/bash/cleanup_worktrees_dirt_lib.sh`
  (confirmed by direct search: line 297 only, no other match in the file) makes the
  unanchored global `sed` substitution safe and unambiguous.
  Acceptance (named test): after Phase 2's test run, the TAP output contains the single-line
  token `dirt_typechange_delta: mutating [MARCTU] to [MARCU] changes the verdict away from UNIQUE (negative control)`
  on an `ok` line. AC-2.

- [x] [P1-T4] In `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, update the
  "every verdict emitted..." test's hardcoded scenario list and record count (current lines
  214-257) in two places:
  1. In the `for s in ...` token list, change the line reading
     `        dirt_tracked_staged_only_blob dirt_unique; do`
     to
     `        dirt_tracked_staged_only_blob dirt_typechange_delta dirt_unique; do`
     (alphabetically between `dirt_tracked_staged_only_blob` and `dirt_unique`).
  2. Change the comment-and-assertion pair
     ```
         # The union must be exactly the thirty-eight records these scenarios produce:
         # twenty-nine scenarios, of which six carry two status entries each and one carries
         # four. Without this count the membership check would pass vacuously over an empty
         # union.
         [ "$seen" -eq 38 ]
     ```
     to
     ```
         # The union must be exactly the thirty-nine records these scenarios produce:
         # thirty scenarios, of which six carry two status entries each and one carries
         # four. Without this count the membership check would pass vacuously over an empty
         # union.
         [ "$seen" -eq 39 ]
     ```
  Independently re-counted (via `Glob` over
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_*/status._repo-wt_dirt.out`): 29
  directories exist before this task; P1-T1 adds one one-entry scenario, so the post-task
  count is 30 directories / 39 records (29 base scenarios + 6 with one extra entry + 1 with
  three extra entries + 1 new one-entry scenario = 30 scenarios, 38 + 1 = 39 records).
  Acceptance: `grep -F 'dirt_typechange_delta dirt_unique; do' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  and `grep -F '[ "$seen" -eq 39 ]' tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  each return exactly one match. AC-1 (list-coupling correctness).

- [x] [P1-T5] In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, extend the existing
  test `"dirt_staged_tree_is_commit: report mode issues no mutating git command and
  redirects no index"` (current lines 205-222). Anchor `old_string` on:
  ```
      [[ "$log" != *"worktree remove"* ]]
      [[ "$log" != *"branch -D"* ]]
      [[ "$log" != *"hash-object -w"* ]]
  }
  ```
  Replace with:
  ```
      [[ "$log" != *"worktree remove"* ]]
      [[ "$log" != *"branch -D"* ]]
      [[ "$log" != *"hash-object -w"* ]]
      [[ "$log" != *" add "* ]]
      [[ "$log" != *" commit "* ]]
      [[ "$log" != *"update-index"* ]]
  }
  ```
  `write-tree` is already present in this test (line 211) and is unchanged; only `add`,
  `commit`, and `update-index` are newly asserted absent, per AC-4's stated denylist.
  Acceptance: `grep -F '[[ "$log" != *" add "* ]]' tests/shell/test_cleanup_worktrees_dirt_clear.bats`,
  `grep -F '[[ "$log" != *" commit "* ]]' tests/shell/test_cleanup_worktrees_dirt_clear.bats`,
  and `grep -F '[[ "$log" != *"update-index"* ]]' tests/shell/test_cleanup_worktrees_dirt_clear.bats`
  each return exactly one match. AC-4.

- [x] [P1-T6] In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, insert one new
  `@test` immediately after the P1-T5-extended test's closing `}` and before the next test
  `"dirt_staged_tree_is_commit: the cached diff-index probe runs..."` (current line 224).
  Insert this exact test:
  ```bash
  @test "dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)" {
      local mutated
      mutated="$(sed '/^run_report() {$/a\
  	cleanup_wt_git add -- test-negative-control >/dev/null 2>&1 || true' "${LIB}")"
      run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
          CLEANUP_WT_STUB_SCENARIO="${SCEN}/dirt_staged_tree_is_commit" \
          bash -c '
              lib=$(cat)
              source "$1"
              eval "$lib"
              source "$2"
              source "$3"
              source "$4"
              run_report
          ' _ "${ELIB}" "${RLIB}" "${DLIB}" "${DIRTLIB}" <<<"$mutated"
      log="$(printf '%s\n' "$output" | grep '^stub-git' || true)"
      # The injected call reaches the argv log, so the widened AC-4 assertion
      # ([[ "$log" != *" add "* ]], asserted in the test above against the real library)
      # would fail here: this line is that same assertion's negation, over the mutated
      # library.
      [[ "$log" == *" add "* ]]
      # The mutated source was composed into a shell variable and evaluated in a child
      # process; the production file on disk was never opened for writing.
      run git -C "${REPO_ROOT}" diff origin/main -- "${LIB}"
      [ "$status" -eq 0 ]
      [ -z "$output" ]
      run git -C "${REPO_ROOT}" status --porcelain -- "${LIB}"
      [ "$status" -eq 0 ]
      [ -z "$output" ]
  }
  ```
  `ELIB`, `LIB`, `RLIB`, `DLIB`, `DIRTLIB`, `STUB`, `SCAN`, `SCEN`, and `REPO_ROOT` are all
  already defined by this file's existing `setup()` (current lines 51-61); the sourcing
  order (`ELIB`, then the mutated `LIB` text, then `RLIB`, `DLIB`, `DIRTLIB`, then
  `run_report`) matches the existing `report_run()` helper's order (current lines 73-77)
  with `LIB` eval'd instead of sourced from disk. `run_report()`'s definition (confirmed at
  `scripts/bash/cleanup_worktrees_lib.sh:452`) is the sole match for
  `/^run_report() {$/` in that file, so the `sed` address is unambiguous.
  Acceptance (named test): after Phase 2's test run, the TAP output contains the single-line
  token
  `dirt_staged_tree_is_commit: injecting a git add call into run_report makes the widened non-mutation assertion fail (negative control)`
  on an `ok` line. AC-5.

- [x] [P1-T7] In `tests/fixtures/cleanup_worktrees/stub-bin/git`, replace the false
  "no writing arm is defined" paragraph (current lines 68-73) with an accurate table of
  every index/object-database-writing arm, its production call site(s), and the mode that
  reaches each. Anchor `old_string` on:
  ```
  # No arm is defined for any subcommand that writes to the index or the object database.
  # The dirt classifier must reach its staged-tree answer by reading only, so defining
  # such an arm would make the report-mode non-mutation assertion unable to fail. The
  # assertion in tests/shell/test_cleanup_worktrees_dirt_clear.bats searches this file's
  # argv log for those subcommand names; adding one here would defeat it.
  #
  ```
  Replace with:
  ```
  # Every arm below writes to the index or the object database. The dirt classifier
  # itself must reach its staged-tree answer by reading only, so run_report never calls
  # any of them; the report-mode non-mutation assertion in
  # tests/shell/test_cleanup_worktrees_dirt_clear.bats searches this file's argv log for
  # these subcommand names and depends on that read-only guarantee, not on their absence
  # from this stub.
  #
  # add             -> cleanup_worktrees_preserve_lib.sh:400,402 (preserve_commit_plan);
  #                    reached only by preserve / --preserve.
  # worktree add    -> cleanup_worktrees_actions_lib.sh:103 (create_consolidation_worktree);
  #                    not reachable from any wrapper dispatch arm (report/apply/preserve).
  # worktree remove -> cleanup_worktrees_actions_lib.sh:191 (cleanup_consolidation_on_abort,
  #                    not reachable, same as above) and
  #                    cleanup_worktrees_actions_lib.sh:292 (remove_worktree_safe, via
  #                    delete_candidate); reached by --apply / apply for the second site.
  # cherry-pick     -> cleanup_worktrees_actions_lib.sh:147,157,164
  #                    (cherry_pick_candidates); not reachable from any wrapper dispatch arm.
  # branch -D       -> cleanup_worktrees_actions_lib.sh:198 (consolidation teardown, not
  #                    reachable) and cleanup_worktrees_actions_lib.sh:317 (delete_branch,
  #                    via delete_candidate); reached by --apply / apply for the second site.
  # reset --hard    -> cleanup_worktrees_dirt_lib.sh:483 (clear_disposable_dirt); reached
  #                    only by --apply --clear-disposable.
  # clean -fd       -> cleanup_worktrees_dirt_lib.sh:488 (clear_disposable_dirt); reached
  #                    only by --apply --clear-disposable.
  #
  # "Not reachable from any wrapper dispatch arm" means create_consolidation_worktree,
  # cherry_pick_candidates, and cleanup_consolidation_on_abort have no caller under
  # run_report, run_apply, or run_preserve (cleanup-worktrees.sh's main() dispatch); they
  # are exercised only by tests/shell/test_cleanup_worktrees_consolidation.bats, which
  # calls them directly rather than through the wrapper.
  #
  ```
  This is a comment-only edit inside a file `shfmt`/`shellcheck` never scan (it sits under
  `tests/fixtures/`, outside the three discovery roots in `.claude/rules/shell.md`), so it
  carries no formatting/lint obligation of its own; Phase 2's `check` run remains a
  whole-repo regression check, not a validator of this specific edit.
  Acceptance: `grep -c -F 'No arm is defined for any subcommand that writes' tests/fixtures/cleanup_worktrees/stub-bin/git`
  returns `0` (the false sentence is gone); `grep -c -F 'cleanup_worktrees_actions_lib.sh:103 (create_consolidation_worktree)' tests/fixtures/cleanup_worktrees/stub-bin/git`
  returns `1`. AC-3.

### Phase 2 — Final QC (unconditional)

- [ ] [P2-T1] Run the final check-stage command `sh scripts/bash/shell-qc.sh check` (or the
  CI-confirming-gate fallback per "Command-route note" if locally blocked by permissions or
  by a missing `shfmt`/`shellcheck`). Write `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/qa-gates/final-shell-qc-check.<ISO-8601 timestamp>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording whether
  `shfmt -d`/`shellcheck` reported any diagnostic line. This command MUST be executed and
  recorded; `EXIT_CODE: SKIPPED` is not a valid outcome. If `EXIT_CODE` is nonzero or any
  diagnostic line is printed, restart the full toolchain loop from formatting (per
  `.claude/rules/general-code-change.md`'s "Mandatory Toolchain Loop") — but note this stage
  does not scan any file this plan's Phase 1 tasks touch (`.claude/rules/shell.md`'s
  discovery roots exclude `tests/`), so any diagnostic here is pre-existing and outside this
  plan's blast radius; do not edit an in-scope test/fixture file to silence it. AC-7.

- [ ] [P2-T2] Run the final test-stage command `npx --yes bats tests/shell` (or
  `sh scripts/bash/shell-qc.sh test`; see "Command-route note"). Write
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/qa-gates/final-shell-qc-test.<ISO-8601 timestamp>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording: the TAP
  `1..N` header's `N` value (call this `N_final`), confirming `N_final` equals `N_baseline`
  (recorded in P0-T7) plus exactly 3 (the three new `@test` blocks added by P1-T2, P1-T3,
  and P1-T6 — P1-T5 edits an existing test and adds no new one); zero `not ok` lines; the
  ABSENCE of the literal string `bats not installed; skipping shell tests.`; and the
  presence, on `ok` lines, of all three new tests' exact description strings quoted in
  P1-T2, P1-T3, and P1-T6 above. This command MUST be executed and recorded;
  `EXIT_CODE: SKIPPED` is not a valid outcome. If any stage changed a file or failed,
  restart the toolchain loop from formatting. AC-1, AC-2, AC-4, AC-5, AC-7.

- [ ] [P2-T3] Run `git diff origin/main --name-status -- scripts/` followed by
  `git status --porcelain -- scripts/`. Write
  `docs/features/active/cleanup-worktrees-test-suite-blind-spots-660/evidence/qa-gates/final-ac6-scripts-diff.<ISO-8601 timestamp>.md`
  with `Timestamp:`, `Command: git diff origin/main --name-status -- scripts/ (and) git
  status --porcelain -- scripts/`, `EXIT_CODE:`, and `Output Summary:` recording that both
  commands produced empty output (proving no path under `scripts/` was modified, added, or
  deleted by this branch, and — per the "Coverage applicability" note above — that the
  changed-line coverage obligation is vacuously satisfied). A nonempty result from either
  command is a blocking finding: it means a task in Phase 1 touched a production file
  outside this plan's stated blast radius, and the plan's implementation must be corrected
  before this gate can pass. AC-6.

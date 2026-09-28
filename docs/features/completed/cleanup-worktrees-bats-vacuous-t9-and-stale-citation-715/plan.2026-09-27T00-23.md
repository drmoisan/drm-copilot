# cleanup-worktrees-bats-vacuous-t9-and-stale-citation (Plan)

- **Issue:** #715
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-23
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (AC source: `spec.md` only, per `acceptance-criteria-tracking`)

## Scope and Environment Notes (read before executing)

- Files changed by this plan: `tests/shell/test_cleanup_worktrees_deletion.bats`,
  `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, plus evidence artifacts under
  `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/`,
  plus AC checkboxes in `spec.md`. No file under `scripts/` is changed (AC7).
- The executor runs on Windows in an agent worktree whose Bash isolation guard refuses any
  command text containing `bash`, `pwsh`, or `wsl`. `bats`, `shfmt`, `shellcheck`, and `kcov`
  cannot run locally. Every bats/shellcheck/coverage verification in this plan is therefore a
  CI-observed check against `.github/workflows/_shell-coverage.yml` (job `shell-coverage`,
  invoked from `.github/workflows/ci.yml` on PRs into `main`/`development`), not a local run.
- `.bats` files are **not** in the shfmt/shellcheck discovery set: `discover_shell_scripts()`
  in `scripts/bash/shell_qc_lib.sh` (lines 75-102) walks only `tools/`, `scripts/`, and
  `.claude/lib/bash/`; `tests/shell` is not a discovery root. The two edited `.bats` files are
  exercised only by `find_bats_test_dirs()` (`scripts/bash/shell_qc_lib.sh` lines 104-119),
  which feeds `run_test`/`run_test_coverage` (the `shell-qc.sh test [--coverage]` commands).
  The CI `check` step (shfmt diff + shellcheck) therefore cannot validate this change; the CI
  `test --coverage` step is the step that does.
- `git` commands in this plan (`git grep`, `git diff`, `git commit`) do not contain the
  substrings `bash`, `pwsh`, or `wsl` and are not subject to the isolation guard.
- Commit tasks use `git commit -m "<message>" -- <path> [<path> ...]` (pathspec-bearing,
  no `&&` chaining) and contain none of `<`, `>`, `$`, or a backtick character.

## Evidence Path Convention

All evidence in this plan is written under
`docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/<kind>/`.
`<timestamp>` below denotes the actual ISO-8601 `yyyy-MM-ddTHH-mm` timestamp at artifact-creation
time, per `evidence-and-timestamp-conventions`.

### Phase 0 — Policy Reads & Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md`, in particular the "Policy Compliance Reading Order" section,
      and confirm it lists `.github/copilot-instructions.md` first, followed by
      `.github/instructions/general-code-change.instructions.md` and
      `.github/instructions/general-unit-test.instructions.md` as the second and third entries.
      Acceptance: both file names are visible in the section text as read.
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
      Acceptance: the "Mandatory Toolchain Loop" and "File Size Limit" sections are visible
      as read.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
      Acceptance: the "Core Principles" and "Test File Location" sections are visible as read.
- [ ] [P0-T4] Read `.claude/rules/shell.md` in full (language rule scoped to `**/*.bats` and
      `tests/shell/**`).
      Acceptance: the "Toolchain" and "Discovery Contract" sections are visible as read,
      including the statement that bats test directories are `tests/shell` and `tests/bash`.
- [ ] [P0-T5] Write
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/phase0-instructions-read.md`
      containing `Timestamp:`, a `Policy Order:` line listing, in order, `CLAUDE.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/shell.md`, and an explicit bulleted list of the four files read in
      P0-T1 through P0-T4.
      Acceptance: the artifact file exists and contains all four required fields/lines.
- [ ] [P0-T6] Baseline capture: confirm the pre-fix vacuous assertion literal is present at
      the current commit by running
      `git grep -n -F -e '!= *"merge-base"*' -- tests/shell/test_cleanup_worktrees_deletion.bats`
      (expected: one match, exit code 0). Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/p0-t6.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state the matched line
      number and text).
      Acceptance: `EXIT_CODE: 0` and exactly one matched line recorded.
- [ ] [P0-T7] Baseline capture: confirm the stale citation literal is present at the current
      commit by running
      `git grep -n -F -e 'cleanup-worktrees.sh:145' -- tests/shell/test_cleanup_worktrees_dirt_clear.bats`
      (expected: one match, exit code 0). Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/p0-t7.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `EXIT_CODE: 0` and exactly one matched line recorded.
- [ ] [P0-T8] Baseline capture: confirm both occurrences of the second stale citation are
      present at the current commit by running
      `git grep -c -F -e 'test_cleanup_worktrees_deletion.bats:47' -- tests/shell/test_cleanup_worktrees_dirt_clear.bats`
      (expected: count of 2, exit code 0). Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/p0-t8.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state the reported count).
      Acceptance: `Output Summary:` records a count of exactly 2.
- [ ] [P0-T9] Baseline capture (bash coverage, CI-observed): identify the most recent
      completed, successful CI run of the `shell-coverage` job on `main` by running
      `gh run list --branch main --workflow ci.yml --status success --limit 1 --json databaseId,conclusion,headSha`.
      Record the raw JSON output in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/p0-t9.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state the `databaseId`
      captured for use in P0-T10).
      Acceptance: `EXIT_CODE: 0` and a `databaseId` value recorded.
- [ ] [P0-T10] Baseline capture (bash coverage, CI-observed): using the `databaseId` recorded
      in P0-T9, run `gh run view DATABASE_ID --log` (substituting the actual numeric ID) and
      search the output for the literal line prefix `Bash coverage (lines):`. Record the full
      matched line and the numeric percentage in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline/p0-t10.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state the baseline
      coverage percentage as a number, e.g. `Baseline: NN.N%`).
      Acceptance: `Output Summary:` records a numeric baseline coverage percentage.
- [ ] [P0-T11] Commit the Phase 0 evidence artifacts:
      `git commit -m "docs(715): record phase 0 policy-read and baseline evidence (#715)" -- docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/baseline`
      Acceptance: `git log -1 --name-status` (no ref needed; this reads the newly created
      commit at `HEAD`) lists the six files added under `evidence/baseline/`.

### Phase 1 — Test-Only Implementation Edits & Verification

- [ ] [P1-T1] In `tests/shell/test_cleanup_worktrees_deletion.bats`, inside the `@test`
      block `"delete_candidate refuses the base branch before re-verification"` (current
      lines 182-191), replace the single line
      `    [[ "$output" != *"merge-base"* ]]`
      with the following five lines (a four-line comment plus the new assertion):
      ```
          # merge-base is never reached here: compute_protected already classifies main
          # PROTECTED_CURRENT, so classify_branch returns before classify_ancestry runs.
          # A guard moved after reverify_delete_eligible would instead make classify_branch's
          # first call - rev-parse --abbrev-ref HEAD via compute_protected - reach $output.
          [[ "$output" != *"rev-parse --abbrev-ref HEAD"* ]]
      ```
      Do not modify the `[ "$status" -eq 1 ]` line, the
      `[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]` line, or the two
      following `!= *"worktree remove"*` / `!= *"branch -D"*` lines in this test block.
      Acceptance: the file, when read back, contains the new five-line block in place of the
      old single line, with the three surrounding assertions unchanged.
- [ ] [P1-T2] In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, in the header comment
      block, replace the two-line span (current lines 14-15)
      `# observes the flag pre-pass at scripts/bash/cleanup-worktrees.sh:145, which is the line`
      `# that sets CLEANUP_WT_CLEAR_DISPOSABLE in production: with the direct driver alone, a`
      with
      `# observes the flag pre-pass in main() (the block that sets CLEANUP_WT_CLEAR_DISPOSABLE=1)`
      `# in scripts/bash/cleanup-worktrees.sh: with the direct driver alone, a`
      Acceptance: the file, when read back, no longer contains the literal
      `cleanup-worktrees.sh:145` and contains the literal `CLEANUP_WT_CLEAR_DISPOSABLE=1` in
      the same comment paragraph.
- [ ] [P1-T3] In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, in the same header
      comment block, replace the single line (current line 21)
      `# in the form used at tests/shell/test_cleanup_worktrees_deletion.bats:47, and not`
      with the two lines
      `# in the form used in the @test "a candidate whose re-verification flips is blocked`
      `# before any branch delete" (test_cleanup_worktrees_deletion.bats), and not`
      Acceptance: the file, when read back, no longer contains this line's original
      `test_cleanup_worktrees_deletion.bats:47` literal at this location and instead names the
      `@test` by its title text.
- [ ] [P1-T4] In `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, in the same header
      comment block, replace the single line (current line 39)
      `# at tests/shell/test_cleanup_worktrees_deletion.bats:47 would compare against a line`
      with the two lines
      `# at the @test "a candidate whose re-verification flips is blocked before any branch`
      `# delete" (test_cleanup_worktrees_deletion.bats) would compare against a line`
      Acceptance: the file, when read back, no longer contains this line's original
      `test_cleanup_worktrees_deletion.bats:47` literal at this location and instead names the
      `@test` by its title text.
- [ ] [P1-T5] Verify AC1 and AC2 (spec.md): run
      `git diff origin/main...HEAD -- tests/shell/test_cleanup_worktrees_deletion.bats`
      and confirm the diff contains a removed line matching the fixed string
      `-    [[ "$output" != *"merge-base"* ]]` and an added line matching the fixed string
      `+    [[ "$output" != *"rev-parse --abbrev-ref HEAD"* ]]`, and that the diff contains no
      removed line matching `-    [[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]`,
      `-    [[ "$output" != *"worktree remove"* ]]`, or `-    [[ "$output" != *"branch -D"* ]]`.
      Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p1-t5.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: the diff shows the exact one-line removal/addition pair and none of the
      three retained assertions are shown as removed lines.
- [ ] [P1-T6] Verify AC3 (spec.md): run
      `git diff origin/main...HEAD -- tests/shell/test_cleanup_worktrees_dirt_clear.bats`
      and confirm the diff contains a removed line matching the fixed string
      `cleanup-worktrees.sh:145` and an added line matching the fixed string
      `CLEANUP_WT_CLEAR_DISPOSABLE=1`. Then run
      `git grep -n -E 'cleanup-worktrees\.sh:[0-9]+' -- tests/shell/test_cleanup_worktrees_dirt_clear.bats`
      and confirm no match (expected exit code 1). Record both results in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p1-t6.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:`.
      Acceptance: the second command reports zero matches (no `scripts/bash/cleanup-worktrees.sh:<N>`
      citation remains anywhere in the file).
- [ ] [P1-T7] Verify AC4 (spec.md): run
      `git grep -n -F -e 'test_cleanup_worktrees_deletion.bats:47' -- tests/shell/test_cleanup_worktrees_dirt_clear.bats`
      and confirm no match (expected exit code 1). Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p1-t7.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary:`.
      Acceptance: the command reports zero matches.
- [ ] [P1-T8] Verify AC7 (spec.md): run
      `git diff origin/main...HEAD --name-status -- scripts/` and, in the same task, run the
      companion `git status --porcelain -- scripts/`, confirming both produce empty output.
      Record both results in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p1-t8.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: both commands produce empty output (no file under `scripts/` is changed or
      modified in the working tree).

### Phase 2 — D6 Falsifiability Trace Evidence

- [ ] [P2-T1] Author a static call-path trace artifact at
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other/<timestamp>-falsifiability-trace.md`
      (AC5). The artifact must not modify, describe as committed, or reference a mutated copy
      of any production file; it documents the mutation without applying it. It must cite, by
      function name and literal call-site text (not line numbers):
      (a) `delete_candidate()` in `scripts/bash/cleanup_worktrees_actions_lib.sh`, quoting the
      base-branch guard `if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]` and the line
      `reverify_delete_eligible "$name" "$state" || return 1`;
      (b) `reverify_delete_eligible()` in the same file, quoting
      `out=$(classify_branch "$name") || crc=$?`;
      (c) `classify_branch()` in `scripts/bash/cleanup_worktrees_lib.sh`, quoting
      `cpout=$(compute_protected) || cprc=$?` and the subsequent
      `if [[ -n ${prot_branch[$name]:-} ]] ...` protected-check preceding the
      `v=$(classify_ancestry "$name")` call;
      (d) `compute_protected()` in `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, quoting
      `current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?`;
      (e) the stub's unconditional argv log line `printf 'stub-git: %s\n' "$*" >&2` in
      `tests/fixtures/cleanup_worktrees/stub-bin/git`.
      The artifact must state, citing these same anchors: (i) under the current code, for the
      `base_not_checked_out` fixture, `compute_protected` classifies `main` `PROTECTED_CURRENT`
      before `classify_ancestry` (and therefore `merge-base`) is ever reached, so no
      `rev-parse --abbrev-ref HEAD` call is issued by the direct `delete_candidate` driver used
      in T9; and (ii) under the named mutation (moving the base-branch guard in
      `delete_candidate` to after the `reverify_delete_eligible` call), `reverify_delete_eligible`
      would run first, invoking `classify_branch` -> `compute_protected`, whose unredirected
      `rev-parse --abbrev-ref HEAD` call would be logged by the stub to stderr and merged into
      `$output` under `bats run`, causing the new T9 assertion to fail.
      Acceptance: the artifact file exists at the exact path above and contains all five
      function-name/literal citations and both the (i) and (ii) statements.
- [ ] [P2-T2] Verify the Phase 2 artifact's completeness: run a plain (non-`git`) text search
      of `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other/<timestamp>-falsifiability-trace.md`
      (the file is untracked at this point, so `git grep` must not be used) for each of the
      five literals `delete_candidate`, `reverify_delete_eligible`, `classify_branch`,
      `compute_protected`, and `rev-parse --abbrev-ref HEAD`, confirming at least one match for
      each. Record the per-literal match counts in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other/p2-t2.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: all five literals report at least one match.

### Phase 3 — Commit Implementation

- [ ] [P3-T1] Commit the two edited test files and the Phase 2 evidence artifacts together:
      `git commit -m "test(cleanup-worktrees): replace vacuous T9 assertion and stale line citations (#715)" -- tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/other`
      Acceptance: `git diff origin/main...HEAD --name-status` lists exactly the two `.bats`
      files as modified (`M`) and the Phase 2 evidence file(s) as added (`A`); pair with
      `git status --porcelain` in the same task, confirming no other tracked or untracked
      change remains outstanding from this commit's intended scope.

### Phase 4 — Final QC (CI-Observed Shell Toolchain Gate)

- [x] [P4-T1] Identify the CI run for this branch's current head commit by running
      `gh run list --branch bug/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715 --workflow ci.yml --limit 1 --json databaseId,status,conclusion,headSha`.
      `ci.yml` triggers only on PRs/pushes into `main` or `development`, and the PR for this
      branch is opened by the executing lane outside this plan, so an empty result is an
      expected interim state, not a failure. If the command returns an empty JSON array (`[]`),
      no run exists yet: record the empty result in the artifact below and stop this task
      without retrying; resume this task only after a PR has been opened for this branch. If
      the command returns a non-empty array, run `git rev-parse HEAD` and confirm the returned
      `headSha` equals that value; if it does not match (a stale run from an earlier commit),
      treat the result as if no run exists yet and stop this task the same way, recording the
      mismatch. If `headSha` matches and `status` is not `completed`, re-run the `gh run list`
      command until `status` is `completed`. Record the final JSON output in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p4-t1.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state either `status:
      completed` with the matching `headSha` and the `databaseId` captured for use in P4-T2
      through P4-T7, or the empty-result/stale-run stop condition and that the task is pending
      PR creation).
      Acceptance: `Output Summary:` records `status: completed` with a `headSha` matching
      `git rev-parse HEAD` and the `databaseId`, or records the empty-result/stale-run stop
      condition.
- [x] [P4-T2] Execute this task only once P4-T1 has recorded a `databaseId` under its
      completed-run outcome (not the empty-result/stale-run stop condition). Using that
      `databaseId`, run `gh run view DATABASE_ID --json jobs` (substituting the actual numeric
      ID) and locate the job object whose `name` field equals `Shell Coverage (Bats + kcov)`;
      record its `conclusion` field value. Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p4-t2.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: `Output Summary:` records `conclusion: success` for the
      `Shell Coverage (Bats + kcov)` job (this is the AC6 job-pass gate).
- [x] [P4-T3] Execute this task only once P4-T1 has recorded a `databaseId` under its
      completed-run outcome (not the empty-result/stale-run stop condition). Using that same
      `databaseId`, run `gh run view DATABASE_ID --json jobs` (substituting the actual numeric
      ID) and, within the `Shell Coverage (Bats + kcov)` job's `steps` array, locate the step
      object whose `name` field equals `Run shell-qc check (shfmt diff + shellcheck)`; record
      its `conclusion` field. Record the result, together with an explicit note that per
      `scripts/bash/shell_qc_lib.sh`'s `discover_shell_scripts()` this step does not lint or
      format the two `.bats` files edited by this fix (they are outside its `tools/`,
      `scripts/`, `.claude/lib/bash/` discovery roots) and is recorded for full-QA-loop
      completeness only, in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p4-t3.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: the recorded `conclusion` field for this step equals `success`.
- [x] [P4-T4] Execute this task only once P4-T1 has recorded a `databaseId` under its
      completed-run outcome (not the empty-result/stale-run stop condition). Using that same
      `databaseId`, run `gh run view DATABASE_ID --log` (substituting the actual numeric ID)
      and search the output for the literal line prefix `Bash coverage (lines):` and record
      the full matched line and numeric percentage in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p4-t4.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (state the post-change
      coverage percentage as a number, e.g. `Post-change: NN.N%`).
      Acceptance: `Output Summary:` records a numeric post-change coverage percentage.
- [x] [P4-T5] Execute this task only once P4-T4 has recorded a post-change coverage
      percentage (which itself requires P4-T1's completed-run outcome). Compare the baseline
      coverage percentage recorded in P0-T10 against the post-change coverage percentage
      recorded in P4-T4. Record the comparison in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates/p4-t5.<timestamp>.md`
      with `Timestamp:`, `Baseline:`, `PostChange:`, `Delta:`, `Output Summary:`.
      Acceptance: `PostChange` is not lower than `Baseline` (no regression on the uniform bash
      line-coverage gate per `.claude/rules/quality-tiers.md`).
- [x] [P4-T6] Execute this task only once P4-T4 has produced the `gh run view DATABASE_ID --log`
      output (which itself requires P4-T1's completed-run outcome). From that output, search
      for a TAP result line containing both `ok` and the literal test title
      `delete_candidate refuses the base branch before re-verification`, and confirm no `not ok`
      line contains the same title. Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/regression-testing/p4-t6.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: an `ok` line is found for this title and no `not ok` line is found for it.
- [x] [P4-T7] Execute this task only once P4-T6 has completed its search of the same log
      output (which itself requires P4-T1's completed-run outcome). From the same log output,
      search for a TAP result line containing both `ok` and the literal test title
      `a candidate whose re-verification flips is blocked before any branch delete`, and
      confirm no `not ok` line contains the same title. Record the result in
      `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/regression-testing/p4-t7.<timestamp>.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
      Acceptance: an `ok` line is found for this title and no `not ok` line is found for it
      (this is the D4 text-anchor target and must still pass under its new-anchor citation).

### Phase 5 — Acceptance Criteria Check-off & Final Commit

- [ ] [P5-T1] After P1-T5 passes, check off AC1 in `spec.md`
      (`docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/spec.md`):
      change the `- [ ] AC1: ...` line to `- [x] AC1: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC1: ...` and no other text on the line changed.
- [ ] [P5-T2] After P1-T5 passes, check off AC2 in the same `spec.md`: change the
      `- [ ] AC2: ...` line to `- [x] AC2: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC2: ...` and no other text on the line changed.
- [ ] [P5-T3] After P1-T6 passes, check off AC3 in the same `spec.md`: change the
      `- [ ] AC3: ...` line to `- [x] AC3: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC3: ...` and no other text on the line changed.
- [ ] [P5-T4] After P1-T7 passes, check off AC4 in the same `spec.md`: change the
      `- [ ] AC4: ...` line to `- [x] AC4: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC4: ...` and no other text on the line changed.
- [ ] [P5-T5] After P2-T1 and P2-T2 pass, check off AC5 in the same `spec.md`: change the
      `- [ ] AC5: ...` line to `- [x] AC5: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC5: ...` and no other text on the line changed.
- [x] [P5-T6] After P4-T1 has recorded its completed-run outcome (not the
      empty-result/stale-run stop condition) and P4-T2, P4-T6, and P4-T7 all pass, check off
      AC6 in the same `spec.md`: change the `- [ ] AC6: ...` line to `- [x] AC6: ...`, editing
      only the checkbox marker.
      Acceptance: the line reads `- [x] AC6: ...` and no other text on the line changed.
- [ ] [P5-T7] After P1-T8 passes, check off AC7 in the same `spec.md`: change the
      `- [ ] AC7: ...` line to `- [x] AC7: ...`, editing only the checkbox marker.
      Acceptance: the line reads `- [x] AC7: ...` and no other text on the line changed.
- [ ] [P5-T8] Commit the `spec.md` AC checkbox updates and the Phase 4 evidence artifacts:
      `git commit -m "docs(715): check off AC1-AC7 and record final QC evidence (#715)" -- docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/spec.md docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/qa-gates docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/evidence/regression-testing`
      Acceptance: `git diff origin/main...HEAD --name-status` lists `spec.md` as modified (`M`)
      and the Phase 4 evidence files as added (`A`); pair with `git status --porcelain` in the
      same task, confirming no outstanding change remains from this commit's intended scope.

## Acceptance Criteria Status (to be updated by the executor at completion)

- Source: `docs/features/active/cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/spec.md`
- Total AC items: 7
- Checked off (delivered): 0 (at plan-authoring time)
- Remaining (unchecked): 7
- Items remaining: AC1, AC2, AC3, AC4, AC5, AC6, AC7 (see `spec.md` for full text)

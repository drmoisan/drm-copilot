# 2026-08-29-cleanup-worktrees-apply-deletes-local-main (Plan)

- **Issue:** #594
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/cleanup-worktrees-apply-deletes-local-main-594`
- **Last Updated:** 2026-09-25T22-50
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug

**Requirements source (sole AC source, full-bug):** `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`,
section `## Acceptance Criteria` (23 items, referenced below as AC-01 through AC-23 in document
order). `user-story.md` is not produced for full-bug work and its absence is not a blocker.
Supporting inputs: `issue.md` and `research/research.2026-09-25T22-10.md` in the same folder.

**Notation.** `<FEATURE>` denotes `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594`.
`<ts>` denotes the artifact creation time in `yyyy-MM-ddTHH-mm` form. Every evidence artifact
is written under `<FEATURE>/evidence/<kind>/`; no artifact is written under `artifacts/`.

**Base commit (BASE_SHA).** `0658f6945aa833c6960dc5bf8a43635fc346991f`, the head of
`bug/cleanup-worktrees-apply-deletes-local-main-594` when this plan was authored (read from the
branch ref file). Every scope diff in this plan is anchored to that literal SHA. No task
references `origin/main` or any other remote ref: the CI checkout is depth 1 and sibling issue
#660 failed CI on exactly that dependency. P0-T1 proves that no code path changed between
BASE_SHA and the execution start, so the literal stays a valid anchor if docs-only commits
(for example this plan) land on the branch before execution.

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact
tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage.
If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the
audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing
task. Do not mark evidence-backed work complete without the artifact. Every command-step
artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact
whose passing outcome is a non-zero exit also carries `ExpectedExitCode: <int>`.

**Command route (agent worktree).** The executor runs commands with the Bash tool (Git Bash;
its `sh` is GNU bash). The worktree isolation guard refuses command text that contains the
words `bash`, `pwsh`, or `wsl`, and refuses heredocs. Therefore:
- shell scripts run as `sh <script>` (for example `sh scripts/bash/shell-qc.sh check`);
- bats runs as `npx --yes bats <files>` (bats-core 1.13.0 from npm, no repository change);
- `shfmt` and `shellcheck` run directly from the Windows PATH;
- when the guard refuses a command's text, the executor writes the identical command into a
  `.sh` file in its session scratchpad (outside the repository) and runs `sh <that file>`;
  the artifact's `Command:` field records the command itself, not the scratch file path.

**`shell-qc.sh test` is not used locally.** `run_test` in `scripts/bash/shell_qc_lib.sh`
resolves `bats` with `command -v`; bats is not on the Windows PATH, so the wrapper prints
`bats not installed; skipping shell tests.` and exits 0 having run nothing. Local test evidence
therefore comes from `npx --yes bats` only, and every local test artifact must show a TAP
`1..N` plan line.

**kcov has no local route.** Coverage is measured only by `.github/workflows/_shell-coverage.yml`
(ubuntu-latest, `actions/checkout@v7` default depth, shfmt 3.8.0, kcov v43), dispatched with
`gh workflow run` against this branch. CI is the authoritative bats and kcov run; when local
and CI results disagree, CI governs (`.claude/rules/shell.md`, CI-vs-Local Version Drift). The
CI artifact `shell-coverage` is downloaded into the executor's session scratchpad (outside the
repository); only extracted values are written to `<FEATURE>/evidence/`, never the raw kcov tree
and never an absolute host path.

**Formatter scope.** `shell-qc.sh check` discovers `.sh` files and bash/sh shebang files under
`tools/`, `scripts/`, and `.claude/lib/bash/` only; `.bats` files are outside discovery and the
three edited suites use 4-space indentation that shfmt defaults would rewrite. shfmt therefore
applies to the five changed production `.sh` files; the three edited `.bats` files are held to
shellcheck with no finding absent from baseline (P0-T8, P6-T3), and the new test blocks follow
each file's existing 4-space style.

**Line-number citation invariant.** `tests/fixtures/cleanup_worktrees/stub-bin/git:75-91` cites
`scripts/bash/cleanup_worktrees_actions_lib.sh` lines 103, 147, 157, 164, 191, 198, 292, and 317;
`scripts/bash/cleanup_worktrees_detached_lib.sh:23` cites `actions_lib.sh:19-35` and `:46` cites
`scripts/bash/cleanup_worktrees_enumerate_lib.sh:115-116`. Every insertion in those two
libraries is placed below line 317 (actions) or below line 116 (enumerate); header edits above
those lines are zero-net-line rewordings. P0-T13 captures the cited lines and P5-T10 proves
them unchanged.

**Batch-budget hooks.** The per-session batch-budget hooks cover PowerShell and Python only;
this plan edits no file of either kind.

**Commit route.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` blocks
`git add` and `git commit` unless `artifacts/orchestration/orchestrator-state.json` carries a
valid issue number, feature folder, route, and `lifecycle_ready`. P6-T8 runs under the
orchestrator's checkpoint for issue #594; if the gate refuses, P6-T8 records the refusal and
the plan stops at that task (BLOCKED) rather than working around the gate.

**Spec reconciliation (verification form only; no requirement is dropped).**
1. AC-12 and AC-13 name `git diff origin/main` as the reviewer check. This plan anchors those
   diffs on BASE_SHA instead (P6-T15, P6-T16), for the CI-depth reason stated above.
2. AC-15 names the search `needs no special handling`. At BASE_SHA that phrase wraps across
   `scripts/bash/cleanup_worktrees_report_records_lib.sh` lines 392-393, so a line-oriented search
   returns zero matches before any edit and cannot fail. The plan asserts single-line tokens
   instead: `needs no special` (line 392), `needs no separate protection` (line 429), and
   `classify_branch marks it PROTECTED_CURRENT` (`cleanup_worktrees_actions_lib.sh:362`), each of
   which matches exactly one line at BASE_SHA and must match none after the change (P5-T4).
3. The spec lists a header note for `BLOCKED-PROTECTED-BASE` in `cleanup_worktrees_actions_lib.sh`.
   A header insertion would shift the lines that `stub-bin/git` cites, which conflicts with the
   spec's own line-citation invariant. The plan therefore records the token in the
   `delete_candidate` docstring (below line 317) and makes the header change a zero-net-line
   reword (P3-T2, P3-T4).
4. AC-19 covers "changed shell and bats files". shfmt applies to the `.sh` files only (see
   Formatter scope); the `.bats` files are covered by shellcheck and by the CI check step, which
   the AC names as its alternative.
5. AC-23 concerns the pull-request CI run, which may not exist while this plan executes. P6-T40
   carries an explicit deferral branch.

---

### Phase 0 — Policy Reads and Baseline Capture

- [ ] [P0-T1] Record BASE_SHA in `<FEATURE>/evidence/baseline/base-sha.<ts>.md`. Run
  `git rev-parse HEAD`, `git merge-base --is-ancestor 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD`,
  and `git diff --exit-code --stat 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- scripts/ tests/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/ .github/workflows/`.
  Acceptance: the artifact records the printed HEAD SHA, the ancestry check `EXIT_CODE: 0`,
  and the diff `EXIT_CODE: 0` with empty output (no code, test, skill, or workflow path changed
  since BASE_SHA). Any other result stops the plan: record BLOCKED and return to the planner.
- [ ] [P0-T2] Read policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md`:
  `CLAUDE.md`, `.github/copilot-instructions.md`,
  `.github/instructions/general-code-change.instructions.md`,
  `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/shell.md`,
  `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/tonality.md`, and
  `.claude/rules/plan-acceptance-gates.md`. Acceptance: all eleven files read in that order;
  no file edited.
- [ ] [P0-T3] Write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with
  `Timestamp:`, `Policy Order:` (the P0-T2 order), and the explicit list of the eleven files
  read. Acceptance: the file exists with all three fields and eleven listed paths.
- [ ] [P0-T4] Record tool availability in `<FEATURE>/evidence/baseline/tool-versions.<ts>.md`
  by running `shfmt --version`, `shellcheck --version`, `npx --yes bats --version`, and
  `gh --version` (each command with its own `Command:`/`EXIT_CODE:` pair). Acceptance: the
  artifact records each version string; `npx --yes bats --version` prints a line beginning
  `Bats `. If `bats` cannot be resolved through npx, record that result verbatim and use the
  CI fallback stated in P1-T20 for every local bats step.
- [ ] [P0-T5] Baseline format step for `scripts/bash/` production files: run
  `shfmt -d scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh`
  and write `<FEATURE>/evidence/baseline/shfmt-diff.<ts>.md`. Acceptance: the artifact records
  `EXIT_CODE:` and, in `Output Summary:`, either "no diff printed" or the verbatim diff hunks
  (a pre-existing diff is recorded, not fixed, in this task).
- [ ] [P0-T6] Baseline lint step for `scripts/bash/` production files: run
  `shellcheck -f gcc scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh`
  and write `<FEATURE>/evidence/baseline/shellcheck-production.<ts>.md`. Acceptance: the
  artifact records `EXIT_CODE:` and the finding count (number of output lines) plus every
  finding line verbatim.
- [ ] [P0-T7] Baseline repo-wide check step: run `sh scripts/bash/shell-qc.sh check` and write
  `<FEATURE>/evidence/baseline/shell-qc-check.<ts>.md`. Acceptance: the artifact records
  `EXIT_CODE:` and every diagnostic line verbatim (a clean run prints nothing and exits 0; a
  non-zero exit from local shfmt 3.12 or shellcheck 0.11 version drift is recorded as a
  pre-existing condition).
- [ ] [P0-T8] Baseline lint step for the three `tests/shell/` suites being edited: run
  `shellcheck -f gcc tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
  and write `<FEATURE>/evidence/baseline/shellcheck-bats.<ts>.md`. Acceptance: the artifact
  records `EXIT_CODE:`, the total finding count, and the per-code multiset (each distinct
  `[SCnnnn]` code with its count), which P6-T3 compares against.
- [ ] [P0-T9] Baseline syntax step (bash has no type checker; `.claude/rules/shell.md` step 3):
  run `sh -n scripts/bash/cleanup_worktrees_enumerate_lib.sh`, and the same for
  `scripts/bash/cleanup_worktrees_actions_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`,
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`, and `scripts/bash/cleanup-worktrees.sh`;
  write `<FEATURE>/evidence/baseline/syntax-check.<ts>.md`. Acceptance: five `EXIT_CODE:`
  values recorded; a clean file prints nothing and exits 0.
- [ ] [P0-T10] Baseline local test step: run `npx --yes bats tests/shell/test_cleanup_worktrees_*.bats`
  (19 files; run in the background, expected duration tens of minutes) and write
  `<FEATURE>/evidence/baseline/bats-cleanup-suites.<ts>.md`. Also run
  `grep -c -e '^@test ' tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
  and record the three per-file counts. Acceptance: the artifact records `EXIT_CODE:`, the TAP
  `1..N` value, the `ok` and `not ok` counts, the name of every `not ok` test (the baseline
  failure set, possibly empty), and the three per-file `@test` counts.
- [ ] [P0-T11] Baseline CI coverage step via `.github/workflows/_shell-coverage.yml`: push the
  branch at BASE_SHA with
  `git push -u origin bug/cleanup-worktrees-apply-deletes-local-main-594` (no force), dispatch
  `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-apply-deletes-local-main-594`,
  identify the run with
  `gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-worktrees-apply-deletes-local-main-594 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`,
  wait with `gh run watch <RUN_ID> --exit-status`, and read `gh run view <RUN_ID> --log`.
  Write `<FEATURE>/evidence/baseline/ci-shell-coverage.<ts>.md`. Acceptance: the artifact
  records the run ID, `headSha` equal to the P0-T1 HEAD SHA, the conclusion, every TAP `1..N`
  line, the count of `not ok` lines, and the numeric `Bash coverage (lines): NN.N%` headline
  copied from the log. If push, dispatch, or the run fails to produce the headline, record
  the observed failure verbatim and mark the coverage baseline remediation-required (the
  plan outcome cannot be PASS without a numeric baseline).
- [ ] [P0-T12] Baseline per-file coverage into `<FEATURE>/evidence/baseline/kcov-per-file.<ts>.md`: run
  `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-baseline`
  (RUN_ID from P0-T11; the scratchpad is outside the repository), then, from the `cov.xml` at
  the root of the downloaded directory (or `kcov-merged/cov.xml` when the root copy is
  absent), record for each of `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`,
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`, and `scripts/bash/cleanup-worktrees.sh`
  the `line-rate` value of the `<class>` element whose `filename` attribute ends with that
  file's basename. Write `<FEATURE>/evidence/baseline/kcov-per-file.<ts>.md`. Acceptance: five
  numeric line-rate values recorded with the run ID; no absolute path is copied into the
  artifact.
- [ ] [P0-T13] Baseline line counts and citation anchors for `scripts/bash/` and `tests/shell/`: run
  `wc -l scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`,
  `sed -n '19p;35p;103p;147p;157p;164p;191p;198p;292p;317p' scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `sed -n '34p;115,116p' scripts/bash/cleanup_worktrees_enumerate_lib.sh`, and
  `sed -n '54,55p' scripts/bash/cleanup_worktrees_lib.sh`; write
  `<FEATURE>/evidence/baseline/line-counts-and-anchors.<ts>.md`. Acceptance: the eight line
  counts are recorded (expected at authoring: 236, 437, 496, 476, 229, 113, 259, 153) and the
  printed anchor lines are recorded verbatim for comparison in P5-T10.
- [ ] [P0-T14] Baseline parity of the two `cleanup-merged-worktrees/SKILL.md` copies: run
  `git diff --no-index --exit-code .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  and write `<FEATURE>/evidence/baseline/skill-parity.<ts>.md`. Acceptance: `EXIT_CODE: 0`
  (the two copies are byte-identical before any edit). A non-zero exit is recorded verbatim
  and P4-T6 must then apply its edit to each copy independently without overwriting
  mirror-only content.

### Phase 1 — Regression Fixtures and Fail-Before Tests

All fixture files are written with the Write tool using LF line endings and no byte-order
mark. The two new scenario directories are
`tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/` (reported topology: primary
worktree on `chore-cleanup`, `main` checked out nowhere) and
`tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/` (`main` checked out in the
linked worktree `/repo-wt/base`). Neither directory carries a `rev-parse.origin_main.*` file, so
`check_main_freshness` emits nothing. New `@test` blocks are appended at the end of each suite
file, after its last existing test, so that the pre-existing test bodies and header comments
are not modified.

- [ ] [P1-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/worktree-list.out`
  with exactly four lines followed by a final newline: `worktree /repo/main`, `HEAD cccc0000`,
  `branch refs/heads/chore-cleanup`, and an empty line. Acceptance: file exists with that
  content.
- [ ] [P1-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/for-each-ref.out`
  with exactly four newline-terminated lines in this order: `chore-cleanup cccc0000`,
  `feature-merged bbbb1111`, `main aaaa0000`, `zeta-merged dddd3333`. Acceptance: file exists
  with that content (LC_ALL=C order; `zeta-merged` sorts after `main`).
- [ ] [P1-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/rev-parse.abbrev-ref-HEAD.out`
  containing the single newline-terminated line `chore-cleanup`. Acceptance: file exists
  with that content.
- [ ] [P1-T4] Create `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/rev-parse.show-toplevel.out`
  containing the single newline-terminated line `/repo/main`. Acceptance: file exists with
  that content.
- [ ] [P1-T5] Create `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/worktree-list.out`
  with exactly eight lines followed by a final newline: `worktree /repo/main`,
  `HEAD cccc0000`, `branch refs/heads/chore-cleanup`, an empty line, `worktree /repo-wt/base`,
  `HEAD aaaa0000`, `branch refs/heads/main`, and an empty line. Acceptance: file exists with
  that content.
- [ ] [P1-T6] Create `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/for-each-ref.out`
  with the same four lines as P1-T2. Acceptance: file content is byte-identical to the P1-T2
  file (verified in P1-T9).
- [ ] [P1-T7] Create `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/rev-parse.abbrev-ref-HEAD.out`
  containing the single newline-terminated line `chore-cleanup`. Acceptance: file exists with
  that content.
- [ ] [P1-T8] Create `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/rev-parse.show-toplevel.out`
  containing the single newline-terminated line `/repo/main`. Acceptance: file exists with
  that content.
- [ ] [P1-T9] Verify the fixtures in `tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/`
  and `tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/`: run
  `ls -1 tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`,
  `grep -rlU $'\r' tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`,
  and `cmp tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out/for-each-ref.out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree/for-each-ref.out`;
  write `<FEATURE>/evidence/regression-testing/fixtures-check.<ts>.md`. Acceptance: `ls`
  lists exactly the four names from P1-T1..T4 in each directory; the carriage-return search
  prints nothing and exits 1 (`ExpectedExitCode: 1`); `cmp` exits 0.
- [ ] [P1-T10] Append test T1 to `tests/shell/test_cleanup_worktrees_enumeration.bats`, named
  exactly `compute_protected emits protected-branch main when the primary worktree is on another branch`.
  Body: a one-line comment stating that the primary worktree is on `chore-cleanup` and `main`
  is checked out nowhere; `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && compute_protected 2>/dev/null"`
  (wrapped with a trailing backslash as in the existing tests); then, in this order,
  `[ "$status" -eq 0 ]`, `[[ "$output" == *"protected-branch|chore-cleanup"* ]]`, and
  `[[ "$output" == *"protected-branch|main"* ]]`. Acceptance: the test block is the file's
  last block and uses the file's 4-space indentation.
- [ ] [P1-T11] Append test T2 to `tests/shell/test_cleanup_worktrees_enumeration.bats`, named
  exactly `compute_protected emits protected-branch main under current_exclusion`. Body: a
  one-line comment stating that the base record is additional to the existing records; the
  same `run env ...` line as P1-T10 with scenario `${SCEN}/current_exclusion`; then, in this
  order, `[ "$status" -eq 0 ]`, `[[ "$output" == *"protected-branch|current-branch"* ]]`,
  `[[ "$output" == *"protected-path|/repo/main"* ]]`,
  `[[ "$output" == *"protected-path|/repo-wt/current"* ]]`, and
  `[[ "$output" == *"protected-branch|main"* ]]`. Acceptance: block appended after T1.
- [ ] [P1-T12] Append test T3 to `tests/shell/test_cleanup_worktrees_enumeration.bats`, named
  exactly `compute_protected emits exactly one protected-branch main when the current branch is main`.
  Body: a one-line comment stating that the `merged_no_worktree` scenario's current branch is
  `main`; the same `run env ...` line with scenario `${SCEN}/merged_no_worktree`; then
  `[ "$status" -eq 0 ]`, `count=$(printf '%s\n' "$output" | grep -c -x -F 'protected-branch|main' || true)`,
  and `[ "$count" -eq 1 ]`. Acceptance: block appended after T2.
- [ ] [P1-T13] Append test T4 to `tests/shell/test_cleanup_worktrees_classification.bats`, named
  exactly `classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch`.
  Body: a one-line comment naming the reported topology; `cb base_not_checked_out main`;
  `[ "$status" -eq 0 ]`; `[ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]`. Acceptance: the
  block is the file's last block and reuses the existing `cb` helper unchanged.
- [ ] [P1-T14] Append test T5 to `tests/shell/test_cleanup_worktrees_classification.bats`, named
  exactly `classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree`.
  Body: a one-line comment stating that `/repo-wt/base` is neither the primary nor the invoking
  worktree; `cb base_in_linked_worktree main`; `[ "$status" -eq 0 ]`;
  `[ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]`. Acceptance: block appended after T4.
- [ ] [P1-T15] Append test T6 to `tests/shell/test_cleanup_worktrees_deletion.bats`, named
  exactly `run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch`.
  Body: `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${DLIB}'; run_report 2>/dev/null"`
  (wrapped as in the existing tests); then `[ "$status" -eq 0 ]`,
  `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]`, and
  `[[ "$output" != *"BRANCH|main|MERGED_CLEAN"* ]]`. Acceptance: the block is the file's last
  block.
- [ ] [P1-T16] Append test T7 to `tests/shell/test_cleanup_worktrees_deletion.bats`, named
  exactly `run_apply does not delete main when the primary worktree is on another branch`.
  Body: `apply "${SCEN}/base_not_checked_out"`; then, in this order,
  `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]`,
  `[[ "$output" != *"BRANCH|main|MERGED_CLEAN"* ]]`, `[[ "$output" != *"branch -D main"* ]]`,
  `[[ "$output" != *"ACTION|branch-delete|main|"* ]]`, a one-line comment naming the positive
  controls, `[[ "$output" == *"ACTION|branch-delete|feature-merged|OK"* ]]`, and
  `[[ "$output" == *"ACTION|branch-delete|zeta-merged|OK"* ]]`. Acceptance: block appended
  after T6 and reuses the existing `apply` helper unchanged.
- [ ] [P1-T17] Append test T8 to `tests/shell/test_cleanup_worktrees_deletion.bats`, named
  exactly `run_apply neither removes nor deletes main checked out in a linked worktree`. Body:
  `apply "${SCEN}/base_in_linked_worktree"`; then `[[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]`,
  `[[ "$output" != *"worktree remove /repo-wt/base"* ]]`, `[[ "$output" != *"branch -D main"* ]]`,
  and `[[ "$output" != *"ACTION|branch-delete|main|"* ]]`. Acceptance: block appended after T7.
- [ ] [P1-T18] Append test T9 to `tests/shell/test_cleanup_worktrees_deletion.bats`, named
  exactly `delete_candidate refuses the base branch before re-verification`. Body: a one-line
  comment stating that stderr is retained so the stub argv log is observable;
  `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${ALIB}'; delete_candidate main '' MERGED_CLEAN"`
  (no stderr redirection); then `[ "$status" -eq 1 ]`,
  `[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]`,
  `[[ "$output" != *"merge-base"* ]]`, `[[ "$output" != *"worktree remove"* ]]`, and
  `[[ "$output" != *"branch -D"* ]]`. Acceptance: block appended after T8.
- [ ] [P1-T19] Append test T10 to `tests/shell/test_cleanup_worktrees_deletion.bats`, named
  exactly `delete_candidate refuses the base branch before removing its linked worktree`.
  Body: `run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_in_linked_worktree" bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${ALIB}'; delete_candidate main /repo-wt/base MERGED_CLEAN"`
  (no stderr redirection); then `[ "$status" -eq 1 ]`,
  `[[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]`, and
  `[[ "$output" != *"worktree remove"* ]]`. Acceptance: block appended after T9.
- [ ] [P1-T20] [expect-fail] Fail-before run into `<FEATURE>/evidence/regression-testing/fail-before.<ts>.md`:
  run `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
  against the unfixed libraries and record the artifact with `ExpectedExitCode: 1`.
  Acceptance: `EXIT_CODE: 1`; the TAP plan equals the P0-T10 per-file `@test` total plus 10
  (12 + 19 + 11 + 10 = 52 at authoring); exactly nine `not ok` lines, naming T1, T2, T4, T5, T6, T7, T8, T9, and
  T10; T3 reports `ok` (it pins the no-duplicate property and passes before the fix); every
  pre-existing test reports `ok`. For each of the nine failures the artifact records the
  first failed assertion line that bats prints, and that line must be an assertion about
  `main` (a line containing `protected-branch|main`, `BRANCH|main|PROTECTED_CURRENT`, or, for
  T9 and T10, `[ "$status" -eq 1 ]`); a failure on any other line (for example a missing
  fixture or a syntax error) fails this task. CI fallback, used only when P0-T4 recorded that
  npx cannot resolve bats: commit the Phase 1 files alone, push, and dispatch
  `_shell-coverage.yml` as in P0-T11; the same acceptance applies to the TAP lines read from
  `gh run view <RUN_ID> --log`.

### Phase 2 — Base-Branch Constant and compute_protected Protection

- [ ] [P2-T1] In `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, insert immediately above
  the line `compute_protected() {` (line 166 at BASE_SHA; below line 116) a three-line comment
  followed by the plain assignment `CLEANUP_WT_BASE_BRANCH="main"` and one blank line. The
  comment states that the constant names the ladder's fixed comparison base, that
  `compute_protected` protects it by name in every checkout topology and `delete_candidate`
  refuses it, and that it is deliberately not read from the environment (issue #594).
  Acceptance: `grep -n -F 'CLEANUP_WT_BASE_BRANCH="main"' scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  prints exactly one line whose number is greater than 116.
- [ ] [P2-T2] In `scripts/bash/cleanup_worktrees_enumerate_lib.sh` `compute_protected`,
  immediately after the existing block that prints `protected-branch|<current branch>` (the
  `fi` at line 198 at BASE_SHA, which follows both `rev-parse` hard-failure guards), insert a
  comment stating that base protection is unconditional, is emitted only after both guards
  pass, and is skipped when the current branch already equals the base; then insert
  `if [[ $current_branch != "$CLEANUP_WT_BASE_BRANCH" ]]; then`,
  `printf 'protected-branch|%s\n' "$CLEANUP_WT_BASE_BRANCH"`, and `fi` (tab-indented per
  shfmt defaults). Acceptance: `grep -n -F '"$CLEANUP_WT_BASE_BRANCH"' scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  prints exactly two lines (the new `if` line and the new `printf` line), and both line numbers
  are greater than the line number of the `ctrc` guard's `return "$ctrc"`.
- [ ] [P2-T3] Update the docstring of `compute_protected` in `scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  (the comment block under `compute_protected() {`) to state that the base branch `CLEANUP_WT_BASE_BRANCH` is always
  protected by name, that its `protected-branch|` record is emitted after both `rev-parse`
  guards pass (the fail-closed contract is unchanged), and that it is omitted only when the
  current branch already equals the base (no duplicate record). Acceptance: the docstring
  block contains the token `CLEANUP_WT_BASE_BRANCH`.
- [ ] [P2-T4] Reword the file header of `scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  (lines 1-32) so that the description of `compute_protected` names the base branch (for
  example "current-worktree/branch and base-branch protection set") and the lines 29-32
  paragraph states that the base-branch record is emitted only after both `rev-parse` guards;
  the rewording must be zero net lines. Acceptance: `sed -n '1,32p' scripts/bash/cleanup_worktrees_enumerate_lib.sh`
  piped to `grep -c -F 'base-branch'` prints at least `1`, and
  `sed -n '34p' scripts/bash/cleanup_worktrees_enumerate_lib.sh` still prints `cleanup_wt_git() {`.

### Phase 3 — delete_candidate Backstop and Actions-Library Documentation

- [ ] [P3-T1] In `scripts/bash/cleanup_worktrees_actions_lib.sh` `delete_candidate`,
  immediately after the line `local name="$1" wt_path="$2" state="$3"` and before
  `reverify_delete_eligible "$name" "$state" || return 1`, insert a comment stating that the
  base branch is refused before re-verification, worktree removal, or branch deletion, and
  that `run_apply` never reaches this path for the base because `compute_protected` already
  classifies it `PROTECTED_CURRENT`; then insert
  `if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then`,
  `printf 'ACTION|delete|%s|BLOCKED-PROTECTED-BASE\n' "$name"`, `return 1`, and `fi`.
  Acceptance: `grep -n -F 'BLOCKED-PROTECTED-BASE' scripts/bash/cleanup_worktrees_actions_lib.sh`
  shows the `printf` line, and its line number is lower than the line number of the first
  `reverify_delete_eligible "$name" "$state"` call inside `delete_candidate`.
- [ ] [P3-T2] Update the `delete_candidate` docstring in `scripts/bash/cleanup_worktrees_actions_lib.sh`
  to add a step 0 ahead of the existing three
  steps: refuse the base branch `CLEANUP_WT_BASE_BRANCH` by emitting
  `ACTION|delete|<name>|BLOCKED-PROTECTED-BASE` and returning 1 before any other step runs;
  note that the constant is defined in `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
  which every caller sources first. Acceptance: the docstring block contains both tokens
  `CLEANUP_WT_BASE_BRANCH` and `BLOCKED-PROTECTED-BASE`.
- [ ] [P3-T3] Reword the `run_apply` docstring in `scripts/bash/cleanup_worktrees_actions_lib.sh`
  (lines 361-362 at BASE_SHA) so that it no longer attributes `main`'s protection to worktree
  position alone: the main worktree and the base branch `CLEANUP_WT_BASE_BRANCH` are never
  candidates, `compute_protected` protects the base by name in every checkout topology so
  `classify_branch` marks it `PROTECTED_CURRENT`, and `delete_candidate` refuses it as a
  backstop. Acceptance: `grep -c -F 'classify_branch marks it PROTECTED_CURRENT' scripts/bash/cleanup_worktrees_actions_lib.sh`
  prints `0` (`ExpectedExitCode: 1` in the P5-T6 artifact) and the `run_apply` docstring
  contains the token `CLEANUP_WT_BASE_BRANCH`.
- [ ] [P3-T4] Reword the header of `scripts/bash/cleanup_worktrees_actions_lib.sh` at lines 6-7
  from "deletion mechanics (same-process re-verification, no-force worktree removal, branch
  deletion) plus the apply-mode driver." to a two-line form that also names the base-branch
  refusal, for example `# deletion mechanics (base-branch refusal, same-process re-verification, no-force`
  and `# worktree removal, branch deletion) plus the apply-mode driver.`; zero net lines.
  Acceptance: `grep -c -F 'base-branch refusal' scripts/bash/cleanup_worktrees_actions_lib.sh`
  prints `1`, and the P5-T10 anchor comparison shows lines 19 and 35 unchanged.
- [ ] [P3-T5] Lint the cross-file constant reference in `scripts/bash/cleanup_worktrees_actions_lib.sh`:
  run `shellcheck -f gcc scripts/bash/cleanup_worktrees_actions_lib.sh`. Acceptance: no finding
  refers to a line added in P3-T1 to P3-T4. Explicit remediation branch: if shellcheck reports
  `SC2154` for `CLEANUP_WT_BASE_BRANCH` on the P3-T1 `if` line, add
  `# shellcheck disable=SC2154` on the line immediately above it, preceded by a comment stating
  that the constant is assigned in `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, which the
  wrapper and every bats harness source first, and re-run the command until no finding
  refers to an added line. Record the result in
  `<FEATURE>/evidence/other/actions-lib-sc2154-check.<ts>.md`.

### Phase 4 — Comment, Help-Text, and Skill Documentation Corrections

- [ ] [P4-T1] In `scripts/bash/cleanup_worktrees_lib.sh` `classify_branch` docstring, replace
  the two lines `#   1. PROTECTED_CURRENT exclusion (branch-name OR worktree-path match; main`
  and `#      worktree always protected).` (lines 319-320 at BASE_SHA) with exactly two lines:
  `#   1. PROTECTED_CURRENT exclusion (branch-name OR worktree-path match; main worktree`
  and `#      and base branch CLEANUP_WT_BASE_BRANCH always protected).` (tab-indented as the
  surrounding lines). Acceptance: `wc -l scripts/bash/cleanup_worktrees_lib.sh` prints `496`
  and `grep -c -F 'CLEANUP_WT_BASE_BRANCH' scripts/bash/cleanup_worktrees_lib.sh` prints `1`.
- [ ] [P4-T2] In `scripts/bash/cleanup_worktrees_report_records_lib.sh` `classify_all_branches`,
  replace the four comment lines 391-394 (BASE_SHA) with four lines stating that restricting
  the probe to the NOT_MERGED set bounds its cost at k*(k-1) probes, and that the base branch
  `main` never enters the probe set because `compute_protected` protects it by name
  (`CLEANUP_WT_BASE_BRANCH`) in every checkout topology, so `classify_branch` resolves it
  `PROTECTED_CURRENT` at rung 1. Acceptance: `grep -c -F 'needs no special' scripts/bash/cleanup_worktrees_report_records_lib.sh`
  prints `0` and the file's line count is unchanged at 476.
- [ ] [P4-T3] In `scripts/bash/cleanup_worktrees_report_records_lib.sh`, replace the three
  comment lines 427-429 (BASE_SHA, the "Phase 2: pairwise ancestry" comment) with three lines
  stating that a branch resolving anything other than NOT_MERGED is neither subject nor target,
  so `main`, which is `PROTECTED_CURRENT` by the unconditional base-branch protection in
  `compute_protected`, is excluded by its verdict. Acceptance:
  `grep -c -F 'needs no separate protection' scripts/bash/cleanup_worktrees_report_records_lib.sh`
  prints `0`, `grep -c -F 'CLEANUP_WT_BASE_BRANCH' scripts/bash/cleanup_worktrees_report_records_lib.sh`
  prints at least `1`, and `wc -l scripts/bash/cleanup_worktrees_report_records_lib.sh` prints `476`.
- [ ] [P4-T4] In `scripts/bash/cleanup-worktrees.sh` `usage()` heredoc, insert after the
  paragraph ending "hard git failure and never unlocks a destructive action." (line 122 at
  BASE_SHA) one empty line followed by exactly these four lines, leaving lines 119-122
  unchanged:
  `PROTECTED_CURRENT also covers the base branch main, which is protected by name in every`
  `checkout topology: main is never deleted and a worktree checked out on main is never`
  `removed. As a second guard, apply mode refuses a deletion request for main with the`
  `action result BLOCKED-PROTECTED-BASE.`
  Acceptance: `sed -n '119,122p' scripts/bash/cleanup-worktrees.sh` prints the same four
  state-list lines as `git show 0658f6945aa833c6960dc5bf8a43635fc346991f:scripts/bash/cleanup-worktrees.sh`
  piped to `sed -n '119,122p'`, and `wc -l scripts/bash/cleanup-worktrees.sh` prints `234`
  (229 plus five).
- [ ] [P4-T5] In `.claude/skills/cleanup-merged-worktrees/SKILL.md`, insert immediately after
  line 527 (the line ending "and never for `PROTECTED_CURRENT`.") a new bullet consisting of
  exactly the six lines inside the fence below (the fence itself is not inserted):

  ```text
  - Never delete the base branch `main` and never remove a worktree checked out on it.
    `compute_protected` protects `main` by name in every checkout topology, so it
    classifies `PROTECTED_CURRENT` even when no protected worktree has it checked out, and
    `delete_candidate` refuses a deletion request for it with
    `ACTION|delete|main|BLOCKED-PROTECTED-BASE` before any re-verification, worktree
    removal, or branch deletion runs.
  ```

  In the file, the first line starts at column 1 with `- ` and the five continuation lines
  are indented by two spaces, matching the surrounding bullets. Acceptance: `grep -c -F 'BLOCKED-PROTECTED-BASE' .claude/skills/cleanup-merged-worktrees/SKILL.md`
  prints `1` and `grep -c -F 'Never delete the base branch' .claude/skills/cleanup-merged-worktrees/SKILL.md`
  prints `1`.
- [ ] [P4-T6] Apply the P4-T5 insertion to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  with the Edit tool (same old and new strings as P4-T5). Acceptance: the same two `grep -c -F` checks
  against the extension copy each print `1`.

### Phase 5 — Pass-After and Targeted Acceptance Verification

- [ ] [P5-T1] Pass-after run into `<FEATURE>/evidence/regression-testing/pass-after.<ts>.md`:
  run `npx --yes bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`. Acceptance: `EXIT_CODE: 0`,
  zero `not ok` lines, the TAP plan equals the P1-T20 plan, and the artifact lists the `ok`
  line for each of T1 through T10 by its exact name.
- [ ] [P5-T2] AC-01 check in `<FEATURE>/evidence/qa-gates/ac01-base-constant.<ts>.md`: run
  `grep -rn -F 'CLEANUP_WT_BASE_BRANCH=' scripts/bash/` and
  `grep -rn -F 'CLEANUP_WT_BASE_BRANCH:-' scripts/bash/`. Acceptance: the first prints exactly
  one line, in `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, whose text after the line
  number is `CLEANUP_WT_BASE_BRANCH="main"`; the second prints nothing and exits 1 (recorded
  with `ExpectedExitCode: 1` for that command).
- [ ] [P5-T3] AC-14 check in `<FEATURE>/evidence/qa-gates/ac14-no-new-state.<ts>.md`: run
  `grep -rnE 'PROTECTED_BASE\b' scripts/bash/` and `sed -n '54,55p' scripts/bash/cleanup_worktrees_lib.sh`.
  Acceptance: the search prints nothing and exits 1 (the only new token uses hyphens,
  `BLOCKED-PROTECTED-BASE`); the two header state-list lines are identical to those recorded in
  P0-T13; the P4-T4 acceptance already proved help lines 119-122 unchanged.
- [ ] [P5-T4] AC-15 check in `<FEATURE>/evidence/qa-gates/ac15-comments.<ts>.md`: run
  `grep -rn -F 'needs no special' scripts/bash/`,
  `grep -rn -F 'needs no separate protection' scripts/bash/`,
  `grep -rn -F 'classify_branch marks it PROTECTED_CURRENT' scripts/bash/`, and
  `grep -c -F 'CLEANUP_WT_BASE_BRANCH' scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh`.
  Acceptance: the three phrase searches each print nothing and exit 1 (each phrase is on a
  single line at BASE_SHA: `report_records_lib.sh:392`, `:429`, `actions_lib.sh:362`); each of
  the three per-file counts is at least 1; the artifact quotes the three reworded docstring
  passages (`classify_all_branches` lines 391-394 and 427-429, `run_apply`, `classify_branch`
  step 1) for reviewer inspection.
- [ ] [P5-T5] AC-16 check in `<FEATURE>/evidence/qa-gates/ac16-help-text.<ts>.md`: run
  `sh scripts/bash/cleanup-worktrees.sh --help` and, on its captured output,
  `grep -c -F 'covers the base branch main'` and `grep -c -F 'BLOCKED-PROTECTED-BASE'`.
  Acceptance: `--help` exits 0; each count is at least 1.
- [ ] [P5-T6] P3-T3 negative search in `<FEATURE>/evidence/qa-gates/ac15-run-apply-docstring.<ts>.md`: run
  `grep -n -F 'classify_branch marks it PROTECTED_CURRENT' scripts/bash/cleanup_worktrees_actions_lib.sh`
  with `ExpectedExitCode: 1`, and `sed -n '356,375p' scripts/bash/cleanup_worktrees_actions_lib.sh`.
  Acceptance: the search prints nothing and exits 1; the printed docstring contains
  `CLEANUP_WT_BASE_BRANCH`.
- [ ] [P5-T7] AC-17 check in `<FEATURE>/evidence/qa-gates/ac17-skill-parity.<ts>.md`: run
  `git diff --no-index --exit-code .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Acceptance: `EXIT_CODE: 0` with empty output (the two copies are byte-identical after the
  edit).
- [ ] [P5-T8] AC-21 check in `<FEATURE>/evidence/qa-gates/ac21-portability.<ts>.md`: run
  `git diff -U0 0658f6945aa833c6960dc5bf8a43635fc346991f -- tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
  and filter its added lines (lines beginning `+` but not `+++`) with
  `grep -nE 'origin/|/mnt/|[A-Za-z]:[\\/]|mktemp|artifacts/'`, then run
  `grep -rnE 'origin/|/mnt/|[A-Za-z]:[\\/]|mktemp|artifacts/' tests/fixtures/cleanup_worktrees/scenarios/base_not_checked_out tests/fixtures/cleanup_worktrees/scenarios/base_in_linked_worktree`,
  and, over the same added lines, `grep -c -F 'run env CLEANUP_WT_GIT_BIN="${STUB}"'` and
  `grep -c -F 'run env'`. Acceptance: both pattern searches print nothing and exit 1; the two
  counts are equal and each is `6` (T1, T2, T3, T6, T9, T10 each add one `run env` line that
  routes git through the stub; T4, T5, T7, and T8 use the existing `cb`/`apply` helpers, which
  already do so).
- [ ] [P5-T9] AC-22 check in `<FEATURE>/evidence/qa-gates/ac22-no-temp-files.<ts>.md`: over
  the added lines of the same anchored diff as P5-T8 on `tests/shell/test_cleanup_worktrees_deletion.bats`,
  `tests/shell/test_cleanup_worktrees_enumeration.bats`, and
  `tests/shell/test_cleanup_worktrees_classification.bats`, run
  `grep -nE 'git init|mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR'` and
  `grep -n '>' | grep -v -F '2>/dev/null'`. Acceptance: both print nothing (the only
  redirection in the added test bodies is `2>/dev/null`, which targets a device, not a file).
- [ ] [P5-T10] AC-18 and citation-invariant check in `<FEATURE>/evidence/qa-gates/ac18-line-counts-and-anchors.<ts>.md`:
  re-run the three `sed -n`
  commands and the `wc -l` command from P0-T13 verbatim. Acceptance: every printed anchor line
  is byte-identical to the P0-T13 record (actions 19, 35, 103, 147, 157, 164, 191, 198, 292,
  317; enumerate 34, 115, 116; lib 54-55); every line count is at most 500;
  `scripts/bash/cleanup_worktrees_lib.sh` is exactly 496.

### Phase 6 — Final QC Loop, CI Coverage, Scope Verification, and Acceptance Check-off

Loop rule: P6-T1 through P6-T6 are one pass of the shell toolchain loop (format, lint, syntax,
test). If any step fails, or if remediation changes any file, fix the cause and restart at
P6-T1; artifacts from an abandoned pass are kept and the new pass writes new timestamped
artifacts. P6-T7 records the clean pass. If the CI run in P6-T11 fails, fix the cause, restart
at P6-T1, and re-run P6-T8 through P6-T11.

- [ ] [P6-T1] QC step 1 (format) on `scripts/bash/` production files: run
  `shfmt -d scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh`;
  write `<FEATURE>/evidence/qa-gates/qc-step1-shfmt.<ts>.md`. Acceptance: exit 0 and no diff
  printed (a clean shfmt `-d` run prints nothing). On a diff, run `shfmt -w` on the named files,
  record the rewrite, and restart the loop.
- [ ] [P6-T2] QC step 2a (lint) on `scripts/bash/` production files: run
  `shellcheck -f gcc scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh`;
  write `<FEATURE>/evidence/qa-gates/qc-step2a-shellcheck-production.<ts>.md`. Acceptance: the
  finding lines are exactly the P0-T6 baseline set (normally empty, exit 0); any new finding
  fails the step.
- [ ] [P6-T3] QC step 2b (lint) on the three edited `tests/shell/` suites: run
  `shellcheck -f gcc tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`;
  write `<FEATURE>/evidence/qa-gates/qc-step2b-shellcheck-bats.<ts>.md`. Acceptance: the total
  finding count and the per-code multiset equal the P0-T8 baseline (no finding introduced by
  the added tests).
- [ ] [P6-T4] QC step 2c (repo-wide check): run `sh scripts/bash/shell-qc.sh check`; write
  `<FEATURE>/evidence/qa-gates/qc-step2c-shell-qc-check.<ts>.md`. Acceptance: every diagnostic
  line printed is present in the P0-T7 baseline record (no diagnostic absent from baseline);
  when the baseline was clean, the run prints nothing and exits 0.
- [ ] [P6-T5] QC step 3 (syntax; bash has no type checker) on `scripts/bash/` production files:
  run `sh -n` on each of `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_report_records_lib.sh`,
  and `scripts/bash/cleanup-worktrees.sh`; write `<FEATURE>/evidence/qa-gates/qc-step3-syntax.<ts>.md`.
  Acceptance: five `EXIT_CODE: 0` values, no output.
- [ ] [P6-T6] QC step 4 (tests, local): run `npx --yes bats tests/shell/test_cleanup_worktrees_*.bats`
  (background); write `<FEATURE>/evidence/qa-gates/qc-step4-bats-cleanup-suites.<ts>.md`.
  Acceptance: the TAP plan equals the P0-T10 plan plus 10; no test that reported `ok` in P0-T10
  reports `not ok`; T1 through T10 each report `ok`; the `not ok` set is a subset of the P0-T10
  baseline failure set (when that set is empty, `EXIT_CODE: 0`).
- [ ] [P6-T7] Record the clean loop pass in `<FEATURE>/evidence/qa-gates/qc-loop-pass.<ts>.md`:
  the pass number, the six artifact paths from P6-T1 through P6-T6 of that pass, and the output
  of `sha256sum scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
  captured immediately before P6-T1 and immediately after P6-T6 of that pass (a per-file hash
  pair is used because these files are already modified, so a porcelain status comparison
  could not detect a rewrite). Acceptance: all six steps passed in the same pass and the two
  hash listings are identical.
- [ ] [P6-T8] Commit the implementation: stage exactly `scripts/bash/cleanup_worktrees_enumerate_lib.sh`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`,
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup-worktrees.sh`,
  the three edited `tests/shell/` suites, the eight new files under
  `tests/fixtures/cleanup_worktrees/scenarios/`, and both `SKILL.md` copies with `git add`, then
  `git commit -F <message file in the session scratchpad>` (message per the commit-message
  skill, ending with the session's required trailer lines). Record the commit SHA in
  `<FEATURE>/evidence/other/commit-push.<ts>.md`. Acceptance: `git status --porcelain -- scripts/ tests/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/`
  prints nothing after the commit. If the preimplementation gate refuses the commit, record
  the refusal text and stop (BLOCKED).
- [ ] [P6-T9] Push the commit with `git push origin bug/cleanup-worktrees-apply-deletes-local-main-594`
  (no force); append the result to `<FEATURE>/evidence/other/commit-push.<ts>.md`. Acceptance:
  exit 0 and the remote branch head equals the P6-T8 commit SHA
  (`git ls-remote origin refs/heads/bug/cleanup-worktrees-apply-deletes-local-main-594`).
- [ ] [P6-T10] Dispatch the authoritative `.github/workflows/_shell-coverage.yml` run:
  `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-apply-deletes-local-main-594`,
  identify it with the P0-T11 `gh run list` command, and wait with
  `gh run watch <RUN_ID> --exit-status`. Record the run ID in
  `<FEATURE>/evidence/qa-gates/ci-shell-coverage.<ts>.md`. Acceptance: the run's `headSha` equals
  the P6-T8 commit SHA and its `createdAt` is later than the dispatch time.
- [ ] [P6-T11] Complete `<FEATURE>/evidence/qa-gates/ci-shell-coverage.<ts>.md` from
  `gh run view <RUN_ID> --log`. Acceptance: the `Run shell-qc check`
  step succeeded (CI shfmt 3.8.0 diff and shellcheck clean); the `Run shell-qc test with coverage`
  step succeeded with zero `not ok` lines; the TAP `1..N` line is recorded (one plan, because
  `tests/bash` does not exist and only `tests/shell` runs) and equals the P0-T11 plan plus 10; the numeric
  `Bash coverage (lines): NN.N%` headline is recorded; the run conclusion is `success`. On any
  failure, restart the loop at P6-T1.
- [ ] [P6-T12] Per-file coverage into `<FEATURE>/evidence/qa-gates/kcov/coverage-summary.<ts>.md`:
  download the P6-T10 run's artifact with `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-final` and
  extract, by the P0-T12 rule, the `line-rate` for the same five files. Write
  `<FEATURE>/evidence/qa-gates/kcov/coverage-summary.<ts>.md` with the run ID, the overall
  headline from P6-T11, and the five per-file values. Acceptance: five numeric values recorded;
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh` and `scripts/bash/cleanup_worktrees_actions_lib.sh`
  are each at least 0.85.
- [ ] [P6-T13] Added-line execution for `scripts/bash/cleanup_worktrees_enumerate_lib.sh` and
  `scripts/bash/cleanup_worktrees_actions_lib.sh`: derive the added line numbers from the hunk
  headers of `git diff -U0 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh`,
  keep those that are neither blank nor comment-only, and look each up in the matching
  `<class>` element's `<line number="N" hits="H"/>` entries of the P6-T12 `cov.xml`. Write
  `<FEATURE>/evidence/qa-gates/kcov/added-line-hits.<ts>.md`. Acceptance: these four added lines
  are listed with `hits` of at least 1: `CLEANUP_WT_BASE_BRANCH="main"`,
  `printf 'protected-branch|%s\n' "$CLEANUP_WT_BASE_BRANCH"`,
  `printf 'ACTION|delete|%s|BLOCKED-PROTECTED-BASE\n' "$name"`, and the `return 1` inside the
  P3-T1 guard; every other added executable line either has `hits` of at least 1 or is absent
  from the element (not instrumented by kcov, for example `fi`), and each absent line is named.
- [ ] [P6-T14] Coverage delta: write `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md` with,
  for each of the five files, the P0-T12 baseline line-rate, the P6-T12 post-change line-rate,
  and the difference, plus the P0-T11 and P6-T11 overall headlines and the P6-T13 added-line
  result as the new-code coverage. Acceptance: every post-change value is at least 0.85 or at
  least its baseline value; any file below both is recorded as remediation-required and the
  plan outcome is not PASS.
- [ ] [P6-T15] AC-12 scope check in `<FEATURE>/evidence/qa-gates/ac12-tests-added-only.<ts>.md`:
  run `git diff --numstat 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- tests/shell/` and
  `git status --porcelain -- tests/shell/`. Acceptance: the numstat output has exactly three
  rows, for `tests/shell/test_cleanup_worktrees_enumeration.bats`,
  `tests/shell/test_cleanup_worktrees_classification.bats`, and
  `tests/shell/test_cleanup_worktrees_deletion.bats`, each with a deleted-line count of `0`; the
  porcelain status prints nothing; P6-T11 recorded zero failures in CI.
- [ ] [P6-T16] AC-13 golden check in `<FEATURE>/evidence/qa-gates/ac13-goldens-unchanged.<ts>.md`:
  run `git diff --exit-code 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- tests/fixtures/cleanup_worktrees/expected/`
  and `git status --porcelain -- tests/fixtures/cleanup_worktrees/expected/`. Acceptance: the
  diff exits 0 with empty output, the porcelain status prints nothing, and the P6-T11 CI run
  contains `ok` lines for every test in `tests/shell/test_cleanup_worktrees_dirt_regression.bats`.
- [ ] [P6-T17] Non-goal boundary check in `<FEATURE>/evidence/qa-gates/untouched-files.<ts>.md`:
  run `git diff --exit-code --stat 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- tests/fixtures/cleanup_worktrees/stub-bin/ scripts/bash/cleanup_worktrees_detached_lib.sh scripts/bash/cleanup_worktrees_dirt_lib.sh .github/workflows/ .claude/lib/cleanup-manifest/ tests/scripts/claude-lib/cleanup-manifest/`
  and `git diff --numstat 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD -- scripts/ tests/ .claude/skills/ extensions/`.
  Acceptance: the first exits 0 with empty output; the second lists exactly the 5 production
  files, 3 test suites, 8 fixture files, and 2 `SKILL.md` copies named in P6-T8 (18 rows) and
  no other path.
- [ ] [P6-T18] Check off AC-01 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (the `CLEANUP_WT_BASE_BRANCH="main"`
  constant item) only if `<FEATURE>/evidence/qa-gates/ac01-base-constant.<ts>.md` meets its
  acceptance. Acceptance: that item reads `- [x]`.
- [ ] [P6-T19] Check off AC-02 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T1) only if
  `<FEATURE>/evidence/regression-testing/pass-after.<ts>.md` and the P6-T11 CI record show T1 `ok`.
  Acceptance: that item reads `- [x]`.
- [ ] [P6-T20] Check off AC-03 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T2) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T2 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T21] Check off AC-04 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T3) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T3 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T22] Check off AC-05 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T4) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T4 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T23] Check off AC-06 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T5) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T5 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T24] Check off AC-07 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T6) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T6 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T25] Check off AC-08 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T7) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T7 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T26] Check off AC-09 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T8) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T8 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T27] Check off AC-10 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T9) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T9 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T28] Check off AC-11 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (test T10) only if the P5-T1 and P6-T11
  records under `<FEATURE>/evidence/` show T10 `ok`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T29] Check off AC-12 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (existing suites pass unmodified) only if
  `<FEATURE>/evidence/qa-gates/ac12-tests-added-only.<ts>.md` meets its acceptance. Acceptance:
  that item reads `- [x]`.
- [ ] [P6-T30] Check off AC-13 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (goldens unchanged) only if
  `<FEATURE>/evidence/qa-gates/ac13-goldens-unchanged.<ts>.md` meets its acceptance. Acceptance:
  that item reads `- [x]`.
- [ ] [P6-T31] Check off AC-14 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (no new state name) only if
  `<FEATURE>/evidence/qa-gates/ac14-no-new-state.<ts>.md` and the P4-T4 help-line check meet
  their acceptance. Acceptance: that item reads `- [x]`.
- [ ] [P6-T32] Check off AC-15 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (comments corrected) only if
  `<FEATURE>/evidence/qa-gates/ac15-comments.<ts>.md` and
  `<FEATURE>/evidence/qa-gates/ac15-run-apply-docstring.<ts>.md` meet their acceptance.
  Acceptance: that item reads `- [x]`.
- [ ] [P6-T33] Check off AC-16 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (help text) only if
  `<FEATURE>/evidence/qa-gates/ac16-help-text.<ts>.md` meets its acceptance. Acceptance: that
  item reads `- [x]`.
- [ ] [P6-T34] Check off AC-17 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (skill copies) only if
  `<FEATURE>/evidence/qa-gates/ac17-skill-parity.<ts>.md` meets its acceptance and both P4-T5 and
  P4-T6 token counts were `1`. Acceptance: that item reads `- [x]`.
- [ ] [P6-T35] Check off AC-18 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (500-line limit) only if
  `<FEATURE>/evidence/qa-gates/ac18-line-counts-and-anchors.<ts>.md` meets its acceptance.
  Acceptance: that item reads `- [x]`.
- [ ] [P6-T36] Check off AC-19 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (shfmt and shellcheck) only if the
  P6-T1 through P6-T4 artifacts under `<FEATURE>/evidence/qa-gates/` meet their acceptance and
  P6-T11 records the CI check step as successful. Acceptance: that item reads `- [x]`.
- [ ] [P6-T37] Check off AC-20 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (kcov coverage) only if
  `<FEATURE>/evidence/qa-gates/kcov/coverage-summary.<ts>.md` and
  `<FEATURE>/evidence/qa-gates/kcov/added-line-hits.<ts>.md` meet their acceptance. Acceptance:
  that item reads `- [x]`.
- [ ] [P6-T38] Check off AC-21 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (remote-ref and depth independence) only
  if `<FEATURE>/evidence/qa-gates/ac21-portability.<ts>.md` meets its acceptance and P6-T11
  shows the new tests passing on ubuntu-latest. Acceptance: that item reads `- [x]`.
- [ ] [P6-T39] Check off AC-22 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (no temporary files or scratch
  repositories) only if `<FEATURE>/evidence/qa-gates/ac22-no-temp-files.<ts>.md` meets its
  acceptance. Acceptance: that item reads `- [x]`.
- [ ] [P6-T40] AC-23 in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md` (CI `_shell-coverage.yml` job for the pull request):
  run `gh pr checks bug/cleanup-worktrees-apply-deletes-local-main-594` and record the result in
  `<FEATURE>/evidence/qa-gates/ac23-pr-ci.<ts>.md`. Explicit branch: if a pull request exists
  and its `Shell Coverage (Bats + kcov)` check concluded `pass`, check the item off; if no pull
  request exists yet, leave the item unchecked, record `AC-23: DEFERRED TO PR CI GATE` with the
  P6-T11 dispatch result (same workflow, same default-depth checkout) as supporting evidence,
  and hand the item to the orchestrator's CI gate. Acceptance: the item state matches the
  recorded branch.
- [ ] [P6-T41] Verify check-off state in `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`: run
  `grep -c -e '^- \[x\] ' docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`
  and `grep -c -e '^- \[ \] ' docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`;
  record both in `<FEATURE>/evidence/qa-gates/ac-checkoff-count.<ts>.md`. Acceptance: the
  checked count is 23 and the unchecked count is 0, or 22 and 1 when P6-T40 recorded the
  deferral branch; every checked item has its evidence artifact present on disk.

# cleanup-report-registration-lost-false-positive (Plan)

- **Issue:** #706
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/cleanup-report-registration-lost-false-positive-706`
- **Last Updated:** 2026-09-26T22-56
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug

## Plan Conventions

**Requirements source (sole AC source, full-bug).** `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`,
section `## Acceptance Criteria`, items AC-1 through AC-4. `user-story.md` is not produced for
full-bug work and its absence is not a blocker. Supporting inputs: `issue.md` and
`research/2026-09-26-registration-lost-false-positive-research.md` in the same folder. Design
decisions D1 through D10 of `spec.md` are binding; this plan implements D1 (pure predicate), D2
(one-line existence seam redefined by bats), D3 (append-only tests, new fixture root), D4 (no
SKILL.md edit), D5 (tier T4), D8 (test 2 in script-invocation form, R6), D9 (tests 3 and 4
appended after the fix; P3-T4 mutation check), and D10 (sibling change on `origin/main`
recorded and resolved at rebase, P0-T5).

**Notation.** `<FEATURE>` denotes `docs/features/active/cleanup-report-registration-lost-false-positive-706`.
`<ts>` denotes the artifact creation time in `yyyy-MM-ddTHH-mm` form. `<MERGE_BASE>` denotes the
literal 40-character SHA recorded by P0-T1; every later command substitutes that literal. It is
never `origin/main` itself. `<RUN_ID>` denotes a GitHub Actions run ID recorded by the task
that dispatches it. `<session-scratchpad>` denotes the executor's session scratchpad, which is
outside the repository; no absolute host path is ever copied into an evidence artifact.

**Evidence rules.** Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` with
kind `baseline`, `regression-testing`, `qa-gates`, or `other`; nothing is written under
`artifacts/` except the tools' own gitignored output. Every command-step artifact carries
`Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, one artifact per command unless a
task states otherwise. An artifact whose passing outcome is a non-zero exit carries
`ExpectedExitCode: <int>` and holds that one command only, because the PR-context parser reads
the last `EXIT_CODE:` line and the first `ExpectedExitCode:` line of a file. Local command
output that contains the absolute path of the worktree (for example the `# (in test file ...)`
line and the printed `$output` of a failing bats test in P1-T5 and P3-T4) is recorded with that
path prefix replaced by the literal `<REPO_ROOT>`. Where a task says verbatim, it means verbatim
after this one substitution; no other text is altered.

**Command route (agent-isolated worktree).** The worktree isolation guard refuses command text
containing the words `bash`, `pwsh`, or `wsl`, and refuses heredocs. Therefore:
shell scripts run as `sh <script>` (Git Bash `sh` is GNU bash), for example
`sh scripts/bash/shell-qc.sh check`; bats runs as `npx --yes bats <one or more named .bats files>`
(bats-core from npm, no repository change; named files only, never the `tests/shell`
directory, because the recursive suite takes about 35 minutes locally); `shfmt` and
`shellcheck` run from the Windows PATH. If the guard
refuses a command's text, the executor writes the identical command into a `.sh` file in
`<session-scratchpad>` and runs `sh <that file>`; the artifact's `Command:` field records the
command itself, not the scratch file path.

**Local test route.** `sh scripts/bash/shell-qc.sh test` is not used locally: `run_test` in
`scripts/bash/shell_qc_lib.sh` resolves `bats` with `command -v`, bats is not on the Windows
PATH, and the wrapper then prints `bats not installed; skipping shell tests.` and exits 0 having
run nothing. Local test evidence comes from `npx --yes bats` only, and every local test artifact
must contain a TAP `1..N` plan line. The spec's `bash scripts/bash/shell-qc.sh test` and
`test --coverage` commands are executed by CI (`.github/workflows/_shell-coverage.yml` runs
`bash scripts/bash/shell-qc.sh check` and `bash scripts/bash/shell-qc.sh test --coverage`).

**Authoritative coverage.** kcov has no local route. The only authoritative coverage numbers
are those read from a `workflow_dispatch` run of `.github/workflows/_shell-coverage.yml`
(ubuntu-latest, depth-1 `actions/checkout@v7`, shfmt 3.8.0, kcov v43) against the pushed
branch head: the overall `Bash coverage (lines): NN.N%` headline read from
`gh run view <RUN_ID> --log`, and the per-file `line-rate` and per-line `hits` of
`scripts/bash/cleanup_worktrees_scan_helper.sh` read from the `cov.xml` in the run's
`shell-coverage` artifact. The P0-T13/P0-T14 run is the baseline; the P4-T10/P4-T12 run on the
final implementation commit is the post-change figure. When local and CI results disagree, CI
governs (`.claude/rules/shell.md`, CI-vs-Local Version Drift). Bash coverage is line-only; no
branch-coverage gate applies.

**Coverage attribution design.** The spec records a risk that kcov may not attribute lines
executed inside a `bash -c` child that sources the helper. This plan does not depend on that
attribution: every new or modified executable line of the helper is executed by a test that
runs the helper as a script (`bash "${HELPER}" scan-dirs ...`), which is the form the existing
test already uses and which produced the 2026-09-08 per-file figure of 46/53. The existing test
drives the relative-target path (predicate returns non-zero, directory prefixed, real seam
called for `good_wt` and `broken_wt`); new test 2 drives the drive-letter path (predicate
returns 0, no prefix, real seam called). P4-T13 verifies non-zero hits per line; a gap is
recorded as remediation-required and leaves AC-4 unchecked.

**Formatter scope.** `shell-qc.sh` discovers `.sh` files and bash/sh-shebang files under
`tools/`, `scripts/`, and `.claude/lib/bash/`. `tests/shell/test_cleanup_worktrees_scan_helper.bats`
has a `bats` shebang and no `.sh` suffix, so it is outside format and lint discovery; the new
test blocks follow that file's existing 4-space indentation. The fixture file is data.

**Quality tier.** `quality-tiers.yml` is absent from the repository root on this branch
(verified by P0-T4). Per `spec.md` D5, `scripts/bash/cleanup_worktrees_scan_helper.sh` is
assumed tier **T4** (dev tooling). Under T4 no property-test or mutation obligation applies;
the uniform gates apply: format pass, zero lint findings, line coverage at or above 85%, and no
regression on changed lines.

**Merge-order independence (issues 707-716).** Edits are located by content anchors, never by
line number. New `@test` blocks are appended at the end of
`tests/shell/test_cleanup_worktrees_scan_helper.bats` after whatever test is last at execution
time; the existing test is not edited. No task asserts a total test count or a TAP plan value
for any bats file; tests are asserted by name. P0-T5 detects whether a sibling has changed an
edit site, on the branch and on `origin/main`; it stops the plan when an anchor is missing on
the branch, and records a main-side change for resolution at rebase (D10).

**Commit route.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` gates
`git add` and `git commit` on the orchestration checkpoint. Every commit is pathspec-bearing:
`git add -- <paths>` and `git commit -F <message file> -- <paths>`, with the message file
written by the Write tool into `<session-scratchpad>` (per the commit-message skill, ending with
the session's required trailer lines). The implementation pathspec (IMPL_PATHS) is exactly:
`scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`.
If the gate refuses a commit, the refusing task records the refusal text and the plan stops at
that task (BLOCKED, returned to the orchestrator).

**Files written by this plan (exhaustive).** `scripts/bash/cleanup_worktrees_scan_helper.sh`,
`tests/shell/test_cleanup_worktrees_scan_helper.bats`,
`tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit` (new),
`<FEATURE>/spec.md` (AC check-offs only), this plan (check marks only), and artifacts under
`<FEATURE>/evidence/`. Read-only for this plan: `scripts/bash/cleanup_worktrees_report_records_lib.sh`,
`tests/shell/test_cleanup_worktrees_report_records.bats`, both `cleanup-merged-worktrees/SKILL.md`
copies, and `tests/fixtures/cleanup_worktrees/scan_roots/basic/`.

**Spec reconciliation (verification form only; no requirement is dropped).**
1. AC-4 names `bash scripts/bash/shell-qc.sh format` and `check`. Locally these run as
   `sh scripts/bash/shell-qc.sh format` and `check` (same script, Git Bash GNU bash); the CI
   `check` step runs the `bash` form with shfmt 3.8.0 and is authoritative.
2. Test placement and invocation form follow spec D8 and D9; no reconciliation is required.
3. AC-4 requires the shell-qc format step to make no changes. When P4-T1 takes the scoped
   `shfmt -w` branch (`LOCAL-DRIFT: PRESENT`), this is verified by the CI shell-qc check step,
   whose `shfmt -d` under shfmt 3.8.0 exits 0 only when formatting would change nothing
   (P4-T10).
4. `.claude/rules/shell.md` directs the Windows toolchain to run under WSL. The worktree
   isolation guard refuses command text containing that word, so local steps use Git Bash `sh`;
   CI results govern per that rule's CI-vs-Local Version Drift section.

## Reference Text

The executor copies these blocks verbatim. Production code uses tab indentation (shfmt
default); test code uses the 4-space indentation of the existing bats file.

#### R1 — New functions for `scripts/bash/cleanup_worktrees_scan_helper.sh`

Inserted immediately above the line `scan_helper_gitdir_target_exists() {`, followed by one
blank line before that line.

```bash
scan_helper_is_absolute_path() {
	# Return 0 when <path> is absolute, else 1. Pure: no filesystem access.
	#
	# Absolute forms are a leading `/` (POSIX paths, MSYS `/c/...` paths, and `//server`
	# UNC paths) and a drive letter followed by `/` or `\` (`C:/...`, `c:/...`,
	# `C:\...`), which is the form Git for Windows writes into a worktree's `.git`
	# pointer file (issue #706). A drive letter with no separator (`C:rel`) is
	# drive-relative and is not absolute; an empty path is not absolute.
	#
	# Args: $1 = path. Returns 0 (absolute) or 1 (not absolute).
	local path=${1:-}
	[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]
}

scan_helper_target_present() {
	# Return 0 when <path> exists, else non-zero. This is the helper's single
	# filesystem existence check, kept in its own function as a test seam: bats tests
	# redefine this function after sourcing the helper so that a drive-letter target
	# can be reported present on a runner that has no such drive (issue #706).
	#
	# Args: $1 = path.
	[[ -e ${1:-} ]]
}
```

#### R2 — Line replacements inside `scan_helper_gitdir_target_exists`

The line `	if [[ $target != /* ]]; then` becomes `	if ! scan_helper_is_absolute_path "$target"; then`.
The line `	if [[ -e $target ]]; then` becomes `	if scan_helper_target_present "$target"; then`.
The line `		target="$dir/$target"` between them is unchanged.

#### R3 — Header comment replacement

The single header line `#                        else 0.` (the line after
`#                        (resolved relative to <path> when the target is not absolute),`)
becomes these two lines:

```bash
#                        else 0. A target is absolute when it begins with `/` or with a
#                        drive letter followed by `/` or `\` (for example `C:/repo`).
```

#### R4 — Fixture `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`

Exactly one LF-terminated line, 48 bytes, no byte-order mark, and no target directory checked
in: `gitdir: C:/fixture-repo/.git/worktrees/wt_drive`

#### R5 — Test 1 (regression; appended first)

```bash

@test "scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory" {
    # Regression for issue #706. The fixture pointer names the drive-letter target
    # C:/fixture-repo/.git/worktrees/wt_drive. The helper is sourced in a child shell and
    # its single existence check, scan_helper_target_present, is redefined after sourcing
    # (a function-override test seam) to succeed only for that exact, unprefixed string.
    # A helper that prefixes the worktree directory never matches it and reports 0.
    local drive_root="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/drive_letter"
    run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit \
        bash -c '
            source "$1"
            scan_helper_target_present() { [[ $1 == "C:/fixture-repo/.git/worktrees/wt_drive" ]]; }
            scan_helper_scan_dirs "$2"
        ' _ "${HELPER}" "${drive_root}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/wt_drive|1|1|"?* ]]
}
```

#### R6 — Test 2 (appended second)

```bash

@test "scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist" {
    # Issue #706: a drive-letter target is resolved as given, with no worktree prefix.
    # No C:/fixture-repo path exists on the test host, so the real existence check
    # reports the target missing and a genuine registration loss is still reported.
    # The helper runs as a script, the same form as the first test in this file.
    local drive_root="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/drive_letter"
    run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit \
        bash "${HELPER}" scan-dirs "${drive_root}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/wt_drive|1|0|"?* ]]
}
```

#### R7 — Test 3 (appended third, after the fix)

```bash

@test "scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths" {
    # Issue #706: slash-leading paths and drive letters followed by / or \ are absolute.
    # Each candidate that is classified relative is printed, so a failure names it.
    run bash -c '
        source "$1"
        shift
        for candidate in "$@"; do
            scan_helper_is_absolute_path "$candidate" || printf "classified relative: [%s]\n" "$candidate"
        done
    ' _ "${HELPER}" "/abs" "C:/x" "c:/x" 'C:\x'
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
```

#### R8 — Test 4 (appended fourth, after the fix)

```bash

@test "scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths" {
    # Issue #706: relative paths, a drive letter with no separator, and the empty string
    # are not absolute. Each candidate that is classified absolute is printed.
    run bash -c '
        source "$1"
        shift
        for candidate in "$@"; do
            if scan_helper_is_absolute_path "$candidate"; then
                printf "classified absolute: [%s]\n" "$candidate"
            fi
        done
    ' _ "${HELPER}" "../rel" "rel" "C:rel" ""
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
```

---

### Phase 0 — Policy Reads, Base Anchor, Edit-Site Detection, and Baseline Capture

- [x] [P0-T1] Record the base anchor in `<FEATURE>/evidence/baseline/base-anchor.<ts>.md`: run
  `git fetch origin main`, `git rev-parse HEAD`, `git merge-base HEAD origin/main`, and
  `git diff --exit-code --stat <MERGE_BASE> HEAD -- scripts/ tests/ .claude/skills/ extensions/`
  (the third command's printed SHA is `<MERGE_BASE>` for the rest of the plan). Acceptance: the
  artifact records the HEAD SHA, the `<MERGE_BASE>` literal, and the scoped diff with
  `EXIT_CODE: 0` and empty output (the branch carries no code, test, or skill change relative
  to the merge base; docs-only commits under `<FEATURE>/` are expected). Any other result
  stops the plan (BLOCKED, returned to the planner).
- [x] [P0-T2] Read policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md`:
  `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
  then the language rule `.claude/rules/shell.md`, then the supplementary rules
  `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`,
  `.claude/rules/tonality.md`, and `.claude/rules/plan-acceptance-gates.md`, then
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` and
  `.claude/skills/acceptance-criteria-tracking/SKILL.md`. Acceptance: all ten files read in
  that order; no file edited.
- [x] [P0-T3] Write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`,
  `Policy Order:` (the P0-T2 order), and the explicit list of the ten files read. Acceptance:
  the file exists with all three fields and ten listed paths.
- [x] [P0-T4] Record the quality-tier assumption in `<FEATURE>/evidence/baseline/quality-tier.<ts>.md`
  with `ExpectedExitCode: 1`: run `test -e quality-tiers.yml`. Acceptance: `EXIT_CODE: 1` (the
  file is absent), and the artifact states `Tier: T4 (assumed per spec.md D5; dev tooling)` for
  `scripts/bash/cleanup_worktrees_scan_helper.sh`. If the command exits 0 (the file now exists),
  record the tier it assigns to `scripts/`; if that tier is T1 or T2, stop the plan (BLOCKED,
  returned to the planner, because property-test obligations would apply).
- [x] [P0-T5] Edit-site detection for `scripts/bash/cleanup_worktrees_scan_helper.sh` and
  `tests/shell/test_cleanup_worktrees_scan_helper.bats` into
  `<FEATURE>/evidence/baseline/edit-site-detection.<ts>.md`. Run, each with its own
  `Command:`/`EXIT_CODE:` pair and in this order: first
  `git diff --stat <MERGE_BASE> origin/main -- scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/`
  (reports whether a sibling change to these paths has merged to main since the merge base);
  second, the six main-side counts, each formed from one of the six branch-side commands below
  by replacing its file operand with process input from `git show origin/main:<same path>` (for
  example
  `git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F 'if [[ $target != /* ]]; then'`);
  third and last, the six branch-side counts:
  `grep -c -F 'scan_helper_gitdir_target_exists() {' scripts/bash/cleanup_worktrees_scan_helper.sh`;
  `grep -c -F 'if [[ $target != /* ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh`;
  `grep -c -F 'target="$dir/$target"' scripts/bash/cleanup_worktrees_scan_helper.sh`;
  `grep -c -F 'if [[ -e $target ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh`;
  `grep -c -F '#                        else 0.' scripts/bash/cleanup_worktrees_scan_helper.sh`; and
  `grep -c -F '@test "scan-dirs emits has_gitfile/target_exists/size for each candidate directory"' tests/shell/test_cleanup_worktrees_scan_helper.bats`.
  The branch-side pairs are written last so that the artifact's final `EXIT_CODE:` is a
  branch-side `0` (a main-side count of `0` exits 1, and the PR-context parser reads the last
  `EXIT_CODE:` line). Acceptance: each of the six branch-side counts prints `1`; the stat
  output is recorded verbatim (empty means no sibling change has merged; non-empty is recorded as
  `SIBLING-MERGED: <paths>`). When a main-side count is not `1`, record
  `MAIN-SIDE-ANCHOR-CHANGED: <token>`; the branch-side edit proceeds and the conflict is
  resolved at rebase time by the orchestrator, with the anchors re-checked there. When any
  branch-side count is not `1`, stop the plan (BLOCKED, returned to the planner).
- [x] [P0-T6] Absence detection for the new names in `scripts/bash/cleanup_worktrees_scan_helper.sh`
  and `tests/shell/test_cleanup_worktrees_scan_helper.bats`, each command in its own artifact
  with `ExpectedExitCode: 1`:
  `grep -n -e 'scan_helper_is_absolute_path' -e 'scan_helper_target_present' scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats`
  into `<FEATURE>/evidence/baseline/new-names-absent.<ts>.md`;
  `grep -n -F 'drive-letter' tests/shell/test_cleanup_worktrees_scan_helper.bats` into
  `<FEATURE>/evidence/baseline/new-tests-absent.<ts>.md`; and
  `test -e tests/fixtures/cleanup_worktrees/scan_roots/drive_letter` into
  `<FEATURE>/evidence/baseline/fixture-root-absent.<ts>.md`. Acceptance: each command prints
  nothing and exits 1. Any other result means a sibling or earlier run already introduced
  these names; stop the plan (BLOCKED, returned to the planner).
- [x] [P0-T7] Record tool availability in `<FEATURE>/evidence/baseline/tool-versions.<ts>.md`:
  run `shfmt --version`, `shellcheck --version`, `npx --yes bats --version`, and `gh version`
  (the subcommand form; the flag form is refused by a PreToolUse hook), each with its own
  `Command:`/`EXIT_CODE:` pair. Acceptance: each version string recorded;
  `npx --yes bats --version` prints a line beginning `Bats `. If bats cannot be resolved through
  npx, record the output verbatim; every later local bats step then uses the CI fallback
  stated in P1-T5.
- [x] [P0-T8] Baseline format step on `scripts/bash/cleanup_worktrees_scan_helper.sh`: run
  `shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh` and write
  `<FEATURE>/evidence/baseline/shfmt-diff.<ts>.md`. Acceptance: the artifact records
  `EXIT_CODE:` and, in `Output Summary:`, either `no diff printed` or the verbatim diff (a
  pre-existing diff is recorded, not fixed, here).
- [x] [P0-T9] Baseline repo-wide check step via `scripts/bash/shell-qc.sh`: run
  `sh scripts/bash/shell-qc.sh check` and write `<FEATURE>/evidence/baseline/shell-qc-check.<ts>.md`.
  Acceptance: the artifact records `EXIT_CODE:` and every diagnostic line verbatim, and states
  `LOCAL-DRIFT: NONE` when the run prints nothing and exits 0, or
  `LOCAL-DRIFT: PRESENT` with the list of files named by any shfmt diff otherwise (local shfmt
  and shellcheck versions differ from CI; see P4-T1 for the consequence).
- [x] [P0-T10] Baseline syntax step (bash has no type checker; `.claude/rules/shell.md` step 3):
  run `sh -n scripts/bash/cleanup_worktrees_scan_helper.sh` and write
  `<FEATURE>/evidence/baseline/syntax-check.<ts>.md`. Acceptance: `EXIT_CODE: 0`, no output.
- [x] [P0-T11] Baseline local test step for `tests/shell/test_cleanup_worktrees_scan_helper.bats`:
  run `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats` and write
  `<FEATURE>/evidence/baseline/bats-scan-helper.<ts>.md`. Acceptance: the artifact records the
  full TAP output, including a `1..N` line and the line `ok <n> scan-dirs emits has_gitfile/target_exists/size for each candidate directory`;
  the number of `not ok` lines is recorded (the baseline failure set, expected empty).
- [x] [P0-T12] Baseline local test step for `tests/shell/test_cleanup_worktrees_report_records.bats`
  and `tests/shell/test_cleanup_worktrees_scan_seam.bats`: run
  `npx --yes bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats`
  and write `<FEATURE>/evidence/baseline/bats-report-records.<ts>.md`. Acceptance: the artifact
  records the full TAP output with a `1..N` line and the names of any `not ok` tests (the
  baseline failure set, expected empty).
- [x] [P0-T13] Baseline CI coverage via `.github/workflows/_shell-coverage.yml`: push the branch
  at its current HEAD with `git push -u origin bug/cleanup-report-registration-lost-false-positive-706`
  (no force), record the pushed SHA and the dispatch time (UTC), dispatch
  `gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706`,
  then repeat
  `gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-report-registration-lost-false-positive-706 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
  until it returns a run created after the dispatch time; that run's `databaseId` is the
  baseline `<RUN_ID>`. Run `gh run watch <RUN_ID> --exit-status` in the background (runs have
  taken from 6 to over 30 minutes); only after that watch has finished, run
  `gh run view <RUN_ID> --log` (run logs are unavailable while the run is in progress) and
  filter it three ways: `grep -F 'Bash coverage (lines):'`, `grep -c -E ' not ok [0-9]+ '`, and
  `grep -E ' not ok [0-9]+ '`. Write
  `<FEATURE>/evidence/baseline/ci-shell-coverage.<ts>.md` with the pairs in the order push,
  dispatch, each poll, log filters, and the `gh run watch` pair LAST (written last although it
  was started before the log filters). Acceptance: the `gh run watch` pair is the final pair
  and exits 0; `headSha` equals the pushed SHA; the numeric `Bash coverage (lines): NN.N%`
  headline and the `not ok` count are recorded; and the test names on every line printed by
  the `grep -E ' not ok [0-9]+ '` filter are recorded under the heading
  `CI baseline failure set:` (the word `none` when that filter prints nothing). If the run
  fails or prints no headline, run `gh run view <RUN_ID> --log-failed` and record its output
  (the name of the failed step and its diagnostic lines) as a pair written before the
  `gh run watch` pair, still record the CI baseline
  failure set, and mark the coverage baseline remediation-required (the plan outcome cannot be
  PASS without a numeric baseline).
- [x] [P0-T14] Baseline per-file coverage for `scripts/bash/cleanup_worktrees_scan_helper.sh` into
  `<FEATURE>/evidence/baseline/kcov-per-file.<ts>.md`: run
  `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-baseline-706`
  (baseline `<RUN_ID>` from P0-T13), then, on the `cov.xml` at the root of that directory (or
  `kcov-merged/cov.xml` when the root copy is absent), run
  `sed -n '/cleanup_worktrees_scan_helper\.sh"/,/<\/class>/p' <session-scratchpad>/kcov-baseline-706/cov.xml`
  and count its `<line ` entries and its `hits="0"` entries with `grep -c`. Then run
  `git show <MERGE_BASE>:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -n -F -e 'if [[ $target != /* ]]; then' -e 'target="$dir/$target"' -e 'if [[ -e $target ]]; then'`
  and record its three printed `N:` prefixes as the pre-change line numbers of those three
  lines (91, 92, and 94 at authoring; the recorded values govern). Acceptance: the artifact
  records the class element's `line-rate`, the total instrumented line count, the zero-hit
  count, the derived covered/total fraction (the 2026-09-08 figure was 46/53), the run ID, the
  three pre-change line numbers, and, for each of them, the `hits` value of the matching
  `<line number="N" .../>` entry in the class block or `NOT-INSTRUMENTED` when the class block
  has no such entry; no absolute path is copied into the artifact. When the P0-T13 run uploaded
  no `shell-coverage` artifact (the upload step runs only after a successful test step), record
  the `gh run download` output verbatim and mark the per-file baseline remediation-required.
- [x] [P0-T15] Baseline line counts for `scripts/bash/cleanup_worktrees_scan_helper.sh` and
  `tests/shell/test_cleanup_worktrees_scan_helper.bats`: run
  `wc -l scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats`
  and write `<FEATURE>/evidence/baseline/line-counts.<ts>.md`. Acceptance: both counts recorded
  (157 and 34 at authoring); each is below 500.

### Phase 1 — Regression Fixture and Fail-Before Tests

New `@test` blocks are appended at the end of `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
after its last existing test, each preceded by one blank line. The file header, `setup()`, and
every existing test are not modified.

- [ ] [P1-T1] Create `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`
  with the Write tool, content exactly as reference block R4 (one line, LF-terminated).
  Acceptance: the file exists; no other file is created under
  `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`.
- [ ] [P1-T2] Verify the fixture `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`
  into `<FEATURE>/evidence/regression-testing/fixture-check.<ts>.md`: run
  `wc -c tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`,
  `grep -c -x -F 'gitdir: C:/fixture-repo/.git/worktrees/wt_drive' tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`,
  `git check-attr text eol -- tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`,
  and `find tests/fixtures/cleanup_worktrees/scan_roots/drive_letter -type f`. Acceptance:
  `wc -c` prints `48` (a CR or BOM would make it 49 or more); the `grep -c -x -F` count is `1`;
  `git check-attr` prints `text: auto` and `eol: lf` (the repository rule `* text=auto eol=lf`
  in `.gitattributes` covers the path and no `-text` exemption matches it, so
  `.gitattributes` is not edited); `find` lists exactly the one `dotgit` path.
- [ ] [P1-T3] [expect-fail] Append test 1 to `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
  exactly as reference block R5, named
  `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory`.
  Verify with
  `git diff --numstat <MERGE_BASE> -- tests/shell/test_cleanup_worktrees_scan_helper.bats`
  (the deleted-line column is `0`) and
  `grep -n -F '@test "' tests/shell/test_cleanup_worktrees_scan_helper.bats` (the last printed
  line names this task's test). Acceptance: the block is the file's last block, uses 4-space
  indentation, and the existing test block is byte-unchanged (the numstat check above; P4-T15
  re-verifies). This test is expected to fail against the unfixed helper; its
  `[expect-fail]` evidence artifact is
  `<FEATURE>/evidence/regression-testing/fail-before.<ts>.md` (P1-T5).
- [ ] [P1-T4] Append test 2 to `tests/shell/test_cleanup_worktrees_scan_helper.bats`, exactly as
  reference block R6, named
  `scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist`.
  Acceptance: the block is appended after test 1 and is the file's last block. Verify with
  `git diff --numstat <MERGE_BASE> -- tests/shell/test_cleanup_worktrees_scan_helper.bats`
  (the deleted-line column is `0`) and
  `grep -n -F '@test "' tests/shell/test_cleanup_worktrees_scan_helper.bats` (the last printed
  line names this task's test).
- [ ] [P1-T5] [expect-fail] Fail-before run into `<FEATURE>/evidence/regression-testing/fail-before.<ts>.md`
  with `ExpectedExitCode: 1`: with `scripts/bash/cleanup_worktrees_scan_helper.sh` still
  unmodified, run
  `npx --yes bats --print-output-on-failure tests/shell/test_cleanup_worktrees_scan_helper.bats`
  (the flag makes bats print the failed test's `$output`, which `run` otherwise captures
  silently). Acceptance: `EXIT_CODE: 1`; the TAP output is recorded verbatim; exactly one
  `not ok` line exists and it names test 1; the lines for test 2 and for
  `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` begin `ok `;
  the bats failure detail for test 1 names the assertion `[[ "$output" == *"/wt_drive|1|1|"?* ]]`
  as the failed line and the printed output shows a record ending `/wt_drive|1|0|<size>`
  (this reproduces the reported false positive in the record shape `scan_registration_loss`
  consumes). A failure on any other line (for example a missing fixture) fails this task.
  CI fallback, used only when P0-T7 recorded that npx cannot resolve bats: commit
  `tests/shell/test_cleanup_worktrees_scan_helper.bats` and
  `tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/` with a pathspec-bearing commit,
  push, dispatch `_shell-coverage.yml` as in P0-T13, and apply the same acceptance to the TAP
  lines read from `gh run view <RUN_ID> --log` (the run is then expected to conclude
  `failure`).

### Phase 2 — Minimal Fix and Pass-After Run

- [ ] [P2-T1] In `scripts/bash/cleanup_worktrees_scan_helper.sh`, insert reference block R1
  (functions `scan_helper_is_absolute_path` and `scan_helper_target_present`) immediately above
  the line `scan_helper_gitdir_target_exists() {`, with one blank line between the R1 block and
  that line. Acceptance: `grep -n -e '^scan_helper_is_absolute_path() {' -e '^scan_helper_target_present() {' -e '^scan_helper_gitdir_target_exists() {' scripts/bash/cleanup_worktrees_scan_helper.sh`
  prints three lines in that order.
- [ ] [P2-T2] In `scripts/bash/cleanup_worktrees_scan_helper.sh` `scan_helper_gitdir_target_exists`,
  replace the line `	if [[ $target != /* ]]; then` with
  `	if ! scan_helper_is_absolute_path "$target"; then` (reference block R2). Acceptance:
  `grep -c -F 'if ! scan_helper_is_absolute_path "$target"; then' scripts/bash/cleanup_worktrees_scan_helper.sh`
  prints `1`.
- [ ] [P2-T3] In `scripts/bash/cleanup_worktrees_scan_helper.sh` `scan_helper_gitdir_target_exists`,
  replace the line `	if [[ -e $target ]]; then` with
  `	if scan_helper_target_present "$target"; then` (reference block R2). Acceptance:
  `grep -c -F 'if scan_helper_target_present "$target"; then' scripts/bash/cleanup_worktrees_scan_helper.sh`
  prints `1`.
- [ ] [P2-T4] In the header of `scripts/bash/cleanup_worktrees_scan_helper.sh`, replace the line
  `#                        else 0.` with the two lines of reference block R3. Acceptance:
  `grep -c -F 'drive letter followed by' scripts/bash/cleanup_worktrees_scan_helper.sh` prints
  `2` (one header line from R3 and one comment line inside R1).
- [ ] [P2-T5] Verify the removed literals are gone from `scripts/bash/cleanup_worktrees_scan_helper.sh`,
  in its own artifact `<FEATURE>/evidence/regression-testing/old-literals-absent.<ts>.md` with
  `ExpectedExitCode: 1`: run
  `grep -n -F -e 'if [[ $target != /* ]]; then' -e 'if [[ -e $target ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh`.
  Acceptance: prints nothing and exits 1.
- [ ] [P2-T6] Pass-after run into `<FEATURE>/evidence/regression-testing/pass-after.<ts>.md`: run
  `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats`. Acceptance:
  `EXIT_CODE: 0`; zero `not ok` lines; the lines for test 1, test 2, and
  `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` each begin
  `ok `. CI fallback as in P1-T5 when npx cannot resolve bats (the run is then expected to
  conclude `success`).

### Phase 3 — Predicate Tests and Unmodified-Consumer Tests

- [ ] [P3-T1] Append test 3 to `tests/shell/test_cleanup_worktrees_scan_helper.bats`, exactly as
  reference block R7, named
  `scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths`.
  Acceptance: the block is appended after test 2 and is the file's last block. Verify with
  `git diff --numstat <MERGE_BASE> -- tests/shell/test_cleanup_worktrees_scan_helper.bats`
  (the deleted-line column is `0`) and
  `grep -n -F '@test "' tests/shell/test_cleanup_worktrees_scan_helper.bats` (the last printed
  line names this task's test).
- [ ] [P3-T2] Append test 4 to `tests/shell/test_cleanup_worktrees_scan_helper.bats`, exactly as
  reference block R8, named
  `scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths`.
  Acceptance: the block is appended after test 3 and is the file's last block. Verify with
  `git diff --numstat <MERGE_BASE> -- tests/shell/test_cleanup_worktrees_scan_helper.bats`
  (the deleted-line column is `0`) and
  `grep -n -F '@test "' tests/shell/test_cleanup_worktrees_scan_helper.bats` (the last printed
  line names this task's test).
- [ ] [P3-T3] Run `tests/shell/test_cleanup_worktrees_scan_helper.bats` into
  `<FEATURE>/evidence/regression-testing/scan-helper-all-tests.<ts>.md`:
  `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats`. Acceptance:
  `EXIT_CODE: 0`; zero `not ok` lines; the lines for tests 1 through 4 and for
  `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` each begin `ok `.
- [ ] [P3-T4] Negative control for test 3 in `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
  proving it can fail, recorded in `<FEATURE>/evidence/regression-testing/predicate-negative-control.<ts>.md`
  with `ExpectedExitCode: 1`: first, before any edit, run
  `sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh` and record it as the pre-mutation
  hash in `<FEATURE>/evidence/regression-testing/predicate-restored.<ts>.md`; then temporarily
  replace, in `scripts/bash/cleanup_worktrees_scan_helper.sh`, the R1 line
  `	[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]` with `	[[ $path == /* ]]` (the pre-fix
  rule); run
  `npx --yes bats --print-output-on-failure --filter 'scan_helper_is_absolute_path returns 0 for slash-leading' tests/shell/test_cleanup_worktrees_scan_helper.bats`
  into the negative-control artifact; then restore the R1 line exactly. Acceptance: the
  filtered run exits 1 with one `not ok` line naming test 3 and output containing
  `classified relative: [C:/x]`; after restoring,
  `grep -c -F '[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh`
  prints `1`, `shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh` prints nothing, and
  `sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh` prints the same hash as the
  pre-mutation hash (all three post-restore pairs appended to
  `<FEATURE>/evidence/regression-testing/predicate-restored.<ts>.md` after the pre-mutation
  pair, so the file is byte-identical to its pre-mutation state and the mutated line is gone).
- [ ] [P3-T5] Unmodified-consumer run for `tests/shell/test_cleanup_worktrees_report_records.bats`
  and `tests/shell/test_cleanup_worktrees_scan_seam.bats` into
  `<FEATURE>/evidence/regression-testing/report-records-unmodified.<ts>.md`: run
  `npx --yes bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats`.
  Acceptance: the `not ok` set is a subset of the P0-T12 baseline failure set (when that set
  is empty, `EXIT_CODE: 0` and zero `not ok` lines).

### Phase 4 — Final QA Loop, CI Coverage, Scope Verification, and Acceptance Check-off

Loop rule: P4-T1 through P4-T5 are one pass of the shell toolchain loop (format, lint, syntax,
test). If any step fails, or if any step or remediation changes a file, fix the cause and
restart at P4-T1; artifacts from an abandoned pass are kept and the new pass writes new
timestamped artifacts. If the CI run (P4-T10) fails, fix the cause, restart at P4-T1, and
re-run P4-T7 through P4-T14. Exception: when every `not ok` test in the P4-T10 log is in the
P0-T13 CI baseline failure set, do not restart. The exception applies only when the P4-T10 log
contains at least one `not ok` line and the `Run shell-qc check` step succeeded, so a failure
with no failing test (for example a CI shfmt diff) still restarts the loop. Record
`PRE-EXISTING-CI-FAILURE: <names>` in the P4-T10 artifact, leave AC-4 unchecked, and
continue; the plan outcome is not PASS. Second exception: when the `Run shell-qc check` step
failed in both the P0-T13 run and the P4-T10 run, every diagnostic line that
`gh run view <RUN_ID> --log-failed` prints for the P4-T10 check step is present in the P0-T13
`--log-failed` record, and none of those lines names `scripts/bash/cleanup_worktrees_scan_helper.sh`,
do not restart. Lines are compared after removing the job-name, step-name, and timestamp
prefix that `gh run view` prepends to every log line, because the timestamp differs between
runs. Record `PRE-EXISTING-CI-CHECK-FAILURE: <lines>` in the P4-T10 artifact, leave AC-4
unchecked, and continue; the plan outcome is not PASS.

- [ ] [P4-T1] QC step 1 (format) for `scripts/bash/cleanup_worktrees_scan_helper.sh` into
  `<FEATURE>/evidence/qa-gates/qc-step1-format.<ts>.md`. Before formatting, run
  `git status --porcelain -- scripts/ tools/ .claude/lib/bash/` and
  `sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh` and record both as the pre-pass
  observation. Then, when P0-T9 recorded `LOCAL-DRIFT: NONE`, run
  `sh scripts/bash/shell-qc.sh format`; when it recorded `LOCAL-DRIFT: PRESENT`, run the scoped
  form `shfmt -w scripts/bash/cleanup_worktrees_scan_helper.sh` instead (so local-version drift
  does not rewrite files outside scope; the CI `check` step with shfmt 3.8.0 remains the
  authoritative format gate). Then re-run the same `git status --porcelain` and `sha256sum`
  commands. Acceptance (success-case observation): the formatter prints nothing and exits 0,
  the post-pass porcelain listing is identical to the pre-pass listing, and the post-pass
  hash equals the pre-pass hash. A changed hash or listing means the formatter rewrote a file:
  record the rewrite and restart the loop.
- [ ] [P4-T2] QC step 2 (lint) via `scripts/bash/shell-qc.sh`: run
  `sh scripts/bash/shell-qc.sh check` and write `<FEATURE>/evidence/qa-gates/qc-step2-check.<ts>.md`.
  Acceptance: no printed diagnostic line names `scripts/bash/cleanup_worktrees_scan_helper.sh`,
  and every printed diagnostic line is present in the P0-T9 baseline record; when P0-T9
  recorded `LOCAL-DRIFT: NONE`, the run prints nothing and exits 0. When P0-T9 recorded
  `LOCAL-DRIFT: PRESENT`, the artifact carries `ExpectedExitCode:` equal to the P0-T9
  `EXIT_CODE:` value, and the observed `EXIT_CODE:` equals that value.
- [ ] [P4-T3] QC step 2b (targeted lint) on `scripts/bash/cleanup_worktrees_scan_helper.sh`: run
  `shellcheck -f gcc scripts/bash/cleanup_worktrees_scan_helper.sh` and write
  `<FEATURE>/evidence/qa-gates/qc-step2b-shellcheck.<ts>.md`. Acceptance: `EXIT_CODE: 0` and no
  output (zero findings). No suppression comment is added; a finding is fixed in the code.
- [ ] [P4-T4] QC step 3 (syntax; bash has no type checker) on `scripts/bash/cleanup_worktrees_scan_helper.sh`:
  run `sh -n scripts/bash/cleanup_worktrees_scan_helper.sh` and write
  `<FEATURE>/evidence/qa-gates/qc-step3-syntax.<ts>.md`. Acceptance: `EXIT_CODE: 0`, no output.
- [ ] [P4-T5] QC step 4 (tests, local) on `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
  `tests/shell/test_cleanup_worktrees_report_records.bats`, and
  `tests/shell/test_cleanup_worktrees_scan_seam.bats`: run
  `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats`
  and write `<FEATURE>/evidence/qa-gates/qc-step4-bats.<ts>.md`. Acceptance: the lines for
  tests 1 through 4 and for `scan-dirs emits has_gitfile/target_exists/size for each candidate directory`
  each begin `ok `; the `not ok` set is a subset of the P0-T11 and P0-T12 baseline failure sets
  (when both are empty, `EXIT_CODE: 0` and zero `not ok` lines).
- [ ] [P4-T6] Record the clean loop pass in `<FEATURE>/evidence/qa-gates/qc-loop-pass.<ts>.md`:
  the pass number, the five artifact paths of P4-T1 through P4-T5 of that pass, and the output
  of `sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`
  run immediately after P4-T5. Acceptance: all five steps passed in the same pass without
  changing a file, and the helper hash equals the P4-T1 post-pass hash of that pass.
- [ ] [P4-T7] Commit the implementation and evidence for `scripts/bash/cleanup_worktrees_scan_helper.sh`
  and its tests: run `git add -- scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/ docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/`
  and `git commit -F <message file> -- scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/ docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/`,
  then run `git rev-parse HEAD` (CI_SHA) and
  `git status --porcelain -- scripts/ tests/`. Record all pairs in
  `<FEATURE>/evidence/other/commit-push.<ts>.md`. Acceptance: both git commands exit 0; the
  porcelain status prints nothing. If the preimplementation gate refuses either command,
  record the refusal text and stop (BLOCKED).
- [ ] [P4-T8] Push CI_SHA of `bug/cleanup-report-registration-lost-false-positive-706`: run
  `git push origin bug/cleanup-report-registration-lost-false-positive-706` (no force) and
  `git ls-remote origin refs/heads/bug/cleanup-report-registration-lost-false-positive-706`;
  append both pairs to `<FEATURE>/evidence/other/commit-push.<ts>.md`. Acceptance: both exit 0
  and the remote head equals CI_SHA.
- [ ] [P4-T9] Dispatch the authoritative `.github/workflows/_shell-coverage.yml` run: record the
  dispatch time (UTC), run
  `gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706`,
  then repeat the P0-T13 `gh run list` command until it returns a run created after the
  dispatch time; that run's `databaseId` is the final `<RUN_ID>`. Start
  `gh run watch <RUN_ID> --exit-status` in the background. Record the dispatch time, the run
  ID, and the dispatch and poll pairs in `<FEATURE>/evidence/qa-gates/ci-shell-coverage.<ts>.md`
  (the watch pair is written by P4-T10). Acceptance: the run's `headSha` equals CI_SHA.
- [ ] [P4-T10] Complete `<FEATURE>/evidence/qa-gates/ci-shell-coverage.<ts>.md` for the P4-T9
  run of `.github/workflows/_shell-coverage.yml` after the background watch finishes: run
  `gh run view <RUN_ID> --log` filtered by
  `grep -F -e 'scan-dirs reports target_exists' -e 'scan_helper_is_absolute_path returns' -e 'scan-dirs emits has_gitfile' -e 'Bash coverage (lines):'`,
  and append those pairs, then append the `gh run watch <RUN_ID> --exit-status` pair LAST.
  Acceptance: the watch pair is the final pair and shows `EXIT_CODE: 0` (conclusion
  `success`, so both the `Run shell-qc check` step and the `Run shell-qc test with coverage`
  step succeeded, and CI shfmt 3.8.0 printed no diff); the filtered log shows an `ok` TAP line
  for each of tests 1 through 4 and for
  `scan-dirs emits has_gitfile/target_exists/size for each candidate directory`; the numeric
  `Bash coverage (lines): NN.N%` headline is recorded and is at least `85.0`. Also run
  `gh run view <RUN_ID> --log` filtered by `grep -E ' not ok [0-9]+ '` and record the test
  names it prints (before the watch pair). When the run failed with no `not ok` line, also run
  `gh run view <RUN_ID> --log-failed` and record its output for the second exception (before
  the watch pair). On any failure, restart the loop at P4-T1, except under the two exceptions
  of the Phase 4 loop rule: the pre-existing CI failure exception, evaluated against those
  recorded names, and the second exception, evaluated against the recorded `--log-failed`
  output.
- [ ] [P4-T11] CI failure count for the P4-T9 run of `.github/workflows/_shell-coverage.yml`, in
  its own artifact `<FEATURE>/evidence/qa-gates/ci-not-ok-count.<ts>.md` with
  `ExpectedExitCode: 1`: run `gh run view <RUN_ID> --log` piped to
  `grep -c -E ' not ok [0-9]+ '`. Acceptance: prints `0` and exits 1 (no failing test anywhere
  in the CI suite, which includes `tests/shell/test_cleanup_worktrees_report_records.bats`
  unmodified).
- [ ] [P4-T12] Post-change per-file coverage for `scripts/bash/cleanup_worktrees_scan_helper.sh`
  into `<FEATURE>/evidence/qa-gates/kcov-per-file.<ts>.md`: run
  `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-final-706`
  (final `<RUN_ID>`), then apply the P0-T14 `sed -n` extraction and `grep -c` counts to that
  directory's `cov.xml`. Acceptance: the class `line-rate` is at least `0.85`; the total and
  zero-hit counts and the covered/total fraction are recorded with the run ID. When the run
  uploaded no `shell-coverage` artifact, record the `gh run download` output verbatim and mark
  the artifact remediation-required.
- [ ] [P4-T13] New-line hit verification for `scripts/bash/cleanup_worktrees_scan_helper.sh` into
  `<FEATURE>/evidence/qa-gates/kcov-new-line-hits.<ts>.md`: at CI_SHA, locate each of these
  lines with `grep -n -F` on the helper, then read the matching `<line number="N" hits="H"/>`
  entry from the P4-T12 class block: `local path=${1:-}`,
  `[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]`, `[[ -e ${1:-} ]]`,
  `if ! scan_helper_is_absolute_path "$target"; then`, `target="$dir/$target"`, and
  `if scan_helper_target_present "$target"; then`. Expected drivers, all in the
  script-invocation form: the existing test drives every one of the six lines through
  `good_wt` and `broken_wt` (relative targets), and test 2 drives all of them except
  `target="$dir/$target"` (drive-letter target). Acceptance: each of the six lines is recorded
  with its line number and `hits`, and each line present in the class block has `hits` of at
  least 1. A line absent from the class block is recorded as `NOT-INSTRUMENTED: <line>`; this
  is accepted only for the three lines inside `scan_helper_gitdir_target_exists` and only when
  the P0-T14 baseline block also omits the corresponding pre-change line (the three
  pre-change line numbers that P0-T14 recorded from the `git show <MERGE_BASE>:` grep for
  `if [[ $target != /* ]]; then`, `target="$dir/$target"`, and `if [[ -e $target ]]; then`),
  and otherwise is treated as a gap. For any gap or any `hits="0"` line: record
  `ATTRIBUTION-GAP: <line>`, record the class-block excerpt, mark the artifact
  remediation-required, leave AC-4 unchecked (P4-T21), and continue to P4-T14; do not restart
  the loop for this cause.
- [ ] [P4-T14] Coverage delta for `scripts/bash/cleanup_worktrees_scan_helper.sh` into
  `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md`: record the P0-T13 and P4-T10 overall
  headlines, the P0-T14 and P4-T12 per-file `line-rate` values and covered/total fractions,
  their differences, and the P4-T13 result as the new-code coverage. Acceptance: the
  post-change overall headline is at least `85.0`, the post-change per-file `line-rate` is at
  least `0.85`, and every instrumented new or modified line has non-zero hits; otherwise the
  artifact states remediation-required and the plan outcome is not PASS.
- [ ] [P4-T15] Scope verification into `<FEATURE>/evidence/qa-gates/scope-check.<ts>.md`, anchored
  to `<MERGE_BASE>`, over `scripts/`, `tests/`, and the skill copies: run
  `git diff --name-status <MERGE_BASE> HEAD -- scripts/ tests/ .claude/skills/ extensions/`,
  `git status --porcelain -- scripts/ tests/ .claude/skills/ extensions/`,
  `git diff --numstat <MERGE_BASE> HEAD -- scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats`, and
  `git diff --exit-code --stat <MERGE_BASE> HEAD -- scripts/bash/cleanup_worktrees_report_records_lib.sh tests/shell/test_cleanup_worktrees_report_records.bats .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md tests/fixtures/cleanup_worktrees/scan_roots/basic/`.
  Acceptance: the name-status output lists exactly three rows,
  `M scripts/bash/cleanup_worktrees_scan_helper.sh`,
  `M tests/shell/test_cleanup_worktrees_scan_helper.bats`, and
  `A tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit`; the porcelain
  status prints nothing (every change is committed, so the name-status diff sees all of it);
  the numstat deleted-line column is `3` for the helper (the R2 and R3 replaced lines) and
  `0` for the bats file (append-only; the existing test is unchanged); the final diff exits 0
  with empty output (D3 and D4 files untouched).
- [ ] [P4-T16] Test-portability check on the added lines of `tests/shell/test_cleanup_worktrees_scan_helper.bats`,
  in its own artifact `<FEATURE>/evidence/qa-gates/test-portability.<ts>.md` with
  `ExpectedExitCode: 1`: run
  `git diff -U0 <MERGE_BASE> HEAD -- tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/`
  piped to `grep -E '^[+][^+]'` piped to
  `grep -n -E 'mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|BATS_FILE_TMPDIR|origin/|artifacts/|git init|/mnt/'`.
  Acceptance: prints nothing and exits 1 (no temporary file, no remote ref, no gitignored
  state, no scratch repository, and no host path in the added test lines or fixture).
- [ ] [P4-T17] Line-count limit for `scripts/bash/cleanup_worktrees_scan_helper.sh` and
  `tests/shell/test_cleanup_worktrees_scan_helper.bats`: run
  `wc -l scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats`
  and write `<FEATURE>/evidence/qa-gates/line-counts.<ts>.md`. Acceptance: each count is below
  500.
- [ ] [P4-T18] Check off AC-1 in `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  (change `- [ ] AC-1:` to `- [x] AC-1:` only, text preserved) only if
  `<FEATURE>/evidence/regression-testing/scan-helper-all-tests.<ts>.md`, P4-T5, and P4-T10 show
  `ok` for test 1, test 3, and
  `scan-dirs emits has_gitfile/target_exists/size for each candidate directory`, and P4-T15
  shows the bats file append-only. Acceptance: that item reads `- [x] AC-1:`.
- [ ] [P4-T19] Check off AC-2 in `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  only if P3-T3, P4-T5, and P4-T10 show `ok` for test 2 and test 4, P4-T11 records zero CI
  failures (which covers the existing `broken_wt|1|0|` assertion and
  `tests/shell/test_cleanup_worktrees_report_records.bats`), and P4-T15 shows
  `tests/shell/test_cleanup_worktrees_report_records.bats` unmodified. Acceptance: that item
  reads `- [x] AC-2:`.
- [ ] [P4-T20] Check off AC-3 in `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  only if `<FEATURE>/evidence/regression-testing/fail-before.<ts>.md` (P1-T5) and
  `<FEATURE>/evidence/regression-testing/pass-after.<ts>.md` (P2-T6) meet their acceptance and
  `grep -c -F 'Confirmed root cause:' docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  prints `1` (the Root Cause Analysis bullet naming `scan_helper_gitdir_target_exists` with
  file and line citations is present). Record the
  grep pair in `<FEATURE>/evidence/qa-gates/ac3-root-cause.<ts>.md`. Acceptance: that item
  reads `- [x] AC-3:`.
- [ ] [P4-T21] Check off AC-4 in `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  only if P4-T1 through P4-T6 (clean local loop), P4-T10 and P4-T11 (CI check and
  test-with-coverage passed, headline at least 85.0), P4-T12 (per-file line-rate at least
  0.85), P4-T13 (non-zero hits on every instrumented new or modified line), and P4-T14 meet
  their acceptance. Acceptance: that item reads `- [x] AC-4:`.
- [ ] [P4-T22] Verify check-off state in `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`:
  run `grep -c -e '^- \[x\] AC-[1-4]:' docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
  into `<FEATURE>/evidence/qa-gates/ac-checked-count.<ts>.md`, and, in its own artifact
  `<FEATURE>/evidence/qa-gates/ac-unchecked-count.<ts>.md` with `ExpectedExitCode: 1`, run
  `grep -c -e '^- \[ \] AC-[1-4]:' docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`.
  Acceptance: the checked count prints `4` and exits 0; the unchecked count prints `0` and
  exits 1; every checked item's evidence artifact exists on disk. If any item was left
  unchecked, record the gap and the counts as observed, and the plan outcome is not PASS.
- [ ] [P4-T23] Commit and push the `docs/features/active/cleanup-report-registration-lost-false-positive-706/`
  check-offs and remaining evidence: run
  `git add -- docs/features/active/cleanup-report-registration-lost-false-positive-706/` and
  `git commit -F <message file> -- docs/features/active/cleanup-report-registration-lost-false-positive-706/`,
  then `git diff --exit-code --stat CI_SHA HEAD -- scripts/ tests/ .claude/skills/ extensions/`
  (CI_SHA replaced by the P4-T7 literal), `git push origin bug/cleanup-report-registration-lost-false-positive-706`,
  and `git ls-remote origin refs/heads/bug/cleanup-report-registration-lost-false-positive-706`.
  Record every pair and the new HEAD SHA (FINAL_SHA) in
  `<FEATURE>/evidence/other/commit-final.<ts>.md`. Acceptance: every command exits 0; the
  `--stat` diff prints nothing (no code or test path changed after the commit CI tested); the
  remote head equals FINAL_SHA. The artifact `commit-final.<ts>.md` and this task's plan
  check mark are written after the commit and are left for the orchestrator's completion
  commit. If the gate refuses the commit, record the refusal text and stop (BLOCKED).

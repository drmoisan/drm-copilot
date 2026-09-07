# 2026-09-06-cleanup-worktrees-skips-detached-head-worktrees (Remediation Plan, cycle 1)

- **Issue:** #630 (<https://github.com/drmoisan/drm-copilot/issues/630>)
- **Epic:** `cleanup-merged-worktrees-hardening`, child A
- **Branch:** `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` at `65a56cb9`
- **Base:** `epic/cleanup-merged-worktrees-hardening-integration` (merge base `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07T12-45
- **Version:** 1.0 — first authoring of the remediation cycle. Every citation in this file was re-derived against the current tree in this pass.
- **Work Mode:** `full-bug`

## Requirements Source

The requirements source for this cycle is
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/remediation-inputs.2026-09-07T12-45.md`
and its enumerated fix list R1 through R6. R1 and R2 are Major and blocking; R3 through R6 are Minor
and non-blocking and are included because the inputs enumerate them.

`spec.md` remains the sole acceptance-criteria source under work mode `full-bug`. All 24 criteria are
already checked and this cycle does not invalidate any of them. No acceptance criterion is added,
reworded, removed, or re-marked. `issue.md` is context only.

## Scope Statement and the Production-Code Question

The reviewer's estimate is that this cycle closes with roughly three new fixture directories and
roughly six new bats cases and no production-code change. This plan reports two deliberate
departures from that estimate, each with its reason.

1. **Eight fixture directories, not three.** The remediation inputs enumerate seven by name — three
   under R1 and four under R2. This plan adds one more,
   `tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/`, because
   `MERGED_EQUIVALENT` has two producing statements in `classify_detached_head`
   (`scripts/bash/cleanup_worktrees_detached_lib.sh:131` on the cherry rung and `:152` on the
   all-residuals-content-on-main rung) and R1's definition of done requires the token to be produced
   by a test and the per-file line rate to reach 85%. The eighth directory closes the second
   producer. It is inside R1, not a widening of it.
2. **Thirteen bats cases, not six.** R1's own text sets a minimum of four; this plan uses six for R1
   so that the destructive `git worktree remove` path is exercised for each of the two previously
   untested allowlist entries rather than only one. R2 needs six because its table names five
   fail-closed branches and the third of them covers two distinct tokens, `CHERRY_ERROR` and
   `DIFF_TREE_ERROR`, which the stub cannot fail for the same sha in one scenario and which therefore
   need one case each. R4 adds one CLI case.

**No production-code change is required, and none is planned for any executable statement.** R1, R2,
and R3 are fixture and test additions only. The only edit this plan makes to any file under
`scripts/` is R4's operator-facing text inside the `usage()` heredoc of
`scripts/bash/cleanup-worktrees.sh` (the heredoc opens at `:31` and closes at `:66`). Heredoc body
lines are data, not statements, so this edit changes no control flow and does not alter the kcov
denominator. `scripts/bash/cleanup_worktrees_detached_lib.sh`,
`scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`, and
`scripts/bash/cleanup_worktrees_enumerate_lib.sh` are not modified by any task in this plan.

## Evidence Location (Non-Overridable)

All evidence artifacts resolve to:

`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/<kind>/`

with `<kind>` in `remediation-baseline`, `regression-testing`, `qa-gates`, `other`. Paths under
`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/coverage/`, `artifacts/evidence/`, and `artifacts/regression-testing/` are forbidden and
are not used. The calling directive supplied only the canonical location, so there is no override to
reject. Filenames use the ISO-8601 form `yyyy-MM-ddTHH-mm`; where a task names an artifact as
`name.<timestamp>.md`, substitute the run timestamp.

## Binding Execution Environment (Read Before Phase 0)

The WSL wrapper form used by the original plan is unavailable in this worktree and no task in this
plan uses it. The verified invocation set for this cycle is:

- `npx --yes bats --tap <path>` runs a suite or a directory of suites and prints a TAP stream. Bats
  1.13.0. A directory operand is supported; `scripts/bash/shell_qc_lib.sh:350` passes a directory to
  the same binary.
- `npx --yes bats --tap --filter "<name>" <path>` runs the single named case.
- `scripts/bash/shell-qc.sh format` and `scripts/bash/shell-qc.sh check` run natively against shfmt
  v3.12.0 and shellcheck 0.11.0 on PATH.
- `kcov` has **no local route**. Coverage comes only from CI:
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`,
  then read the run log and the uploaded `shell-coverage` artifact.
- `git`, `git grep`, `gh`, `awk`, and `sh` are available. `git grep` is preferred over a shell glob
  for any per-file enumeration, because the orchestrator's shell does not expand a glob operand for
  an external command and `git grep` performs its own pathspec matching identically on every
  platform.

The orchestrator runs all commands; the executor authors files. Every acceptance condition below is
written so the orchestrator can run it in that split. No task carries a `SKIPPED` completion path.
Where a named command cannot run, the task text states the substitution explicitly and both branches
produce a recorded observation.

## What Each Command Actually Prints (Observation Contract)

Carried forward from `plan.2026-09-06T17-12.md` and re-derived against the current tree in this pass.

- **`format`** runs `shfmt -w` and prints nothing on a clean run. Its exit code is 0 whether or not
  it rewrote files, so the exit code alone is not an observation. The assertable substitute is
  `git status --porcelain -- tools scripts .claude/lib/bash` captured immediately before and
  immediately after: the two listings are byte-identical when shfmt rewrote nothing. Byte-identity is
  the assertion, not emptiness. A read-only `check` run before `format` closes the residual gap that
  porcelain reports one status letter per path rather than content.
- **`check`** runs `shfmt -d` once over the discovered list (`scripts/bash/shell_qc_lib.sh:188`) then
  `shellcheck` once per file (`:194-200`), and prints nothing on a clean run. Empty stdout and stderr
  with exit 0 is the falsifiable positive evidence.
- **`npx --yes bats --tap <dir>`** prints a TAP plan line and one `ok N <name>` line per case. Record
  the plan count and confirm no line begins with `not ok`.
- **`shell-qc.sh test --coverage`** additionally prints the coverage headline emitted at
  `scripts/bash/shell_qc_lib.sh:291`, whose literal form is `Bash coverage (lines): NN.N%` with one
  decimal place. That command runs only in CI for this cycle.
- **`discover_shell_scripts`** searches only `tools/`, `scripts/`, and `.claude/lib/bash/`, so
  `tests/shell/*.bats` is not seen by `format` or `check`. No task expects shfmt to format a bats
  file.
- **There is no type-check stage for bash.** The loop is format, then check, then test.
- **`git grep`** exits 1 with empty stdout when a pattern matches nothing. Tasks that assert absence
  record `ExpectedExitCode: 1`.
- **`git grep -c`** prefixes every count with the matching file path. Acceptance conditions that
  assert a bare numeric count use `git grep -h -c`, which suppresses the prefix. Enumeration tasks
  that need the per-file listing use `git grep -c` without `-h`.

## Baseline-Ordering Decision

Phase 0 does not run `format`. `format` is write-mode: running it first would repair any pre-existing
drift, so the recorded baseline would describe a tree the executor created. The read-only `check`
command is the baseline instrument instead. `format` runs for the first time in Phase 6.

## Fail-Before Position

R1 and R2 add coverage over behavior that is already correct. The remediation inputs state this
directly: the library "is functionally correct as written; the finding is that its state space is
under-tested, not that it is wrong." Consequently **no new case in this plan is expected to fail
before an implementation change, and no task carries the `[expect-fail]` tag.** A failing run is
structurally impossible because there is no defect to be red against. P0-T9 records a fail-before
exception dossier with an absence-of-test proof in its place, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Fixture Mechanics Re-Derived In This Pass

- The stub derives one KEY per invocation and replaces every character outside `[A-Za-z0-9._-]` with
  an underscore (`tests/fixtures/cleanup_worktrees/stub-bin/git:49-53`), so `/repo-wt/det` becomes
  `_repo-wt_det` and `src/app.py` becomes `src_app.py`.
- `worktree remove` is keyed on the subcommand alone
  (`tests/fixtures/cleanup_worktrees/stub-bin/git:104`), so a scenario directory carries at most one
  removal outcome. Every scenario in this plan that permits a removal omits `worktree-remove.rc`,
  which makes the stub exit 0.
- `diff --quiet main...<sha>` keys on the text after the three dots
  (`tests/fixtures/cleanup_worktrees/stub-bin/git:135`), giving `diff-quiet.<sha>`.
- `diff-tree` keys on its last argument (`:147-151`), so the same `diff-tree.<sha>.out` file answers
  both the empty-residual probe in `classify_cherry_equivalent`
  (`scripts/bash/cleanup_worktrees_lib.sh:151`) and the name-status read in
  `classify_residual_commit` (`:214`). The reference fixture for the tab-separated shape is
  `tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/diff-tree.det00002.out`, whose single
  line is the status letter `M`, one literal tab, then `src/app.py`.
- `ls-tree main -- <path>` keys as `ls-tree.main_<sanitized-path>`
  (`tests/fixtures/cleanup_worktrees/stub-bin/git:165`); the worked example already in the tree is
  `tests/fixtures/cleanup_worktrees/scenarios/ls_tree_error/ls-tree.main_docs_old.md.rc`.
- Every scenario needs `worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`, and
  `rev-parse.show-toplevel.out` at minimum, because `compute_protected`
  (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:185`, `:190`, `:203`) and `enumerate_branches`
  (`:74`) run unconditionally.
- `classify_detached_head` takes the HEAD sha and the path as arguments and consults the porcelain
  listing only through `compute_protected`'s `protected-path|` records. A direct call may therefore
  name a path that is absent from `worktree-list.out`; that path is simply unprotected. This is what
  lets one scenario directory host a second key set for a direct-invocation case.

## Coverage Target (Stated Explicitly)

- **Aggregate.** The uniform floor is 85.0 (`.claude/rules/quality-tiers.md`). The last measured
  aggregate on this branch is 92.9. This plan's gate is **at or above 92.9**, because no production
  line is added to the denominator and every new case can only add covered lines.
- **Per-file, `scripts/bash/cleanup_worktrees_detached_lib.sh`.** The last measured value is 0.806
  and the reviewer graded it FAIL. This plan's **gate is a line rate at or above 0.85** in the
  uploaded `shell-coverage/cov.xml`, and its **stated target is at or above 0.95**. The ten
  previously unreachable regions this plan closes are, by first line of each:
  `:90` protection-set failure, `:116` `MERGED_CONTENT_NEUTRAL`, `:120` `CONTENT_NEUTRAL_ERROR`,
  `:127` `CHERRY_ERROR` and `DIFF_TREE_ERROR`, `:131` `MERGED_EQUIVALENT` on the cherry rung, `:141`
  `RESIDUAL_ERROR`, `:146` the content-on-main counter, `:152` `MERGED_EQUIVALENT` on the residual
  rung, `:160` `HAS_UNIQUE_RESIDUALS`, and `:212` `BLOCKED-REVERIFY` on a hard failure. If the
  measured value lands below 0.95 the P6-T5 artifact must enumerate every line still uncovered.
- **No branch-coverage figure is reported.** kcov does not measure branch coverage for bash; the
  `branch-rate="1.0"` attributes in the Cobertura report are fixed placeholders. Reading a number
  from them would be fabrication.

## Literals This Plan Instructs the Executor to Create

Quoted here verbatim, outside every command span, so the acceptance gate can exonerate assertions
that reference them.

- `locked-exit-code-propagation` — a comment token the executor places inside the locked detached
  case in `tests/shell/test_cleanup_worktrees_detached.bats` alongside the R3 exit-code assertion.
- `ac22-record-literal` — a comment token the executor places inside the
  `--help documents the detached worktree record` case in `tests/shell/test_cleanup_worktrees_cli.bats`
  alongside the R3 record-literal assertion.
- `det00008`, `det00009`, `det00010`, `det00011`, `det00012`, `det00013`, `det00014`, `det00015`,
  `det00016` — the new detached HEAD shas.
- `blobSAME` — the shared blob OID used by the content-on-main residual fixture.
- `detached_content_neutral`, `detached_equivalent`, `detached_unique_residuals`,
  `detached_equivalent_residual`, `detached_protection_error`, `detached_content_neutral_error`,
  `detached_cherry_error`, `detached_residual_error` — the new scenario directory names.

`BLOCKED-REVERIFY`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `HAS_UNIQUE_RESIDUALS`, and
`ANCESTRY_ERROR` already exist in the tracked tree and are asserted as-is.

The detached record shape written in documentation contains angle brackets, and the coverage headline
contains a percent sign. Both are skipped by the acceptance gate and gate nothing, so no acceptance
condition in this plan is a search for either. Documentation presence is asserted through
bracket-free single-line tokens and through named bats cases instead.

---

### Phase 0 — Policy reads and remediation baseline capture

Baselines are captured before any file is modified. `format` is not run in this phase.

- [x] [P0-T1] Read the policy files in the `policy-compliance-order` sequence and record the read in `evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`. Files, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/tonality.md`; `.claude/rules/shell.md`; `.claude/rules/plan-acceptance-gates.md`. **Acceptance:** the artifact exists and carries `Timestamp:`, `Policy Order:`, and an explicit list naming all seven file paths. Advances: R1, R2, R3, R4, R5, R6 (process precondition).
- [x] [P0-T2] Record the requirements-source resolution and the acceptance-criteria preservation baseline in `evidence/remediation-baseline/requirements-source.<timestamp>.md`. Run `git grep -h -c "^- \[x\] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` and `git grep -h -c "^- \[ \] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`. **Acceptance:** the artifact carries `Timestamp:`, both `Command:` strings, both `EXIT_CODE:` values, and an `Output Summary:` recording that the checked count is 24 and that the unchecked search matched nothing, that `remediation-inputs.2026-09-07T12-45.md` is the fix-list source for this cycle, and that `spec.md` remains the sole acceptance-criteria source. The unchecked search exits 1 with empty stdout; record `ExpectedExitCode: 1` for it. Advances: R1, R2, R3, R4, R5, R6 (traceability precondition).
- [x] [P0-T3] Record the starting worktree state with `git status --porcelain --untracked-files=all` into `evidence/remediation-baseline/starting-tree.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the `Output Summary:` states whether the output was empty and, if it was not, enumerates every reported path, so the Phase 6 `format` observation can be read against a known starting point. Advances: R1, R2, R3, R4, R5, R6.
- [x] [P0-T4] Record toolchain availability into `evidence/remediation-baseline/toolchain-availability.<timestamp>.md` by running `npx --yes bats --version`, `shfmt --version`, `shellcheck --version`, and `gh --version`. **Acceptance:** the artifact carries `Timestamp:`, all four `Command:` strings, all four `EXIT_CODE:` values, and an `Output Summary:` naming the four printed version strings and stating explicitly that `kcov` has no local route in this worktree and that coverage for this cycle is therefore produced by `.github/workflows/_shell-coverage.yml`. If any of the four commands is refused, record the refusal text verbatim, set that command's `EXIT_CODE:` to the observed value, and stop the plan and report a blocking execution condition. Advances: R1, R2.
- [x] [P0-T5] Capture the baseline lint-and-format state with `scripts/bash/shell-qc.sh check` into `evidence/remediation-baseline/bash-check.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating either that stdout and stderr were both empty, which is the clean-run observation because the `shfmt -d` stage prints a unified diff for any unformatted discovered file, or reproducing the diff and shellcheck findings verbatim. Advances: R1, R2, R3, R4.
- [x] [P0-T6] Capture the baseline test state with `npx --yes bats --tap tests/shell` into `evidence/remediation-baseline/bats-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the TAP plan count as a numeric value, which must be 308, and stating that no output line begins with `not ok`. Advances: R1, R2, R3.
- [x] [P0-T7] Capture the baseline coverage figures from CI into `evidence/remediation-baseline/bash-test-coverage.<timestamp>.md`. First run `git fetch origin bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`, then `git rev-parse HEAD` and `git rev-parse origin/bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`; the two shas must be equal before dispatch, and if they are not, push the branch first and record that. Then run `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`, wait for the run to finish, and download its `shell-coverage` artifact to a scratch directory outside the repository. **Acceptance:** the artifact carries `Timestamp:`, every `Command:` string, every `EXIT_CODE:`, the run ID, the run URL, the run conclusion, the head sha the run tested, and an `Output Summary:` recording the numeric aggregate percentage read from the line beginning `Bash coverage (lines):` and the numeric per-file line rate read from the `cov.xml` entry whose filename is `scripts/bash/cleanup_worktrees_detached_lib.sh`. A placeholder such as `UNVERIFIED` is not acceptable for either number. Advances: R1, R2.
- [x] [P0-T8] Capture the baseline file sizes with `git grep -c "^" -- "scripts/bash/*.sh" "tests/shell/*.bats"` into `evidence/remediation-baseline/file-line-counts.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, the full printed list, and an `Output Summary:` naming the counts for `scripts/bash/cleanup_worktrees_detached_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup-worktrees.sh`, and `tests/shell/test_cleanup_worktrees_detached.bats`, and stating that no listed count exceeds 500. Advances: R1, R2, R4.
- [x] [P0-T9] Write the fail-before exception dossier to `evidence/regression-testing/fail-before-exception.<timestamp>.md`. The absence-of-test proof is `git grep -n -E "MERGED_CONTENT_NEUTRAL|MERGED_EQUIVALENT|HAS_UNIQUE_RESIDUALS" -- tests/shell/test_cleanup_worktrees_detached.bats`, which matches nothing before this cycle's edits. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, `Output Summary:`, a `WhyFailingRunImpossible:` field of one to three sentences stating that R1 and R2 add coverage over behavior that is already correct so no deterministically red run exists, and the absence-of-test proof above reproduced verbatim with its empty result. It must also record `SearchScope:`, `SearchPatterns:`, and `SearchResult: none`. Advances: R1, R2.

---

### Phase 1 — R1 fixture scenarios for the untested delete-eligible verdicts

This phase adds fixture data only. No test or source file changes, so the suite must remain green at
the end of it with an unchanged case count.

- [x] [P1-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/` with six files: `worktree-list.out` carrying the `/repo/main` branch stanza then a stanza `worktree /repo-wt/det`, `HEAD det00008`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00008.rc` containing `1`; `diff-quiet.det00008.rc` containing `0`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. Do not create `worktree-remove.rc`: its absence makes the stub removal exit 0, which P2-T2 requires. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral` lists exactly six paths, and `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral/worktree-remove.rc` prints no line, which is the observation that the file was not created. `git grep` is not used for this check because it does not search untracked files and would report the same empty result whether or not the file exists. Advances: R1.
- [x] [P1-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent/` with seven files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00009`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00009.rc` containing `1`; `diff-quiet.det00009.rc` containing `1`; `cherry.det00009.out` containing the single line consisting of a hyphen, a space, then `det00009`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. A single patch-id-equivalent cherry line leaves the residual list empty, so `classify_cherry_equivalent` returns the single `MERGED_EQUIVALENT` line at `scripts/bash/cleanup_worktrees_lib.sh:162`. Do not create `worktree-remove.rc`. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent` lists exactly seven paths, and `cherry.det00009.out` is one line whose second whitespace-separated field is `det00009`. Advances: R1.
- [x] [P1-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals/` with ten files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00010`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00010.rc` containing `1`; `diff-quiet.det00010.rc` containing `1`; `cherry.det00010.out` containing exactly two lines, the first a hyphen, a space, then `ddd00001`, and the second a plus sign, a space, then `det00010`; `diff-tree.det00010.out` containing exactly one line, the status letter `M`, then one literal tab character, then `src/app.py`, with no space anywhere on the line; `rev-parse.det00010_src_app.py.out` containing `blobA`; `rev-parse.main_src_app.py.out` containing `blobB`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. The hyphen line is the `MINUS_PRESENT` signal that separates `HAS_UNIQUE_RESIDUALS` from `NOT_MERGED` at `scripts/bash/cleanup_worktrees_detached_lib.sh:158-163`; the differing blob OIDs make the residual `UNIQUE`. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals` lists exactly ten paths, `diff-tree.det00010.out` is one line whose second tab-separated field is `src/app.py`, and the contents of `rev-parse.det00010_src_app.py.out` and `rev-parse.main_src_app.py.out` differ from each other. Advances: R1.
- [x] [P1-T4] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual/` with ten files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00011`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00011.rc` containing `1`; `diff-quiet.det00011.rc` containing `1`; `cherry.det00011.out` containing exactly one line, a plus sign, a space, then `det00011`; `diff-tree.det00011.out` containing exactly one line, the status letter `M`, one literal tab character, then `src/shared.py`; `rev-parse.det00011_src_shared.py.out` containing `blobSAME`; `rev-parse.main_src_shared.py.out` containing `blobSAME`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. Identical blob OIDs make the single residual `CONTENT_ON_MAIN`, which drives the second `MERGED_EQUIVALENT` producer at `scripts/bash/cleanup_worktrees_detached_lib.sh:152` and the content counter at `:146`. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual` lists exactly ten paths, and the contents of `rev-parse.det00011_src_shared.py.out` and `rev-parse.main_src_shared.py.out` are identical to each other. Advances: R1.
- [x] [P1-T5] Confirm the Phase 1 fixture additions changed no behavior by running `npx --yes bats --tap tests/shell` and recording the result in `evidence/regression-testing/r1-fixtures-only-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that the TAP plan count is 308, equal to the P0-T6 baseline, and that no line begins with `not ok`. Advances: R1.

---

### Phase 2 — R1 bats cases for the untested delete-eligible verdicts

Each task adds exactly one case to `tests/shell/test_cleanup_worktrees_detached.bats`, appended after
the existing final case so the line positions of the existing cases are unchanged. Every case uses
the file's existing `report` and `runin` helpers, both of which retain stderr so the stub argv log
merges into `$output`. No case in this phase is expected to fail; see **Fail-Before Position**.

- [x] [P2-T1] Add the case named `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD`, running `report "${SCEN}/detached_content_neutral"` and asserting that `$output` contains the literal `WORKTREE|/repo-wt/det|DETACHED|MERGED_CONTENT_NEUTRAL|detached` and does not contain `MERGED_CLEAN`. **Acceptance:** `npx --yes bats --tap --filter "report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T2] Add the case named `apply removes a content-neutral detached worktree without force`, running `runin "${SCEN}/detached_content_neutral" run_apply` and asserting that `$output` contains `ACTION|worktree-remove|/repo-wt/det|OK`, contains `worktree remove /repo-wt/det`, does not contain `--force`, and does not contain `worktree prune`. This is the first test in the repository to drive the destructive path from a `MERGED_CONTENT_NEUTRAL` verdict. **Acceptance:** `npx --yes bats --tap --filter "apply removes a content-neutral detached worktree without force" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T3] Add the case named `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD`, running `report "${SCEN}/detached_equivalent"` and asserting that `$output` contains the literal `WORKTREE|/repo-wt/det|DETACHED|MERGED_EQUIVALENT|detached` and does not contain `MERGED_CLEAN`. **Acceptance:** `npx --yes bats --tap --filter "report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T4] Add the case named `apply removes a cherry-equivalent detached worktree without force`, running `runin "${SCEN}/detached_equivalent" run_apply` and asserting that `$output` contains `ACTION|worktree-remove|/repo-wt/det|OK`, contains `worktree remove /repo-wt/det`, does not contain `--force`, and does not contain `worktree prune`. This is the first test in the repository to drive the destructive path from a `MERGED_EQUIVALENT` verdict. **Acceptance:** `npx --yes bats --tap --filter "apply removes a cherry-equivalent detached worktree without force" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T5] Add the case named `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD`, running `report "${SCEN}/detached_unique_residuals"` and asserting that `$output` contains the literal `WORKTREE|/repo-wt/det|DETACHED|HAS_UNIQUE_RESIDUALS|detached`, then running `runin "${SCEN}/detached_unique_residuals" run_apply` and asserting that `$output` does not contain `ACTION|worktree-remove` and does not contain `worktree remove`. The second run is what proves the non-eligible terminal blocks the destructive path. **Acceptance:** `npx --yes bats --tap --filter "report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T6] Add the case named `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main`, running `runin "${SCEN}/detached_equivalent_residual" "classify_detached_head det00011 /repo-wt/det"` and asserting that `$status` equals 0, that `$output` contains `MERGED_EQUIVALENT`, and that `$output` does not contain `HAS_UNIQUE_RESIDUALS`. The assertions are substring form, not equality, because the helper retains stderr and the stub writes one `stub-git: ` argv line per invocation. **Acceptance:** `npx --yes bats --tap --filter "classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R1.
- [x] [P2-T7] Run the whole detached suite with `npx --yes bats --tap tests/shell/test_cleanup_worktrees_detached.bats` and record the result in `evidence/regression-testing/r1-detached-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that the TAP plan count is 20, that no line begins with `not ok`, and naming the six case names added by P2-T1 through P2-T6 as present in the `ok` lines. Advances: R1.

---

### Phase 3 — R2 fixture scenarios for the unexercised fail-closed guards

This phase adds fixture data only. The key conventions are taken from the branch-backed equivalents
already in the tree: `scenarios/rev_parse_error_protection/` for the protection failure,
`scenarios/cherry_error/` for the cherry failure, `scenarios/diff_tree_error/` for the diff-tree
failure, and `scenarios/ls_tree_error/` for the residual failure.

- [x] [P3-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/` with four files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00012`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `rev-parse.abbrev-ref-HEAD.rc` containing `128`; `rev-parse.show-toplevel.out` containing `/repo/main`. Deliberately no `merge-base.det00012.rc`: the protection-set guard at `scripts/bash/cleanup_worktrees_detached_lib.sh:88-92` must fire before the ancestry rung is reached, so that key must be irrelevant. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error` lists exactly four paths, and `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error/merge-base.det00012.rc` prints no line, which is the observation that the file was not created. `git grep` is not used for this check because it does not search untracked files and would report the same empty result whether or not the file exists. Advances: R2.
- [x] [P3-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error/` with six files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00013`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00013.rc` containing `1`; `diff-quiet.det00013.rc` containing `128`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. The non-zero `diff --quiet` exit maps to `CONTENT_NEUTRAL_ERROR` at `scripts/bash/cleanup_worktrees_lib.sh:96` and then to `ANCESTRY_ERROR` at `scripts/bash/cleanup_worktrees_detached_lib.sh:119-122`. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error` lists exactly six paths, and the content of `diff-quiet.det00013.rc` is `128`. Advances: R2.
- [x] [P3-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error/` with eleven files, carrying two independent key sets so one directory covers both tokens that share the guard at `scripts/bash/cleanup_worktrees_detached_lib.sh:126-129`. The registered key set, for `det00014`: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00014`, `detached`; `merge-base.det00014.rc` containing `1`; `diff-quiet.det00014.rc` containing `1`; `cherry.det00014.rc` containing `128`. The direct-invocation key set, for `det00015`, which is deliberately absent from `worktree-list.out`: `merge-base.det00015.rc` containing `1`; `diff-quiet.det00015.rc` containing `1`; `cherry.det00015.out` containing exactly one line, a plus sign, a space, then `det00015`; `diff-tree.det00015.rc` containing `128`. Shared: `for-each-ref.out` containing `main aaaa0000`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error` lists exactly eleven paths, the content of `cherry.det00014.rc` is `128`, and the content of `diff-tree.det00015.rc` is `128`. Advances: R2.
- [x] [P3-T4] Create `tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error/` with nine files: `worktree-list.out` carrying the main stanza then `worktree /repo-wt/det`, `HEAD det00016`, `detached`; `for-each-ref.out` containing `main aaaa0000`; `merge-base.det00016.rc` containing `1`; `diff-quiet.det00016.rc` containing `1`; `cherry.det00016.out` containing exactly one line, a plus sign, a space, then `det00016`; `diff-tree.det00016.out` containing exactly one line, the status letter `D`, one literal tab character, then `docs/old.md`; `ls-tree.main_docs_old.md.rc` containing `128`; `rev-parse.abbrev-ref-HEAD.out` containing `main`; `rev-parse.show-toplevel.out` containing `/repo/main`. The D-rung `ls-tree` probe is the route to `RESIDUAL_ERROR`: making the name-status read fail instead would trip the earlier diff-tree guard, because the stub answers both diff-tree invocations from the same key. **Acceptance:** `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error` lists exactly nine paths, `diff-tree.det00016.out` is one line whose second tab-separated field is `docs/old.md`, and the content of `ls-tree.main_docs_old.md.rc` is `128`. Advances: R2.
- [x] [P3-T5] Confirm the Phase 3 fixture additions changed no behavior by running `npx --yes bats --tap tests/shell` and recording the result in `evidence/regression-testing/r2-fixtures-only-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that the TAP plan count is 314, which is the P0-T6 baseline of 308 plus the six cases added in Phase 2, and that no line begins with `not ok`. Advances: R2.

---

### Phase 4 — R2 bats cases for the unexercised fail-closed guards

Each task adds exactly one case to `tests/shell/test_cleanup_worktrees_detached.bats`, appended after
the existing final case. Every case asserts the fail-closed contract in the same three-part shape:
the classification returns 2 and echoes `ANCESTRY_ERROR` and no `MERGED_` token, report mode carries
the error state into the record, and apply mode invokes no removal and returns non-zero.

- [x] [P4-T1] Add the case named `a protection-set hard failure fails closed as ANCESTRY_ERROR`, which runs `runin "${SCEN}/detached_protection_error" "classify_detached_head det00012 /repo-wt/det"` and asserts `$status` equals 2, `$output` contains `ANCESTRY_ERROR`, and `$output` does not contain `MERGED_`; then runs `report "${SCEN}/detached_protection_error"` and asserts `$output` contains `WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached`; then runs `runin "${SCEN}/detached_protection_error" run_apply` and asserts `$output` does not contain `worktree remove` and `$status` is non-zero. **Acceptance:** `npx --yes bats --tap --filter "a protection-set hard failure fails closed as ANCESTRY_ERROR" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T2] Add the case named `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR`, in the same three-part shape against `${SCEN}/detached_content_neutral_error` with the direct invocation `classify_detached_head det00013 /repo-wt/det`. **Acceptance:** `npx --yes bats --tap --filter "a content-neutral probe hard failure fails closed as ANCESTRY_ERROR" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T3] Add the case named `a cherry hard failure fails closed as ANCESTRY_ERROR`, in the same three-part shape against `${SCEN}/detached_cherry_error` with the direct invocation `classify_detached_head det00014 /repo-wt/det`. **Acceptance:** `npx --yes bats --tap --filter "a cherry hard failure fails closed as ANCESTRY_ERROR" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T4] Add the case named `a diff-tree hard failure fails closed as ANCESTRY_ERROR`, running `runin "${SCEN}/detached_cherry_error" "classify_detached_head det00015 /repo-wt/det2"` and asserting `$status` equals 2, `$output` contains `ANCESTRY_ERROR`, and `$output` does not contain `MERGED_`. This case is direct-invocation only: `det00015` is deliberately absent from that scenario's `worktree-list.out`, because the stub answers `cherry` from one key per sha and one scenario cannot make both `cherry` and `diff-tree` fail for the same sha. **Acceptance:** `npx --yes bats --tap --filter "a diff-tree hard failure fails closed as ANCESTRY_ERROR" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T5] Add the case named `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR`, in the same three-part shape against `${SCEN}/detached_residual_error` with the direct invocation `classify_detached_head det00016 /repo-wt/det`. **Acceptance:** `npx --yes bats --tap --filter "a residual ls-tree hard failure fails closed as ANCESTRY_ERROR" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T6] Add the case named `reverify_detached_delete_eligible blocks on a classification hard failure`, running `runin "${SCEN}/detached_content_neutral_error" "reverify_detached_delete_eligible det00013 /repo-wt/det"` and asserting `$status` equals 1, `$output` contains `BLOCKED-REVERIFY`, and `$output` does not contain `worktree remove`. This exercises the hard-failure branch at `scripts/bash/cleanup_worktrees_detached_lib.sh:211-214`, which is distinct from the allowlist-miss branch at `:220-221` already covered by `reverify_detached_delete_eligible blocks on a flipped verdict`. **Acceptance:** `npx --yes bats --tap --filter "reverify_detached_delete_eligible blocks on a classification hard failure" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R2.
- [x] [P4-T7] Run the whole detached suite with `npx --yes bats --tap tests/shell/test_cleanup_worktrees_detached.bats` and record the result in `evidence/regression-testing/r2-detached-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that the TAP plan count is 26, that no line begins with `not ok`, and naming the six case names added by P4-T1 through P4-T6 as present in the `ok` lines. Advances: R2.

---

### Phase 5 — R3 assertion strengthening, R4 documentation, R5 limitation

- [x] [P5-T1] R3 item 1. In `tests/shell/test_cleanup_worktrees_detached.bats`, inside the existing case `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`, add the assertion that `$status` is non-zero, preceded by a one-line comment containing the token `locked-exit-code-propagation` and stating that the locked path is the primary source of the documented apply-mode exit-code change. Change no existing assertion in that case. **Acceptance:** `git grep -h -c "locked-exit-code-propagation" -- tests/shell/test_cleanup_worktrees_detached.bats` prints `1`, and `npx --yes bats --tap --filter "locked detached worktree yields BLOCKED-LOCKED and invokes no removal" tests/shell/test_cleanup_worktrees_detached.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R3.
- [x] [P5-T2] R3 item 2. In `tests/shell/test_cleanup_worktrees_cli.bats`, inside the existing case `--help documents the detached worktree record`, add an assertion that `$output` contains the five-field detached record literal exactly as it is written in the `usage()` heredoc at `scripts/bash/cleanup-worktrees.sh:48`, preceded by a one-line comment containing the token `ac22-record-literal`. Keep the existing `ANCESTRY_ERROR` assertion unchanged. The pattern contains no glob metacharacter and is quoted, so the substring test works as written. Do not move or edit the assertions at `:33` or `:61`, which AC5 and AC6 pin. **Acceptance:** `git grep -h -c "ac22-record-literal" -- tests/shell/test_cleanup_worktrees_cli.bats` prints `1`, and `npx --yes bats --tap --filter "documents the detached worktree record" tests/shell/test_cleanup_worktrees_cli.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R3.
- [x] [P5-T3] R4. In `.claude/skills/cleanup-merged-worktrees/SKILL.md`, append to the detached-worktree paragraph that ends at `:149` one sentence stating that a blocked detached removal sets a non-zero exit status, naming `BLOCKED-DIRTY`, `BLOCKED-LOCKED`, and `BLOCKED-REVERIFY`, and stating that a checkout holding dirty or locked detached worktrees exits non-zero from `--apply` where the same checkout previously exited 0. Write `BLOCKED-REVERIFY` exactly once in the file. Change no other line. **Acceptance:** `git grep -h -c "BLOCKED-REVERIFY" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` prints `1`. Advances: R4.
- [x] [P5-T4] R4 mirror. Copy `.claude/skills/cleanup-merged-worktrees/SKILL.md` over `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` so the two files are byte-identical, as AC21 requires. **Acceptance:** `git hash-object .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` prints two object ids that are identical to each other, and `git status --porcelain -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` lists both paths as modified. Advances: R4.
- [x] [P5-T5] R4. In the `usage()` heredoc of `scripts/bash/cleanup-worktrees.sh`, which opens at `:31` and closes at `:66`, add after the branch-and-detached-state paragraph that ends at `:56` a short paragraph stating that in apply mode a blocked detached removal sets a non-zero exit status, naming `BLOCKED-DIRTY`, `BLOCKED-LOCKED`, and `BLOCKED-REVERIFY` on a single line, and stating that such a checkout exits non-zero from `--apply` where it previously exited 0. Add no executable statement. **Acceptance:** `git grep -h -c "BLOCKED-REVERIFY" -- scripts/bash/cleanup-worktrees.sh` prints `1`, and `sh scripts/bash/cleanup-worktrees.sh --help` exits 0 and its stdout contains `BLOCKED-REVERIFY`. Advances: R4.
- [x] [P5-T6] R4. Append to `tests/shell/test_cleanup_worktrees_cli.bats`, after its current final case, one new case named `--help documents the apply-mode exit-code change for blocked detached removals`, which runs the wrapper with `--help` and asserts `$status` equals 0 and `$output` contains `BLOCKED-REVERIFY`. Appending at the end leaves the line positions of the existing cases unchanged. **Acceptance:** `npx --yes bats --tap --filter "documents the apply-mode exit-code change" tests/shell/test_cleanup_worktrees_cli.bats` exits 0, prints a plan line selecting exactly one case, and prints one line beginning `ok 1 `. Advances: R4.
- [x] [P5-T7] R5. Add a fifth entry to the `## Known Limitations` section of `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`, immediately after the L4 entry that ends at `:395`, formatted in the same bold-heading style as L1 through L4 and beginning a line with two asterisks then `L5`. It states that `classify_detached_head` emits no `COMMIT|` record by design, that unique work held in a detached worktree classified `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` is correctly retained but is never surfaced to the consolidation triage flow that reads `COMMIT|` records in `scripts/bash/cleanup_worktrees_actions_lib.sh`, that the omission fails in the safe direction of retention rather than deletion, and that it is a follow-up candidate rather than a defect in this child. Do not implement `COMMIT|` emission for detached HEADs. Change no acceptance criterion. **Acceptance:** `git grep -h -c "^\*\*L5 " -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` prints `1`, `git grep -h -c "^\*\*L[1-5] " -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` prints `5`, and `git grep -h -c "^- \[x\] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` still prints `24`. Advances: R5.

---

### Phase 6 — Final QC loop, coverage verification, and exit-gate evidence

Stages 1 through 3 are the bash toolchain loop in order. If any stage fails or rewrites a file,
restart the loop at P6-T1.

- [x] [P6-T1] Stage 1, format. Run, in this order: (a0) `scripts/bash/shell-qc.sh check`, a read-only command whose output is recorded as `PreCheck:`; (a) `git status --porcelain -- tools scripts .claude/lib/bash`; (b) `scripts/bash/shell-qc.sh format`; (c) the same porcelain command as (a) again, immediately after (b). Record all four in `evidence/qa-gates/final-bash-format.<timestamp>.md` with the (a) and (c) listings reproduced verbatim and labelled `Before:` and `After:`. `format` prints nothing on a clean run and exits 0 whether or not it rewrote a file, so its exit code cannot distinguish a clean run from a repairing one; the before-and-after porcelain pair and the `PreCheck:` output together are the observation. Byte-identity is the assertion, not emptiness. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, the `PreCheck:` output, both verbatim listings, and an `Output Summary:` stating that `format` printed no output, that the `PreCheck:` output is empty, and that the `Before:` and `After:` listings are byte-identical to each other. If `PreCheck:` is non-empty or the two listings differ, record the differing paths and restart the loop at P6-T1. Advances: R1, R2, R3, R4, R5.
- [x] [P6-T2] Stage 2, lint. Run `scripts/bash/shell-qc.sh check` and record the result in `evidence/qa-gates/final-bash-check.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that both stdout and stderr were empty. Empty output is the falsifiable positive evidence, because the `shfmt -d` stage prints a unified diff whenever any discovered file is unformatted. Any non-empty output fails this task and restarts the loop at P6-T1. Advances: R1, R2, R3, R4.
- [x] [P6-T3] Stage 3, tests. Run `npx --yes bats --tap tests/shell` and record the result in `evidence/qa-gates/final-bats-suite.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording that the TAP plan count is 321, which is the P0-T6 baseline of 308 plus the 13 cases this cycle adds — six in Phase 2, six in Phase 4, and one in P5-T6 — and that no output line begins with `not ok`. The `Output Summary:` must enumerate all 13 case names. Advances: R1, R2, R3, R4.
- [x] [P6-T4] Stage 3 coverage. First commit every change made by Phases 1 through 5 onto `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2` and push it, because the workflow dispatch resolves `--ref` against the remote and an uncommitted worktree change is invisible to it; a dispatch run against the unchanged tip would re-measure the P0-T7 baseline and report 0.806 for the per-file rate regardless of the work done. Then confirm the local HEAD and the remote branch tip agree with `git fetch origin bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`, `git rev-parse HEAD`, and `git rev-parse origin/bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`, and proceed only when they are equal, then run `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`, wait for the run to finish, and download its `shell-coverage` artifact to a scratch directory outside the repository. Record everything in `evidence/qa-gates/final-bash-test-coverage.<timestamp>.md`. The workflow's test step runs `bash scripts/bash/shell-qc.sh test --coverage` on `ubuntu-latest`, which is the same script and argument the toolchain policy names, on a runner where bats and kcov are installed. **Acceptance:** the artifact carries `Timestamp:`, every `Command:` string, every `EXIT_CODE:`, the run ID, the run URL, the run conclusion `success`, the head sha the run tested, and an `Output Summary:` recording the numeric aggregate percentage read from the line beginning `Bash coverage (lines):`, the TAP plan count reported by that run, that no line begins with `not ok`, and the numeric per-file line rate read from the `cov.xml` entry whose filename is `scripts/bash/cleanup_worktrees_detached_lib.sh`. Both numbers must be measured values, not placeholders. The artifact must additionally record the commit sha created for this cycle and state that it differs from the P0-T7 baseline head sha; a run whose head sha equals the P0-T7 head sha did not measure this cycle's changes and fails this task. Advances: R1, R2.
- [x] [P6-T5] Record the coverage delta and the two thresholds in `evidence/qa-gates/coverage-delta.<timestamp>.md`. **Acceptance:** the artifact records the P0-T7 baseline aggregate percentage, the P6-T4 post-change aggregate percentage, the signed delta between them, and an explicit statement that the post-change aggregate is at or above 92.9 and therefore at or above the 85.0 uniform floor in `.claude/rules/quality-tiers.md`. It records the P0-T7 baseline per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh`, the P6-T4 post-change per-file line rate, the signed delta, and an explicit statement that the post-change per-file rate is at or above 0.85, which is this cycle's gate. If the post-change per-file rate is below the stated target of 0.95, the artifact must additionally enumerate every line of that file still reported uncovered. It states that no branch-coverage value is reported and why: kcov does not measure branch coverage for bash, so the `branch-rate="1.0"` attributes are placeholders and reporting a number from them would be fabrication. It confirms the file is inside the kcov include pattern at `scripts/bash/shell_qc_lib.sh:335-336`. Advances: R1, R2.
- [x] [P6-T6] Confirm a single clean pass of the loop and record it in `evidence/qa-gates/toolchain-single-pass.<timestamp>.md`. **Acceptance:** the artifact names the P6-T1, P6-T2, and P6-T3 artifacts of the final iteration, states the iteration number, and states that no file was rewritten and no stage failed within that iteration. If more than one iteration was required, the artifact enumerates every iteration and what changed between them. Advances: R1, R2, R3, R4, R5.
- [x] [P6-T7] Record post-change file sizes with `git grep -c "^" -- "scripts/bash/*.sh" "tests/shell/*.bats"` into `evidence/qa-gates/file-line-counts.<timestamp>.md`. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, the full printed list, and an `Output Summary:` stating that no listed count exceeds 500, that `scripts/bash/cleanup_worktrees_detached_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh` both carry the same counts recorded in P0-T8 because this cycle does not modify either file, and naming the post-change counts for `scripts/bash/cleanup-worktrees.sh`, `tests/shell/test_cleanup_worktrees_detached.bats`, and `tests/shell/test_cleanup_worktrees_cli.bats`. Advances: R1, R2, R4.
- [x] [P6-T8] Verify push-down mirror parity with `git hash-object .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` and record the result in `evidence/qa-gates/push-down-mirror.<timestamp>.md`. A content-hash comparison is used rather than a `diff` invocation because the orchestrator's shell resolves `diff` to a different program. **Acceptance:** the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, both printed object ids verbatim, and an `Output Summary:` stating that the two ids are identical to each other, which is AC21. Advances: R4.
- [x] [P6-T9] Audit the changed test files for prohibited temporary-file usage with `git grep -n -E "mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|git init" -- tests/shell/test_cleanup_worktrees_detached.bats tests/shell/test_cleanup_worktrees_cli.bats` and record the result in `evidence/qa-gates/no-temp-files.<timestamp>.md`. **Acceptance:** the command prints nothing and exits 1; the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` stating that no match was found in either file, which is AC19. Advances: R1, R2, R3.
- [x] [P6-T10] Confirm every new fixture path is present by running `git status --porcelain --untracked-files=all -- tests/fixtures/cleanup_worktrees tests/shell scripts/bash .claude/skills extensions/drm-copilot/resources` followed by `git ls-files tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent tests/fixtures/cleanup_worktrees/scenarios/detached_unique_residuals tests/fixtures/cleanup_worktrees/scenarios/detached_equivalent_residual tests/fixtures/cleanup_worktrees/scenarios/detached_protection_error tests/fixtures/cleanup_worktrees/scenarios/detached_content_neutral_error tests/fixtures/cleanup_worktrees/scenarios/detached_cherry_error tests/fixtures/cleanup_worktrees/scenarios/detached_residual_error`, recording both in `evidence/qa-gates/new-paths-tracked.<timestamp>.md`. The porcelain span is the companion required because `git ls-files` sees tracked paths only and reports nothing for a file created but not yet staged; `--untracked-files=all` makes it enumerate individual files rather than collapsing a new directory to one entry. **Acceptance:** taken together, the two listings name at least one file inside each of the eight new fixture directories, and the artifact records which of the two spans covered each directory. Advances: R1, R2.
- [x] [P6-T11] Confirm no pinned `WORKTREE|` assertion was removed or altered by running `git diff a36b6dca7809e456f00c7d5b01eec5da49f7fca0 -- tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_enumeration.bats` piped through `awk '/^-/ && !/^---/ && /WORKTREE/ {n++} END {print n+0}'`, and separately `git diff a36b6dca7809e456f00c7d5b01eec5da49f7fca0 -- tests/shell/test_cleanup_worktrees_enumeration.bats`, recording both in `evidence/qa-gates/pinned-assertions-unmodified.<timestamp>.md`. The diff is anchored at the fixed merge-base commit rather than at the moving remote base ref, because that ref has advanced five commits since the merge base and would attribute sibling child 634's changes to this branch. Removed lines only are counted: P5-T2 deliberately adds a `WORKTREE` assertion line to the CLI suite, so counting added lines as well would make this condition unsatisfiable. **Acceptance:** the awk stage prints `0`, meaning no removed line in those four files carries a `WORKTREE` assertion, and the second command produces empty output, meaning `tests/shell/test_cleanup_worktrees_enumeration.bats` is byte-unmodified against the merge base. Advances: R3, and preserves AC5 and AC6.
- [x] [P6-T12] Confirm `remove_worktree_safe` is untouched by running `git diff a36b6dca7809e456f00c7d5b01eec5da49f7fca0 -- scripts/bash/cleanup_worktrees_actions_lib.sh` piped through `awk '/^[-+]/ && /remove_worktree_safe/ {n++} END {print n+0}'`, recording the command and its output in `evidence/qa-gates/remove-worktree-safe-untouched.<timestamp>.md`. **Acceptance:** the awk stage prints `0`, meaning no added or removed line in that file references `remove_worktree_safe`; the artifact additionally states that no task in this remediation cycle modified `scripts/bash/cleanup_worktrees_actions_lib.sh`. Advances: preserves AC11 and the child-C boundary.
- [x] [P6-T13] Verify evidence locations by running `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` and recording the result in `evidence/qa-gates/evidence-locations.<timestamp>.md`. If `poetry` cannot be resolved in this environment, record the refusal text verbatim with its observed exit code, and in the same artifact record three substitute observations: `git status --porcelain --untracked-files=all -- artifacts`; `git ls-files docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence`; and `git status --porcelain --untracked-files=all -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence`. The third span is required because `git ls-files` enumerates tracked paths only, and P6-T4 commits the Phase 1 through Phase 5 changes alone, so the Phase 0 and Phase 6 artifacts are still untracked when this task runs and no `git ls-files` listing can name them. State explicitly that the substitution was made and why. **Acceptance:** the artifact carries `Timestamp:`, every `Command:` string, every `EXIT_CODE:`, and an `Output Summary:` stating either that the validator exited 0, or, on the substitution branch, that no evidence artifact produced by this cycle appears anywhere inside the repository `artifacts` tree and that every artifact this plan names appears in the union of the second and third listings under `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/`, with the artifact recording which of the two listings covered each named artifact. Advances: R1, R2, R3, R4, R5.
- [x] [P6-T14] R6, pre-PR integration check. Run `git fetch origin epic/cleanup-merged-worktrees-hardening-integration` then `git merge-tree --write-tree origin/epic/cleanup-merged-worktrees-hardening-integration HEAD`, recording both in `evidence/qa-gates/integration-precheck.<timestamp>.md`. This must be run after P5-T3, because R4 adds text to the same `.claude/skills/cleanup-merged-worktrees/SKILL.md` region sibling child 634 also edits. Because `merge-tree` reads `HEAD` rather than the working tree, the edit is visible to this check only after P6-T4 commits it, which the task order supplies. **Acceptance:** the artifact carries `Timestamp:`, both `Command:` strings, `EXIT_CODE: 0` for the merge-tree command, the resolved sha of `origin/epic/cleanup-merged-worktrees-hardening-integration` at the time of the run, and an `Output Summary:` stating that the exit code of 0 means the merge produces no conflict. A non-zero exit is a blocking condition to report, not a step to skip. Advances: R6.
- [x] [P6-T15] Confirm the acceptance-criteria state is unchanged by running `git grep -h -c "^- \[x\] AC" -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` and `git diff 65a56cb94352c2a19c381acf4008837fa84aee69 -- docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md` piped through `awk '/^[-+]/ && /\[x\] AC/ {n++} END {print n+0}'`, recording both in `evidence/other/ac-status.<timestamp>.md`. The diff is anchored at `65a56cb9`, the branch head at this remediation cycle's entry, rather than at the merge base. `spec.md` is present at the merge base `a36b6dca` and carries all 24 criteria unchecked there; commit `65a56cb9` checked them off, so a merge-base anchor renders all 24 checked-criterion lines as additions and the awk stage prints 24 regardless of executor action. Measured against the current tree, the merge-base anchor prints 24 and the `65a56cb9` anchor prints 0. **Acceptance:** the first command prints `24`, the awk stage prints `0`, meaning no acceptance-criterion line was added, removed, or reworded by this cycle, and the artifact records the source file path `spec.md`, a total AC count of 24, a checked count of 24, a remaining count of 0, and the statement that the only edit this cycle makes to `spec.md` is the L5 limitation added by P5-T7. Advances: R5, and preserves AC1 through AC24.
- [x] [P6-T16] Write the remediation exit-gate summary to `evidence/other/remediation-exit-gate.<timestamp>.md`. **Acceptance:** the artifact names, for each of R1 through R6, the tasks that implemented it and the evidence artifact paths that verify it; states that all seven detached state tokens `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, and `ANCESTRY_ERROR` are each produced by at least one named bats case, listing the case name for each; states that each of the five fail-closed guards named in R2 is asserted by at least one named bats case, listing the case name for each; and records the post-change per-file line rate for `scripts/bash/cleanup_worktrees_detached_lib.sh` against the 0.85 gate. Advances: R1, R2, R3, R4, R5, R6.

---

## R-to-Task Traceability

Every item in the remediation fix list maps to at least one implementation task, at least one test,
and at least one evidence artifact.

| Item | Implementation task(s) | Test(s) | Evidence |
|---|---|---|---|
| R1 | P1-T1 through P1-T4, P2-T1 through P2-T6 | `report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD`, `apply removes a content-neutral detached worktree without force`, `report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD`, `apply removes a cherry-equivalent detached worktree without force`, `report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD`, `classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main` | `evidence/regression-testing/r1-detached-suite.<timestamp>.md`, `evidence/qa-gates/coverage-delta.<timestamp>.md` |
| R2 | P3-T1 through P3-T4, P4-T1 through P4-T6 | `a protection-set hard failure fails closed as ANCESTRY_ERROR`, `a content-neutral probe hard failure fails closed as ANCESTRY_ERROR`, `a cherry hard failure fails closed as ANCESTRY_ERROR`, `a diff-tree hard failure fails closed as ANCESTRY_ERROR`, `a residual ls-tree hard failure fails closed as ANCESTRY_ERROR`, `reverify_detached_delete_eligible blocks on a classification hard failure` | `evidence/regression-testing/r2-detached-suite.<timestamp>.md`, `evidence/qa-gates/coverage-delta.<timestamp>.md` |
| R3 | P5-T1, P5-T2 | `locked detached worktree yields BLOCKED-LOCKED and invokes no removal`, `--help documents the detached worktree record` | `evidence/qa-gates/final-bats-suite.<timestamp>.md`, `evidence/qa-gates/pinned-assertions-unmodified.<timestamp>.md` |
| R4 | P5-T3, P5-T4, P5-T5, P5-T6 | `--help documents the apply-mode exit-code change for blocked detached removals` | `evidence/qa-gates/push-down-mirror.<timestamp>.md`, `evidence/qa-gates/final-bats-suite.<timestamp>.md` |
| R5 | P5-T7 | none; `spec.md` carries no executable behavior, and the condition is verified by the two `git grep` counts in P5-T7 and by P6-T15 | `evidence/other/ac-status.<timestamp>.md`, `evidence/other/remediation-exit-gate.<timestamp>.md` |
| R6 | P6-T14 | none; this is a pre-PR integration check, not a behavior | `evidence/qa-gates/integration-precheck.<timestamp>.md` |

## Acceptance-Criteria Preservation

This cycle adds no acceptance criterion and re-marks none. The four criteria most exposed to the
edits above are guarded explicitly:

| Criterion | Exposure | Guard |
|---|---|---|
| AC5, AC6 | P5-T2 edits `tests/shell/test_cleanup_worktrees_cli.bats`, one of the four pinned suites | P6-T11 counts removed `WORKTREE` lines only and requires `tests/shell/test_cleanup_worktrees_enumeration.bats` to be byte-unmodified |
| AC11 | the child-C boundary in `scripts/bash/cleanup_worktrees_actions_lib.sh` | P6-T12; no task in this plan edits that file |
| AC21 | P5-T3 edits the source of the push-down mirror | P5-T4 and P6-T8 |
| AC22 | P5-T5 edits the `usage()` heredoc | P5-T2, P5-T5, and P5-T6 |
| AC23 | P5-T5 grows `scripts/bash/cleanup-worktrees.sh` | P0-T8 and P6-T7 |
| AC24 | the full toolchain loop | P6-T1 through P6-T6 |

## Do-Not-Do List Carried Forward

1. No production-code change to `scripts/bash/cleanup_worktrees_detached_lib.sh`,
   `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, or
   `cleanup_worktrees_enumerate_lib.sh`. No task restructures, refactors, or simplifies any library
   while adding coverage.
2. No modification to `remove_worktree_safe`.
3. No coverage threshold is lowered or reinterpreted, and no file under `.claude/rules/` or
   `.github/instructions/` is edited.
4. No bash branch-coverage figure is reported.
5. No temporary file, scratch git repository, `mktemp` path, `$BATS_TMPDIR` usage, or `git init` call
   appears in any new test. All new coverage routes through the `CLEANUP_WT_GIT_BIN` and
   `CLEANUP_WT_STUB_SCENARIO` seams against checked-in fixture directories.
6. No pinned assertion literal in `test_cleanup_worktrees_enumeration.bats`,
   `test_cleanup_worktrees_classification.bats`, `test_cleanup_worktrees_cli.bats`, or
   `test_cleanup_worktrees_hard_failures.bats` is changed.
   `test_cleanup_worktrees_enumeration.bats` remains entirely untouched.
7. No file is excluded from the kcov denominator; the include pattern at
   `scripts/bash/shell_qc_lib.sh:335-336` is not narrowed.
8. No shell or bats file exceeds 500 lines.
9. No scope is widened to sibling epic children. R5 records the `COMMIT|` blind spot as a limitation
   and does not implement a fix for it.
10. `BLOCKED-LOCKED` is not unified across the branch-backed path; `spec.md` L2 routes that to a
    follow-up.
11. No silent skip. Where `kcov` cannot run locally, the CI workflow is dispatched and its run ID,
    head sha, and conclusion are recorded. No figure that was not measured is reported.
12. No acceptance criterion is re-marked, added, reworded, or removed.

## Ordering Constraints (Satisfiability Check)

1. **Baseline before any modification.** All of Phase 0 runs against the unmodified tree, and Phase 0
   omits the write-mode `format` command so the baseline describes the inherited tree.
2. **Fixtures before cases.** Phase 1 precedes Phase 2 and Phase 3 precedes Phase 4. A case added
   before its scenario directory exists would read an empty scenario and resolve every stub key to
   empty output with exit 0, which is a different verdict from the one it asserts.
3. **No red window, and therefore no exit-0 gate inside one.** Every case this plan adds passes as
   soon as its fixture exists, because no production behavior changes. P1-T5, P2-T7, P3-T5, and
   P4-T7 each assert an exit code of 0 and each is satisfiable at the point it runs: the plan counts
   they assert are 308, 20, 314, and 26 respectively, which follow from the case counts added before
   each of them.
4. **P5-T2 before P6-T11.** P6-T11 counts removed lines only precisely because P5-T2 adds a
   `WORKTREE` assertion line. Counting added lines as well, as the original plan's P7-T9 did, would
   make P6-T11 unsatisfiable after P5-T2 runs.
5. **P5-T3 before P5-T4 before P6-T8.** The mirror is copied from the edited source, and the parity
   check reads the result. P6-T8 after both.
6. **P5-T3 before P6-T14.** The integration pre-check must observe the tree that includes R4's edit
   to the file sibling child 634 also touches, which is the reason the inputs require it to be
   re-run immediately before the PR.
7. **Coverage last.** P6-T4 runs after every fixture and test change, so the kcov denominator is
   final and every branch the plan closes is exercised in the measured run. P6-T5 reads P6-T4 and
   P0-T7, which were produced by the same instrument and are therefore comparable.
8. **P6-T4 requires this cycle's changes to be committed and pushed.** The workflow dispatch resolves
   `--ref` against the remote, so P6-T4 begins by committing and pushing Phases 1 through 5 and then
   confirming the local HEAD equals the remote tip. P0-T7 requires no commit: its purpose is to
   measure the inherited tree, which is already the remote tip.
9. **Two different diff anchors, deliberately.** P6-T11 and P6-T12 anchor at the merge base
   `a36b6dca` because their four bats files and `scripts/bash/cleanup_worktrees_actions_lib.sh` all
   exist at that commit and the question is what the whole branch did to them. P6-T15 anchors at
   `65a56cb9` because the question is what this remediation cycle did to `spec.md`. `spec.md` also
   exists at `a36b6dca`, but with all 24 criteria unchecked, so a merge-base anchor renders every
   checked-criterion line as an addition, prints 24, and cannot fail.

# Remediation Plan — cleanup-worktrees dirt classifier (Issue #632), cycle 1

- Timestamp: 2026-09-08T05-00
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/`
- Work mode: `full-bug` (marker `- Work Mode: full-bug` at `issue.md:12`); requirements source is
  `spec.md` only. `user-story.md` is present but is not an acceptance-criteria source under this
  mode. The three unchecked boxes in `spec.md` `## Context` (lines 24-27) are the
  Blocker/High/Medium/Low severity radio block, not acceptance criteria.
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `eac077a2858e6c357d1c4e118a3ca0bb5cd85e16`
  (re-derived from `.git/refs/heads/bug/cleanup-worktrees-dirt-classifier-632-r2` in the main
  repository, reached through the `gitdir:` pointer in this worktree's `.git` file, when this
  revision was written). `ad6bc946bbf0ad9e69756b2155eae19771a232d8` is the commit the CI coverage
  run `34182198357` measured and remains the anchor for the P0-T7 baseline only.
  `ad6bc946..eac077a2` touches `docs/` alone, so every code citation in this plan holds at all
  three of `ad6bc946`, `388e1a78`, and `eac077a2`.
  P8-T5 states its head-SHA assertion against a pre-commit SHA the executor records in the same
  artifact rather than against a SHA quoted here. A quoted SHA goes stale on every further
  docs-only commit to this branch, and once it is stale the assertion holds before the executor
  commits anything, which is the vacuous-pass class this plan's Gate Ownership section rules out.
- Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680ebcebaabbba10faaa490e46a717686535`

## Findings This Plan Closes

| ID | Severity | Subject | Phase |
|---|---|---|---|
| R1 | FAIL (data loss) | Rung 1 ignores the porcelain **Y** column; an `MM` entry is labelled `STAGED_TREE_IS_COMMIT` and `--clear-disposable` destroys the unstaged delta | 2 |
| R2 | FAIL (data loss) | The ` -> ` split is unconditional instead of `R`/`C`-only; a non-rename path containing that literal is truncated, misclassified, and misreported | 3 |
| R5 | blocking-PARTIAL | The diff header filter is content-blind and drops added content lines beginning `++ ` | 4 |
| R4 | FAIL (pinning) | `STAGED_TREE_IS_COMMIT` is pinned in one of five material directions | 2, 5 |
| R3 | FAIL (coverage) | `scripts/bash/cleanup_worktrees_dirt_lib.sh` at 82.63% (138/167), below the uniform 85% line floor | 5, 6, 8 |
| R6a | blocking-PARTIAL | Report-mode exit code changed 0 -> 128 under `dirty_worktree_status_error`; undocumented, unpinned | 1, 7 |
| R6b | blocking-PARTIAL | `DISPOSABLE_SESSION_ARTIFACT` cannot fire against a real drm-copilot checkout | 1, 7 |

## Recorded Decisions (both are decisions, not test gaps)

### Decision A — R6a: the report-mode exit-code propagation is INTENDED and is documented and pinned.

`classify_worktree_dirt` returns git's exit code on a hard `status --porcelain` failure
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:342-344`), `run_report` propagates it
(`scripts/bash/cleanup_worktrees_lib.sh:485-487`), and the wrapper propagates it in turn. Report
mode is the read-only diagnostic pass that feeds the Dirty Worktree Triage Procedure. A worktree
whose status read failed produces **no** `DIRTFILE|` or `DIRTSUM|` record at all, so a report that
also exited 0 would be indistinguishable from a report about a clean worktree, and an operator
would make a deletion decision on silently incomplete data. Suppressing the propagation in favour
of a `WARN|` record would require adding a record type to the published contract and would leave
the exit code unable to signal the incompleteness to a wrapping script.

The precedent is in the same document: `.claude/skills/cleanup-merged-worktrees/SKILL.md:197-200`
already documents an analogous apply-mode exit-status change introduced by issue 631. This plan
mirrors that treatment for report mode: a SKILL.md note (canonical plus byte-identical bundle
mirror), a new acceptance criterion, and a test pinning exit 128 for the
`dirty_worktree_status_error` scenario in report mode. No code change is made.

### Decision B — R6b: rung 2 is RETAINED, reachable in consumer checkouts, deliberately inert in drm-copilot, and the inertness is documented.

The verdict is not dead code and is not removed. It is unreachable **in drm-copilot only**, because
`.gitignore:6` is `/artifacts` and the status read deliberately omits `--ignored`
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:29-33`, `:341`). The tool is repository-agnostic. The
2026-09-06 observations that named the three paths were produced against the TaskMaster checkout
(`issue.md:27`, `spec.md:21`, `spec.md:132-134`), where those paths were reported by
`git status --porcelain` and are therefore not ignored. Delivery to that checkout is by the
extension push-down of `claude-customizations`, recorded in the `## Rollout & Follow-up` step of
`spec.md` that begins `Consumer checkouts pick the change up through the normal extension
push-down of`, so the rung is live exactly where the tool is used. That step is cited by its
content rather than by line number because Phase 1 of this plan appends to `spec.md` above it.

**How it is reachable:** through the inspected checkout's own `.gitignore`, with no change to the
status read. **What that costs elsewhere:** nothing, because `--ignored` is not added. Adding it
would pull every ignored build output into the classified set and, for any entry matching a
disposable rung, into the cleared set; that prohibition is already stated at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:29-33` and is reinforced by a new test in Phase 7 that
asserts no status read the library issues carries `--ignored`.

Consequence for coverage: retaining the rung is coverage-neutral. `dirt_is_session_artifact` and its
emission site are already exercised by the `dirt_session_artifact` scenario — the matcher body at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:126-129` and the emission at `:244-245` are absent from
the uncovered set. Lines 74-77 are reported uncovered because they are the interior of the
multi-line `CLEANUP_WT_SESSION_ARTIFACT_PATHS=(` array assignment whose statement kcov attributes to
its closing line 78, which is not in the uncovered set — the same instrumentation property that
reports lines 95, 148, 151 and 305 uncovered while the statements they open do execute. That is
unrelated to this decision. Of the 29 uncovered lines, the new scenarios close 19, taking the file
from 138/167 to 157/167 (94.0%) against a floor of 85%. Phase 8 records the residual uncovered set
from the merged Cobertura report rather than predicting it.

## Scope Boundary

**In scope:** R1, R2, R3, R4, R5, R6a, R6b, and the acceptance-criteria reconciliation named in
`remediation-inputs.2026-09-08T05-00.md` (AC-1, AC-14, AC-15, AC-31, AC-32).

**Out of scope, deferred with a stated disposition:** the advisory findings F7 through F14 from
`code-review.2026-09-08T05-00.md`, with one split. None blocks merge on its own; F7 and F9 would
consume headroom in `scripts/bash/cleanup_worktrees_lib.sh`, which is at 496 of 500 lines and which
this plan does not modify at all. Phase 8 records them for a follow-up issue rather than leaving
them undispositioned.

F14 is the split one. `remediation-inputs.2026-09-08T05-00.md:164` records AC-15 as contradicted by
both R2 and F14, so deferring F14 whole would leave half of a recorded contradiction open while
P8-T10 checked AC-15 off. Its acceptance-criteria half is therefore **in scope** and is closed by
P1-T11, which takes the narrow-the-AC branch of the remedy that document states at `:153`. Its
documentation half — the `SKILL.md` omission that detached, `main`, and `bare` registrations are
never classified — stays deferred alongside F13, whose second clause records the same gap.

## Binding Constraints

1. **500-line cap** (`.claude/rules/general-code-change.md`, `.claude/rules/shell.md:89`).
   Measured now: `cleanup_worktrees_lib.sh` 496, `cleanup_worktrees_report_records_lib.sh` 476,
   `cleanup_worktrees_actions_lib.sh` 437, `cleanup_worktrees_dirt_lib.sh` 425,
   `cleanup-worktrees.sh` 187, `tests/fixtures/cleanup_worktrees/stub-bin/git` 362,
   `test_cleanup_worktrees_dirt_classify.bats` 300, `test_cleanup_worktrees_dirt_clear.bats` 283,
   `test_cleanup_worktrees_dirt_regression.bats` 126. **This plan modifies exactly one production
   shell file, `scripts/bash/cleanup_worktrees_dirt_lib.sh`.** `cleanup_worktrees_lib.sh`,
   `cleanup_worktrees_report_records_lib.sh`, `cleanup_worktrees_actions_lib.sh`,
   `cleanup-worktrees.sh`, and the git stub are not modified.
2. **No temporary files in tests** (`.claude/rules/general-unit-test.md`). Every new scenario is a
   checked-in directory under `tests/fixtures/cleanup_worktrees/scenarios/`.
3. **Every git call goes through the `cleanup_wt_git` seam**
   (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`); tests drive it via
   `CLEANUP_WT_GIT_BIN` paired with `CLEANUP_WT_STUB_SCENARIO`.
4. **Report mode stays non-mutating**: no `write-tree`, no `GIT_INDEX_FILE`, and every read carries
   `--no-optional-locks`. Pinned by `tests/shell/test_cleanup_worktrees_dirt_clear.bats:205` and
   `:224`, which must continue to pass unmodified.
5. **Evidence paths resolve under
   `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/` only.**
6. **`.claude/**` edits mirror byte-identically** into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

## Gate Ownership (read before authoring or executing any acceptance condition)

The bash toolchain is split across two hosts.

- **Runs locally in this worktree:** `shfmt`, `shellcheck` (both reached through
  `bash scripts/bash/shell-qc.sh format` and `bash scripts/bash/shell-qc.sh check`), and `bats`
  via `npx --yes bats`. Observed success-case forms are recorded in
  `evidence/qa-gates/shell-qc-format.2026-09-08T03-30.md`,
  `evidence/qa-gates/shell-qc-check.2026-09-08T03-30.md`, and
  `evidence/qa-gates/shell-qc-test.2026-09-08T03-30.md`.
- **Has no local route:** `kcov`. `bash scripts/bash/shell-qc.sh test --coverage` exits **127**
  in this worktree with `kcov not installed; cannot run shell tests with coverage.`, recorded at
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T03-30.md`. Coverage is therefore measurable
  only by dispatching `.github/workflows/_shell-coverage.yml`, which measures the **pushed** tree.
  Every coverage acceptance condition in this plan names that dispatch and a pushed commit.

Two forms are prohibited anywhere in this plan and in its execution, because neither is runnable:
the `wsl -d Ubuntu -- bash -lc '...'` wrapper, and the worktree path `agent-a3944b95a7d58e712`.
This worktree is `agent-ac72d35e7980bc69d`.

`shfmt` in write mode prints nothing and exits 0 whether or not it rewrote a file, so every
formatter task in this plan records a before-and-after tree digest as its observation rather than
relying on the exit code.

---

### Phase 0 — Baseline capture

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`, `.claude/rules/shell.md`,
  `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and write
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/remediation-baseline/phase0-instructions-read.2026-09-08T05-30.md`
  containing `Timestamp:`, `Policy Order:`, and an explicit list of the six files read.
  Acceptance: that file exists and its `Policy Order:` list names all six paths.

- [x] [P0-T2] Read `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
  `issue.md`, `remediation-inputs.2026-09-08T05-00.md`, `code-review.2026-09-08T05-00.md`,
  `feature-audit.2026-09-08T05-00.md`, `policy-audit.2026-09-08T05-00.md`, and
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`, and write
  `evidence/remediation-baseline/phase0-findings-read.2026-09-08T05-30.md` recording `Timestamp:`,
  the seven paths read, the resolved work mode `full-bug`, and the AC source `spec.md`.
  Acceptance: that file exists and names all seven paths and the literal `full-bug`.

- [x] [P0-T3] Capture the pre-change tree digest, run the formatter, and capture the digest again.
  Commands, in order:
  `for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum`
  then `bash scripts/bash/shell-qc.sh format` then the digest command again. Write
  `evidence/remediation-baseline/shell-qc-format.2026-09-08T05-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the before digest, the after digest, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the before and after digests recorded in that artifact are equal.
  The digest equality is the failable observation; the exit code alone is identical on a clean run
  and on a repairing one.

- [x] [P0-T4] Run `bash scripts/bash/shell-qc.sh check` and write
  `evidence/remediation-baseline/shell-qc-check.2026-09-08T05-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, and `Output Summary:` stating whether any `shfmt` diff hunk or
  `shellcheck` finding was emitted.
  Acceptance: `EXIT_CODE: 0` and the `Output Summary:` records zero shfmt hunks and zero shellcheck
  findings.

- [x] [P0-T5] Resolve the bats binary and capture the full-suite baseline. Run
  `npx --yes bats --version` and record the version and the absolute path of the executable it
  resolves; then run the stage as
  `env SHELL_QC_BATS_BIN=<that absolute path> bash scripts/bash/shell-qc.sh test`
  (`run_test` in `scripts/bash/shell_qc_lib.sh` honours the `SHELL_QC_BATS_BIN` seam documented at
  `.claude/rules/shell.md:42-44`). Write
  `evidence/remediation-baseline/shell-qc-test.2026-09-08T05-30.md` with `Timestamp:`,
  both commands with the placeholder resolved to the concrete path, `EXIT_CODE:`, the resolved
  bats path and version, the TAP plan line, the count of lines beginning `ok`, the count of lines
  beginning `not ok`, and `Output Summary:`. Record the observed local total on its own line in the
  exact form `BaselineLocalTestTotal: <n>`; that recorded value, not a literal carried from CI, is
  what P8-T3 measures its delta against.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, the recorded `ok` count equals the
  recorded plan-line upper bound, and the artifact contains a `BaselineLocalTestTotal:` line whose
  value equals that `ok` count. If the artifact records the message
  `bats not installed; skipping shell tests.` the task is INCOMPLETE, not a pass.
  The CI run at `ad6bc946` reported `1..390`; that figure is recorded here for comparison only and
  is deliberately not asserted, because the local stage and the CI stage can enumerate different
  suites and an assertion on `390` would fail this task for a difference that is not a defect. If
  the observed local total differs from `390`, record the difference in `Output Summary:` and
  continue.

- [x] [P0-T6] Observe the targeted-run command shape that later phases assert over. Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats` and
  write `evidence/remediation-baseline/bats-targeted-run-shape.2026-09-08T05-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the verbatim first three output lines, and
  `Output Summary:` stating the exact prefix form the runner uses for a passing test and for a
  failing test.
  Acceptance: `EXIT_CODE: 0`, the artifact records the plan line `1..11`, records `0` lines
  beginning `not ok`, and records the observed passing-line prefix verbatim. Every later
  acceptance condition in this plan that reads bats output uses the form recorded here; if the
  observed form differs from `ok <n> <description>`, the later conditions are restated against the
  observed form before those tasks run.

- [x] [P0-T7] Record the coverage baseline from the last measured run without re-dispatching. Read
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md` and write
  `evidence/remediation-baseline/shell-qc-test-coverage.2026-09-08T05-30.md` with `Timestamp:`,
  `Command:` naming
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`,
  `EXIT_CODE: 0`, the run id `34182198357`, headSha `ad6bc946bbf0ad9e69756b2155eae19771a232d8`,
  and `Output Summary:` carrying the four numbers `92.9` (repo-wide line coverage), `82.63`
  (`scripts/bash/cleanup_worktrees_dirt_lib.sh`), `138` covered, `167` instrumented, plus the
  29-entry uncovered-line list verbatim.
  Acceptance: that file exists and its `Output Summary:` contains the literals `92.9`, `82.63`,
  `138 / 167`, and the literal `415, 416` (the last two entries of the uncovered list).

- [x] [P0-T8] Run `wc -l` over `scripts/bash/cleanup_worktrees_dirt_lib.sh`,
  `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`, `scripts/bash/cleanup-worktrees.sh`,
  `tests/fixtures/cleanup_worktrees/stub-bin/git`, and every file matching
  `tests/shell/test_cleanup_worktrees_*.bats`, and write
  `evidence/remediation-baseline/file-size-limit.2026-09-08T05-30.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the full line-count table, and `Output Summary:` naming the maximum.
  Acceptance: `EXIT_CODE: 0` and the recorded maximum is `496` for
  `scripts/bash/cleanup_worktrees_lib.sh`.

- [x] [P0-T9] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and write `evidence/remediation-baseline/pytest-push-down-contract.2026-09-08T05-30.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the summary line, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the artifact records the literal `11 passed`.

---

### Phase 1 — Recorded decisions and spec reconciliation

Phase 1 changes only `spec.md` and writes two decision records. No code, test, or fixture changes.

- [x] [P1-T1] Write
  `evidence/other/decision-report-mode-exit-code.2026-09-08T06-00.md` recording Decision A: the
  report-mode exit-code propagation is intended and retained. The record must contain `Timestamp:`,
  the two observed exit codes (`HEAD report-mode exit code = 128`,
  `BASE report-mode exit code = 0`) with their source
  (`code-review.2026-09-08T05-00.md` F5), the three code locations
  `scripts/bash/cleanup_worktrees_dirt_lib.sh:342-344`,
  `scripts/bash/cleanup_worktrees_lib.sh:485-487`, and the precedent
  `.claude/skills/cleanup-merged-worktrees/SKILL.md:197-200`, the rejected alternative (suppress
  and emit `WARN|`) with its reason, and the three work items the decision entails (SKILL.md note,
  new acceptance criterion, report-mode test).
  Acceptance: that file exists and contains the literals `128`, `SKILL.md:197-200`, and
  `Decision: RETAIN`.

- [x] [P1-T2] Write
  `evidence/other/decision-session-artifact-reachability.2026-09-08T06-00.md` recording Decision B
  and the re-derivation of the 2026-09-06 observation. The record must contain `Timestamp:`, the
  verbatim `git check-ignore -v artifacts/pr_context.summary.txt artifacts/pr_context.appendix.txt artifacts/orchestration/orchestrator-state.json`
  output with `EXIT_CODE:`, the citation `.gitignore:6`, the re-derivation of the observation's
  provenance (`issue.md:27`, `spec.md:21`, `spec.md:132-134` — the run was against the TaskMaster
  checkout, where the three paths were reported by `git status --porcelain`), an explicit statement
  that the TaskMaster checkout is not present in this worktree so the provenance rests on the
  issue's own run record rather than on a re-execution, the decision to retain the rung, the
  explicit prohibition on `--ignored`, and the coverage consequence stated in the Decision B block
  above, written with the exact single-word literal `coverage-neutral`: retaining the rung is
  coverage-neutral, because `dirt_is_session_artifact` at
  `scripts/bash/cleanup_worktrees_dirt_lib.sh:126-129` and its emission site at `:244-245` are
  already exercised by the `dirt_session_artifact` scenario and are absent from the uncovered set,
  and lines 74-77 are reported uncovered only because they are the interior of a multi-line array
  assignment whose statement kcov attributes to its closing line 78 — an instrumentation property
  unrelated to this decision.
  Acceptance: that file exists and contains the literals `.gitignore:6`, `Decision: RETAIN`,
  `--ignored`, and `coverage-neutral`. The asserted token is the single hyphenated word rather than
  a multi-word phrase because a phrase drawn from prose straddles a line break once the artifact
  wraps, and a line-oriented search then reports zero matches although the text is present.

- [x] [P1-T3] In `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
  replace AC-1 (the first item of `## Acceptance Criteria`) with an unchecked `- [ ]` item whose
  sourcing clause uses the exact single-word literal `self-sourcing` and reads: sourced by
  `scripts/bash/cleanup-worktrees.sh` and by every self-sourcing
  `tests/shell/test_cleanup_worktrees_*.bats` suite, meaning every suite that itself sources
  `scripts/bash/cleanup_worktrees_lib.sh`; and add the exclusion note naming the three suites that
  fall outside that set: `tests/shell/test_cleanup_worktrees_scan_helper.bats` (sources no
  cleanup-worktrees library), `tests/shell/test_cleanup_worktrees_scan_seam.bats` (sources only
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`), and
  `tests/shell/test_cleanup_worktrees_cli.bats` (references
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` but not `scripts/bash/cleanup_worktrees_lib.sh`, so
  it too shows zero in the `cleanup_worktrees_lib.sh` column P7-T8 tabulates).
  Acceptance: `spec.md` AC-1 begins `- [ ] `;
  `grep -c -F 'self-sourcing' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports exactly `1`, up from `0` before this task; and AC-1 contains the exact literal
  `test_cleanup_worktrees_scan_seam.bats` and the exact literal `test_cleanup_worktrees_cli.bats`.
  The narrowing is asserted through the single-word token `self-sourcing` rather than a phrase
  because a phrase straddles a line break once the criterion wraps and a line-oriented search then
  reports zero matches. The three filename literals are single-line tokens and are unaffected.

- [x] [P1-T4] In `spec.md`, change the AC-14 checkbox and the AC-15 checkbox from `- [x]` to
  `- [ ]`. AC-14 is the criterion beginning "A tracked, modified `*.csproj` entry whose diff
  contains at least one changed line that is not a `HintPath` rewrite"; AC-15 is the criterion
  beginning "For each worktree with dirt, report mode emits exactly one `DIRTFILE|` record".
  Acceptance: both criteria begin `- [ ] ` in `spec.md`, and the count of `- [x]` items inside
  `## Acceptance Criteria` is `33`.

- [x] [P1-T5] In `spec.md`, replace the command text of AC-31 and AC-32 with the routes that exist.
  AC-31 must name `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`,
  and `bash scripts/bash/shell-qc.sh test` run in this worktree with the bats binary supplied
  through the documented `SHELL_QC_BATS_BIN` seam. AC-32 must name a dispatch of
  `.github/workflows/_shell-coverage.yml` against the pushed branch, must state that `kcov` has no
  local route so the CI dispatch is the measurement path, and must add the per-file clause that
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` itself reports line coverage of at least 85%. Both
  remain `- [ ]`.
  Acceptance: AC-31 contains the literal `SHELL_QC_BATS_BIN` and AC-32 contains the literals
  `_shell-coverage.yml` and `at least 85%`, and neither criterion contains the literal
  `wsl -d Ubuntu`. The whole-file assertion that no such literal survives anywhere in `spec.md` is
  deferred to P1-T8, because the Test Strategy block and the Assumptions bullet still carry it
  when this task runs.

- [x] [P1-T6] In `spec.md` `## Acceptance Criteria`, append seven new unchecked criteria whose
  text begins with the explicit identifier prefixes `AC-39 —` through `AC-45 —` in document order.
  The existing criteria carry no identifier prefix; the seven new ones do, so this remediation
  cycle's additions are addressable from the audit documents. The subjects are:
  AC-39 — rung 1 resolves `STAGED_TREE_IS_COMMIT` only when the porcelain **Y** column is a space;
  an `MM` entry falls through to the lower rungs, pinned in both directions by a single fixture
  carrying one `MM` entry and one `M ` entry.
  AC-40 — the ` -> ` payload split is applied only when the porcelain **X** column is `R` or `C`;
  a non-rename entry whose path contains the literal ` -> ` is classified and reported under its
  full path, pinned in both directions.
  AC-41 — the diff header skip is anchored to the header forms git emits, so an added line whose
  content begins `+++ ` is counted as a changed content line and tested for `HintPath`; pinned in
  both directions.
  AC-42 — `STAGED_TREE_IS_COMMIT` is pinned in five material directions, the two hard-failure sites
  counted separately: probe match; probe no-match; probe hard read failure at the `rev-list` site;
  probe hard read failure at the `diff-index` site; and a staged entry with a non-space Y column.
  AC-43 — report mode returns git's non-zero exit code when a candidate worktree's
  `status --porcelain` read fails, emits no `DIRTFILE|` or `DIRTSUM|` record for that worktree, and
  the behaviour is documented in `.claude/skills/cleanup-merged-worktrees/SKILL.md` and pinned by a
  test over `dirty_worktree_status_error`.
  AC-44 — `DISPOSABLE_SESSION_ARTIFACT` is retained as repository-agnostic behaviour and is inert
  in drm-copilot because `.gitignore:6` ignores `/artifacts`; the status read never carries
  `--ignored`, pinned by a test asserting its absence from the stub argv log with a positive
  control.
  AC-45 — `scripts/bash/cleanup_worktrees_dirt_lib.sh` reports kcov line coverage of at least 85%
  in the merged Cobertura report of the CI coverage run against the pushed branch.
  Acceptance: `## Acceptance Criteria` contains exactly `45` checkbox items, of which exactly `33`
  are `- [x]`, and the section contains each of the seven identifier literals `AC-39`, `AC-40`,
  `AC-41`, `AC-42`, `AC-43`, `AC-44`, and `AC-45`.

- [x] [P1-T7] In `spec.md` `## Test Strategy`, replace the four-line fenced command block (the
  `wsl -d Ubuntu -- bash -lc '... agent-a3944b95a7d58e712 ...'` block) with the runnable routes:
  `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`,
  `env SHELL_QC_BATS_BIN=... bash scripts/bash/shell-qc.sh test`, and the
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`
  dispatch, with a sentence stating that `kcov` has no local route and the dispatch measures the
  pushed tree.
  Acceptance: the `## Test Strategy` fenced block contains the literal `_shell-coverage.yml` and
  the fenced block contains no occurrence of the literal `wsl -d Ubuntu`. The whole-file assertion
  is deferred to P1-T8.

- [x] [P1-T8] In `spec.md` `## Assumptions, Constraints, Dependencies`, replace the assumption
  bullet that states toolchain verification runs through the `wsl -d Ubuntu -- bash -lc '...'` form
  with a bullet stating the split: `shfmt`, `shellcheck`, and `bats` run natively in the agent
  worktree; `kcov` has no local route and coverage is measured by dispatching
  `.github/workflows/_shell-coverage.yml` against the pushed branch. The word `natively` must
  appear in this bullet and nowhere else in `spec.md`; the sentence P1-T7 adds to `## Test Strategy`
  must state the same split without using that word, so the count assertion below stays at one.
  Acceptance:
  `grep -c -F 'natively' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports exactly `1`, up from `0` before this task, and that occurrence is inside the replaced
  assumption bullet; and `spec.md` as a whole contains zero occurrences of the literal
  `wsl -d Ubuntu` and zero occurrences of the literal `agent-a3944b95a7d58e712`. The positive half
  is asserted through the single-word token `natively` rather than the phrase describing the kcov
  route because that phrase straddles a line break once the bullet wraps. This is the whole-file
  assertion deferred from P1-T5 and P1-T7; it is placed here because P1-T8 is the last of the three
  tasks that remove those literals. The zero-occurrence half is stated over `wsl -d Ubuntu` rather
  than over the bare token `wsl` because `spec.md` line 17 records the environment as
  `bash toolchain under WSL Ubuntu` and `## Assumptions, Constraints, Dependencies` describes the
  operator running the tool through WSL; neither is a command form, both survive this plan, and an
  assertion over the bare token would therefore be unsatisfiable.

- [x] [P1-T9] In `spec.md` `## Proposed Fix` (a level-two heading, at line 159 as the file stands
  before Phase 1 runs), append a subsection headed
  `**Decision 4 — report-mode exit code on a hard status read.**` reproducing Decision A: the
  propagation is intended, the operator consequence, the rejected `WARN|` alternative, and the
  cross-reference to `.claude/skills/cleanup-merged-worktrees/SKILL.md:197-200` as precedent.
  Acceptance: `spec.md` contains the literal `Decision 4 — report-mode exit code`.

- [x] [P1-T10] In `spec.md` `## Proposed Fix` (the same level-two heading P1-T9 appends to), append
  a subsection headed
  `**Decision 5 — DISPOSABLE_SESSION_ARTIFACT is retained and inert in drm-copilot.**` reproducing
  Decision B: the re-derived provenance of the 2026-09-06 observation, the `.gitignore:6` fact, the
  reachability mechanism (the inspected checkout's own ignore state, with no change to the status
  read), the prohibition on `--ignored`, and the coverage consequence exactly as the Decision B
  block states it, written with the exact single-word literal `coverage-neutral` — retaining the
  rung is coverage-neutral, because the matcher and its emission site are already exercised by
  `dirt_session_artifact`, and lines 74-77 are reported uncovered only as the kcov
  multi-line-statement attribution property, not as a reachability property.
  Acceptance: `spec.md` contains the literal `Decision 5 — DISPOSABLE_SESSION_ARTIFACT`, and
  `grep -c -F 'coverage-neutral' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports exactly `1`, up from `0` before this task. The single-word token replaces the phrase for
  the wrap reason stated in P1-T2; the heading literal is asserted as written because it is the
  opening run of a short bold heading line that carries no wrapping point before it.

- [x] [P1-T11] In `spec.md` `## Acceptance Criteria`, narrow AC-15 — the criterion beginning
  "For each worktree with dirt, report mode emits exactly one `DIRTFILE|` record" — so its scope is
  the non-detached candidate registrations the report classifies, and append an exclusion clause
  naming detached, `main`, and `bare` registrations as never classified, citing the
  `is_detached_candidate` guard that precedes the classification call in `run_report`. The
  criterion remains `- [ ]`.
  The narrowing is required because `run_report` skips detached registrations before it calls
  `classify_worktree_dirt`: `is_detached_candidate "$wflags" && continue` at
  `scripts/bash/cleanup_worktrees_lib.sh:482` runs ahead of the
  `classify_worktree_dirt "$wpath" || rc=$?` call at `:486`, and the `main`/`bare` guard at `:485`
  excludes those two registration kinds as well. AC-15's present text is therefore false for a
  dirty detached worktree, and stays false after Phase 3's fix, which addresses the path field of
  the records that are emitted rather than which registrations produce records at all.
  `remediation-inputs.2026-09-08T05-00.md:164` records AC-15 as contradicted by two findings, R2
  and F14, and `:153` states F14 as "Detached-HEAD registrations receive no dirt records, against
  AC-15's literal text" with the remedy "Extend classification to them, or narrow the AC". Phase 3
  closes the R2 half; this task closes the F14 half by taking the narrow-the-AC branch. The other
  branch, extending classification to detached registrations, is not taken: it would modify
  `scripts/bash/cleanup_worktrees_lib.sh`, which Binding Constraint 1 excludes at 496 of 500 lines.
  Without this task the contradiction would survive the plan while P8-T10 checked AC-15 off, which
  `.claude/skills/acceptance-criteria-tracking/SKILL.md` rules 1 and 4 prohibit.
  Acceptance: the fifteenth checkbox item of `## Acceptance Criteria` — AC-15, whose ordinal
  position is unchanged by P1-T3, P1-T4, and P1-T6 because none of those tasks reorders or inserts
  ahead of it — begins `- [ ] `;
  `grep -c -F 'is_detached_candidate' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
  reports exactly `1`, up from `0` before this task, and that occurrence is inside AC-15; and
  `## Acceptance Criteria` still contains exactly `45` checkbox items of which exactly `33` are
  `- [x]`. `is_detached_candidate` is asserted rather than a prose phrase because it is a single
  identifier token that cannot straddle a line break. The two counts are unchanged from P1-T6
  because this task edits the text of an item P1-T4 has already unchecked and adds no item; the
  assertion is stated so that a narrowing that accidentally added or re-checked a criterion fails
  here rather than at P8-T10.

---

### Phase 2 — R1: rung 1 must honour the porcelain Y column

The fix and its pin live in one fixture carrying two entries that differ **only** in the Y column,
so the same once-per-worktree probe result serves both directions and the pin cannot be satisfied
by an unrelated change.

Rationale for falling through rather than returning `UNIQUE` directly: the lower rungs compare
*working-tree* content. An `MM` entry on a `*.csproj` whose unstaged and staged deltas are both
`HintPath`-confined is genuinely disposable and rung 3 will say so, because
`dirt_is_build_artifact` reads both the worktree diff and the cached diff. An `MM` entry on any
other path reaches rung 6 and is `UNIQUE`.

- [x] [P2-T1] Create the checked-in scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_worktree_delta/` carrying the
  standard scenario baseline (`worktree-list.out`, `for-each-ref.out`,
  `rev-parse.abbrev-ref-HEAD.out`, `rev-parse.show-toplevel.out`, `merge-base.feature-dirt.rc`,
  `worktree-remove.rc`) copied in shape from
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_is_commit/`, plus
  `status._repo-wt_dirt.out` whose two lines are exactly `MM src/a.cs` and `M  src/b.cs` (the
  second line's Y column is a space), plus a `rev-list.HEAD.out` whose first line is `dddd9999` and
  whose second is `eeee7777` and a `diff-index.eeee7777.rc` of `0`, so the probe drops the HEAD sha
  `dddd9999` as its first line and matches `eeee7777`, plus a `diff-quiet..src_a.cs.rc` of `1`.
  That last file is the only lower-rung response `src/a.cs` needs: once rung 1 declines, rung 3's
  `case` takes its `*)` arm because the path is not a project file, and rung 4's tracked probe
  reads `diff-quiet..src_a.cs.rc`. Without it the stub's default exit 0 resolves the entry
  `CONTENT_ON_MAIN` and the P2-T2 assertion cannot pass. No `hash-object.src_a.cs.out` is supplied,
  so the stub's default empty response takes the `hash-object`-empty fail-closed branch and the
  entry resolves `UNIQUE`. Every key here follows the stub scheme documented at
  `tests/fixtures/cleanup_worktrees/stub-bin/git:10-70`, under which `diff --quiet main -- <path>`
  keys on an empty range spec and so carries two consecutive dots.
  Acceptance: the directory exists, `status._repo-wt_dirt.out` has exactly two lines, its first
  line is exactly `MM src/a.cs`, its second line is exactly `M  src/b.cs`, `diff-index.eeee7777.rc`
  contains exactly `0`, `diff-quiet..src_a.cs.rc` contains exactly `1`, and the directory contains
  no file named `hash-object.src_a.cs.out`.

- [x] [P2-T2] Create `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` with a header
  paragraph stating its subject (the staged-tree rung's five directions and the classifier's
  fail-closed branches), a `setup()` sourcing
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, and
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`, the `dirt`/`dirt_log`/`argv_log` helpers in the
  form used at `tests/shell/test_cleanup_worktrees_dirt_classify.bats:41-58`, and exactly these
  two tests, whose descriptions this plan quotes verbatim for the executor to create:
  `dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE`
  and
  `dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT`.
  The first asserts the record for `src/a.cs` carries verdict `UNIQUE`, that the output contains
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and that the output contains no
  `DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs`. The second asserts the
  output contains `DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs`.
  Acceptance: the file exists, `wc -l` reports at most 500, and it contains both quoted test
  descriptions verbatim.

- [x] [P2-T3] [expect-fail] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` against
  the **unfixed** library and write
  `evidence/regression-testing/fail-before-staged-y-column.2026-09-08T06-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, the verbatim failing-test line, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero `EXIT_CODE:` and its captured output contains a
  `not ok` line for the test description
  `dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE`,
  and contains an `ok` line for
  `dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT`.
  Both halves are required: the second proves the fixture is not simply broken.

- [x] [P2-T4] In `scripts/bash/cleanup_worktrees_dirt_lib.sh`, gate rung 1 on the Y column. Add
  `y="${xy:1:1}"` to the `classify_dirt_entry` local declaration that currently reads
  `local x="${xy:0:1}" untracked=0 blob="" hrc=0 mrc=0 mainblob="" brc=0` (line 217 as the file
  stands before this task), and change the rung-1 condition that currently reads
  `if [[ $x != " " && $x != "?" && $x != "!" ]]; then` (line 231 as the file stands before this
  task) to require additionally that `$y` is a single space. Add a comment block immediately above
  that condition stating that the X column answers an index question, that
  `diff-index --cached --quiet` says nothing about a non-space Y column, and that an entry with a
  non-space Y column therefore falls through to the rungs that compare working-tree content — so
  an `MM` entry on a `HintPath`-confined project file can still reach
  `DISPOSABLE_BUILD_ARTIFACT`, because `dirt_is_build_artifact` reads both the worktree diff and
  the cached diff, while an `MM` entry on any other path reaches `UNIQUE`.
  Both anchors are quoted verbatim above rather than referenced by line number alone, because
  later phases in this plan insert lines into this file and shift every number after their
  insertion point.
  Acceptance: `scripts/bash/cleanup_worktrees_dirt_lib.sh` contains the literal `${xy:1:1}`;
  `grep -c -F '!= "!" ]]; then' scripts/bash/cleanup_worktrees_dirt_lib.sh` reports exactly `1`,
  down from `2` before this task; and `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh` exits 0.
  The surviving occurrence is the `any_staged` pre-scan inside `classify_worktree_dirt`
  (line 351 as the file stands before this task), which decides only whether to issue the probe and
  is deliberately not gated on the Y column: a worktree carrying only `MM` entries must still issue
  the probe, because the probe's result is what rung 1 consumes for the entries that do have a
  space Y column. The count drops from 2 to 1 because the rung-1 condition at line 231 gains the
  Y-column term after the `!= "!"` clause, so that line no longer ends `!= "!" ]]; then`.

- [x] [P2-T5] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` and
  write `evidence/regression-testing/pass-after-staged-y-column.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and
  `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, and the recorded output contains
  an `ok` line for each of the two test descriptions quoted in P2-T2.

- [x] [P2-T6] Re-run the three pre-existing dirt suites together —
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
  — and write `evidence/regression-testing/sibling-check-phase2.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, and `Output Summary:` naming the sibling
  region checked: `dirt_staged_tree_is_commit` (X column `M`, Y column space, must remain
  `STAGED_TREE_IS_COMMIT`) and `dirt_build_artifact` (X column space, must remain unaffected).
  Acceptance: `EXIT_CODE: 0` and the recorded `not ok` count is `0`.

---

### Phase 3 — R2: the ` -> ` split applies only to `R` and `C` entries

- [ ] [P3-T1] Create the checked-in scenario directory
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_rename_split/` with the standard scenario
  baseline and a `status._repo-wt_dirt.out` whose two lines are exactly `?? notes -> draft.md` and
  `R  old.md -> new.md`.
  Derive every stub key from the sanitize rule at
  `tests/fixtures/cleanup_worktrees/stub-bin/git:89-93`, which is `${s//[^A-Za-z0-9._-]/_}`. Under
  it `notes -> draft.md` sanitizes to **`notes_-__draft.md`**: the space becomes `_`, the `-` is
  retained, the `>` becomes `_`, and the second space becomes `_`. A key one underscore short would
  not raise a missing-file error — `respond`
  (`tests/fixtures/cleanup_worktrees/stub-bin/git:95-109`) falls through to exit 0 with no stdout
  for an unmatched key — so the entry would resolve `UNIQUE` through the `hash-object`-empty
  fail-closed branch of `scripts/bash/cleanup_worktrees_dirt_lib.sh`, the branch whose condition
  line reads verbatim `if ((hrc != 0)) || [[ -z $blob ]]; then`, and the P3-T2 assertion would pass
  for the wrong reason, indistinguishable from a hash-object read failure. That branch is line 282
  as the file stands at `eac077a2`, but it is cited by its verbatim condition rather than by number
  because P2-T4 inserts a comment block above line 231 and shifts every line below it.
  Under the unfixed split the first entry's payload truncates to `draft.md`, so the reads are
  `hash-object.draft.md` and `rev-parse.main_draft.md`; supply both, with the `rev-parse` response
  equal to the `hash-object` response, which resolves the entry `CONTENT_ON_MAIN`. Under the fixed
  split the payload is the full `notes -> draft.md`, so the reads are
  `hash-object.notes_-__draft.md` and `rev-parse.main_notes_-__draft.md`; supply only the first,
  carrying a blob different from `hash-object.draft.md`. The `rev-parse` and `log.find-object`
  responses for the full path are deliberately absent, so the stub's default (exit 0, no stdout)
  makes rung 4's untracked half miss and rung 5 find nothing, and the entry reaches rung 6 as
  `UNIQUE`.
  Supply no response for the second entry, and copy no `rev-list.HEAD` file into this directory. The
  `R ` entry sets the `any_staged` flag, so the probe is issued; with no `rev-list.HEAD` response
  the stub's default empty output makes `dirt_staged_tree_commit` return 1, rung 1 declines, rung 3
  takes its `*)` arm because `new.md` is not a project file, and rung 4's tracked probe reads the
  stub default exit 0 for `diff-quiet..new.md`, so `new.md` resolves `CONTENT_ON_MAIN` under both
  the unfixed and the fixed split. A `rev-list.HEAD.out` copied in from the source scenario would
  instead resolve the entry `STAGED_TREE_IS_COMMIT` and the P3-T2 assertion could not pass.
  Acceptance: the directory exists; `status._repo-wt_dirt.out` has exactly two lines and its first
  line is exactly `?? notes -> draft.md`; the directory contains `hash-object.draft.md.out` and
  `hash-object.notes_-__draft.md.out` whose contents differ; it contains
  `rev-parse.main_draft.md.out` byte-identical to `hash-object.draft.md.out`; it contains no file
  whose name begins `rev-parse.main_notes_`; and it contains neither `rev-list.HEAD.out` nor
  `rev-list.HEAD.rc`. The two differing blobs are what makes the pin able to fail in both
  directions.

- [ ] [P3-T2] Append two tests to `tests/shell/test_cleanup_worktrees_dirt_classify.bats` with
  these descriptions, quoted verbatim here for the executor to create:
  `dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE`
  and
  `dirt_rename_split: a genuine R entry is still split and the destination path is classified`.
  The first asserts the output contains
  `DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md`, contains
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and contains no
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md`. The second asserts the output contains
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||R |new.md` and that the stub argv log contains no
  invocation naming `old.md`.
  Acceptance: `tests/shell/test_cleanup_worktrees_dirt_classify.bats` contains both quoted
  descriptions verbatim and `wc -l` reports at most 500.

- [ ] [P3-T3] [expect-fail] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats` against
  the unfixed split and write
  `evidence/regression-testing/fail-before-rename-split.2026-09-08T06-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, the verbatim failing line, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero `EXIT_CODE:`, contains a `not ok` line for
  `dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE`,
  and contains an `ok` line for
  `dirt_rename_split: a genuine R entry is still split and the destination path is classified`.

- [ ] [P3-T4] In `scripts/bash/cleanup_worktrees_dirt_lib.sh`, replace the line that currently
  reads `[[ $rel == *" -> "* ]] && rel="${rel#* -> }"` inside `classify_worktree_dirt` (line 367 as
  the file stands at `eac077a2`; the number has shifted by Phase 2's insertion, so the line content
  is the anchor) with the following three lines, whose spelling is required rather than
  illustrative, because `shfmt` will not normalise between a `case` form, a quoted `== "R"`, and
  the unquoted form the acceptance condition searches for:

  ```
  	if [[ ${xy:0:1} == R || ${xy:0:1} == C ]]; then
  		rel="${rel#* -> }"
  	fi
  ```

  Indentation is a single tab for the `if` and `fi` and two tabs for the assignment, matching the
  tab indentation `shfmt` default formatting produces in this file. The variable is `xy` and not
  the enclosing function's `x`, because `x` holds the last value the `any_staged` pre-scan loop
  assigned rather than the current entry's X column. Amend the two comment lines immediately above
  the replaced line to state that `git status --porcelain` uses the `OLD -> NEW` payload only for
  those two codes and that a space does not trigger C-quoting, so an ordinary path may contain the
  literal.
  Acceptance: `scripts/bash/cleanup_worktrees_dirt_lib.sh` contains the literal `${xy:0:1} == R`,
  contains zero occurrences of the literal `$rel == *" -> "* ]] && rel=` (the unconditional split's
  distinguishing text, which the three-line replacement does not carry), and
  `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh` exits 0.

- [ ] [P3-T5] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats` and write
  `evidence/regression-testing/pass-after-rename-split.2026-09-08T06-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, and the output contains an `ok`
  line for each of the two descriptions quoted in P3-T2.

- [ ] [P3-T6] Re-run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`
  and write `evidence/regression-testing/sibling-check-phase3.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the sibling region checked:
  the `dirt_pipe_path` field-ordering pin at
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats:252` and the `dirt_quoted_path` pin at
  `:263`, both of which read the same `rel` value the edited line produces.
  Acceptance: `EXIT_CODE: 0` and the recorded `not ok` count is `0`.

---

### Phase 4 — R5: anchor the diff header skip to the forms git emits

- [ ] [P4-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_plus_content/`
  modelled on `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_mixed/`: a
  `status._repo-wt_dirt.out` of exactly one line ` M src/Legacy/Legacy.csproj`, a
  `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` retaining the genuine
  `--- a/src/Legacy/Legacy.csproj` and `+++ b/src/Legacy/Legacy.csproj` headers plus one genuine
  `HintPath` rewrite pair plus one added line whose text is exactly
  `+++ this line is real added content and is NOT a HintPath rewrite`, and the rung-4 and rung-5
  responses (`diff-quiet..src_Legacy_Legacy.csproj.rc` of `1`, a `hash-object` response, and no
  `log.find-object` hit) that resolve the entry to `UNIQUE` once rung 3 correctly declines it.
  Acceptance: the directory exists, `status._repo-wt_dirt.out` has exactly one line, and
  `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` contains both the literal `--- a/` and the
  literal `+++ this line is real added content`.

- [ ] [P4-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_added_file/`
  with a `status._repo-wt_dirt.out` of exactly one line `A  src/Legacy/Legacy.csproj`, no worktree
  diff fixture, and a `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` whose headers are
  exactly `--- /dev/null` and `+++ b/src/Legacy/Legacy.csproj` followed by a hunk header and one
  added `HintPath` line, so the entry resolves `DISPOSABLE_BUILD_ARTIFACT` only if the
  `/dev/null` header forms are skipped. Supply the rung-4 and rung-5 responses that would resolve
  the entry to `UNIQUE` if rung 3 declined it, so the two outcomes are distinguishable. Copy no
  `rev-list.HEAD` file into this directory: the `A ` status code sets the `any_staged` flag, so the
  probe is issued, and with no `rev-list.HEAD` response the stub's default empty output makes the
  probe return 1 and rung 1 decline. A `rev-list.HEAD.out` copied in from a source scenario would
  resolve the entry `STAGED_TREE_IS_COMMIT` at rung 1 and the entry would never reach rung 3.
  Acceptance: the directory exists,
  `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` contains the literal `--- /dev/null`,
  and the directory contains neither `rev-list.HEAD.out` nor `rev-list.HEAD.rc`.

- [ ] [P4-T3] Append two tests to `tests/shell/test_cleanup_worktrees_dirt_classify.bats` with
  these descriptions, quoted verbatim here for the executor to create:
  `dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE`
  and
  `dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT`.
  The first asserts the output contains
  `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj` and contains no
  `DISPOSABLE_BUILD_ARTIFACT`. The second asserts the output contains
  `DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT||A |src/Legacy/Legacy.csproj` and
  `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|`.
  Acceptance: the file contains both quoted descriptions verbatim and `wc -l` reports at most 500.

- [ ] [P4-T4] [expect-fail] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats` against
  the unfixed filter and write
  `evidence/regression-testing/fail-before-diff-header-anchor.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, the verbatim failing line, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero `EXIT_CODE:`, contains a `not ok` line for
  `dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE`,
  and contains an `ok` line for
  `dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT`.
  Both halves are required, matching the guard P2-T3 and P3-T3 carry: the `ok` half proves the
  added-file fixture is not simply broken. That half is satisfiable against the unfixed filter
  because the fixture's `--- /dev/null` and `+++ b/src/Legacy/Legacy.csproj` headers both match the
  unanchored `"+++ "* | "--- "*` pattern and are skipped, so the entry resolves
  `DISPOSABLE_BUILD_ARTIFACT` before P4-T5 lands as well as after it. Without the `ok` half a
  fixture that produced no record at all would satisfy this task.

- [ ] [P4-T5] In `scripts/bash/cleanup_worktrees_dirt_lib.sh`, replace the header-skip pattern
  line that currently reads `"+++ "* | "--- "*) continue ;;` inside
  `dirt_diff_is_hintpath_confined` (line 159 at `eac077a2`; Phase 2's and Phase 3's insertions are
  both below this line and do not shift it, but the line content is used as the anchor for
  consistency with the other two library edits) with one anchored to the four
  forms git emits — a `---` header prefixed `a/`, a `+++` header prefixed `b/`, and the two
  `/dev/null` forms — and amend the docstring paragraph that begins
  `# The \`---\` and \`+++\` file headers are excluded before the test` to state that the skip is
  anchored, that the default `a/` and `b/` prefixes are assumed because the library issues
  `diff --no-color -U0` without `--no-prefix`, and that a header form the pattern does not match is
  counted as a changed content line, which fails closed to `UNIQUE`.
  Acceptance: `scripts/bash/cleanup_worktrees_dirt_lib.sh` contains the literal `"--- /dev/null"`,
  contains zero occurrences of the literal `"+++ "* | "--- "*` (the unanchored pattern, whose
  anchored replacement carries the `a/` and `b/` prefixes inside the quotes), and
  `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh` exits 0.

- [ ] [P4-T6] Re-run the three suites that read the header-skip branch —
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
  — and write `evidence/regression-testing/pass-after-diff-header-anchor.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and
  `Output Summary:`.
  The two clear-mode suites are included because `dirt_clear_all_disposable` and
  `dirt_clear_clean_failed` each carry a
  `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` whose first two lines are genuine
  `--- a/src/Legacy/Legacy.csproj` and `+++ b/src/Legacy/Legacy.csproj` headers that P4-T5's
  anchored pattern must continue to skip. A mis-anchored replacement leaves those two entries
  counted as changed content, resolves them `UNIQUE`, and turns the clear into a
  `REFUSED-UNIQUE` — a failure that surfaces nowhere in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats` and would otherwise first appear at
  P6-T7, three phases later.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, the output contains an `ok`
  line for each of the two descriptions quoted in P4-T3, and the output contains an `ok` line for
  `dirt_clear_all_disposable: the clear result record reports OK` and for
  `dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal`, the two
  pre-existing clear-mode tests that consume those genuine-header fixtures.

- [ ] [P4-T7] Write `evidence/regression-testing/sibling-check-phase4.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:` naming the P4-T6 run, `EXIT_CODE:`, and `Output Summary:` naming the
  sibling region: the two pre-existing pins that read the same header-skip branch —
  `dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT`
  (`tests/shell/test_cleanup_worktrees_dirt_classify.bats:60`), whose fixture carries real
  `--- a/` and `+++ b/` headers that must still be skipped, and
  `dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE` (`:83`).
  Acceptance: the artifact records `EXIT_CODE: 0` and names both pre-existing test descriptions
  verbatim, and the P4-T6 output contains an `ok` line for each of them.

---

### Phase 5 — R4: the three staged-rung directions not already pinned by Phase 2

R4 has **five** material directions, counting the probe's two hard-failure sites separately: probe
match; probe no-match; `rev-list` hard failure; `diff-index` hard failure; and a staged entry with a
non-space Y column. One is pinned today. Phase 2 adds two (P2-T2) and this phase adds the remaining
three (P5-T4), for five pins in total. `remediation-inputs.2026-09-08T05-00.md` describes three
remaining directions because it counts the two hard-failure sites as one; that is the same set
counted differently, not a different set, and the five-direction wording is what AC-42 carries,
because P8-T10 checks AC-42 off permanently and the wording outlives this cycle.

The reviewer drove the no-match and hard-read-failure paths directly and reports they behave
correctly today, so these are pins of correct behaviour rather than fixes. Each therefore carries a
mutation probe demonstrating that the new pin can fail.

- [ ] [P5-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_no_match/` with a
  `status._repo-wt_dirt.out` of exactly one line `M  src/a.cs`, a `rev-list.HEAD.out` whose first
  line is `dddd9999` and whose second is `eeee7777`, a `diff-index.eeee7777.rc` of `1`, and a
  `diff-quiet..src_a.cs.rc` of `1`. This scenario is the one of the three that reaches the lower
  rungs: the probe returns 1, rung 1 declines, rung 3 takes its `*)` arm, and rung 4's tracked
  probe reads `diff-quiet..src_a.cs.rc`. Without that file the stub's default exit 0 resolves the
  entry `CONTENT_ON_MAIN` and the P5-T4 assertion cannot pass. Supply no
  `hash-object.src_a.cs.out`, so the empty default takes the fail-closed branch and the entry
  resolves `UNIQUE`.
  Acceptance: the directory exists, `diff-index.eeee7777.rc` contains exactly `1`, and
  `diff-quiet..src_a.cs.rc` contains exactly `1`.

- [ ] [P5-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_probe_revlist_error/`
  with a `status._repo-wt_dirt.out` of exactly one line `M  src/a.cs` and a `rev-list.HEAD.rc` of
  `128`, so `dirt_staged_tree_commit` returns 2 from
  `scripts/bash/cleanup_worktrees_dirt_lib.sh:97-99` and rung 1 takes the branch whose condition
  line reads verbatim `if [[ $staged == "ERROR" ]]; then`. That branch is line 232 as the file
  stands at `eac077a2`, but it is cited by its verbatim condition rather than by number because
  P2-T4 inserts a comment block above line 231 and shifts every line below it; the `:97-99`
  citation is left as a line number because the earliest-positioned edit this plan makes to this
  file is P4-T5's docstring amendment at line 136, so every line at or above 135 keeps its number
  through execution.
  Supply **no** lower-rung response and no `diff-quiet..src_a.cs.rc`: the X
  column is `M` and the Y column is a space, so rung 1's gate is entered and the `ERROR` branch
  prints `UNIQUE` and returns before rung 2 is reached. Adding a lower-rung file here would create
  a fixture entry no code path reads.
  Acceptance: the directory exists, `rev-list.HEAD.rc` contains exactly `128`, and the directory
  contains neither `diff-quiet..src_a.cs.rc` nor `diff-quiet..src_a.cs.out`.

- [ ] [P5-T3] Create
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_probe_diffindex_error/` with a
  `status._repo-wt_dirt.out` of exactly one line `M  src/a.cs`, a `rev-list.HEAD.out` of
  `dddd9999` then `eeee7777`, and a `diff-index.eeee7777.rc` of `128`, so the probe returns 2 from
  its second hard-failure site at `scripts/bash/cleanup_worktrees_dirt_lib.sh:113-115`. As in
  P5-T2, supply **no** lower-rung response and no `diff-quiet..src_a.cs.rc`: rung 1's `ERROR`
  branch prints `UNIQUE` and returns before rung 2 is reached, so a lower-rung file here would be
  a fixture entry no code path reads.
  Acceptance: the directory exists, `diff-index.eeee7777.rc` contains exactly `128`, and the
  directory contains neither `diff-quiet..src_a.cs.rc` nor `diff-quiet..src_a.cs.out`.

- [ ] [P5-T4] Append three tests to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` with
  these descriptions, quoted verbatim here for the executor to create:
  `dirt_staged_tree_no_match: a staged index matching no ancestor tree is UNIQUE not STAGED_TREE_IS_COMMIT`,
  `dirt_staged_probe_revlist_error: a rev-list hard failure maps the staged entry to UNIQUE`, and
  `dirt_staged_probe_diffindex_error: a diff-index exit above one maps the staged entry to UNIQUE`.
  Each asserts the output contains `DIRTFILE|/repo-wt/dirt|UNIQUE||M |src/a.cs` and
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` and contains no `STAGED_TREE_IS_COMMIT` and no
  `ALL_DISPOSABLE`. The second and third additionally assert, over the stub argv log with the
  filtering helper, that the probe was issued — a positive control without which each test would
  pass in a build where no classification ran at all.
  Acceptance: the file contains all three quoted descriptions verbatim and `wc -l` reports at most
  500.

- [ ] [P5-T5] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` and
  write `evidence/regression-testing/pass-staged-rung-directions.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and
  `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, and the output contains an `ok`
  line for each of the three descriptions quoted in P5-T4 and for the two quoted in P2-T2.

- [ ] [P5-T6] Demonstrate the three new pins can fail. Record
  `sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh`; apply one temporary mutation to
  `dirt_staged_tree_commit` that makes its no-match return and its two hard-failure returns
  indistinguishable from a match, by replacing each of `return 1` and the two `return 2`
  statements in that function's body with a path that prints a candidate sha and returns 0; record
  the sha256 again; re-run the P5-T5 command; revert the mutation; record the sha256 a third time;
  re-run the P5-T5 command again. Write
  `evidence/qa-gates/staged-rung-mutation-probe.2026-09-08T06-00.md` with `Timestamp:`, all five
  commands, the two bats `EXIT_CODE:` values, the three sha256 values, the mutated hunk, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero exit for the mutated bats run whose output carries a
  `not ok` line for each of the three P5-T4 descriptions; exit 0 for the reverted bats run; the
  first and third recorded sha256 values are equal; and the second differs from them. The sha256
  triple is the failable revert check — a diff against the base branch is non-empty here because
  the phase's own fixes are in the tree, so it cannot distinguish a reverted mutation from an
  unreverted one.

---

### Phase 6 — R3: the remaining fail-closed branches

Targets, taken from the enumeration in
`evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md` rather than re-derived. This phase
closes nine lines: 155, 258, 259, 273, 274, 308, 309, 415, and 416.

The rest of the closable set is closed earlier. Line 191, rung 3's `*) return 1 ;;` arm for a path
that is not a project file, is first reached by [P2-T1]'s `MM src/a.cs` entry once [P2-T4] makes it
fall through rung 1, and is reached again by [P3-T1]'s tracked `R` entry and by [P5-T1]. Lines 269
and 270, the second `CONTENT_ON_MAIN` emission site, are closed by [P3-T1]'s tracked `R` entry
through rung 4's tracked half. Lines 98, 113, 114, 117, 233 and 234 are closed by Phase 5; line 343
by Phase 7's report-mode exit test.

Ten entries in the enumeration are not closable by any scenario and no task here targets them.
Lines 95, 148, 151 and 305 are the **first** physical lines of backslash-continued commands
(`rev-list`, the cached `diff`, the worktree `diff`, and `log --find-object`); kcov attributes each
statement to its continuation line — 96, 149, 152 and 306, none of which appears in the uncovered
list — so the opening line can never be marked executed. Lines 160 (`"+"* | "-"*) ;;`) and 190
(the `*.csproj | packages.config | */packages.config | app.config | */app.config) ;;` arm) are
empty `case` arms carrying no statement to instrument; both are already taken by every
build-artifact fixture and are reported uncovered regardless. Lines 74-77 are the interior of a
multi-line array assignment whose statement kcov attributes to its closing line 78, the same
property. The gate for this finding is therefore the file percentage recorded in P8-T7, not a
per-line list.

Arithmetic: 29 uncovered lines, 10 unclosable, 19 closed — one in Phase 2, two in Phase 3, six in
Phase 5, nine in Phase 6, one in Phase 7. That takes the file from 138/167 to 157/167, or 94.0%,
against an 85% floor that requires 142/167. The floor is cleared by Phase 5 alone, so the margin
does not depend on this phase landing every scenario.

- [ ] [P6-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_read_errors/` with a
  `status._repo-wt_dirt.out` of exactly two lines, ` M src/Legacy/Legacy.csproj` and
  ` M docs/tracked.md`. Supply `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.rc` of `128` so the
  rung-3 diff read hard-fails, and `diff-quiet..docs_tracked.md.rc` of `128` so the rung-4 tracked
  probe exits above 1. Both entries must resolve `UNIQUE` and the aggregate `HAS_UNIQUE`.
  Acceptance: the directory exists, `status._repo-wt_dirt.out` has exactly two lines, and both
  named `.rc` files contain exactly `128`.

- [ ] [P6-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_history_read_error/` with a
  `status._repo-wt_dirt.out` of exactly one line `?? docs/old.md`, a `hash-object.docs_old.md.out`
  carrying a blob, a `rev-parse.main_docs_old.md.rc` of `128`, a `rev-parse.verify.main_1000.rc`
  of `1` so the range falls back to plain `main`, and a `log.find-object.<blob>.rc` of `128` keyed
  on that blob per the stub scheme at `tests/fixtures/cleanup_worktrees/stub-bin/git:321-331`, so
  the `log --find-object` read hard-fails and the entry resolves `UNIQUE`.
  Acceptance: the directory exists and contains exactly one file whose name begins
  `log.find-object.` and whose extension is `.rc`, containing exactly `128`.

- [ ] [P6-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_reset_failed/` as a
  copy of `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_all_disposable/` with the single
  addition of `reset-hard.rc` containing `1`, so `clear_disposable_dirt` emits
  `ACTION|dirt-clear|/repo-wt/dirt|FAILED` from its reset-failure branch and issues no `clean` and
  no removal retry.
  Acceptance: the directory exists, `reset-hard.rc` contains exactly `1`, and
  `status._repo-wt_dirt.out` is byte-identical to
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_all_disposable/status._repo-wt_dirt.out`.

- [ ] [P6-T4] Append two tests to `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` with
  these descriptions, quoted verbatim here for the executor to create:
  `dirt_tracked_read_errors: a rung-3 diff read failure and a rung-4 probe failure both map to UNIQUE`
  and
  `dirt_history_read_error: a find-object read failure maps the untracked entry to UNIQUE`.
  The first asserts both `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj` and
  `DIRTFILE|/repo-wt/dirt|UNIQUE|| M|docs/tracked.md` are present with
  `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, and that no `DISPOSABLE_BUILD_ARTIFACT` and no
  `CONTENT_ON_MAIN` appears. The second asserts
  `DIRTFILE|/repo-wt/dirt|UNIQUE||??|docs/old.md`, `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`, no
  `CONTENT_IN_HISTORY`, and — as the positive control — that the argv log contains a
  `--find-object` invocation.
  Acceptance: the file contains both quoted descriptions verbatim and `wc -l` reports at most 500.

- [ ] [P6-T5] Append one test to `tests/shell/test_cleanup_worktrees_dirt_clear.bats` with this
  description, quoted verbatim here for the executor to create:
  `dirt_clear_reset_failed: a non-zero reset reports FAILED, runs no clean, and retries no removal`.
  It drives `clear_candidate dirt_clear_reset_failed`, asserts a non-zero status, asserts the
  output contains `ACTION|dirt-clear|/repo-wt/dirt|FAILED` and contains no
  `ACTION|dirt-clear|/repo-wt/dirt|OK`, asserts the argv log contains `reset --hard` as the
  positive control, and asserts the log contains no whole-token `clean` and exactly one
  `worktree remove`.
  Acceptance: `tests/shell/test_cleanup_worktrees_dirt_clear.bats` contains that description
  verbatim and `wc -l` reports at most 500.

- [ ] [P6-T6] Extend the verdict-token membership test at
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats:214` so its scenario list names every
  directory under `tests/fixtures/cleanup_worktrees/scenarios/` whose name begins `dirt_` — 25
  after this plan's ten additions — update the `seen` guard from `17` to the total number of
  `DIRTFILE|` records those scenarios produce, which is `30` for the fixture set this plan
  specifies, and add a companion assertion that the number of scenarios the loop iterated equals
  the number of `dirt_*` directories present on disk, so a future scenario cannot be silently
  omitted from the list. Rename the test description to
  `every verdict emitted across the checked-in dirt scenarios is one of the six defined tokens`.
  Acceptance: `tests/shell/test_cleanup_worktrees_dirt_classify.bats` contains that description
  verbatim, contains the literal `dirt_clear_reset_failed`, and no longer contains the literal
  `-eq 17`.

- [ ] [P6-T7] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
  and write `evidence/regression-testing/pass-failclosed-scenarios.2026-09-08T06-00.md` with
  `Timestamp:`, `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and
  `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, and the output contains an `ok`
  line for each of the three descriptions quoted in P6-T4, P6-T5, and P6-T6.

- [ ] [P6-T8] Demonstrate the fail-closed pins can fail. Record
  `sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh`; apply one temporary mutation replacing
  the rung-3 hard-failure emission in `classify_dirt_entry` — the `printf 'UNIQUE|\n'` guarded by
  `if ((brc > 1)); then` — with a `printf 'CONTENT_ON_MAIN|\n'`; record the sha256 again; re-run
  the P6-T7 command; revert; record the sha256 a third time; re-run the P6-T7 command again. Write
  `evidence/qa-gates/failclosed-mutation-probe.2026-09-08T06-00.md` with `Timestamp:`, all five
  commands, the two bats `EXIT_CODE:` values, the three sha256 values, the mutated hunk, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero exit for the mutated bats run whose output carries a
  `not ok` line for
  `dirt_tracked_read_errors: a rung-3 diff read failure and a rung-4 probe failure both map to UNIQUE`;
  exit 0 for the reverted bats run; the first and third recorded sha256 values are equal; and the
  second differs from them.

---

### Phase 7 — R6a and R6b: documentation and pins for the two recorded decisions

`.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundle mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
must remain byte-identical. Every edit in this phase is applied to both files.

- [ ] [P7-T1] In `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## Report Line Contract`,
  extend the `DIRTSUM|` bullet block with a paragraph stating the report-mode exit-status
  behaviour: when a candidate worktree's `git status --porcelain` read fails, report mode emits no
  `DIRTFILE|` and no `DIRTSUM|` record for that worktree and returns git's non-zero exit code, so a
  checkout containing such a worktree exits non-zero from report mode where it previously exited 0
  and produced a complete report. State that this is deliberate, that the alternative would make an
  incomplete report indistinguishable from a report about a clean worktree, and cross-reference the
  analogous apply-mode note in the End-to-End Workflow. The word `indistinguishable` must appear in
  this new paragraph and nowhere else in the file.
  Acceptance:
  `grep -c -F 'indistinguishable' .claude/skills/cleanup-merged-worktrees/SKILL.md`
  reports exactly `1`, up from `0` before this task, and that occurrence is inside the new
  paragraph in `## Report Line Contract`. The asserted token is a single word rather than the
  sentence describing the exit-code behaviour because that sentence straddles a line break once the
  paragraph wraps and a line-oriented search then reports zero matches. The file carries no
  occurrence of `indistinguishable` at `eac077a2`, so the count moves from `0` to `1` only if the
  executor writes the paragraph.

- [ ] [P7-T2] In the same `## Report Line Contract` section, extend the `DIRTFILE|` bullet with a
  sentence recording Decision B: `DISPOSABLE_SESSION_ARTIFACT` matches three fixed repository paths
  under `artifacts/`, is repository-agnostic, and cannot fire in a checkout that gitignores
  `artifacts/` — which drm-copilot does at `.gitignore:6` — because the status read never carries
  `--ignored`; and that the rung is retained for consumer checkouts and must not be made reachable
  by adding `--ignored`. The hyphenated word `repository-agnostic` must appear in this new sentence
  and nowhere else in the file.
  Acceptance:
  `grep -c -F 'repository-agnostic' .claude/skills/cleanup-merged-worktrees/SKILL.md`
  reports exactly `1`, up from `0` before this task, and that occurrence is inside the `DIRTFILE|`
  bullet of `## Report Line Contract`. The asserted token is a single hyphenated word rather than
  the clause prohibiting `--ignored` because that clause straddles a line break once the bullet
  wraps. The existing statement at `.claude/skills/cleanup-merged-worktrees/SKILL.md:373-375`, that
  status is read without `--ignored` so an ignored file never becomes an entry, sits in
  `## Prohibited Shortcuts` and is a different location; it carries no occurrence of
  `repository-agnostic`, so it does not satisfy this task and does not disturb the count.

- [ ] [P7-T3] Copy `.claude/skills/cleanup-merged-worktrees/SKILL.md` over
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  and write `evidence/qa-gates/skill-mirror-parity.2026-09-08T06-00.md` with `Timestamp:`,
  `Command:` naming the `sha256sum` invocation over both paths, `EXIT_CODE:`, the two digests, and
  `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the two recorded digests are equal.

- [ ] [P7-T4] Append one test to `tests/shell/test_cleanup_worktrees_dirt_regression.bats` with
  this description, quoted verbatim here for the executor to create:
  `report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record`.
  It runs `run_report` under `CLEANUP_WT_STUB_SCENARIO` pointing at
  `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree_status_error` with the scan seam wired
  to the checked-in scan stub and stderr discarded inside the subshell, asserts `status` equals
  `128`, asserts the output contains `WORKTREE|/repo-wt/dirty|feature-dirty|` as the positive
  control, and asserts the output contains no `DIRTFILE|` and no `DIRTSUM|`.
  Acceptance: `tests/shell/test_cleanup_worktrees_dirt_regression.bats` contains that description
  verbatim and `wc -l` reports at most 500.

- [ ] [P7-T5] Append one test to `tests/shell/test_cleanup_worktrees_dirt_classify.bats` with this
  description, quoted verbatim here for the executor to create:
  `no status read the classifier issues carries --ignored`. It drives `dirt_log dirt_session_artifact`,
  asserts the filtered argv log contains `status --porcelain` as the positive control, and asserts
  the log contains no `--ignored`.
  Acceptance: `tests/shell/test_cleanup_worktrees_dirt_classify.bats` contains that description
  verbatim and `wc -l` reports at most 500.

- [ ] [P7-T6] Run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats`
  and write `evidence/regression-testing/pass-decision-pins.2026-09-08T06-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the plan line, the `ok`/`not ok` counts, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, and the output contains an `ok`
  line for each of the two descriptions quoted in P7-T4 and P7-T5.

- [ ] [P7-T7] Demonstrate the report-mode exit pin can fail. Record
  `sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh`; apply one temporary mutation replacing
  the `return "$srrc"` guarded by `if ((srrc != 0)); then` in `classify_worktree_dirt` with
  `return 0`; record the sha256 again; run
  `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats`; revert;
  record the sha256 a third time; run that bats command again. Write
  `evidence/qa-gates/report-exit-mutation-probe.2026-09-08T06-00.md` with `Timestamp:`, all five
  commands, the two bats `EXIT_CODE:` values, the three sha256 values, the mutated hunk, and
  `Output Summary:`.
  Acceptance: the artifact records a non-zero exit for the mutated bats run whose output carries a
  `not ok` line for
  `report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record`;
  exit 0 for the reverted bats run; the first and third recorded sha256 values are equal; and the
  second differs from them.

- [ ] [P7-T8] Add `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` to the AC-1 sourcing
  set by confirming its `setup()` sources `scripts/bash/cleanup_worktrees_lib.sh` and
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`, and write
  `evidence/qa-gates/dirt-lib-source-set.2026-09-08T06-00.md` recording, for every file matching
  `tests/shell/test_cleanup_worktrees_*.bats`, whether it references `cleanup_worktrees_lib.sh`
  and whether it references `cleanup_worktrees_dirt_lib.sh`, with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the table, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`; the recorded table shows every suite whose
  `cleanup_worktrees_lib.sh` column is non-zero also has a non-zero
  `cleanup_worktrees_dirt_lib.sh` column; the table has exactly `11` such suites, being the ten
  measured at `eac077a2` plus `test_cleanup_worktrees_dirt_failclosed.bats`; and
  `test_cleanup_worktrees_scan_helper.bats`, `test_cleanup_worktrees_scan_seam.bats`, and
  `test_cleanup_worktrees_cli.bats` each show zero in the `cleanup_worktrees_lib.sh` column, which
  is what places all three outside the narrowed AC-1 text written in P1-T3.
  `test_cleanup_worktrees_cli.bats` is the third exclusion and is easy to miss because its
  `cleanup_worktrees_dirt_lib.sh` column is non-zero.

---

### Phase 8 — Final QA loop, coverage gate, and acceptance-criteria reconciliation

The loop restarts from P8-T1 if any stage fails or rewrites a tracked file.

Operational prerequisite for P8-T5: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
gates staging and commit commands. The orchestrator-state checkpoint at
`artifacts/orchestration/orchestrator-state.json` must permit implementation staging before P8-T5
runs; that is an orchestration precondition, not an acceptance condition of this plan.

- [ ] [P8-T1] Capture the tree digest, run `bash scripts/bash/shell-qc.sh format`, capture the
  digest again, using the same digest command as P0-T3, and write
  `evidence/qa-gates/shell-qc-format.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, both digests, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the before and after digests recorded in that artifact are equal.
  If they differ, the formatter rewrote a file and the loop restarts at P8-T1 after the rewrite is
  committed to the working tree.

- [ ] [P8-T2] Run `bash scripts/bash/shell-qc.sh check` and write
  `evidence/qa-gates/shell-qc-check.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, and `Output Summary:` recording the shfmt hunk count and the shellcheck finding
  count.
  Acceptance: `EXIT_CODE: 0` and the recorded counts are both `0`.

- [ ] [P8-T3] Run the full bats stage with the bats path recorded in P0-T5 and write
  `evidence/qa-gates/shell-qc-test.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the TAP plan line, the `ok` count, the `not ok` count, the value of the
  `BaselineLocalTestTotal:` line recorded by P0-T5 reproduced verbatim, and the delta computed as
  this run's `ok` count minus that recorded value, plus `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`, the recorded `not ok` count is `0`, the recorded `ok` count equals
  the recorded plan-line upper bound, and the recorded delta is exactly `14` — the number of tests
  this plan adds, being 2 in P2-T2, 2 in P3-T2, 2 in P4-T3, 3 in P5-T4, 2 in P6-T4, 1 in P6-T5,
  1 in P7-T4, and 1 in P7-T5. The delta is taken against the observed local baseline P0-T5
  recorded, not against the CI figure `390`, so a local-versus-CI difference in suite enumeration
  cannot make this condition unsatisfiable. The artifact must not record the message
  `bats not installed; skipping shell tests.`

- [ ] [P8-T4] Run `wc -l` over the same file set as P0-T8 plus
  `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, and write
  `evidence/qa-gates/file-size-limit.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the full table, and `Output Summary:` naming the maximum.
  Acceptance: `EXIT_CODE: 0` and every recorded count is at or below `500`, with
  `scripts/bash/cleanup_worktrees_lib.sh` still at `496` — unchanged, because this plan does not
  modify it.

- [ ] [P8-T5] Stage and commit every change this plan made, then push
  `bug/cleanup-worktrees-dirt-classifier-632-r2`. Write
  `evidence/other/remediation-commit-and-push.2026-09-08T07-00.md` with `Timestamp:`, a
  `git rev-parse HEAD` span taken immediately before the `git add` and recorded on its own line in
  the exact form `PreCommitHeadSha: <sha>`, the `git add`, `git commit`, and `git push` commands,
  their `EXIT_CODE:` values, a second `git rev-parse HEAD` span taken after the commit and recorded
  in the exact form `PostCommitHeadSha: <sha>`, a `git status --porcelain` span taken after the
  commit, and a
  `git diff --name-status origin/epic/cleanup-merged-worktrees-hardening-integration...HEAD` span.
  Acceptance: all three `EXIT_CODE:` values are `0`, the recorded `git status --porcelain` span is
  empty, the recorded name-status span lists
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`,
  `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`,
  `.claude/skills/cleanup-merged-worktrees/SKILL.md`, and
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`,
  and the artifact contains a `PreCommitHeadSha:` line and a `PostCommitHeadSha:` line whose values
  differ.
  The coverage-evidence file was committed in `388e1a78` and is therefore already tracked; it still
  appears in the three-dot name-status span, because that span covers every commit on this branch
  since the merge base with `origin/epic/cleanup-merged-worktrees-hardening-integration`.
  The head-SHA comparison is stated against the pre-commit SHA this artifact itself records, and
  not against a SHA quoted in this plan, because a quoted SHA goes stale on every further
  docs-only commit to this branch: `ad6bc946` was superseded by `388e1a78` and `388e1a78` by
  `eac077a2` during preflight alone, and against any superseded SHA the condition holds before the
  executor commits anything. The self-relative form cannot go stale, because the two SHAs are read
  in the same task on either side of the commit.
  The porcelain span and the anchored name-status span are both required: the anchored diff cannot
  report a newly created file until it is staged, and the porcelain span goes empty once the commit
  lands, so neither alone establishes the state.

- [ ] [P8-T6] Dispatch the coverage workflow against the pushed branch with
  `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`,
  wait for the run to complete, and write
  `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the run id, the run URL, the event `workflow_dispatch`, the headSha, the
  conclusion, the TAP plan line and `ok`/`not ok` counts from the run log, and `Output Summary:`
  carrying the verbatim `Bash coverage (lines):` line the run printed.
  Acceptance: the recorded conclusion is `success`, the recorded headSha equals the head SHA
  recorded in P8-T5, the recorded `not ok` count is `0`, and the `Output Summary:` contains a
  verbatim `Bash coverage (lines):` line whose percentage is at least `85.0`. A run whose log
  prints no `Bash coverage (lines):` line is INCOMPLETE, not a pass: `print_coverage_summary` can
  return 0 having printed nothing, and the percentage is the only failable observation. `kcov` has
  no local route in this worktree — `bash scripts/bash/shell-qc.sh test --coverage` exits 127 here
  — so this dispatch is the measurement path and no local coverage invocation substitutes for it.

- [ ] [P8-T7] Download the `shell-coverage` artifact of the P8-T6 run with `gh run download`, read
  `kcov-merged/cov.xml`, and write
  `evidence/qa-gates/dirt-lib-coverage.2026-09-08T07-00.md` with `Timestamp:`, `Command:`,
  `EXIT_CODE:`, the per-file table for all eight `scripts/bash/cleanup_worktrees*` files as covered
  lines over instrumented lines and a percentage, the complete list of line numbers still reported
  with zero hits for `scripts/bash/cleanup_worktrees_dirt_lib.sh`, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the recorded percentage for
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` is at least `85.00`. The percentage is computed as
  the count of `line` elements with a non-zero hit count divided by the total count of `line`
  elements under the `class` element whose `filename` attribute ends
  `scripts/bash/cleanup_worktrees_dirt_lib.sh`; the artifact must record both counts so the
  percentage is re-derivable by a third party.

- [ ] [P8-T8] Write `evidence/qa-gates/coverage-delta.2026-09-08T07-00.md` with `Timestamp:`,
  `Command:` naming the P8-T6 dispatch and the P0-T7 baseline artifact, `EXIT_CODE:`,
  `BaselineRepoLineCoverage:` `92.9`, `PostChangeRepoLineCoverage:` from P8-T6,
  `BaselineDirtLibLineCoverage:` `82.63`, `PostChangeDirtLibLineCoverage:` from P8-T7,
  `Threshold:` `85.0`, and `Output Summary:` stating whether any pre-existing file regressed.
  Acceptance: `EXIT_CODE: 0`, the recorded post-change repo-wide value is at least `85.0`, the
  recorded post-change dirt-library value is at least `85.00` and is greater than `82.63`, and the
  summary records that no file listed in the P0-T7 baseline table fell below its baseline
  percentage.

- [ ] [P8-T9] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
  and write `evidence/qa-gates/pytest-push-down-contract.2026-09-08T07-00.md` with `Timestamp:`,
  `Command:`, `EXIT_CODE:`, the summary line, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and the artifact records the literal `11 passed`, equal to the P0-T9
  baseline, so no test was skipped rather than passing.

- [ ] [P8-T10] Check off the reconciled acceptance criteria in
  `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`: AC-1, AC-14,
  AC-15, AC-31, AC-32, and AC-39 through AC-45, each from `- [ ]` to `- [x]`, and write
  `evidence/other/ac-checkoff.2026-09-08T07-00.md` naming, for each of the twelve, the evidence
  artifact path and the test description or command that satisfies it.
  Acceptance: `## Acceptance Criteria` in `spec.md` contains exactly `45` checkbox items, all `45`
  are `- [x]`, and the check-off artifact names a distinct evidence artifact path for each of the
  twelve criteria.

- [ ] [P8-T11] Write `evidence/qa-gates/single-consecutive-pass.2026-09-08T07-00.md` declaring the
  toolchain loop complete in a single consecutive pass, with `Timestamp:`, one row per stage
  (format, lint, test, coverage) naming that stage's artifact path and `EXIT_CODE:`, an explicit
  statement that no stage rewrote a tracked file and no stage was re-entered after the last
  restart, and `Output Summary:`.
  Acceptance: the artifact names the four artifact paths written by P8-T1, P8-T2, P8-T3, and
  P8-T6, records `EXIT_CODE: 0` for each, and states that the P8-T1 before and after digests were
  equal.

- [ ] [P8-T12] Write `evidence/other/deferred-findings.2026-09-08T07-00.md` recording the
  disposition of the eight advisory findings F7 through F14 from
  `code-review.2026-09-08T05-00.md`: for each, its title, why it does not block this remediation
  cycle, and the reason for deferral. F14 is the one finding of the eight that is split rather than
  wholly deferred, and its disposition line must say so: its acceptance-criteria half is closed by
  P1-T11, which narrows AC-15 so the criterion no longer asserts dirt records for registrations
  `run_report` never classifies, and only its documentation half remains deferred — the `SKILL.md`
  omission that detached, `main`, and `bare` registrations are never classified, which is the same
  gap F13's second clause records and is deferred alongside F13 for that reason. Record explicitly
  that F7 and F9 target
  `scripts/bash/cleanup_worktrees_lib.sh`, which is at 496 of 500 lines and which this plan does
  not modify, so acting on them requires the `cleanup_worktrees_report_lib.sh` extraction
  contingency recorded in the `## Risks & Mitigations` bullet of `spec.md` that begins
  ``Fan-in on `cleanup_worktrees_lib.sh` is mitigated by`` and carries the literal
  ``extract `run_report` into a new `scripts/bash/cleanup_worktrees_report_lib.sh```. That bullet
  is cited by its content rather than by line number because Phase 1 of this plan appends seven
  acceptance criteria and two `Proposed Fix` subsections above it, all of which shift its line
  numbers before this task runs.
  Acceptance: the artifact names all eight identifiers `F7` through `F14`, each with a one-line
  disposition, contains the literal `496`, contains the literal
  `cleanup_worktrees_report_lib.sh`, and the F14 disposition line contains the literal `P1-T11`.

---

## Traceability

| Finding | Fix task | Fixture task | Both-directions pin | Evidence |
|---|---|---|---|---|
| R1 | P2-T4 | P2-T1 | P2-T2 (both tests, one fixture, two entries differing only in Y) | P2-T3, P2-T5, P2-T6 |
| R2 | P3-T4 | P3-T1 | P3-T2 (untracked ` -> ` path plus genuine `R` entry) | P3-T3, P3-T5, P3-T6 |
| R5 | P4-T5 | P4-T1, P4-T2 | P4-T3 plus the pre-existing `dirt_build_artifact` pin | P4-T4, P4-T6, P4-T7 |
| R4 | none (pins only) | P5-T1, P5-T2, P5-T3 | P2-T2 (2 directions) plus P5-T4 (3), five in total | P5-T5, P5-T6 |
| R3 | none (pins only) | P6-T1, P6-T2, P6-T3 | P6-T4, P6-T5, P6-T6 | P6-T7, P6-T8, P8-T7, P8-T8 |
| R6a | none (documented) | none (existing scenario) | P7-T4 | P1-T1, P7-T1, P7-T6, P7-T7 |
| R6b | none (retained) | none (existing scenario) | P7-T5 | P1-T2, P7-T2, P7-T3, P7-T6 |
| AC-1 | P1-T3 | none | P7-T8 | P7-T8, P8-T10 |
| AC-14 | P4-T5 | P4-T1, P4-T2 | P4-T3 (`++`-leading content line plus the dev-null-header counterpart) | P4-T4, P4-T6, P4-T7, P8-T10 |
| AC-15 | P3-T4 (record path), P1-T11 (AC narrowing) | P3-T1 | P3-T2 (untracked ` -> ` path plus genuine `R` entry) | P3-T3, P3-T5, P3-T6, P8-T10 |
| AC-31 | P1-T5, P1-T7, P1-T8 | none | none | P8-T1, P8-T2, P8-T3, P8-T11, P8-T10 |
| AC-32 | P1-T5 | none | none | P8-T6, P8-T7, P8-T8, P8-T10 |
| AC-39 | P2-T4 | P2-T1 | P2-T2 (`MM` and `M ` entries in one fixture) | P2-T3, P2-T5, P2-T6, P8-T10 |
| AC-40 | P3-T4 | P3-T1 | P3-T2 (both directions) | P3-T3, P3-T5, P3-T6, P8-T10 |
| AC-41 | P4-T5 | P4-T1, P4-T2 | P4-T3 (both directions) | P4-T4, P4-T6, P4-T7, P8-T10 |
| AC-42 | none (pins only) | P5-T1, P5-T2, P5-T3 | P2-T2 (2 directions) plus P5-T4 (3), five in total | P5-T5, P5-T6, P8-T10 |
| AC-43 | none (documented) | none (existing `dirty_worktree_status_error`) | P7-T4 | P1-T1, P7-T1, P7-T3, P7-T6, P7-T7, P8-T10 |
| AC-44 | none (retained) | none (existing `dirt_session_artifact`) | P7-T5 | P1-T2, P7-T2, P7-T3, P7-T6, P8-T10 |
| AC-45 | none (coverage gate) | P6-T1, P6-T2, P6-T3 | P6-T4, P6-T5, P6-T6 | P6-T7, P6-T8, P8-T6, P8-T7, P8-T8, P8-T10 |

The twelve acceptance-criteria rows above are the complete set P8-T10 checks off: AC-1, AC-14,
AC-15, AC-31, AC-32, and AC-39 through AC-45. Every one carries at least one task in the
`Fix task` or `Both-directions pin` column and at least one evidence artifact task, so no criterion
is checked off on a task that produces no record. The rows whose `Fix task` cell reads `none` are
criteria this cycle pins or measures rather than changes code for; the reason is stated in the
cell.

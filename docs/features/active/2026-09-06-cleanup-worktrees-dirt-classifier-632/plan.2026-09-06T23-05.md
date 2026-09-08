# 2026-09-06-cleanup-worktrees-dirt-classifier (Plan)

- **Issue:** #632
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child C)
- **Owner:** drmoisan
- **Branch:** `bug/cleanup-worktrees-dirt-classifier-632`
- **Work Mode:** `full-bug` (persisted marker `- Work Mode: full-bug` in `issue.md`)
- **Last Updated:** 2026-09-07T00-20
- **Status:** Draft
- **Version:** 1.0

## Plan Preamble

**Sole acceptance-criteria source.** `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
section `## Acceptance Criteria` (lines 616-739), which carries exactly 38 unchecked items. The
raw file carries 41 `- [ ]` matches; the other three are the Blocker / Medium / Low checkboxes in
`## Context` (`spec.md:24`, `:26`, `:27`) and are not acceptance criteria. The plan's AC identifiers
`AC-01` through `AC-38` are assigned in file order over those 38 items.

**Authoritative design source.**
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/research/2026-09-06-dirt-classifier-design-research.md`.
The design is settled and is not re-litigated by this plan. The three accepted decisions are
recorded in `spec.md` under `## Proposed Fix`.

**Language in scope for coverage: bash only.** No `.py` file is created or modified by this work.
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is executed unmodified as a
mirror-parity gate, so no Python coverage baseline, no Python coverage delta, and no Python
formatter/linter/type-check step applies. kcov measures **line coverage only**
(`.claude/rules/shell.md:68-70`); the uniform line threshold of >= 85% applies and **there is no
bash branch-coverage gate**. No task in this plan reads a branch-coverage percentage from the bash
toolchain, because no such number is printed. The Python-oriented `--cov=` /
`--cov-report=term-missing` guidance in `atomic-plan-contract` does not apply to
`scripts/bash/shell-qc.sh`, which accepts no such flags.

**Repository root used in every command.** Windows path
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3944b95a7d58e712`; WSL path
`/mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712`.

**Evidence location invariant.** Every artifact this plan requires resolves under
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/<kind>/`, using the
canonical sub-paths `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`. No
`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/coverage/`, or `artifacts/evidence/` path is used. In artifact filenames,
`<run-timestamp>` denotes the ISO-8601 `yyyy-MM-ddTHH-mm` value observed when the task runs. Every
command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An
artifact whose gate is expected to exit non-zero additionally carries `ExpectedExitCode:` with that
integer.

**Fail-closed evidence rule.** If any required baseline artifact, regression artifact, QA artifact,
or coverage artifact is missing or incomplete, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Assertion-authoring note applied throughout.** Acceptance conditions are expressed as named bats
tests and their exit codes wherever a test can carry the assertion. The record shapes
`DIRTFILE|` and `DIRTSUM|` are documented shapes, not assertable tokens; the tests assert the
concrete lines quoted in the task prose instead. The stub git is stateless — it replays one canned
response per key — so no acceptance condition in this plan requires a first call to fail and a
retry of the same key to succeed. The clear-and-retry sequence is asserted through argv ordering in
the stub argv log, and the post-clear re-verification through argv ordering plus a direct test of
`reverify_delete_eligible` against the existing `unmerged` fixture.

Every ordinal assertion over that argv log names the occurrence it means. `remove_worktree_safe`
issues `git worktree remove` before it reads status
(`scripts/bash/cleanup_worktrees_actions_lib.sh:263`), so the first `worktree remove` in the log
precedes the clearing sequence and only the second one is the retry.

Not every git call the classification ladder issues is observable in that log, and the difference
governs which calls this plan may assert over. `classify_ancestry` redirects both streams of its
`merge-base --is-ancestor` probe (`scripts/bash/cleanup_worktrees_lib.sh:64`) and
`classify_content_neutral` redirects both streams of its `diff --quiet` probe (`:89`), so the stub's
`stub-git:` line for either call is discarded before it reaches the log even though the call is
issued; `verify_consolidation_merged` redirects the same way
(`scripts/bash/cleanup_worktrees_actions_lib.sh:206`). The cherry rung is the first ladder rung
whose call is observable: `classify_cherry_equivalent` captures stdout only
(`scripts/bash/cleanup_worktrees_lib.sh:131`) and leaves stderr attached, so a
`cherry main feature-dirt` line does reach the log. Every ordinal assertion in this plan is
therefore written over `cherry main feature-dirt` or over `worktree remove` and never over
`merge-base --is-ancestor`, and the number of `cherry main feature-dirt` occurrences depends on
whether the test drives `delete_candidate` directly or `run_apply`. A first-match idiom such as the
`grep -n ... | head -n1` at `tests/shell/test_cleanup_worktrees_deletion.bats:47` is correct only
where the plan says the first occurrence is meant.

### Out of scope (no task in this plan may address these)

- Detached-worktree classification and the consolidation-branch ordering hazard — child A, #630.
- Orphan, stale-ref, `CHILD_OF`, and `registration-lost` report records — child B.
- The removal manifest — child D.
- `PRESERVE` consolidation — child F.
- Any change to `remove_worktree_safe`, to the branch classification ladder, or to the apply-mode
  state allowlist.
- Any consumer-repository patch. Delivery is in `drm-copilot` only. `scripts/bash/**` is not in the
  push-down mirror scope (`SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)` at
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20`); only the SKILL.md edit
  is mirrored.

### Fixture scenario set created by this plan

All under `tests/fixtures/cleanup_worktrees/scenarios/`. The dirty worktree path in every new
scenario is `/repo-wt/dirt`, which the stub sanitizer (`tests/fixtures/cleanup_worktrees/stub-bin/git:49-53`)
turns into the status key `status._repo-wt_dirt`. Each scenario carries the seven-file baseline
`worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
`rev-parse.show-toplevel.out`, `merge-base.feature-dirt.rc`, `worktree-remove.rc`,
`status._repo-wt_dirt.out`, plus the verdict-specific responses named in each task.

**Baseline file values, fixed for every new scenario.** These are not defaults the executor may
choose; they are the values that make the clear-and-retry path reachable, and they mirror the
existing `dirty_worktree` fixture and research §11.1.

- `worktree-remove.rc` contains `1`. The clearing hook in `delete_candidate` runs only after
  `remove_worktree_safe` fails, so a `0` here makes the removal succeed and every
  `ACTION|dirt-clear|` assertion in the clearing suite unreachable.
- `merge-base.feature-dirt.rc` contains `0`, so the branch classifies onto the delete-eligible
  allowlist and `reverify_delete_eligible` admits it. `dirt_clear_reverify_order` is the one
  documented exception: P2-T11 sets that file to `1` so the ladder continues past the unobservable
  ancestry rung, and the branch still reaches a delete-eligible verdict at the cherry rung.
- `rev-parse.abbrev-ref-HEAD.out` contains `main`; `rev-parse.show-toplevel.out` contains
  `/repo/main`.
- `for-each-ref.out` carries the two lines `feature-dirt dddd9999` and `main aaaa0000`.
- `worktree-list.out` carries the `--porcelain` registration for `/repo/main` on `refs/heads/main`
  followed by `/repo-wt/dirt` on `refs/heads/feature-dirt`, mirroring
  `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree/worktree-list.out`.

P2-T9 restates the first two values for emphasis on the scenario whose name makes them load-bearing;
that restatement does not imply a different baseline elsewhere. P2-T11 overrides
`merge-base.feature-dirt.rc` to `1` for the single scenario named in that task and states the
derivation there; no other scenario deviates from the values above.

`dirt_build_artifact`, `dirt_build_artifact_mixed`, `dirt_session_artifact`, `dirt_content_on_main`,
`dirt_content_in_history`, `dirt_staged_tree_is_commit`, `dirt_unique`, `dirt_mixed_unique_blocks`,
`dirt_clear_all_disposable`, `dirt_classifier_read_error`, `dirt_clear_reverify_order`,
`dirt_pipe_path`, `dirt_quoted_path`, `dirt_history_depth_fallback`, `dirt_clear_clean_failed`.

### New and edited test suites

- New: `tests/shell/test_cleanup_worktrees_dirt_classify.bats`
- New: `tests/shell/test_cleanup_worktrees_dirt_clear.bats`
- New: `tests/shell/test_cleanup_worktrees_dirt_regression.bats`
- Edited (new tests added): `tests/shell/test_cleanup_worktrees_cli.bats`
- Edited (source chain only): `tests/shell/test_cleanup_worktrees_classification.bats`,
  `tests/shell/test_cleanup_worktrees_consolidation.bats`,
  `tests/shell/test_cleanup_worktrees_deletion.bats`,
  `tests/shell/test_cleanup_worktrees_enumeration.bats`,
  `tests/shell/test_cleanup_worktrees_hard_failures.bats`

---

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read, in this exact order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`, and `.claude/rules/tonality.md`, then write `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/baseline/phase0-instructions-read.md`. **Acceptance:** that file exists and contains a `Timestamp:` field, a `Policy Order:` field naming the seven files in the order above, and one bullet per file recording its line count as read. The task is complete only when all seven files appear.

- [x] [P0-T2] Capture the bash formatter baseline and a tree observation that distinguishes a clean run from a repairing one. Run both commands and record both in `evidence/baseline/shell-qc-format.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh format'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && git status --porcelain -- tools scripts .claude/lib/bash'
```

  **Acceptance:** the artifact records `EXIT_CODE: 0` for the format command **and** records the second command's stdout as empty. `shfmt -w` prints nothing on either a clean or a repairing run (`scripts/bash/shell_qc_lib.sh:204-224` calls `shfmt -w` and returns its exit code with no summary line), so the exit code alone cannot fail; the empty porcelain output is the observation that can. The observation scope is exactly the three formatter discovery roots `tools`, `scripts`, and `.claude/lib/bash` (`scripts/bash/shell_qc_lib.sh:85`); `tests/` is deliberately absent because the formatter never walks it, and a narrower scope such as `scripts/bash` alone would not see a repair under `tools/` or `.claude/lib/bash/`. `git status --porcelain` is used rather than a `git diff` form because it reports untracked files as well as tracked ones. A non-empty second output means the formatter rewrote a shell file and the baseline is not clean.

- [x] [P0-T3] Capture the bash lint/format-diff baseline into `evidence/baseline/shell-qc-check.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh check'
```

  **Acceptance:** the artifact records `EXIT_CODE: 0` and an `Output Summary:` stating that the command emitted no `shfmt` diff hunk and no `shellcheck` finding. `check` runs `shfmt -d` once over the full file list and `shellcheck` once per file, returning the maximum exit code (`scripts/bash/shell_qc_lib.sh:186-201`), so a non-zero exit is a real failure.

- [x] [P0-T4] Capture the bats baseline into `evidence/baseline/shell-qc-test.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test'
```

  **Acceptance:** the artifact records `EXIT_CODE: 0`, the total test count printed by bats, and `Output Summary:` stating that no `not ok` line appeared. If the run reports `bats not installed; skipping shell tests.` the baseline is INCOMPLETE and the phase is blocked, because `run_test` returns 0 on that path (`scripts/bash/shell_qc_lib.sh:239-243`) and a zero exit would otherwise be recorded as a pass.

- [x] [P0-T5] Capture the bash line-coverage baseline into `evidence/baseline/shell-qc-test-coverage.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test --coverage'
```

  **Acceptance:** the artifact records `EXIT_CODE: 0` and, in `Output Summary:`, the numeric value printed on the run's `Bash coverage (lines):` line (`scripts/bash/shell_qc_lib.sh:291`), written as a decimal percentage such as `88.4`. `UNVERIFIED` is not an acceptable value. No branch-coverage number is recorded, because kcov prints none.

- [x] [P0-T6] Capture the push-down mirror contract-test baseline into `evidence/baseline/pytest-push-down-contract.<run-timestamp>.md`.

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

  **Acceptance:** the artifact records `EXIT_CODE: 0` and the passed-test count reported by pytest. This test is the gate that fails when `.claude/skills/cleanup-merged-worktrees/SKILL.md` and its bundle mirror diverge; the baseline must be green before any SKILL.md edit so a later failure is attributable to this change.

- [x] [P0-T7] Re-measure the current line counts of the four production shell files and the stub at execution time rather than assuming the research figures, and record the result in `evidence/other/line-count-remeasure.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && wc -l scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup-worktrees.sh tests/fixtures/cleanup_worktrees/stub-bin/git'
```

  **Acceptance:** the artifact records each measured count, records `HEADROOM_CLEANUP_WORKTREES_LIB:` as `500` minus the measured count of `scripts/bash/cleanup_worktrees_lib.sh`, and records exactly one of the two decision tokens `CONTINGENCY: NOT-REQUIRED` (headroom is 4 or greater) or `CONTINGENCY: REQUIRED` (headroom is 3 or less). The threshold of 4 is the exact line budget this plan spends in that file and the artifact must record that derivation: 2 lines from P5-T2 (the two contract-comment lines) plus 2 lines from P5-T3 (one comment line and one guarded call line). If the executor's implementation of either hunk needs more than its stated line count, the threshold rises by the same amount and the decision is re-taken against the higher figure. Epic sibling child A (#630) also edits `run_report` in that file and may have landed first, so the measured value governs and the research projection of 479 lines is not used as an input.

- [x] [P0-T8] Execute the file-size contingency **only when** `evidence/other/line-count-remeasure.<run-timestamp>.md` recorded `CONTINGENCY: REQUIRED`. When it recorded `CONTINGENCY: NOT-REQUIRED`, this task is explicitly authorized to be skipped and is marked complete by recording that token in `evidence/other/line-count-remeasure.<run-timestamp>.md` under a `ContingencyDecision:` field. When required: extract `run_report` from `scripts/bash/cleanup_worktrees_lib.sh` into a new `scripts/bash/cleanup_worktrees_report_lib.sh` as a behavior-preserving move, add its source block to `scripts/bash/cleanup-worktrees.sh` and to the source chain of the six existing `tests/shell/test_cleanup_worktrees_*.bats` suites, and confirm the move is behavior-preserving. **Acceptance when required:** `bash scripts/bash/shell-qc.sh test` exits 0 with the same total test count as the P0-T4 baseline, and every subsequent task in this plan that names `scripts/bash/cleanup_worktrees_lib.sh` as a `run_report` edit target is redirected to `scripts/bash/cleanup_worktrees_report_lib.sh`.

---

### Phase 1 — Stub Seam Extensions

- [x] [P1-T1] Add one `GIT_INDEX_FILE` environment log line to `tests/fixtures/cleanup_worktrees/stub-bin/git` immediately after the existing `printf 'stub-git: %s\n' "$*" >&2` at `:45`, emitting to stderr when and only when `GIT_INDEX_FILE` is set in the environment. The emitted prefix the executor must write is exactly the token `stub-git-env: ` followed by `GIT_INDEX_FILE=` and the variable's value. This token is the sentinel that makes the report-mode non-mutation assertion in the clearing suite (test 10) falsifiable, so the sentinel itself must be exercised in both states rather than only asserted absent.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && GIT_INDEX_FILE=/tmp/never-created-index bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-parse --show-toplevel 2>&1'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && env -u GIT_INDEX_FILE bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-parse --show-toplevel 2>&1'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_cli.bats'
```

  **Acceptance:** `evidence/qa-gates/stub-env-log.<run-timestamp>.md` records the combined output of both stub invocations verbatim; the first output contains the literal `stub-git-env: GIT_INDEX_FILE=/tmp/never-created-index` and the second contains no occurrence of the literal `stub-git-env`. The two invocations together are what can fail: an unguarded line makes the second output carry the token, and a missing line makes the first output lack it. The `GIT_INDEX_FILE` value names a path that is never created, so no temporary file is produced by this check. The artifact additionally records `EXIT_CODE: 0` for the bats run.

- [x] [P1-T2] Extend the global-option strip loop at `tests/fixtures/cleanup_worktrees/stub-bin/git:77-90` with a case arm that consumes `--no-optional-locks` as a leading global option and advances the index by one. Without this the option is read as the subcommand and every classifier read falls through to the `*) exit 0` default at `:205-207`. **Acceptance:** the file contains a case label naming `--no-optional-locks` inside that loop, and `bats tests/shell/test_cleanup_worktrees_classification.bats` exits 0.

- [x] [P1-T3] Extend the `rev-list` arm at `tests/fixtures/cleanup_worktrees/stub-bin/git:115-123` so a range-free invocation keys on the trailing revision argument rather than producing the empty key `rev-list.`. The classifier calls `rev-list --max-count=201 HEAD`, which carries no `..` range.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && CLEANUP_WT_STUB_SCENARIO=tests/fixtures/cleanup_worktrees/scenarios/unmerged bash tests/fixtures/cleanup_worktrees/stub-bin/git rev-list --no-merges main..feature-unmerged 2>/dev/null'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_classification.bats'
```

  **Acceptance:** the first command's stdout is byte-identical to `tests/fixtures/cleanup_worktrees/scenarios/unmerged/rev-list.feature-unmerged.out`, proving the `main..branch` range form still keys as before; and `bats tests/shell/test_cleanup_worktrees_classification.bats` exits 0. Record both in `evidence/qa-gates/stub-rev-list-key.<run-timestamp>.md`. The range-free `rev-list.HEAD` key is not behaviorally observable at this point because no checked-in scenario carries a `rev-list.HEAD.out` response until P2-T6 creates one; its behavioral gate is classify-suite test 11 in P4-T4, which replays that response and would read nothing if the key were still derived as `rev-list.`.

- [x] [P1-T4] Extend the `diff` arm at `tests/fixtures/cleanup_worktrees/stub-bin/git:124-142` so a non-`--quiet` diff keys separately from the existing `diff-quiet.` keys. The content-confinement check issues `diff --no-color -U0 -- <path>` and `diff --no-color -U0 --cached -- <path>`, whose stdout must be replayable. The full key shapes the executor must write, stated here because the P2-T1 and P2-T2 fixture filenames encode them and a prefix alone would not reproduce those names, are `diff.<sanitized -C path>.<sanitized file path>` for the worktree diff and `diff-cached.<sanitized -C path>.<sanitized file path>` for the `--cached` diff, using the existing `sanitize` helper and the retained `dash_c_path` value. For the worktree path `/repo-wt/dirt` and the file `src/Legacy/Legacy.csproj` this yields exactly `diff._repo-wt_dirt.src_Legacy_Legacy.csproj`, which is the name P2-T1 creates. **Acceptance:** the existing `diff-quiet.` keys are unchanged for `--quiet` invocations, the arm contains a `respond` call naming a key built from both `dash_c_path` and the post-`--` path for the non-`--quiet` case, and `bats tests/shell/test_cleanup_worktrees_classification.bats` and `bats tests/shell/test_cleanup_worktrees_deletion.bats` both exit 0. The behavioral gate for the two new key shapes is classify-suite tests 1 and 3 in P4-T4, which replay the P2-T1 and P2-T2 responses and read nothing if the key shape differs.

- [x] [P1-T5] Add a `hash-object` subcommand arm to `tests/fixtures/cleanup_worktrees/stub-bin/git` keyed as `hash-object.` plus the sanitized path that follows `--`. **Acceptance:** the dispatcher `case "$subcmd" in` block contains a `hash-object)` label, and `bats tests/shell/test_cleanup_worktrees_cli.bats` exits 0.

- [x] [P1-T6] Add a `log` subcommand arm keyed on the value of the `--find-object=` argument, producing the key `log.find-object.` plus the sanitized object id. **Acceptance:** the dispatcher contains a `log)` label that scans the argv for `--find-object=`, and `bats tests/shell/test_cleanup_worktrees_cli.bats` exits 0.

- [x] [P1-T7] Add a `diff-index` subcommand arm keyed as `diff-index.` plus the sanitized commit argument, so a scenario can supply a per-candidate `.rc` file. **Acceptance:** the dispatcher contains a `diff-index)` label, and `bats tests/shell/test_cleanup_worktrees_cli.bats` exits 0.

- [x] [P1-T8] Add a `reset` subcommand arm keyed as `reset-hard`. **Acceptance:** the dispatcher contains a `reset)` label, and `bats tests/shell/test_cleanup_worktrees_cli.bats` exits 0.

- [x] [P1-T9] Add a `clean` subcommand arm keyed as `clean`. **Acceptance:** the dispatcher contains a `clean)` label, and `bats tests/shell/test_cleanup_worktrees_cli.bats` exits 0.

- [x] [P1-T10] Confirm the stub changes are non-regressive against the five suites this phase does not edit. Record the run in `evidence/regression-testing/existing-suites-after-stub-change.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_consolidation.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_hard_failures.bats'
```

  **Acceptance:** the artifact records `EXIT_CODE: 0`, records the total test count, and records that no `not ok` line appeared. `tests/shell/test_cleanup_worktrees_cli.bats` is deliberately excluded here because Phase 3 adds deliberately-failing tests to it.

- [x] [P1-T11] Verify the stub still defines no `write-tree` arm and remains within the 500-line cap. Record the result in `evidence/qa-gates/stub-size-and-write-tree.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && wc -l tests/fixtures/cleanup_worktrees/stub-bin/git && grep -c "write-tree" tests/fixtures/cleanup_worktrees/stub-bin/git'
```

  **Acceptance:** the artifact records a `wc -l` value of 500 or less and a `grep -c` value of `0`. `grep -c` exits 1 when the count is zero, so the artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`. A non-zero count means a `write-tree` arm was added, which would make the report-mode non-mutation assertion in P5-T9 unable to fail.

---

### Phase 2 — Checked-In Scenario Fixtures and Pre-Change Expected Outputs

Every task in this phase creates only checked-in files under `tests/fixtures/cleanup_worktrees/`. No
task creates a temporary file, and no scenario is generated at test time.

- [x] [P2-T1] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact/` with the seven-file baseline, `status._repo-wt_dirt.out` containing the single line ` M src/Legacy/Legacy.csproj`, a `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` whose every `+` and `-` line is an analyzer `HintPath` rewrite, and an empty `diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out`. **Acceptance:** the directory exists and contains exactly those files with those names.

- [x] [P2-T2] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact_mixed/` identical to `dirt_build_artifact` except for three additions: the worktree diff fixture carries one additional changed line that is not a `HintPath` rewrite (a `Compile Include` registration line); a `diff-quiet..src_Legacy_Legacy.csproj.rc` containing `1`; and a `hash-object.src_Legacy_Legacy.csproj.out` containing `7777cccc`, with no `log.find-object.7777cccc.out`. The last two files are load-bearing rather than incidental. The entry is a tracked modification, so a rung-3 miss falls through to rung 4, whose tracked-modified probe is `diff --quiet main -- src/Legacy/Legacy.csproj` (spec `:331`). The stub keys that invocation as `diff-quiet.` plus the sanitized spec plus the sanitized path, and `main` carries no `..` range so the spec stays empty (`tests/fixtures/cleanup_worktrees/stub-bin/git:124-142`); the resulting response filename is the literal double-dot name `diff-quiet..src_Legacy_Legacy.csproj.rc`, which is quoted here because a single-dot spelling would not be read. Without that `.rc` the stub replays its default exit 0, which rung 4 reads as content identical to `main`, and the entry classifies `CONTENT_ON_MAIN` rather than `UNIQUE`, making classify-suite test 3 and AC-14 unsatisfiable. The `hash-object` response with no matching find-object response makes the rung-5 probe miss on a concrete blob rather than on an empty key. **Acceptance:** the directory exists; its `diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` contains at least one `+` line that is not a `HintPath` line; `diff-quiet..src_Legacy_Legacy.csproj.rc` contains `1`; `hash-object.src_Legacy_Legacy.csproj.out` contains `7777cccc`; and no `log.find-object.7777cccc.out` exists in the directory.

- [x] [P2-T3] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_session_artifact/` with the seven-file baseline and `status._repo-wt_dirt.out` containing the single line `?? artifacts/pr_context.summary.txt`, and no other stub response file. **Acceptance:** the directory exists, contains exactly the seven baseline files, and contains no `hash-object.`, `diff.`, `rev-parse.main_`, or `log.` response file, so a git call for that path would produce the stub default rather than a canned answer.

- [x] [P2-T4] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_content_on_main/` with `status._repo-wt_dirt.out` containing `?? docs/copy.md`, `hash-object.docs_copy.md.out` containing `bbbb1111`, and `rev-parse.main_docs_copy.md.out` containing `bbbb1111`. **Acceptance:** the directory exists with those three files and no `log.find-object.bbbb1111.out`.

- [x] [P2-T5] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_content_in_history/` with `status._repo-wt_dirt.out` containing `?? docs/old.md`, `hash-object.docs_old.md.out` containing `cccc2222`, `rev-parse.main_docs_old.md.rc` containing `128`, and `log.find-object.cccc2222.out` containing `ffff8888`. **Acceptance:** the directory exists with those four files.

- [x] [P2-T6] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_is_commit/` with `status._repo-wt_dirt.out` containing the two lines `M  src/a.cs` and `M  src/b.cs`, `rev-list.HEAD.out` containing the three lines `dddd9999`, `eeee7777`, `ffff6666`, `diff-index.eeee7777.rc` containing `0`, and `diff-index.ffff6666.rc` containing `1`. **Acceptance:** the directory exists with those four files, and it contains no `diff-index.dddd9999.rc`, so a probe of the first `rev-list` entry would be observable in the argv log as an unkeyed invocation.

- [x] [P2-T7] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/` with `status._repo-wt_dirt.out` containing `?? notes.md`, `hash-object.notes.md.out` containing `9999aaaa`, `rev-parse.main_notes.md.rc` containing `128`, and no `log.find-object.9999aaaa.out`. **Acceptance:** the directory exists with those three files and no find-object response file.

- [x] [P2-T8] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_mixed_unique_blocks/` with `status._repo-wt_dirt.out` containing the two lines `?? artifacts/pr_context.summary.txt` and `?? notes.md`, plus the `dirt_unique` responses for `notes.md`. **Acceptance:** the directory exists, its status fixture carries exactly two lines in that order, the session-artifact line is first, and `worktree-remove.rc` contains `1` with `merge-base.feature-dirt.rc` containing `0`. Those two values are load-bearing here rather than incidental: clearing-suite tests 4 and 5 assert an `ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE` record, and that record is emitted only on the clearing hook that a failed `remove_worktree_safe` reaches.

- [x] [P2-T9] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_all_disposable/` as a copy of `dirt_build_artifact` with `worktree-remove.rc` containing `1` and `merge-base.feature-dirt.rc` containing `0`. **Acceptance:** the directory exists with the build-artifact responses and those two `.rc` values.

- [x] [P2-T10] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_classifier_read_error/` with `status._repo-wt_dirt.out` containing `?? notes.md` and `hash-object.notes.md.rc` containing `128`. **Acceptance:** the directory exists with those two files and no `hash-object.notes.md.out`, and `worktree-remove.rc` contains `1` with `merge-base.feature-dirt.rc` containing `0`, because clearing-suite test 6 asserts a refused clear and the clearing hook is reached only after a failed `remove_worktree_safe`.

- [x] [P2-T11] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_reverify_order/` as a copy of `dirt_clear_all_disposable` with three additions: `merge-base.feature-dirt.rc` containing `1` (overriding the `0` copied from `dirt_clear_all_disposable`), `diff-quiet.feature-dirt.rc` containing `1`, and `cherry.feature-dirt.out` containing exactly the two lines `- 1111aaaa` and `- 2222bbbb`, each of which is a hyphen, a space, and a concrete object id. These three values are load-bearing rather than incidental and the executor must not substitute others. Derivation: `classify_ancestry` reads exit 1 as `NOT_ANCESTOR` and continues the ladder (`scripts/bash/cleanup_worktrees_lib.sh:64-71`); `classify_content_neutral` reads exit 1 as `NOT_NEUTRAL` and continues (`scripts/bash/cleanup_worktrees_lib.sh:89-97`); `classify_cherry_equivalent` then issues `cherry main feature-dirt`, and a cherry output carrying only hyphen-marker lines adds nothing to the residual array (`scripts/bash/cleanup_worktrees_lib.sh:142-145`), so the function prints `MERGED_EQUIVALENT` (`:160-161`). `MERGED_EQUIVALENT` is on the delete-eligible allowlist of `reverify_delete_eligible` (`scripts/bash/cleanup_worktrees_actions_lib.sh:242`), so both re-verifications still succeed, the branch remains delete-eligible, and the clearing path proceeds exactly as it does under `dirt_clear_all_disposable`. Driving the ladder as far as the cherry rung is what makes each re-verification observable: the ancestry probe's `stub-git:` line is discarded by the redirection at `scripts/bash/cleanup_worktrees_lib.sh:64`, whereas the cherry call at `:131` captures stdout only, so each re-verification emits one `cherry main feature-dirt` line into the stub argv log. The stub keys the three responses as `merge-base.feature-dirt` (`tests/fixtures/cleanup_worktrees/stub-bin/git:111`), `diff-quiet.feature-dirt` (`:141`), and `cherry.feature-dirt` (`:145`); the classifier's own rung-4 probe keys as `diff-quiet.` plus an empty spec plus the sanitized file path and therefore does not collide with `diff-quiet.feature-dirt`. **Acceptance:** the directory exists; `merge-base.feature-dirt.rc` contains `1`; `diff-quiet.feature-dirt.rc` contains `1`; `cherry.feature-dirt.out` contains exactly the two lines `- 1111aaaa` and `- 2222bbbb`; and every other file in the directory is byte-identical to its counterpart in `dirt_clear_all_disposable`.

- [x] [P2-T12] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_pipe_path/` with `status._repo-wt_dirt.out` containing the single line `?? docs/a|b.md`, `hash-object.docs_a_b.md.out` containing `bbbb1111`, and `rev-parse.main_docs_a_b.md.out` containing `bbbb1111`, so the entry classifies `CONTENT_ON_MAIN`. The path is named concretely rather than described, because the two response filenames are the sanitized form of that exact path and a different pipe-bearing path would not match them. **Acceptance:** the directory exists and contains all three of those files with those names and contents.

- [x] [P2-T13] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_quoted_path/` with `status._repo-wt_dirt.out` containing a single entry whose path field begins with a double-quote character, as `git status --porcelain` emits under the default `core.quotePath`. **Acceptance:** the directory exists and the status fixture's path field begins with a double-quote character.

- [x] [P2-T14] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_history_depth_fallback/` as a copy of `dirt_content_in_history` plus a `rev-parse.verify.main_1000.rc` containing `1`, so the bounded range probe fails to resolve and the classifier must fall back to plain `main`. **Acceptance:** the directory exists with that additional `.rc` file, and it carries a `log.find-object.cccc2222.out` containing `ffff8888`.

- [x] [P2-T15] Create `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_clean_failed/` as a copy of `dirt_clear_all_disposable` plus a `clean.rc` containing `1`. **Acceptance:** the directory exists with that additional `.rc` file.

- [x] [P2-T16] Capture the **pre-change** report-mode expected output for the eight regression scenarios into `tests/fixtures/cleanup_worktrees/expected/report.<scenario>.out`, one file per scenario, for `merged_with_worktree`, `merged_no_worktree`, `unmerged`, `content_neutral`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`, and `main_divergence`, by running `run_report` under each scenario against the current, unmodified libraries with stderr discarded. The capture command is stated rather than left to the executor, because these eight files are the reference the whole byte-identity gate compares against and a third party must be able to re-derive them identically.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && mkdir -p tests/fixtures/cleanup_worktrees/expected && for s in merged_with_worktree merged_no_worktree unmerged content_neutral residual_on_main residual_unique_doc current_exclusion main_divergence; do env CLEANUP_WT_GIT_BIN="$PWD/tests/fixtures/cleanup_worktrees/stub-bin/git" CLEANUP_WT_STUB_SCENARIO="$PWD/tests/fixtures/cleanup_worktrees/scenarios/$s" bash -c "source scripts/bash/cleanup_worktrees_enumerate_lib.sh; source scripts/bash/cleanup_worktrees_lib.sh; run_report" >"tests/fixtures/cleanup_worktrees/expected/report.$s.out" 2>/dev/null; done'
```

  **Acceptance:** exactly eight files exist under `tests/fixtures/cleanup_worktrees/expected/` with those names, none is empty, and re-running the identical command produces byte-identical files (verify by capturing `sha256sum tests/fixtures/cleanup_worktrees/expected/report.*.out | sha256sum` immediately after the first run, re-running the identical capture command, capturing the same digest again, and recording both digests in `evidence/other/expected-capture-determinism.<run-timestamp>.md`; the two digests must be identical. Enumerate the eight files with `git status --porcelain -uall -- tests/fixtures/cleanup_worktrees/expected`, which must list exactly eight `??` entries. The `-uall` flag is required: the default form collapses an entirely-untracked directory to one entry and never names the files, and porcelain status reports `??` for an untracked file whatever its content, so it cannot observe a change between the two runs and the digest comparison is what can fail.). These files record behavior before any classifier lands, which is what makes the later byte-identity comparison able to fail.

- [x] [P2-T17] Capture the **pre-change** apply-mode expected output for `dirty_worktree` and `dirty_worktree_status_error` into `tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree.out` and `tests/fixtures/cleanup_worktrees/expected/apply.dirty_worktree_status_error.out`, by running `run_apply` under each scenario against the current, unmodified libraries with stderr discarded.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && for s in dirty_worktree dirty_worktree_status_error; do env CLEANUP_WT_GIT_BIN="$PWD/tests/fixtures/cleanup_worktrees/stub-bin/git" CLEANUP_WT_STUB_SCENARIO="$PWD/tests/fixtures/cleanup_worktrees/scenarios/$s" bash -c "source scripts/bash/cleanup_worktrees_enumerate_lib.sh; source scripts/bash/cleanup_worktrees_lib.sh; source scripts/bash/cleanup_worktrees_actions_lib.sh; run_apply" >"tests/fixtures/cleanup_worktrees/expected/apply.$s.out" 2>/dev/null; done'
```

  **Acceptance:** both files exist, `apply.dirty_worktree.out` contains the exact line `DIRTY|/repo-wt/dirty|?? untracked-artifact.txt` and the exact line `ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY`, and neither file contains the token `DIRTFILE` or the token `DIRTSUM`.

---

### Phase 3 — Regression and Verdict Tests Authored Before Implementation

- [x] [P3-T1] Create `tests/shell/test_cleanup_worktrees_dirt_regression.bats` sourcing only the three existing libraries, with eleven tests: eight named `report mode output for <scenario> is byte-identical to the checked-in expected output` (one per P2-T16 scenario), two named `apply mode without --clear-disposable over dirty_worktree is byte-identical` and `apply mode without --clear-disposable over dirty_worktree_status_error is byte-identical`, and one named `report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM record`. That eleventh test asserts over the live `run_report` stdout for `merged_with_worktree`, not over the checked-in expected file: an assertion over the expected file would be reading bytes P2-T16 captured before the classifier existed and could therefore never fail, whereas the live assertion fails if the implementation emits an aggregate record for a worktree whose status read returned nothing. It also carries the `DIRTSUM|` half of spec `:663`. Every test in this suite captures the driver's stdout with stderr discarded, using the same capture form as the P2-T16 and P2-T17 commands that produced the expected files. Those files are stdout-only captures, whereas the stub writes its `stub-git:` invocation log to stderr and under bats `run` that log merges into the captured output (`tests/fixtures/cleanup_worktrees/stub-bin/git:5-8`), so a comparison that did not discard stderr would compare the expected bytes against stdout plus the log and could never report byte-identity. **Acceptance:** running `bats tests/shell/test_cleanup_worktrees_dirt_regression.bats` exits 0 against the current, unmodified libraries and reports eleven passing tests. Record the run in `evidence/regression-testing/regression-byte-identity-prechange.<run-timestamp>.md`. This suite is a pin, not an expect-fail test: it must pass before and after the implementation.

- [x] [P3-T2] [expect-fail] Create `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, sourcing `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, and the not-yet-existing `scripts/bash/cleanup_worktrees_dirt_lib.sh`, driving `classify_worktree_dirt` directly through the `CLEANUP_WT_GIT_BIN` plus `CLEANUP_WT_STUB_SCENARIO` seam in every test except test 19, which drives `run_report` through the same seam because the record placement it asserts is produced by the report-mode call site rather than by the classifier. The suite carries exactly these nineteen test names:
  1. `dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT`
  2. `dirt_build_artifact: no find-object history walk runs for the classified project file`
  3. `dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE`
  4. `dirt_session_artifact: the session artifact is DISPOSABLE_SESSION_ARTIFACT`
  5. `dirt_session_artifact: no git invocation names the session artifact path`
  6. `dirt_content_on_main: an untracked blob equal to main's blob is CONTENT_ON_MAIN`
  7. `dirt_content_on_main: no find-object history walk runs`
  8. `dirt_content_in_history: the detail field carries the find-object commit sha`
  9. `dirt_staged_tree_is_commit: staged entries carry the matching commit sha`
  10. `dirt_staged_tree_is_commit: the aggregate detail field carries the same commit sha`
  11. `dirt_staged_tree_is_commit: the first rev-list entry is never probed`
  12. `dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths`
  13. `dirt_unique: an unmatched untracked file is UNIQUE and the worktree is HAS_UNIQUE`
  14. `dirt_classifier_read_error: a non-zero classifier read yields UNIQUE and HAS_UNIQUE`
  15. `every verdict emitted across the fifteen dirt scenarios is one of the six defined tokens`
  16. `dirt_mixed_unique_blocks: two entries emit two per-file records in porcelain order then one aggregate`
  17. `dirt_pipe_path: the file path is the last field and the detail field is empty`
  18. `dirt_quoted_path: a C-quoted path is UNIQUE and no unquoting is attempted`
  19. `dirt_mixed_unique_blocks: report mode emits the two per-file records and the aggregate immediately after that worktree's WORKTREE record`

  The exact record lines the tests assert, quoted here so the executor writes them verbatim: `DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj`; `DIRTFILE|/repo-wt/dirt|DISPOSABLE_SESSION_ARTIFACT||??|artifacts/pr_context.summary.txt`; `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|docs/copy.md`; `DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff8888|??|docs/old.md`; `DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/a.cs`; `DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md`; `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|eeee7777`; `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`. Test 15 asserts over the union of the verdict fields produced by all fifteen scenarios, requiring each to be one of `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`, `CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT`, `UNIQUE`. Test 19 drives `run_report` under `CLEANUP_WT_STUB_SCENARIO` pointing at `dirt_mixed_unique_blocks` with stderr discarded, locates the single stdout line beginning with the literal `WORKTREE|/repo-wt/dirt|`, and asserts the three lines that follow it are, in order, `DIRTFILE|/repo-wt/dirt|DISPOSABLE_SESSION_ARTIFACT||??|artifacts/pr_context.summary.txt`, `DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md`, and `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`. The assertion is by position rather than by membership because the placement clause of spec `:659-662` is what it pins, and a membership check passes wherever the records are emitted. The `WORKTREE|` line is matched on its leading literal rather than in full so the assertion does not depend on the record's trailing flags field. **Acceptance:** the file exists and contains nineteen `@test` declarations with those names.

- [ ] [P3-T3] [expect-fail] Run the classifier suite before the library exists and record the failing run.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_dirt_classify.bats'
```

  **Acceptance:** `evidence/regression-testing/fail-before-dirt-classify.<run-timestamp>.md` exists, records `EXIT_CODE: 1`, records `ExpectedExitCode: 1`, records that all nineteen tests reported `not ok`, and records in `Output Summary:` that the cause is the absence of `scripts/bash/cleanup_worktrees_dirt_lib.sh` and the resulting undefined `classify_worktree_dirt`.

- [x] [P3-T4] [expect-fail] Create `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, sourcing the three existing libraries plus the not-yet-existing dirt library, with exactly these eleven test names:
  1. `dirt_clear_all_disposable: the clearing sequence is reset then clean then worktree remove`
  2. `dirt_clear_all_disposable: the clear result record reports OK`
  3. `dirt_clear_all_disposable: no force flag and no ignored-file flag reaches git`
  4. `dirt_mixed_unique_blocks: a UNIQUE verdict refuses the clear`
  5. `dirt_mixed_unique_blocks: a refused clear runs no reset, no clean, and no second worktree remove`
  6. `dirt_classifier_read_error: a fail-closed UNIQUE refuses the clear`
  7. `dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal`
  8. `dirt_clear_reverify_order: the post-clear re-verification cherry probe follows the reset and precedes the removal retry`
  9. `reverify_delete_eligible refuses a non-eligible branch under the unmerged fixture`
  10. `dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index`
  11. `dirt_staged_tree_is_commit: the cached diff-index probe runs and every status read suppresses optional locks`

  The exact record lines the tests assert, quoted here so the executor writes them verbatim: `ACTION|dirt-clear|/repo-wt/dirt|OK`; `ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE`; `ACTION|dirt-clear|/repo-wt/dirt|FAILED`; `ACTION|delete|feature-unmerged|BLOCKED-REVERIFY`. Test 3 asserts the argv log contains none of `--force`, `-x`, `-X`, `-ff`. Test 10 asserts the argv log contains none of `write-tree`, `stub-git-env`, `/index`, `reset`, `clean`, `worktree remove`, `branch -D`, `hash-object -w`. Test 11 asserts the argv log contains `diff-index --cached --quiet` and that every logged `status --porcelain` invocation is preceded on the same line by `--no-optional-locks`. Test 5 asserts the argv log contains no `reset --hard`, no `clean`, and exactly one `worktree remove` invocation, which is the `no second worktree remove` half of spec `:686`.

  **Driver, stated because the ordinal assertions in tests 1, 5 and 8 depend on it.** Tests 1 through 8 invoke `delete_candidate feature-dirt /repo-wt/dirt MERGED_CLEAN` directly under `CLEANUP_WT_CLEAR_DISPOSABLE=1`, in the form used at `tests/shell/test_cleanup_worktrees_deletion.bats:36-43`, not `run_apply`. The third argument is the recorded state, which `reverify_delete_eligible` takes as advisory and never compares against the fresh verdict (`scripts/bash/cleanup_worktrees_actions_lib.sh:227-249`), so passing `MERGED_CLEAN` is correct for `dirt_clear_reverify_order` even though that scenario's fresh verdict is `MERGED_EQUIVALENT`.

  Under that driver the observable invocation counts, stated in terms of the stub argv log rather than of calls issued, are as follows. `merge-base --is-ancestor` is issued by every `reverify_delete_eligible` call but never appears in the log at all, because `classify_ancestry` discards both streams at `scripts/bash/cleanup_worktrees_lib.sh:64`; no test in this suite asserts over it. For `dirt_clear_all_disposable` (tests 1, 2 and 3) the ladder stops at that unobservable ancestry rung, so the log carries zero `cherry main feature-dirt` lines and exactly two `worktree remove` lines. For `dirt_clear_reverify_order` (test 8) the ladder continues to the cherry rung on both re-verifications, so the log carries exactly two `cherry main feature-dirt` lines — one from the pre-removal `reverify_delete_eligible` at `scripts/bash/cleanup_worktrees_actions_lib.sh:309` and one from the post-clear call — and exactly two `worktree remove` lines. A scenario whose clear is refused or fails (`dirt_mixed_unique_blocks`, `dirt_classifier_read_error`, `dirt_clear_clean_failed`, tests 4 through 7) stops at the refusal, so it reaches only the pre-removal re-verification and issues exactly one `worktree remove`; that single removal is what test 5 counts. Driving `run_apply` instead would add a further classification pass from `classify_branch` ahead of all of these, which would make an ordinal assertion written for the direct-driver case read the wrong line. Tests 10 and 11 invoke `run_report` under `CLEANUP_WT_STUB_SCENARIO` pointing at `dirt_staged_tree_is_commit`, not `delete_candidate` and not `run_apply`. The driver is stated because `remove_worktree_safe` issues `cleanup_wt_git -C "$path" status --porcelain` with no `--no-optional-locks` at `scripts/bash/cleanup_worktrees_actions_lib.sh:270`, and that line is textually unchanged by this plan. Under a deletion driver the scenario's `worktree-remove.rc` of `1` always reaches that read, so test 11's assertion would fail for a call site the plan is forbidden to modify. Under `run_report` the only `status --porcelain` invocation is the new library's, which is the scope spec `:709-710` states.

  Test 1 asserts ordering by comparing the argv-log line number of `reset --hard`, then `clean -fd`, then **the second** `worktree remove` occurrence, in that order. The second occurrence is the subject and the first must not be used: `remove_worktree_safe` issues `git worktree remove` before it reads status (`scripts/bash/cleanup_worktrees_actions_lib.sh:263`), so the first occurrence is logged before the clearing sequence begins and a first-match idiom such as the `grep -n ... | head -n1` at `tests/shell/test_cleanup_worktrees_deletion.bats:47` would compare against a line that precedes `reset --hard` and fail regardless of whether the implementation is correct. Test 8 asserts two comparisons over the **second** occurrence of `cherry main feature-dirt` in the argv log: its line number is greater than that of `reset --hard`, and less than that of the second `worktree remove`, which is what the test name's "follows the reset and precedes the removal retry" states. The probe is the cherry call rather than the ancestry call because the ancestry call is not observable: `classify_ancestry` redirects both streams of `merge-base --is-ancestor` at `scripts/bash/cleanup_worktrees_lib.sh:64`, so its `stub-git:` line never reaches the log and a search for it returns nothing whatever the implementation does, whereas `classify_cherry_equivalent` captures stdout only at `:131` and leaves stderr attached. The `dirt_clear_reverify_order` fixture created by P2-T11 is what drives both re-verifications down to that rung. Residual limitation, recorded so a later reader does not weaken the fixture: on the `MERGED_CLEAN` path the post-clear re-verification produces no observable output at all, because `classify_branch` stops at the unobservable ancestry rung and its stdout is consumed by the command substitution at `scripts/bash/cleanup_worktrees_actions_lib.sh:231`. Reverting `dirt_clear_reverify_order` to the plain `dirt_clear_all_disposable` responses therefore makes this test unsatisfiable rather than merely weaker. Test 9 drives `reverify_delete_eligible` directly against the existing `unmerged` fixture, mirroring `tests/shell/test_cleanup_worktrees_deletion.bats:36-43`, because the stateless stub cannot flip a canned response between two calls of the same key. For the same reason the retry's own outcome is not asserted: `worktree-remove.rc` replays `1` on both calls, so the retry reports `BLOCKED-DIRTY` again and the tests' subject is the ordering and the absence of force and ignored-file flags. **Acceptance:** the file exists and contains eleven `@test` declarations with those names.

- [x] [P3-T5] [expect-fail] Run the clearing suite before the library and the call sites exist and record the failing run.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_dirt_clear.bats'
```

  **Acceptance:** `evidence/regression-testing/fail-before-dirt-clear.<run-timestamp>.md` exists, records `EXIT_CODE: 1`, records `ExpectedExitCode: 1`, and records that at least ten of the eleven tests reported `not ok`, naming each.

- [x] [P3-T6] [expect-fail] Add four tests to `tests/shell/test_cleanup_worktrees_cli.bats` without editing any of its five existing tests, named exactly:
  1. `--clear-disposable without a mode argument prints usage to stderr and exits 2`
  2. `report --clear-disposable prints usage to stderr and exits 2`
  3. `--apply --clear-disposable and --clear-disposable --apply both dispatch to apply mode`
  4. `--help output documents the new flag and both new record prefixes`

  Test 4 asserts the `--help` stdout contains the three literals `--clear-disposable`, `DIRTFILE|`, and `DIRTSUM|`, none of which is present in the tracked tree yet and each of which is quoted here so the executor writes it verbatim into `scripts/bash/cleanup-worktrees.sh` in P5-T7. The four new tests are appended after the existing final test, whose body ends at `tests/shell/test_cleanup_worktrees_cli.bats:63`; no line is inserted above it. The insertion point is stated because the acceptance below cites the pre-existing declarations by line number and any insertion above them would shift those lines and make the citation unreadable. **Acceptance:** the file contains nine `@test` declarations in total, the five pre-existing test names remain at `tests/shell/test_cleanup_worktrees_cli.bats:16`, `:22`, `:28`, `:41`, and `:53` and are textually unchanged, and `git diff HEAD -- tests/shell/test_cleanup_worktrees_cli.bats` shows added lines only, with no deleted line.

- [x] [P3-T7] [expect-fail] Run the CLI suite before the flag exists and record the failing run.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_cli.bats'
```

  **Acceptance:** `evidence/regression-testing/fail-before-cli-flag.<run-timestamp>.md` exists, records `EXIT_CODE: 1`, records `ExpectedExitCode: 1`, records that exactly the four new tests reported `not ok`, and records that the five pre-existing tests still reported `ok`. A run in which a pre-existing test also fails means P3-T6 edited more than it was permitted to and the task is not complete.

---

### Phase 4 — New Classifier Library

- [ ] [P4-T1] Create `scripts/bash/cleanup_worktrees_dirt_lib.sh` with a family-style header comment and the constants block only: `CLEANUP_WT_CLEAR_DISPOSABLE` defaulting to `0` via parameter expansion so bats can drive the functions without the wrapper, `CLEANUP_WT_STAGED_TREE_DEPTH` set to `200`, `CLEANUP_WT_HISTORY_SCAN_DEPTH` set to `1000`, and `CLEANUP_WT_SESSION_ARTIFACT_PATHS` as a hard-coded array of exactly the three paths `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `artifacts/orchestration/orchestrator-state.json`. The header states the one-sided bound asymmetry (a missed match degrades to `UNIQUE`, which blocks clearing) and the prohibition on adding `--ignored` to the status read, so a later reader does not remove either. The header must not contain the literal `write-tree` or the literal `GIT_INDEX_FILE` in any form, including a prose statement that the library avoids them: P4-T2 asserts those two literals are absent from the whole file, so a documentary mention would fail that gate for a reason unrelated to behavior. Express the same point as "this library performs no index or object-database write". **Acceptance:** the file exists, begins with `set -euo pipefail` omitted (it is a sourced library, matching `scripts/bash/cleanup_worktrees_lib.sh`), defines no executable statement outside a function other than the constant assignments, and `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh` exits 0.

- [ ] [P4-T2] Add the bounded staged-tree probe to `scripts/bash/cleanup_worktrees_dirt_lib.sh`. It captures `rev-list --max-count` over `HEAD` with the bound set to `CLEANUP_WT_STAGED_TREE_DEPTH` plus one, drops the first returned line, and for each remaining sha issues a guarded `--no-optional-locks -C <worktree> diff-index --cached --quiet <sha> --`, returning the matching sha on exit 0, continuing on exit 1, and returning a distinct hard-failure code on any other exit. It never invokes `git write-tree` and never sets `GIT_INDEX_FILE`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh && grep -c "write-tree\|GIT_INDEX_FILE" scripts/bash/cleanup_worktrees_dirt_lib.sh'
```

  **Acceptance:** `evidence/qa-gates/no-write-tree-in-library.<run-timestamp>.md` records that command verbatim, records the `grep -c` value as `0`, and records `EXIT_CODE: 1` with `ExpectedExitCode: 1`, because `grep -c` exits 1 on a zero count and `bash -n` exiting 0 is what allows the chained grep to run at all. A count above zero, or an exit code other than 1, fails the task.

- [ ] [P4-T3] Add `classify_dirt_entry` to `scripts/bash/cleanup_worktrees_dirt_lib.sh` implementing the six-rung, first-match-wins precedence ladder in the order staged-tree, session artifact, build artifact, content-on-main, content-in-history, unique, with every git read guarded, and with a two-way classification of non-zero exits. A probe whose non-zero exit is its defined negative answer advances the ladder to the next rung: `rev-parse main:<path>` exiting non-zero means the path is absent from `main`, and `diff --quiet main -- <path>` exiting 1 means the contents differ. Both are rung-4 misses and fall through to rung 5. A probe whose non-zero exit carries no verdict is a hard read failure and maps the entry to `UNIQUE` (fail closed): `status --porcelain`, `hash-object`, `log --find-object`, and `diff-index --cached --quiet` exiting above 1. The fixtures encode exactly this split and it is what makes them separable: P2-T5 and P2-T7 both set `rev-parse.main_<path>.rc` to `128` and require the ladder to continue, while P2-T10 sets `hash-object.notes.md.rc` to `128` and requires the fail-closed `UNIQUE`. A single blanket rule collapses the two and makes classify test 8 unsatisfiable. A path field beginning with a double quote returns `UNIQUE` immediately with no unquoting attempt. A rename or copy entry classifies the text after the ` -> ` separator.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh && for t in DISPOSABLE_BUILD_ARTIFACT DISPOSABLE_SESSION_ARTIFACT CONTENT_ON_MAIN CONTENT_IN_HISTORY STAGED_TREE_IS_COMMIT UNIQUE; do printf "%s=%s\n" "$t" "$(grep -vE "^[[:space:]]*#" scripts/bash/cleanup_worktrees_dirt_lib.sh | grep -c "$t")"; done'
```

  **Acceptance:** `bash -n` exits 0 and each of the six printed `<token>=<count>` pairs carries a count of at least 1, recorded verbatim in `evidence/qa-gates/verdict-tokens-in-ladder.<run-timestamp>.md`. The comment lines are filtered out before counting and each token is counted separately, because a single aggregated line count over the whole file is satisfied by a header comment that merely lists the six verdicts and would therefore pass with no ladder present. The behavioral gate for the ladder is P4-T4, because `classify_dirt_entry` is not reachable from the bats suites until `classify_worktree_dirt` drives it; asserting a bats test here would run before the function that calls it exists.

- [ ] [P4-T4] Add `classify_worktree_dirt` to `scripts/bash/cleanup_worktrees_dirt_lib.sh`. It performs one guarded `--no-optional-locks -C <worktree> status --porcelain` read, emits one per-file record per status entry in porcelain order followed by exactly one aggregate record, emits neither record when the status output is empty, and returns non-zero with no record emitted when the status read hard-fails. The aggregate is `ALL_DISPOSABLE` if and only if the entry count is at least one and the `UNIQUE` count is zero, and `HAS_UNIQUE` otherwise. **Acceptance:** `bats tests/shell/test_cleanup_worktrees_dirt_classify.bats` reports tests 1 through 18 as `ok` and exactly one `not ok` line, naming test 19, so the run records `EXIT_CODE: 1` with `ExpectedExitCode: 1`. Record the run in `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md`. Test 19 is excluded from this gate on ordering grounds and not on merit: it drives `run_report`, whose guarded `classify_worktree_dirt` call site does not exist until P5-T3, so a demand that all nineteen pass here would be unsatisfiable at this point in the plan while the eighteen-pass demand can fail. The full-pass gate, with all nineteen tests passing and `EXIT_CODE: 0`, is P5-T3.

- [ ] [P4-T5] Add `clear_disposable_dirt` to `scripts/bash/cleanup_worktrees_dirt_lib.sh` implementing the sequence classify, require the aggregate to be exactly `ALL_DISPOSABLE`, `reset --hard`, `clean -fd`, then emit the clear result record. `git worktree remove` is never invoked from this function.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && grep -nE "^[[:space:]]*cleanup_wt_git" scripts/bash/cleanup_worktrees_dirt_lib.sh'
```

  **Acceptance:** among the listed statement lines, exactly one carries `clean` in the subcommand position and exactly one carries `reset` in that position; the `clean` line's flag list is exactly `-fd` and carries none of `-x`, `-X`, `-ff`, `-fdx`; the `reset` line's flag list is exactly `--hard`. The subcommand position is the first token after `cleanup_wt_git` once any leading global options are skipped, that is any `--no-optional-locks` token and any `-C` option together with its path operand. The count is read at that token position and is not a substring search over the matched lines: the wrapper name `cleanup_wt_git` itself contains the letters `clean`, so a substring count would match every listed line and would report the total number of wrapper statements whatever the executor wrote. Record the full grep output verbatim in `evidence/qa-gates/clean-flags.<run-timestamp>.md`. The grep pattern is anchored to a statement line beginning with the `cleanup_wt_git` wrapper rather than searching for the bare text `clean `, because the library's mandatory header comment describes the clearing behavior in prose and a prose match would make an "exactly one" count fail for a documentation reason. The behavioral gate for this function is P5-T9.

- [ ] [P4-T6] Verify `scripts/bash/cleanup_worktrees_dirt_lib.sh` runs nothing at source time. No temporary file is created by this check.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash -c "source scripts/bash/cleanup_worktrees_dirt_lib.sh; echo SOURCE_GUARD_OK"'
```

  **Acceptance:** the combined stdout and stderr of that command is exactly the single line `SOURCE_GUARD_OK`. Any additional line means the library executed a statement at source time, which the family convention prohibits. Record the result in `evidence/qa-gates/dirt-lib-source-guard.<run-timestamp>.md`.

- [ ] [P4-T7] Verify the new library is within the 500-line cap.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh'
```

  **Acceptance:** the reported count is 500 or less, recorded in `evidence/qa-gates/dirt-lib-size.<run-timestamp>.md`.

---

### Phase 5 — Call-Site Wiring

- [ ] [P5-T1] Add `scripts/bash/cleanup_worktrees_dirt_lib.sh` to the `source` chain of all nine suites: the six existing `tests/shell/test_cleanup_worktrees_*.bats` files and the three new suites, by defining a `DLIB` variable in each `setup` and adding it to each driver helper's source list. No assertion in any suite is edited. This task precedes every call-site edit in this phase: once `run_report` calls `classify_worktree_dirt`, a suite that has not sourced the new library would invoke an undefined function, so wiring the chain first is what keeps the later gates meaningful. **Acceptance:** `grep -c "cleanup_worktrees_dirt_lib.sh" tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_consolidation.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats` reports a non-zero count for every one of the nine files, and `bats tests/shell/test_cleanup_worktrees_dirt_regression.bats` still exits 0 with eleven passing tests.

- [ ] [P5-T2] Add exactly two lines to the report-line contract comment block in `scripts/bash/cleanup_worktrees_lib.sh`, immediately after the `DIRTY|` contract line at `:45`, documenting the two new record prefixes. The three literals the executor must write across those two lines are `DIRTFILE|`, `DIRTSUM|`, and `--clear-disposable`; spec `:736` requires this comment block to document all three, and the flag literal is carried on the `DIRTSUM|` line as the apply-mode gate annotation so the hunk stays at exactly two lines and the P0-T7 line budget is unchanged. **Acceptance:** the comment block contains one line whose text includes `DIRTFILE|`, one line whose text includes `DIRTSUM|`, at least one of those two lines includes `--clear-disposable`, the block grew by exactly two lines, and no existing contract line in the block is altered.

- [ ] [P5-T3] Add a guarded `classify_worktree_dirt` call plus one explanatory comment line inside the `run_report` worktree loop at `scripts/bash/cleanup_worktrees_lib.sh:465-469`, immediately after the `WORKTREE|` emission, invoked only for a non-main, non-bare registration. If P0-T8 executed the extraction contingency, this edit targets `scripts/bash/cleanup_worktrees_report_lib.sh` instead. **Acceptance:** `bats tests/shell/test_cleanup_worktrees_dirt_regression.bats` exits 0 with all eleven tests still passing, which proves the eight report scenarios and the two apply scenarios are byte-identical after the call site was added; and `bats tests/shell/test_cleanup_worktrees_dirt_classify.bats` exits 0 with all nineteen tests passing, recorded in `evidence/regression-testing/pass-after-dirt-classify-full.<run-timestamp>.md`. That second run is this task's gate for classify test 19, whose report-mode adjacency assertion is the only test in the suite that observes this call site and which therefore reported `not ok` at P4-T4.

- [ ] [P5-T4] Add header-comment lines to `scripts/bash/cleanup_worktrees_actions_lib.sh` noting that `delete_candidate` carries an opt-in clearing hook and that `remove_worktree_safe` is unmodified by it. **Acceptance:** the header comment block contains a line naming `clear_disposable_dirt`, and `git diff HEAD -- scripts/bash/cleanup_worktrees_actions_lib.sh` shows hunks confined to the header comment block above the first function definition, with no line added or removed inside the body of `remove_worktree_safe`. The function's pre-edit range `:252-279` is recorded as a locator only; this task's own header insertion shifts it, so the assertion is over the diff rather than over that range.

- [ ] [P5-T5] Replace lines `:310-312` of `scripts/bash/cleanup_worktrees_actions_lib.sh` inside `delete_candidate` with the guarded clear-and-retry block: on a failed `remove_worktree_safe`, return 1 unless `CLEANUP_WT_CLEAR_DISPOSABLE` is 1; then `clear_disposable_dirt` on the worktree path, then `reverify_delete_eligible` with the branch name and recorded state, then `remove_worktree_safe` again. Each step returns 1 on failure. No new `git worktree remove` call site is introduced.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_deletion.bats && grep -n "cleanup_wt_git worktree remove" scripts/bash/cleanup_worktrees_actions_lib.sh'
```

  **Acceptance:** the bats run exits 0 with no assertion edited, and the grep reports exactly two lines.

- [ ] [P5-T6] Append a fourth source block to `scripts/bash/cleanup-worktrees.sh` after the actions-lib block at `:22-24`, sourcing `scripts/bash/cleanup_worktrees_dirt_lib.sh` with the same `shellcheck source=` and `shellcheck disable=SC1091` directive pair the three existing blocks use. **Acceptance:** the file contains four `source "$SCRIPT_DIR/` statements, the fourth names `cleanup_worktrees_dirt_lib.sh`, and `bash scripts/bash/cleanup-worktrees.sh --help` exits 0.

- [ ] [P5-T7] Add the new flag entry to the `usage` here-doc in `scripts/bash/cleanup-worktrees.sh` and add the two new record lines to its report-line block at `:42-45`. The three literals the `--help` output must contain, quoted here so the executor writes them verbatim, are `--clear-disposable`, `DIRTFILE|`, and `DIRTSUM|`. The flag entry states that it is apply-mode-only, opt-in, and destructive, that it refuses any worktree carrying a `UNIQUE` verdict, and that supplying it without apply mode is a usage error exiting 2. **Acceptance:** `bats tests/shell/test_cleanup_worktrees_cli.bats` reports the test named `--help output documents the new flag and both new record prefixes` as passing.

- [ ] [P5-T8] Insert the flag pre-pass into `main` in `scripts/bash/cleanup-worktrees.sh` immediately before `local command=${1:-}` at `:65`, stripping `--clear-disposable` from the argument list, setting `CLEANUP_WT_CLEAR_DISPOSABLE`, and returning 2 after printing usage to stderr when the flag is present and the remaining first argument is neither the apply flag nor the apply word. Every existing `case` arm at `:66-81` stays textually unchanged. **Acceptance:** `bats tests/shell/test_cleanup_worktrees_cli.bats` reports the tests named `--clear-disposable without a mode argument prints usage to stderr and exits 2`, `report --clear-disposable prints usage to stderr and exits 2`, and `--apply --clear-disposable and --clear-disposable --apply both dispatch to apply mode` as passing.

- [ ] [P5-T9] Run the clearing and non-mutation suite and record the pass-after evidence.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_dirt_clear.bats'
```

  **Acceptance:** `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` records `EXIT_CODE: 0` and eleven passing tests, naming each. This is the gate that pins the never-force invariant, the `-x`/`-X`/`-ff` prohibition, the refusal on any `UNIQUE` verdict, the post-clear re-verification ordering, and the report-mode non-mutation property.

- [ ] [P5-T10] Run the byte-identity regression suite after the call sites are wired and record the post-change evidence.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_dirt_regression.bats'
```

  **Acceptance:** `evidence/regression-testing/regression-byte-identity-postchange.<run-timestamp>.md` records `EXIT_CODE: 0` and eleven passing tests, and its `Output Summary:` states that the same eleven tests passed in the pre-change run recorded by P3-T1.

- [ ] [P5-T11] Run the CLI suite after the flag is wired and record the pass-after evidence.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_cli.bats'
```

  **Acceptance:** `evidence/regression-testing/pass-after-cli-flag.<run-timestamp>.md` records `EXIT_CODE: 0` and nine passing tests, naming the five pre-existing and the four new tests.

- [ ] [P5-T12] Confirm the two suites the acceptance criteria name as unmodified apart from the source chain still pass.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_hard_failures.bats'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && git diff HEAD -- tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_hard_failures.bats'
```

  **Acceptance:** `evidence/regression-testing/deletion-hard-failures-unmodified.<run-timestamp>.md` records `EXIT_CODE: 0` for the bats command, and records that every hunk in the anchored diff touches only a `setup` variable definition or a driver-helper `source` list. A hunk touching any `@test` body or any assertion means the constraint is violated and the task is not complete.

- [ ] [P5-T13] Verify the removal call-site invariant across the production tree and record it in `evidence/qa-gates/worktree-remove-call-sites.<run-timestamp>.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && grep -rn "cleanup_wt_git worktree remove" scripts/bash/'
```

  **Acceptance:** the artifact records exactly two matching lines, both in `scripts/bash/cleanup_worktrees_actions_lib.sh` (the consolidation abort cleanup and the single call inside `remove_worktree_safe`), and records that neither matched line contains the token `--force`. A third match means the clear-and-retry path introduced a new removal call site rather than routing through `remove_worktree_safe`.

---

### Phase 6 — SKILL.md Reconciliation and Bundle Mirror

- [ ] [P6-T1] Edit the **Report Line Contract** section of `.claude/skills/cleanup-merged-worktrees/SKILL.md` (`:57-71`): amend the existing `DIRTY|` bullet at `:69-70` to state that the record is apply-mode only and its three-field shape is unchanged by the dirt classifier, and insert two new bullets after it documenting the two new record prefixes with their full field lists, the six permitted verdict tokens, the detail-field rule, the file-path-last rule, and the fail-closed `UNIQUE` mapping. **Acceptance:** the section contains a bullet whose text includes `DIRTFILE|`, a bullet whose text includes `DIRTSUM|`, and a `DIRTY|` bullet whose text includes the phrase `apply mode only`; the five other bullets in the section are textually unchanged. The phrase `apply mode only` must be written on one unwrapped line, because P6-T7 counts it with a line-oriented `grep -cF` and a phrase split across two lines returns a count of zero even though the text is present.

- [ ] [P6-T2] Replace the second bullet of **Prohibited Shortcuts** in `.claude/skills/cleanup-merged-worktrees/SKILL.md` (`:236-237`) with the expanded text stating that the new flag is not an exception to the never-force-remove rule and is not force-removal, because it clears the working tree first and then retries the same unforced removal, that it runs only when every per-file verdict for that worktree is non-`UNIQUE`, only in apply mode, only when explicitly requested, and only after a fresh in-process re-verification, and that a single `UNIQUE` verdict — including the fail-closed one assigned when a classification read errors — refuses the clear for the whole worktree. **Acceptance:** the bullet retains its opening sentence `Never pass a force flag to` and additionally contains the literal `--clear-disposable`.

- [ ] [P6-T3] Append a new bullet to **Prohibited Shortcuts** in `.claude/skills/cleanup-merged-worktrees/SKILL.md` prohibiting any widening of the disposable-dirt definition, naming the fixed in-script session-artifact array with no configuration override, the build-artifact rule's requirement of both the path pattern and the analyzer-`HintPath` content confinement, and the fact that ignored files are never cleared because they are never classified. **Acceptance:** the section contains seven bullets (six pre-existing plus the new one) and the new bullet contains the literal `HintPath`.

- [ ] [P6-T4] Edit the **Dirty Worktree Triage Procedure** in `.claude/skills/cleanup-merged-worktrees/SKILL.md`: extend the Trigger paragraph (`:131-137`) with a closing sentence stating that report mode now precedes the procedure with per-file verdicts and a per-worktree aggregate and that steps 1-9 apply to worktrees carrying at least one `UNIQUE` verdict; add a scoping sentence to step 6 (`:184-188`) stating that the classifier labels that class disposable only when the changed lines are confined to analyzer `HintPath` rewrites and that a project file whose diff touches anything else is reported `UNIQUE`; and amend step 9 (`:204-219`) so it distinguishes the automated clearing of classified-disposable dirt from the never-automated editorial discard of `UNIQUE` content, preserving the existing statements that the classification ladder and apply-mode allowlist are never changed. **Acceptance:** the Trigger paragraph contains the literal `DIRTSUM|`, step 6 contains the literal `HintPath`, and step 9 contains the literal `--clear-disposable` while still containing the pre-existing sentence that begins `This is never automated:` textually unchanged. The `never automated` phrase is asserted as a retention rather than as an addition because step 9 already carries it at `.claude/skills/cleanup-merged-worktrees/SKILL.md:214`; asserting its presence as though it were new would pass whether or not the executor edited step 9 at all, whereas the `--clear-disposable` literal is absent from the file today and the retention check fails if the amendment deletes the existing sentence.

- [ ] [P6-T5] Copy `.claude/skills/cleanup-merged-worktrees/SKILL.md` byte-for-byte over `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`. The two files are byte-identical before this change, so the mirror is a whole-file copy rather than a re-application of the four edits.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && cmp .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md'
```

  **Acceptance:** `cmp` exits 0 and prints nothing, recorded in `evidence/qa-gates/skill-mirror-parity.<run-timestamp>.md`.

- [ ] [P6-T6] Run the push-down mirror contract test after the SKILL.md edits.

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

  **Acceptance:** `evidence/qa-gates/pytest-push-down-contract.<run-timestamp>.md` records `EXIT_CODE: 0` and a passed-test count equal to the count recorded in the P0-T6 baseline artifact. A lower count means a test was skipped rather than passing.

- [ ] [P6-T7] Record the documentation-literal evidence for the SKILL.md and contract-comment criteria.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && for t in "DIRTFILE|" "DIRTSUM|" "--clear-disposable" "HintPath" "apply mode only" "This is never automated:"; do printf "%s=%s\n" "$t" "$(grep -cF -- "$t" .claude/skills/cleanup-merged-worktrees/SKILL.md)"; done'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && for t in "DIRTFILE|" "DIRTSUM|" "--clear-disposable"; do printf "%s=%s\n" "$t" "$(grep -cF -- "$t" scripts/bash/cleanup_worktrees_lib.sh)"; done'
```

  **Acceptance:** `evidence/qa-gates/doc-literals.<run-timestamp>.md` records both command outputs verbatim, every one of the nine printed `<token>=<count>` pairs carries a count of at least 1, and `EXIT_CODE: 0`. `grep -cF -- ` is used so the leading dashes of `--clear-disposable` are read as pattern text rather than as options. Each token is counted separately because a single combined pattern is satisfied by any one of them. The multi-word tokens `apply mode only` and `This is never automated:` are asserted only because each occupies a single line: the second already does at `.claude/skills/cleanup-merged-worktrees/SKILL.md:214` and P6-T4 requires it unchanged, and P6-T1 must write the first on one unwrapped line so this count can be read.

---

### Phase 7 — Final QC Loop

Run the four bash toolchain steps in the stated order. If any step fails or rewrites a file, restart
from P7-T1 and record a fresh artifact set; the phase completes only on one consecutive clean pass.

- [ ] [P7-T1] Run the bash formatter and record a before-and-after tree observation, because `shfmt -w` prints nothing and exits 0 on both a clean and a repairing run, so its exit code cannot distinguish the two.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh format'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum'
```

  **Acceptance:** `evidence/qa-gates/shell-qc-format.<run-timestamp>.md` records `EXIT_CODE: 0` for the format command and records both content digests verbatim, and the two digests are identical. A content digest is used rather than a `git diff` form because `git diff` in any of its modes reports tracked paths only, and the file most likely to be reformatted by this work — the newly created, still-untracked `scripts/bash/cleanup_worktrees_dirt_lib.sh` — is invisible to it, so a before-and-after diff comparison would be identical whether or not the formatter rewrote that file. The digest scope is the three formatter discovery roots `tools`, `scripts`, and `.claude/lib/bash` (`scripts/bash/shell_qc_lib.sh:85`), with `tools` guarded because it does not currently exist in this checkout and `discover_shell_scripts` silently skips a missing root; `tests/` is excluded because the formatter never walks it. A difference between the two digests means the formatter rewrote a file and the loop restarts from this task.

- [ ] [P7-T2] Run the bash lint and format-diff stage.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh check'
```

  **Acceptance:** `evidence/qa-gates/shell-qc-check.<run-timestamp>.md` records `EXIT_CODE: 0` and an `Output Summary:` stating that the command emitted no `shfmt` diff hunk and no `shellcheck` finding for any file, including the new `scripts/bash/cleanup_worktrees_dirt_lib.sh`.

- [ ] [P7-T3] Run the full bats suite. This is the first task in the plan that runs the whole suite after the deliberately-failing tests of Phase 3 were made to pass; every one of those tests is green by the end of Phase 5, so the gate is satisfiable here and was not earlier.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test'
```

  **Acceptance:** `evidence/qa-gates/shell-qc-test.<run-timestamp>.md` records `EXIT_CODE: 0`, records the total test count, records that no `not ok` line appeared, and records that the total exceeds the P0-T4 baseline count by at least 45 (19 classifier tests, 11 clearing tests, 11 regression tests, 4 CLI tests). A run reporting `bats not installed` is INCOMPLETE, not a pass.

- [ ] [P7-T4] Run the bash coverage stage.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && bash scripts/bash/shell-qc.sh test --coverage'
```

  **Acceptance:** `evidence/qa-gates/shell-qc-test-coverage.<run-timestamp>.md` records `EXIT_CODE: 0` and, in `Output Summary:`, the numeric value printed on the run's `Bash coverage (lines):` line, written as a decimal percentage such as `88.4`. `UNVERIFIED` and any other placeholder are not acceptable values, and a run that exits 0 while printing no `Bash coverage (lines):` line at all is INCOMPLETE rather than a pass: `print_coverage_summary` (`scripts/bash/shell_qc_lib.sh:277-292`) returns 0 and prints nothing when `cov.xml` is missing or unparseable, so the exit code alone does not establish that a percentage was produced. No branch-coverage value is recorded or asserted, because kcov prints none and no bash branch-coverage gate exists.

- [ ] [P7-T5] Compare coverage and record the delta in `evidence/qa-gates/coverage-delta.<run-timestamp>.md`. **Acceptance:** the artifact records three fields: `BaselineLineCoverage:` copied from the P0-T5 baseline artifact, `PostChangeLineCoverage:` copied from the P7-T4 artifact, and `Threshold: 85.0`. The post-change value must be at least `85.0`. The artifact additionally records, from the merged kcov Cobertura report at `artifacts/pester/kcov/cov.xml` (the default `SHELL_QC_KCOV_OUT_DIR` location per `.claude/rules/shell.md:62-64`), the per-file line-coverage figure for `scripts/bash/cleanup_worktrees_dirt_lib.sh`, and states whether the `CONTENT_IN_HISTORY` depth-fallback path and the C-quoted-path branch are covered; an uncovered line in either is a finding requiring a new scenario entry, not a waiver. That `cov.xml` is a read-only tool output consumed by this task, not an evidence artifact: every artifact this task writes resolves under `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/`.

- [ ] [P7-T6] Re-run the push-down mirror contract test as the final-QC gate for the `.claude/**` edits.

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
```

  **Acceptance:** `evidence/qa-gates/pytest-push-down-contract-final.<run-timestamp>.md` records `EXIT_CODE: 0` and the same passed-test count as the P0-T6 baseline.

- [ ] [P7-T7] Verify the 500-line cap over every shell file this work created or changed, measured at execution time rather than taken from the research projection.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh tests/fixtures/cleanup_worktrees/stub-bin/git tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_consolidation.bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_hard_failures.bats'
```

  **Acceptance:** `evidence/qa-gates/file-size-limit.<run-timestamp>.md` records every reported count and every count is 500 or less. If P0-T8 executed the extraction contingency, `scripts/bash/cleanup_worktrees_report_lib.sh` is added to the measured list.

- [ ] [P7-T8] Declare the single consecutive clean pass. **Acceptance:** `evidence/qa-gates/single-consecutive-pass.<run-timestamp>.md` names the four artifact files produced by P7-T1 through P7-T4 in one uninterrupted sequence, records that each carries `EXIT_CODE: 0`, and records that P7-T1's two content digests were identical in that same sequence. If any of P7-T1 through P7-T4 failed or rewrote a file, this task is not complete until the loop has been restarted from P7-T1 and a fresh artifact set produced.

---

### Phase 8 — Acceptance-Criteria Check-Off

- [ ] [P8-T1] Following `.claude/skills/acceptance-criteria-tracking/SKILL.md`, mark each of the 38 items in the `## Acceptance Criteria` section of `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md` as checked, and record in `evidence/other/ac-checkoff.<run-timestamp>.md` one row per criterion giving its `AC-NN` identifier, the plan task that satisfied it, and the evidence artifact path or bats test name that proves it. **Acceptance:** the artifact contains exactly 38 rows, one per identifier `AC-01` through `AC-38`, with no blank evidence cell.

- [ ] [P8-T2] Verify the check-off touched only the acceptance-criteria section of `spec.md`.

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && grep -c "^- \[ \]" docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3944b95a7d58e712 && grep -c "^- \[x\]" docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md'
```

  **Acceptance:** the first count is exactly `3` (the pre-existing Blocker, Medium, and Low checkboxes in `## Context`) and the second is exactly `43` (the 5 pre-existing checked boxes plus the 38 acceptance criteria). Any other pair means either an acceptance criterion was left unchecked or a non-acceptance checkbox was altered. The pre-change counts, measured against the current tree, are 41 and 5.

- [ ] [P8-T3] Update `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md` header fields `Last Updated` and `Status`, and record the plan-to-outcome summary — including the P0-T7 measured line count, whether the extraction contingency ran, and the P7-T5 coverage delta — in `evidence/other/ac-checkoff.<run-timestamp>.md` under an `Outcome Summary:` field. **Acceptance:** the spec header `Status` field reads a value other than `Draft`, and the artifact contains a non-empty `Outcome Summary:` field naming those three values.

---

## Acceptance-Criteria Traceability

| ID | Criterion (spec.md line) | Implementation task | Test | Evidence |
|---|---|---|---|---|
| AC-01 | :616 new library exists, defines the four functions, sources cleanly, is in every suite's chain | P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P5-T1, P5-T6 | `bats tests/shell/test_cleanup_worktrees_dirt_classify.bats` | `evidence/qa-gates/dirt-lib-source-guard.<run-timestamp>.md` |
| AC-02 | :620 `dirt_build_artifact` fixture and verdict | P2-T1, P4-T3 | test 1 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-03 | :623 `dirt_session_artifact` fixture and verdict | P2-T3, P4-T3 | test 4 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-04 | :626 `dirt_content_on_main` fixture and verdict | P2-T4, P4-T3 | test 6 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-05 | :629 `dirt_content_in_history` fixture, verdict, and detail sha | P2-T5, P4-T3 | test 8 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-06 | :632 `dirt_staged_tree_is_commit` fixture, verdict, both detail fields | P2-T6, P4-T2, P4-T4 | tests 9 and 10 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-07 | :636 `dirt_unique` fixture, verdict, aggregate | P2-T7, P4-T3, P4-T4 | test 13 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-08 | :639 only the six verdict tokens are produced | P4-T3 | test 15 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-09 | :643 rung 1 precedes rungs 2-5 | P4-T3 | test 12 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-10 | :646 rung 2 is a pure string comparison | P4-T3 | test 5 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-11 | :649 rung 3 precedes rungs 4-5 | P4-T3 | test 2 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-12 | :651 rung 4 precedes rung 5 | P4-T3 | test 7 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-13 | :653 fail-closed read error yields UNIQUE, HAS_UNIQUE, refused clear | P2-T10, P4-T3, P4-T5 | test 14 of the classify suite and test 6 of the clearing suite | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-14 | :656 non-HintPath csproj diff is UNIQUE | P2-T2, P4-T3 | test 3 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-15 | :659 one per-file record per entry in porcelain order, then one aggregate | P4-T4, P5-T3 | tests 16 and 19 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md`, `evidence/regression-testing/pass-after-dirt-classify-full.<run-timestamp>.md` |
| AC-16 | :663 aggregate iff rule; zero entries emits neither record | P4-T4 | test 16 of the classify suite and test 11 of the regression suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md`, `evidence/regression-testing/regression-byte-identity-postchange.<run-timestamp>.md` |
| AC-17 | :666 detail-field rule and file-path-last rule via a pipe-bearing path | P2-T12, P4-T4 | test 17 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-18 | :669 report-mode byte-identity across eight scenarios | P2-T16, P3-T1, P5-T3 | the eight named tests of the regression suite | `evidence/regression-testing/regression-byte-identity-postchange.<run-timestamp>.md` |
| AC-19 | :673 apply-mode byte-identity without the flag | P2-T17, P3-T1, P5-T5 | the two apply-mode tests of the regression suite | `evidence/regression-testing/regression-byte-identity-postchange.<run-timestamp>.md` |
| AC-20 | :677 `remove_worktree_safe` unchanged; two suites pass with source-chain edits only | P5-T1, P5-T4, P5-T12 | `bats tests/shell/test_cleanup_worktrees_deletion.bats tests/shell/test_cleanup_worktrees_hard_failures.bats` | `evidence/regression-testing/deletion-hard-failures-unmodified.<run-timestamp>.md` |
| AC-21 | :681 flag without apply mode exits 2 with usage on stderr | P5-T8 | CLI tests 1 and 2 | `evidence/regression-testing/pass-after-cli-flag.<run-timestamp>.md` |
| AC-22 | :684 argument-order independence | P5-T8 | CLI test 3 | `evidence/regression-testing/pass-after-cli-flag.<run-timestamp>.md` |
| AC-23 | :686 `dirt_mixed_unique_blocks` refuses and runs no reset or clean | P2-T8, P4-T5, P5-T5 | tests 4 and 5 of the clearing suite | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-24 | :691 `dirt_clear_all_disposable` argv order, OK result, no force or ignored-file flag | P2-T9, P4-T5, P5-T5 | tests 1, 2, 3 of the clearing suite | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-25 | :696 second `cherry main feature-dirt` in the argv log after `reset --hard` and before the removal retry; direct reverify refusal | P2-T11, P5-T5 | clearing-suite test 8 `dirt_clear_reverify_order: the post-clear re-verification cherry probe follows the reset and precedes the removal retry`, and clearing-suite test 9 | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-26 | :701 exactly two removal call sites, no force, no third site | P5-T5, P5-T13 | `bats tests/shell/test_cleanup_worktrees_dirt_clear.bats` test 3 | `evidence/qa-gates/worktree-remove-call-sites.<run-timestamp>.md` |
| AC-27 | :704 report mode is non-mutating | P4-T2, P5-T3 | test 10 of the clearing suite | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-28 | :707 the stub logs the index-file environment variable | P1-T1 | the two-invocation stub observation in P1-T1 (set versus unset) | `evidence/qa-gates/stub-env-log.<run-timestamp>.md` |
| AC-29 | :709 cached diff-index probe present; every status read suppresses optional locks | P1-T2, P4-T2, P4-T4 | test 11 of the clearing suite | `evidence/regression-testing/pass-after-dirt-clear.<run-timestamp>.md` |
| AC-30 | :711 the first `rev-list` entry is never probed | P2-T6, P4-T2 | test 11 of the classify suite | `evidence/regression-testing/pass-after-dirt-classify.<run-timestamp>.md` |
| AC-31 | :714 format, check, and test complete with no error in one consecutive pass | P7-T1, P7-T2, P7-T3, P7-T8 | `bash scripts/bash/shell-qc.sh test` | `evidence/qa-gates/single-consecutive-pass.<run-timestamp>.md` |
| AC-32 | :716 kcov line coverage at least 85% and no branch-coverage assertion | P7-T4, P7-T5 | `bash scripts/bash/shell-qc.sh test --coverage` | `evidence/qa-gates/coverage-delta.<run-timestamp>.md` |
| AC-33 | :718 every changed or added shell file is at or under 500 lines, measured now | P0-T7, P4-T7, P7-T7 | `wc -l` over the enumerated file list | `evidence/qa-gates/file-size-limit.<run-timestamp>.md` |
| AC-34 | :720 SKILL.md Report Line Contract documents both new records and the unchanged `DIRTY` shape | P6-T1 | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/doc-literals.<run-timestamp>.md`, `evidence/qa-gates/pytest-push-down-contract-final.<run-timestamp>.md` |
| AC-35 | :723 SKILL.md Prohibited Shortcuts covers the flag and the widening prohibition | P6-T2, P6-T3 | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/doc-literals.<run-timestamp>.md`, `evidence/qa-gates/pytest-push-down-contract-final.<run-timestamp>.md` |
| AC-36 | :728 SKILL.md Dirty Worktree Triage Procedure trigger, step 6, and step 9 amendments | P6-T4 | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/doc-literals.<run-timestamp>.md`, `evidence/qa-gates/pytest-push-down-contract-final.<run-timestamp>.md` |
| AC-37 | :733 bundle mirror byte-identical and the contract test passes | P6-T5, P6-T6 | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `evidence/qa-gates/skill-mirror-parity.<run-timestamp>.md` |
| AC-38 | :736 contract comment, usage here-doc, and `--help` document all three strings | P5-T2, P5-T7 | CLI test 4 | `evidence/regression-testing/pass-after-cli-flag.<run-timestamp>.md`, `evidence/qa-gates/doc-literals.<run-timestamp>.md` |

# 2026-09-29-issue-507-python-push-down-divergence-follow-ups (Remediation Plan, Cycle 1)

- **Issue:** #790
- **Parent (optional):** epic #770 (`push-down-payload-correctness`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-10 (initial authoring)
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/issue-507-python-push-down-divergence-follow-ups-790`
- **Languages in scope:** Python (`scripts/dev_tools`, tier T4). TypeScript is not touched by this cycle.
- **Requirements source (sole AC source):** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`, section `## Acceptance Criteria`. This cycle closes AC-22 and re-confirms AC-19, AC-20, AC-21, and AC-24.
- **Remediation inputs:** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/remediation-inputs.2026-10-10T08-46.md` (finding R1) and `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/feature-audit.2026-10-10T08-46.md` (finding FA-B1).
- **Original plan:** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`. Its tasks P6-T5, P7-T1, and P8-T22 are completed by this cycle (Phase 4).

**Mode note (full-bug):** `spec.md` is required and present; `user-story.md` is not required and is absent.

**Finding being remediated (FA-B1):** AC-22 requires `scripts/dev_tools/push_down_claude_filesystem.py` at 85% line and 75% branch coverage or higher under the spec Test Strategy pytest command (the P6-T4 command of the original plan). The recorded measurement is 88.5% line and 64.29% branch (18 of 28 branches; `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/python-coverage-values.2026-10-10T08-25.md`). The branch targets missed by that command are in `ExcludingFileSystem._is_memory_mode_included` (`scripts/dev_tools/push_down_claude_filesystem.py` lines 406-414): the `skip` branch, the `merge` branch, and the `destination_root is None` branch. No test in the command's file set sets `memory_mode`.

**Remedy (tests only):** add one parametrized in-memory test of `ExcludingFileSystem.list_files` with four cases (skip; merge with the destination memory present; merge with the destination memory absent; merge with `destination_root=None`) to `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`. Branch arithmetic: the four cases cover the branch targets 406 to 407, 408 to 409, 409 to 410, and 409 to 411, which raises the covered count from 18 to 22 of 28 (78.57%). The threshold needs 21 of 28. No production file, spec criterion text, or file under `.claude/`, `.github/`, or `extensions/drm-copilot/resources/` is changed.

**Scope boundary:** this plan ends at the Phase 4 check-off, commit, and push on the branch above. Pull-request authoring, CI monitoring, and feature review are performed later by the orchestrator and are not tasks in this plan.

**Fail-closed evidence rule:** Python policy requires coverage (line >= 85%, branch >= 75%). Baseline and final coverage tasks record numeric line and branch values for all four AC-22 modules. If any required baseline artifact, final artifact, or numeric value is missing, the outcome is remediation-required and never PASS.

**Evidence accounting rule:** every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the task's last command; every other command's exit code and asserted output are recorded inside `Output Summary:` in command order. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. No planned command task may record `EXIT_CODE: SKIPPED`; this plan contains no skip branch.

## Files Written

- `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` (the only code file)
- `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` (the AC-22 checkbox only)
- `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md` (the checkbox states of P6-T5, P7-T1, and P8-T22 and a pointer suffix on each of those three lines)
- `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/remediation-plan.2026-10-10T08-46.md` (this file; checkbox states)
- Evidence artifacts under `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/` in the sub-folders `remediation-baseline/`, `regression-testing/`, `qa-gates/`, and `other/`.

Tool outputs `artifacts/python/coverage-790-remediation-baseline.json`, `artifacts/python/coverage-790-remediation.json`, and `artifacts/python/lcov.info` are gitignored and are not evidence artifacts.

## Terms used in every task

- FEATURE means `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`. Evidence is written only under FEATURE/evidence/remediation-baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock, never composed.
- START_SHA means the commit printed by `git rev-parse HEAD` in P0-T1, before any edit of this cycle (expected to begin `0f28f1398`). Every diff in this plan is anchored to START_SHA or to `origin/main`.
- BASE_SHA means the commit printed by `git merge-base HEAD origin/main` in P0-T1 (expected `7bbd0b9b990737642b4eeded01a27b7c5c8348b3`).
- TEST-FILE means `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`.
- COVERAGE-CMD means the spec Test Strategy pytest command (the P6-T4 command of the original plan), whose eight test files are `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`, and `tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py`, with the four dotted `--cov=` modules, `--cov-branch`, `--cov-report=term-missing`, and a JSON report path that differs per task. The command is written out in full in P0-T6 and P2-T4.
- AC-22 MODULES means `scripts/dev_tools/push_down_claude_filesystem.py`, `scripts/dev_tools/push_down_claude_gitignore_merge.py`, `scripts/dev_tools/push_down_claude_customizations.py`, and `scripts/dev_tools/push_down_claude_pack_selection.py`.

## Execution constraints

- Commands are written for the Bash tool and run from the root of the #790 worktree. P0-T1 confirms the branch, which identifies the worktree without recording a host path. Artifacts never record an absolute host path.
- No command in this plan contains a heredoc, and no read command is chained to a `cd`.
- File-content checks use `git grep --no-index`, which searches working-tree files whether tracked or untracked. Output convention for `git grep --no-index -c`: a match count n >= 1 prints `<path>:<n>` and exits 0; n = 0 prints nothing and exits 1. A pattern that begins with `-` is passed through `-e`.
- Edits use the Edit tool (one exact `old_string` to `new_string`, copied from the file as it stands). Test content is specified in Appendix A; the executor does not change a test name, a parametrized case, or an asserted literal given there. The only permitted deviation is the whitespace and wrapping that `black` rewrites in P1-T2.
- If any Write or Edit is denied by a hook or a permission rule, stop and report the denial text verbatim. Do not delete hook state files and do not route a write through another tool to avoid a hook.
- Commits and pushes: one commit and one push at the end of every phase (the last three tasks of each phase). Pushes use `git push -u origin <branch>`; no force push, no `--force-with-lease`, and no history rewrite is permitted. A rejected push stops the plan and is reported.
- Commit attribution: every commit carries the two trailer lines `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo`, passed with `--trailer`. The commit subject names the issue as `(790)`.
- Files not edited: every file under `scripts/`, `extensions/`, `.claude/`, `.github/`, `.codex/`, and `.agents/`, and every `tests/` file other than TEST-FILE. If a task appears to require editing one of them, stop and report.
- Commands expected to exceed about 8 minutes (`poetry run pytest tests/scripts/dev_tools -k push_down`) may run in the background; the executor waits for the completion notification before reading output.

## Planner decisions and assumptions (recorded for audit)

- PD1 - Evidence-location override. `spec.md` AC-22 and the Test Strategy name `<FEATURE>/evidence/baselines/` and `<FEATURE>/evidence/coverage/`. Recorded overrides:
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/baselines/ replaced with FEATURE/evidence/remediation-baseline/ (remediation baseline) and FEATURE/evidence/baseline/ (original baseline, unchanged)
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/coverage/ replaced with FEATURE/evidence/qa-gates/
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/qa/ replaced with FEATURE/evidence/qa-gates/
- PD2 - Test placement. TEST-FILE is used instead of `tests/scripts/dev_tools/test_push_down_claude_customizations.py`. The latter has 458 lines and the Appendix A block adds 57 lines (515 total), which exceeds the 500-line cap of AC-19. TEST-FILE has 390 lines and reaches 447. Both files are in the COVERAGE-CMD file set, so the test is counted by the AC-22 command. The line figures are verified in P0-T1 and P3-T1.
- PD3 - No fail-before run. The remedy adds tests for behavior that is already correct in production (`_is_memory_mode_included`); the gap is in measured coverage, not in behavior. The "before" state is the numeric remediation baseline of P0-T6 and P0-T7 (branch 64.29%), and the "after" state is P2-T5. No production change is made, so no test can fail on an unfixed tree.
- PD4 - Coverage command form. COVERAGE-CMD is the spec command with `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py` included, exactly as the original P6-T4 ran it, and with `--cov-report=json:artifacts/python/coverage-790-remediation-baseline.json` (baseline) or `--cov-report=json:artifacts/python/coverage-790-remediation.json` (final). The terminal `Cover` column combines statements and branches, so separate line and branch values are computed from the JSON report's per-file `summary` keys `covered_lines`, `num_statements`, `covered_branches`, and `num_branches`. The success-case output of both the pytest command and the JSON-derived command was observed in `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/pytest-targeted-coverage.2026-10-10T08-25.md` and `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/python-coverage-values.2026-10-10T08-25.md`: the table rows for the four modules and the `TOTAL` row are printed, and the JSON-derived command prints one `LINE ... BRANCH ...` line per module.
- PD5 - Expected post-change values (informational, not asserted exactly). With lines 407 and 409-414 covered, the filesystem module should print about LINE 92.92 and BRANCH 78.57, and `push_down_claude_filesystem.py` should miss only lines 122, 128, 135, 145, 148, 182-183, and 326. The binding thresholds are LINE >= 85, BRANCH >= 75, and at least 21 covered branches of 28.
- PD6 - AC text is not edited. The alternative of amending the AC-22 verification command (add `test_push_down_claude_memory_scope.py` and `test_push_down_claude_pack_memory_modes.py`) is a planning-agent decision outside this plan and is not taken. The only `spec.md` edit is the AC-22 checkbox.
- PD7 - AC-24 re-confirmation. `spec.md` AC-24 is already checked (checked by the feature reviewer on the pre-remediation tree). P3-T3 re-confirms it against the post-remediation loop and records the result; it does not edit `spec.md` for AC-24 and does not change the P8-T24 state of the original plan.
- PD8 - Changed-line coverage. P2-T6 reuses the PD7 method of the original plan (changed executable lines from `git diff -U0 BASE_SHA`, minus `missing_lines` of the final JSON report). The production files are unchanged by this cycle, so the changed lines are those of the original change; the expected result is 100% as in the original delta artifact.
- A1 - Assumption: `origin/main` is not fetched by the executor; BASE_SHA is recorded once.
- A2 - Assumption: the Bash tool provides `wc`, `git`, and `poetry`.

## AC Traceability

| AC | Implementation | Tests | Evidence task |
|---|---|---|---|
| AC-22 | P1-T1 | `test_excluding_file_system_list_files_applies_memory_mode` (4 cases) | P0-T6, P0-T7, P2-T4, P2-T5, P2-T6, P4-T1 |
| AC-19 | P1-T1, P1-T2 | line counts | P0-T1, P3-T1 |
| AC-20 | scope constraint | scope diffs | P3-T2 |
| AC-21 | scope constraint | scope diffs | P3-T2 |
| AC-24 | Phase 2 loop | Python toolchain | P2-T1 to P2-T4, P2-T7, P3-T3 |

### Phase 0 — Policy Reads and Remediation Baseline

Each task in this phase writes the artifact it names under FEATURE/evidence/remediation-baseline/ unless stated otherwise. Phase 0 changes no code.

- [x] [P0-T1] Verify the remediation preconditions and record START_SHA and BASE_SHA in FEATURE/evidence/remediation-baseline/preconditions.TS.md.
      Commands: `git branch --show-current`; `git rev-parse HEAD`; `git merge-base HEAD origin/main`; `wc -l tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_customizations.py`; `git grep --no-index -c -F -e "- [ ] AC-22" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `git status --porcelain -- tests scripts extensions`.
      Acceptance: the branch command prints exactly `bug/issue-507-python-push-down-divergence-follow-ups-790` (any other value stops the plan); the two SHA commands print a 40-character SHA each, recorded as START_SHA and BASE_SHA; `wc -l` prints 390 for TEST-FILE and 458 for `tests/scripts/dev_tools/test_push_down_claude_customizations.py` (any other value is recorded and reported to the orchestrator before Phase 1, because PD2 depends on it); the AC-22 grep prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md:1` (AC-22 is unchecked at the start); the porcelain command prints nothing. Because this task reads `git grep` for the unchecked literal `- [ ] AC-22`, which exists in `spec.md` at the start, the search can fail.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/remediation-baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/tonality.md`; (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`; (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`; (4) `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 15 files in that order.
- [x] [P0-T3] Python format baseline, and record FEATURE/evidence/remediation-baseline/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0 and a summary line containing "would be left unchanged" (the original run printed 585 files). A different result is recorded verbatim; a failure in a file outside TEST-FILE is recorded as PRE-EXISTING and does not authorize editing that file.
- [x] [P0-T4] Python lint baseline, and record FEATURE/evidence/remediation-baseline/ruff-check.TS.md.
      Command: `poetry run ruff check .`.
      Acceptance: exit 0 and the line "All checks passed!". (No `fix` key is set under `[tool.ruff]` in `pyproject.toml`, so this command does not rewrite files.)
- [x] [P0-T5] Python type-check baseline, and record FEATURE/evidence/remediation-baseline/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [x] [P0-T6] Remediation coverage baseline: run COVERAGE-CMD against the unmodified tree, and record FEATURE/evidence/remediation-baseline/pytest-targeted-coverage.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-remediation-baseline.json`.
      Acceptance: exit 0, no failed test, and the summary line reporting 97 passed (recorded as BASELINE_TARGETED_PASSED). The four per-module rows and the `TOTAL` row of the term-missing table are recorded verbatim. The `push_down_claude_filesystem.py` row lists the Missing entries `407` and `409-414` (the lines this cycle covers). A passed count other than 97 is recorded and reported before Phase 1.
- [x] [P0-T7] Remediation per-module numeric baseline from the P0-T6 JSON report, and record FEATURE/evidence/remediation-baseline/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-remediation-baseline.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_gitignore_merge.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"`.
      Acceptance: exit 0 and four printed lines; the first line is `scripts/dev_tools/push_down_claude_filesystem.py LINE 88.5 BRANCH 64.29`. All four lines are recorded verbatim. A printed filesystem BRANCH value of 75 or higher means the finding no longer reproduces; the executor then stops and reports to the orchestrator instead of continuing.
- [x] [P0-T8] Remediation wide push-down baseline, and record FEATURE/evidence/remediation-baseline/pytest-push-down-wide.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools -k push_down`.
      Acceptance: exit 0 and no failed test; the passed count is recorded as BASELINE_WIDE_PASSED (581 at the audit). A failure is recorded verbatim and classified PRE-EXISTING.
- [x] [P0-T9] Mark P0-T1 through P0-T8 `[x]` in this plan file when their artifacts meet their acceptance, then stage the Phase 0 changes, and record FEATURE/evidence/other/rem-p0-t9.TS.md.
      Commands: `git add docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git diff --cached --name-only`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: `git add` exits 0. Allow-list: the cached name list is non-empty and every path begins with `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/`; the list includes `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/remediation-plan.2026-10-10T08-46.md` and the P0-T1 through P0-T8 artifacts. In the scoped porcelain output every line has a non-space first column and a space second column (staged, with no unstaged change) and no line begins with `??`. Any other path or line stops the task. If a hook denies `git add`, stop and report the denial text verbatim. This artifact is written after staging and is committed at the next boundary.
- [x] [P0-T10] Commit the Phase 0 changes on `bug/issue-507-python-push-down-divergence-follow-ups-790`, and record FEATURE/evidence/other/rem-p0-t10.TS.md.
      Commands: `git commit -m "docs(790): add remediation cycle 1 plan and baseline evidence" -m "Remediation cycle 1 for FA-B1: capture the AC-22 coverage baseline for push_down_claude_filesystem.py before adding in-memory memory-mode tests." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- tests`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the porcelain command prints nothing. The P0-T9 artifact and this plan file's later checkbox states are left for the next commit. If a hook denies the commit, stop and report the denial text verbatim.
- [x] [P0-T11] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/rem-p0-t11.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. A rejected push (non-fast-forward) stops the task and is reported; no force push is used.

### Phase 1 — Add the In-Memory Memory-Mode Tests

Each task in this phase writes the artifact it names under FEATURE/evidence/regression-testing/ or FEATURE/evidence/other/, as stated in the task.

- [x] [P1-T1] Update `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` with the Appendix A block, and record FEATURE/evidence/other/rem-p1-t1.TS.md.
      Edit: `old_string` is the file's final line, `    ), "Repeated generation must produce identical destination content."`, which occurs once in TEST-FILE; `new_string` is that same line followed by a newline and the complete Appendix A block (two blank lines, then the block). The new test function is named `test_excluding_file_system_list_files_applies_memory_mode`; the module-level constants it adds are `MEMORY_RELATIVE` and `GENERAL_MEMORY_TEXT`.
      Command: `wc -l tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`.
      Acceptance: the Edit succeeds and `wc -l` prints a count greater than 390 and at most 500 (447 expected). No other file is modified by this task.
- [x] [P1-T2] Format TEST-FILE with black and record the observation in FEATURE/evidence/other/rem-p1-t2.TS.md.
      Commands: `git hash-object tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`; `poetry run black tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`; `git hash-object tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`; `git status --porcelain -- tests`.
      Acceptance: black exits 0 and prints the success-case line `1 file left unchanged.` The two `git hash-object` outputs are identical (the binding no-change observation) and the porcelain output lists only ` M tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` (unstaged modification of TEST-FILE; nothing else). If black instead prints `1 file reformatted.`, record the two differing hashes, rerun the same black command once, and require the line `1 file left unchanged.` from the rerun; the Appendix A names and literals must be intact after the reformat.
- [x] [P1-T3] Run the new tests and the whole TEST-FILE, and record FEATURE/evidence/regression-testing/rem-new-tests.TS.md.
      Commands: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py -k test_excluding_file_system_list_files_applies_memory_mode`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`.
      Acceptance: the first command exits 0 with the summary line reporting 4 passed; the second exits 0 with the summary line reporting 10 passed (6 existing plus 4 new) and no failed test. The four node IDs ending in the case ids `skip-drops-general-memory`, `merge-drops-memory-present-at-destination`, `merge-keeps-memory-absent-at-destination`, and `merge-without-destination-root-keeps-memory` are recorded. A failure is fixed in TEST-FILE only (never in production code), then P1-T2 and P1-T3 are rerun.
- [ ] [P1-T4] Mark P1-T1 through P1-T3 `[x]` and P0-T9 through P0-T11 `[x]` in this plan file when their artifacts meet their acceptance, then stage the Phase 1 changes, and record FEATURE/evidence/other/rem-p1-t4.TS.md.
      Commands: `git add tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git diff --cached --name-only`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: `git add` exits 0. Allow-list: every cached path is `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` or begins with `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/`; the list contains TEST-FILE. In the scoped porcelain output every line has a non-space first column and a space second column and no line begins with `??`. Any other path or line stops the task.
- [ ] [P1-T5] Commit the Phase 1 changes, and record FEATURE/evidence/other/rem-p1-t5.TS.md.
      Commands: `git commit -m "test(790): cover ExcludingFileSystem skip and merge memory modes in memory" -m "Remediation cycle 1 for FA-B1: add four in-memory list_files cases (skip, merge with destination memory present, merge with destination memory absent, merge without destination_root) so the AC-22 command reaches the memory-mode branches. Tests only; no production change." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- tests`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the porcelain command prints nothing.
- [ ] [P1-T6] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/rem-p1-t6.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. No force push is used.

### Phase 2 — Python Toolchain Loop and AC-22 Coverage Verification

Restart rule: run P2-T1 through P2-T7 in order. If any step fails or changes any file, fix the cause in TEST-FILE only, then restart from P2-T1. Every rerun rewrites the affected artifacts with a new TS, and each artifact records its loop iteration number in `Output Summary:`. The loop ends only when P2-T1 through P2-T7 pass in one uninterrupted pass. Architecture-boundary stage: N/A (no Python boundary tool configured). Contract stage: N/A (no schema change). Integration stage: covered by the hermetic in-memory push-down suites in P2-T4 and P2-T7. A coverage shortfall at P2-T5 is fixed by adding further in-memory cases to TEST-FILE within the 500-line cap (a case may not add a temporary file or `tmp_path`), then restarting from P2-T1; if the cap prevents the fix, stop and report. All artifacts in this phase are written under FEATURE/evidence/qa-gates/.

- [ ] [P2-T1] Python format check, and record FEATURE/evidence/qa-gates/remediation-black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0, a summary line containing "would be left unchanged", and no line containing "would reformat". A PRE-EXISTING failure from P0-T3 does not stop the loop but is recorded and its file is not edited.
- [ ] [P2-T2] Python lint, and record FEATURE/evidence/qa-gates/remediation-ruff-check.TS.md.
      Command: `poetry run ruff check .`.
      Acceptance: exit 0 and the line "All checks passed!".
- [ ] [P2-T3] Python type check (`pyproject.toml` `[tool.pyright]`, strict mode), and record FEATURE/evidence/qa-gates/remediation-pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [ ] [P2-T4] Python targeted tests with coverage for the AC-22 modules (COVERAGE-CMD with the final JSON report), and record FEATURE/evidence/qa-gates/remediation-pytest-targeted-coverage.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-remediation.json`.
      Acceptance: exit 0, no failed test, and a passed count equal to BASELINE_TARGETED_PASSED plus 4 (101 expected). The four per-module rows and the `TOTAL` row of the term-missing table are recorded verbatim. The `push_down_claude_filesystem.py` row no longer lists `407` or `409-414` in its Missing column.
- [ ] [P2-T5] Python per-module numeric line and branch coverage from the P2-T4 JSON report plus the filesystem branch detail, and record FEATURE/evidence/qa-gates/remediation-python-coverage-values.TS.md.
      Commands: `poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-remediation.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_gitignore_merge.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"`; `poetry run python -c "import json, pathlib; s = json.loads(pathlib.Path('artifacts/python/coverage-790-remediation.json').read_text(encoding='utf-8'))['files']; k = [x for x in s if x.replace(chr(92), '/').endswith('scripts/dev_tools/push_down_claude_filesystem.py')][0]; print('FS_BRANCHES', s[k]['summary']['covered_branches'], 'OF', s[k]['summary']['num_branches'], 'MISSING', s[k]['missing_lines'])"`.
      Acceptance: both commands exit 0. The first prints four lines; every LINE value is >= 85 and every BRANCH value is >= 75 (a module with `NO_BRANCHES` meets the branch gate); the filesystem line is expected near `LINE 92.92 BRANCH 78.57` (PD5). The second prints one line beginning `FS_BRANCHES` whose covered count is at least 21 and whose total is 28, and whose MISSING list contains none of 407, 409, 410, 411, 412, 413, or 414. `Output Summary:` tabulates, per AC-22 module, baseline LINE and BRANCH (P0-T7), final LINE and BRANCH, and the delta.
- [ ] [P2-T6] Python changed-line coverage for the three changed production modules (AC-22 "no regression on changed lines"; original-plan P7-T1 method), and record FEATURE/evidence/qa-gates/remediation-python-coverage-delta.TS.md.
      Command: `poetry run python -c "import json, pathlib, re, subprocess; base = subprocess.run(['git', 'merge-base', 'HEAD', 'origin/main'], capture_output=True, text=True, check=True).stdout.strip(); files = {k.replace(chr(92), '/'): v for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-remediation.json').read_text(encoding='utf-8'))['files'].items()}; mods = ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']; [print(m, 'CHANGED_EXECUTABLE', len(c), 'MISSED', len(c & set(files[m]['missing_lines'])), 'PCT', round(100 * (len(c) - len(c & set(files[m]['missing_lines']))) / len(c), 2) if c else 'NO_CHANGED_EXECUTABLE') for m in mods for c in [{n for a, b in re.findall(r'^@@ -[^ ]+ [+]([0-9]+)(?:,([0-9]+))? @@', subprocess.run(['git', 'diff', '-U0', base, '--', m], capture_output=True, text=True, check=True).stdout, re.M) for n in range(int(a), int(a) + (int(b) if b else 1))} & (set(files[m]['executed_lines']) | set(files[m]['missing_lines']))]]"`.
      Acceptance: exit 0 and three printed lines; every PCT is >= 85 (a module whose changed lines are all non-executable prints `NO_CHANGED_EXECUTABLE`, which passes). The original delta artifact `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/python-coverage-delta.2026-10-10T08-29.md` reported 100% and is quoted in `Output Summary:` for comparison.
- [ ] [P2-T7] Python wider push-down regression pass, and record FEATURE/evidence/qa-gates/remediation-pytest-push-down-wide.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools -k push_down`.
      Acceptance: exit 0 and no failed test; the passed count equals BASELINE_WIDE_PASSED plus 4 (585 expected). A failure classified PRE-EXISTING in P0-T8 is recorded with `ExpectedExitCode: 1` and the result is `PRE-EXISTING ONLY`; any other failure restarts the loop.
- [ ] [P2-T8] Mark P1-T4 through P1-T6 and P2-T1 through P2-T7 `[x]` in this plan file when their artifacts meet their acceptance, then stage the Phase 2 changes, and record FEATURE/evidence/other/rem-p2-t8.TS.md.
      Commands: `git add docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git diff --cached --name-only`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: `git add` exits 0. Allow-list: the cached list is non-empty and every path begins with `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/`. In the scoped porcelain output every line has a non-space first column and a space second column and no line begins with `??`. Any other path or line stops the task.
- [ ] [P2-T9] Commit the Phase 2 changes, and record FEATURE/evidence/other/rem-p2-t9.TS.md.
      Commands: `git commit -m "docs(790): record remediation cycle 1 QA gate and coverage evidence" -m "Python toolchain loop and AC-22 per-module coverage after the in-memory memory-mode tests." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- tests`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the porcelain command prints nothing.
- [ ] [P2-T10] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/rem-p2-t10.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. No force push is used.

### Phase 3 — AC-19 Line Counts, Scope, and AC-24 Re-Confirmation

Each task in this phase writes the artifact it names under FEATURE/evidence/qa-gates/ or FEATURE/evidence/other/. The check-off in Phase 4 starts only when P2-T5 and P2-T6 met their thresholds.

- [ ] [P3-T1] Per-file physical line counts of every production, test, and fixture file the original change wrote plus TEST-FILE, for AC-19, and record FEATURE/evidence/qa-gates/remediation-line-counts.TS.md.
      Command: `wc -l scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts tests/fixtures/push_down/gitignore-merge-parity.json tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs`.
      Acceptance: exit 0, and every per-file count is at most 500. The count for TEST-FILE is greater than 390 and at most 500 (recorded), the count for `tests/scripts/dev_tools/test_push_down_claude_customizations.py` is 458, and the other counts are unchanged from `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/qa-gates/line-counts.2026-10-10T08-30.md` (compared line by line in `Output Summary:`). A file over 500 is condensed within TEST-FILE and Phase 2 is rerun from P2-T1.
- [ ] [P3-T2] Scope check: this cycle changed no production file and no protected surface (AC-20 and AC-21 in their spec forms), and record FEATURE/evidence/qa-gates/remediation-scope.TS.md.
      Commands: `git diff --name-only START_SHA -- scripts extensions .claude .github .codex .agents`; `git diff --name-only origin/main...HEAD -- scripts/dev_tools/push_down_copilot_customizations_filesystem.py scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_codex_filesystem.py scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_claude_exclusion_filter.py extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`; `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/resources .claude .github .codex .agents`; `git status --porcelain -- scripts extensions .claude .github .codex .agents`.
      Acceptance: the executor substitutes the recorded START_SHA value; all four commands exit 0 and print nothing (no production or protected-surface path changed in this cycle, and the AC-20 and AC-21 spec forms remain empty).
- [ ] [P3-T3] Re-confirm AC-24 (Python toolchain single pass) against the post-remediation loop, and record FEATURE/evidence/qa-gates/remediation-ac24-reconfirm.TS.md.
      Acceptance (derived from recorded artifacts, no new command): `Output Summary:` states, for the final uninterrupted loop iteration, the exit code and key result of P2-T1 (black `--check`), P2-T2 (ruff), P2-T3 (pyright), P2-T4 (the Test Strategy pytest command, 101 passed), and P2-T7 (`-k push_down`, 585 passed), each with its artifact path, and concludes `AC-24: RECONFIRMED` only when every one exited 0 with no `PRE-EXISTING ONLY` outcome; otherwise it concludes `AC-24: NOT RECONFIRMED` with the failing step and the executor stops and reports to the orchestrator. `spec.md` is not edited by this task (PD7).
- [ ] [P3-T4] Mark P2-T8 through P2-T10 and P3-T1 through P3-T3 `[x]` in this plan file when their artifacts meet their acceptance, then stage the Phase 3 changes, and record FEATURE/evidence/other/rem-p3-t4.TS.md.
      Commands: `git add docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git diff --cached --name-only`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: `git add` exits 0. Allow-list: the cached list is non-empty and every path begins with `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/`. In the scoped porcelain output every line has a non-space first column and a space second column and no line begins with `??`. Any other path or line stops the task.
- [ ] [P3-T5] Commit the Phase 3 changes, and record FEATURE/evidence/other/rem-p3-t5.TS.md.
      Commands: `git commit -m "docs(790): record remediation cycle 1 line-count and scope evidence" -m "AC-19 line counts, AC-20 and AC-21 scope checks, and AC-24 re-confirmation after the in-memory memory-mode tests." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- tests`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the porcelain command prints nothing.
- [ ] [P3-T6] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/rem-p3-t6.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. No force push is used.

### Phase 4 — AC-22 Check-Off and Original-Plan Pointers

Phase 4 starts only when P2-T5 printed LINE >= 85 and BRANCH >= 75 for all four AC-22 modules, P2-T6 printed every PCT >= 85 (or `NO_CHANGED_EXECUTABLE`), and P3-T3 concluded `AC-24: RECONFIRMED`. If any of those did not hold, the executor stops and reports FA-B1 as unresolved; this plan has no path that checks AC-22 off on unmet thresholds. Each of P4-T1 through P4-T4 is one Edit and edits no text other than the checkbox state and, for the original plan, the pointer suffix.

- [ ] [P4-T1] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-22 checkbox from the unchecked literal `- [ ] AC-22` to the checked literal `- [x] AC-22` (Edit tool, one replacement whose `old_string` is `- [ ] AC-22 Python coverage` and whose `new_string` is `- [x] AC-22 Python coverage`), and record FEATURE/evidence/other/rem-p4-t1.TS.md.
      Command: `git grep --no-index -c -F -e "- [x] AC-22" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`.
      Acceptance: the Edit succeeds and the grep prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md:1`. The criterion text after the checkbox is not changed (verified in P4-T5).
- [ ] [P4-T2] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md` task P6-T5 from `- [ ] [P6-T5]` to the checked literal `- [x] [P6-T5]` and append the pointer suffix ` Remediation cycle 1 evidence: FEATURE/evidence/qa-gates/remediation-python-coverage-values.<recorded TS>.md (see remediation-plan.2026-10-10T08-46.md).` to the end of the same line, substituting the TS recorded in P2-T5 (Edit tool; `old_string` is the whole P6-T5 task line as it stands, `new_string` is that line with the checkbox changed and the suffix appended), and record FEATURE/evidence/other/rem-p4-t2.TS.md.
      Command: `git grep --no-index -c -F -e "- [x] [P6-T5]" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: the Edit succeeds and the grep prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md:1`.
- [ ] [P4-T3] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md` task P7-T1 from `- [ ] [P7-T1]` to the checked literal `- [x] [P7-T1]` and append the pointer suffix ` Remediation cycle 1 evidence: FEATURE/evidence/qa-gates/remediation-python-coverage-delta.<recorded TS>.md (see remediation-plan.2026-10-10T08-46.md).` to the end of the same line, substituting the TS recorded in P2-T6 (Edit tool; `old_string` is the whole P7-T1 task line, `new_string` is that line with the checkbox changed and the suffix appended), and record FEATURE/evidence/other/rem-p4-t3.TS.md.
      Command: `git grep --no-index -c -F -e "- [x] [P7-T1]" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: the Edit succeeds and the grep prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md:1`.
- [ ] [P4-T4] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md` task P8-T22 from `- [ ] [P8-T22]` to the checked literal `- [x] [P8-T22]` and append the pointer suffix ` Remediation cycle 1 evidence: FEATURE/evidence/other/rem-p4-t1.<recorded TS>.md and the P6-T5 and P7-T1 pointers above (see remediation-plan.2026-10-10T08-46.md).` to the end of the same line, substituting the TS recorded in P4-T1 (Edit tool; `old_string` is the whole P8-T22 task line, `new_string` is that line with the checkbox changed and the suffix appended), and record FEATURE/evidence/other/rem-p4-t4.TS.md.
      Command: `git grep --no-index -c -F -e "- [x] [P8-T22]" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: the Edit succeeds and the grep prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md:1`.
- [ ] [P4-T5] Verify that the only `spec.md` change since START_SHA is the AC-22 checkbox, and record FEATURE/evidence/qa-gates/remediation-spec-diff.TS.md.
      Commands: `git diff --numstat START_SHA -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `git diff -U0 START_SHA -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`.
      Acceptance: the executor substitutes the recorded START_SHA value; the numstat command prints one line with the counts `1` and `1` (one added line, one deleted line) followed by the `spec.md` path; the unified-zero diff shows exactly one removed line beginning `-- [ ] AC-22` and one added line beginning `+- [x] AC-22`, and the text after the checkbox is identical on the two lines (recorded verbatim).
- [ ] [P4-T6] Verify that no unchecked acceptance criterion remains in `spec.md`, and record FEATURE/evidence/qa-gates/remediation-spec-unchecked.TS.md with `ExpectedExitCode: 1`.
      Command: `git grep --no-index -c -F -e "- [ ] AC-" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`.
      Acceptance: the command prints nothing and exits 1 (the pass condition: zero lines contain the unchecked literal `- [ ] AC-`). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [ ] [P4-T7] Verify the three original-plan pointers, and record FEATURE/evidence/qa-gates/remediation-plan-pointers.TS.md.
      Command: `git grep --no-index -c -F -e "Remediation cycle 1 evidence:" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: the command prints `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md:3` (the pointer text `Remediation cycle 1 evidence:` is on the P6-T5, P7-T1, and P8-T22 lines only). Each pointer's artifact path exists on disk (checked with the Glob tool or `ls` and recorded).
- [ ] [P4-T8] Record the Phase 4 check-off in FEATURE/evidence/other/rem-ac-checkoff.TS.md.
      Acceptance (derived from recorded artifacts, no new command): the artifact contains these lines, each with its evidence paths: `AC-22: CHECKED` (P2-T5, P2-T6, P4-T1, P4-T5, P4-T6); `AC-19: RECONFIRMED` (P3-T1); `AC-20: RECONFIRMED` and `AC-21: RECONFIRMED` (P3-T2); `AC-24: RECONFIRMED` (P3-T3); `ORIGINAL-PLAN: P6-T5, P7-T1, P8-T22 CHECKED` (P4-T2, P4-T3, P4-T4, P4-T7). It also states the post-remediation filesystem-module values (LINE and BRANCH from P2-T5) against the baseline values (P0-T7).
- [ ] [P4-T9] Mark P3-T4 through P3-T6 and P4-T1 through P4-T8 `[x]` in this plan file when their artifacts meet their acceptance, then stage the Phase 4 changes, and record FEATURE/evidence/other/rem-p4-t9.TS.md.
      Commands: `git add docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git diff --cached --name-only`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: `git add` exits 0. Allow-list: the cached list is non-empty, every path begins with `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/`, and the list contains `spec.md`, `plan.2026-10-08T13-56.md`, and the P4-T1 through P4-T8 artifacts. In the scoped porcelain output every line has a non-space first column and a space second column and no line begins with `??`. Any other path or line stops the task.
- [ ] [P4-T10] Commit the Phase 4 changes, and record FEATURE/evidence/other/rem-p4-t10.TS.md.
      Commands: `git commit -m "docs(790): check off AC-22 on remediation coverage evidence" -m "Remediation cycle 1 for FA-B1: push_down_claude_filesystem.py meets the AC-22 thresholds under the Test Strategy command. Check off AC-22 in spec.md and mark P6-T5, P7-T1, and P8-T22 of the original plan with pointers to the remediation evidence." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_019X4DnRXKaKaED3yXYySYZo"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- tests docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the scoped porcelain output is empty. The P4-T9 artifact and the later checkbox states of this plan file are left for the orchestrator's next commit.
- [ ] [P4-T11] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/rem-p4-t11.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. A rejected push (non-fast-forward) stops the task and is reported; no force push is used. This artifact and the P4 checkbox states for P4-T10 and P4-T11 are written after the commit and are left for the orchestrator's next commit; the executor creates no further commit.

## Appendix A — Test Content for `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`

The block below is appended after the file's last line (P1-T1). It uses only names already imported by the file (`importlib`, `Path`, `pytest`) and the file's existing `MemoryFile` and `RecordingFileSystem` helpers. It creates no temporary file and does not use `tmp_path`. Source behavior it exercises: `scripts/dev_tools/push_down_claude_filesystem.py` `_is_memory_mode_included` (lines 406-414), reached through `ExcludingFileSystem.list_files`.

```python


# A general-scoped agent memory used by the memory-mode filter test below.
MEMORY_RELATIVE = ".claude/agent-memory/orchestrator/general.md"
GENERAL_MEMORY_TEXT = "---\nname: g\nmetadata:\n  scope: general\n---\nbody\n"


@pytest.mark.parametrize(
    ("memory_mode", "destination_root", "destination_has_memory", "expect_listed"),
    [
        ("skip", Path("/dest"), False, False),
        ("merge", Path("/dest"), True, False),
        ("merge", Path("/dest"), False, True),
        ("merge", None, False, True),
    ],
    ids=[
        "skip-drops-general-memory",
        "merge-drops-memory-present-at-destination",
        "merge-keeps-memory-absent-at-destination",
        "merge-without-destination-root-keeps-memory",
    ],
)
def test_excluding_file_system_list_files_applies_memory_mode(
    memory_mode: str,
    destination_root: Path | None,
    destination_has_memory: bool,
    expect_listed: bool,
) -> None:
    """Verify list_files applies the skip and merge memory modes in memory.

    Each case seeds one general-scoped agent memory under the source root and,
    when requested, the same memory under the destination root. ``skip`` drops
    the memory, ``merge`` drops it only when the destination already holds it,
    and ``merge`` without a destination root keeps it.
    """

    # Arrange: seed the source memory and, when requested, the destination copy.
    module = importlib.import_module("scripts.dev_tools.push_down_claude_filesystem")
    source_memory = Path("/repo") / MEMORY_RELATIVE
    files = {source_memory: MemoryFile(GENERAL_MEMORY_TEXT)}
    if destination_has_memory:
        files[Path("/dest") / MEMORY_RELATIVE] = MemoryFile("existing\n")
    excluding = module.ExcludingFileSystem(
        RecordingFileSystem(files=files),
        Path("/repo"),
        (),
        source_root=Path("/repo"),
        destination_root=destination_root,
        memory_mode=memory_mode,
    )

    # Act: enumerate the source `.claude` tree through the filtered view.
    listed = excluding.list_files(Path("/repo/.claude"))

    # Assert: the memory is listed only when the active memory mode keeps it.
    expected: list[Path] = [source_memory] if expect_listed else []
    assert listed == expected
```

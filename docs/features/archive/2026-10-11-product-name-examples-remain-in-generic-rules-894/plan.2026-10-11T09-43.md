# 2026-10-11-product-name-examples-remain-in-generic-rules (Plan)

- **Issue:** #894
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** minor-audit
- **Branch:** `bug/product-name-examples-remain-in-generic-rules-894`
- **Language in scope:** Python (one test module). The other changed files are Markdown rule files and their bundled mirrors.
- **Requirements source (sole AC source):** `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`, section `## Acceptance Criteria` (seven items, lines 44-50 at planning time). This plan names them AC-1 through AC-7 in their order of appearance.
- **Design input (not a requirements source):** `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/research/research.2026-10-11T13-50.md`. Every line number, count, and test name this plan takes from it was re-derived against the current tree at planning time.
- **Operator approval:** the operator approved, for this item only, editing `.claude/rules/parallel-orchestration.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md`, and their three bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`. The approval is recorded in `issue.md`, section `## Operator Approval`. No other file under `.claude/rules/` or `.github/instructions/` may be edited.

**Mode note (minor-audit):** `spec.md` and `user-story.md` must not exist in the feature folder and are not required. Only the `## Acceptance Criteria` section of `issue.md` is the acceptance-criteria source. Execution fails closed if `spec.md` or `user-story.md` appears in the feature folder, if the `## Acceptance Criteria` section is missing from `issue.md`, if a required Phase 0 artifact is missing or incomplete, or if checklist state contradicts evidence on disk.

**Fail-closed evidence rule:** Every Phase 0 baseline command and every Phase 2 final-QC command has its own artifact. If any required artifact is missing or lacks a required field, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Coverage statement (not applicable, with reason):** this plan changes no production source file. The changed files are six Markdown rule files and one test module, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`. The coverage configuration in `pyproject.toml` (`[tool.coverage.run]`, `source = ["src", "scripts/dev_tools"]`, `omit` includes `tests/*`) measures only `src` and `scripts/dev_tools`, so no changed line is inside the coverage denominator and there are no changed production lines whose coverage could regress. No coverage percentage is asserted and no coverage command is planned. The mechanical proof is the scope check P2-T11, which requires that no path under `src/` or `scripts/` changes. If P2-T11 reports any path under `src/` or `scripts/`, this statement no longer holds and the plan stops for the caller.

**Evidence accounting rule:** every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. When a task runs several commands, the top-level `EXIT_CODE:` is the exit code of the task's last listed command, and every other command's exit code and printed value are recorded inside `Output Summary:`. No planned command task may record `EXIT_CODE: SKIPPED`.

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no override was recorded.
- TS means the execution time of the task in yyyy-MM-ddTHH-mm form, read from the host clock.
- BRANCH means `bug/product-name-examples-remain-in-generic-rules-894`.
- MERGE_BASE means the commit printed by `git merge-base origin/main HEAD` in P0-T3. Every scope diff is anchored to MERGE_BASE, because `origin/main` can advance during execution.
- MIRROR means the directory `extensions/drm-copilot/resources/claude-customizations/.claude/rules`.
- SIX-RULES means these six files, in this order: `.claude/rules/parallel-orchestration.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`.
- GUARD means `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
- REGRESSION-SET means these six pytest files, in this order: `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`, `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`, `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py`.
- Appendix A holds the exact rule-file edits. Appendix B holds the exact test-module edits.

## Execution constraints

- No PowerShell file and no bats file is in scope. No task runs a shell-interpreter wrapper (no `sh`, no `bash`, no `pwsh` command) and no command text begins with an interpreter name. Were PowerShell verification ever needed, it would use the PoshQC MCP tools plus CI evidence only; none is needed here. Files are written with the Write or Edit tools; mirrors are written with the Edit tool only.
- Local tools used: `git` (including `git grep --no-index`, `git ls-files`, `git diff --no-index`) and `poetry run` (black, ruff, pyright, pytest). `grep`, `wc`, `cp` and `ls` are not in the Bash allowlist and are not used. No command pipes one tool into another.
- No scratch or helper file is used. If one becomes unavoidable, its name must contain `894` (for example under a `SCRATCH/894/` directory or with an `-894` suffix) and it must live outside the repository; a fixed shared name is not permitted.
- Commit and push at every phase boundary (P0-T13, P1-T17, P2-T22): `git add` of explicit paths only, `git commit`, `git push origin bug/product-name-examples-remain-in-generic-rules-894`. Never force-push. Delete nothing (no `git rm`, no file deletion). Create no GitHub issue.
- Tests create no temporary files. The new negative tests use in-memory dictionaries and strings only.
- Hooks. If a hook or guard denies a command, stop and report the denial text. Do not bypass it and do not substitute another command.
- Search scoping. Any search asserting zero matches for `TaskMaster` or `No-COM` is scoped to SIX-RULES only. Classifier test data elsewhere intentionally keeps `src/TaskMaster.Domain` (`tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` and `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`; out of scope per `issue.md`). GUARD itself contains both tokens as test data after P1-T6 and is not searched for them.
- Every search uses `git grep --no-index ... -- <paths>`. It reads the named working-tree files whether they are tracked, modified or untracked. Plain `grep` is not used. With `-c`, `git grep` omits files that have zero matches. When nothing matches, or when a path is misspelled, it prints nothing and exits 1. Every zero-match assertion is therefore paired with a positive command on the same files. Patterns that begin with a hyphen, and multiple patterns, are passed with `-e`. A single-file search passes `-h`, so its output carries no path prefix.
- Output order. A multi-file `git grep --no-index` search is not guaranteed to print its files in the order the pathspecs are given, so every multi-file acceptance condition below names each expected line by path and value and does not depend on line order.
- 500-line limit. The limit in `.claude/rules/general-code-change.md` (section "File Size Limit") applies to production code, test code, and reusable scripts and exempts Markdown documentation files. AC-7's "no changed file exceeds 500 lines" is therefore checked against GUARD, the only changed code file (issue verification step 8 names this one file). The six rule files are Markdown; their line counts are recorded as information only.

## Recorded design decisions

- D1 — Placeholder for the dotted-directory example: `src/<Product>.Domain`, matching `.claude/rules/architecture-boundaries.md:40` (`<Product>.Domain`). The example is kept because the token shape is hard to recognize without one (research section A.1).
- D2 — The #797 CR-2 fix uses the research's recommended option: item 7 leaves the numbered write-intent list and becomes a separate four-line paragraph after item 6 and before "Three mitigations bound these cases:". The new paragraph begins with the literal "The file-shape classifier, which runs before write-intent extraction, drops one further case". Item 6 becomes the last list item and keeps its terminal period. The paragraph is wrapped at or under 100 columns, matching the surrounding prose.
- D3 — The `typescript.md` cross-reference names the exact current heading: "Host-Neutral Architecture Rules (enforceable assertions)" (`.claude/rules/architecture-boundaries.md:17`).
- D4 — The guard keeps the exact-count design of research section F: `PINNED_NAME_OCCURRENCES: dict[str, int] = {}`, pure helpers `count_name_occurrences`, `pinned_count_mismatches`, and `stale_pinned_entries`, a real-tree count test, a real-tree staleness test, and in-memory negative tests. Adding `stale_pinned_entries` as a pure helper lets a negative test prove that the staleness check can fail, which a vacuous pass over an empty map cannot show.
- D5 — Test counts. GUARD has 43 collected tests at planning time (41 kept plus the 2 replaced). After Phase 1 it has 50: the 41 kept, 2 real-tree replacements, and 5 new single tests and 1 parametrized test with 2 cases (6 new functions, 7 new collected tests); 41 + 2 + 7 = 50. Between P1-T6 and the rule edits exactly 1 test fails: `test_pushed_rule_and_skill_files_match_pinned_name_counts`.
- D6 — Mirrors are produced by applying the identical Appendix A edits to the mirror with the Edit tool. P0-T5 proves the pairs are identical before any edit, so identical edits keep them identical. Identity is verified by `git diff --no-index --exit-code` for each pair and by the bundle parity test.

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Verify the minor-audit preconditions for FEATURE (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `git grep --no-index -h -c "^## Acceptance Criteria$" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "Work Mode: minor-audit" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git ls-files --cached --others -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894`.
      Acceptance: the first two searches each print 1; the third prints 10 (seven AC lines and three Evidence Checklist lines); the fourth prints nothing and exits 1 (the pass condition here; the third search, on the same file, proves the path exists); the listing contains neither `spec.md` nor `user-story.md`. Any other result stops the plan. `git ls-files` is the last command, so the top-level `EXIT_CODE:` is its exit code.
- [x] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/python.md`; (5) `.claude/rules/python-suppressions.md`.
      Acceptance: the artifact has the three required headers and lists all 5 files in that order.
- [x] [P0-T3] Record the branch, MERGE_BASE, and the clean pre-edit state of every repository path this plan edits, and record FEATURE/evidence/baseline/merge-base.TS.md.
      Commands: `git fetch origin main`; `git branch --show-current`; `git rev-parse HEAD`; `git merge-base origin/main HEAD`; `git diff --name-only MERGE_BASE -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (substitute the SHA printed by the merge-base command for MERGE_BASE); `git status --porcelain --untracked-files=all -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the branch printed equals BRANCH; `git rev-parse HEAD` and the merge-base each print one 40-character SHA, the latter recorded as MERGE_BASE; the anchored diff prints nothing; the status command prints nothing. Any other output stops the plan, because the baseline would not measure the committed state.
- [x] [P0-T4] Baseline product-name token counts over SIX-RULES (`.claude/rules/`, MIRROR) and record FEATURE/evidence/baseline/token-counts.TS.md.
      Command: `git grep --no-index -c -F -e TaskMaster -e No-COM -- .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`.
      Acceptance: exit 0; exactly six `path:count` lines, one per SIX-RULES path, in any order: each `parallel-orchestration.md` copy with count 1, each `typescript.md` copy with count 1, each `csharp.md` copy with count 2 (planning-time lines: `parallel-orchestration.md:411`, `typescript.md:57`, `csharp.md:5` and `:10`, identical in the mirrors). Any other count, or a missing path, stops the plan.
- [x] [P0-T5] Baseline mirror byte identity for the three source and mirror pairs and record FEATURE/evidence/baseline/mirror-identity.TS.md.
      Commands: `git diff --no-index --exit-code .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; `git diff --no-index --exit-code .claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`; `git diff --no-index --exit-code .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`; `git status --porcelain -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules`.
      Acceptance: each `git diff --no-index --exit-code` exits 0 and prints nothing (it prints a diff and exits 1 only when the pair differs); the status command prints nothing. An unequal pair stops the plan, because identical later edits would then not produce identical files.
- [x] [P0-T6] Baseline line count of GUARD (`tests/scripts/dev_tools/`) and record FEATURE/evidence/baseline/line-counts.TS.md.
      Command: `git grep --no-index -h -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0; prints the line count (planning-time 356), recorded as BASE_LINES_GUARD. A value above 400 stops the plan, because the planned net growth of 106 lines would then approach the 500-line limit.
- [x] [P0-T7] Baseline format check of GUARD in read-only mode and record FEATURE/evidence/baseline/python-black-check.TS.md.
      Command: `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the exit code and output are recorded. A clean file prints output containing the literal "1 file would be left unchanged" and exits 0 (observed at line 13 of the issue #824 pass-after follow-ups pytest artifact dated 2026-10-10T00-09, where the literal appears in parentheses, and in the round-1 preflight's direct `--check` run on GUARD, which printed "1 file would be left unchanged." with a trailing period). `--check` writes nothing. A non-zero exit is recorded verbatim as pre-existing drift that P2-T1 must clear.
- [x] [P0-T8] Baseline lint of GUARD and record FEATURE/evidence/baseline/python-ruff.TS.md.
      Command: `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the exit code and output are recorded. No `--fix` flag is passed, so the command writes nothing. A clean run prints the literal "All checks passed!" and exits 0. Each finding line is recorded verbatim as pre-existing.
- [x] [P0-T9] Baseline type check of GUARD and record FEATURE/evidence/baseline/python-pyright.TS.md.
      Command: `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the exit code and the summary line are recorded. A clean run prints the literal "0 errors, 0 warnings, 0 informations" and exits 0; version or venv notices are not diagnostics and are recorded as notes.
- [x] [P0-T10] Baseline GUARD pytest run and record FEATURE/evidence/baseline/python-pytest-guard.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q`.
      Acceptance: exit 0 and the summary line reads `43 passed` (planning-time static count; the observed count is authoritative and recorded as BASE_GUARD_N). Any failure stops the plan, because the fail-before step P1-T7 depends on a green starting point. `Output Summary:` also states "Coverage: not applicable (see the plan's coverage statement)".
- [x] [P0-T11] Baseline bundle parity pytest (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) and record FEATURE/evidence/baseline/python-pytest-bundle-parity.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.
      Acceptance: the exit code and the summary line are recorded; a clean run prints `N passed` and exits 0, with N recorded as BASE_PARITY_N. A failure whose only failing node is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, whose assertion message begins with the literal "Repo file missing from bundle:", and whose named path makes `git check-ignore -q` exit 0, is the known local issue #510: the artifact records `KL-510: STATE-ONLY` and `ExpectedExitCode: 1`. Any other failure stops the plan.
- [x] [P0-T12] Baseline REGRESSION-SET pytest run (`tests/scripts/dev_tools/`) and record FEATURE/evidence/baseline/python-pytest-regression-set.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -q`.
      Acceptance: the exit code, the summary line, and every `FAILED` line printed by the `-ra` summary are recorded. The passed count is BASE_RS_PASSED and the `FAILED` node set is BASE_RS_FAILED (expected empty). A non-empty BASE_RS_FAILED is recorded with `ExpectedExitCode: 1` and reported to the caller; it does not stop the plan, and P2-T8 is judged against it.
- [x] [P0-T13] Phase 0 boundary commit and push of the Phase 0 evidence and feature documents, and record FEATURE/evidence/other/commit-phase-0.TS.md. Before staging, change this task's own checkbox to `- [x]`; if the commit or push fails, revert that checkbox to `- [ ]` and stop.
      Commands: `git add docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/evidence docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/research/research.2026-10-11T13-50.md`; `git commit -m "chore(894): record Phase 0 baseline evidence"`; `git push origin bug/product-name-examples-remain-in-generic-rules-894`; `git status --porcelain -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894`; `git rev-parse HEAD`; `git rev-parse origin/bug/product-name-examples-remain-in-generic-rules-894`.
      Acceptance: the commit and the push each exit 0; the status command prints nothing; the two `git rev-parse` values are equal. The artifact is written after the push, so it is committed by P1-T17. No force flag is used.

### Phase 1 — Constrained Small-Path Implementation

This phase is one delegated handoff. The small-path implementation engineer performs P1-T2 through P1-T17 in order. No implementation is performed during planning. Each of P1-T2 through P1-T6 and P1-T8 through P1-T15 writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number) recording its commands, exit codes, and output summary. P1-T7 and P1-T16 write the regression-testing artifacts named in those tasks, and P1-T17 writes the artifact named in it. The exact text of every edit is in Appendix A and Appendix B. Order matters: the guard rewrite (P1-T2 through P1-T6) and its fail-before run (P1-T7) precede every rule edit (P1-T8 through P1-T15).

- [x] [P1-T1] Delegated implementation handoff: apply P1-T2 through P1-T17 to GUARD and SIX-RULES only, and record FEATURE/evidence/other/p1-t1.TS.md with the engineer's completion report (no `EXIT_CODE:` line, because P1-T1 runs no command).
      Constraints: apart from evidence artifacts under FEATURE/evidence/ and checklist state in the plan file (Write list item 9), the seven code and rule files of the Write list (items 1-7) are the only repository files edited; no other file under `.claude/rules/` or `.github/instructions/` is edited; `paths:` in `csharp.md` is not changed; mirrors are produced by the Edit tool applying the identical Appendix A edit; no shell copy and no whole-file Write; no temporary files in tests; no deletion; no force-push.
      Acceptance: every acceptance condition of P1-T2 through P1-T17 holds.
- [x] [P1-T2] Edit the module docstring of GUARD (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`): replace docstring lines 9-11 with the three lines of edit B1 in Appendix B. Line 8 and every other docstring line stay unchanged.
      Commands: `git grep --no-index -h -c -F "PRE_EXISTING_NAME_EXCEPTIONS" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F "PINNED_NAME_OCCURRENCES" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the first search prints 3 (it printed 4 before the edit; the remaining hits are the constant and its two test uses); the second prints 1; the line count equals BASE_LINES_GUARD.
- [x] [P1-T3] Replace the `PRE_EXISTING_NAME_EXCEPTIONS` block of GUARD (the three comment lines and the `frozenset` assignment, planning-time lines 107-120) with the five lines of edit B2 in Appendix B. The constant line is `PINNED_NAME_OCCURRENCES: dict[str, int] = {}`.
      Commands: `git grep --no-index -h -c -F "PRE_EXISTING_NAME_EXCEPTIONS" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F "PINNED_NAME_OCCURRENCES: dict[str, int] = {}" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the first search prints 2; the second prints 1; the line count equals BASE_LINES_GUARD minus 9.
- [x] [P1-T4] Add the three pure helpers of edit B3 in Appendix B to GUARD, immediately after `pushed_rule_and_skill_files` and before `step_eight`, separated by two blank lines: `count_name_occurrences`, `pinned_count_mismatches`, `stale_pinned_entries`.
      Commands: `git grep --no-index -h -c -F -e "def count_name_occurrences(" -e "def pinned_count_mismatches(" -e "def stale_pinned_entries(" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the search prints 3; the line count equals BASE_LINES_GUARD plus 25 (minus 9 from P1-T3, plus 34).
- [x] [P1-T5] Replace the two tests `test_pushed_rule_and_skill_files_name_no_consuming_product` and `test_name_exceptions_still_name_a_consuming_product` in GUARD with the two tests of edit B4 in Appendix B: `test_pushed_rule_and_skill_files_match_pinned_name_counts` and `test_pinned_name_entries_are_pushed_files_with_positive_counts`.
      Commands: `git grep --no-index -h -c -F "PRE_EXISTING_NAME_EXCEPTIONS" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F -e "def test_name_exceptions_still_name_a_consuming_product" -e "def test_pushed_rule_and_skill_files_name_no_consuming_product" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F -e "def test_pushed_rule_and_skill_files_match_pinned_name_counts" -e "def test_pinned_name_entries_are_pushed_files_with_positive_counts" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F "PINNED_NAME_OCCURRENCES" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the first search prints nothing and exits 1; the second prints nothing and exits 1; the third prints 2; the fourth prints 4 (docstring, constant, and one use in each new test). The third and fourth searches name the same file, so they prove the path in the first two is correct. The top-level `EXIT_CODE:` is the last search's (0).
- [x] [P1-T6] Append the six in-memory negative and helper tests of edit B5 in Appendix B to the end of GUARD, in this order: `test_pinned_count_mismatches_flags_new_occurrence_in_unpinned_file`, `test_pinned_count_mismatches_flags_new_occurrence_in_pinned_file`, `test_pinned_count_mismatches_flags_removed_occurrence_in_pinned_file`, `test_pinned_count_mismatches_accepts_matching_counts`, `test_count_name_occurrences_counts_every_token` (parametrized, 2 cases), `test_stale_pinned_entries_flags_unscanned_path_and_non_positive_pin`.
      Commands: `git grep --no-index -h -c "^def test_" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c -F -e "tmp_path" -e "tempfile" -e "write_text" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep --no-index -h -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the first search prints 17 (11 test functions before this plan, minus 2 replaced, plus 2, plus 6); the second prints nothing and exits 1 (no temporary-file use; the pass condition here; the first and third searches prove the path exists); the line count equals BASE_LINES_GUARD plus 106 (planning-time value 462) and is at most 500.
- [x] [P1-T7] [expect-fail] Fail-before run of GUARD before any rule edit, and record FEATURE/evidence/regression-testing/expect-fail-pinned-name-counts.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules`; `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q`.
      Acceptance: the status command prints nothing (no rule file or mirror has changed yet); pytest exits 1 and its summary line reads `1 failed, 49 passed`; the only `FAILED` line names `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_rule_and_skill_files_match_pinned_name_counts`; the assertion output contains each of these six messages: ".claude/rules/csharp.md: observed 2, pinned 0", ".claude/rules/parallel-orchestration.md: observed 1, pinned 0", ".claude/rules/typescript.md: observed 1, pinned 0", and the same three messages prefixed with `extensions/drm-copilot/resources/claude-customizations/`. Every other new test passes. Any other split stops the plan. The top-level `EXIT_CODE:` is the pytest exit code (1).
- [x] [P1-T8] Edit `.claude/rules/parallel-orchestration.md` line 411 per edit A1 in Appendix A: replace the inline-code token `src/TaskMaster.Domain` with `src/<Product>.Domain`. No other character on the line changes.
      Commands: `git grep --no-index -h -c -F "TaskMaster" -- .claude/rules/parallel-orchestration.md`; `git grep --no-index -h -n -F "src/<Product>.Domain" -- .claude/rules/parallel-orchestration.md`.
      Acceptance: the first search prints nothing and exits 1 (it printed 1 before the edit); the second prints exactly one line, numbered `411:`, which also proves the path searched by the first exists.
- [x] [P1-T9] Edit `.claude/rules/parallel-orchestration.md` "Known false negatives" per edit A2 in Appendix A: replace the single item-7 line (planning-time line 567, beginning with the literal "7. a genuine file cited only as a separator-free bare file name") with one blank line followed by the four-line paragraph of A2. Item 6 (line 566) and the lead-in "Write-intent extraction can drop a genuine write in these cases:" (line 559) stay unchanged.
      Commands: `git grep --no-index -h -c -F "7. a genuine file" -- .claude/rules/parallel-orchestration.md`; `git grep --no-index -h -n -F -e "placeholder set (W6)." -e "drops one further case" -e "Three mitigations bound these cases:" -- .claude/rules/parallel-orchestration.md`.
      Acceptance: the first search prints nothing and exits 1; the second prints exactly three lines in this order: `566:` (item 6), `568:` (the first paragraph line, containing "drops one further case"), and `573:` (the mitigations lead-in, which was line 569 before the edit). The top-level `EXIT_CODE:` is the second search's (0).
- [x] [P1-T10] Edit `.claude/rules/typescript.md` line 57 so the line equals edit A3 in Appendix A exactly: "the No-COM architecture assertions" becomes "the host-neutral architecture assertions", and the cross-reference names the current heading "Host-Neutral Architecture Rules (enforceable assertions)". The second sentence of the line is unchanged.
      Commands: `git grep --no-index -h -c -F "No-COM" -- .claude/rules/typescript.md`; `git grep --no-index -n -F "Host-Neutral Architecture Rules (enforceable assertions)" -- .claude/rules/typescript.md .claude/rules/architecture-boundaries.md`.
      Acceptance: the first search prints nothing and exits 1; the second prints exactly two lines, in any order, one beginning `.claude/rules/typescript.md:57:` and one beginning `.claude/rules/architecture-boundaries.md:17:`. The top-level `EXIT_CODE:` is the second search's (0).
- [x] [P1-T11] Edit `.claude/rules/csharp.md` line 5 (frontmatter `description`) per edit A4 in Appendix A, so it reads `description: C#-specific toolchain and coding standards (xUnit).` Lines 1-4 and 6 (including `paths:`) are unchanged.
      Commands: `git grep --no-index -h -n -F "standards (xUnit)." -- .claude/rules/csharp.md`; `git grep --no-index -h -n -F "paths:" -- .claude/rules/csharp.md`; `git diff MERGE_BASE -- .claude/rules/csharp.md` (substitute the SHA recorded by P0-T3).
      Acceptance: the first search prints exactly one line, numbered `5:`; the second prints exactly `2:paths:`, as before the edit; the anchored diff shows one hunk in which the only removed line is the old line 5 and the only added line is the new line 5 (lines 2-4 unchanged). The top-level `EXIT_CODE:` is the diff's (0).
- [x] [P1-T12] Edit `.claude/rules/csharp.md` line 10 per edit A5 in Appendix A: replace "the No-COM .NET foundation" with "a host-neutral .NET foundation". No other character on the line changes.
      Commands: `git grep --no-index -h -c -F "No-COM" -- .claude/rules/csharp.md`; `git grep --no-index -h -n -F "a host-neutral .NET foundation" -- .claude/rules/csharp.md`.
      Acceptance: the first search prints nothing and exits 1 (it printed 2 before P1-T11); the second prints exactly one line, numbered `10:`, which also proves the path searched by the first exists.
- [x] [P1-T13] Read the mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`, then apply edits A1 and A2 of Appendix A to it with the Edit tool, using the same old_string and new_string as P1-T8 and P1-T9.
      Commands: `git diff --no-index --exit-code .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`.
      Acceptance: the no-index diff exits 0 and prints nothing (this is the identity observation; the Edit tool's own result is not the pass signal); the status shows the mirror as modified (` M`).
- [x] [P1-T14] Read the mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`, then apply edit A3 of Appendix A to it with the Edit tool, using the same old_string and new_string as P1-T10.
      Commands: `git diff --no-index --exit-code .claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`.
      Acceptance: the no-index diff exits 0 and prints nothing (this is the identity observation; the Edit tool's own result is not the pass signal); the status shows the mirror as modified (` M`).
- [x] [P1-T15] Read the mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`, then apply edits A4 and A5 of Appendix A to it with the Edit tool, using the same old_string and new_string as P1-T11 and P1-T12.
      Commands: `git diff --no-index --exit-code .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`; `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`.
      Acceptance: the no-index diff exits 0 and prints nothing (this is the identity observation; the Edit tool's own result is not the pass signal); the status shows the mirror as modified (` M`).
- [x] [P1-T16] Pass-after run of GUARD after every rule and mirror edit, and record FEATURE/evidence/regression-testing/pass-after-pinned-name-counts.TS.md.
      Commands: `git ls-files --error-unmatch -- .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`; `git grep --no-index -c -F -e TaskMaster -e No-COM -- .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q`.
      Acceptance: `git ls-files --error-unmatch` exits 0 and lists all six paths; the search prints nothing and exits 1 (the pass condition here); pytest exits 0 and its summary line reads `50 passed`, including `test_pushed_rule_and_skill_files_match_pinned_name_counts`, which failed in P1-T7. The top-level `EXIT_CODE:` is the pytest exit code (0).
- [x] [P1-T17] Phase 1 boundary commit and push of GUARD, SIX-RULES, and the Phase 0 and Phase 1 evidence, and record FEATURE/evidence/other/commit-phase-1.TS.md. Before staging, change this task's own checkbox to `- [x]`; if the commit or push fails, revert that checkbox to `- [ ]` and stop.
      Commands: `git add tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/evidence docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md`; `git commit -m "fix(894): neutralize product names in pushed rules and pin guard counts"`; `git push origin bug/product-name-examples-remain-in-generic-rules-894`; `git status --porcelain -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git rev-parse HEAD`; `git rev-parse origin/bug/product-name-examples-remain-in-generic-rules-894`.
      Acceptance: the commit and the push each exit 0; the status command prints nothing; the two `git rev-parse` values are equal. No force flag is used.

### Phase 2 — Final QC Loop, Targeted Verification, and End State

Run the Python toolchain in this order: format (P2-T1), lint (P2-T2), type check (P2-T3), then the tests (P2-T4 through P2-T8). If any of P2-T1 through P2-T8 fails, or if its remediation changes any file, the small-path engineer remediates, applies any remediation edit to a source rule file identically to its mirror with the Edit tool and re-runs that pair's identity commands from P1-T13 through P1-T15, and restarts from P2-T1. The loop ends only when P2-T1 through P2-T8 all pass in one pass with no file changed. Every Phase 2 command task is unconditional; none has a SKIPPED outcome. Artifacts go to FEATURE/evidence/qa-gates/ unless stated. Every pytest command in this phase runs after P1-T8 through P1-T15, so no test added red by P1-T6 can be failing when it runs.

- [x] [P2-T1] Format GUARD with black in write mode and record FEATURE/evidence/qa-gates/python-black.TS.md.
      Command: `poetry run black tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and the output contains the literal "1 file left unchanged" (observed at line 13 of the issue #824 artifact described in P0-T7). This literal, not the exit code, is the pass signal, because black also exits 0 after rewriting. If the output instead contains "reformatted", black changed the file: record it and restart from P2-T1.
- [x] [P2-T2] Lint GUARD with ruff and record FEATURE/evidence/qa-gates/python-ruff.TS.md.
      Command: `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and the output is the literal "All checks passed!". No `--fix` flag is passed. No suppression comment is added (`.claude/rules/python-suppressions.md`).
- [x] [P2-T3] Type-check GUARD with pyright (strict mode per `pyproject.toml`) and record FEATURE/evidence/qa-gates/python-pyright.TS.md.
      Command: `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and the summary line is the literal "0 errors, 0 warnings, 0 informations".
- [x] [P2-T4] Run the full GUARD module and record FEATURE/evidence/qa-gates/python-pytest-guard.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q`.
      Acceptance: exit 0 and the summary line reads `50 passed` (BASE_GUARD_N plus 7). `Output Summary:` also states "Coverage: not applicable (see the plan's coverage statement)".
- [x] [P2-T5] Run the named guard, staleness, and negative test nodes for AC-6 and record FEATURE/evidence/qa-gates/python-pytest-guard-named-nodes.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_rule_and_skill_files_match_pinned_name_counts tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pinned_name_entries_are_pushed_files_with_positive_counts tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pinned_count_mismatches_flags_new_occurrence_in_unpinned_file tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pinned_count_mismatches_flags_new_occurrence_in_pinned_file tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pinned_count_mismatches_flags_removed_occurrence_in_pinned_file tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_stale_pinned_entries_flags_unscanned_path_and_non_positive_pin -v`.
      Acceptance: exit 0; the summary line reads `6 passed`; each of the six node IDs appears on its own `PASSED` line.
- [x] [P2-T6] Run the bundle parity module for AC-5 (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) and record FEATURE/evidence/qa-gates/python-pytest-bundle-parity.TS.md.
      Commands: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`.
      Acceptance, case (a): both exit 0; the first prints `1 passed`; the second prints `N passed` with N equal to BASE_PARITY_N; the artifact records `KL-510: PASSED`. Case (b), only if P0-T11 recorded `KL-510: STATE-ONLY`: the only failing node in both runs is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, its message begins with the literal "Repo file missing from bundle:" and names the same path recorded by P0-T11, and no output line contains the literal "Bundle content differs from repo for:"; the artifact records `KL-510: STATE-ONLY` with `ExpectedExitCode: 1`. Any other outcome fails the task. P2-T7 is the direct byte-identity proof in either case.
- [x] [P2-T7] Mirror byte identity for AC-5 over the three source and mirror pairs and record FEATURE/evidence/qa-gates/mirror-identity.TS.md.
      Commands: the three `git diff --no-index --exit-code` commands of P0-T5; `git status --porcelain -- .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules`.
      Acceptance: each no-index diff exits 0 and prints nothing. The status prints nothing after the P1-T17 commit, or, if a remediation edit is pending, lists only SIX-RULES paths.
- [x] [P2-T8] Run REGRESSION-SET (`tests/scripts/dev_tools/`) and record FEATURE/evidence/qa-gates/python-pytest-regression-set.TS.md.
      Command: the P0-T12 command.
      Acceptance: the passed count equals BASE_RS_PASSED and the `FAILED` node set equals BASE_RS_FAILED (expected empty, exit 0). Any `FAILED` node outside BASE_RS_FAILED fails the task.
- [x] [P2-T9] Structural checks for AC-1 through AC-4 over SIX-RULES and record FEATURE/evidence/qa-gates/structural-checks.TS.md.
      Commands, run in this order: (1) `git grep --no-index -c -F -e TaskMaster -e No-COM -- .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`; (2) `git grep --no-index -n -F "src/<Product>.Domain" -- .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; (3) `git grep --no-index -n -F -e "placeholder set (W6)." -e "drops one further case" -e "Three mitigations bound these cases:" -e "7. a genuine file" -- .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; (4) `git grep --no-index -n -F "Host-Neutral Architecture Rules (enforceable assertions)" -- .claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md .claude/rules/architecture-boundaries.md`; (5) `git grep --no-index -n -F -e "standards (xUnit)." -e "a host-neutral .NET foundation" -- .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`.
      Acceptance (line order within each output is not asserted): (1) prints nothing and exits 1 (the pass condition here); the existence of all six files for (1) is proven by (2), (4) and (5), which each print a line from every file they name; (2) prints two lines, one per file, each at line `411`; (3) prints six lines, three per file, at lines `566` (item 6), `568` (the new paragraph), and `573` (the mitigations lead-in), and no line containing "7. a genuine file"; (4) prints three lines: the two `typescript.md` copies at line `57` and `architecture-boundaries.md` at line `17`; (5) prints four lines: each `csharp.md` copy at line `5` (description) and line `10` (foundation sentence). The top-level `EXIT_CODE:` is that of command (5) (0); the exit code of (1) is recorded in `Output Summary:` with its pass meaning.
- [x] [P2-T10] Line limit for AC-7 over GUARD (`tests/scripts/dev_tools/`), with the rule files recorded for information, and record FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `git grep --no-index -c "" -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md`.
      Acceptance: exit 0; four `path:N` lines, one per named file, in any order; the GUARD count is at most 500 and equals the P1-T6 count unless P2-T1 reformatted the file (planning-time value 462). The three Markdown counts are recorded as information under the Markdown exemption of `.claude/rules/general-code-change.md` (section "File Size Limit").
- [x] [P2-T11] Scope check against the Write list (`.claude/rules`, `.claude/skills`, `.claude/agents`, `.claude/hooks`, `extensions`, `tests`, `scripts`, `src`, `.github`) and record FEATURE/evidence/qa-gates/scope.TS.md.
      Commands: `git diff --name-only MERGE_BASE -- .claude/rules .claude/skills .claude/agents .claude/hooks extensions tests scripts src .github` (substitute the SHA recorded by P0-T3); `git status --porcelain --untracked-files=all -- .claude/rules .claude/skills .claude/agents .claude/hooks extensions tests scripts src .github`.
      Acceptance: the union of the paths listed by the two commands equals exactly the seven repository files of the Write list (SIX-RULES and GUARD), and each appears. No path under `src/` or `scripts/` appears, which is the mechanical proof of the coverage statement. No other `.claude/rules/` file and no `.github/instructions/` file appears. The pathspec leaves out `.claude/agent-memory`, which other agents may write during the run.
- [x] [P2-T12] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-1 (line 44), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-1.TS.md. Evidence required before the edit: P1-T8, P1-T13, P2-T9 checks (1) and (2).
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly one line, numbered `44:`; the second prints 9.
- [x] [P2-T13] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-2 (line 45), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-2.TS.md. Evidence required before the edit: P1-T10, P1-T11, P1-T12, P1-T14, P1-T15, P2-T9 checks (1) and (5).
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly two lines, numbered `44:` and `45:`; the second prints 8.
- [x] [P2-T14] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-3 (line 46), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-3.TS.md. Evidence required before the edit: P1-T10, P1-T14, P2-T9 check (4).
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly three lines, numbered `44:` through `46:`; the second prints 7.
- [x] [P2-T15] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-4 (line 47), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-4.TS.md. Evidence required before the edit: P1-T9, P1-T13, P2-T9 check (3).
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly four lines, numbered `44:` through `47:`; the second prints 6.
- [x] [P2-T16] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-5 (line 48), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-5.TS.md. Evidence required before the edit: P1-T13 through P1-T15, P2-T6, P2-T7.
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly five lines, numbered `44:` through `48:`; the second prints 5.
- [x] [P2-T17] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-6 (line 49), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-6.TS.md. Evidence required before the edit: P1-T2 through P1-T7 (fail-before), P1-T16 (pass-after), P2-T4, P2-T5.
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly six lines, numbered `44:` through `49:`; the second prints 4.
- [x] [P2-T18] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) to check off AC-7 (line 50), changing only `- [ ]` to `- [x]` on that line, and record FEATURE/evidence/other/ac-checkoff-ac-7.TS.md. Evidence required before the edit: P2-T1, P2-T2, P2-T3, P2-T4, P2-T6, P2-T10, all from the same clean loop pass.
      Commands: `git grep --no-index -h -n -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints exactly seven lines, numbered `44:` through `50:`; the second prints 3.
- [x] [P2-T19] Edit FEATURE/issue.md (`docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`) section `## Evidence Checklist` to check off its three items (baseline, targeted verification, end-state; lines 85-87), changing only `- [ ]` to `- [x]` on those lines, and record FEATURE/evidence/other/evidence-checklist.TS.md. Evidence required: the Phase 0 baseline artifacts (baseline), P1-T7 and P1-T16 (targeted verification), P2-T1 through P2-T11 (end-state).
      Commands: `git grep --no-index -h -c -F "[x]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`; `git grep --no-index -h -c -F "[ ]" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`.
      Acceptance: the first search prints 10, which also proves the path exists; the second prints nothing and exits 1 (the pass condition here). The artifact's top-level `EXIT_CODE:` is 1 with `ExpectedExitCode: 1`.
- [x] [P2-T20] Reduced-audit handoff: record FEATURE/evidence/other/small-audit-handoff.TS.md listing AC-1 through AC-7, each with the artifact paths that evidence it per the traceability table below. The orchestrator then delegates the minor-audit review with that file as its evidence index.
      Command: `git ls-files --cached --others -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/evidence`.
      Acceptance: exit 0 and every artifact path named in the handoff file appears in the listing.
- [x] [P2-T21] Update `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md` so its checklist state matches the evidence on disk: change `- [ ]` to `- [x]` for each of P0-T1 through P2-T20 whose artifact exists with every required field, and for no other task. Record FEATURE/evidence/other/plan-checklist-state.TS.md, then check off this task.
      Commands: `git grep --no-index -h -c "^- \[x\] \[P" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md`; `git grep --no-index -h -c "^- \[ \] \[P" -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md`.
      Acceptance, measured before this task checks itself off: the first search prints 50 (P0-T1 through P2-T20); the second prints 2 (this task and P2-T22). Any mismatch means an artifact is missing or incomplete, and the unchecked task is named in the artifact.
- [x] [P2-T22] Phase 2 boundary commit and push of the final evidence, `issue.md`, and the plan. This task writes no evidence artifact, so the tree stays clean after the push; its evidence is the pushed commit itself, and the executor's final report records the commit SHA, the push exit code, and both `git rev-parse` values. Before staging, change this task's own checkbox to `- [x]`; if the commit or push fails, revert that checkbox to `- [ ]` and stop. The seven code and rule paths are staged so that any Phase 2 remediation edit is committed; staging an unchanged tracked path stages nothing.
      Commands: `git add tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py .claude/rules/parallel-orchestration.md .claude/rules/typescript.md .claude/rules/csharp.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/evidence docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md`; `git commit -m "docs(894): record final QC evidence and check off acceptance criteria"`; `git push origin bug/product-name-examples-remain-in-generic-rules-894`; `git status --porcelain -- docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894 .claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/rules tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git rev-parse HEAD`; `git rev-parse origin/bug/product-name-examples-remain-in-generic-rules-894`.
      Acceptance: the commit and the push each exit 0; the status command prints nothing; the two `git rev-parse` values are equal. No force flag is used. The executor's final report quotes the commit SHA and the push result.

## Acceptance-criteria traceability

| AC | Criterion (abridged, `issue.md` line) | Implementation | Tests | Evidence |
| --- | --- | --- | --- | --- |
| AC-1 | `src/TaskMaster.Domain` removed from `parallel-orchestration.md` and its mirror; placeholder `src/<Product>.Domain` (line 44) | P1-T8, P1-T13 | GUARD `test_pushed_rule_and_skill_files_match_pinned_name_counts` | other/p1-t8, other/p1-t13, regression-testing/pass-after-pinned-name-counts, qa-gates/structural-checks |
| AC-2 | `No-COM` removed from `typescript.md` and `csharp.md` (including the frontmatter `description`) and their mirrors; neutral wording (line 45) | P1-T10, P1-T11, P1-T12, P1-T14, P1-T15 | GUARD `test_pushed_rule_and_skill_files_match_pinned_name_counts`; REGRESSION-SET (`test_claude_rules_frontmatter.py`) | other/p1-t10, other/p1-t11, other/p1-t12, qa-gates/structural-checks, qa-gates/python-pytest-regression-set |
| AC-3 | `typescript.md` cross-reference names the current "Host-Neutral Architecture Rules" heading (line 46) | P1-T10, P1-T14 | REGRESSION-SET (`test_typescript_toolchain_instruction_contracts.py`); structural check (4) | other/p1-t10, qa-gates/structural-checks |
| AC-4 | (#797 CR-2) former item 7 sits under a lead-in attributing it to the file-shape classifier, in source and mirror (line 47) | P1-T9, P1-T13 | REGRESSION-SET (four `parallel-orchestration.md` readers); structural check (3) | other/p1-t9, qa-gates/structural-checks, qa-gates/python-pytest-regression-set |
| AC-5 | Three mirrors byte-identical; `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes (line 48) | P1-T13, P1-T14, P1-T15 | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`; `git diff --no-index` pairs | qa-gates/python-pytest-bundle-parity, qa-gates/mirror-identity |
| AC-6 | `PRE_EXISTING_NAME_EXCEPTIONS` replaced by exact pinned counts; negative tests for unpinned and pinned files; staleness check kept (line 49) | P1-T2 through P1-T6 | P2-T5 named nodes (six), GUARD full module | regression-testing/expect-fail-pinned-name-counts, regression-testing/pass-after-pinned-name-counts, qa-gates/python-pytest-guard, qa-gates/python-pytest-guard-named-nodes |
| AC-7 | GUARD clean under black, ruff, pyright, pytest; guard and parity tests pass; no changed code file over 500 lines (line 50) | P1-T2 through P1-T6 | P2-T1 through P2-T4, P2-T6 | qa-gates/python-black, qa-gates/python-ruff, qa-gates/python-pyright, qa-gates/python-pytest-guard, qa-gates/python-pytest-bundle-parity, qa-gates/line-counts |

## Appendix A — exact rule-file edits

Each edit is applied to the source file under `.claude/rules/`; the identical edit is then applied to the mirror with the Edit tool (P1-T13 through P1-T15).

Edit A1, `.claude/rules/parallel-orchestration.md` line 411. Before:

```text
`src/TaskMaster.Domain`; host-qualified tokens such as `example.com/page.html` or `owner/repo.git`;
```

After:

```text
`src/<Product>.Domain`; host-qualified tokens such as `example.com/page.html` or `owner/repo.git`;
```

Edit A2, `.claude/rules/parallel-orchestration.md` lines 566-569. Before (item 7 is one physical line):

```text
6. a genuine file whose stem is in the placeholder set (W6).
7. a genuine file cited only as a separator-free bare file name is not recorded, because only repository-relative paths and configured root surfaces are accepted (issue #797); the planner cites the repository-relative path or appends it to the declared radius.

Three mitigations bound these cases:
```

After (lines 566-573; line 567 and line 572 are blank):

```text
6. a genuine file whose stem is in the placeholder set (W6).

The file-shape classifier, which runs before write-intent extraction, drops one further case: a
genuine file cited only as a separator-free bare file name is not recorded, because only
repository-relative paths and configured root surfaces are accepted (issue #797). The planner
cites the repository-relative path or appends it to the declared radius.

Three mitigations bound these cases:
```

Edit A3, `.claude/rules/typescript.md` line 57. After (one physical line):

```text
Layer rules and the host-neutral architecture assertions are defined in `.claude/rules/architecture-boundaries.md` under the heading "Host-Neutral Architecture Rules (enforceable assertions)". The TypeScript enforcement tool is `dependency-cruiser` with configuration file `.dependency-cruiser.cjs`.
```

Edit A4, `.claude/rules/csharp.md` line 5. After:

```text
description: C#-specific toolchain and coding standards (xUnit).
```

Edit A5, `.claude/rules/csharp.md` line 10. After (one physical line):

```text
This rule file summarizes the C#-specific policies for this repository. It targets a host-neutral .NET foundation: xUnit, NSubstitute, FluentAssertions, `dotnet build`, the analyzer stack, `TimeProvider`, and uniform coverage thresholds.
```

## Appendix B — exact test-module edits (GUARD)

Edit B1, replacement for docstring lines 9-11 (line 8, "threshold-precedence copy states the per-metric fallback. A scan of every pushed", is unchanged):

```text
rule and skill file compares each file's product-name occurrence count with
``PINNED_NAME_OCCURRENCES``, so a new occurrence fails in any file, including a
pinned one, and a pinned entry that is absent or not positive is reported as stale.
```

Edit B2, replacement for planning-time lines 107-120:

```python
# Exact expected count of CONSUMING_NAMES occurrences per pushed file. A file
# absent from the map is expected to hold none. An entry records an accepted,
# counted occurrence; the count must match exactly, so a new occurrence and a
# removed one both fail. Issue #894 removed the last occurrences, so it is empty.
PINNED_NAME_OCCURRENCES: dict[str, int] = {}
```

Edit B3, inserted directly after the last line of `pushed_rule_and_skill_files` (`return sorted(found)`, planning-time line 158), so the two existing blank lines before `step_eight` follow it (34 lines including the two leading blank lines):

```python


def count_name_occurrences(text: str) -> int:
    """Return the total number of CONSUMING_NAMES occurrences in the text."""

    return sum(text.count(name) for name in CONSUMING_NAMES)


def pinned_count_mismatches(
    observed: dict[str, int], pinned: dict[str, int]
) -> list[str]:
    """Return one message per observed path whose count differs from its pin.

    A path absent from ``pinned`` is expected to hold zero occurrences, so a new
    occurrence in an unpinned file, a new occurrence in a pinned file, and a
    removed occurrence in a pinned file are all reported.
    """

    return [
        f"{path}: observed {count}, pinned {pinned.get(path, 0)}"
        for path, count in sorted(observed.items())
        if count != pinned.get(path, 0)
    ]


def stale_pinned_entries(pinned: dict[str, int], scanned: list[str]) -> list[str]:
    """Return the pinned paths that are not scanned or whose pin is not positive."""

    scanned_paths = set(scanned)
    return sorted(
        path
        for path, count in pinned.items()
        if path not in scanned_paths or count <= 0
    )
```

Edit B4, replacement for the two tests at planning-time lines 320-356:

```python
def test_pushed_rule_and_skill_files_match_pinned_name_counts() -> None:
    """FU-823-2 and #894: every pushed file holds exactly its pinned name count."""

    # Arrange
    observed = {
        path: count_name_occurrences(read_copy(path))
        for path in pushed_rule_and_skill_files()
    }

    # Act
    mismatches = pinned_count_mismatches(observed, PINNED_NAME_OCCURRENCES)

    # Assert
    assert mismatches == [], f"product-name counts differ from pins: {mismatches}"


def test_pinned_name_entries_are_pushed_files_with_positive_counts() -> None:
    """Each pinned entry names a scanned pushed file and a positive count."""

    # Arrange
    scanned = pushed_rule_and_skill_files()

    # Act
    stale = stale_pinned_entries(PINNED_NAME_OCCURRENCES, scanned)

    # Assert
    assert stale == [], f"remove or correct stale pinned entries: {stale}"
```

Edit B5, appended at the end of GUARD (two blank lines before each function or decorator):

```python
def test_pinned_count_mismatches_flags_new_occurrence_in_unpinned_file() -> None:
    """A new occurrence in a file with no pin is reported."""

    # Arrange
    observed = {".claude/rules/example.md": 1}
    pinned: dict[str, int] = {}

    # Act
    mismatches = pinned_count_mismatches(observed, pinned)

    # Assert
    assert mismatches == [".claude/rules/example.md: observed 1, pinned 0"]


def test_pinned_count_mismatches_flags_new_occurrence_in_pinned_file() -> None:
    """A new occurrence beyond a file's pinned count is reported."""

    # Arrange
    observed = {".claude/rules/example.md": 2}
    pinned = {".claude/rules/example.md": 1}

    # Act
    mismatches = pinned_count_mismatches(observed, pinned)

    # Assert
    assert mismatches == [".claude/rules/example.md: observed 2, pinned 1"]


def test_pinned_count_mismatches_flags_removed_occurrence_in_pinned_file() -> None:
    """A pinned file that lost an occurrence is reported, so a pin cannot go stale."""

    # Arrange
    observed = {".claude/rules/example.md": 0}
    pinned = {".claude/rules/example.md": 1}

    # Act
    mismatches = pinned_count_mismatches(observed, pinned)

    # Assert
    assert mismatches == [".claude/rules/example.md: observed 0, pinned 1"]


def test_pinned_count_mismatches_accepts_matching_counts() -> None:
    """Counts equal to their pins, and zero in unpinned files, are accepted."""

    # Arrange
    observed = {".claude/rules/example.md": 1, ".claude/rules/other.md": 0}
    pinned = {".claude/rules/example.md": 1}

    # Act
    mismatches = pinned_count_mismatches(observed, pinned)

    # Assert
    assert mismatches == []


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        ("TaskMaster and No-COM and TaskMaster", 3),
        ("`src/<Product>.Domain` with host-neutral wording", 0),
    ],
)
def test_count_name_occurrences_counts_every_token(text: str, expected: int) -> None:
    """Every consuming-name occurrence is counted; neutral text counts zero."""

    # Act
    count = count_name_occurrences(text)

    # Assert
    assert count == expected


def test_stale_pinned_entries_flags_unscanned_path_and_non_positive_pin() -> None:
    """A pin for an unscanned file and a zero pin are both reported as stale."""

    # Arrange
    pinned = {
        ".claude/rules/gone.md": 1,
        ".claude/rules/zero.md": 0,
        ".claude/rules/kept.md": 2,
    }
    scanned = [".claude/rules/kept.md", ".claude/rules/zero.md"]

    # Act
    stale = stale_pinned_entries(pinned, scanned)

    # Assert
    assert stale == [".claude/rules/gone.md", ".claude/rules/zero.md"]
```

Line arithmetic (planning time): 356 lines, minus 9 (B2: 14 lines replaced by 5), plus 34 (B3), minus 10 (B4: 37 lines replaced by 27, that is 14 lines, 2 blank, 11 lines), plus 91 (B5: four 14-line blocks, one 17-line block, one 18-line block, each including its two leading blank lines) gives 462.

## Write list (every repository file this plan writes)

Rule files and mirrors (6), all operator-approved for this item only:

1. `.claude/rules/parallel-orchestration.md` (P1-T8, P1-T9)
2. `.claude/rules/typescript.md` (P1-T10)
3. `.claude/rules/csharp.md` (P1-T11, P1-T12)
4. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` (P1-T13)
5. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md` (P1-T14)
6. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md` (P1-T15)

Test module (1):

7. `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (P1-T2 through P1-T6)

Feature documents (outside the P2-T11 pathspec):

8. `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md` (P2-T12 through P2-T19, checkbox state only)
9. `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/plan.2026-10-11T09-43.md` (checklist state only)

Evidence artifacts are written under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/ and are not listed individually.

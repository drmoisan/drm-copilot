# 2026-09-29-issue-507-python-push-down-divergence-follow-ups (Plan)

- **Issue:** #790
- **Parent (optional):** epic #770 (`push-down-payload-correctness`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08 (preflight revision round 1: P1-T6 remedy clause, P1-T8 count, P7-T6 untracked-aware grep, P9 staging allow-list and pathspec-scoped status)
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/issue-507-python-push-down-divergence-follow-ups-790`
- **Languages in scope:** Python (`scripts/dev_tools`, tier T4), TypeScript (`extensions/drm-copilot`, tier T3)
- **Requirements source (sole AC source):** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`, section `## Acceptance Criteria` (AC-1 through AC-26). Decisions D1 through D4 of the same file are binding design input.
- **Design input (not a requirements source):** `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md` (sections 7 and 8). Every citation this plan takes from it was re-derived against the worktree at planning time.

**Mode note (full-bug):** `spec.md` is required and present; `user-story.md` is not required and is absent. The full QA loop applies to Python and TypeScript.

**Scope boundary (preparation run):** this plan ends at the final QC loop, the AC check-off in `spec.md`, and one commit plus push of the implementation on the branch above. Pull-request authoring, CI monitoring, and feature review are performed later by the parallel orchestrator and are not tasks in this plan.

**Fail-closed evidence rule:** Python and TypeScript policy both require coverage (line >= 85%, branch >= 75%). Baseline and final-QC coverage tasks record numeric line and branch values for every module named in AC-22 and for `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`. If any required baseline artifact, final-QC artifact, or numeric coverage value is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** every evidence-producing task names its artifact path. A task is not checked off until its artifact exists and carries every required field. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. The top-level `EXIT_CODE:` of a multi-command artifact is the exit code of the task's last command; every other command's exit code and its asserted output are recorded inside `Output Summary:` in command order. No planned command task may record `EXIT_CODE: SKIPPED`; the only skip branch in this plan is the one stated in the task text of P6-T7.

## Files Written

Every repository file the implementation writes, one per line. Each also appears in a task whose title begins with a write verb.

- `scripts/dev_tools/push_down_claude_gitignore_merge.py`
- `scripts/dev_tools/push_down_claude_customizations.py`
- `scripts/dev_tools/push_down_claude_pack_selection.py`
- `scripts/dev_tools/push_down_claude_filesystem.py`
- `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`
- `extensions/drm-copilot/jest.config.cjs`
- `tests/fixtures/push_down/gitignore-merge-parity.json`
- `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`
- `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`
- `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`
- `tests/scripts/dev_tools/test_push_down_claude_customizations.py`
- `tests/scripts/dev_tools/test_push_down_claude_parity.py`
- `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`
- `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`
- `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`
- `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`
- `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`

Evidence artifacts are additionally written under `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/` (sub-folders `baseline/`, `regression-testing/`, `qa-gates/`, `other/`), with timestamped names given in each task. No file under `extensions/drm-copilot/resources/`, `.claude/`, `.github/`, `.codex/`, or `.agents/` is written (spec item list and research section 5.4; there is no bundled mirror of any written file). Tool outputs `artifacts/python/coverage-790-baseline.json`, `artifacts/python/coverage-790-final.json`, `artifacts/python/lcov.info`, and `extensions/drm-copilot/coverage/lcov.info` are gitignored (`.gitignore` lines 6 and 61) and are not evidence artifacts.

## Terms used in every task

- FEATURE means `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`. Evidence is written only under FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, and FEATURE/evidence/other/.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock, never composed.
- BASE_SHA means the commit printed by `git merge-base HEAD origin/main` in P0-T3, before any edit. Every pre-commit scope diff in this plan is anchored to it.
- PY-WRITE-SET means these ten Python files: `scripts/dev_tools/push_down_claude_gitignore_merge.py`, `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_pack_selection.py`, `scripts/dev_tools/push_down_claude_filesystem.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`, `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `tests/scripts/dev_tools/test_push_down_claude_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
- TS-WRITE-SET means these four TypeScript-surface files: `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`, `extensions/drm-copilot/jest.config.cjs`.
- BLOCK means the four-line managed block, each line terminated by LF: `# BEGIN drm-copilot managed ignores`, `.claude/state/`, `.codex/state/`, `# END drm-copilot managed ignores` (values from `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` lines 39-59).
- RED-SET means the six pytest files `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`, `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `tests/scripts/dev_tools/test_push_down_claude_parity.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
- PRE-EXISTING means a failure recorded at baseline (Phase 0) in a file outside PY-WRITE-SET and TS-WRITE-SET. A PRE-EXISTING failure is recorded verbatim, is not fixed by this plan (out of scope), and keeps the AC that requires a clean pass unchecked (Phase 8 records the reason). It never authorizes a change to an out-of-scope file.

## Execution constraints

- Commands are written for the Bash tool and run from the root of the #790 worktree. P0-T1 confirms the branch, which identifies the worktree without recording a host path. Artifacts never record an absolute host path.
- No command in this plan contains a heredoc. TypeScript commands use `npm --prefix extensions/drm-copilot run <script>`; the only `cd` prefix is `cd extensions/drm-copilot && npx prettier ...`, which chains no read command.
- File-content checks use `git grep --no-index`, which searches working-tree files whether tracked or untracked, so it sees files this plan creates before they are committed. A pattern that begins with `-` is passed through `-e`. Output convention for `git grep --no-index -c`: a match count n >= 1 prints `<path>:<n>` and exits 0; n = 0 prints nothing and exits 1.
- Edits are made with the Edit tool (one exact `old_string` to `new_string` per replacement, copying `old_string` from the file as it stands) or with the Write tool for new files. Code and test content is specified in the Appendices; the executor does not change a test name, an asserted literal, or a fixture value given there.
- Python batch budget: `.claude/hooks/enforce-python-batch-budget.ps1` denies the fourth distinct production Python path per session unless `artifacts/orchestration/orchestrator-state.json` selects the large, remediation, or preparation route with a non-terminal checkpoint. This plan writes four production Python files (P3-T1, P3-T2, P3-T3, P4-T1). P0-T3 records the observed route. If any Write or Edit is denied by a hook or a permission rule, stop and report the denial text verbatim. Do not delete hook state files and do not route a write through another tool to avoid a hook.
- Commands expected to exceed about 8 minutes (`npm --prefix extensions/drm-copilot run test:coverage`, `poetry run pytest tests/scripts/dev_tools -k push_down`) may run in the background; the executor waits for the completion notification before reading output.
- Files not edited (spec "Explicitly excluded systems" and AC-20): `scripts/dev_tools/push_down_copilot_customizations_filesystem.py`, `scripts/dev_tools/push_down_copilot_customizations.py`, `scripts/dev_tools/push_down_codex_filesystem.py`, `scripts/dev_tools/push_down_codex_and_agents_customizations.py`, `scripts/dev_tools/push_down_claude_exclusion_filter.py`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`, `tests/fixtures/push_down_exclusions/plan-corpus.json`, `README.md`, and everything under `extensions/drm-copilot/resources/`, `.claude/`, `.github/`, `.codex/`, `.agents/`. If a task appears to require editing one of them, stop and report.

## Planner decisions and assumptions (recorded for audit)

- PD1 - Evidence-location override. `spec.md` names `<FEATURE>/evidence/regression/`, `<FEATURE>/evidence/coverage/`, `<FEATURE>/evidence/baselines/`, and `<FEATURE>/evidence/qa/`. Those kinds are not canonical. Recorded overrides:
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/regression/ replaced with FEATURE/evidence/regression-testing/
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/coverage/ replaced with FEATURE/evidence/qa-gates/
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/baselines/ replaced with FEATURE/evidence/baseline/
  - EVIDENCE_LOCATION_OVERRIDE_REJECTED: FEATURE/evidence/qa/ replaced with FEATURE/evidence/qa-gates/
- PD2 - AC-18 grep scope. AC-18 asks that a grep for `def _resolve_published_paths` under `scripts/dev_tools` return no match. At planning time that literal also occurs at `scripts/dev_tools/push_down_codex_and_agents_customizations.py` line 233, a file AC-20 requires to stay unchanged. The directory-wide form is therefore unsatisfiable without violating AC-20. P7-T6 asserts the removal against `scripts/dev_tools/push_down_claude_customizations.py` and asserts that the only remaining directory-wide match is the Codex file. Phase 8 records the narrowing in the AC-18 check-off evidence.
- PD3 - Gitignore fixture test location. `tests/scripts/dev_tools/test_push_down_claude_parity.py` is 438 lines at planning time; the runtime-directory parity tests add about 45 lines, and the fixture test would add about 25 more, leaving under 15 lines of headroom against the 500-line cap after formatting. Per the spec's stated fallback (AC-3, risk list), `test_gitignore_merge_fixture_parity` is placed in the new `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`.
- PD4 - Conditional test file made unconditional. Spec item 13 makes `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` conditional. This plan adds three direct tests of `resolve_published_paths` unconditionally so the written-file set is fixed before execution and the moved lines are covered directly.
- PD5 - `resolve_published_paths` signature. The moved function takes `manifest_dir: Path` instead of `bundle_root`, and the entry module passes `effective_bundle / PACK_MANIFEST_SUBDIR`. `PACK_MANIFEST_SUBDIR` therefore stays defined in `scripts/dev_tools/push_down_claude_customizations.py` and stays in its `__all__` (spec invariant), and the pack-selection module needs no new constant.
- PD6 - Coverage command form. The final-QC pytest command is the spec "Test Strategy" command with two additions: the relocated `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py` (PD3) and `--cov-report=json:artifacts/python/coverage-790-final.json`. The terminal `Cover` column combines statements and branches, so separate line and branch values are computed from the JSON report's per-file `summary` keys `covered_lines`, `num_statements`, `covered_branches`, and `num_branches`. The baseline command uses only the test files that exist at baseline (P0-T9).
- PD7 - Changed-line coverage. "No regression on changed lines" (AC-22) is measured as the share of changed executable lines (from `git diff -U0 BASE_SHA`) that are not in the final JSON report's `missing_lines`, required to be >= 85% per changed production module. The new module `push_down_claude_gitignore_merge.py` is wholly new code; its module percentages are its new-code values.
- PD8 - CRLF behavior tests use an in-memory filesystem whose `read_text` applies the same newline translation as `Path.read_text` (`scripts/dev_tools/push_down_copilot_customizations_filesystem.py` line 171), so decision D2 is tested without the real filesystem.
- PD9 - The TypeScript constant-membership test is added after the production export exists (P4-T3), because importing a missing export makes ts-jest fail the whole suite at compile time instead of failing the individual assertions. The behavioral prefix-exclusion tests are added before the fix (P1-T9) and fail by assertion.
- PD10 - AC-26 says "verified by inspection during feature review". Feature review is outside this plan. P7-T7 records a mechanical docstring check, and the AC-26 check-off notes that the feature-review inspection remains with the orchestrator.
- PD11 - AC-20 and AC-21 name the form `git diff --name-only origin/main...HEAD`, which observes committed changes only. P7-T4 and P7-T5 check the uncommitted tree against BASE_SHA together with `git status --porcelain`; P9-T3 re-runs the exact spec form after the commit.
- A1 - Assumption: `origin/main` is not fetched by the executor during the run; BASE_SHA is recorded once and reused.
- A2 - Assumption: the Bash tool provides `wc`, `git`, `poetry`, `npm`, and `npx`.

## AC Traceability

| AC | Implementation | Tests | Evidence task |
|---|---|---|---|
| AC-1 | P3-T1 | `test_constants_match_typescript_values` | P5-T2, P6-T4 |
| AC-2 | P3-T1 | 15 `test_merge_*` tests (Appendix C1) | P5-T2, P6-T4 |
| AC-3 | P1-T1, P3-T1 | `test_gitignore_merge_fixture_parity` | P5-T2 |
| AC-4 | P1-T1 | `claude-gitignore-merge-parity.test.ts` | P2-T3, P6-T10 |
| AC-5 | P1-T1 | fixture parity tests (Python and TypeScript) | P5-T2, P6-T10 |
| AC-6 | P3-T1, P3-T3 | delivery tests D1-D3 | P5-T2 |
| AC-7 | P3-T1 | delivery test D4 | P5-T2 |
| AC-8 | P3-T1, P3-T3 | delivery tests D5-D8 | P5-T2 |
| AC-9 | P3-T3 | delivery tests D9-D11 | P5-T2 |
| AC-10 | P3-T1 | delivery test D12 | P5-T2 |
| AC-11 | P3-T1, P3-T3 | red and green delivery runs, TypeScript merge suites | P2-T1, P5-T2, P6-T10 |
| AC-12 | P3-T1 | delivery tests D13-D14 | P5-T2, P7-T7 |
| AC-13 | P4-T1 | F1, F2 (Appendix C4) | P5-T2 |
| AC-14 | P4-T1 | F3 | P2-T1, P5-T2 |
| AC-15 | P4-T1 | F4, F5, F6 | P5-T2 |
| AC-16 | P4-T2 | T1-T6 (Appendix C8, C9) | P5-T3, P6-T10 |
| AC-17 | P4-T1, P4-T2 | `test_local_runtime_directories_match_typescript`, `test_local_runtime_directories_comparison_detects_divergence` | P5-T2 |
| AC-18 | P3-T2, P3-T3 | pack-selection and pack end-to-end suites | P6-T4, P7-T6 |
| AC-19 | all write tasks | line counts | P7-T3 |
| AC-20 | scope constraint | scope diffs | P7-T4, P9-T3 |
| AC-21 | scope constraint | scope diffs, resource-contract suite | P7-T5, P9-T3 |
| AC-22 | Phases 3-4 | final targeted pytest | P0-T10, P6-T5, P7-T1 |
| AC-23 | P4-T4 | `test:coverage` | P0-T18, P6-T11, P6-T12, P7-T2 |
| AC-24 | Phases 3-5 | Python toolchain | P6-T1 to P6-T6 |
| AC-25 | Phases 4-5 | TypeScript toolchain | P6-T7 to P6-T10 |
| AC-26 | P3-T1, P3-T3 | docstring checks | P7-T7 |

### Phase 0 — Preconditions, Policy Reads, and Baseline Capture

Each task in this phase writes the artifact it names under FEATURE/evidence/baseline/.

- [ ] [P0-T1] Verify the full-bug preconditions for FEATURE (`docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`, `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md`) and record FEATURE/evidence/baseline/phase0-mode-check.TS.md.
      Commands: `git branch --show-current`; `ls docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`; `git grep --no-index -c "^## Acceptance Criteria$" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `git grep --no-index -c -e "^- \[ \] AC-[0-9]" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `git grep --no-index -c -F "Work Mode: full-bug" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md`.
      Acceptance: the branch command prints exactly `bug/issue-507-python-push-down-divergence-follow-ups-790` (any other value stops the plan); the listing contains `spec.md`, `issue.md`, and `research` and does not contain `user-story.md`; the heading grep prints 1; the AC grep prints 26; the work-mode grep prints 1. Any other result stops the plan.
- [ ] [P0-T2] Read the policy files in the required order and record FEATURE/evidence/baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.github/copilot-instructions.md`, `.claude/rules/tonality.md`; (2) `.github/instructions/general-code-change.instructions.md`, `.claude/rules/general-code-change.md`; (3) `.github/instructions/general-unit-test.instructions.md`, `.claude/rules/general-unit-test.md`; (4) `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`; (6) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (7) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 20 files in that order.
- [ ] [P0-T3] Record BASE_SHA, HEAD, the orchestrator route that governs the Python batch budget, and the clean pre-edit state of every path in PY-WRITE-SET, TS-WRITE-SET, and `tests/fixtures/push_down`, and record FEATURE/evidence/baseline/base-sha.TS.md.
      Commands: `git merge-base HEAD origin/main`; `git rev-parse HEAD`; `git status --porcelain -- scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs tests/fixtures/push_down`. Then read `artifacts/orchestration/orchestrator-state.json` with the Read tool.
      Acceptance: each `git` SHA command prints one 40-character SHA (the first is recorded as BASE_SHA); the status command prints nothing (any output stops the plan, because the baseline would not measure committed content). `Output Summary:` records the checkpoint's `route_id` value, else its `path_selected` value, else the literal `CHECKPOINT ABSENT`.
- [ ] [P0-T4] Verify that the Poetry environment imports `scripts.dev_tools` from this worktree (`scripts/dev_tools/push_down_claude_filesystem.py`), and record FEATURE/evidence/baseline/python-env-identity.TS.md.
      Command: `poetry run python -c "import pathlib, subprocess, scripts.dev_tools.push_down_claude_filesystem as m; top = pathlib.Path(subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True, text=True, check=True).stdout.strip()).resolve(); print('MODULE_IN_WORKTREE', pathlib.Path(m.__file__).resolve().is_relative_to(top))"`.
      Acceptance: exit 0 and the printed line `MODULE_IN_WORKTREE True`. If it prints `MODULE_IN_WORKTREE False`, run `poetry install --no-interaction`, record its exit code and final line, and rerun the command; a second `False` stops the plan, because every later Python result would exercise another checkout's source.
- [ ] [P0-T5] Baseline physical line counts of the existing files this plan edits, and record FEATURE/evidence/baseline/line-counts.TS.md.
      Command: `wc -l scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs`.
      Acceptance: exit 0 and one count per file recorded. Planning-time values: 499, 401, 472, 303, 284, 438, 348, 306, 470. A differing value is recorded; it does not stop the plan, because every edit locates text by `old_string`, but the executor re-reads the file before editing it.
- [ ] [P0-T6] Baseline Python format check (`pyproject.toml` `[tool.black]`), and record FEATURE/evidence/baseline/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: the exit code and the summary line (expected to contain "would be left unchanged") are recorded. On a non-zero exit, every "would reformat" line is recorded; files outside PY-WRITE-SET are recorded as PRE-EXISTING; a listed file inside PY-WRITE-SET stops the plan.
- [ ] [P0-T7] Baseline Python lint (`pyproject.toml` `[tool.ruff]`), and record FEATURE/evidence/baseline/ruff-check.TS.md.
      Command: `poetry run ruff check .`.
      Acceptance: the exit code is recorded; on exit 0 the line "All checks passed!" is recorded. On a non-zero exit, every finding is recorded and classified as PRE-EXISTING or, when it names a file in PY-WRITE-SET, stops the plan.
- [ ] [P0-T8] Baseline Python type check (`pyproject.toml` `[tool.pyright]`), and record FEATURE/evidence/baseline/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: the exit code and the summary line (expected to begin "0 errors") are recorded. Errors outside PY-WRITE-SET are recorded as PRE-EXISTING; an error in PY-WRITE-SET stops the plan.
- [ ] [P0-T9] Baseline targeted Python tests with coverage for the three existing changed modules (`scripts/dev_tools/push_down_claude_filesystem.py`, `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_pack_selection.py`), and record FEATURE/evidence/baseline/pytest-targeted-coverage.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-baseline.json`.
      Acceptance: exit 0, the pytest summary line (passed count recorded as BASELINE_TARGETED_PASSED), and the three per-module rows plus the `TOTAL` row of the term-missing table are recorded verbatim. Any failure stops the plan.
- [ ] [P0-T10] Baseline numeric per-module line and branch coverage from the P0-T9 JSON report (`artifacts/python/coverage-790-baseline.json`), and record FEATURE/evidence/baseline/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-baseline.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"`.
      Acceptance: exit 0 and three printed lines of the form `<path> LINE <n> BRANCH <n>`; the six numbers are recorded as the baseline values. `scripts/dev_tools/push_down_claude_gitignore_merge.py` is recorded as `N/A - module absent at baseline (new module)`. An empty output or a `KeyError` stops the plan.
- [ ] [P0-T11] Baseline wider Python push-down regression pass (`tests/scripts/dev_tools`), and record FEATURE/evidence/baseline/pytest-push-down-wide.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools -k push_down`.
      Acceptance: the exit code, the summary line, and every `FAILED` line of the `-ra` summary are recorded. Failures are recorded as PRE-EXISTING (with `ExpectedExitCode: 1` when present); a failure in a file of RED-SET stops the plan.
- [ ] [P0-T12] Install the extension dependencies (`extensions/drm-copilot/package-lock.json`) and confirm the Jest binary, and record FEATURE/evidence/baseline/npm-ci.TS.md.
      Commands: `npm --prefix extensions/drm-copilot ci`; `ls -d extensions/drm-copilot/node_modules/jest`.
      Acceptance: the install exits 0 (final summary line recorded); `ls -d` exits 0 and prints one line naming `extensions/drm-copilot/node_modules/jest`. Either failing stops the plan.
- [ ] [P0-T13] Baseline TypeScript format check over the globs of the `format` script (`extensions/drm-copilot/package.json` line 207), and record FEATURE/evidence/baseline/prettier-check.TS.md.
      Command: `cd extensions/drm-copilot && npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
      Acceptance: the exit code and the final line (expected "All matched files use Prettier code style!") are recorded. On a non-zero exit every listed file is recorded; files outside TS-WRITE-SET are PRE-EXISTING (and select the skip branch of P6-T7); a listed file in TS-WRITE-SET stops the plan.
- [ ] [P0-T14] Baseline TypeScript lint (`extensions/drm-copilot/package.json` script `lint`), and record FEATURE/evidence/baseline/eslint.TS.md.
      Command: `npm --prefix extensions/drm-copilot run lint`.
      Acceptance: exit 0 and no line containing "error" after the npm script header. A non-zero exit is recorded verbatim; findings outside TS-WRITE-SET are PRE-EXISTING, findings in TS-WRITE-SET stop the plan.
- [ ] [P0-T15] Baseline TypeScript type check (`extensions/drm-copilot/package.json` script `typecheck`), and record FEATURE/evidence/baseline/tsc.TS.md.
      Command: `npm --prefix extensions/drm-copilot run typecheck`.
      Acceptance: exit 0 and no line containing "error TS". A non-zero exit is recorded verbatim and classified as in P0-T14.
- [ ] [P0-T16] Baseline targeted Jest run of the existing push-down suites the spec names (`extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts`), and record FEATURE/evidence/baseline/jest-targeted.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts`.
      Acceptance: exit 0 and the Jest `Tests:` line recorded; the adapter suite count (planning-time: 23 tests) is recorded from the per-suite output. Any failure stops the plan.
- [ ] [P0-T17] Baseline full extension Jest run in coverage mode (`extensions/drm-copilot/package.json` script `test:coverage`, `extensions/drm-copilot/jest.config.cjs`), and record FEATURE/evidence/baseline/jest-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: the exit code, the `Tests:` line, and the text-summary lines beginning `Statements`, `Branches`, and `Lines` are recorded. A non-zero exit is recorded with every failing test name and every "coverage threshold" line; failures outside TS-WRITE-SET are PRE-EXISTING (`ExpectedExitCode: 1`), and the plan continues only if `extensions/drm-copilot/coverage/lcov.info` was written.
- [ ] [P0-T18] Baseline per-file coverage of `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` from the P0-T17 LCOV report (`extensions/drm-copilot/coverage/lcov.info`), before any threshold entry exists for it, and record FEATURE/evidence/baseline/adapter-coverage.TS.md.
      Command: `poetry run python -c "import pathlib, re; t = pathlib.Path('extensions/drm-copilot/coverage/lcov.info').read_text(encoding='utf-8').replace(chr(92), '/').replace(chr(13), ''); b = [x for x in t.split('end_of_record') if re.search(r'^SF:.*src/lib/push-down/claude-filesystem-adapter[.]ts$', x, re.M)]; v = {k: int(n) for k, n in re.findall(r'^(LF|LH|BRF|BRH):([0-9]+)$', b[0], re.M)}; print('BLOCKS', len(b), 'LINES', round(100 * v['LH'] / v['LF'], 2), 'BRANCHES', round(100 * v['BRH'] / v['BRF'], 2) if v['BRF'] else 'NO_BRANCHES')"`.
      Acceptance: exit 0 and one printed line beginning `BLOCKS 1 LINES`; the two percentages are recorded as BASELINE_ADAPTER_LINES and BASELINE_ADAPTER_BRANCHES. When either value is below 85 (lines) or 75 (branches), `Output Summary:` records `ADAPTER_BELOW_THRESHOLD_AT_BASELINE`, which obliges P6-T11 to add adapter tests before the new threshold can hold (spec risk list). An `IndexError` (no block found) stops the plan.

### Phase 1 — Fixture and Regression Tests

Each task in this phase writes FEATURE/evidence/other/p1-tN.TS.md (N is the task number). No new test is parametrized, so test-function counts equal collected-test counts. Every Python test imports production modules that do not yet exist inside the test body (pattern of `tests/scripts/dev_tools/test_push_down_claude_parity.py` lines 11-13 and 406-411), so each file collects before Phase 3.

- [ ] [P1-T1] Create `tests/fixtures/push_down/gitignore-merge-parity.json` with exactly the content of Appendix B (Write tool, LF line endings; carriage returns appear only as the JSON escape `\r`, never as raw bytes, so `.gitattributes` line 1 `* text=auto eol=lf` cannot alter a case).
      Commands: `git grep --no-index -c -F "\"name\":" -- tests/fixtures/push_down/gitignore-merge-parity.json`; `poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('tests/fixtures/push_down/gitignore-merge-parity.json').read_text(encoding='utf-8')); print('CASES', len(d['cases']), 'KEYS_OK', all(set(c) == {'name', 'current', 'expected'} for c in d['cases']))"`; `git status --porcelain -- tests/fixtures/push_down/gitignore-merge-parity.json`.
      Acceptance: the grep prints 11; the Python command prints `CASES 11 KEYS_OK True`; the status line shows the file as untracked (`??`).
- [ ] [P1-T2] Create `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` with the 16 tests of Appendix C1.
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`; `git grep --no-index -c -E "tempfile|tmp_path|mkstemp|NamedTemporaryFile" -- tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py --collect-only -q`.
      Acceptance: the first grep prints 16; the second prints nothing and exits 1 (the pass condition); collection exits 0 and prints "16 tests collected".
- [ ] [P1-T3] Create `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py` with the single test of Appendix C2 (PD3).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py --collect-only -q`.
      Acceptance: the grep prints 1; collection exits 0 and prints "1 test collected".
- [ ] [P1-T4] Create `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` with helpers and the 14 tests D1-D14 of Appendix C3.
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`; `git grep --no-index -c -E "tempfile|tmp_path|mkstemp|NamedTemporaryFile|push_down_claude_gitignore_merge" -- tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py --collect-only -q`.
      Acceptance: the first grep prints 14; the second prints nothing and exits 1 (the delivery tests assert against literal expected text and never import the module under construction); collection exits 0 and prints "14 tests collected".
- [ ] [P1-T5] Update `tests/scripts/dev_tools/test_push_down_claude_customizations.py` by appending the six F-507-2 tests F1-F6 of Appendix C4 (existing tests unchanged).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_customizations.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py --collect-only -q`.
      Acceptance: the grep prints 14 (8 existing plus 6); collection exits 0 and prints "14 tests collected".
- [ ] [P1-T6] Update `tests/scripts/dev_tools/test_push_down_claude_parity.py` with the helper generalization and the two runtime-directory tests of Appendix C5 (existing tests and their messages unchanged).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_parity.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_parity.py --collect-only -q`; `wc -l tests/scripts/dev_tools/test_push_down_claude_parity.py`.
      Acceptance: the grep prints 12 (10 existing plus 2); collection exits 0 and prints "12 tests collected"; the line count is at most 500 (planning-time projection about 486; executor estimate 490-498).
      Remedy, applied only when the line count exceeds 500 (no existing test is condensed and no new file is written): restore `_ts_root_folders` in this file to its BASE_SHA form (no generalization here), and place the two constants of Appendix C5, `_ts_string_array`, `_py_string_tuple`, and both runtime-directory tests in `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, which imports `assert_same`, `literal_value`, `py_assignment`, `py_string`, `read_repo_text`, and `ts_declarations` from `tests.scripts.dev_tools.test_push_down_claude_parity` (one import direction, no cycle), together with `ast` and `pytest`. To provide those public names without a `reportPrivateUsage` diagnostic or a suppression comment, the remedy appends one alias block to `tests/scripts/dev_tools/test_push_down_claude_parity.py` directly after `_assert_same`, headed by the comment `# Public aliases consumed by test_push_down_claude_gitignore_parity.py.` and consisting of exactly the six assignments `assert_same = _assert_same`, `literal_value = _literal_value`, `py_assignment = _py_assignment`, `py_string = _py_string`, `read_repo_text = _read_repo_text`, and `ts_declarations = _ts_declarations`. The moved `_ts_string_array`, `_py_string_tuple`, and both runtime-directory tests call these public names (Appendix C5 names the underscore forms because it describes the in-file placement). No existing helper is renamed and no `# pyright: ignore` comment is added. The remedy's line count for `tests/scripts/dev_tools/test_push_down_claude_parity.py` must still be at most 500 (BASE is 438 lines; the alias block adds 7, plus the 2 blank separator lines the formatter requires before the next top-level `def`, projecting 447). Test names, messages, and asserted literals stay as in Appendix C5. The artifact records `P1-T6 REMEDY APPLIED` and the line count before and after. Under the remedy these expectations replace the stated ones: P1-T6 grep 10 and "10 tests collected"; P1-T3 grep 3 and "3 tests collected" (rerun P1-T3); P3-T1 adds `-k "not local_runtime_directories"` to its pytest command and expects "17 passed, 2 deselected"; P3-T4 adds the same `-k "not local_runtime_directories"` to its pytest command, expects no failed test and 2 deselected, and records the deselection in `Output Summary:`; P4-T5 adds `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py` to its pytest command and expects 27 passed (14 plus 10 plus 3). P2-T1, P5-T2, P6-T4, and P6-T6 totals are unchanged, because both files belong to RED-SET and to the targeted command.
- [ ] [P1-T7] Update `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` by appending the three `resolve_published_paths` tests of Appendix C6 (PD4).
      Commands: `git grep --no-index -c "^def test_" -- tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py --collect-only -q`.
      Acceptance: the grep prints 19 (16 existing plus 3); collection exits 0 and prints "19 tests collected".
- [ ] [P1-T8] Create `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` with the content specified in Appendix C7.
      Commands: `git grep --no-index -c -E "^  it(\.each)?\(" -- extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`; `git grep --no-index -c -F "gitignore-merge-parity.json" -- extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`.
      Acceptance: the first grep prints 2 (one `it` and one `it.each`); the second prints a count of at least 1 (the `loadFixture` path; a header-comment mention adds one line).
- [ ] [P1-T9] Update `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` by appending the five behavioral tests T1-T5 of Appendix C8 inside the existing `describe("ExcludingFileSystem", ...)` block, with no new import (PD9).
      Commands: `git grep --no-index -c -E "^  it\(" -- extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`; `git grep --no-index -c -F "LOCAL_RUNTIME_RELATIVE_DIRECTORIES" -- extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`.
      Acceptance: the first grep prints 28 (23 existing plus 5); the second prints nothing and exits 1 (the pass condition at this point). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [ ] [P1-T10] Format and lint-check the new and edited Python test files (the six test files of PY-WRITE-SET) before the first red run.
      Commands: `poetry run black tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`; `poetry run ruff check tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
      Acceptance: black exits 0 and its summary line ("N files reformatted" and/or "N files left unchanged") is recorded verbatim; ruff exits 0 and prints "All checks passed!". A ruff finding is fixed in the named test file only, without changing a test name or an asserted literal, and this task is rerun.

### Phase 2 — Expect-Fail Regression Runs

- [ ] [P2-T1] [expect-fail] Run RED-SET against the unfixed production code and record FEATURE/evidence/regression-testing/expect-fail-python.TS.md with `ExpectedExitCode: 1`.
      Commands: `git status --porcelain -- scripts/dev_tools extensions/drm-copilot/src`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
      Acceptance: the status command prints nothing (no production file has changed); pytest exits 1 and its summary line reports exactly 37 failed and 39 passed. The failing set is exactly: all 16 tests of `test_push_down_claude_gitignore_merge.py` (`ModuleNotFoundError`); `test_gitignore_merge_fixture_parity` (`ModuleNotFoundError`); delivery tests D1-D9 and D11-D14 (13; no `.gitignore` write and no `.gitignore` skip record exist); F1, F2, F3 of `test_push_down_claude_customizations.py`; `test_local_runtime_directories_match_typescript` ("found zero LOCAL_RUNTIME_RELATIVE_DIRECTORIES declarations"); the three `test_resolve_published_paths_*` tests (`AttributeError`). The passing set is D10, F4, F5, F6, `test_local_runtime_directories_comparison_detects_divergence`, and the 34 pre-existing tests (8 + 10 + 16). Every `FAILED` line of the `-ra` summary is recorded. Any other split stops the plan; a collection error stops the plan.
      Restart carve-out: this planned red state does not trigger the Phase 6 restart rule.
- [ ] [P2-T2] [expect-fail] Run the TypeScript adapter suite (`extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`) against the unfixed adapter and record FEATURE/evidence/regression-testing/expect-fail-typescript.TS.md with `ExpectedExitCode: 1`.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts`.
      Acceptance: exit 1 and the `Tests:` line reports 3 failed and 25 passed (28 total). The failing tests are exactly T1, T2, and T3 of Appendix C8; T4 and T5 pass. Any other split, or "Test suite failed to run", stops the plan.
- [ ] [P2-T3] Pin the TypeScript merge against the new shared fixture before any Python change (`extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`, `tests/fixtures/push_down/gitignore-merge-parity.json`), and record FEATURE/evidence/regression-testing/typescript-fixture-parity.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-gitignore-merge-parity.test.ts`.
      Acceptance: exit 0 and the `Tests:` line reports 12 passed, 12 total. A failure means a fixture `expected` value disagrees with the existing TypeScript merge; the fix is to correct Appendix B transcription in the fixture (never the TypeScript production file), then rerun P1-T1 and this task.

### Phase 3 — F-507-1: Python Managed `.gitignore` Merge and Delivery

Each task in this phase writes FEATURE/evidence/other/p3-tN.TS.md.

- [ ] [P3-T1] Create `scripts/dev_tools/push_down_claude_gitignore_merge.py` with exactly the content of Appendix A1 (constants, `merge_claude_gitignore`, `deliver_destination_gitignore`; module docstring states decisions D2 and D3).
      Commands: `git grep --no-index -c -E "^def (merge_claude_gitignore|deliver_destination_gitignore)\(" -- scripts/dev_tools/push_down_claude_gitignore_merge.py`; `git grep --no-index -c -F "500-line limit" -- scripts/dev_tools/push_down_claude_gitignore_merge.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`.
      Acceptance: the first grep prints 2; the second prints 1; pytest exits 0 with 17 passed.
- [ ] [P3-T2] Update `scripts/dev_tools/push_down_claude_pack_selection.py` by appending the public `resolve_published_paths` of Appendix A2 (PD5).
      Commands: `git grep --no-index -c -F "def resolve_published_paths(" -- scripts/dev_tools/push_down_claude_pack_selection.py`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
      Acceptance: the grep prints 1; pytest exits 0 with 19 passed.
- [ ] [P3-T3] Update `scripts/dev_tools/push_down_claude_customizations.py` with replacements E1 through E5 of Appendix A3 (imports, removal of `_resolve_published_paths`, call of `resolve_published_paths`, post-copy delivery, docstring).
      Commands: `git grep --no-index -c -F "def _resolve_published_paths" -- scripts/dev_tools/push_down_claude_customizations.py`; `git grep --no-index -c -F "deliver_destination_gitignore(fs, destination_root, manifest)" -- scripts/dev_tools/push_down_claude_customizations.py`; `git grep --no-index -c -F "\"PACK_MANIFEST_SUBDIR\"," -- scripts/dev_tools/push_down_claude_customizations.py`; `wc -l scripts/dev_tools/push_down_claude_customizations.py`.
      Acceptance: the first grep prints nothing and exits 1 (the pass condition); the second prints 1; the third prints 1; the line count is at most 470 (planning-time projection 460).
- [ ] [P3-T4] Verify the F-507-1 tests against the new Python code (`tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`, `tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py`), and record FEATURE/evidence/other/p3-t4.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py`.
      Acceptance: exit 0 and no failed test; the passed count is recorded. A failure is fixed in the Phase 3 production files only; a test name or asserted literal from Appendix C is never changed.

### Phase 4 — F-507-2: Runtime-Directory Exclusion and Jest Threshold

Each task in this phase writes FEATURE/evidence/other/p4-tN.TS.md.

- [ ] [P4-T1] Update `scripts/dev_tools/push_down_claude_filesystem.py` with replacements G1 through G3 of Appendix A4 (module constant `LOCAL_RUNTIME_RELATIVE_DIRECTORIES`, private predicate `_is_local_runtime_path`, first operand in `list_files`).
      Commands: `git grep --no-index -c -F "def _is_local_runtime_path(" -- scripts/dev_tools/push_down_claude_filesystem.py`; `git grep --no-index -c -F "if not self._is_local_runtime_path(p)" -- scripts/dev_tools/push_down_claude_filesystem.py`; `wc -l scripts/dev_tools/push_down_claude_filesystem.py`.
      Acceptance: each grep prints 1; the line count is at most 498.
- [ ] [P4-T2] Update `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` with replacements H1 through H3 of Appendix A5 (exported `LOCAL_RUNTIME_RELATIVE_DIRECTORIES`, private `isLocalRuntimePath`, first filter in `listFiles`).
      Commands: `git grep --no-index -c -F "export const LOCAL_RUNTIME_RELATIVE_DIRECTORIES" -- extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`; `git grep --no-index -c -F "!this.isLocalRuntimePath(p)" -- extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`.
      Acceptance: each grep prints 1.
- [ ] [P4-T3] Update `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` with the import addition and test T6 of Appendix C9.
      Commands: `git grep --no-index -c -E "^  it\(" -- extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`; `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts`.
      Acceptance: the grep prints 29; Jest exits 0 and the `Tests:` line reports 29 passed, 29 total.
- [ ] [P4-T4] Update `extensions/drm-copilot/jest.config.cjs` with the per-file threshold entry of Appendix A6 for `./src/lib/push-down/claude-filesystem-adapter.ts`, placed after the `./src/lib/push-down/claude-customizations.ts` entry. The baseline value from P0-T18 is quoted in this task's artifact.
      Commands: `git grep --no-index -c -F "\"./src/lib/push-down/claude-filesystem-adapter.ts\": {" -- extensions/drm-copilot/jest.config.cjs`; `poetry run python -c "import pathlib; t = pathlib.Path('extensions/drm-copilot/jest.config.cjs').read_text(encoding='utf-8'); i = t.index('./src/lib/push-down/claude-filesystem-adapter.ts'); print('ENTRY', t[i:i + 120].split('}')[0].replace(chr(10), ' '))"`.
      Acceptance: the grep prints 1; the Python command prints one line beginning `ENTRY ./src/lib/push-down/claude-filesystem-adapter.ts` that contains both `lines: 85` and `branches: 75`.
- [ ] [P4-T5] Verify the F-507-2 Python tests and the static parity tests against both production edits (`tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `tests/scripts/dev_tools/test_push_down_claude_parity.py`), and record FEATURE/evidence/other/p4-t5.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py`.
      Acceptance: exit 0 with 26 passed (14 plus 12). A failure is fixed in `scripts/dev_tools/push_down_claude_filesystem.py` or `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` only.

### Phase 5 — Normalization and Pass-After Verification

- [ ] [P5-T1] Format the Python and TypeScript write sets (PY-WRITE-SET, TS-WRITE-SET) and record FEATURE/evidence/other/p5-t1.TS.md.
      Commands: `poetry run black scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`; `cd extensions/drm-copilot && npx prettier --write src/lib/push-down/claude-filesystem-adapter.ts test/lib/push-down/claude-gitignore-merge-parity.test.ts test/lib/push-down/claude-filesystem-adapter.test.ts jest.config.cjs`.
      Acceptance: both exit 0. The black summary line ("reformatted" and/or "left unchanged") and each prettier output line (each ends "(unchanged)" or carries no suffix when rewritten) are recorded verbatim. This task exists so the Phase 6 check-mode gates measure a formatted tree; the later gates, not this task, decide pass or fail.
- [ ] [P5-T2] Pass-after gate for Python: run RED-SET after all production edits and record FEATURE/evidence/regression-testing/pass-after-python.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`.
      Acceptance: exit 0 and a summary line reporting 76 passed and no failed. The collected node set is the P2-T1 node set (76 tests), so the 37 tests that failed in P2-T1 now pass; `Output Summary:` states this comparison. A failure is fixed in production code only, and the affected Phase 3 or Phase 4 task plus this task are rerun.
- [ ] [P5-T3] Pass-after gate for TypeScript: run the four push-down suites the spec names (`extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts`), and record FEATURE/evidence/regression-testing/pass-after-typescript.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge-parity.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts`.
      Acceptance: exit 0; the `Tests:` line reports no failed test; per-suite counts are recorded (adapter 29, parity 12, and the two existing gitignore suites at their P0-T16 counts).

### Phase 6 — Final QC Loop (Python, then TypeScript)

Restart rule: run P6-T1 through P6-T12 in order. If a Python step (P6-T1 to P6-T6) fails or changes any file, fix the cause, then restart from P6-T1. If a TypeScript step (P6-T7 to P6-T12) fails or changes any file, fix the cause, then restart from P6-T7; if that fix changed a Python file, restart from P6-T1. Every rerun rewrites the affected artifacts with a new TS, and each artifact records its loop iteration number in `Output Summary:`. The loop ends only when every step from the restart point through P6-T12 passes in one uninterrupted pass. A failure classified PRE-EXISTING in Phase 0 does not trigger a restart; it is recorded and leaves the corresponding AC unchecked in Phase 8. Architecture-boundary stage: N/A for Python (no boundary tool configured) and for TypeScript (no `.dependency-cruiser*` file; research section 7). Contract stage: N/A (no schema change). Integration stage: covered by the hermetic in-memory push-down suites in P6-T4, P6-T6, and P6-T11. All artifacts in this phase are written under FEATURE/evidence/qa-gates/.

- [ ] [P6-T1] Python format check (`pyproject.toml` `[tool.black]`), and record FEATURE/evidence/qa-gates/black-check.TS.md.
      Command: `poetry run black --check .`.
      Acceptance: exit 0, the summary line containing "would be left unchanged", and no line containing "would reformat". When the only failures are PRE-EXISTING files from P0-T6 and no PY-WRITE-SET file is listed, the result is recorded as `PRE-EXISTING ONLY` and the loop continues.
- [ ] [P6-T2] Python lint (`pyproject.toml` `[tool.ruff]`), and record FEATURE/evidence/qa-gates/ruff-check.TS.md.
      Command: `poetry run ruff check .`.
      Acceptance: exit 0 and the line "All checks passed!". (No `fix` key is set under `[tool.ruff]` in `pyproject.toml`, so this command does not rewrite files; the tree is unchanged by it.)
- [ ] [P6-T3] Python type check (`pyproject.toml` `[tool.pyright]`, strict mode), and record FEATURE/evidence/qa-gates/pyright.TS.md.
      Command: `poetry run pyright`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [ ] [P6-T4] Python targeted tests with coverage for the four modules of AC-22 (`scripts/dev_tools/push_down_claude_filesystem.py`, `scripts/dev_tools/push_down_claude_gitignore_merge.py`, `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_pack_selection.py`), and record FEATURE/evidence/qa-gates/pytest-targeted-coverage.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_gitignore_merge --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-final.json`.
      Acceptance: exit 0, no failed test, the passed count (equal to BASELINE_TARGETED_PASSED plus 42, the number of tests Phases 1 and 4 add), and the four per-module rows plus the `TOTAL` row of the term-missing table recorded verbatim.
- [ ] [P6-T5] Python per-module numeric line and branch coverage from the P6-T4 JSON report (`artifacts/python/coverage-790-final.json`), and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: `poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-final.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_gitignore_merge.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"`.
      Acceptance: exit 0 and four printed lines; every LINE value is >= 85 and every BRANCH value is >= 75 (a module with `NO_BRANCHES` meets the branch gate). A value below threshold is fixed by adding tests to the module's test file in PY-WRITE-SET (`tests/scripts/dev_tools/test_push_down_claude_customizations.py` for the filesystem and entry modules, `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` or `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` for the new module, `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` for the pack-selection module), then restart from P6-T1.
- [ ] [P6-T6] Python wider push-down regression pass (`tests/scripts/dev_tools`), and record FEATURE/evidence/qa-gates/pytest-push-down-wide.TS.md.
      Command: `poetry run pytest tests/scripts/dev_tools -k push_down`.
      Acceptance: exit 0 and no failed test; the passed count is recorded and is at least the P0-T11 passed count plus 42. When the only failures are the PRE-EXISTING node IDs of P0-T11, the result is recorded as `PRE-EXISTING ONLY` with `ExpectedExitCode: 1`.
- [ ] [P6-T7] TypeScript format check over the `format` script globs, then the `format` script itself with a before-and-after observation of TS-WRITE-SET, and record FEATURE/evidence/qa-gates/prettier.TS.md.
      Commands: `cd extensions/drm-copilot && npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `git hash-object extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs`; `git status --porcelain -- extensions/drm-copilot`; `npm --prefix extensions/drm-copilot run format`; `git hash-object extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs`; `git status --porcelain -- extensions/drm-copilot`.
      Acceptance: the check exits 0 and prints "All matched files use Prettier code style!"; the format script exits 0 and every file line it prints ends with "(unchanged)"; the two `git hash-object` outputs are identical (the binding no-change observation for TS-WRITE-SET); the two porcelain outputs are identical (no other extension file changed). Skip branch, authorized here only: when P0-T13 recorded PRE-EXISTING drift outside TS-WRITE-SET, the format script is not run (it would rewrite out-of-scope files); the artifact then records `FORMAT SCRIPT NOT RUN: PRE-EXISTING DRIFT` with the P0-T13 file list, the check step must list only those PRE-EXISTING files, and AC-25 stays unchecked in Phase 8.
- [ ] [P6-T8] TypeScript lint (`extensions/drm-copilot/package.json` script `lint`), and record FEATURE/evidence/qa-gates/eslint.TS.md.
      Command: `npm --prefix extensions/drm-copilot run lint`.
      Acceptance: exit 0 and no line containing "error" after the npm script header.
- [ ] [P6-T9] TypeScript type check (`extensions/drm-copilot/package.json` script `typecheck`), and record FEATURE/evidence/qa-gates/tsc.TS.md.
      Command: `npm --prefix extensions/drm-copilot run typecheck`.
      Acceptance: exit 0 and no line containing "error TS".
- [ ] [P6-T10] TypeScript targeted tests, the spec "Test Strategy" command (`extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts`, `extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts`), and record FEATURE/evidence/qa-gates/jest-targeted.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge-parity.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts`.
      Acceptance: exit 0; `Test Suites:` reports 4 passed; the `Tests:` line reports no failed test.
- [ ] [P6-T11] TypeScript full suite in coverage mode with the new per-file threshold (`extensions/drm-copilot/jest.config.cjs`), and record FEATURE/evidence/qa-gates/jest-coverage.TS.md.
      Command: `npm --prefix extensions/drm-copilot run test:coverage`.
      Acceptance: exit 0, no failed test, no line containing "coverage threshold", and the text-summary `Statements`, `Branches`, and `Lines` lines recorded. A threshold failure for `./src/lib/push-down/claude-filesystem-adapter.ts` is fixed by adding tests to `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` (never by lowering or removing the entry), then restart from P6-T7. Failures limited to PRE-EXISTING tests from P0-T17 are recorded as `PRE-EXISTING ONLY` with `ExpectedExitCode: 1`.
- [ ] [P6-T12] TypeScript per-file coverage of `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` from the P6-T11 LCOV report (`extensions/drm-copilot/coverage/lcov.info`), and record FEATURE/evidence/qa-gates/adapter-coverage.TS.md.
      Command: `poetry run python -c "import pathlib, re; t = pathlib.Path('extensions/drm-copilot/coverage/lcov.info').read_text(encoding='utf-8').replace(chr(92), '/').replace(chr(13), ''); b = [x for x in t.split('end_of_record') if re.search(r'^SF:.*src/lib/push-down/claude-filesystem-adapter[.]ts$', x, re.M)]; v = {k: int(n) for k, n in re.findall(r'^(LF|LH|BRF|BRH):([0-9]+)$', b[0], re.M)}; print('BLOCKS', len(b), 'LINES', round(100 * v['LH'] / v['LF'], 2), 'BRANCHES', round(100 * v['BRH'] / v['BRF'], 2) if v['BRF'] else 'NO_BRANCHES')"`.
      Acceptance: exit 0, a line beginning `BLOCKS 1 LINES`, LINES >= 85, and BRANCHES >= 75 (or `NO_BRANCHES`); the values are recorded as FINAL_ADAPTER_LINES and FINAL_ADAPTER_BRANCHES.

### Phase 7 — Coverage Delta, Size, Scope, and Docstring Verification

Each task in this phase writes the artifact it names under FEATURE/evidence/qa-gates/.

- [ ] [P7-T1] Python coverage delta for AC-22 (`artifacts/python/coverage-790-final.json` against FEATURE/evidence/baseline/python-coverage-values), with changed-line coverage per PD7, and record FEATURE/evidence/qa-gates/python-coverage-delta.TS.md.
      Command: `poetry run python -c "import json, pathlib, re, subprocess; base = subprocess.run(['git', 'merge-base', 'HEAD', 'origin/main'], capture_output=True, text=True, check=True).stdout.strip(); files = {k.replace(chr(92), '/'): v for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-final.json').read_text(encoding='utf-8'))['files'].items()}; mods = ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']; [print(m, 'CHANGED_EXECUTABLE', len(c), 'MISSED', len(c & set(files[m]['missing_lines'])), 'PCT', round(100 * (len(c) - len(c & set(files[m]['missing_lines']))) / len(c), 2) if c else 'NO_CHANGED_EXECUTABLE') for m in mods for c in [{n for a, b in re.findall(r'^@@ -[^ ]+ [+]([0-9]+)(?:,([0-9]+))? @@', subprocess.run(['git', 'diff', '-U0', base, '--', m], capture_output=True, text=True, check=True).stdout, re.M) for n in range(int(a), int(a) + (int(b) if b else 1))} & (set(files[m]['executed_lines']) | set(files[m]['missing_lines']))]]"`.
      Acceptance: exit 0 and three printed lines; every PCT is >= 85 (a module whose changed lines are all non-executable prints `NO_CHANGED_EXECUTABLE`, which passes). `Output Summary:` also tabulates, per AC-22 module, baseline LINE/BRANCH (P0-T10), final LINE/BRANCH (P6-T5), and the delta; for `scripts/dev_tools/push_down_claude_gitignore_merge.py` the new-code values are its P6-T5 module values. Any final value below 85 line or 75 branch, or any PCT below 85, is remediation-required and returns to P6-T5's remedy.
- [ ] [P7-T2] TypeScript coverage delta for `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` (AC-23), and record FEATURE/evidence/qa-gates/typescript-coverage-delta.TS.md.
      Acceptance (derived from recorded artifacts, no new command): `Output Summary:` states BASELINE_ADAPTER_LINES and BASELINE_ADAPTER_BRANCHES (P0-T18), FINAL_ADAPTER_LINES and FINAL_ADAPTER_BRANCHES (P6-T12), and their deltas; the final values are >= 85 and >= 75; P6-T11 exited 0 with the new threshold entry present (P4-T4).
- [ ] [P7-T3] Per-file physical line counts of every production, test, and fixture file this change writes (spec items 1-13 plus PD3's file and the jest config) for AC-19, and record FEATURE/evidence/qa-gates/line-counts.TS.md.
      Command: `wc -l scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts tests/fixtures/push_down/gitignore-merge-parity.json tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs`.
      Acceptance: exit 0 and every per-file count is at most 500. A file over 500 is split or condensed within the same change (never by moving content into an out-of-scope file), and Phase 6 is rerun from P6-T1.
- [ ] [P7-T4] Pre-commit scope check for AC-20 against BASE_SHA (the seven files that must not change), and record FEATURE/evidence/qa-gates/scope-unchanged-files.TS.md.
      Commands: `git diff --name-only BASE_SHA -- scripts/dev_tools/push_down_copilot_customizations_filesystem.py scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_codex_filesystem.py scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_claude_exclusion_filter.py extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`; `git status --porcelain -- scripts/dev_tools/push_down_copilot_customizations_filesystem.py scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_codex_filesystem.py scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_claude_exclusion_filter.py extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`.
      Acceptance: the executor substitutes the recorded BASE_SHA value; both commands exit 0 and print nothing.
- [ ] [P7-T5] Pre-commit scope check for AC-21 (no bundled mirror or customization surface changed) and the resource-contract suite (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`), and record FEATURE/evidence/qa-gates/scope-surfaces.TS.md.
      Commands: `git diff --name-only BASE_SHA -- extensions/drm-copilot/resources .claude .github .codex .agents`; `git status --porcelain -- extensions/drm-copilot/resources .claude .github .codex .agents`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
      Acceptance: the diff and the status command print nothing; pytest exits 0 with no failed test. A failure that P0-T11 recorded as PRE-EXISTING is recorded as such with `ExpectedExitCode: 1` and leaves AC-21 unchecked.
- [ ] [P7-T6] Verify the AC-18 extraction (`scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_pack_selection.py`) and the PD2 narrowing, and record FEATURE/evidence/qa-gates/ac18-extraction.TS.md.
      Commands: `git grep -c -F "def resolve_published_paths(" -- scripts/dev_tools/push_down_claude_pack_selection.py`; `git grep -c -F "resolve_published_paths(" -- scripts/dev_tools/push_down_claude_customizations.py`; `poetry run python -c "import scripts.dev_tools.push_down_claude_customizations as m; print('PACK_MANIFEST_SUBDIR', m.PACK_MANIFEST_SUBDIR, 'IN_ALL', 'PACK_MANIFEST_SUBDIR' in m.__all__, 'HAS_PRIVATE', hasattr(m, '_resolve_published_paths'))"`; `git grep --no-index -l -F "def _resolve_published_paths" -- scripts/dev_tools` (the `--no-index` form also searches the untracked new module `scripts/dev_tools/push_down_claude_gitignore_merge.py`); `git grep -c -F "def _resolve_published_paths" -- scripts/dev_tools/push_down_claude_customizations.py`.
      Acceptance: the first grep prints `scripts/dev_tools/push_down_claude_pack_selection.py:1`; the second prints `scripts/dev_tools/push_down_claude_customizations.py:1`; the Python command prints `PACK_MANIFEST_SUBDIR pack-manifests IN_ALL True HAS_PRIVATE False`; the directory-wide grep prints exactly one line, `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (PD2); the last grep prints nothing and exits 1 (the pass condition). The artifact records `EXIT_CODE: 1` with `ExpectedExitCode: 1`.
- [ ] [P7-T7] Verify the docstring requirements of AC-12 and AC-26 (`scripts/dev_tools/push_down_claude_gitignore_merge.py`, `scripts/dev_tools/push_down_claude_customizations.py`), and record FEATURE/evidence/qa-gates/docstrings.TS.md.
      Commands: `poetry run python -c "import scripts.dev_tools.push_down_claude_gitignore_merge as m; assert 'CRLF' in (m.__doc__ or '')"`; `poetry run python -c "import scripts.dev_tools.push_down_claude_gitignore_merge as g, scripts.dev_tools.push_down_claude_customizations as e; d = e.push_down_customizations.__doc__ or ''; print('D2_CRLF', 'CRLF' in (g.__doc__ or ''), 'D3_LINE_LIMIT', '500-line limit' in (g.__doc__ or ''), 'ENTRY_DELIVERY', 'deliver_destination_gitignore' in d and '.gitignore' in d)"`.
      Acceptance: the first command (the exact AC-12 form) exits 0; the second exits 0 and prints `D2_CRLF True D3_LINE_LIMIT True ENTRY_DELIVERY True`.

### Phase 8 — Acceptance-Criteria Check-Off

Each task in this phase edits one checkbox in `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` from `- [ ] AC-N ` to `- [x] AC-N ` (Edit tool, one replacement), only when the cited evidence exists and meets its acceptance; otherwise the checkbox is left unchanged and the reason is recorded. Every task appends one line `AC-N: CHECKED <evidence paths>` or `AC-N: UNCHECKED <reason>` to FEATURE/evidence/other/ac-checkoff.TS.md (one artifact for the phase, TS fixed at P8-T1).

- [ ] [P8-T1] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-1 checkbox when P5-T2 and P6-T4 show `test_constants_match_typescript_values` passing.
- [ ] [P8-T2] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-2 checkbox when P5-T2 shows all 16 tests of `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` passing.
- [ ] [P8-T3] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-3 checkbox when P1-T1 shows 11 cases with the required keys and P5-T2 shows `test_gitignore_merge_fixture_parity` passing; the entry notes the PD3 location.
- [ ] [P8-T4] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-4 checkbox when P2-T3 and P6-T10 show `claude-gitignore-merge-parity.test.ts` passing (12 tests).
- [ ] [P8-T5] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-5 checkbox when the AC-3 and AC-4 evidence passes (the Python fixture test also asserts the two block entries per case).
- [ ] [P8-T6] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-6 checkbox when P5-T2 shows delivery tests D1, D2, and D3 passing.
- [ ] [P8-T7] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-7 checkbox when P5-T2 shows delivery test D4 passing.
- [ ] [P8-T8] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-8 checkbox when P5-T2 shows delivery tests D5 through D8 passing.
- [ ] [P8-T9] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-9 checkbox when P5-T2 shows delivery tests D9, D10, and D11 passing.
- [ ] [P8-T10] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-10 checkbox when P5-T2 shows delivery test D12 passing.
- [ ] [P8-T11] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-11 checkbox when P2-T1 lists D1 through D9 and D11 through D14 as failing, P5-T2 lists them passing, and P6-T10 shows the existing `claude-gitignore-merge.test.ts` and `claude-gitignore-delivery.test.ts` passing.
- [ ] [P8-T12] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-12 checkbox when P5-T2 shows D13 and D14 passing and P7-T7's first command exited 0.
- [ ] [P8-T13] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-13 checkbox when P5-T2 shows F1 and F2 passing.
- [ ] [P8-T14] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-14 checkbox when P2-T1 lists F3 as failing and P5-T2 lists it passing.
- [ ] [P8-T15] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-15 checkbox when P5-T2 shows F4, F5, and F6 passing.
- [ ] [P8-T16] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-16 checkbox when P4-T2 passed and P6-T10 shows the adapter suite (29 tests, including T1 through T6) passing.
- [ ] [P8-T17] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-17 checkbox when P5-T2 shows `test_local_runtime_directories_match_typescript` and `test_local_runtime_directories_comparison_detects_divergence` passing.
- [ ] [P8-T18] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-18 checkbox when P6-T4 shows the pack-selection and pack end-to-end suites passing and P7-T6 met its acceptance; the entry records the PD2 narrowing.
- [ ] [P8-T19] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-19 checkbox when P7-T3 shows every count at most 500.
- [ ] [P8-T20] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-20 checkbox when P7-T4 printed nothing for both commands; P9-T3 re-confirms the exact spec form after the commit.
- [ ] [P8-T21] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-21 checkbox when P7-T5 printed nothing for the diff and status commands and its pytest exited 0.
- [ ] [P8-T22] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-22 checkbox when P6-T5 and P7-T1 met their thresholds.
- [ ] [P8-T23] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-23 checkbox when P4-T4 passed, P6-T11 exited 0, and P7-T2 met its thresholds.
- [ ] [P8-T24] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-24 checkbox when P6-T1 through P6-T6 passed in the final uninterrupted loop iteration with no `PRE-EXISTING ONLY` outcome.
- [ ] [P8-T25] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-25 checkbox when P6-T7 through P6-T10 passed in the final uninterrupted loop iteration, P6-T7 ran the format script (not its skip branch), and its hash outputs matched.
- [ ] [P8-T26] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` AC-26 checkbox when P7-T7's second command printed `D3_LINE_LIMIT True` and `ENTRY_DELIVERY True`; the entry notes that the feature-review inspection named in AC-26 remains with the orchestrator (PD10).
- [ ] [P8-T27] Verify the check-off state of `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md` against the artifact, and record the result in FEATURE/evidence/other/ac-checkoff.TS.md.
      Commands: `git grep --no-index -c -F -e "- [x] AC-" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `git grep --no-index -c -F -e "- [ ] AC-" -- docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`.
      Acceptance: the first count equals the number of `CHECKED` lines in the artifact and the second equals the number of `UNCHECKED` lines (a zero count prints nothing and exits 1); the two sum to 26. Expected outcome when no PRE-EXISTING failure exists: 26 and nothing, with `EXIT_CODE: 1` and `ExpectedExitCode: 1` recorded (the last grep's exit code).

### Phase 9 — Commit and Push

- [ ] [P9-T1] Update `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md` so every task through P8-T27 whose artifact exists and meets its acceptance shows `[x]`, then stage the implementation, the feature folder, and the promoted lifecycle record `docs/features/potential/promoted/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`, and record FEATURE/evidence/other/p9-t1.TS.md.
      Commands: `git add scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts extensions/drm-copilot/jest.config.cjs tests/fixtures/push_down/gitignore-merge-parity.json tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790 docs/features/potential/promoted/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`; `git diff --cached --name-only`; `git status --porcelain -- scripts tests extensions docs/features/potential docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: `git add` exits 0. Allow-list: every path in the cached name list belongs to this set, and no path outside it appears: the 15 implementation paths in the `git add` command above; `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md`; `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md`; `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md`; `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md`; any file under `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/evidence/`; and `docs/features/potential/promoted/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`. The allow-list holds in both start states: when the orchestrator has already committed the feature folder and the promoted record (the expected state), `issue.md`, the research file, and the promoted record are unchanged and do not appear; when they are untracked, they appear and are permitted. In the scoped porcelain output every line has a non-space first column and a space second column (staged, with no unstaged change) and no line begins with `??`. Any other line stops the task, because it is an out-of-scope or unstaged change. If a hook denies `git add`, stop and report the denial text verbatim. The P9-T1 artifact is written after staging, is not committed, and is left for the orchestrator's next commit.
- [ ] [P9-T2] Commit the staged change on `bug/issue-507-python-push-down-divergence-follow-ups-790`, and record FEATURE/evidence/other/p9-t2.TS.md.
      Commands: `git commit -m "fix(790): port managed gitignore merge to Python push-down and exclude runtime subtrees" -m "F-507-1: add push_down_claude_gitignore_merge with merge_claude_gitignore and deliver_destination_gitignore, called after the engine copy. F-507-2: exclude .claude/state and .claude/worktrees by source-relative prefix in the Python and TypeScript ExcludingFileSystem. Move _resolve_published_paths to push_down_claude_pack_selection.resolve_published_paths. Add the claude-filesystem-adapter.ts jest threshold." --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_01RsMhy8je7BeARkv8LPcpSa"`; `git log -1 --format=%H%n%s`; `git status --porcelain -- scripts tests extensions docs/features/potential docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research`.
      Acceptance: the commit exits 0; `git log` prints the new SHA and the subject line above; the scoped porcelain output is empty. The pathspec excludes the P9 artifacts under FEATURE/evidence/ and the plan file's P9 checkbox states, which are written after staging and are left for the orchestrator's next commit. The two trailer values are the planning-time attribution; when the executor's runtime prescribes different attribution lines, it uses those and records them. If a hook denies the commit, stop and report the denial text verbatim.
- [ ] [P9-T3] Post-commit scope checks in the exact spec form for AC-20 and AC-21, and record FEATURE/evidence/qa-gates/scope-post-commit.TS.md.
      Commands: `git diff --name-only origin/main...HEAD -- scripts/dev_tools/push_down_copilot_customizations_filesystem.py scripts/dev_tools/push_down_copilot_customizations.py scripts/dev_tools/push_down_codex_filesystem.py scripts/dev_tools/push_down_codex_and_agents_customizations.py scripts/dev_tools/push_down_claude_exclusion_filter.py extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`; `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/resources .claude .github .codex .agents`; `git status --porcelain -- scripts tests extensions docs/features/potential docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research`.
      Acceptance: both diffs print nothing and exit 0; the scoped porcelain output is empty (the commit holds every in-scope change). P9 artifacts under FEATURE/evidence/ and the plan file's P9 checkbox states are excluded by the pathspec and are left for the orchestrator's next commit. Any diff output stops the plan before the push; the listed paths are reported to the orchestrator, and the AC-20 or AC-21 check-off is reported as invalid.
- [ ] [P9-T4] Push the branch `bug/issue-507-python-push-down-divergence-follow-ups-790` to `origin`, and record FEATURE/evidence/other/p9-t4.TS.md.
      Commands: `git push -u origin bug/issue-507-python-push-down-divergence-follow-ups-790`; `git rev-parse HEAD`; `git ls-remote origin refs/heads/bug/issue-507-python-push-down-divergence-follow-ups-790`.
      Acceptance: the push exits 0; the SHA printed by `git ls-remote` equals `git rev-parse HEAD`. A rejected push (non-fast-forward) stops the task and is reported; no force push is used. This artifact and the P9 checkbox states are written after the commit and are left for the orchestrator's next commit; the executor creates no further commit.

## Appendix A — Production Code

### A1 — `scripts/dev_tools/push_down_claude_gitignore_merge.py` (new, complete content)

```python
"""Destination ``.gitignore`` merge and delivery for the Claude push-down.

Purpose:
    Port ``mergeClaudeGitignore`` from
    ``extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`` and
    ``deliverDestinationGitignore`` from ``claude-customizations.ts`` so a
    Python push-down leaves the same drm-copilot managed ignore block in the
    destination ``.gitignore`` as the TypeScript push-down (issue #790).

Placement (decision D3):
    ``deliver_destination_gitignore`` lives in this module rather than in
    ``push_down_claude_customizations`` because the entry module is at the
    500-line limit. TypeScript keeps the delivery in its entry module.

CRLF limitation (decision D2):
    ``RealPushDownFileSystem.read_text`` applies universal-newline translation.
    A CRLF destination ``.gitignore`` that already holds an up-to-date block is
    therefore read as LF text equal to the merged text, is not rewritten, and
    keeps its CRLF line endings. TypeScript reads raw text and rewrites such a
    file as LF. Whenever any change is needed, both implementations write
    LF-only text.

Side Effects:
    ``merge_claude_gitignore`` is pure. ``deliver_destination_gitignore``
    performs I/O only through the injected ``PushDownFileSystem``.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_exclusion_manifest import (
        SkippedPath,
        find_first_match,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_exclusion_manifest import SkippedPath, find_first_match

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )
    from scripts.dev_tools.push_down_exclusion_manifest import ExclusionManifest

__all__ = [
    "GITIGNORE_BEGIN_SENTINEL",
    "GITIGNORE_END_SENTINEL",
    "GITIGNORE_RELATIVE_PATH",
    "MANAGED_IGNORE_ENTRIES",
    "deliver_destination_gitignore",
    "merge_claude_gitignore",
]

# Destination-relative path of the file this module merges.
GITIGNORE_RELATIVE_PATH = ".gitignore"
# Lines that open and close the drm-copilot managed ignore block.
GITIGNORE_BEGIN_SENTINEL = "# BEGIN drm-copilot managed ignores"
GITIGNORE_END_SENTINEL = "# END drm-copilot managed ignores"
# Runtime-state directories the push-down manages, in emission order.
MANAGED_IGNORE_ENTRIES: tuple[str, ...] = (".claude/state/", ".codex/state/")

_LINE_SEPARATOR = "\n"
_LINE_ENDING = re.compile(r"\r\n?")


def _to_lines(normalized: str) -> list[str]:
    """Split LF text into lines, dropping the one empty element a final LF leaves."""

    if normalized == "":
        return []
    lines = normalized.split(_LINE_SEPARATOR)
    if lines[-1] == "":
        lines.pop()
    return lines


def _to_document(lines: list[str]) -> str:
    """Join lines with LF and terminate the document with exactly one LF."""

    return _LINE_SEPARATOR.join(lines) + _LINE_SEPARATOR


def _managed_block() -> list[str]:
    """Return the managed block, sentinels included, as a list of lines."""

    return [GITIGNORE_BEGIN_SENTINEL, *MANAGED_IGNORE_ENTRIES, GITIGNORE_END_SENTINEL]


def _append_managed_block(lines: list[str]) -> str:
    """Append the block after one blank line, or return it alone for no content."""

    trimmed = list(lines)
    while trimmed and trimmed[-1] == "":
        trimmed.pop()
    if not trimmed:
        return _to_document(_managed_block())
    return _to_document([*trimmed, "", *_managed_block()])


def merge_claude_gitignore(current_text: str) -> str:
    """Merge the managed ignore block into destination ``.gitignore`` text.

    Args:
        current_text (str): Current destination text; ``""`` represents an
            absent file.

    Returns:
        str: LF-only, newline-terminated merged text. Applying the function to
        its own output returns that output unchanged.
    """

    lines = _to_lines(_LINE_ENDING.sub(_LINE_SEPARATOR, current_text))
    if GITIGNORE_BEGIN_SENTINEL not in lines:
        return _append_managed_block(lines)
    begin_index = lines.index(GITIGNORE_BEGIN_SENTINEL)
    # Only an END sentinel at or after the first BEGIN closes the block; without
    # one, the block is the BEGIN line alone and later lines are kept.
    following = lines[begin_index:]
    end_index = (
        begin_index + following.index(GITIGNORE_END_SENTINEL)
        if GITIGNORE_END_SENTINEL in following
        else begin_index
    )
    return _to_document(
        [*lines[:begin_index], *_managed_block(), *lines[end_index + 1 :]]
    )


def deliver_destination_gitignore(
    fs: PushDownFileSystem,
    destination_root: Path,
    manifest: ExclusionManifest | None,
) -> SkippedPath | None:
    """Merge the managed block into ``<destination>/.gitignore`` after the copy.

    Args:
        fs (PushDownFileSystem): Raw injected adapter (not a decorator), so the
            exclusion write guard does not apply to this write.
        destination_root (Path): Destination workspace root.
        manifest (ExclusionManifest | None): Destination exclusion manifest.

    Returns:
        SkippedPath | None: The skip record when a manifest entry matches
        ``.gitignore`` (no read and no write are performed); otherwise ``None``.

    Side Effects:
        Reads the destination ``.gitignore`` and writes it only when the merged
        text differs from the text read.
    """

    destination_path = destination_root / GITIGNORE_RELATIVE_PATH
    entry = (
        None if manifest is None else find_first_match(manifest, GITIGNORE_RELATIVE_PATH)
    )
    if entry is not None:
        return SkippedPath(
            relative_path=GITIGNORE_RELATIVE_PATH,
            entry=entry.normalized,
            line=entry.line,
            destination_status="present" if fs.is_file(destination_path) else "absent",
        )
    current_text = fs.read_text(destination_path) if fs.is_file(destination_path) else ""
    merged_text = merge_claude_gitignore(current_text)
    if merged_text != current_text:
        fs.write_text(destination_path, merged_text)
    return None
```

Black may rewrap long lines; P5-T1 applies black before the gates. Pyright strict must accept the `destination_status` literal; if it reports a literal-type mismatch, bind the value to a variable annotated with `DestinationStatus` imported under `TYPE_CHECKING` from `scripts.dev_tools.push_down_exclusion_manifest`.

### A2 — `scripts/dev_tools/push_down_claude_pack_selection.py` (append after `assert_single_csharp_toolchain`)

```python


def resolve_published_paths(
    *,
    packs: frozenset[str] | None,
    manifest_dir: Path,
    fs: PushDownFileSystem,
) -> frozenset[str] | None:
    """Compute the published `.claude`-relative path set for a pack selection.

    Purpose:
        Load the selected pack manifests, compute the union of their paths
        (always including ``core``), and assert C# mutual exclusion. Moved from
        ``push_down_claude_customizations`` (issue #790) to keep the entry
        module under the 500-line limit.

    Args:
        packs (frozenset[str] | None): Selected pack names, or ``None``/empty
            for the publish-everything default.
        manifest_dir (Path): Directory holding the ``<pack>.json`` manifests.
        fs (PushDownFileSystem): Adapter used to read the manifest files.

    Returns:
        frozenset[str] | None: The published paths, or ``None`` to signal the
        publish-everything default (no manifest is read).

    Raises:
        ManifestError: When a manifest is missing or malformed, or both C#
            variants are selected.
    """

    if not packs:
        return None
    manifests = load_pack_manifests(manifest_dir, packs, fs)
    published = compute_published_paths(packs, manifests)
    # compute_published_paths returns None only for an empty selection, which
    # the early return excludes; an empty set keeps the C# check concrete.
    empty: frozenset[str] = frozenset()
    effective_published = published if published is not None else empty
    assert_single_csharp_toolchain(effective_published, packs)
    return effective_published
```

`Path` and `PushDownFileSystem` are already imported under `TYPE_CHECKING` in this module (lines 45-50), and `from __future__ import annotations` is present (line 39).

### A3 — `scripts/dev_tools/push_down_claude_customizations.py` replacements

- E1 (imports, both branches). In the `try` branch, replace the `from scripts.dev_tools.push_down_claude_pack_selection import (...)` block (planning-time lines 50-58) with:

```python
    from scripts.dev_tools.push_down_claude_gitignore_merge import (
        deliver_destination_gitignore,
    )
    from scripts.dev_tools.push_down_claude_pack_selection import (
        CSharpVariant,
        ManifestError,
        MemoryMode,
        resolve_published_paths,
    )
```

  In the fallback branch, replace the `from dev_tools.push_down_claude_pack_selection import (...)` block (planning-time lines 91-99) with the same text using the `dev_tools.` prefix instead of `scripts.dev_tools.`. `PackManifest`, `assert_single_csharp_toolchain`, `compute_published_paths`, and `load_pack_manifests` are used only inside the removed function and are dropped.
- E2 (removal). Delete the whole `def _resolve_published_paths(...)` function and the two blank lines after it (planning-time lines 191-241), so `def push_down_customizations(` follows `_passthrough_rewrite` after two blank lines.
- E3 (call). Replace

```python
    published_paths = _resolve_published_paths(
        packs=packs,
        bundle_root=effective_bundle,
        fs=fs,
    )
```

  with

```python
    published_paths = resolve_published_paths(
        packs=packs,
        manifest_dir=effective_bundle / PACK_MANIFEST_SUBDIR,
        fs=fs,
    )
```

- E4 (delivery). Replace

```python
    if manifest is None or not isinstance(engine_fs, ExclusionFilterFileSystem):
        return extend_summary(summary, None)
    report = build_exclusion_report(manifest, engine_fs.skipped)
```

  with

```python
    # Post-copy delivery through the raw adapter, after the summary artifact
    # write and before the exclusion report is appended (issue #790).
    gitignore_skip = deliver_destination_gitignore(fs, destination_root, manifest)
    if manifest is None or not isinstance(engine_fs, ExclusionFilterFileSystem):
        return extend_summary(summary, None)
    skipped = [*engine_fs.skipped]
    if gitignore_skip is not None:
        skipped.append(gitignore_skip)
    report = build_exclusion_report(manifest, skipped)
```

- E5 (docstring of `push_down_customizations`). After the paragraph ending "destination layout, matching the TypeScript push-down." insert one blank line and:

```text
        After the copy and the summary artifact write,
        ``deliver_destination_gitignore`` merges the managed ignore block into
        the destination ``.gitignore`` through the raw adapter, matching the
        TypeScript push-down. A destination exclusion-manifest entry matching
        ``.gitignore`` suppresses that read and write; the skip is reported
        after the enumeration skips.
```

### A4 — `scripts/dev_tools/push_down_claude_filesystem.py` replacements

- G1 (constant). After `REPO_MEMORY_SCOPE = "repo"` (planning-time line 62) insert:

```python
# Source-relative directories holding machine-local runtime state; nothing below
# them is published (issue #790). Mirrors claude-filesystem-adapter.ts.
LOCAL_RUNTIME_RELATIVE_DIRECTORIES: tuple[str, ...] = (
    ".claude/state",
    ".claude/worktrees",
)
```

- G2 (predicate). After the `_source_relative_posix` method (planning-time lines 276-290) insert:

```python
    def _is_local_runtime_path(self, path: Path) -> bool:
        """Return whether a path is a local runtime directory or lies below one."""

        relative = self._source_relative_posix(path)
        if relative is None:
            return False
        return any(
            relative == directory or relative.startswith(directory + "/")
            for directory in LOCAL_RUNTIME_RELATIVE_DIRECTORIES
        )
```

- G3 (`list_files`). Replace the docstring first line and filter so the method reads:

```python
    def list_files(self, root: Path) -> list[Path]:
        """Return inner list_files output with all active filters applied.

        Drops local runtime directories first, then paths in
        ``EXCLUDED_RELATIVE_PATHS``, non-general agent memories, files outside
        the published-pack set, and memories excluded by the memory mode.
        """

        # Runtime directories are dropped before any filter that reads content.
        return [
            p
            for p in self._inner.list_files(root)
            if not self._is_local_runtime_path(p)
            and p.resolve() not in self._excluded
            and self._is_pack_included(p)
            and self._is_scope_included(p)
            and self._is_memory_mode_included(p)
        ]
```

### A5 — `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` replacements

- H1 (constant). After the `export { ... } from "./claude-memory-scope";` block (planning-time lines 37-43) insert:

```ts
/**
 * Source-relative directories that hold machine-local runtime state.
 *
 * Nothing beneath them is published (issue #790). Mirrors
 * `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` in `push_down_claude_filesystem.py`.
 */
export const LOCAL_RUNTIME_RELATIVE_DIRECTORIES: ReadonlyArray<string> = [
  ".claude/state",
  ".claude/worktrees",
];
```

- H2 (predicate). After the `sourceRelativePosix` method (planning-time lines 163-171) insert:

```ts
  /**
   * Return whether a path is a local runtime directory or lies below one.
   *
   * @param path An absolute candidate POSIX path from the inner adapter.
   * @returns True when the source-relative path is in a runtime directory.
   */
  private isLocalRuntimePath(path: string): boolean {
    const relative = this.sourceRelativePosix(path);
    if (relative === null) {
      return false;
    }
    return LOCAL_RUNTIME_RELATIVE_DIRECTORIES.some(
      (directory) =>
        relative === directory || relative.startsWith(`${directory}/`),
    );
  }
```

- H3 (`listFiles`). Replace the method body so it reads:

```ts
  listFiles(root: string): string[] {
    // Drop runtime directories first, then apply hard exclusions, pack
    // selection, agent-memory scope, and memory mode.
    return this.inner
      .listFiles(root)
      .filter(
        (p) =>
          !this.isLocalRuntimePath(p) &&
          !this.excluded.has(normalizePosix(p)) &&
          this.isPackIncluded(p) &&
          this.isScopeIncluded(p) &&
          this.isMemoryModeIncluded(p),
      );
  }
```

### A6 — `extensions/drm-copilot/jest.config.cjs` entry (insert after the `"./src/lib/push-down/claude-customizations.ts"` entry)

```js
    // Issue #790: the runtime-directory filter added to the Claude filesystem
    // adapter. This map carries no `global` key, so the file is gated only by
    // its own entry here.
    "./src/lib/push-down/claude-filesystem-adapter.ts": {
      lines: 85,
      branches: 75,
    },
```

## Appendix B — `tests/fixtures/push_down/gitignore-merge-parity.json` (complete content)

```json
{
  "cases": [
    {
      "name": "absent",
      "current": "",
      "expected": "# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "content-without-block",
      "current": "node_modules/\n*.log\n",
      "expected": "node_modules/\n*.log\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "up-to-date-block",
      "current": "node_modules/\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n",
      "expected": "node_modules/\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "stale-block-with-surrounding-content",
      "current": "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n# END drm-copilot managed ignores\ncoverage/\n",
      "expected": "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\ncoverage/\n"
    },
    {
      "name": "duplicate-entry-outside-block",
      "current": ".claude/state/\nbuild/\n",
      "expected": ".claude/state/\nbuild/\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "no-trailing-newline",
      "current": "node_modules/",
      "expected": "node_modules/\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "crlf-input",
      "current": "node_modules/\r\n*.log\r\n",
      "expected": "node_modules/\n*.log\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "lone-cr-input",
      "current": "node_modules/\r*.log\r",
      "expected": "node_modules/\n*.log\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "begin-without-end",
      "current": "dist/\n# BEGIN drm-copilot managed ignores\nstale-entry/\n",
      "expected": "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\nstale-entry/\n"
    },
    {
      "name": "end-before-begin",
      "current": "# END drm-copilot managed ignores\nkeep/\n# BEGIN drm-copilot managed ignores\nold/\n# END drm-copilot managed ignores\n",
      "expected": "# END drm-copilot managed ignores\nkeep/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    },
    {
      "name": "multiple-trailing-blank-lines",
      "current": "node_modules/\n\n\n\n",
      "expected": "node_modules/\n\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"
    }
  ]
}
```

Derivation of each `expected` value from `claude-gitignore-merge.ts` lines 112-166: cases without an exact BEGIN line take the append path (trailing empty lines removed, one empty separator line, then the block); `stale-block-with-surrounding-content` and `end-before-begin` replace the first BEGIN through the first END at or after it; `begin-without-end` replaces the BEGIN line alone and keeps `stale-entry/`; `up-to-date-block` is a fixed point. P2-T3 confirms every value against the TypeScript implementation before any Python code exists.

## Appendix C — Test Specifications

All Python tests follow Arrange-Act-Assert, carry a one-line docstring, use in-memory filesystems only, and create no temporary file. No test is parametrized. In this appendix BLOCK_TEXT denotes the Python literal `"# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n# END drm-copilot managed ignores\n"`.

### C1 — `tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py` (16 tests)

The module defines `_module()` returning `importlib.import_module("scripts.dev_tools.push_down_claude_gitignore_merge")` and the module constant `BLOCK_TEXT`. Each test calls `_module()` inside its body.

1. `test_constants_match_typescript_values`: `GITIGNORE_RELATIVE_PATH == ".gitignore"`, `GITIGNORE_BEGIN_SENTINEL == "# BEGIN drm-copilot managed ignores"`, `GITIGNORE_END_SENTINEL == "# END drm-copilot managed ignores"`, `MANAGED_IGNORE_ENTRIES == (".claude/state/", ".codex/state/")`.
2. `test_merge_absent_input_returns_bare_block`: `merge("") == BLOCK_TEXT`.
3. `test_merge_appends_block_after_one_blank_line`: `merge("node_modules/\n*.log\n") == "node_modules/\n*.log\n\n" + BLOCK_TEXT`.
4. `test_merge_replaces_stale_block_in_place`: the `stale-block-with-surrounding-content` input of Appendix B returns its `expected`.
5. `test_merge_up_to_date_block_is_fixed_point`: `merge("node_modules/\n\n" + BLOCK_TEXT) == "node_modules/\n\n" + BLOCK_TEXT`.
6. `test_merge_is_idempotent`: for each of `""`, `"a/\n"`, `BLOCK_TEXT`, `"x\r\ny\r\n"`, `"# BEGIN drm-copilot managed ignores\nz/\n"`, `merge(merge(x)) == merge(x)`.
7. `test_merge_input_without_trailing_newline`: `merge("node_modules/") == "node_modules/\n\n" + BLOCK_TEXT`.
8. `test_merge_normalizes_crlf_input`: `merge("node_modules/\r\n*.log\r\n") == "node_modules/\n*.log\n\n" + BLOCK_TEXT` and `"\r" not in` the result.
9. `test_merge_normalizes_lone_cr_input`: `merge("node_modules/\r*.log\r") == "node_modules/\n*.log\n\n" + BLOCK_TEXT`.
10. `test_merge_blank_only_input_returns_bare_block`: `merge("\n\n") == BLOCK_TEXT`.
11. `test_merge_strips_multiple_trailing_blank_lines_before_append`: `merge("node_modules/\n\n\n\n") == "node_modules/\n\n" + BLOCK_TEXT`.
12. `test_merge_begin_without_end_keeps_later_lines`: the `begin-without-end` input of Appendix B returns its `expected`.
13. `test_merge_ignores_end_before_begin`: the `end-before-begin` input of Appendix B returns its `expected`.
14. `test_merge_keeps_managed_entry_duplicated_outside_block`: `merge(".claude/state/\nbuild/\n") == ".claude/state/\nbuild/\n\n" + BLOCK_TEXT` and the result contains `.claude/state/` on exactly two lines.
15. `test_merge_sentinel_with_trailing_whitespace_does_not_match`: for `current = "# BEGIN drm-copilot managed ignores \n.claude/state/\n# END drm-copilot managed ignores\n"`, `merge(current) == current + "\n" + BLOCK_TEXT`.
16. `test_merge_considers_only_first_begin_sentinel`: for `current = BLOCK_TEXT + "x/\n# BEGIN drm-copilot managed ignores\ny/\n"`, `merge(current) == current` and the result has exactly two lines equal to the BEGIN sentinel.

### C2 — `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py` (1 test)

Module constants: `REPO_ROOT = Path(__file__).resolve().parents[3]`, `FIXTURE_PATH = Path("tests/fixtures/push_down/gitignore-merge-parity.json")`, and `EXPECTED_CASE_NAMES` holding the eleven Appendix B names in order. `test_gitignore_merge_fixture_parity` loads the fixture (typed through `cast("dict[str, Any]", ...)` as at `tests/scripts/dev_tools/test_push_down_claude_parity.py` lines 402-405), imports the merge module with `importlib` inside the body, and asserts: the case names equal `EXPECTED_CASE_NAMES`; every case has exactly the keys `name`, `current`, `expected`; for every case `merge_claude_gitignore(case["current"]) == case["expected"]` (message: the case name); and for every case, the lines of `expected` strictly between the first BEGIN sentinel line and the first END sentinel line after it equal `[".claude/state/", ".codex/state/"]` (AC-5).

### C3 — `tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py` (14 tests)

Imports at module level: `scripts.dev_tools.push_down_claude_customizations as entry`, `SkippedPath` from `scripts.dev_tools.push_down_exclusion_manifest`, and `MemoryFile`, `RecordingFileSystem` from `tests.scripts.dev_tools.push_down_customizations_test_support`. It does not import `push_down_claude_gitignore_merge`. Constants: `SOURCE = Path("C:/repo")`, `DEST = Path("C:/dest")`, `BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"`, `MANIFEST = DEST / ".push-down-exclusions"`, `GITIGNORE = DEST / ".gitignore"`, `QUALITY = ".claude/rules/quality-tiers.md"`, `PYTHON = ".claude/rules/python.md"`, `BLOCK_TEXT`. Helpers copied in pattern from `tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py` lines 58-137: `ObservingFileSystem` (records `read_paths` and `write_paths`), `UniversalNewlineFileSystem(ObservingFileSystem)` whose `read_text` returns `re.sub(r"\r\n?", "\n", super().read_text(path))` (PD8), `_empty_lister`, `_seed(source, destination=None, manifest=None, fs_class=ObservingFileSystem)`, and `_push(fs, packs=None)` (with `artifact_root=DEST` and `list_entries=_empty_lister`). No test calls `main`.

- D1 `test_unscoped_push_down_writes_block_into_absent_gitignore`: seed `{PYTHON: "py\n"}`; after `_push`, `fs.files[GITIGNORE].content == BLOCK_TEXT`.
- D2 `test_pack_scoped_push_down_writes_block_into_gitignore`: seed `{".claude/settings.json": "{}\n"}` plus `BUNDLE / "pack-manifests/core.json"` holding `{"name": "core", "label": "Core", "paths": [".claude/settings.json"]}`; `_push(fs, packs=frozenset({"core"}))`; `fs.files[GITIGNORE].content == BLOCK_TEXT`.
- D3 `test_push_down_preserves_unrelated_gitignore_lines_in_order`: destination `{".gitignore": "node_modules/\n*.log\n"}`; content after push `== "node_modules/\n*.log\n\n" + BLOCK_TEXT`.
- D4 `test_second_push_down_performs_no_gitignore_write`: first push, assert content `== BLOCK_TEXT`; second push; `fs.write_paths.count(GITIGNORE) == 1`.
- D5 `test_manifest_skip_with_absent_gitignore_reads_and_writes_nothing`: manifest `".gitignore\n"`; `GITIGNORE not in fs.read_paths`, `GITIGNORE not in fs.write_paths`, `GITIGNORE not in fs.files`, and `summary.exclusions.skipped[-1] == SkippedPath(relative_path=".gitignore", entry=".gitignore", line=1, destination_status="absent")`.
- D6 `test_manifest_skip_with_present_gitignore_keeps_bytes`: destination `{".gitignore": "local\n"}`, manifest `"# keep\n.gitignore\n"`; no read and no write of `GITIGNORE`; content still `"local\n"`; last skip record has `line == 2` and `destination_status == "present"`.
- D7 `test_gitignore_skip_follows_enumeration_skips_in_artifact`: source `{QUALITY: "q\n", PYTHON: "py\n"}`, manifest `QUALITY + "\n.gitignore\n"`; `[s.relative_path for s in summary.exclusions.skipped] == [QUALITY, ".gitignore"]`; the artifact JSON `exclusions.skipped` relative paths are in the same order; `exclusions["skipped_count"] == 2`; `exclusions["unmatched_entries"] == []`.
- D8 `test_exclusion_lines_report_gitignore_skip_after_enumeration_skip`: same seed as D7 via `_push`; `render_exclusion_lines(summary.exclusions)` (imported from `scripts.dev_tools.push_down_claude_exclusion_filter`; `main` prints exactly these lines, `scripts/dev_tools/push_down_claude_customizations.py` lines 492-494) equals `["push-down exclusion: skipped .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 1)", "push-down exclusion: skipped .gitignore (entry .gitignore, line 2)"]`. The test does not call `main`, because `main` uses the real directory lister.
- D9 `test_gitignore_delivery_follows_summary_artifact_write`: source `{PYTHON: "py\n"}`, manifest `".claude/agent-memory/**\n"`; with `artifact = Path(summary.artifact_path)`, the first index of `artifact` in `fs.write_paths` is less than the index of `GITIGNORE`, which is less than the last index of `artifact`.
- D10 `test_destination_validation_failure_writes_no_gitignore`: seed `{PYTHON: "py\n"}` then `fs.directories.discard(DEST)`; `pytest.raises(ValueError, match="Invalid destination")`; `GITIGNORE not in fs.write_paths`.
- D11 `test_gitignore_write_is_absent_from_summary_files_and_counts`: source `{PYTHON: "py\n"}`; `[r.relative_path for r in summary.files] == [PYTHON]`; `summary.created_count + summary.overwritten_count == 1`; `GITIGNORE in fs.files`.
- D12 `test_gitignore_written_through_raw_fs_with_active_manifest`: source `{QUALITY: "q\n", PYTHON: "py\n"}`, manifest `QUALITY + "\n"`; the push raises nothing; `fs.files[GITIGNORE].content == BLOCK_TEXT`.
- D13 `test_crlf_up_to_date_gitignore_is_not_rewritten`: `UniversalNewlineFileSystem`, destination `{".gitignore": BLOCK_TEXT.replace("\n", "\r\n")}`; `GITIGNORE in fs.read_paths`; `GITIGNORE not in fs.write_paths`; stored content still equals the CRLF text.
- D14 `test_crlf_stale_gitignore_is_rewritten_lf_only`: `UniversalNewlineFileSystem`, destination `{".gitignore": "node_modules/\r\n"}`; content after push `== "node_modules/\n\n" + BLOCK_TEXT` and contains no `"\r"`.

### C4 — `tests/scripts/dev_tools/test_push_down_claude_customizations.py` additions (6 tests)

Add `_load_filesystem_module()` returning `importlib.import_module("scripts.dev_tools.push_down_claude_filesystem")` and an `_empty_lister` typed as at `tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py` lines 38-43 and 91-94. Push tests pass `list_entries=_empty_lister`, `source_root=repo_root`, `artifact_root=destination_root`, with `repo_root = Path("/repo")` and `destination_root = Path("/dest")` and both in `fs.directories`.

- F1 `test_excluding_file_system_list_files_drops_local_runtime_directories`: inner files `/repo/.claude/state` (a file whose relative path equals the directory name), `/repo/.claude/state/batch-budget.json`, `/repo/.claude/worktrees/wt/a.md`, `/repo/.claude/rules/python.md`; `ExcludingFileSystem(inner, Path("/repo"), (), source_root=Path("/repo")).list_files(Path("/repo/.claude")) == [Path("/repo/.claude/rules/python.md")]`; `module.LOCAL_RUNTIME_RELATIVE_DIRECTORIES == (".claude/state", ".claude/worktrees")`.
- F2 `test_list_files_drops_runtime_paths_even_when_published`: same inner files without the bare `state` file; `published_paths=frozenset({".claude/state/batch-budget.json", ".claude/rules/python.md"})`; result `== [Path("/repo/.claude/rules/python.md")]`.
- F3 `test_push_down_excludes_claude_state_and_worktrees_subtrees`: source files `/repo/.claude/rules/python.md`, `/repo/.claude/state/batch-budget.json`, `/repo/.claude/state/current-session-id`, `/repo/.claude/worktrees/wt/.claude/settings.json`, `/repo/.claude/worktrees/wt/README.md`; `[r.relative_path for r in summary.files] == [".claude/rules/python.md"]`; no key of `fs.files` lies under `/dest/.claude/state` or `/dest/.claude/worktrees`.
- F4 `test_push_down_retains_lookalike_runtime_paths`: source files `/repo/.claude/statement.md`, `/repo/.claude/worktrees-notes.md`, `/repo/.claude/hooks/state/x.ps1`; all three relative paths are in `summary.files` and their destination files exist.
- F5 `test_push_down_still_publishes_general_agent_memory`: source file `/repo/.claude/agent-memory/orchestrator/general.md` with content `"---\nname: g\nmetadata:\n  scope: general\n---\nbody\n"`; `.claude/agent-memory/orchestrator/general.md` is in `summary.files` and its destination file exists. (No runtime-directory file is seeded here, so this retention test passes before and after the fix; F3 carries the exclusion assertion.)
- F6 `test_list_files_passes_paths_outside_source_root_through`: inner file `/other/.claude/state/x.json`; `ExcludingFileSystem(inner, Path("/repo"), (), source_root=Path("/repo")).list_files(Path("/other/.claude")) == [Path("/other/.claude/state/x.json")]`.

### C5 — `tests/scripts/dev_tools/test_push_down_claude_parity.py` changes

- Add constants `TS_FILESYSTEM_ADAPTER = "extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts"` and `PY_FILESYSTEM = "scripts/dev_tools/push_down_claude_filesystem.py"`.
- Generalize `_ts_root_folders` into `_ts_string_array(text, label, name)` with the messages `f"{label}: found zero {name} declarations"`, `f"{label}: {name} is not a bracketed literal"`, and `_literal_value(token, label, name)`; keep `_ts_root_folders(text, label)` as a one-line call with `name="ROOT_FOLDERS"`, so every existing test and message is unchanged.
- Add `_py_string_tuple(source, label, name)` returning the string elements of a tuple literal via `_py_assignment` and `_py_string`, raising `f"{label}: {name} is not a tuple literal"` otherwise.
- `test_local_runtime_directories_match_typescript`: set of the TypeScript `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` literals equals the set of the Python tuple, compared through `_assert_same(ts_dirs, py_dirs, TS_FILESYSTEM_ADAPTER, PY_FILESYSTEM)`; both sets have 2 members (spec decision D1; research "Numeric Derivation Evidence", Claim B).
- `test_local_runtime_directories_comparison_detects_divergence`: `ts_text = 'export const LOCAL_RUNTIME_RELATIVE_DIRECTORIES = [".claude/state"];\n'`, `py_text = 'LOCAL_RUNTIME_RELATIVE_DIRECTORIES = (".claude/state", ".claude/worktrees")\n'`; the extracted sets differ, and `_assert_same` raises `AssertionError` matching `r"synthetic\.ts.*synthetic\.py"`.

### C6 — `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` additions (3 tests)

Using the file's existing `_selection_module`, `RecordingFileSystem`, `_write_manifests`, `_manifest_payload`, and `MANIFEST_DIR_RELATIVE`, with `source_root = Path("/repo")` and `manifest_dir = source_root / MANIFEST_DIR_RELATIVE`:

- `test_resolve_published_paths_returns_none_without_selection`: with an empty `RecordingFileSystem`, both `packs=None` and `packs=frozenset()` return `None` (no manifest exists, so any read would raise).
- `test_resolve_published_paths_unions_selected_pack_with_core`: manifests `core` (`[".claude/settings.json"]`) and `python` (`[".claude/rules/python.md"]`); `packs=frozenset({"python"})` returns `frozenset({".claude/settings.json", ".claude/rules/python.md"})`.
- `test_resolve_published_paths_rejects_both_csharp_variants`: manifests `core`, `csharp-modern`, and `csharp-legacy` (each csharp manifest with `[".claude/rules/csharp.md"]`); `packs=frozenset({"csharp-modern", "csharp-legacy"})` raises `module.ManifestError` matching `"C# mutual exclusion"`.

### C7 — `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts` (2 test declarations, 12 tests)

Modeled on `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts`: imports `describe`, `expect`, `it` from `@jest/globals`, `node:fs`, `node:path`, `mergeClaudeGitignore` from `../../../src/lib/push-down/claude-gitignore-merge`, and `REPO_ROOT` from `./config-carriage.test-helpers`. It declares `GitignoreParityCase` (`name`, `current`, `expected`, all strings) and `GitignoreParityFixture` (`cases`), the narrowing guards `isRecord`, `isParityCase`, `isParityFixture`, a `loadFixture()` that reads `tests/fixtures/push_down/gitignore-merge-parity.json` through `REPO_ROOT` and throws on a malformed document, and `EXPECTED_CASE_NAMES` with the eleven Appendix B names in order. Inside `describe("issue #790: gitignore-merge behavioral parity fixture", ...)`: `it("carries the eleven named cases in order", ...)` asserts the names equal `EXPECTED_CASE_NAMES`; `it.each([...FIXTURE.cases])("reproduces the $name case", ...)` asserts `mergeClaudeGitignore(current)` is `expected`. The file states in its header comment that the same fixture is asserted by `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`.

### C8 — `extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` behavioral additions (5 tests, inside `describe("ExcludingFileSystem", ...)`)

Each uses `buildInMemoryFileSystem` and `new ExcludingFileSystem(inner, "/repo", [], { sourceRoot: "/repo" })` unless stated, and compares `[...listed].sort()` with a sorted expected array.

- T1 `it("excludes .claude/state files from enumeration", ...)`: files `/repo/.claude/state/budget.json`, `/repo/.claude/state/session/id.txt`, `/repo/.claude/rules/general.md`; `listFiles("/repo/.claude")` returns only the rule.
- T2 `it("excludes .claude/worktrees files from enumeration", ...)`: files `/repo/.claude/worktrees/wt/.claude/settings.json`, `/repo/.claude/worktrees/wt/README.md`, `/repo/.claude/rules/general.md`; only the rule.
- T3 `it("excludes runtime directories even when the published set lists them", ...)`: files `/repo/.claude/state/budget.json`, `/repo/.claude/rules/general.md`, `publishedPaths: new Set([".claude/state/budget.json", ".claude/rules/general.md"])`; only the rule.
- T4 `it("retains lookalike paths outside the runtime directories", ...)`: files `/repo/.claude/statement.md`, `/repo/.claude/worktrees-notes.md`, `/repo/.claude/hooks/state/x.ps1`; all three returned.
- T5 `it("passes a path outside the source root through the runtime-directory filter", ...)`: file `/other/.claude/state/x.json`; `listFiles("/other/.claude")` returns `["/other/.claude/state/x.json"]`.

### C9 — constant test added after the production export (P4-T3)

Add `LOCAL_RUNTIME_RELATIVE_DIRECTORIES` to the existing import from `../../../src/lib/push-down/claude-filesystem-adapter` and add, inside `describe("ExcludingFileSystem", ...)`, T6 `it("exports LOCAL_RUNTIME_RELATIVE_DIRECTORIES with the two runtime directories", ...)` asserting `[...LOCAL_RUNTIME_RELATIVE_DIRECTORIES]` equals `[".claude/state", ".claude/worktrees"]`.

# 2026-10-11-concurrent-children-share-scratchpad-file-names (Plan)

- **Issue:** #900
- **Branch:** bug/concurrent-children-share-scratchpad-file-names-900
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T12-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** minor-audit
- **Requirements source:** `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`, section `## Acceptance Criteria` (11 items; the sole acceptance-criteria source). `spec.md` and `user-story.md` are intentionally absent and must stay absent.
- **Scope source:** `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/research/scratch-file-naming.2026-10-11T10-45.md`, section `## Recommended Change Set`.

**Fail-closed evidence rule:** Every baseline, fail-before, targeted-verification, final-QC, and coverage-comparison step has its own artifact under `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/<kind>/`. If any required artifact is missing or lacks its required fields, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until that artifact exists. Every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose gate is expected to exit non-zero also carries `ExpectedExitCode: <int>` and records only that one gate. Artifacts never record a host absolute path: the executor worktree root is recorded as the literal token `WORKTREE_ROOT`.

**Evidence location:** All evidence lives under `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/`, `.../evidence/regression-testing/`, or `.../evidence/qa-gates/`. No path under `artifacts/` other than `artifacts/orchestration/` is used for evidence. Tool output that pytest writes under `artifacts/python/` through the project `addopts` value is tool output, not evidence.

**Scratch location for this plan:** `SCRATCH` means `<session scratchpad>/issue-900/`, the child-unique directory for this issue. This plan names no scratch or helper file: every command is run directly and its result is written straight to the named evidence artifact. If the executor needs a transient capture, it creates `SCRATCH` first and writes the capture under it; no file is ever written to the scratchpad root or under a fixed shared name. Artifacts record the literal token `SCRATCH`, never a host path.

**Binding constraints (operator):**
- Do not edit `.claude/rules/**`, `.github/instructions/**`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.codex/agents/*.toml`, any child-prompt template, or any plan-validator source. Do not modify any other feature folder's plans or evidence.
- PowerShell verification uses the PoshQC MCP tools only, plus PR CI evidence. No shell or PowerShell wrapper script is created or run. A PoshQC MCP result carries no per-test output, so no acceptance condition in this plan reads a count, percentage, or test name from it; only its call disposition is recorded. Pester per-test detail, including `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` (which reads `.claude/agents/atomic-executor.md`), is taken from the PR CI run at the CI gate handled by the later execution run.
- Commit and push at the end of every phase with `git push -u origin HEAD`. Never force-push. Delete no file. Create no GitHub issue.
- If a repository hook denies a staging, commit, or push command, record the denial text verbatim beside the affected task in this plan, leave that task unchecked, and do not bypass the hook.

**Known local failure (issue #510):** the node `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally on gitignored `.claude/state/**` files while passing in CI. This plan deselects that node from every combined pytest run and runs it alone in P0-T17, P3-T3, and P4-T5. The #510 signature is defined as: the node fails, and every assertion message it prints names a path beginning `.claude/state/` or `.claude\state\` (for example `Repo file missing from bundle: .claude\state\...`). A failure with that signature is recorded as pre-existing and is not a regression. Any other failure of that node is a regression.

**Coverage handling:** The change adds Markdown prose (no executable lines) and one test module. `pyproject.toml` `[tool.coverage.run]` omits `tests/*`, so the new module is outside the coverage denominator, and no file under `scripts/` or `src/` changes. Changed-line coverage is therefore not applicable: there are zero changed executable production lines, which P4-T7 verifies from the branch diff and working-tree status of `scripts/` and `src/` rather than asserting it. The coverage gate that can fail is a no-regression comparison: P0-T16 and P4-T4 run the same contract tests with `--cov=scripts.dev_tools.push_down_claude_customizations` (the production module those tests import, at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:274-276`), and P4-T7 requires the `TOTAL` row's `Stmts`, `Miss`, `Branch`, and `BrPart` values to be identical. The repository-wide 85% line and 75% branch thresholds are not evaluated by this single-module slice and are not changed by this work. No branch percentage is derived from the terminal row.

**Fixed names used below:**
- Feature folder: `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900`
- New test module: `tests/scripts/dev_tools/test_scratch_location_contracts.py` (content fixed in Appendix A)
- Primary sources and their bundled copies (pairs, in this order):
  1. `.claude/agents/atomic-planner.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`
  2. `.claude/agents/atomic-executor.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`
  3. `.agents/skills/atomic-planner/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`
  4. `.agents/skills/atomic-executor/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`
- Existing contract modules (the "five existing modules"): `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`, `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`.
- Inserted passages: "Planner passage" and "Executor passage", fixed verbatim in Appendix B.

**Observed facts the plan relies on (re-derived against the tree in this authoring pass):**
- `.claude/agents/atomic-planner.md`: `## Requirements` at line 50 with items 1-5 at lines 52-56; line 56 is `5. Do not execute implementation; produce the plan only.`; `## Preflight Validation` at line 58; `## Evidence Location Invariant` at line 68.
- `.claude/agents/atomic-executor.md`: `## Toolchain Commands` at line 74; line 83 is `Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files.`; `## Preflight Validation` at line 85; `## Evidence Location Invariant` at line 130.
- `.agents/skills/atomic-planner/SKILL.md`: `## Plan Requirements` at line 22; line 35 is `- free of placeholder text.`; `## Mandatory Preflight Loop` at line 37.
- `.agents/skills/atomic-executor/SKILL.md`: `## Execution Rules` at line 48; line 56 is ``5. Check off satisfied acceptance criteria in the authoritative requirement source file per `acceptance-criteria-tracking`.``; `## Non-Negotiable Constraints` at line 58.
- The four bundled copies carry the same anchor lines at the same line numbers (read in this pass).
- No file under `.claude/` or `.agents/` contains `SCRATCH`, `scratchpad`, `run-ps.sh`, `changed-line-coverage`, `region-probe`, or `cov-final`, and none of the four primary sources contains `issue-<issue-num>` or `Scratch Location`. The new module's negative test therefore passes before and after the change, and its other 14 tests fail before the change.
- `.gitattributes` line 1 is `* text=auto eol=lf`. `.gitignore` lines 69-70 ignore `.claude/agent-memory` and `.claude/state/`.
- `pyproject.toml`: `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` (line 116, no terminal reporter); `[tool.coverage.run]` `source = ["src", "scripts/dev_tools"]` and `omit` includes `tests/*` (lines 119-127); Pyright `typeCheckingMode = "strict"` with `tests` included (lines 143-153); Black `line-length = 88` (line 85); Ruff `line-length = 88` (line 89), the selected rule set includes `S` (line 100), and `tests/**/*` ignores only `S101` (line 106). Ruff `S105` therefore applies to the new test module, so no Appendix A constant name contains a segment such as `TOKEN`, `PASSWORD`, or `SECRET`; the two asserted-phrase constants are named `ISSUE_DIRECTORY_SEGMENT` and `LITERAL_MARKER_PHRASE`.
- Ruff `check` without `--no-fix` is a write-mode register entry (`scripts/dev_tools/plan_gate_observability.py:169-173`); this plan always passes `--no-fix`. Black is run in `--check` mode in every gate.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `CLAUDE.md` (repository root) in full and note the policy compliance reading order. No file is written by this task; the read is recorded in P0-T9 at `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/phase0-instructions-read.md`. Acceptance: the file was read in full before any later task.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full. Acceptance: read in full; the 500-line file limit, the toolchain loop, and the no-temporary-files rule for tests are noted.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full. Acceptance: read in full; the line >= 85% and branch >= 75% thresholds, the no-regression-on-changed-lines rule, and the test-location rule are noted.
- [x] [P0-T4] Read `.claude/rules/python.md` in full. Acceptance: read in full; the Black, Ruff, Pyright, and Pytest command forms are noted.
- [x] [P0-T5] Read `.claude/rules/python-suppressions.md` in full. Acceptance: read in full; the new test module is to carry no suppression comment.
- [x] [P0-T6] Read `.claude/rules/powershell.md` in full. Acceptance: read in full; the PoshQC MCP route for Pester is noted; no PowerShell file is edited by this plan.
- [x] [P0-T7] Read `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md` and use the Glob tool on `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/*.md`. Acceptance: `issue.md` carries `- Work Mode: minor-audit` and a `## Acceptance Criteria` section with exactly 11 unchecked `- [ ]` items; the Glob result lists no `spec.md` and no `user-story.md`.
- [x] [P0-T8] Read `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/research/scratch-file-naming.2026-10-11T10-45.md` in full. Acceptance: read in full; the `## Recommended Change Set` (8 edits, 1 new file) matches the "Fixed names used below" list in this plan.
- [x] [P0-T9] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the six policy files in the order read in P0-T1 through P0-T6), and an explicit list of every file read in P0-T1 through P0-T8. Acceptance: the artifact exists and lists all eight files.
- [x] [P0-T10] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/branch-commit-baseline.2026-10-11T10-38.md` from `git branch --show-current`, `git rev-parse HEAD`, and `git merge-base origin/main HEAD`, one `Command:`/`EXIT_CODE:` pair per command. Acceptance: each `EXIT_CODE: 0`; `Output Summary:` records the branch name `bug/concurrent-children-share-scratchpad-file-names-900`, the HEAD commit hash, and the merge-base commit hash.
- [x] [P0-T11] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/mirror-parity-baseline.2026-10-11T10-38.md` from `git hash-object --no-filters .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`. The command prints one 40-hex-digit hash per path in argument order, hashing raw bytes. Acceptance: `EXIT_CODE: 0`; `Output Summary:` records all eight hashes labelled by path, and hashes 1 and 2, 3 and 4, 5 and 6, and 7 and 8 are pairwise equal.
- [x] [P0-T12] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/line-endings-baseline.2026-10-11T10-38.md` from `git ls-files --eol .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`. Acceptance: `EXIT_CODE: 0`; the output has eight lines and `Output Summary:` records that each line carries `i/lf` and `w/lf`.
- [x] [P0-T13] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/black-check-baseline.2026-10-11T10-38.md` from `poetry run black --check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`. `--check` does not rewrite files. The success-case output ends with `5 files would be left unchanged.` Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` quoting the last output line; a non-zero exit is recorded as pre-existing baseline state with the files Black names.
- [x] [P0-T14] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/ruff-baseline.2026-10-11T10-38.md` from `poetry run ruff check --no-fix tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`. The success-case output is `All checks passed!` Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` quoting the last output line; a non-zero exit is recorded as pre-existing baseline state with the finding count.
- [x] [P0-T15] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/pyright-baseline.2026-10-11T10-38.md` from `poetry run pyright tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`. The success-case output contains the line `0 errors, 0 warnings, 0 informations`; other lines Pyright prints (venv or version notices) are not quoted, because they can carry a host path. Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` quoting the summary line.
- [x] [P0-T16] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools.push_down_claude_customizations --cov-branch --cov-report=term-missing -q`. The output prints a coverage table with the columns `Stmts`, `Miss`, `Branch`, `BrPart`, `Cover` and a `TOTAL` row, and a summary line of the form `N passed, M skipped, 1 deselected` (the `skipped` part appears only when M > 0). Acceptance: the artifact records the observed `EXIT_CODE:`; `Output Summary:` records the numeric passed, skipped, failed, and deselected counts, the numeric `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values of the `TOTAL` row, and the derived line percentage `(Stmts - Miss) / Stmts`; when the exit code is non-zero, the summary lists every failing node ID as pre-existing baseline state.
- [x] [P0-T17] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/issue-510-node-baseline.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`. Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` that classifies the result as exactly one of `PASS` (`1 passed`), `ISSUE-510 SIGNATURE` (failed, and every assertion message names a path beginning `.claude/state/` or `.claude\state\`), or `OTHER FAILURE` (any other failure, quoted verbatim).
- [x] [P0-T18] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/baseline/poshqc-claude-runtime-baseline.2026-10-11T10-38.md` from one call to the MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the executor worktree root and `scan_folders` set to `["tests/scripts/claude-runtime"]`. The result carries no per-test output. Acceptance: the artifact records `Command:` as `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=["tests/scripts/claude-runtime"]`, `EXIT_CODE: 0` when the call returned or non-zero when it raised, and an `Output Summary:` recording only the call disposition and the returned `ok` value; it records no test count, percentage, or test name.
- [x] [P0-T19] (Commit: `01204a1fe`; pushed, `git rev-list --count "@{u}..HEAD"` printed `0`. Note: the worktree isolation guard refused the unquoted `@{u}..HEAD` form as "too complex to verify"; the same command was run with the revision range quoted.) Commit and push Phase 0 for `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`: run `git add docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`, then `git commit -m "docs(900): record phase 0 baseline evidence"`, then `git push -u origin HEAD`. Acceptance: `git status --porcelain -- docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/` lists nothing other than this plan file (whose check-off for this task is written after the commit), and `git rev-list --count @{u}..HEAD` prints `0`. The new commit hash is recorded beside this task.

### Phase 1 — Contract Test and Fail-Before Evidence

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_scratch_location_contracts.py` with exactly the content in Appendix A. Acceptance: the file exists, its content equals Appendix A, and it carries no `noqa` or `type: ignore` comment.
- [x] [P1-T2] (Last line number reported: 275.) Read `tests/scripts/dev_tools/test_scratch_location_contracts.py` with the Read tool. Acceptance: the last line number reported is at or below 500; the number is recorded beside this task.
- [x] [P1-T3] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/new-module-black-check.2026-10-11T10-38.md` from `poetry run black --check tests/scripts/dev_tools/test_scratch_location_contracts.py`. `--check` does not rewrite files. The success-case output ends with `1 file would be left unchanged.` Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes that line. Appendix A is Black-stable, so an exit code of 1 means the file diverges from Appendix A: do not run Black in write mode; record the divergence beside this task, correct the file to equal Appendix A, and rerun this task's check command.
- [x] [P1-T4] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/new-module-ruff.2026-10-11T10-38.md` from `poetry run ruff check --no-fix tests/scripts/dev_tools/test_scratch_location_contracts.py`. Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes `All checks passed!`.
- [x] [P1-T5] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/new-module-pyright.2026-10-11T10-38.md` from `poetry run pyright tests/scripts/dev_tools/test_scratch_location_contracts.py`. Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes `0 errors, 0 warnings, 0 informations`.
- [x] [P1-T6] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/red-run-precondition.2026-10-11T10-38.md` from `git diff --name-only origin/main...HEAD -- .claude/agents/atomic-planner.md .claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md` together with `git status --porcelain -- .claude/agents/atomic-planner.md .claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md`. The anchored diff covers committed changes and the porcelain status covers uncommitted ones. Acceptance: both commands exit 0 and both print nothing, proving the four primary sources are in their pre-change state; `Output Summary:` states this.
- [x] [P1-T7] [expect-fail] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v`, run against the pre-change sources confirmed in P1-T6. Expected summary line: `14 failed, 1 passed`. Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` that quotes the summary line and lists, as FAILED, these 14 node IDs (each prefixed `tests/scripts/dev_tools/test_scratch_location_contracts.py::`): `test_scratch_location_section_states_the_rule[claude-planner]`, `test_scratch_location_section_states_the_rule[claude-executor]`, `test_scratch_location_section_states_the_rule[agents-planner]`, `test_scratch_location_section_states_the_rule[agents-executor]`, `test_scratch_location_section_avoids_forbidden_shapes[claude-planner]`, `test_scratch_location_section_avoids_forbidden_shapes[claude-executor]`, `test_scratch_location_section_avoids_forbidden_shapes[agents-planner]`, `test_scratch_location_section_avoids_forbidden_shapes[agents-executor]`, `test_planner_scratch_location_placement[claude-planner]`, `test_planner_scratch_location_placement[agents-planner]`, `test_executor_scratch_location_placement[claude-executor]`, `test_executor_scratch_location_placement[agents-executor]`, `test_executor_scratch_location_handles_pre_rule_plans[claude-executor]`, `test_executor_scratch_location_handles_pre_rule_plans[agents-executor]`; and lists `test_normative_surfaces_name_no_bare_fixed_scratch_path` as PASSED. This artifact records this one gate only.
- [x] [P1-T8] (Commit: `6027a78e2`; pushed, count `0`.) Commit and push Phase 1 for `tests/scripts/dev_tools/test_scratch_location_contracts.py` and `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`: run `git add tests/scripts/dev_tools/test_scratch_location_contracts.py docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`, then `git commit -m "test(900): add scratch location contract test with fail-before evidence"`, then `git push -u origin HEAD`. Acceptance: `git status --porcelain -- tests/scripts/dev_tools/test_scratch_location_contracts.py docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/` lists nothing other than this plan file, and `git rev-list --count @{u}..HEAD` prints `0`. The new commit hash is recorded beside this task.

### Phase 2 — Persona and Skill Edits with Byte-Identical Mirrors

Execution note (2026-10-12T17-40): before Phase 2 the "Observed facts" anchor lines were re-confirmed against the tree after the origin/main merge (df009ffbe); every anchor heading and anchor line in all eight files was at the cited line number, so no correction was recorded.

Each edit in this phase is an insertion only: the anchor text is kept unchanged, and the inserted passage is placed between the anchor line and the following blank line and heading. No neighbouring text is rewritten, and no `## Evidence Location Invariant` section is touched. Each bundled copy receives the identical Edit-tool operation as its primary source.

- [x] [P2-T1] Edit `.claude/agents/atomic-planner.md`: replace the text `5. Do not execute implementation; produce the plan only.` followed by one blank line and `## Preflight Validation` with the same line, one blank line, the Planner passage from Appendix B, one blank line, and `## Preflight Validation`. Acceptance: the Planner passage appears once, between `## Requirements` and `## Preflight Validation`; its first line is `## Scratch Location`; it contains the literal text `` `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` ``.
- [x] [P2-T2] Apply the identical edit from P2-T1 to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`. Acceptance: the Planner passage appears once, between `## Requirements` and `## Preflight Validation`.
- [x] [P2-T3] Edit `.claude/agents/atomic-executor.md`: replace the line `Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files.` followed by one blank line and `## Preflight Validation` with the same line, one blank line, the Executor passage from Appendix B, one blank line, and `## Preflight Validation`. Acceptance: the Executor passage appears once, between `## Toolchain Commands` and `## Preflight Validation`, and therefore before `## Evidence Location Invariant`; it contains the literal text ``Create `SCRATCH` before the first scratch write``.
- [x] [P2-T4] Apply the identical edit from P2-T3 to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`. Acceptance: the Executor passage appears once, between `## Toolchain Commands` and `## Preflight Validation`.
- [x] [P2-T5] Edit `.agents/skills/atomic-planner/SKILL.md`: replace the line `- free of placeholder text.` followed by one blank line and `## Mandatory Preflight Loop` with the same line, one blank line, the Planner passage from Appendix B, one blank line, and `## Mandatory Preflight Loop`. Acceptance: the Planner passage appears once, between `## Plan Requirements` and `## Mandatory Preflight Loop`.
- [x] [P2-T6] Apply the identical edit from P2-T5 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md`. Acceptance: the Planner passage appears once, between `## Plan Requirements` and `## Mandatory Preflight Loop`.
- [x] [P2-T7] Edit `.agents/skills/atomic-executor/SKILL.md`: replace the line ``5. Check off satisfied acceptance criteria in the authoritative requirement source file per `acceptance-criteria-tracking`.`` followed by one blank line and `## Non-Negotiable Constraints` with the same line, one blank line, the Executor passage from Appendix B, one blank line, and `## Non-Negotiable Constraints`. Acceptance: the Executor passage appears once, between `## Execution Rules` and `## Non-Negotiable Constraints`.
- [x] [P2-T8] Apply the identical edit from P2-T7 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`. Acceptance: the Executor passage appears once, between `## Execution Rules` and `## Non-Negotiable Constraints`.
- [x] [P2-T9] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/mirror-parity-after.2026-10-11T10-38.md` from `git hash-object --no-filters .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`. Acceptance: `EXIT_CODE: 0`; `Output Summary:` records all eight hashes labelled by path; hashes 1 and 2, 3 and 4, 5 and 6, and 7 and 8 are pairwise equal; and each of the eight hashes differs from its P0-T11 value.
- [x] [P2-T10] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/line-endings-after.2026-10-11T10-38.md` from `git ls-files --eol .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`. Acceptance: `EXIT_CODE: 0`; each of the eight lines carries `i/lf` and `w/lf` (no `w/crlf` and no `w/mixed`).
- [x] [P2-T11] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/insertion-only-numstat.2026-10-11T10-38.md` from `git diff --numstat HEAD -- .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md`, run before the Phase 2 commit. Acceptance: `EXIT_CODE: 0`; the output has eight lines; each of the four planner files shows `10` added and `0` deleted; each of the four executor files shows `11` added and `0` deleted; `Output Summary:` records the eight rows, confirming that no existing line was removed or rewritten.
- [x] [P2-T12] (Commit: `f90ee9a06`; pushed, count `0`.) Commit and push Phase 2 for the eight edited files and `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`: run `git add .claude/agents/atomic-planner.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md .agents/skills/atomic-planner/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md .agents/skills/atomic-executor/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`, then `git commit -m "fix(900): add child-unique scratch location rule to planner and executor"`, then `git push -u origin HEAD`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-list --count @{u}..HEAD` prints `0`. The new commit hash is recorded beside this task.

### Phase 3 — Targeted Verification and Acceptance-Criteria Check-Off

- [x] [P3-T1] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v`. Acceptance: `EXIT_CODE: 0`; `Output Summary:` quotes the summary line `15 passed` and lists all 15 node IDs named in P1-T7 (the 14 formerly failing ones and `test_normative_surfaces_name_no_bare_fixed_scratch_path`) as PASSED.
- [x] [P3-T2] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/push-down-claude-parity.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v`. Acceptance: `EXIT_CODE: 0`; `Output Summary:` quotes the summary line (`N passed, 1 deselected`, with zero failed) and lists `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_planner_review_resources_exist_and_are_byte_identical` as PASSED.
- [x] [P3-T3] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/issue-510-node-after.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`. Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` classifying the result as `PASS` or `ISSUE-510 SIGNATURE` under the definitions in P0-T17; when the exit code is non-zero, the artifact also carries `ExpectedExitCode: 1` and quotes every assertion message. An `OTHER FAILURE` classification fails this task, and in particular any message naming one of the eight Phase 2 paths is a regression.
- [x] [P3-T4] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/push-down-codex-agents-parity.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -v`. Acceptance: `EXIT_CODE: 0`; `Output Summary:` quotes the summary line with zero failed and lists `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_root_and_bundle_payload_contract_excludes_ephemeral_codex_state` as PASSED.
- [x] [P3-T5] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/regression-testing/neighbour-contracts.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -v`. Acceptance: `EXIT_CODE: 0`; `Output Summary:` quotes the summary line with zero failed and lists `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py::test_planner_review_contract_requires_all_three_dimensions`, `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py::test_mirror_does_not_name_the_vitest_framework[.claude/agents/atomic-executor.md]`, and `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py::test_atomic_executor_handoff_contract_is_strict_in_skill_and_agent` with their observed outcomes (PASSED, or SKIPPED where the module's own skip condition applies).
- [x] [P3-T6] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: change the first acceptance criterion (the one beginning ``- [ ] `.claude/agents/atomic-planner.md` contains a normative rule``) from `- [ ]` to `- [x]`, only after `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` lists `test_scratch_location_section_states_the_rule[claude-planner]` and `test_planner_scratch_location_placement[claude-planner]` as PASSED. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T7] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the second acceptance criterion (beginning ``- [ ] `.claude/agents/atomic-executor.md` contains a `## Scratch Location` section``) only after `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` lists `test_scratch_location_section_states_the_rule[claude-executor]`, `test_executor_scratch_location_placement[claude-executor]`, and `test_executor_scratch_location_handles_pre_rule_plans[claude-executor]` as PASSED. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T8] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the third acceptance criterion (beginning ``- [ ] `.agents/skills/atomic-planner/SKILL.md` and``) only after `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` lists `test_scratch_location_section_states_the_rule[agents-planner]` and `test_scratch_location_section_states_the_rule[agents-executor]` as PASSED. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T9] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the fourth acceptance criterion (beginning `- [ ] The new rule text in all four edited sources`) only after `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` lists all four `test_scratch_location_section_states_the_rule[...]` nodes and all four `test_scratch_location_section_avoids_forbidden_shapes[...]` nodes as PASSED. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T10] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the fifth acceptance criterion (beginning `- [ ] Each bundled copy`) only after `evidence/regression-testing/mirror-parity-after.2026-10-11T10-38.md`, `evidence/regression-testing/push-down-claude-parity.2026-10-11T10-38.md`, and `evidence/regression-testing/push-down-codex-agents-parity.2026-10-11T10-38.md` meet their acceptance and `evidence/regression-testing/issue-510-node-after.2026-10-11T10-38.md` is classified `PASS` or `ISSUE-510 SIGNATURE`. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T11] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the sixth acceptance criterion (beginning ``- [ ] `tests/scripts/dev_tools/test_scratch_location_contracts.py` exists``) only after `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` lists `test_normative_surfaces_name_no_bare_fixed_scratch_path` and all four `test_scratch_location_section_states_the_rule[...]` nodes as PASSED. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T12] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the seventh acceptance criterion (beginning `- [ ] A recorded red run`) only after `evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md` records `EXIT_CODE: 1` with `14 failed, 1 passed` and `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` records `EXIT_CODE: 0` with `15 passed`. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P3-T13] (Commit: `ef50acb2d`; pushed, count `0`.) Commit and push Phase 3 for `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`: run `git add docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`, then `git commit -m "docs(900): record targeted verification and acceptance-criteria check-offs"`, then `git push -u origin HEAD`. Acceptance: `git status --porcelain` lists nothing other than this plan file, and `git rev-list --count @{u}..HEAD` prints `0`. The new commit hash is recorded beside this task.

### Phase 4 — Final QA Loop, Scope Verification, and End-State Evidence

Run P4-T1 through P4-T8 in order as one pass. If any of P4-T1 through P4-T6 exits with a result its acceptance does not allow, or changes any file, fix the cause, restart from P4-T1, and overwrite every P4-T1 through P4-T8 artifact from that restart. The loop is complete only when P4-T1 through P4-T7 all meet their acceptance in a single pass with no file changed. Every command task in this loop is unconditional; `EXIT_CODE: SKIPPED` is not a valid outcome.

- [x] [P4-T1] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-black-check.2026-10-11T10-38.md` from `poetry run black --check tests/scripts/dev_tools/test_scratch_location_contracts.py`. `--check` does not rewrite files and exits 1 on drift. Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes `1 file would be left unchanged.` On exit 1 the file diverges from Appendix A, which is Black-stable: do not run Black in write mode; correct the file to equal Appendix A and restart the loop.
- [x] [P4-T2] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-ruff.2026-10-11T10-38.md` from `poetry run ruff check --no-fix tests/scripts/dev_tools/test_scratch_location_contracts.py`. `--no-fix` prevents rewriting. Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes `All checks passed!`.
- [x] [P4-T3] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-pyright.2026-10-11T10-38.md` from `poetry run pyright tests/scripts/dev_tools/test_scratch_location_contracts.py`. Acceptance: `EXIT_CODE: 0` and `Output Summary:` quotes `0 errors, 0 warnings, 0 informations`.
- [x] [P4-T4] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools.push_down_claude_customizations --cov-branch --cov-report=term-missing -q`. Acceptance: `EXIT_CODE: 0`; zero failed; the passed count equals the P0-T16 passed count plus 15, the skipped count equals the P0-T16 skipped count, and `1 deselected` is printed; `Output Summary:` records those counts and the numeric `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values of the `TOTAL` row with the derived line percentage `(Stmts - Miss) / Stmts`. If P0-T16 recorded pre-existing failures, this task instead requires that the failing node IDs are a subset of those recorded in P0-T16 and that none belongs to `tests/scripts/dev_tools/test_scratch_location_contracts.py`.
- [x] [P4-T5] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-issue-510-node.2026-10-11T10-38.md` from `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`. Acceptance: the artifact records the observed `EXIT_CODE:` and an `Output Summary:` classifying the result as `PASS` or `ISSUE-510 SIGNATURE` under the definitions in P0-T17; when the exit code is non-zero, the artifact also carries `ExpectedExitCode: 1` and quotes every assertion message. An `OTHER FAILURE` classification fails this task.
- [x] [P4-T6] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-poshqc-claude-runtime.2026-10-11T10-38.md` from one call to the MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the executor worktree root and `scan_folders` set to `["tests/scripts/claude-runtime"]`. Acceptance: the artifact records `Command:` as `mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=["tests/scripts/claude-runtime"]`, `EXIT_CODE: 0` (the call returned without raising), and an `Output Summary:` recording only the call disposition and the returned `ok` value, which must equal the P0-T18 value; it records no test count, percentage, or test name, and states that per-test Pester results for `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` are taken from PR CI.
- [x] [P4-T7] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/coverage-comparison.2026-10-11T10-38.md` comparing `evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md` with `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, and recording the output of `git diff --name-only origin/main...HEAD -- scripts src` together with `git status --porcelain -- scripts src`. The anchored diff covers committed production changes and the porcelain status covers uncommitted and untracked ones. Acceptance: the artifact carries `Timestamp:`, `Command:` (naming the two artifacts compared and the two git commands), `EXIT_CODE: 0`, and an `Output Summary:` listing baseline coverage, post-change coverage, and changed-line coverage; the `TOTAL` row values `Stmts`, `Miss`, `Branch`, and `BrPart` are identical between the two artifacts and the derived line percentage is unchanged; both git commands exit 0 and print nothing, so no file under `scripts/` or `src/` changed; and changed-line coverage is stated as not applicable because the changed lines are Markdown prose with no executable lines and the new module is under `tests/`, which `[tool.coverage.run]` `omit` excludes. Any difference in the four `TOTAL` values, or any path printed by either git command, fails this task.
- [x] [P4-T8] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/final-qc-loop-pass.2026-10-11T10-38.md` recording that P4-T1 through P4-T7 completed in one pass with no file changed and no restart, or the number of restarts and the cause of each. Acceptance: the artifact carries `Timestamp:`, `Command:` (the sequence P4-T1 to P4-T7), `EXIT_CODE: 0`, and an `Output Summary:` stating the restart count and that Black reported `1 file would be left unchanged.` on the final pass.
- [x] [P4-T9] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/scope-check.2026-10-11T10-38.md` from `git diff --name-status origin/main...HEAD` together with `git status --porcelain`. The triple-dot diff is anchored to the merge base and lists committed changes with their status letters; the porcelain status lists uncommitted and untracked paths, which the diff cannot see. Acceptance: both commands exit 0; every status letter printed by the diff is `A` or `M`; and every path printed by either command is one of `tests/scripts/dev_tools/test_scratch_location_contracts.py`, the eight paths edited in Phase 2, or a path beginning `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`. `Output Summary:` records both outputs and states that no path is under `scripts/`, `src/`, `.claude/rules/`, `.github/`, `.codex/`, or any other `docs/features/` folder, and that none of the excluded files named in the binding constraints appears. No file is deleted (no `D` status in either output).
- [x] [P4-T10] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the eighth acceptance criterion (beginning `- [ ] Historical plans and evidence under feature folders other than this one`) only after `evidence/qa-gates/scope-check.2026-10-11T10-38.md` meets its acceptance. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P4-T11] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the ninth acceptance criterion (beginning `- [ ] The diff contains no edit to`) only after `evidence/qa-gates/scope-check.2026-10-11T10-38.md` meets its acceptance. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P4-T12] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`: check the tenth acceptance criterion (beginning `- [ ] The Python toolchain passes on the new test module`) only after `evidence/qa-gates/final-qc-loop-pass.2026-10-11T10-38.md`, `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/final-issue-510-node.2026-10-11T10-38.md`, and `evidence/qa-gates/coverage-comparison.2026-10-11T10-38.md` meet their acceptance and `evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md` exists. Acceptance: the box is checked and the criterion text is unchanged.
- [x] [P4-T13] Create `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/evidence/qa-gates/ac-status.2026-10-11T10-38.md` recording the AC Status Summary for `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md`. Acceptance: the artifact carries `Timestamp:`, `Command:` (`Read issue.md ## Acceptance Criteria`), `EXIT_CODE: 0`, and an `Output Summary:` stating `Total AC items: 11`, `Checked off (delivered): 10`, `Remaining (unchecked): 1`, and naming the eleventh criterion (beginning `- [ ] PR CI is green`) as pending-CI: it is CI-dependent, is left unchecked by this plan, and is checked off at the CI green gate by the item's own orchestrator run per `.claude/skills/acceptance-criteria-tracking/SKILL.md` section `### CI-Dependent Criteria`.
- [x] [P4-T14] Edit `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md` section `## Evidence Checklist`: check `baseline` only when every Phase 0 artifact exists with its required fields, `targeted verification` only when every Phase 1 through Phase 3 artifact exists with its required fields, and `end-state` only when every P4-T1 through P4-T13 artifact exists with its required fields. Acceptance: the three boxes are checked and their text is unchanged; any box whose condition is unmet stays unchecked with the gap recorded beside this task.
- [x] [P4-T15] (Commit: `521218235`; pushed, count `0`. This check-off is the one remaining uncommitted change.) Commit and push Phase 4 for `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`: run `git add docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/`, then `git commit -m "docs(900): record final QA and end-state evidence"`, then `git push -u origin HEAD`. Acceptance: `git status --porcelain` lists nothing other than this plan file (the check-off of this task is the one remaining uncommitted change, carried by the caller's next commit), and `git rev-list --count @{u}..HEAD` prints `0`. The new commit hash is recorded beside this task.

## Appendix A — Content of `tests/scripts/dev_tools/test_scratch_location_contracts.py`

The executor writes this content verbatim in P1-T1. The content is Black-stable and Ruff-clean as written (observed by executor preflight in revision round 1: `black --check` printed `1 file would be left unchanged.` and `ruff check --no-fix` printed `All checks passed!`), so no change to it is permitted; P1-T3 and P1-T4 verify this.

```python
"""Contract tests for the child-unique scratch location rule (issue #900).

Concurrent child runs in one session share one session scratchpad, so fixed
scratch file names can collide. The planner and executor personas, and their
Codex skill counterparts, therefore carry a ``## Scratch Location`` section
that resolves ``SCRATCH`` to a directory unique to the child.

Only the four repository-root sources are asserted here. Their bundled copies
under ``extensions/drm-copilot/resources/`` are covered by the two push-down
parity tests, which require the bundled payload to match the repository.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]

SECTION_HEADING = "## Scratch Location"
EVIDENCE_HEADING = "## Evidence Location Invariant"

CLAUDE_PLANNER = ".claude/agents/atomic-planner.md"
CLAUDE_EXECUTOR = ".claude/agents/atomic-executor.md"
AGENTS_PLANNER = ".agents/skills/atomic-planner/SKILL.md"
AGENTS_EXECUTOR = ".agents/skills/atomic-executor/SKILL.md"
PRIMARY_SOURCES = (CLAUDE_PLANNER, CLAUDE_EXECUTOR, AGENTS_PLANNER, AGENTS_EXECUTOR)

RULE_SOURCES = (
    pytest.param(CLAUDE_PLANNER, id="claude-planner"),
    pytest.param(CLAUDE_EXECUTOR, id="claude-executor"),
    pytest.param(AGENTS_PLANNER, id="agents-planner"),
    pytest.param(AGENTS_EXECUTOR, id="agents-executor"),
)
EXECUTOR_SOURCES = (
    pytest.param(CLAUDE_EXECUTOR, id="claude-executor"),
    pytest.param(AGENTS_EXECUTOR, id="agents-executor"),
)
PLANNER_PLACEMENTS = (
    pytest.param(
        CLAUDE_PLANNER,
        "## Requirements",
        "## Preflight Validation",
        id="claude-planner",
    ),
    pytest.param(
        AGENTS_PLANNER,
        "## Plan Requirements",
        "## Mandatory Preflight Loop",
        id="agents-planner",
    ),
)
EXECUTOR_PLACEMENTS = (
    pytest.param(
        CLAUDE_EXECUTOR,
        "## Toolchain Commands",
        "## Preflight Validation",
        id="claude-executor",
    ),
    pytest.param(
        AGENTS_EXECUTOR,
        "## Execution Rules",
        "## Non-Negotiable Constraints",
        id="agents-executor",
    ),
)

PINNED_RULE_PHRASE = "`SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`"
ISSUE_DIRECTORY_SEGMENT = "issue-<issue-num>"
SCOPE_PHRASE = "Every scratch file, helper script, staged copy, and coverage report"
LITERAL_MARKER_PHRASE = "record the literal token `SCRATCH`, never a host path"
PLANNER_NO_ROOT_PHRASE = (
    "never directs a scratch file to the scratchpad root or to a fixed shared name"
)
EXECUTOR_CREATE_PHRASE = "Create `SCRATCH` before the first scratch write"
EXECUTOR_PRE_RULE_PHRASE = (
    "treat that definition as `<session scratchpad>/issue-<issue-num>/`"
)

NPM_RUN_PATTERN = re.compile(r"`npm run [^`]+`")
ISSUE_NUMBER_PATTERN = re.compile(
    r"issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?\d+", re.IGNORECASE
)
ACTIVE_FEATURE_PATH = "docs/features/active/"

NORMATIVE_SURFACE_GLOBS = (
    ".claude/agents/*.md",
    ".claude/skills/**/SKILL.md",
    ".agents/skills/**/SKILL.md",
)
FORBIDDEN_SCRATCH_PATHS = (
    "SCRATCH/run-ps.sh",
    "SCRATCH/changed-line-coverage.ps1",
    "SCRATCH/cov-final.txt",
    "SCRATCH/cov-final.xml",
    "SCRATCH/region-probe.ps1",
    "<scratchpad>/",
)


def read_repo_lines(relative_path: str) -> list[str]:
    """Return the lines of one checked-in repository file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8").splitlines()


def section_start(lines: list[str]) -> int:
    """Return the index of the ``## Scratch Location`` heading, or -1."""

    return lines.index(SECTION_HEADING) if SECTION_HEADING in lines else -1


def scratch_section(relative_path: str) -> str:
    """Return the ``## Scratch Location`` body, or an empty string when absent.

    The body runs from the line after the heading to the next ``## `` heading.
    """

    lines = read_repo_lines(relative_path)
    start = section_start(lines)
    if start < 0:
        return ""
    body: list[str] = []
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        body.append(line)
    return "\n".join(body)


def neighbouring_headings(relative_path: str) -> tuple[str, str]:
    """Return the ``## `` headings directly before and after the section.

    Both values are empty strings when the section is absent; one value is
    empty when the section is the first or last top-level section.
    """

    lines = read_repo_lines(relative_path)
    start = section_start(lines)
    if start < 0:
        return ("", "")
    before = [line for line in lines[:start] if line.startswith("## ")]
    after = [line for line in lines[start + 1 :] if line.startswith("## ")]
    return (before[-1] if before else "", after[0] if after else "")


def normative_surface_paths() -> list[Path]:
    """Return every persona and skill file the scratch rule governs."""

    paths: set[Path] = set()
    for pattern in NORMATIVE_SURFACE_GLOBS:
        paths.update(path for path in REPO_ROOT.glob(pattern) if path.is_file())
    return sorted(paths)


@pytest.mark.parametrize("relative_path", RULE_SOURCES)
def test_scratch_location_section_states_the_rule(relative_path: str) -> None:
    """Require the child-unique ``SCRATCH`` rule in each primary source."""

    # Arrange
    required = (
        PINNED_RULE_PHRASE,
        ISSUE_DIRECTORY_SEGMENT,
        SCOPE_PHRASE,
        LITERAL_MARKER_PHRASE,
    )

    # Act
    section = scratch_section(relative_path)
    missing = [phrase for phrase in required if phrase not in section]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert missing == [], f"{relative_path} scratch rule lacks {missing}"


@pytest.mark.parametrize("relative_path", RULE_SOURCES)
def test_scratch_location_section_avoids_forbidden_shapes(relative_path: str) -> None:
    """Forbid npm commands, issue-number assignments, and active feature paths."""

    # Arrange
    section = scratch_section(relative_path)

    # Act
    npm_tokens = [match.group(0) for match in NPM_RUN_PATTERN.finditer(section)]
    issue_shapes = [match.group(0) for match in ISSUE_NUMBER_PATTERN.finditer(section)]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert npm_tokens == [], f"{relative_path} names npm commands {npm_tokens}"
    assert issue_shapes == [], f"{relative_path} states issue numbers {issue_shapes}"
    assert (
        ACTIVE_FEATURE_PATH not in section
    ), f"{relative_path} names {ACTIVE_FEATURE_PATH}"


@pytest.mark.parametrize(
    ("relative_path", "preceding", "following"), PLANNER_PLACEMENTS
)
def test_planner_scratch_location_placement(
    relative_path: str, preceding: str, following: str
) -> None:
    """Require the planner rule after its requirements and before preflight."""

    # Arrange
    expected = (preceding, following)

    # Act
    neighbours = neighbouring_headings(relative_path)
    section = scratch_section(relative_path)

    # Assert
    assert neighbours == expected, f"{relative_path} placed between {neighbours}"
    assert PLANNER_NO_ROOT_PHRASE in section, f"{relative_path} allows root names"


@pytest.mark.parametrize(
    ("relative_path", "preceding", "following"), EXECUTOR_PLACEMENTS
)
def test_executor_scratch_location_placement(
    relative_path: str, preceding: str, following: str
) -> None:
    """Require the executor rule in place and ahead of any evidence invariant."""

    # Arrange
    expected = (preceding, following)
    lines = read_repo_lines(relative_path)

    # Act
    neighbours = neighbouring_headings(relative_path)
    start = section_start(lines)
    evidence = lines.index(EVIDENCE_HEADING) if EVIDENCE_HEADING in lines else -1

    # Assert
    assert neighbours == expected, f"{relative_path} placed between {neighbours}"
    assert start >= 0, f"{relative_path} has no {SECTION_HEADING} section"
    assert evidence < 0 or start < evidence, f"{relative_path} rule follows evidence"


@pytest.mark.parametrize("relative_path", EXECUTOR_SOURCES)
def test_executor_scratch_location_handles_pre_rule_plans(relative_path: str) -> None:
    """Require directory creation and bare-scratchpad reinterpretation."""

    # Arrange
    required = (EXECUTOR_CREATE_PHRASE, EXECUTOR_PRE_RULE_PHRASE)

    # Act
    section = scratch_section(relative_path)
    missing = [phrase for phrase in required if phrase not in section]

    # Assert
    assert section.strip(), f"{relative_path} has no {SECTION_HEADING} section"
    assert missing == [], f"{relative_path} executor rule lacks {missing}"


def test_normative_surfaces_name_no_bare_fixed_scratch_path() -> None:
    """Forbid fixed scratch names and scratchpad-root paths on normative surfaces."""

    # Arrange
    surfaces = normative_surface_paths()
    scanned = {path.relative_to(REPO_ROOT).as_posix() for path in surfaces}

    # Act
    offending = [
        f"{path.relative_to(REPO_ROOT).as_posix()}: {literal}"
        for path in surfaces
        for literal in FORBIDDEN_SCRATCH_PATHS
        if literal in path.read_text(encoding="utf-8")
    ]

    # Assert
    assert set(PRIMARY_SOURCES) <= scanned, "scan missed a primary scratch source"
    assert offending == [], f"bare fixed scratch paths found: {offending}"
```

## Appendix B — Inserted Passages (verbatim)

Each passage is inserted exactly as shown, with LF line endings, one blank line before it, and one blank line after it. The Planner passage is 9 lines plus its trailing blank line (10 added lines in `git diff --numstat`); the Executor passage is 10 lines plus its trailing blank line (11 added lines).

**Planner passage** (inserted in P2-T1, P2-T2, P2-T5, and P2-T6):

```markdown
## Scratch Location

Concurrent child runs in one session share one session scratchpad, so every plan places its scratch files in a directory unique to the child.

- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`, where `<issue-num>` is the plan's canonical issue number. Every plan that uses scratch files defines `SCRATCH` this way.
- Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`. Subdirectories such as `SCRATCH/stage/` are permitted.
- A plan never directs a scratch file to the scratchpad root or to a fixed shared name outside `SCRATCH`.
- Plans and evidence artifacts record the literal token `SCRATCH`, never a host path.
- If two runs for the same issue can execute at once, the run-unique form `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` replaces `issue-<issue-num>`.
```

**Executor passage** (inserted in P2-T3, P2-T4, P2-T7, and P2-T8):

```markdown
## Scratch Location

Concurrent child runs in one session share one session scratchpad, so every scratch file a run writes lives in a directory unique to the child.

- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`, where `<issue-num>` is the plan's canonical issue number.
- Every scratch file, helper script, staged copy, and coverage report a plan names lives under `SCRATCH`. Subdirectories such as `SCRATCH/stage/` are permitted.
- Create `SCRATCH` before the first scratch write. Never write a scratch file to the scratchpad root or to a fixed shared name outside `SCRATCH`.
- When a plan written before this rule defines `SCRATCH` as the bare session scratchpad, treat that definition as `<session scratchpad>/issue-<issue-num>/`. This is a mechanical micro-action, not replanning.
- Plans and evidence artifacts record the literal token `SCRATCH`, never a host path.
- If two runs for the same issue can execute at once, the run-unique form `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` replaces `issue-<issue-num>`.
```

Literal tokens the contract test asserts, quoted here because they do not yet exist in the tree: `` `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` ``, `issue-<issue-num>`, `Every scratch file, helper script, staged copy, and coverage report`, ``record the literal token `SCRATCH`, never a host path``, `never directs a scratch file to the scratchpad root or to a fixed shared name`, ``Create `SCRATCH` before the first scratch write``, and ``treat that definition as `<session scratchpad>/issue-<issue-num>/` ``. Neither passage contains a backticked npm command, an issue-number assignment, the text `docs/features/active/`, the text `Vitest`, any of the six forbidden scratch literals in Appendix A, or a `## Evidence Location Invariant` reference.

## Planner Self-Review Record

SELF-REVIEW: RE-DERIVED THIS PASS

Revision round 1 (2026-10-11T12-15) applied preflight deltas D1 (constants renamed to `ISSUE_DIRECTORY_SEGMENT` and `LITERAL_MARKER_PHRASE` for Ruff `S105`), D2 (single-line `issue_shapes` comprehension, 87 characters), D3 (P4-T9 uses `git diff --name-status` and requires status letters `A` or `M`), and D4 (P0-T15 Pyright wording), and tightened the Black allowance in the Appendix A preamble, P1-T3, and P4-T1. Citations re-derived in round 1 against the current tree:
- `pyproject.toml` line 85 (Black `line-length = 88`), line 89 (Ruff `line-length = 88`), lines 93-103 (`S` selected at line 100), line 106 (`tests/**/*` ignores only `S101`), line 116 (`addopts`), line 144 (`typeCheckingMode = "strict"`).
- `.claude/agents/atomic-planner.md` headings at lines 30, 40, 50, 58, 64, 68 (Appendix A `PLANNER_PLACEMENTS` neighbours `## Requirements` / `## Preflight Validation`).
- `.claude/agents/atomic-executor.md` headings at lines 43, 50, 62, 74, 85, 92, 103, 112, 121, 130 (Appendix A `EXECUTOR_PLACEMENTS` neighbours and `EVIDENCE_HEADING`).
- `.agents/skills/atomic-planner/SKILL.md` headings at lines 10, 16, 22, 37, 60, 72, 80; line 35 anchor `- free of placeholder text.`.
- `.agents/skills/atomic-executor/SKILL.md` headings at lines 10, 17, 24, 48, 58, 68; line 56 anchor.
- `scripts/dev_tools/plan_gate_observability.py` lines 163-170 (`black-write` and `ruff-fix` register entries; P1-T3 and P4-T1 no longer direct a Black write-mode run).
- Plan-internal siblings re-checked: Appendix A usage sites in `test_scratch_location_section_states_the_rule`; Appendix B literal-token list (string values unchanged); P1-T7 and P3-T1 counts (`14 failed, 1 passed`, `15 passed`, observed by executor preflight with D1 and D2 applied); P1-T5 and P4-T3 Pyright quotes; P4-T7 anchored diff with porcelain companion; P4-T10 and P4-T11 dependence on P4-T9.

Citations re-derived in the initial authoring pass against the tree:
- `.claude/agents/atomic-planner.md` lines 50-58 (`## Requirements`, item 5 at line 56, `## Preflight Validation` at line 58) and sibling line 68 (`## Evidence Location Invariant`).
- `.claude/agents/atomic-executor.md` lines 74-85 (`## Toolchain Commands`, line 83, `## Preflight Validation` at line 85), sibling lines 78-81 (MCP tool tokens read by the Pester suite), and line 130 (`## Evidence Location Invariant`).
- `.agents/skills/atomic-planner/SKILL.md` lines 22-37 (`## Plan Requirements`, line 35, `## Mandatory Preflight Loop`) and sibling headings at lines 10, 16, 47, 60, 72, 80.
- `.agents/skills/atomic-executor/SKILL.md` lines 48-58 (`## Execution Rules`, line 56, `## Non-Negotiable Constraints`) and sibling headings at lines 10, 17, 24, 34, 68.
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md` lines 48-62; `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` lines 72-87; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-planner/SKILL.md` lines 20-39; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-executor/SKILL.md` lines 46-60: anchor text identical to the primaries.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: `PLANNER_REVIEW_RESOURCE_PATHS` lines 41-45, `test_bundled_claude_payload_contains_all_repo_runtime_contracts` line 89, `test_planner_review_resources_exist_and_are_byte_identical` lines 113-123, `importlib.import_module("scripts.dev_tools.push_down_claude_customizations")` lines 274-276.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`: `REQUIRED_BUNDLED_FILES` lines 55-68, test functions at lines 215 and 231.
- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`: `MIRROR_RELATIVE_PATHS` lines 28-35, `NPM_RUN_PATTERN` line 42, parametrized node id form at line 94.
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`: lines 96-138 (planner tokens unaffected by an insertion).
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`: lines 87-131 (required fragments unaffected by an insertion).
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`: lines 39-48 (MCP tokens only).
- `pyproject.toml`: lines 89, 93-106, 116, 119-127, 143-153.
- `.gitattributes` line 1; `.gitignore` lines 69-70.
- `scripts/dev_tools/push_down_claude_customizations.py` (exists); `scripts/dev_tools/plan_gate_observability.py` lines 163-173 (black and ruff register entries and markers).
- `.claude/hooks/validate-planner-output.ps1` lines 96-97 (path-token rule), 239-342 (structure rules).
- `.claude/rules/plan-acceptance-gates.md` rule table lines 31-42.
- `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md` lines 48-60 (11 acceptance criteria) and lines 84-87 (Evidence Checklist).
- Searches re-run in this pass: `SCRATCH|scratchpad|run-ps\.sh|changed-line-coverage|region-probe|cov-final` over `.claude/` and `.agents/` (zero matches); `issue-<issue-num>|Scratch Location|session scratchpad` outside `docs/features/` (matches only in orchestrate, parallel-orchestrate, and epic-orchestrate skills and their bundle copies; none in the four primaries).

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/agents/atomic-planner.md | lines 50-58 Requirements and Preflight Validation headings
CITATION: .claude/agents/atomic-executor.md | lines 74-85 Toolchain Commands, line 130 Evidence Location Invariant
CITATION: .agents/skills/atomic-planner/SKILL.md | lines 22-37 Plan Requirements and Mandatory Preflight Loop
CITATION: .agents/skills/atomic-executor/SKILL.md | lines 48-58 Execution Rules and Non-Negotiable Constraints
CITATION: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py | lines 41-45, 89, 113-123, 274-276
CITATION: tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py | lines 55-68, 215, 231
CITATION: pyproject.toml | lines 116 addopts, 119-127 coverage run, 143-153 pyright
CITATION: pyproject.toml | line 85 black line-length, line 100 ruff S selected, line 106 tests ignore S101 only
CITATION: scripts/dev_tools/plan_gate_observability.py | lines 163-170 black-write and ruff-fix register entries
CITATION: docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md | Acceptance Criteria lines 48-60
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC11
AC-MAPPING: AC1 | IMPLEMENTATION: P2-T1 | TESTS: P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md
AC-MAPPING: AC2 | IMPLEMENTATION: P2-T3 | TESTS: P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md
AC-MAPPING: AC3 | IMPLEMENTATION: P2-T5, P2-T7 | TESTS: P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md
AC-MAPPING: AC4 | IMPLEMENTATION: P2-T1, P2-T3, P2-T5, P2-T7 | TESTS: P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md
AC-MAPPING: AC5 | IMPLEMENTATION: P2-T2, P2-T4, P2-T6, P2-T8 | TESTS: P2-T9, P3-T2, P3-T3, P3-T4 | EVIDENCE: evidence/regression-testing/mirror-parity-after.2026-10-11T10-38.md
AC-MAPPING: AC6 | IMPLEMENTATION: P1-T1 | TESTS: P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md
AC-MAPPING: AC7 | IMPLEMENTATION: P1-T1 | TESTS: P1-T7, P3-T1 | EVIDENCE: evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md
AC-MAPPING: AC8 | IMPLEMENTATION: P4-T9 | TESTS: P4-T9 | EVIDENCE: evidence/qa-gates/scope-check.2026-10-11T10-38.md
AC-MAPPING: AC9 | IMPLEMENTATION: P4-T9 | TESTS: P4-T9 | EVIDENCE: evidence/qa-gates/scope-check.2026-10-11T10-38.md
AC-MAPPING: AC10 | IMPLEMENTATION: P1-T1 | TESTS: P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T7 | EVIDENCE: evidence/qa-gates/final-qc-loop-pass.2026-10-11T10-38.md
AC-MAPPING: AC11 | IMPLEMENTATION: P4-T15 | TESTS: P4-T6 local PoshQC call disposition; PR CI Pester run deferred to the CI gate | EVIDENCE: evidence/qa-gates/ac-status.2026-10-11T10-38.md (pending-CI)
UNRESOLVED-GAPS: NONE

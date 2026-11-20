# plan-validator-accepts-bare-scratch-paths (Remediation Plan, Cycle 1)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T01-52 (remediation cycle 1, initial authoring)
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug. `spec.md` remains the acceptance-criteria source for the item; this cycle's requirements come only from `remediation-inputs.2026-10-16T01-52.md` and the three review artifacts it lists.
- **Branch:** `bug/plan-validator-accepts-bare-scratch-paths-932` (HEAD `a2f2c0332` at authoring time). Base: `main`.
- **Inputs:** `remediation-inputs.2026-10-16T01-52.md`, `policy-audit.2026-10-16T01-52.md`, `code-review.2026-10-16T01-52.md`, `feature-audit.2026-10-16T01-52.md`; original plan `plan.2026-10-15T15-45.md`; `spec.md`.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above applies to preflight rounds only. After preflight returns `PREFLIGHT: ALL CLEAR`, the orchestrator delegates execution separately.

**Fail-closed evidence rule:** Python and TypeScript each have explicit remediation-baseline tasks, final-QA tasks, and coverage-comparison tasks. If any required baseline, QA, or coverage artifact is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with every required field.

## Cycle Scope

In scope (remediation IDs from `remediation-inputs.2026-10-16T01-52.md`):

- **RF-1 / CR-1 (Blocking, autonomous).** Declare CommonJS `sourceType` and the Node globals for `**/*.cjs` in `extensions/drm-copilot/eslint.config.mjs`, rerun the original `[P3-T6]` command exactly as written, record a new `ts-lint-phase3` artifact, and check off `[P3-T6]` in `plan.2026-10-15T15-45.md`. `extensions/drm-copilot/jest.config.cjs` is not edited (concurrent item #543 reads it). No dependency is added.
- **CR-2.** Decision: remove the unreachable heading and task-line conditions from the continuation predicate in both runtimes (`scripts/dev_tools/plan_gate_scratch.py:83-85`, `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts:111-114`), keeping behaviour unchanged. The stop fixtures are renamed so they claim only that a line not beginning with whitespace ends a logical line, and a new pinned fixture pair shows that an indented heading or task line is absorbed. The test name `test_logical_line_stops_at_heading_fence_and_task_line` is kept because `spec.md` cites it for an already-checked acceptance criterion.
- **CR-3.** Correct `.claude/rules/plan-acceptance-gates.md` lines 15, 17, and 289 so they state G1 through G9 plus the document-level G10; keep the bundle copy byte-identical (operator-approved for this item).
- **CR-4.** Decision: align line splitting on the explicit CR LF, LF, and CR rule in the G10 modules and in the shared command extractor, through one shared splitter per runtime: a new public `split_plan_lines` in `scripts/dev_tools/plan_gate_commands.py` (used by `extract_plan_commands` at line 322 and by `plan_gate_scratch.py` at line 120), and the existing private `splitLines` in `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:262` exported as `splitPlanLines` and reused by `plan-gate-scratch.ts` in place of its duplicate at lines 67-85. Frozen form-feed and U+2028 fixtures are added to both suites. The extractor alignment is a minimal change (one helper plus one call site in Python; an export and a rename in TypeScript) and is therefore included rather than documented. The remaining whitespace-normalization residual (Python `str.split()` against the JavaScript whitespace class, which disagree on the information separators, NEL, and the byte-order mark) is outside this cycle's scope and is recorded as a documented limitation in the `spec.md` NFR-2 note and in the rule file. The U+2028 fixture is chosen over NEL because NEL also falls in that normalization residual.
- **CR-5.** Document in the rule file's G10 false-negative list (and its bundle copy, and the `spec.md` false-negative list) that any `issue-<digits>` or `issue-<issue-num>` token after the definition match accepts the line, including a cross-reference.

Out of scope (orchestrator decision): CR-6 (delete the stale research duplicate; the run rule is "Delete nothing") and CR-7 (convert TypeScript fixtures to `it.each`; original plan task P1-T5 prohibits it).

## Conventions

- `<FEATURE>` abbreviates `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932`. Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` (kinds used: `remediation-baseline`, `regression-testing`, `qa-gates`, `other`).
- Evidence artifacts are named `<name>.<timestamp>.md`. The `<timestamp>` is the UTC write time read from the host clock immediately before the write (for example `date -u +%Y-%m-%dT%H-%M`), in the shape `yyyy-MM-ddTHH-mm`. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage-bearing artifacts carry numeric line and branch percentages in `Output Summary:`.
- Scratch location (issue #900 rule):
  - `SCRATCH` resolves to `<session scratchpad>/issue-932/`.
  - Every scratch file this plan names lives under `SCRATCH` (subdirectory `SCRATCH/cov/`). Nothing is written to the scratchpad root.
  - Evidence and this plan record the literal token `SCRATCH`, never a host path. When pytest or jest output contains a host path, the executor replaces the scratch prefix with `SCRATCH` and the repository prefix with a repository-relative path before recording it.
  - The untracked `SCRATCH/` directory at the worktree root is orchestrator session state. It is unrelated to the `SCRATCH` token above, is never staged, and is never deleted by this plan.
- `<MERGE_BASE>` denotes the merge-base SHA and `<RC1_BASE>` the HEAD SHA, both recorded by [P0-T3] in the latest `<FEATURE>/evidence/remediation-baseline/git-baseline.*.md`. If the branch is rebased later, the executor re-derives `<MERGE_BASE>` with `git merge-base origin/main HEAD` and records the new value in the consuming artifact.
- TypeScript commands run with `extensions/drm-copilot/` as the working directory. Python and git commands run at the repository root.
- Python check-mode commands only: `black --check` and `ruff check --no-fix`. Write-mode formatting is permitted only inside the remediation branch of a check task and is followed by a loop restart.
- Commits: `git add` names each file or evidence folder explicitly. No force push. No file is deleted. No issue is created. No pull request is opened. A related finding discovered during execution is fixed inside this item; a completely unrelated finding is recorded in `<FEATURE>/evidence/other/unrelated-findings.<timestamp>.md`.
- Known local failure (#510): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally because of gitignored state. Only that node, with a failure message that names a gitignored path absent from the bundle, is accepted locally; any other failure in that file is a real failure. CI is the authority for that node.
- PowerShell and bats are not in scope. Pester stays on breakpoint coverage and is not run by this plan.
- Agent-worktree command routes: the worktree isolation guard refuses command text containing three shell-host words (the POSIX shell name, the PowerShell 7 executable name, and the Linux-subsystem launcher name), so no task in this plan names them. File copying uses `cp` or the Read-plus-Write fallback; timestamps use `date -u`.
- npm dependencies: `extensions/drm-copilot/node_modules/` was present at planning time. If the Glob tool finds no `extensions/drm-copilot/node_modules/jest/package.json` when [P0-T6] starts, the executor stops with `BLOCKED: node_modules absent` and reports to the caller.
- Out-of-scope remediation log: whenever a task edits a repository file that is not in the WRITES list of this plan, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation.<timestamp>.md` carrying `Timestamp:`, the triggering task ID, one `PATH: ` line per edited repository-relative path, and a one-line reason per path. Those paths are staged in the commit of the phase that edited them.

## Fixture Rule for This Plan

This plan must pass G10. It therefore quotes no bare SCRATCH definition outside a fenced block. Every new test fixture that contains definition text is listed in Appendix B (fenced) and is referred to in the tasks by its fixture label.

### Phase 0 — Policy Reads and Remediation Baselines

All Phase 0 commands are read-only check modes. No write-mode formatter runs in this phase. All artifacts go to `<FEATURE>/evidence/remediation-baseline/`.

- [x] [P0-T1] Read the policy files in policy-compliance order and record them in `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`
  - Files, in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and a list naming all nine files in that order.
- [x] [P0-T2] Read the cycle inputs and record them in `<FEATURE>/evidence/remediation-baseline/remediation-inputs-read.<timestamp>.md`
  - Files: `<FEATURE>/remediation-inputs.2026-10-16T01-52.md`, `<FEATURE>/policy-audit.2026-10-16T01-52.md`, `<FEATURE>/code-review.2026-10-16T01-52.md`, `<FEATURE>/feature-audit.2026-10-16T01-52.md`.
  - Acceptance: the artifact carries `Timestamp:`, lists the four files, and lists the in-scope IDs `RF-1`, `CR-2`, `CR-3`, `CR-4`, `CR-5` and the declined IDs `CR-6`, `CR-7` with the reason for each as stated in Cycle Scope.
- [x] [P0-T3] Record the git baseline in `<FEATURE>/evidence/remediation-baseline/git-baseline.<timestamp>.md`
  - Commands: `git fetch origin main`, `git rev-parse HEAD`, `git merge-base origin/main HEAD`, `git status --porcelain`.
  - Acceptance: each command records `EXIT_CODE: 0`; the artifact records the HEAD SHA under the label `RC1_BASE:` and the merge-base SHA under the label `MERGE_BASE:`; the porcelain output lists no path other than `SCRATCH/` and `<FEATURE>/remediation-plan.2026-10-16T01-52.md` (either may be absent).
- [x] [P0-T4] Create the scratch directory `SCRATCH/cov/` and record it in `<FEATURE>/evidence/remediation-baseline/scratch-setup.<timestamp>.md`
  - Method: the Write tool writes `SCRATCH/cov/README.txt` with the one-line content `Issue 932 remediation cycle 1 scratch directory; not committed.`, with `SCRATCH` resolved to its absolute path for the tool call only.
  - Acceptance: the Glob tool with pattern `cov/README.txt` rooted at the resolved `SCRATCH` directory returns that one file; the artifact records the method and the relative result using the token `SCRATCH` only.
- [x] [P0-T5] Reproduce the RF-1 defect by rerunning the original `[P3-T6]` command and record `<FEATURE>/evidence/remediation-baseline/ts-lint-p3t6-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs`
  - Acceptance: the artifact records the observed exit code, `ExpectedExitCode: 1` only when the output's sole problem is `'module' is not defined` with rule `no-undef` in `jest.config.cjs`, and `Output Summary:` quotes every reported problem line. Any other problem halts the task for a plan revision.
- [x] [P0-T6] Capture the TypeScript format baseline in `<FEATURE>/evidence/remediation-baseline/ts-format-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `Output Summary:` quotes either `All matched files use Prettier code style!` or the list of files reported with warnings, and the observed exit code.
- [x] [P0-T7] Capture the TypeScript lint baseline in `<FEATURE>/evidence/remediation-baseline/ts-lint-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `Output Summary:` records the error and warning counts (no output on a clean run is recorded as `0 errors, 0 warnings`).
- [x] [P0-T8] Capture the TypeScript production type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count (no output on success).
- [x] [P0-T9] Capture the TypeScript test type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-test-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count.
- [x] [P0-T10] Capture the full jest coverage baseline in `<FEATURE>/evidence/remediation-baseline/ts-coverage-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `Output Summary:` records the suite and test pass/fail counts, the `text-summary` totals, every failing suite, any coverage-threshold message, and the `lines.pct` and `branches.pct` values for `src/lib/validate/plan-gate-scratch.ts` and `src/lib/validate/plan-gate-commands.ts` read from `extensions/drm-copilot/coverage/coverage-summary.json`.
- [x] [P0-T11] Capture the Python format baseline in `<FEATURE>/evidence/remediation-baseline/python-format-baseline.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the black summary line (for example `5 files would be left unchanged.`) and the observed exit code.
- [x] [P0-T12] Capture the Python lint baseline in `<FEATURE>/evidence/remediation-baseline/python-lint-baseline.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes either `All checks passed!` or the diagnostic count.
- [x] [P0-T13] Capture the Python type-check baseline in `<FEATURE>/evidence/remediation-baseline/python-typecheck-baseline.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the pyright summary line (`N errors, N warnings, N informations`).
- [x] [P0-T14] Capture the Python coverage baseline for `scripts.dev_tools.plan_gate_scratch` and `scripts.dev_tools.plan_gate_commands` in `<FEATURE>/evidence/remediation-baseline/python-coverage-baseline.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_commands --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py.json`
  - Acceptance: `Output Summary:` records the total `passed` and `failed` counts from the final pytest summary line, the `term-missing` rows for `plan_gate_scratch.py` and `plan_gate_commands.py`, and for each file the numeric line coverage (`covered_lines / num_statements`) and branch coverage (`covered_branches / num_branches`) read from its `summary` object in `SCRATCH/cov/baseline-py.json`.
- [x] [P0-T15] Capture the broad dev-tools regression baseline in `<FEATURE>/evidence/remediation-baseline/python-devtools-baseline.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: `Output Summary:` records the pass/fail/error/skip counts and lists every failing or erroring node ID (the reference set for [P5-T6]).
- [x] [P0-T16] Commit and push the Phase 0 evidence under `<FEATURE>/evidence/remediation-baseline/` with this plan file
  - Commands: `git add <FEATURE>/evidence/remediation-baseline <FEATURE>/remediation-plan.2026-10-16T01-52.md` (with the concrete folder path), `git commit -m "docs(932): record remediation cycle 1 baselines"`, `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

### Phase 1 — Red Tests

Static checks for the files written in this phase are waived until Phase 2 (Python) and Phase 3 (TypeScript), because the symbols the new tests import do not exist yet. No task in this phase runs a test node that a later phase makes pass, except the two `[expect-fail]` runs.

- [x] [P1-T1] Add the shared-splitter tests to `tests/scripts/dev_tools/test_plan_gate_commands.py` (CR-4)
  - Add `split_plan_lines` to the existing `from scripts.dev_tools.plan_gate_commands import (...)` list.
  - Add `test_split_plan_lines_splits_only_on_cr_lf_terminators`, parametrized over the four splitter cases in Appendix B (ids `empty`, `trailing-lf`, `mixed-terminators`, `form-feed-and-line-separator`), asserting `split_plan_lines(text) == expected`.
  - Add `test_extract_plan_commands_line_numbers_ignore_form_feed_and_line_separator`, parametrized over the two extractor cases in Appendix B (ids `form-feed`, `line-separator`), asserting that `extract_plan_commands(text)` returns exactly one command whose `task_id` is `P1-T1` and whose `source_line` is 2.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; file at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on the file with the pattern `^def (test_split_plan_lines_splits_only_on_cr_lf_terminators|test_extract_plan_commands_line_numbers_ignore_form_feed_and_line_separator)\(` returns exactly 2 (0 before this task); the Grep tool with pattern `^` and output mode `count` returns at most 500; the Grep tool, output mode count, on the file with the pattern [\x{2028}\x0c] returns 0. The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T2] Update the G10 stop fixtures and add the CR-2 and CR-4 G10 tests in `tests/scripts/dev_tools/test_plan_gate_scratch.py`
  - CR-2: in `_STOP_FIXTURES` (lines 93-100) rename the ids `heading` to `column-0-heading` and `task-line` to `column-0-task-line` (the `indented-fence` id and all three fixture lists are unchanged); change the docstring of `test_logical_line_stops_at_heading_fence_and_task_line` (name unchanged) to `Continuation stops at an indented fence and at any line not beginning with whitespace.` Add `test_indented_heading_and_task_line_continue_logical_line`, parametrized over the Appendix B fixtures `G10-ABSORB-HEADING` (id `indented-heading`) and `G10-ABSORB-TASK` (id `indented-task-line`), each asserting exactly the one frozen finding listed for it in Appendix B.
  - CR-4: add `test_bare_scratch_definitions_splits_only_on_cr_lf_terminators`, parametrized over the Appendix B fixtures `G10-FORM-FEED` (id `form-feed`) and `G10-LINE-SEPARATOR` (id `line-separator`), each asserting exactly the one frozen finding listed for it in Appendix B.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; file at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on the file returns exactly 2 for the pattern `^def (test_indented_heading_and_task_line_continue_logical_line|test_bare_scratch_definitions_splits_only_on_cr_lf_terminators)\(`, exactly 1 for the pattern `id="column-0-heading"`, exactly 1 for the pattern `id="column-0-task-line"`, and 0 for the pattern `id="heading"`; the line count (Grep pattern `^`, output mode `count`) is at most 500; the Grep tool, output mode count, on the file with the pattern [\x{2028}\x0c] returns 0. The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T3] Add the CR-2, CR-3, CR-4, and CR-5 rule-file tests to `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Add `test_rule_file_scope_and_enforcement_state_the_shipped_set`: reads `.claude/rules/plan-acceptance-gates.md` and asserts that each of the tokens `G1 through G9 judge the shell commands the plan states`, `G1 through G9 are fed by the command extractor`, and `evaluates G1 through G9, calls` is present, and that each of `applies to the shell commands an atomic plan states`, `both fed by the command extractor`, and `evaluates G1 through G6` is absent.
  - Add `test_rule_file_documents_g10_line_rules_and_issue_token_class`: asserts that each of the tokens `an indented heading or task line is absorbed`, `do not end a physical line`, `One parity residual remains`, and `**Any issue token after the definition.**` is present, and that the index of `### Known false-negative classes — G10` is lower than the index of `**Any issue token after the definition.**`, which is lower than the index of `## The Write-Mode Register`.
  - Structural rules: module constants for the token tuples; Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on the file with the pattern `^def (test_rule_file_scope_and_enforcement_state_the_shipped_set|test_rule_file_documents_g10_line_rules_and_issue_token_class)\(` returns exactly 2; the count is recorded in the [P1-T6] artifact.
- [x] [P1-T4] Add the shared-splitter cases to `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts` (CR-4)
  - Add `splitPlanLines` to the existing import from `../../../src/lib/validate/plan-gate-commands`.
  - Inside the existing `describe("extractPlanCommands", ...)` block add `it("reports line numbers that ignore a form feed and a line separator", ...)` over the two extractor cases in Appendix B, comparing the array of `[taskId, sourceLine]` pairs of each result to `[[["P1-T1", 2]], [["P1-T1", 2]]]`.
  - Add a new block `describe("splitPlanLines", ...)` with one case `it("splits only on CR LF, LF, and CR terminators", ...)` comparing the array of results for the four splitter cases in Appendix B to the array of their expected values.
  - Structural rules: plain `it("<literal title>", ...)` calls only (no `it.each`, no `test(`); Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on the file returns 1 for the pattern `describe\("splitPlanLines"`, 1 for the pattern `it\("splits only on CR LF, LF, and CR terminators"`, 1 for the pattern `it\("reports line numbers that ignore a form feed and a line separator"`, and 0 for the pattern `it\.each|^\s*test\(`; the Grep tool, output mode count, on the file with the pattern [\x{2028}\x0c] returns 0. The counts are recorded in the [P1-T7] artifact.
- [x] [P1-T5] Update the stop case and add the CR-2 and CR-4 cases in `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`
  - CR-2: retitle the case at line 219 from `stops a logical line at a fence, a heading, and a task line` to `stops a logical line at an indented fence and at a column-0 heading or task line` (body unchanged). Add `it("absorbs an indented heading or task line into the logical line", ...)` over the Appendix B fixtures `G10-ABSORB-HEADING` and `G10-ABSORB-TASK`, comparing the array of results to the array of their frozen findings.
  - CR-4: add `it("does not end a physical line at a form feed or a line separator", ...)` over the Appendix B fixtures `G10-FORM-FEED` and `G10-LINE-SEPARATOR`, comparing the array of results to the array of their frozen findings. The TypeScript form of each fixture uses the escapes listed in Appendix B.
  - Structural rules: plain `it("<literal title>", ...)` calls only; Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on the file returns 0 for the pattern `stops a logical line at a fence, a heading, and a task line`, 1 for each of the patterns `it\("stops a logical line at an indented fence and at a column-0 heading or task line"`, `it\("absorbs an indented heading or task line into the logical line"`, and `it\("does not end a physical line at a form feed or a line separator"`, and 0 for the pattern `it\.each|^\s*test\(`; the Grep tool, output mode count, on the file with the pattern [\x{2028}\x0c] returns 0. The counts are recorded in the [P1-T7] artifact.
- [x] [P1-T6] [expect-fail] Run the Python red set and record `<FEATURE>/evidence/regression-testing/python-red-rc1.<timestamp>.md`
  - Command: `poetry run pytest -v --continue-on-collection-errors tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Expected signatures: one collection error for `test_plan_gate_commands.py` naming `ImportError` for `split_plan_lines`; failures of `test_bare_scratch_definitions_splits_only_on_cr_lf_terminators[form-feed]` and `[line-separator]` (finding at line 2 instead of line 1); failures of `test_rule_file_scope_and_enforcement_state_the_shipped_set` and `test_rule_file_documents_g10_line_rules_and_issue_token_class`. Expected passes: `test_indented_heading_and_task_line_continue_logical_line[indented-heading]` and `[indented-task-line]` (behaviour is unchanged) and all three `test_logical_line_stops_at_heading_fence_and_task_line` ids.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` (set to the observed exit code only when every observed failure and error matches an expected signature above), and `Output Summary:` naming each failing or erroring node with its first error line and each expected-pass node, as printed by the `-v` per-node lines. It also records the Grep counts from [P1-T1], [P1-T2], and [P1-T3]. Any unexpected signature halts the task for a plan revision.
- [x] [P1-T7] [expect-fail] Run the TypeScript red set and record `<FEATURE>/evidence/regression-testing/ts-red-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-commands.test.ts test/lib/validate/plan-gate-scratch.test.ts`
  - Expected signatures: `plan-gate-commands.test.ts` fails, either with a ts-jest diagnostic stating that the module has no exported member `splitPlanLines` or with a `TypeError` stating that `splitPlanLines` is not a function; every case in `plan-gate-scratch.test.ts` passes, including the three new or retitled cases (the TypeScript twin already splits on CR LF, LF, and CR, and behaviour is unchanged).
  - Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `Output Summary:` naming the failing suite with its first error line and quoting the verbose passing lines of the three new or retitled `plan-gate-scratch G10` cases. It also records the Grep counts from [P1-T4] and [P1-T5]. Any other failure halts the task for a plan revision.
- [x] [P1-T8] Commit and push the Phase 1 test changes, the `<FEATURE>/evidence/regression-testing/` artifacts, and the plan check-offs
  - Commands: `git add tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` plus the two red artifacts and this plan file, `git commit -m "test(932): add remediation cycle 1 red tests for line splitting and rule text"`, `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

### Phase 2 — Python Implementation (CR-2, CR-4)

- [x] [P2-T1] Add the shared splitter `split_plan_lines` to `scripts/dev_tools/plan_gate_commands.py` and use it in `extract_plan_commands`
  - Add a module constant `_LINE_BREAK_RE` and the public function `split_plan_lines` exactly as in Appendix C, placed immediately before `def extract_plan_commands`. Replace `text.splitlines()` in the `for` statement of `extract_plan_commands` (line 322 before the edit) with `split_plan_lines(text)`. No other line changes.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py` exits 0 with 0 failed; the Grep tool, output mode `count`, on `scripts/dev_tools/plan_gate_commands.py` returns 0 for the pattern `text\.splitlines\(` (1 before this task, at line 322; the Appendix C docstring mentions `str.splitlines()`, which this pattern does not match) and 1 for the pattern `^def split_plan_lines\(`; the file is at most 500 lines.
- [x] [P2-T2] Remove the unreachable conditions and use the shared splitter in `scripts/dev_tools/plan_gate_scratch.py`
  - Replace the runtime import of `PLAN_GATE_HEADING_RE` and `PLAN_GATE_TASK_RE` (lines 36-39) with `from scripts.dev_tools.plan_gate_commands import split_plan_lines`.
  - Reduce `_continues_logical_line` (lines 74-85) to the whitespace test followed by `return FENCE_RE.match(line) is None`, and change its docstring to state that a continuation is non-blank, begins with whitespace, and is not a fence line, so a column-0 heading or task line ends the logical line while an indented one is absorbed.
  - Replace `text.splitlines()` at line 120 with `split_plan_lines(text)`.
  - Module docstring (lines 16-21): state that at runtime the module imports only the shared line splitter from `plan_gate_commands`, and add one sentence that physical lines are split on CR LF, LF, and CR only, matching the TypeScript twin.
  - Acceptance: the Grep tool, output mode `count`, on `scripts/dev_tools/plan_gate_scratch.py` returns 0 for the pattern `PLAN_GATE_HEADING_RE|PLAN_GATE_TASK_RE` (4 before this task, at lines 37, 38, 83, and 85), 0 for the pattern `text\.splitlines\(` (1 before, at line 120), and 1 for the pattern `split_plan_lines\(text\)`; `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py` exits 0 with 0 failed.
- [x] [P2-T3] Run the Python green set with coverage and record `<FEATURE>/evidence/regression-testing/python-green-rc1.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_parity.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_commands --cov-branch --cov-report=term-missing`
  - Acceptance: `EXIT_CODE: 0` and 0 failed; `Output Summary:` records the pass count and the `term-missing` rows for both files, and the `plan_gate_scratch.py` row shows `100%` with an empty `Missing` column.
- [x] [P2-T4] Run the Python plan-gate regression suites and record `<FEATURE>/evidence/regression-testing/python-plan-gate-regression-rc1.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`
  - Acceptance: `EXIT_CODE: 0` and 0 failed; `Output Summary:` records the pass count.
- [x] [P2-T5] Run the Python format check on the five Python files and record `<FEATURE>/evidence/regression-testing/python-format-rc1.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary line `5 files would be left unchanged.` Remediation branch: run `poetry run black scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, record its `reformatted` and `left unchanged` summary, then rerun from [P2-T3].
- [x] [P2-T6] Run the Python lint check on the same five files and record `<FEATURE>/evidence/regression-testing/python-lint-rc1.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the output line `All checks passed!`. Any suppression added follows `.claude/rules/python-suppressions.md`.
- [x] [P2-T7] Run the Python strict type check on the same five files and record `<FEATURE>/evidence/regression-testing/python-typecheck-rc1.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary `0 errors`.
- [x] [P2-T8] Commit and push the Python changes in `scripts/dev_tools/plan_gate_commands.py` and `scripts/dev_tools/plan_gate_scratch.py`, the evidence, and the plan check-offs
  - Commands: `git add scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py` plus any file reformatted in [P2-T5], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): share the CR LF line splitter and drop unreachable G10 continuation checks in Python"`; `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

### Phase 3 — TypeScript Implementation and ESLint Configuration (RF-1, CR-2, CR-4)

- [x] [P3-T1] Export the shared splitter as `splitPlanLines` from `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`
  - Rename the private `function splitLines` (line 262) to `export function splitPlanLines` and update its single call site (line 381). In its TSDoc, replace the sentence that cites `orchestration-artifacts.ts` line 82 with a sentence stating that the split expression matches the one in `orchestration-artifacts.ts` and the Python `split_plan_lines`, without a line number. No other change.
  - Acceptance: the Grep tool, output mode `count`, on the file returns 1 for the pattern `^export function splitPlanLines\(` and 0 for the pattern `splitLines\(`; the file is at most 500 lines.
- [x] [P3-T2] Remove the unreachable conditions and reuse the shared splitter in `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`
  - Replace the import of `PLAN_GATE_HEADING_PATTERN` and `PLAN_GATE_TASK_PATTERN` (lines 28-31) with `import { splitPlanLines } from "./plan-gate-commands";`. Delete the local `splitLines` function and its TSDoc (lines 67-85) and call `splitPlanLines(text)` at the former `splitLines(text)` call site.
  - Reduce `continuesLogicalLine` (lines 100-115) to the whitespace test followed by `return !FENCE_RE.test(line);`, with TSDoc matching the Python docstring from [P2-T2].
  - Module TSDoc (lines 19-21): state that the module imports only type declarations from `plan-gate-rules.ts` and the shared line splitter from `plan-gate-commands.ts`.
  - Acceptance: the Grep tool, output mode `count`, on the file returns 0 for the pattern `PLAN_GATE_HEADING_PATTERN|PLAN_GATE_TASK_PATTERN|function splitLines` (5 before this task, at lines 29, 30, 76, 111, and 114) and 1 for the pattern `splitPlanLines\(text\)`; `npx tsc -p ./ --noEmit` exits 0.
- [x] [P3-T3] Add the CommonJS block to `extensions/drm-copilot/eslint.config.mjs` (RF-1)
  - Method: the Write tool replaces the file with the exact content of Appendix A. The new block declares `files: ["**/*.cjs"]`, `sourceType: "commonjs"`, and the globals `module` (writable), `require`, `__dirname`, and `process` (read-only); it is placed after the TypeScript block and before the `ignores` block so it overrides the `typescript-eslint` base `sourceType`. If the lint runs in [P3-T5] or [P3-T7] report another undefined Node global in a `.cjs` file, that global is added to the same block as read-only and the Appendix A deviation is recorded in the [P3-T5] artifact. `extensions/drm-copilot/jest.config.cjs` is not edited and `package.json` is not edited.
  - Acceptance: `npx eslint jest.config.cjs` exits 0 and prints no problem line; the Grep tool, output mode `count`, on `extensions/drm-copilot/eslint.config.mjs` returns 1 for the pattern `files: \["\*\*/\*\.cjs"\]`.
- [x] [P3-T4] Run the TypeScript format check on the changed TypeScript and configuration files and record `<FEATURE>/evidence/regression-testing/ts-format-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-commands.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-commands.test.ts eslint.config.mjs jest.config.cjs`
  - Acceptance: `EXIT_CODE: 0` and the line `All matched files use Prettier code style!`. Remediation branch (for any of the first five paths only; `jest.config.cjs` is never rewritten): run `npx prettier --write` over the reported paths, record each path it reports as `(unchanged)` or rewritten, then rerun from [P3-T4].
- [x] [P3-T5] Rerun the original `[P3-T6]` command exactly as written and record `<FEATURE>/evidence/regression-testing/ts-lint-phase3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs`
  - Acceptance: `EXIT_CODE: 0` with no reported problem line; `Output Summary:` states that the command text is identical to `[P3-T6]` in `<FEATURE>/plan.2026-10-15T15-45.md` and that it supersedes `ts-lint-phase3.2026-10-16T01-01.md`.
- [x] [P3-T6] Check off `[P3-T6]` in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/plan.2026-10-15T15-45.md`
  - Edit: change the line-203 prefix `- [ ] [P3-T6]` to `- [x] [P3-T6]`. No other line of that file changes.
  - Precondition: the latest `<FEATURE>/evidence/regression-testing/ts-lint-phase3.*.md` is the [P3-T5] artifact and records `EXIT_CODE: 0`.
  - Acceptance: the Grep tool, output mode `count`, on that file returns 1 for the pattern `^- \[x\] \[P3-T6\]` and 0 for the pattern `^- \[ \] `.
- [x] [P3-T7] Run the TypeScript lint check on the changed files and record `<FEATURE>/evidence/regression-testing/ts-lint-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-commands.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-commands.test.ts eslint.config.mjs jest.config.cjs`
  - Acceptance: `EXIT_CODE: 0` with no reported problem line. Any suppression follows `.claude/rules/typescript-suppressions.md`.
- [x] [P3-T8] Run both TypeScript type checks and the validate test directory and record `<FEATURE>/evidence/regression-testing/ts-green-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Commands: `npx tsc -p ./ --noEmit`, `npx tsc -p tsconfig.jest.json --noEmit`, `npx jest --config jest.config.cjs --verbose test/lib/validate`.
  - Acceptance: all three exit 0; `Output Summary:` records the jest suite and test pass counts and 0 failed, and quotes the verbose passing lines for `splits only on CR LF, LF, and CR terminators`, `reports line numbers that ignore a form feed and a line separator`, `stops a logical line at an indented fence and at a column-0 heading or task line`, `absorbs an indented heading or task line into the logical line`, and `does not end a physical line at a form feed or a line separator`.
- [x] [P3-T9] Commit and push the TypeScript changes in `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, and `extensions/drm-copilot/eslint.config.mjs`, the original-plan check-off, the evidence, and the plan check-offs
  - Commands: `git add extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/eslint.config.mjs <FEATURE>/plan.2026-10-15T15-45.md` (with the concrete folder path) plus any file rewritten in [P3-T4], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): lint CommonJS config files and share the TypeScript line splitter"`; `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

### Phase 4 — Rule File and Specification Text (CR-2, CR-3, CR-4, CR-5)

Every sentence quoted in this phase is inserted verbatim as one line of the target file (the rule file does not hard-wrap prose).

- [x] [P4-T1] Correct the scope and enforcement statements in `.claude/rules/plan-acceptance-gates.md` (CR-3)
  - Line 15: replace the first sentence with `This rule governs the acceptance-gate rules the plan validator applies to an atomic plan: G1 through G9 judge the shell commands the plan states as acceptance conditions, and G10 judges the whole plan document.` The rest of the paragraph is unchanged.
  - Line 17: in the first sentence, replace the clause that begins `, both fed by the command extractor (` and ends with the closing parenthesis after the two extractor paths with a period, so the sentence ends after the `plan-gate-rules.ts` reference. Then insert, before `Enforcement is validator logic plus this prose file.`, one new sentence: the words `G1 through G9 are fed by the command extractor`, the same two extractor paths in parentheses, a semicolon, the words `G10 reads the whole document through`, and the backticked paths `scripts/dev_tools/plan_gate_scratch.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` joined by `and`, ending with a period. The two closing sentences of the paragraph are unchanged.
  - Line 289: replace the bullet text after the extractor clause with `scripts/dev_tools/plan_gate_discrimination.py` (backticked) followed by ` evaluates G1 through G9, calls ` and the backticked path `scripts/dev_tools/plan_gate_scratch.py` and ` for G10, and returns the two severity channels.`
  - The title line 13 and the line-45 sentence that explains the title parenthetical are unchanged.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_scope_and_enforcement_state_the_shipped_set` exits 0 with 1 passed.
- [x] [P4-T2] Document the continuation rule, the line-splitting rule, the normalization residual, and the issue-token class in `.claude/rules/plan-acceptance-gates.md` (CR-2, CR-4, CR-5)
  - After the line-151 paragraph (`Lines inside fenced code blocks are skipped, ...`) insert one blank line and one new paragraph made of these three sentences in order: `A continuation line is non-blank, begins with whitespace, and is not a fence line, so a heading or task line written at column 0 ends the logical line, and an indented heading or task line is absorbed into it.` `Both runtimes split the document into physical lines on the CR LF, LF, and CR terminators only; a form feed, a vertical tab, the information separators, NEL, and the Unicode line and paragraph separators do not end a physical line.` `One parity residual remains: whitespace normalization uses Python str.split() in one runtime and the JavaScript whitespace class in the other, and the two disagree on the information separators, NEL, and the byte-order mark, so a logical line containing one of those characters can produce a different finding or message text in the two runtimes.` (In the file, `str.split()` is written between backticks.)
  - After the `**Fenced definitions.**` bullet (line 166) insert the bullet `- **Any issue token after the definition.** A logical line is accepted when an issue-<digits> or issue-<issue-num> token appears anywhere in its text after the first definition match, including a cross-reference that is not the scratch location, such as (see issue-900 for context). Step 2 checks the namespace shape anywhere in that text, not inside a path segment.` (In the file, the two token shapes and the parenthesized cross-reference are each written between backticks.)
  - No literal bare SCRATCH definition is added outside a fenced block.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10_line_rules_and_issue_token_class tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` exits 0 with 2 passed.
- [x] [P4-T3] Copy the rule file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
  - Command (repository root): `cp .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. Fallback when the tool layer refuses `cp`: read the source with the Read tool and write the identical content to the destination with the Write tool.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical` exits 0 with 1 passed; `git hash-object .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` prints two equal object IDs, recorded in the [P4-T5] artifact.
- [x] [P4-T4] Update the detection contract, the NFR-2 note, and the false-negative list in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md` (CR-2, CR-4, CR-5)
  - `### Logical lines` item 2 (line 67): replace the second sentence with `Continuation stops at a fence line (an indented fence included) and at any line that does not begin with whitespace; a Markdown ATX heading or task line written at column 0 therefore ends the logical line, and an indented heading or task line is absorbed into it.`
  - After item 4 of `### Logical lines` add item `5. Physical lines are split on the CR LF, LF, and CR terminators only, in both runtimes and in the command extractor (remediation cycle 1).`
  - Under the NFR-2 bullet (line 209) add the sub-bullet `  - Remediation cycle 1 note: line splitting is aligned on the CR LF, LF, and CR terminators in both runtimes and in the command extractor. One residual difference remains in whitespace normalization (Python str.split() against the JavaScript whitespace class) for the information separators, NEL, and the byte-order mark; it is documented in .claude/rules/plan-acceptance-gates.md and is not fixed in this item.` (`str.split()` and the rule-file path written between backticks in the file).
  - Append to `## Known False-Negative Classes (documented, not fixed)` the bullet `- Any issue-<digits> or issue-<issue-num> token after the definition match, including a cross-reference that is not the scratch location.` (token shapes written between backticks in the file).
  - No acceptance-criterion checkbox in `spec.md` changes.
  - Acceptance: the Grep tool, output mode `count`, on `spec.md` returns 1 for each of the patterns `indented heading or task line is absorbed`, `Remediation cycle 1 note`, `token after the definition match`, and `CR LF, LF, and CR terminators only` (each 0 before this task), and the count for the pattern `^- \[x\] ` is unchanged from its value before the edit (31).
- [x] [P4-T5] Run the documentation, contract, push-down, and frontmatter suites and record `<FEATURE>/evidence/regression-testing/docs-green-rc1.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: 0 failed, or exactly one failure that is the #510 node with the #510 signature described in Conventions; the artifact records which case applies and the two object IDs from [P4-T3].
- [x] [P4-T6] Commit and push `.claude/rules/plan-acceptance-gates.md`, its bundle copy, `spec.md`, the evidence, and the plan check-offs
  - Commands: `git add .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md <FEATURE>/spec.md` (with the concrete folder path) plus the new evidence and this plan file; `git commit -m "docs(932): correct G10 scope, line-splitting, and false-negative text in the rule file"`; `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

### Phase 5 — Final QA Loop

Loop rule: [P5-T1] through [P5-T12] form one pass. If any of them fails or changes a file, fix the cause, commit the fix, and restart at [P5-T1]; each pass writes new artifacts with new timestamps. The loop ends only when one pass completes with every step meeting its acceptance and no file change.

- [x] [P5-T1] Run the final Python format check and record `<FEATURE>/evidence/qa-gates/python-format-final-rc1.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `5 files would be left unchanged.` Remediation branch: run `poetry run black` over the same five paths, record the `reformatted` and `left unchanged` summary, and restart the loop.
- [x] [P5-T2] Run the final Python lint check and record `<FEATURE>/evidence/qa-gates/python-lint-final-rc1.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `All checks passed!`.
- [x] [P5-T3] Run the final Python strict type check and record `<FEATURE>/evidence/qa-gates/python-typecheck-final-rc1.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `0 errors`.
- [x] [P5-T4] Run the final Python coverage gate and record `<FEATURE>/evidence/qa-gates/python-coverage-final-rc1.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_commands --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/final-py.json`
  - Acceptance: `EXIT_CODE: 0` and 0 failed; the total `passed` count is at least the [P0-T14] count. From each file's `summary` object in `SCRATCH/cov/final-py.json`: `plan_gate_scratch.py` has `covered_lines == num_statements` and `covered_branches == num_branches` (100% line and branch); `plan_gate_commands.py` line and branch percentages are not lower than the [P0-T14] values and each is at least the policy floor (85% line, 75% branch); no `+` line number in the hunks of `git diff -U0 <RC1_BASE> HEAD -- scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py` that is an executable statement appears in that file's `missing_lines`. `Output Summary:` records baseline, post-change, and changed-line figures for both files.
- [x] [P5-T5] Run the final Python contract and frontmatter suites and record `<FEATURE>/evidence/qa-gates/python-contract-final-rc1.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: 0 failed, or exactly the #510 node with the #510 signature (recorded as `pending-CI` for that node); the artifact quotes the `PASSED` line of `test_rule_file_bundle_copy_is_byte_identical`.
- [x] [P5-T6] Run the final broad dev-tools regression and record `<FEATURE>/evidence/qa-gates/python-devtools-final-rc1.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: every failing or erroring node ID is in the [P0-T15] reference set or is the #510 node; the artifact lists any node that newly passes or newly fails. A new failure related to this change is fixed inside this item and the loop restarts; when that fix edits a file outside the WRITES list, the out-of-scope remediation log in Conventions applies.
- [x] [P5-T7] Run the final TypeScript format check and record `<FEATURE>/evidence/qa-gates/ts-format-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `EXIT_CODE: 0` and `All matched files use Prettier code style!`, or, if [P0-T6] recorded pre-existing warnings, the reported file set is a subset of the baseline set and contains no file changed by this plan. Remediation branch for a file changed by this plan: `npx prettier --write` on that file, record `(unchanged)` or the rewrite, and restart the loop.
- [x] [P5-T8] Run the final repository lint script command and record `<FEATURE>/evidence/qa-gates/ts-lint-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `EXIT_CODE: 0` with 0 errors and no warning in a file changed by this plan.
- [x] [P5-T9] Run the final configuration-file lint and record `<FEATURE>/evidence/qa-gates/ts-lint-config-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint jest.config.cjs eslint.config.mjs`
  - Acceptance: `EXIT_CODE: 0` with no reported problem line.
- [x] [P5-T10] Run the final TypeScript production type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T11] Run the final TypeScript test type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-test-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T12] Run the final full jest coverage gate and record `<FEATURE>/evidence/qa-gates/ts-coverage-final-rc1.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `EXIT_CODE: 0`, 0 failed suites and tests, and no coverage-threshold message. From `extensions/drm-copilot/coverage/coverage-summary.json`: `src/lib/validate/plan-gate-scratch.ts` has `lines.pct` equal to 100 and `branches.pct` equal to 100; `src/lib/validate/plan-gate-commands.ts` percentages are not lower than the [P0-T10] values. From `extensions/drm-copilot/coverage/lcov.info`: no `+` line of `git diff -U0 <RC1_BASE> HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` has a zero-hit `DA:` record. `Output Summary:` records baseline, post-change, and changed-line figures.
- [x] [P5-T13] Confirm a single clean loop pass in `<FEATURE>/evidence/qa-gates/qa-loop-summary-rc1.<timestamp>.md`
  - Acceptance: the latest artifacts of [P5-T1] through [P5-T12] all carry timestamps from one pass that started after the last code commit, each records an `EXIT_CODE:` meeting its task, and `git status --porcelain` lists only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T14] Validate this plan and the original plan with the production CLI and record `<FEATURE>/evidence/qa-gates/plan-self-validation-rc1.<timestamp>.md`
  - Commands: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-plan.2026-10-16T01-52.md` and `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/plan.2026-10-15T15-45.md`.
  - Acceptance: both exit 0; neither prints a line containing `SCRATCH definition`; the artifact records each exit code and every printed `PLAN GATE WARNING: ` line verbatim.
- [x] [P5-T15] Check file size and temporary-file use for every changed non-Markdown file and record `<FEATURE>/evidence/qa-gates/file-size-and-tempfile-check-rc1.<timestamp>.md`
  - Method: the Grep tool with pattern `^` and output mode `count` on each of the ten non-Markdown files in the WRITES list below; the Grep tool with pattern `tmp_path|tempfile|mkdtemp|NamedTemporaryFile|tmpdir|writeFileSync|mkdtempSync` over the five changed test files.
  - Acceptance: every count is at most 500; the temporary-file search returns zero matches; the artifact lists each file with its count; for each of the five changed test files, the Grep tool, output mode count, on the file with the pattern [\x{2028}\x0c] returns 0.
- [x] [P5-T16] Verify the change scope and record `<FEATURE>/evidence/qa-gates/scope-diff-rc1.<timestamp>.md`
  - Commands: `git diff --name-only <RC1_BASE> HEAD`, `git diff --name-status --diff-filter=D <MERGE_BASE> HEAD`, `git status --porcelain`.
  - Acceptance: every path listed by the first command is in the WRITES list of this plan, or under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/`, or on a `PATH: ` line of an `out-of-scope-remediation.*.md` artifact written in this cycle (the artifact records `REMEDIATION-LOG: none` when no such file exists, with the Glob search that established it); `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/package.json`, and `research/bare-scratch-plan-gate.2026-10-15T19-52.md` are not listed; the deletion listing is empty; the porcelain listing shows only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T17] Commit and push the final evidence under `<FEATURE>/evidence/qa-gates/` and the plan check-offs
  - Commands: `git add` naming the new `<FEATURE>/evidence/qa-gates/` artifacts and this plan file; `git commit -m "docs(932): record remediation cycle 1 final QA evidence"`; `git push origin HEAD`.
  - Acceptance: after the push, `git status --porcelain` lists no path other than `SCRATCH/`; the push exits 0.

## Remediation Acceptance Criteria

- **RF-1.** `npx eslint jest.config.cjs` (from `extensions/drm-copilot/`) exits 0 without editing `jest.config.cjs` or adding a dependency; the original `[P3-T6]` command exits 0 and is recorded in a new `ts-lint-phase3` artifact; `[P3-T6]` is checked in `plan.2026-10-15T15-45.md`; the repository lint script still exits 0.
- **CR-2.** Neither G10 module contains the heading or task-line condition; behaviour is unchanged (pinned by the absorb fixtures); the stop fixtures are labelled by what they prove; the rule file and `spec.md` state the column-0 rule; both modules stay at 100% line and branch coverage.
- **CR-3.** Rule-file lines 15, 17, and 289 state G1 through G9 plus G10; the bundle copy is byte-identical.
- **CR-4.** Python and TypeScript split plan text on CR LF, LF, and CR only, in G10 and in the command extractor, through one shared splitter per runtime; frozen form-feed and U+2028 fixtures pass in both suites; the normalization residual is documented in the rule file and the `spec.md` NFR-2 note.
- **CR-5.** The rule file (and bundle copy) and `spec.md` list the issue-token-after-definition false-negative class, including a cross-reference example.

## Acceptance-Criteria Map

| ID | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- |
| RF-1 | P3-T3, P3-T6 | `npx eslint jest.config.cjs`; original `[P3-T6]` command; lint script | ts-lint-phase3 (P3-T5), ts-lint-config-final-rc1, ts-lint-final-rc1 |
| CR-2 | P2-T2, P3-T2, P4-T2, P4-T4 | `test_indented_heading_and_task_line_continue_logical_line`; `test_logical_line_stops_at_heading_fence_and_task_line`; TS cases `absorbs an indented heading or task line into the logical line` and `stops a logical line at an indented fence and at a column-0 heading or task line`; `test_rule_file_documents_g10_line_rules_and_issue_token_class` | python-green-rc1, ts-green-rc1, python-coverage-final-rc1, ts-coverage-final-rc1 |
| CR-3 | P4-T1, P4-T3 | `test_rule_file_scope_and_enforcement_state_the_shipped_set`; `test_rule_file_bundle_copy_is_byte_identical` | docs-green-rc1, python-contract-final-rc1 |
| CR-4 | P2-T1, P2-T2, P3-T1, P3-T2, P4-T2, P4-T4 | `test_split_plan_lines_splits_only_on_cr_lf_terminators`; `test_extract_plan_commands_line_numbers_ignore_form_feed_and_line_separator`; `test_bare_scratch_definitions_splits_only_on_cr_lf_terminators`; TS cases `splits only on CR LF, LF, and CR terminators`, `reports line numbers that ignore a form feed and a line separator`, `does not end a physical line at a form feed or a line separator` | python-red-rc1, ts-red-rc1, python-green-rc1, ts-green-rc1 |
| CR-5 | P4-T2, P4-T3, P4-T4 | `test_rule_file_documents_g10_line_rules_and_issue_token_class` | docs-green-rc1 |

## WRITES (repository files outside the feature folder)

- `extensions/drm-copilot/eslint.config.mjs`
- `scripts/dev_tools/plan_gate_commands.py`
- `scripts/dev_tools/plan_gate_scratch.py`
- `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`
- `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`
- `tests/scripts/dev_tools/test_plan_gate_commands.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
- `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`
- `.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`

Feature-folder writes: this plan, `plan.2026-10-15T15-45.md` (the `[P3-T6]` checkbox only), `spec.md` (text only; no checkbox), and evidence under `evidence/remediation-baseline/`, `evidence/regression-testing/`, and `evidence/qa-gates/`.

Scratch files (not committed): `SCRATCH/cov/README.txt`, `SCRATCH/cov/baseline-py.json`, `SCRATCH/cov/final-py.json`.

## Appendix A — `extensions/drm-copilot/eslint.config.mjs` (complete file content)

The content ends with a single newline and carries no trailing whitespace (the current file has a trailing space after the final `);`).

```js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ["src/**/*.ts", "test/**/*.ts"],
    languageOptions: {
      parserOptions: {
        project: false,
      },
    },
    rules: {
      "no-console": "off",
    },
  },
  {
    // CommonJS configuration and build scripts (for example jest.config.cjs)
    // run under Node; declare the module system and the Node globals they use.
    files: ["**/*.cjs"],
    languageOptions: {
      sourceType: "commonjs",
      globals: {
        module: "writable",
        require: "readonly",
        __dirname: "readonly",
        process: "readonly",
      },
    },
  },
  {
    ignores: ["out/**", "node_modules/**"],
  },
);
```

## Appendix B — New Test Fixtures

Python string literals are shown with escapes; both runtimes write a form feed as the two-character escape for form feed and U+2028 as the six-character Unicode escape, and no test file contains a raw form-feed or U+2028 character. The definition-line constant in the absorb fixtures is the existing `_DEFINITION_LINE` (Python) or `DEFINITION_LINE` (TypeScript).

```text
Splitter cases (P1-T1, P1-T4):
  empty                         ""                      -> []
  trailing-lf                   "a\n"                   -> ["a"]
  mixed-terminators             "a\r\nb\rc\n\n"         -> ["a", "b", "c", ""]
  form-feed-and-line-separator  "a\fb\u2028c"           -> ["a\fb\u2028c"]

Extractor cases (P1-T1, P1-T4); one command, task P1-T1, source line 2:
  form-feed       "### Phase 1 — Work\f\n- [ ] [P1-T1] Run `poetry run pytest tests/a.py`\n"
  line-separator  "### Phase 1 — Work\u2028\n- [ ] [P1-T1] Run `poetry run pytest tests/a.py`\n"

G10 fixtures (P1-T2, P1-T5) and their single frozen finding:
  G10-ABSORB-HEADING   DEFINITION_LINE + "\n  ## Indented heading"
                       -> (1, "- SCRATCH means the session scratchpad. ## Indented heading")
  G10-ABSORB-TASK      DEFINITION_LINE + "\n  - [ ] [P1-T1] Do the thing"
                       -> (1, "- SCRATCH means the session scratchpad. - [ ] [P1-T1] Do the thing")
  G10-FORM-FEED        "intro\fSCRATCH is the session scratchpad."
                       -> (1, "intro SCRATCH is the session scratchpad.")
  G10-LINE-SEPARATOR   "intro\u2028SCRATCH is the session scratchpad."
                       -> (1, "intro SCRATCH is the session scratchpad.")
```

Before the Phase 2 change, Python `str.splitlines()` reports the two G10 split fixtures at line 2 with the text after the separator, and the two extractor cases at source line 3; these are the expected red failures in [P1-T6].

## Appendix C — `split_plan_lines` (Python)

```python
_LINE_BREAK_RE = re.compile(r"\r\n|\n|\r")


def split_plan_lines(text: str) -> list[str]:
    """Split plan text into physical lines on CR LF, LF, and CR only.

    Purpose:
        Share one line-splitting rule between the command extractor and the
        G10 rule, matching the TypeScript `splitPlanLines` byte for byte.
        `str.splitlines()` also breaks on form feed, vertical tab, the
        information separators, NEL, and the Unicode line and paragraph
        separators, which the TypeScript split does not, so the two runtimes
        would otherwise report different line numbers for the same text.

    Args:
        text (str): Full document text.

    Returns:
        list[str]: Lines without their terminators. Empty text yields no
        lines, and the empty element after a final terminator is dropped.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not text:
        return []
    lines = _LINE_BREAK_RE.split(text)
    # Drop the empty element after a final terminator, as `str.splitlines()`
    # and the TypeScript twin both do.
    if lines[-1] == "":
        lines.pop()
    return lines
```

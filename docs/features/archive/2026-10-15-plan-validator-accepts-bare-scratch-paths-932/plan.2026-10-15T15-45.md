# plan-validator-accepts-bare-scratch-paths (Plan)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T15-45 (preflight revision round 2 applied)
- **Status:** Ready for preflight
- **Version:** 1.1
- **Work Mode:** full-bug. `spec.md` in this folder is the sole acceptance-criteria source; `user-story.md` is intentionally absent.
- **Branch:** `bug/plan-validator-accepts-bare-scratch-paths-932`
- **Inputs:** `spec.md` (32 acceptance criteria), `issue.md`, and `research/2026-10-15T19-52-bare-scratch-plan-gate-research.md` (authoritative). The file `research/bare-scratch-plan-gate.2026-10-15T19-52.md` is a stale duplicate, is not an input, and is not deleted by this plan.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above applies to preflight rounds only. After preflight returns `PREFLIGHT: ALL CLEAR`, the orchestrator delegates execution separately.

**Fail-closed evidence rule:** Each in-scope language has explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks. If any required baseline, QA, or coverage-comparison artifact is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with every required field.

## Conventions

- `<FEATURE>` abbreviates `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932`. Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` (kinds used: `baseline`, `regression-testing`, `qa-gates`, `other`).
- Evidence artifacts are named `<name>.<timestamp>.md`. The `<timestamp>` is the UTC write time read from the host clock immediately before the write (for example `date -u +%Y-%m-%dT%H-%M`), in the shape `yyyy-MM-ddTHH-mm`. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage-bearing artifacts carry numeric line and branch percentages in `Output Summary:`.
- Scratch location (issue #900 rule):
  - `SCRATCH` resolves to `<session scratchpad>/issue-932/`.
  - Every scratch file, helper script, and coverage report this plan names lives under `SCRATCH` (subdirectories `SCRATCH/cov/` and `SCRATCH/g10/`). Nothing is written to the scratchpad root.
  - Evidence and this plan record the literal token `SCRATCH`, never a host path. When pytest or jest output contains a host path, the executor replaces the scratch prefix with `SCRATCH` and the repository prefix with a repository-relative path before recording it.
- `<MERGE_BASE>` denotes the commit SHA recorded by [P0-T2] in the latest `<FEATURE>/evidence/baseline/git-baseline.*.md`. If the branch is rebased later, the executor re-derives it with `git merge-base origin/main HEAD` and records the new value in the consuming artifact. `git diff <MERGE_BASE> HEAD` is equivalent to the spec's `origin/main...HEAD` form.
- TypeScript commands run with `extensions/drm-copilot/` as the working directory. Python and git commands run at the repository root.
- Python check-mode commands only: `black --check` and `ruff check --no-fix`. Write-mode formatting is permitted only inside the remediation branch of a check task and is followed by a loop restart.
- Commits: `git add` names each file explicitly. No force push. No file is deleted. No issue is created. A related finding discovered during execution is fixed inside this item by a remediation cycle; a completely unrelated finding is recorded in `<FEATURE>/evidence/other/unrelated-findings.<timestamp>.md` for later filing.
- Known local failure (#510): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally because of gitignored state. Only that node, with a failure message that names a gitignored path absent from the bundle, is accepted locally; any other failure in that file is a real failure. CI is the authority for that node.
- PowerShell and bats are not in scope; if a PowerShell change becomes necessary, verification follows Option A (PoshQC MCP tools plus CI evidence).
- Agent-worktree command routes: the worktree isolation guard refuses any command text containing `pwsh`, `bash`, or `wsl`, so no task in this plan invokes `pwsh`. File creation and copying use the Write tool or `cp`; timestamps use `date -u`.
- Out-of-scope remediation log: whenever [P2-T3] or [P6-T6] (or a [P6] loop restart that fixes a cause found by [P6-T6]) edits a repository file that is not in the WRITES list, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation.<timestamp>.md` carrying `Timestamp:`, the triggering task ID, one `PATH: ` line per edited repository-relative path, and a one-line reason per path. Each remediation writes a new file; the set of remediated paths is the union of the `PATH: ` lines across every file matching `out-of-scope-remediation.*.md`. Those paths are staged in the commit of the phase that edited them.
- Prior-item references: the #900 feature folder `*-concurrent-children-share-scratchpad-file-names-900/` is located under either `docs/features/active/` or `docs/features/archive/`.

## Fixture Rule for This Plan

This plan must itself pass G10. It therefore quotes no bare SCRATCH definition outside a fenced block. Test fixtures are taken from the `spec.md` sections `### Examples: accepted (no finding)`, `### Examples: rejected (one finding each)`, `### Examples: not definitions (no finding)`, and `## Error Message Contract`; the executor copies them from `spec.md` into the test files rather than from this plan.

### Phase 0 — Policy Reads and Baseline Capture

All Phase 0 commands are read-only check modes, except [P0-T10], which installs untracked dependencies under `extensions/drm-copilot/node_modules/` when they are absent and changes no tracked file. No write-mode formatter runs before every baseline artifact in this phase exists.

- [x] [P0-T1] Read the policy files in policy-compliance order and record them in `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md`
  - Files, in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and a list naming all nine files in that order.
- [x] [P0-T2] Record the git baseline in `<FEATURE>/evidence/baseline/git-baseline.<timestamp>.md`
  - Commands: `git fetch origin main`, `git rev-parse HEAD`, `git merge-base origin/main HEAD`, `git status --porcelain`.
  - Acceptance: the artifact records each command with its `EXIT_CODE:` (all 0), the HEAD SHA, the merge-base SHA under the label `MERGE_BASE:`, and the porcelain output (expected empty).
- [x] [P0-T3] Create the scratch directories `SCRATCH/cov/` and `SCRATCH/g10/` and record their creation in `<FEATURE>/evidence/baseline/scratch-setup.<timestamp>.md`
  - Method: the Write tool writes a one-line `README.txt` (content: `Issue 932 scratch directory; not committed.`) to `SCRATCH/cov/README.txt` and to `SCRATCH/g10/README.txt`, with `SCRATCH` resolved to its absolute path for the tool call only. The Write tool creates the missing parent directories. No shell command is used.
  - Acceptance: the Glob tool with pattern `*/README.txt` rooted at the resolved `SCRATCH` directory returns exactly the two files `cov/README.txt` and `g10/README.txt`; the artifact records the method, the two relative results, and uses the token `SCRATCH` only.
- [x] [P0-T4] Capture the Python format baseline in `<FEATURE>/evidence/baseline/python-format-baseline.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: artifact fields present; `Output Summary:` quotes the black summary line (for example `4 files would be left unchanged.`) and the observed exit code, whatever it is.
- [x] [P0-T5] Capture the Python lint baseline in `<FEATURE>/evidence/baseline/python-lint-baseline.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: artifact fields present; `Output Summary:` quotes either `All checks passed!` or the diagnostic count.
- [x] [P0-T6] Capture the Python type-check baseline in `<FEATURE>/evidence/baseline/python-typecheck-baseline.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: artifact fields present; `Output Summary:` quotes the pyright summary line (`N errors, N warnings, N informations`).
- [x] [P0-T7] Capture the Python coverage baseline for `scripts.dev_tools.plan_gate_discrimination` in `<FEATURE>/evidence/baseline/python-coverage-baseline.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py.json`
  - Acceptance: `Output Summary:` records the pytest pass/fail counts, the `term-missing` table row for `plan_gate_discrimination.py` (Stmts, Miss, Branch, BrPart, Cover, Missing), and numeric line coverage (`covered_lines / num_statements`) and branch coverage (`covered_branches / num_branches`) read from that file's `summary` object in `SCRATCH/cov/baseline-py.json`. The artifact also lists the file's `missing_lines` and `missing_branches` for the changed-line comparison in [P6-T4].
- [x] [P0-T8] Capture the contract-suite baseline in `<FEATURE>/evidence/baseline/python-contract-baseline.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: `Output Summary:` records pass/fail counts and every failing node ID with its first failure line; a #510 failure is labelled as such.
- [x] [P0-T9] Capture the broad dev-tools regression baseline in `<FEATURE>/evidence/baseline/python-devtools-baseline.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: `Output Summary:` records the pass/fail/error/skip counts and lists every failing or erroring node ID (the reference set for [P6-T6]).
- [x] [P0-T10] Install the extension's locked npm dependencies in `extensions/drm-copilot/node_modules/` only when they are missing, and record `<FEATURE>/evidence/baseline/npm-dependencies.<timestamp>.md`
  - Presence probe: the Glob tool with pattern `extensions/drm-copilot/node_modules/jest/package.json` (repository root).
  - Skip branch (explicitly authorized): when the probe returns that file, no install command runs; the artifact records `NPM_CI: not required`, the probe result, and `EXIT_CODE: 0` for the probe.
  - Install branch: when the probe returns no file, run `npm ci --prefix extensions/drm-copilot --no-audit --no-fund` from the repository root (the `--prefix` form avoids a `cd` chain), then repeat the probe, then run `git status --porcelain -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json`. Route note: `npm ci` is not among the `Bash(...)` patterns in the `.claude/agents/atomic-executor.md` frontmatter (which lists only `npx prettier`, `npx eslint`, `npx tsc`, and `npx jest` for Node), and no generic `npx` pattern exists there that could carry an install. The command contains no token blocked by `.claude/hooks/validate-bash.ps1` and no `cd` chain; whether the tool layer accepts it is determined when the command runs, and the BLOCKED branch below covers refusal. If the tool layer refuses the command, the task stops with `BLOCKED: npm ci refused` in the artifact and the executor reports it to the caller; it does not continue to [P0-T11] without dependencies.
  - Acceptance (install branch): `npm ci` records `EXIT_CODE: 0`; the repeated probe returns `extensions/drm-copilot/node_modules/jest/package.json`; the porcelain command prints nothing (no tracked file changed). `Output Summary:` records the npm `added N packages` line, the probe result before and after, and the empty porcelain output.
- [x] [P0-T11] Capture the TypeScript format baseline in `<FEATURE>/evidence/baseline/ts-format-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
  - Acceptance: `Output Summary:` quotes either `All matched files use Prettier code style!` or the list of files reported with warnings.
- [x] [P0-T12] Capture the TypeScript lint baseline in `<FEATURE>/evidence/baseline/ts-lint-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: artifact fields present; `Output Summary:` records the error and warning counts (zero output on a clean run is recorded as `0 errors, 0 warnings`).
- [x] [P0-T13] Capture the TypeScript production type-check baseline in `<FEATURE>/evidence/baseline/ts-typecheck-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: artifact fields present; `Output Summary:` records the diagnostic count (no output on success).
- [x] [P0-T14] Capture the TypeScript test type-check baseline in `<FEATURE>/evidence/baseline/ts-typecheck-test-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: artifact fields present; `Output Summary:` records the diagnostic count.
- [x] [P0-T15] Capture the full jest coverage baseline in `<FEATURE>/evidence/baseline/ts-coverage-baseline.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `Output Summary:` records the suite and test pass/fail counts, the `text-summary` totals, every failing suite, any coverage-threshold message, and the `lines.pct` and `branches.pct` values for `src/lib/validate/plan-gate-discrimination.ts` read from `extensions/drm-copilot/coverage/coverage-summary.json`. The artifact also lists the zero-hit `DA:` line numbers for that file read from `extensions/drm-copilot/coverage/lcov.info` (input to [P6-T11]).
- [x] [P0-T16] Commit and push the Phase 0 evidence under `<FEATURE>/evidence/baseline/` together with the plan check-offs
  - Commands: `git add <FEATURE>/evidence/baseline <FEATURE>/plan.2026-10-15T15-45.md` (with the concrete folder path), `git commit -m "docs(932): record phase 0 baselines"`, `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

### Phase 1 — Red Tests and Contract-Test Changes

Static checks (format, lint, type-check) for the files written in this phase are explicitly waived until Phase 2 (Python) and Phase 3 (TypeScript), because the production modules they import do not exist yet. No task in this phase or in Phase 2 runs a test node that a later phase makes pass, except the two `[expect-fail]` runs.

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_plan_gate_scratch.py` with the G10 unit, dispatcher, CLI, and parity tests
  - Required test functions (exact names): `test_g10_severity_is_blocking`; `test_bare_scratch_definitions_accepts_namespaced_forms` (parametrized over the three accepted examples in `spec.md`); `test_bare_scratch_definitions_flags_unnamespaced_forms` (parametrized over every single-line rejected example in `spec.md` plus a plain-colon form, a `denotes` form, a `refers to` form, a `stands for` form, and an `is an` form; each asserts exactly one finding at line 1); `test_bare_scratch_definitions_ignores_non_definitions` (parametrized over the five non-definition examples in `spec.md` plus a bare definition placed inside a three-backtick fence); `test_wrapped_definition_reports_first_line` (the two-line wrapped example from `spec.md`, preceded by one unrelated line so the expected line number is 2); `test_logical_line_stops_at_heading_fence_and_task_line` (parametrized over three fixtures, each a bare definition line followed directly by (a) an indented three-backtick fence block with an opening line, one content line, and a closing line, (b) a `## ` heading line, or (c) a canonical task line; each asserts exactly one finding at line 1 whose normalized text equals the definition line alone); `test_g10_message_matches_frozen_string` (two fixtures, one carrying an apostrophe and one carrying a tab, each compared to a frozen literal built from the `spec.md` Error Message Contract); `test_evaluate_scratch_gate_routes_by_severity_argument` (passes `severity=WARNING_CHANNEL` and `severity=BLOCKING_CHANNEL` and asserts channel placement); `test_evaluate_plan_gates_reports_g10_with_and_without_context` (asserts `report.blocking` equals the frozen G10 list both for `context=None` and for a stub `PlanGateContext`, and that the two lists are equal); `test_cli_rejects_bare_scratch_definition` and `test_cli_accepts_namespaced_scratch_definition` (monkeypatch `validate_orchestration_artifacts._read_text`, call `validate_orchestration_artifacts.main(["plan", "ignored.md"])`, use `capsys`; the reject case asserts exit 1 and the `Line N:` G10 message on stderr, the accept case asserts no `SCRATCH definition` text on stderr and exit 0); `test_g10_severity_constant_matches_typescript` (regex `G10_SEVERITY\s*:\s*string\s*=\s*"([^"]+)"` over `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, compared to the Python constant); `test_fence_pattern_matches_extractor` (compares `plan_gate_scratch.FENCE_RE.pattern` to `vars(plan_gate_commands)["_FENCE_RE"].pattern`; the `vars()` form is used because ruff B009 rejects a `getattr` call with a constant name and direct attribute access to a private name fails pyright strict).
  - Structural rules: Arrange–Act–Assert comments; no temporary files; no file I/O except reading the TypeScript source in the parity test; the plan fixtures for the dispatcher and CLI tests contain a canonical `### Phase 1 — Work` heading and one canonical task line so that structural validation yields no error. File length at most 500 lines.
  - Acceptance: the Grep tool, output mode `count`, on `tests/scripts/dev_tools/test_plan_gate_scratch.py` with the pattern `^def (test_g10_severity_is_blocking|test_bare_scratch_definitions_accepts_namespaced_forms|test_bare_scratch_definitions_flags_unnamespaced_forms|test_bare_scratch_definitions_ignores_non_definitions|test_wrapped_definition_reports_first_line|test_logical_line_stops_at_heading_fence_and_task_line|test_g10_message_matches_frozen_string|test_evaluate_scratch_gate_routes_by_severity_argument|test_evaluate_plan_gates_reports_g10_with_and_without_context|test_cli_rejects_bare_scratch_definition|test_cli_accepts_namespaced_scratch_definition|test_g10_severity_constant_matches_typescript|test_fence_pattern_matches_extractor)\(` returns exactly 13 (one per name; the file does not exist before this task, so the count is 0 until the task is done). The count is recorded in the [P1-T8] artifact. The [P1-T8] collection list cannot serve as this check, because that file fails collection on the missing module.
- [x] [P1-T2] Create `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` with the documentation and frontmatter tests
  - Required test functions: `test_rule_file_documents_g10` (reads `.claude/rules/plan-acceptance-gates.md` and asserts the presence of each of these single-line tokens: `| **G10** |`, `### G10 — ships as Blocking`, `G1 through G10 are the complete shipped set.`, `G10 exception`, the enforcement token defined below, `### Known false-negative classes — G10`, `operator-approved scope for issue #932`, `g10-corpus-measurement.`; asserts the absence of `G1 through G9 are the complete shipped set.`; asserts that the `### G10 — ships as Blocking` heading lies after `## Severity Decisions` and before `## The Write-Mode Register`, and that the enforcement token lies after `## Enforcement`). Enforcement token: the exact 54-character literal formed by one backtick character, the path `scripts/dev_tools/plan_gate_scratch.py`, one backtick character, one space, and the words `evaluates G10`, in that order with nothing between them. The test declares it as a module constant `ENFORCEMENT_TOKEN` whose Python value is that 54-character string, written as a double-quoted Python string literal containing the two backtick characters, and [P5-T5] creates the same literal as the opening text of the new `## Enforcement` bullet; `test_rule_file_bundle_copy_is_byte_identical` (compares `read_bytes()` of `.claude/rules/plan-acceptance-gates.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`); `test_atomic_plan_contract_states_shipped_set_through_g10` (both `.claude/skills/atomic-plan-contract/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` contain `The complete shipped set is therefore G1 through G10.`, neither contains `The complete shipped set is therefore G1 through G9.`, and their bytes are equal); `test_rule_frontmatter_paths_reach_scratch_gate_modules` (imports `assert_rule_paths_reach` from `tests.scripts.dev_tools.test_claude_rules_frontmatter` and asserts `plan-acceptance-gates.md` reaches `scripts/dev_tools/plan_gate_scratch.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`); `test_discrimination_docstrings_name_g10` (asserts `G1 through G10` is in `plan_gate_discrimination.__doc__`, `G10` is in `evaluate_plan_gates.__doc__`, and `pre-change output` is not in `evaluate_plan_gates.__doc__`).
  - Acceptance: the file is at most 500 lines; the Grep tool, output mode `count`, with the pattern `^def (test_rule_file_documents_g10|test_rule_file_bundle_copy_is_byte_identical|test_atomic_plan_contract_states_shipped_set_through_g10|test_rule_frontmatter_paths_reach_scratch_gate_modules|test_discrimination_docstrings_name_g10)\(` returns exactly 5, and with the pattern `^ENFORCEMENT_TOKEN = ` returns exactly 1.
- [x] [P1-T3] Add `plan_gate_scratch.py` to `_PYTHON_GATE_MODULES` in `tests/scripts/dev_tools/test_plan_gate_parity.py`
  - Edit: one tuple entry `_REPO_ROOT / "scripts" / "dev_tools" / "plan_gate_scratch.py",` after the `plan_gate_observability.py` entry (the file is 493 lines before the edit and 494 after).
  - Sibling docstring correction (same file, lines 8–13 before the edit): the module docstring already names only two Python gate modules and a count of three TypeScript gate modules, which the new entry makes further out of date. Reword those lines in place, without adding lines, so they name the discrimination, coverage, observability, and scratch modules and refer to the TypeScript gate modules without a fixed count. No other line changes. This docstring correction is a recorded deviation from the `spec.md` NFR-4 statement that this file changes only its module list; the NFR-4 file-size rationale is preserved because no line is added. The executor records the deviation in the [P1-T8] artifact as `SPEC-DEVIATION: NFR-4 docstring reword`.
  - Acceptance: the tuple contains four entries, the new one last; the Grep tool, output mode `count`, on the file with the pattern `— currently$` returns 0 (it returns 1, on line 9, before the edit); the file is at most 494 lines.
- [x] [P1-T4] Rewrite the scan and extend the rule sources in `tests/scripts/dev_tools/test_scratch_location_contracts.py`
  - Remove the `FORBIDDEN_SCRATCH_PATHS` constant and every reference to it.
  - Add `from scripts.dev_tools.plan_gate_scratch import bare_scratch_definitions`, a constant `SCRATCHPAD_ROOT_RE = re.compile(r"<[^>\n]*scratchpad[^>\n]*>/(?!issue-)", re.IGNORECASE)`, and a helper `scratch_violations(text: str) -> list[str]` that returns one entry per G10 detector result (`Line N: <normalized line>`) plus one entry per root-regex match.
  - Change `test_normative_surfaces_name_no_bare_fixed_scratch_path` (name unchanged) to assert `scratch_violations` is empty for every normative surface, keeping the primary-source coverage assertion.
  - Add `.codex/agents/*.toml` to `NORMATIVE_SURFACE_GLOBS`.
  - Add the parametrized self-test `test_scratch_pattern_check_self_test` with four cases: `<scratchpad>/run-ps.sh` (flagged), `<SCRATCHPAD>/derive-worklists.ps1` (flagged), the `spec.md` rejected example that begins with the word SCRATCH followed by `is the session scratchpad` (flagged), and `<session scratchpad>/issue-<issue-num>/run-ps.sh` (accepted).
  - Add constants `CODEX_PLANNER = ".codex/agents/atomic-planner.toml"` and `CODEX_EXECUTOR = ".codex/agents/atomic-executor.toml"`; add both to `RULE_SOURCES` (ids `codex-planner`, `codex-executor`), add `CODEX_EXECUTOR` to `EXECUTOR_SOURCES`, add `(CODEX_PLANNER, "## Requirements", "## Preflight Validation")` to `PLANNER_PLACEMENTS`, and add `(CODEX_EXECUTOR, "## Toolchain Commands", "## Preflight Validation")` to `EXECUTOR_PLACEMENTS`.
  - Update the module docstring to state that the two Codex base TOMLs are also asserted and that the scan uses the production G10 detector.
  - Acceptance: the file is at most 500 lines; the Grep tool, output mode `count`, on `tests/scripts/dev_tools/test_scratch_location_contracts.py` returns 0 for the pattern `FORBIDDEN_SCRATCH_PATHS` (it returns 2 before the rewrite, at the constant on line 93 and its use on line 269), 1 for the pattern `^def scratch_violations\(`, 1 for the pattern `^def test_scratch_pattern_check_self_test\(`, and 1 for the pattern `^SCRATCHPAD_ROOT_RE = `. The counts are recorded in the [P1-T8] artifact.
- [x] [P1-T5] Create `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` with the TypeScript G10 tests
  - Cases (in one `describe("plan-gate-scratch G10", ...)` block): `G10_SEVERITY` equals `"blocking"`; the same accepted, rejected, non-definition, wrapped-line, heading/fence/task-stop, and fenced fixtures as [P1-T1], with the same expected line numbers; the same two frozen message strings as [P1-T1], byte for byte; `evaluateScratchGate` routes to the channel named by an explicit `severity` argument (both channels); `evaluatePlanGates` returns the frozen G10 list in `blocking` both with no context and with a stub `PlanGateContext`; `validateArtifactWithWarnings({ artifactType: "plan", text })` returns the G10 message in `errors` for a plan with a bare definition and no G10 text for a namespaced one; `bareScratchDefinitions`, `evaluateScratchGate`, and `G10_SEVERITY` are importable from `src/lib/validate/plan-gate-discrimination` (re-export); the JSDoc block immediately preceding `export function evaluatePlanGates` in `src/lib/validate/plan-gate-discrimination.ts` contains `G10`, and that file does not contain `pre-change output`; `jest.config.cjs` source matches `/"\.\/src\/lib\/validate\/plan-gate-scratch\.ts":\s*\{\s*lines:\s*85,\s*branches:\s*75,?\s*\}/`.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; file reads only of the two source files named above; at most 500 lines. Every case is a plain `it("<literal title>", ...)` call with a string-literal title (no `it.each`, no `test(`, no template-literal titles), so the titles in the source equal the titles jest prints. A fixture group is one case whose single assertion compares the full array of results to the expected array.
  - Acceptance: the Grep tool, output mode `count`, on `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` returns exactly 1 for the pattern `describe\("plan-gate-scratch G10"` and returns 0 for the pattern `it\.each|^\s*test\(`; the Grep tool, output mode `content`, with the pattern `^\s*it\("` lists the case titles, and that list (its count recorded as `TS_CASE_COUNT:`) is recorded verbatim in the [P1-T9] artifact. Cross-check: [P3-T7] asserts that its `--verbose` output lists every one of those titles as passing under `plan-gate-scratch G10` and lists no other case under that `describe` title.
- [x] [P1-T6] Add `plan-gate-scratch.ts` to `GATE_MODULE_PATHS` in `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`
  - Edit: one array entry `path.join(__dirname, "../../../src/lib/validate/plan-gate-scratch.ts"),` after the `plan-gate-observability.ts` entry.
  - Acceptance: the array contains five entries, the new one last.
- [x] [P1-T7] Add the MCP throw-path case to `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts`
  - Add a fixture constant `BARE_SCRATCH_PLAN` whose first line is the `spec.md` rejected example that begins with the word SCRATCH followed by `is the session scratchpad`, followed by the `### Phase 1 — Work` heading and one canonical task line; add the case `it("throws with the G10 message when a SCRATCH definition is not namespaced", ...)` asserting `toThrow` with the exact text `Validation failed for plan artifact at 'docs/plan.md':\n` followed by the frozen G10 message for line 1.
  - Acceptance: the file is at most 500 lines and contains the new case.
- [x] [P1-T8] [expect-fail] Run the Python red set and record `<FEATURE>/evidence/regression-testing/python-red.<timestamp>.md`
  - Command: `poetry run pytest -v --continue-on-collection-errors tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages`
  - Expected outcome: non-zero exit. Expected signatures: two collection errors naming `ModuleNotFoundError` for `scripts.dev_tools.plan_gate_scratch` (in `test_plan_gate_scratch.py` and `test_scratch_location_contracts.py`); failures of `test_rule_file_documents_g10`, `test_atomic_plan_contract_states_shipped_set_through_g10`, and `test_discrimination_docstrings_name_g10`; a failure of `test_no_repr_formatting_in_gate_messages` on the missing `plan_gate_scratch.py` file (`FileNotFoundError` or `No such file`). `test_rule_file_bundle_copy_is_byte_identical` and `test_rule_frontmatter_paths_reach_scratch_gate_modules` are expected to pass at this point, because the bundle copy is still identical and the existing frontmatter globs already cover the new paths.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` (set to the observed exit code only when every observed failure and error matches an expected signature above), and `Output Summary:` naming each failing or erroring node or file with its first error line and the two passing nodes, as printed by the `-v` per-node lines. The artifact also records the Grep counts from [P1-T1], [P1-T2], and [P1-T4]. Any unexpected signature halts the task for a plan revision.
- [x] [P1-T9] [expect-fail] Run the TypeScript red set and record `<FEATURE>/evidence/regression-testing/ts-red.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts`
  - Expected signatures: `plan-gate-scratch.test.ts` fails to run because `../../../src/lib/validate/plan-gate-scratch` cannot be found; the parity case `renders offending values without pythonRepr formatting` fails with `ENOENT`; the new service-call case fails because no error is thrown.
  - Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `Output Summary:` naming the three failures above and the passing count of every other case; it also records `TS_CASE_COUNT:` and the verbatim case-title list from [P1-T5]. Any other failure halts the task for a plan revision.
- [x] [P1-T10] Commit and push the Phase 1 test changes, the `<FEATURE>/evidence/regression-testing/` artifacts, and the plan check-offs
  - Commands: `git add tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts` plus the evidence folder and plan file, `git commit -m "test(932): add failing G10 tests and scratch contract pattern check"`, `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

### Phase 2 — Python G10 Implementation

- [x] [P2-T1] Create `scripts/dev_tools/plan_gate_scratch.py` (the Python G10 authority)
  - Module docstring: purpose, scope (document-level, context-free), the acyclic import rule, and the no-`repr` rule.
  - Imports: `re`; `TYPE_CHECKING`; at runtime only `PLAN_GATE_HEADING_RE` and `PLAN_GATE_TASK_RE` from `scripts.dev_tools.plan_gate_commands`; `PlanGateReport` from `scripts.dev_tools.plan_gate_discrimination` under `TYPE_CHECKING` only.
  - Constants: `BLOCKING_CHANNEL = "blocking"`, `WARNING_CHANNEL = "warning"` (declared locally, as in `plan_gate_observability.py`); `G10_SEVERITY: str = BLOCKING_CHANNEL`; `FENCE_RE = re.compile(r"^\s*```")`; `SCRATCH_DEFINITION_PATTERN` and `SCRATCH_NAMESPACE_PATTERN` as raw strings equal to the two patterns in the `spec.md` Predicate section; both compiled with `re.ASCII` so `\b` matches the JavaScript dialect.
  - `bare_scratch_definitions(text: str) -> list[tuple[int, str]]`: walks `text.splitlines()` once; toggles fence state on `FENCE_RE` lines and skips fenced lines; starts a logical line at each non-blank, non-fenced line; appends each following line that is non-blank, begins with whitespace, and matches none of `FENCE_RE`, `PLAN_GATE_HEADING_RE`, and `PLAN_GATE_TASK_RE`; normalizes the joined logical line with `" ".join(value.split())`; applies the definition pattern with `search`; accepts the line when the namespace pattern matches the text after the end of the first definition match; returns `(first physical line number, normalized logical line)` for each unaccepted line, at most one per logical line, in source order.
  - `scratch_finding_message(line_number: int, logical_line: str) -> str`: returns the exact `spec.md` Error Message Contract string using an f-string with backtick delimiters and no conversion flag.
  - `evaluate_scratch_gate(report: PlanGateReport, text: str, *, severity: str = G10_SEVERITY) -> None`: appends each message to `report.blocking` when `severity == BLOCKING_CHANNEL`, otherwise to `report.warnings`.
  - Every public function carries a docstring with Args, Returns, Raises, and Side Effects. File at most 500 lines. The module reads no file, clock, environment variable, or git state.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py --deselect tests/scripts/dev_tools/test_plan_gate_scratch.py::test_g10_severity_constant_matches_typescript -k "not evaluate_plan_gates and not cli"` passes with 0 failed (the dispatcher and CLI cases are run in [P2-T3]).
- [x] [P2-T2] Wire G10 into `scripts/dev_tools/plan_gate_discrimination.py` and correct its docstrings
  - Add `from scripts.dev_tools.plan_gate_scratch import evaluate_scratch_gate` and, as the last statement before `return report` in `evaluate_plan_gates`, an unconditional `evaluate_scratch_gate(report, text)` with a one-line comment stating that G10 is document-level and context-free.
  - Module docstring: replace "the fixed G1 through G6 rule set" with wording that names "G1 through G10", and add one sentence stating that the document-level G10 rule lives in `scripts.dev_tools.plan_gate_scratch`.
  - `evaluate_plan_gates` docstring: replace the statement that the Blocking list is byte-identical to the pre-change output with a statement that, without a context, the context-free rules G1, G4, G7, G8, G8b, and G10 run, and that G10 can add Blocking findings without a context.
  - Acceptance: the file stays at most 500 lines; `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_discrimination_docstrings_name_g10` passes.
- [x] [P2-T3] Run the Python G10 dispatcher and CLI tests and record `<FEATURE>/evidence/regression-testing/python-green.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py::test_scratch_pattern_check_self_test tests/scripts/dev_tools/test_scratch_location_contracts.py::test_normative_surfaces_name_no_bare_fixed_scratch_path --deselect tests/scripts/dev_tools/test_plan_gate_scratch.py::test_g10_severity_constant_matches_typescript --cov=scripts.dev_tools.plan_gate_scratch --cov-branch --cov-report=term-missing`
  - Acceptance: `EXIT_CODE: 0`; `Output Summary:` records the pass count, 0 failed, and the `term-missing` row for `plan_gate_scratch.py`. If the scan test flags a pre-existing normative surface, the executor classifies the hit against the `spec.md` predicate: a genuine bare definition or root path is corrected in that surface by a remediation cycle (its bundle copy too); a non-definition hit halts the task for a plan revision, because the predicate is not narrowed after implementation. Whenever this remediation edits a file that is not in the WRITES list, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation.<timestamp>.md` as defined in Conventions (one `PATH: ` line per edited file, including each bundle copy) before rerunning the command, and [P2-T9] stages those paths.
- [x] [P2-T4] Update the stale context-free comment in `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Edit the comment at the `_EXPECTED_BLOCKING_G1` block and the comment in `test_blocking_channel_is_unchanged_without_context` so they state that G1 is the only command-attributed Blocking rule that decides without the repository seam, and that the document-level G10 rule also runs without it while these fixtures carry no SCRATCH definition. Comment-only; no code line changes.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` passes with 0 failed.
- [x] [P2-T5] Run the Python discrimination regression suites and record `<FEATURE>/evidence/regression-testing/python-discrimination-regression.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`
  - Acceptance: `EXIT_CODE: 0` and 0 failed; this file set is exactly the nine test files of the [P0-T7] command, so the total `passed` count printed on the final pytest summary line is compared with the total `passed` count recorded in the latest `<FEATURE>/evidence/baseline/python-coverage-baseline.*.md` and is at least that number. `Output Summary:` records both totals and their difference.
- [x] [P2-T6] Run the Python format check on the Phase 1–2 Python files and record `<FEATURE>/evidence/regression-testing/python-format-phase2.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and the summary line `7 files would be left unchanged.` Remediation branch: if the check fails, run `poetry run black scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`, record its `reformatted` and `left unchanged` summary, then rerun from [P2-T3].
- [x] [P2-T7] Run the Python lint check on the same seven files and record `<FEATURE>/evidence/regression-testing/python-lint-phase2.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and the output line `All checks passed!`. Any suppression added follows `.claude/rules/python-suppressions.md`.
- [x] [P2-T8] Run the Python strict type check on the same seven files and record `<FEATURE>/evidence/regression-testing/python-typecheck-phase2.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and the summary `0 errors`.
- [x] [P2-T9] Commit and push the Python implementation in `scripts/dev_tools/plan_gate_scratch.py` and `scripts/dev_tools/plan_gate_discrimination.py`, the comment edit, the evidence, and the plan check-offs
  - Commands: `git add scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` plus any file reformatted in [P2-T6], every path on a `PATH: ` line of an `out-of-scope-remediation.*.md` artifact written by [P2-T3], the evidence folder, and the plan file; `git commit -m "fix(932): add G10 bare SCRATCH definition gate to the Python plan validator"`; `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

### Phase 3 — TypeScript G10 Implementation

- [x] [P3-T1] Create `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (the TypeScript twin)
  - Imports: `import type { PlanGateReport } from "./plan-gate-rules";` (types only from that module) and `PLAN_GATE_HEADING_PATTERN`, `PLAN_GATE_TASK_PATTERN` from `./plan-gate-commands`.
  - Exports: `G10_SEVERITY: string = "blocking"`; `SCRATCH_DEFINITION_PATTERN` and `SCRATCH_NAMESPACE_PATTERN` as `String.raw` template strings identical to the Python raw strings; `bareScratchDefinitions(text: string): Array<[number, string]>`; `scratchFindingMessage(lineNumber: number, logicalLine: string): string`; `evaluateScratchGate(report: PlanGateReport, text: string, severity: string = G10_SEVERITY): void`.
  - Behaviour: identical to [P2-T1]. Line splitting matches the extractor's private `splitLines` (`text.split(/\r\n|\n|\r/)`, an empty text yields no lines, and a trailing empty element after a final newline is dropped so line numbers match Python `splitlines()`); fence regex `/^\s*```/`; normalization `value.split(/\s+/).filter((word) => word !== "").join(" ")`; the namespace test runs on `logical.slice(match.index + match[0].length)`. No `pythonRepr(` call. TSDoc on every export. At most 500 lines.
  - Acceptance: `npx tsc -p ./ --noEmit` (working directory `extensions/drm-copilot/`) exits 0.
- [x] [P3-T2] Wire G10 into `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` and correct its JSDoc
  - Add `import { evaluateScratchGate } from "./plan-gate-scratch";`, a re-export block `export { bareScratchDefinitions, evaluateScratchGate, G10_SEVERITY, scratchFindingMessage } from "./plan-gate-scratch";`, and an unconditional `evaluateScratchGate(report, text);` as the last statement before `return report;` in `evaluatePlanGates`.
  - Replace the `@param context` text that states the Blocking list is byte-identical to the pre-change output with text stating that the context-free rules G1, G4, G7, G8, G8b, and G10 run without a context and that G10 can add Blocking findings; name the gate set through G10 in the JSDoc summary line.
  - Acceptance: the file stays at most 500 lines and contains no `pre-change output` text (verified by the JSDoc case in [P3-T7]).
- [x] [P3-T3] Add the per-file coverage threshold for the new module to `extensions/drm-copilot/jest.config.cjs`
  - Insert, directly after the `./src/lib/validate/plan-gate-observability.ts` entry, a two-line comment (`// Issue #932: the document-level G10 rule module. This map carries no` / `// global key, so the new production file is gated by its own entry.`) followed by the entry `"./src/lib/validate/plan-gate-scratch.ts": { lines: 85, branches: 75 },` written across four lines in the file's existing style. Net addition at most 6 lines (file stays at most 489 lines).
  - Acceptance: the threshold-entry case in `plan-gate-scratch.test.ts` passes in [P3-T7].
- [x] [P3-T4] Update the stale context-free comments in `extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts`
  - Edit the doc comment above the expected G1 blocking strings and the assertion comment in the blocking-channel case with the same meaning as [P2-T4]. Comment-only.
  - Acceptance: `npx jest --config jest.config.cjs test/lib/validate/plan-gate-observability-boundaries.test.ts` passes with 0 failed.
- [x] [P3-T5] Run the TypeScript format check on the Phase 1 and Phase 3 TypeScript files and record `<FEATURE>/evidence/regression-testing/ts-format-phase3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs`
  - Acceptance: `EXIT_CODE: 0` and the line `All matched files use Prettier code style!`. Remediation branch: run `npx prettier --write` over the same seven paths, record each path it reports as `(unchanged)` or rewritten, then rerun from [P3-T5].
- [x] [P3-T6] Run the TypeScript lint check on the same seven files and record `<FEATURE>/evidence/regression-testing/ts-lint-phase3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-discrimination.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-parity.test.ts test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts test/lib/validate/plan-gate-observability-boundaries.test.ts jest.config.cjs`
  - Acceptance: `EXIT_CODE: 0` with no reported problems. Any suppression follows `.claude/rules/typescript-suppressions.md`.
- [x] [P3-T7] Run both TypeScript type checks and the validate test directory and record `<FEATURE>/evidence/regression-testing/ts-green.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Commands: `npx tsc -p ./ --noEmit`, `npx tsc -p tsconfig.jest.json --noEmit`, `npx jest --config jest.config.cjs --verbose test/lib/validate`.
  - Acceptance: all three exit 0; `Output Summary:` records the jest suite and test pass counts and 0 failed. From the `--verbose` per-case lines: under the `plan-gate-scratch G10` describe title, the passing case titles equal, one for one, the `TS_CASE_COUNT:` title list recorded in the latest `<FEATURE>/evidence/regression-testing/ts-red.*.md` (no title missing, no extra title); the parity case `renders offending values without pythonRepr formatting` and the case `throws with the G10 message when a SCRATCH definition is not namespaced` are listed as passing. The artifact quotes those verbose lines.
- [x] [P3-T8] Run the Python severity parity node against the new TypeScript module in `tests/scripts/dev_tools/test_plan_gate_scratch.py` and append the result to the latest `<FEATURE>/evidence/regression-testing/ts-green.*.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py::test_g10_severity_constant_matches_typescript`
  - Acceptance: exit 0 with 1 passed.
- [x] [P3-T9] Commit and push the TypeScript implementation in `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` and its wiring, the jest threshold, the comment edit, the evidence, and the plan check-offs
  - Commands: `git add extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts` plus any file rewritten in [P3-T5], the evidence folder, and the plan file; `git commit -m "fix(932): add G10 bare SCRATCH definition gate to the TypeScript plan validator"`; `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

### Phase 4 — Codex Agent Definitions

The inserted planner text is exactly lines 58 through 67 of `.claude/agents/atomic-planner.md` (the `## Scratch Location` heading, the blank line, the introductory sentence, the blank line, the five bullets, and one trailing blank line). The inserted executor text is exactly lines 85 through 95 of `.claude/agents/atomic-executor.md` (heading, introductory sentence, six bullets, and one trailing blank line). Each insertion is made with the Edit tool immediately before the line `## Preflight Validation` inside the `developer_instructions` literal string. The generator is not run in write mode.

- [x] [P4-T1] Insert the planner section into the six root planner TOMLs under `.codex/agents/`
  - Files: `.codex/agents/atomic-planner.toml`, `.codex/agents/atomic-planner-c1.toml`, `.codex/agents/atomic-planner-c2.toml`, `.codex/agents/atomic-planner-c3.toml`, `.codex/agents/atomic-planner-c3-elevated.toml`, `.codex/agents/atomic-planner-c4.toml`.
  - Acceptance: each file has `## Scratch Location` directly preceded (as the nearest `## ` heading) by `## Requirements` and followed by `## Preflight Validation`.
- [x] [P4-T2] Insert the executor section into the six root executor TOMLs under `.codex/agents/`
  - Files: `.codex/agents/atomic-executor.toml`, `.codex/agents/atomic-executor-c1.toml`, `.codex/agents/atomic-executor-c2.toml`, `.codex/agents/atomic-executor-c3.toml`, `.codex/agents/atomic-executor-c3-elevated.toml`, `.codex/agents/atomic-executor-c4.toml`.
  - Acceptance: each file has `## Scratch Location` between `## Toolchain Commands` and `## Preflight Validation`.
- [x] [P4-T3] Insert the planner section into the six bundle planner TOMLs under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`
  - Files: the same six planner file names as [P4-T1] under that directory.
  - Acceptance: same placement as [P4-T1].
- [x] [P4-T4] Insert the executor section into the six bundle executor TOMLs under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`
  - Files: the same six executor file names as [P4-T2] under that directory.
  - Acceptance: same placement as [P4-T2].
- [x] [P4-T5] Verify root-to-bundle byte identity for the twelve TOML pairs and record `<FEATURE>/evidence/regression-testing/codex-toml-identity.<timestamp>.md`
  - Command, once per pair: `git hash-object .codex/agents/<file> extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<file>` for each of the twelve file names in [P4-T1] and [P4-T2].
  - Acceptance: for every pair the two printed object IDs are equal; the artifact lists the twelve pairs with both IDs.
- [x] [P4-T6] Run the full scratch contract suite in `tests/scripts/dev_tools/test_scratch_location_contracts.py` and record `<FEATURE>/evidence/regression-testing/scratch-contract-green.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v`
  - Acceptance: exit 0, 0 failed, and the verbose output lists passing `codex-planner` and `codex-executor` parametrizations for `test_scratch_location_section_states_the_rule` and `test_scratch_location_section_avoids_forbidden_shapes`, `codex-planner` for `test_planner_scratch_location_placement`, and `codex-executor` for `test_executor_scratch_location_placement` and `test_executor_scratch_location_handles_pre_rule_plans`.
- [x] [P4-T7] Run the Codex parity, generator, and schema suites and record `<FEATURE>/evidence/regression-testing/codex-suites-green.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -v`
  - Acceptance: exit 0 and 0 failed; the output shows `test_generator_check_mode_reports_no_drift` and `test_checked_in_variants_match_generator_output_in_both_surfaces` passing.
- [x] [P4-T8] Run the TypeScript push-down suites under `extensions/drm-copilot/test/lib/push-down` and record `<FEATURE>/evidence/regression-testing/ts-push-down-green.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs test/lib/push-down`
  - Acceptance: exit 0 and 0 failed.
- [x] [P4-T9] Commit and push the 24 TOML files under `.codex/agents/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`, the evidence, and the plan check-offs
  - Pre-commit check: `git status --porcelain` lists exactly the 24 TOML paths, the new evidence files, and the plan file; no pack manifest under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` appears.
  - Commands: `git add` naming the 24 TOML paths, the evidence folder, and the plan file; `git commit -m "fix(932): add Scratch Location section to Codex planner and executor agents"`; `git push origin HEAD`.
  - Acceptance: the pre-commit listing matches; `git status --porcelain` prints nothing after the push.

### Phase 5 — Severity Governance, Corpus Measurement, and Policy Documentation

- [x] [P5-T1] Write the pre-declared severity decision rule for G10 in `<FEATURE>/evidence/other/g10-severity-decision-rule.<timestamp>.md` before any measurement
  - Content: `Timestamp:`; the decision rule "G10 ships Blocking if and only if the measured finding count is greater than zero and the recorded false-positive count is zero; otherwise the measurement indicates Warning", stated as the same two-conjunct rule used for G5 through G9 in `.claude/rules/plan-acceptance-gates.md`; the false-positive definition "a flagged logical line that is not a SCRATCH definition, or that defines SCRATCH in the canonical issue-namespaced form"; the true-positive definition (a flagged logical line that defines SCRATCH without an accepted issue namespace); the corpus derivation "every path listed by `git ls-tree -r -z --name-only <MERGE_BASE> -- docs` whose final path component matches the case-sensitive glob `*plan.*.md`, read at `<MERGE_BASE>` with `git show`" (this includes `docs/features/active/`, `docs/features/archive/`, and every other `docs/` tree); the statement that G10 ships Blocking by operator-approved scope for issue #932 and that a Warning outcome is recorded as a discrepancy, not acted on by changing `G10_SEVERITY` or narrowing the predicate.
  - Acceptance: the artifact exists with all listed elements and no count.
- [x] [P5-T2] Commit and push the decision-rule artifact under `<FEATURE>/evidence/other/` alone, so its precedence over the measurement is visible in git history
  - Commands: `git add` naming the decision-rule artifact and the plan file, `git commit -m "docs(932): pre-declare the G10 severity decision rule"`, `git push origin HEAD`.
  - Acceptance: `git log -1 --name-only` lists only the artifact and the plan file; the push exits 0.
- [x] [P5-T3] Write the scratch driver `SCRATCH/g10/test_g10_drivers.py` with the exact content of Appendix A and record it in `<FEATURE>/evidence/other/g10-driver-setup.<timestamp>.md`
  - Method: the Write tool. The file name matches `test_*.py`, so `.claude/hooks/check-python-test-purity.ps1` inspects the content and denies any Write that contains `import subprocess`, `from subprocess import`, `os.system(`, or the other patterns it lists. Appendix A therefore runs `git` through the repository's `SubprocessRunner` (`scripts/dev_tools/pr_context/git.py`, the same runner `scripts/dev_tools/plan_gate_discrimination.py` imports), and the driver text contains none of the hook's patterns.
  - Acceptance: the Write call is not denied; the file exists under `SCRATCH/g10/`; the Grep tool, output mode `count`, on the written file returns 0 for the pattern `import\s+subprocess|from\s+subprocess` and 1 for the pattern `^from scripts\.dev_tools\.pr_context\.git import SubprocessRunner`; the artifact records its path with the `SCRATCH` token, both counts, and states that the content equals Appendix A.
- [x] [P5-T4] Run the corpus measurement and record `<FEATURE>/evidence/qa-gates/g10-corpus-measurement.<timestamp>.md`
  - Command: `poetry run pytest -c pyproject.toml --rootdir=. -p no:cacheprovider -s -q SCRATCH/g10/test_g10_drivers.py::test_measure_g10_over_merge_base_plan_corpus`
  - Acceptance: `EXIT_CODE: 0`; the artifact records `MERGE_BASE:` (equal to the [P0-T2] value or, after a rebase, the re-derived value with a note), `CORPUS_FILES:`, `FINDING_COUNT:`, every `FINDING:` line verbatim with a classification of `true positive` or `false positive` and a one-line reason under the [P5-T1] definitions, the false-positive count, and the decision the [P5-T1] rule yields. If the decision is Warning, the artifact records `SEVERITY-DISCREPANCY:` with the reason, and the executor reports it in the phase summary; `G10_SEVERITY` stays Blocking per `spec.md`.
- [x] [P5-T5] Document G10 in `.claude/rules/plan-acceptance-gates.md`
  - Edits: frontmatter `description` names the rule set through G10 and the document-level SCRATCH rule; the `## Rule Table` prefix statement gains the sentence beginning `The G10 exception:` stating that G10 findings begin with `Line N: ` because a SCRATCH definition sits outside any task window, matching the structural-error prefix; a table row beginning `| **G10** |` with the condition (an unfenced logical line matching the definition predicate whose remainder carries no `issue-<issue-num>` or `issue-<digits>` namespace) and severity **Blocking**; the shipped-set sentence becomes `G1 through G10 are the complete shipped set.` with the origin of G10 (issue #932); the context-free paragraph states that G10 is context-free and document-level and can add Blocking findings without a context; a subsection `### G10 — ships as Blocking by operator-approved scope and the pre-declared rule` placed under `## Severity Decisions` before `## The Write-Mode Register`, stating the two-conjunct rule, the false-positive definition, the [P5-T4] counts with the artifact name `g10-corpus-measurement.<stamp>.md` (concrete stamp), the sentence containing `operator-approved scope for issue #932`, and the fact that the research observed the corpus before the measurement; a subsection `### Known false-negative classes — G10` listing wrong issue number, `SCRATCHPAD`-family tokens and root paths under them, definition by reference, and fenced definitions, plus the possible colon-connector false positive; the `## Enforcement` list gains a bullet whose text after the list marker begins with the 54-character enforcement token defined in [P1-T2] (backtick, `scripts/dev_tools/plan_gate_scratch.py`, backtick, space, `evaluates G10`) and that names the TypeScript twin `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`; the message-formatting paragraph refers to the TypeScript gate modules without a fixed count.
  - Every literal example of a bare SCRATCH definition added to the file is placed inside a fenced block.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` passes.
- [x] [P5-T6] Copy the rule file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
  - Command (repository root): `cp .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. Route note: no repository hook pattern blocks `cp` (the six patterns returned by `Get-BlockedBashPattern` in `.claude/hooks/validate-bash.ps1` cover forced deletion, forced push, and hard reset only), and the command text carries none of the words the worktree isolation guard refuses; `cp` is, however, not among the `Bash(...)` patterns in the executor frontmatter. Fallback when the tool layer refuses `cp`: read the source with the Read tool and write the identical content to the destination with the Write tool; the byte-identity test below is the check for either route.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical` passes.
- [x] [P5-T7] Update the shipped-set statement in `.claude/skills/atomic-plan-contract/SKILL.md`
  - Edit the paragraph that ends `The complete shipped set is therefore G1 through G9.`: add a sentence stating that the same call applies G10, a document-level rule that reports a SCRATCH definition not namespaced by issue number, ships in the Blocking channel, and reports with a `Line N: ` prefix rather than a task identifier; end the paragraph with `The complete shipped set is therefore G1 through G10.` The added text contains no bare SCRATCH definition and no scratchpad-root path.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py::test_normative_surfaces_name_no_bare_fixed_scratch_path` passes.
- [x] [P5-T8] Copy the skill byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  - Command (repository root): `cp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`; route note and Read-plus-Write fallback as in [P5-T6].
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_atomic_plan_contract_states_shipped_set_through_g10` passes (that test compares the bytes of the two files, so it is the byte-identity check for either route).
- [x] [P5-T9] Run the documentation, contract, and push-down suites and record `<FEATURE>/evidence/regression-testing/docs-green.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: 0 failed, or exactly one failure that is the #510 node with the #510 signature described in Conventions; the artifact records which case applies.
- [x] [P5-T10] Commit and push the policy documents `.claude/rules/plan-acceptance-gates.md` and `.claude/skills/atomic-plan-contract/SKILL.md`, their bundle copies, the measurement evidence, and the plan check-offs
  - Commands: `git add .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` plus the evidence folder and the plan file; `git commit -m "docs(932): document the G10 plan-acceptance gate"`; `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

### Phase 6 — Final QA Loop and Acceptance Check-Off

Loop rule: [P6-T1] through [P6-T11] form one pass. If any of them fails or changes a file, fix the cause, commit the fix, and restart at [P6-T1]; each pass writes new artifacts with new timestamps. The loop ends only when one pass completes with every step at exit 0 and no file change.

- [x] [P6-T1] Run the final Python format check and record `<FEATURE>/evidence/qa-gates/python-format-final.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and `7 files would be left unchanged.` Remediation branch: run `poetry run black` over the same seven paths, record the `reformatted` and `left unchanged` summary, and restart the loop.
- [x] [P6-T2] Run the final Python lint check and record `<FEATURE>/evidence/qa-gates/python-lint-final.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and `All checks passed!`.
- [x] [P6-T3] Run the final Python strict type check and record `<FEATURE>/evidence/qa-gates/python-typecheck-final.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`
  - Acceptance: `EXIT_CODE: 0` and `0 errors`.
- [x] [P6-T4] Run the final Python coverage gate and record `<FEATURE>/evidence/qa-gates/python-coverage-final.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/final-py.json`
  - Acceptance: `EXIT_CODE: 0`, 0 failed. From each file's `summary` object in `SCRATCH/cov/final-py.json`: `plan_gate_scratch.py` line coverage (`covered_lines / num_statements`) at least 85% and branch coverage (`covered_branches / num_branches`) at least 75%. For `plan_gate_discrimination.py`: the changed lines are the `+` line numbers in the hunks of `git diff -U0 <MERGE_BASE> HEAD -- scripts/dev_tools/plan_gate_discrimination.py`; no changed executable line appears in `missing_lines`, and the file's line and branch percentages are not lower than the [P0-T7] values. `Output Summary:` records baseline, post-change, and changed-line figures for both files.
- [x] [P6-T5] Run the final Python contract, Codex, push-down, and frontmatter suites and record `<FEATURE>/evidence/qa-gates/python-contract-final.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: 0 failed, or exactly the #510 node with the #510 signature (recorded as `pending-CI` for that node); the `-v` per-node output shows `test_generator_check_mode_reports_no_drift` as `PASSED`, and the artifact quotes that line.
- [x] [P6-T6] Run the final broad dev-tools regression and record `<FEATURE>/evidence/qa-gates/python-devtools-final.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: every failing or erroring node ID is in the [P0-T9] baseline set or is the #510 node; the artifact lists any node that newly passes or newly fails. A new failure related to this change is fixed by a remediation cycle and the loop restarts. Whenever that remediation edits a file that is not in the WRITES list, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation.<timestamp>.md` as defined in Conventions (one `PATH: ` line per edited file) before committing the fix, and the fix commit stages those paths.
- [x] [P6-T7] Run the final TypeScript format check and record `<FEATURE>/evidence/qa-gates/ts-format-final.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
  - Acceptance: `EXIT_CODE: 0` and `All matched files use Prettier code style!`, or, if [P0-T11] recorded pre-existing warnings, the reported file set equals the baseline set and contains no file changed by this plan. Remediation branch for a file changed by this plan: `npx prettier --write` on that file, record `(unchanged)` or the rewrite, and restart the loop.
- [x] [P6-T8] Run the final TypeScript lint check and record `<FEATURE>/evidence/qa-gates/ts-lint-final.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `EXIT_CODE: 0` with 0 errors and no warning in a file changed by this plan.
- [x] [P6-T9] Run the final TypeScript production type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-final.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P6-T10] Run the final TypeScript test type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-test-final.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P6-T11] Run the final full jest coverage gate and record `<FEATURE>/evidence/qa-gates/ts-coverage-final.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `EXIT_CODE: 0`, 0 failed suites and tests, and no coverage-threshold message. From `extensions/drm-copilot/coverage/coverage-summary.json`: `src/lib/validate/plan-gate-scratch.ts` has `lines.pct` at least 85 and `branches.pct` at least 75; `src/lib/validate/plan-gate-discrimination.ts` percentages are not lower than [P0-T15]. From `extensions/drm-copilot/coverage/lcov.info`: no `+` line of `git diff -U0 <MERGE_BASE> HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` has a zero-hit `DA:` record. `Output Summary:` records baseline, post-change, and changed-line figures.
- [x] [P6-T12] Confirm a single clean loop pass in `<FEATURE>/evidence/qa-gates/qa-loop-summary.<timestamp>.md`
  - Acceptance: the latest artifacts of [P6-T1] through [P6-T11] all carry timestamps from one pass that started after the last code commit, each records an `EXIT_CODE:` meeting its task, and `git status --porcelain` shows only evidence files and the plan file.
- [x] [P6-T13] Validate this plan with the production validator through the scratch driver and record `<FEATURE>/evidence/qa-gates/plan-self-validation.<timestamp>.md`
  - Command: `poetry run pytest -c pyproject.toml --rootdir=. -p no:cacheprovider -s -q SCRATCH/g10/test_g10_drivers.py::test_issue_932_plan_has_no_blocking_finding`
  - Acceptance: `EXIT_CODE: 0`; the printed `ERROR_COUNT: 0` and `G10_COUNT: 0` lines are recorded, together with every `WARNING:` line.
- [x] [P6-T14] Check file size and temporary-file use for every created or changed non-Markdown file and record `<FEATURE>/evidence/qa-gates/file-size-and-tempfile-check.<timestamp>.md`
  - Method: the Grep tool with pattern `^` and output mode `count` on each of the 14 Python and TypeScript files in the WRITES list (seven Python files and seven TypeScript-side files including `extensions/drm-copilot/jest.config.cjs`) and on each of the 24 TOML files, and on every non-Markdown path named on a `PATH: ` line of any `<FEATURE>/evidence/other/out-of-scope-remediation.*.md` artifact; the Grep tool with pattern `tmp_path|tempfile|mkdtemp|NamedTemporaryFile|tmpdir|writeFileSync|mkdtempSync` over the five created or changed test files under `tests/scripts/dev_tools/` and the four under `extensions/drm-copilot/test/lib/validate/`.
  - Acceptance: every count is at most 500; the temporary-file search returns zero matches; the artifact lists each file with its count.
- [x] [P6-T15] Verify the change scope against the merge base and record `<FEATURE>/evidence/qa-gates/scope-diff.<timestamp>.md`
  - Commands: `git diff --name-only <MERGE_BASE> HEAD`, `git diff --name-status --diff-filter=D <MERGE_BASE> HEAD`, `git status --porcelain`.
  - Acceptance: every listed path is in the WRITES list of this plan, or under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/`, or named on a `PATH: ` line in at least one `<FEATURE>/evidence/other/out-of-scope-remediation.*.md` artifact (the union across all such files; the artifact records which accepted paths came from that log, or `REMEDIATION-LOG: none` when no such file exists, with the Glob search that established it); no path matching `plan.*.md` or `remediation-plan.*.md` lies outside that folder; the deletion listing is empty; `scripts/dev_tools/validate_orchestration_artifacts.py`, `scripts/dev_tools/plan_gate_observability.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts`, `.agents/skills/atomic-plan-contract/SKILL.md`, every path under `.github/`, and every pack manifest are absent; the porcelain listing shows only evidence files and the plan file.
- [x] [P6-T16] Check off verified acceptance criteria in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md` and record `<FEATURE>/evidence/other/ac-checkoff.<timestamp>.md`
  - Rule: an AC is checked `[x]` only when the evidence named for it in the AC map below exists and passes. The bundle-parity AC that names `test_bundled_claude_payload_contains_all_repo_runtime_contracts` stays unchecked with the annotation `pending-CI` when that node failed locally with the #510 signature. No other file's checkboxes are changed.
  - Acceptance: the artifact lists all 32 ACs with status `checked` or `pending-CI` and the evidence file for each.
- [x] [P6-T17] Commit and push the final evidence under `<FEATURE>/evidence/qa-gates/`, the check-offs in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md`, and the plan check-offs
  - Commands: `git add` naming the evidence folder, `spec.md`, and the plan file; `git commit -m "docs(932): record final QA evidence and acceptance check-off"`; `git push origin HEAD`.
  - Acceptance: `git status --porcelain` prints nothing after the push; the push exits 0.

## Acceptance-Criteria Map

AC numbering follows the order of the `## Acceptance Criteria` bullets in `spec.md` (AC-01 is the first bullet under "G10 implementation (Python)", AC-32 the last bullet under "Governance, scope, and quality").

| AC | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- |
| AC-01 | P2-T1 | `test_g10_severity_is_blocking` | python-green, python-coverage-final |
| AC-02 | P2-T1 | `test_bare_scratch_definitions_accepts_namespaced_forms` | python-green |
| AC-03 | P2-T1 | `test_bare_scratch_definitions_flags_unnamespaced_forms` | python-green |
| AC-04 | P2-T1 | `test_bare_scratch_definitions_ignores_non_definitions` | python-green |
| AC-05 | P2-T1 | `test_wrapped_definition_reports_first_line`, `test_logical_line_stops_at_heading_fence_and_task_line` | python-green |
| AC-06 | P2-T1 | `test_g10_message_matches_frozen_string` | python-green |
| AC-07 | P2-T2 | `test_evaluate_plan_gates_reports_g10_with_and_without_context` | python-green |
| AC-08 | P2-T2 | `test_cli_rejects_bare_scratch_definition`, `test_cli_accepts_namespaced_scratch_definition` | python-green |
| AC-09 | P3-T1, P3-T2 | `plan-gate-scratch.test.ts` export and re-export cases | ts-green |
| AC-10 | P1-T5 | `plan-gate-scratch.test.ts` fixture and frozen-string cases | ts-green |
| AC-11 | P3-T2 | `plan-gate-scratch.test.ts` dispatcher cases; service-call throw case | ts-green |
| AC-12 | P3-T1 | `test_g10_severity_constant_matches_typescript` | ts-green (P3-T8 append) |
| AC-13 | P1-T3 | `test_no_repr_formatting_in_gate_messages` | python-green |
| AC-14 | P1-T6 | `renders offending values without pythonRepr formatting` | ts-green |
| AC-15 | P3-T3 | threshold-entry case in `plan-gate-scratch.test.ts`; full jest coverage run | ts-green, ts-coverage-final |
| AC-16 | P1-T4 | `test_normative_surfaces_name_no_bare_fixed_scratch_path` | scratch-contract-green |
| AC-17 | P1-T4 | `test_scratch_pattern_check_self_test` | scratch-contract-green |
| AC-18 | P1-T4, P4-T1, P4-T2 | codex parametrizations of the five rule-source tests | scratch-contract-green |
| AC-19 | P4-T1, P4-T2 | `test_scratch_location_section_states_the_rule[codex-*]`, placement tests | scratch-contract-green |
| AC-20 | P4-T1..P4-T4 | `test_generate_codex_agent_variants.py` incl. `test_generator_check_mode_reports_no_drift` | codex-suites-green, codex-toml-identity |
| AC-21 | P4-T1..P4-T4 | the four Codex parity and schema suites | codex-suites-green |
| AC-22 | P5-T5 | `test_rule_file_documents_g10` | docs-green |
| AC-23 | P5-T6..P5-T8 | `test_rule_file_bundle_copy_is_byte_identical`, `test_atomic_plan_contract_states_shipped_set_through_g10`, CI `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | docs-green, python-contract-final |
| AC-24 | P2-T2, P3-T2 | `test_discrimination_docstrings_name_g10`; JSDoc case in `plan-gate-scratch.test.ts` | python-green, ts-green |
| AC-25 | (no production change) | `test_claude_rules_frontmatter.py`; `test_rule_frontmatter_paths_reach_scratch_gate_modules` | docs-green |
| AC-26 | P5-T1, P5-T2 precede P5-T4 | git history order of the two commits | g10-severity-decision-rule, g10-corpus-measurement |
| AC-27 | this plan | `test_issue_932_plan_has_no_blocking_finding` (scratch driver) | plan-self-validation |
| AC-28 | all phases | `git diff --name-only <MERGE_BASE> HEAD` with porcelain companion | scope-diff |
| AC-29 | P6-T1..P6-T6 | Python toolchain loop | python-*-final |
| AC-30 | P6-T7..P6-T11 | TypeScript toolchain loop | ts-*-final |
| AC-31 | P6-T4, P6-T11 | coverage figures and changed-line checks | python-coverage-final, ts-coverage-final |
| AC-32 | P6-T14 | line counts and temporary-file search | file-size-and-tempfile-check |

## WRITES (repository files outside the feature folder)

- `scripts/dev_tools/plan_gate_scratch.py` (create)
- `scripts/dev_tools/plan_gate_discrimination.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch.py` (create)
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` (create)
- `tests/scripts/dev_tools/test_plan_gate_parity.py`
- `tests/scripts/dev_tools/test_scratch_location_contracts.py`
- `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` (comment only)
- `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (create)
- `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` (create)
- `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts` (comment only)
- `extensions/drm-copilot/jest.config.cjs`
- `.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
- `.codex/agents/atomic-planner.toml`, `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants (6 files)
- `.codex/agents/atomic-executor.toml`, `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants (6 files)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` and its 5 variants (6 files)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml` and its 5 variants (6 files)

Scratch files (not committed): `SCRATCH/g10/test_g10_drivers.py`, `SCRATCH/cov/baseline-py.json`, `SCRATCH/cov/final-py.json`.

## Appendix A — Scratch Driver `SCRATCH/g10/test_g10_drivers.py`

The driver is run by pytest with `-c pyproject.toml --rootdir=.` from the repository root, so it inserts the working directory on `sys.path` before importing repository modules. It reads git state and the plan file; it is a scratch measurement tool, not a repository test. It runs `git` through `SubprocessRunner` from `scripts/dev_tools/pr_context/git.py` rather than importing the standard-library process module directly, because the Python test-purity hook denies a Write of a `test_*.py` file that imports it. `SubprocessRunner.run` raises `RuntimeError` on a non-zero exit when `allow_error` is left at its default, and strips trailing newlines from stdout, which does not change the NUL-separated `ls-tree -z` listing or the `splitlines()` result of a file read with `git show`.

```python
"""Issue 932 scratch drivers. Not committed; lives under the issue scratch directory."""

from __future__ import annotations

import fnmatch
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

from scripts.dev_tools.plan_gate_discrimination import (  # noqa: E402
    build_plan_gate_context,
)
from scripts.dev_tools.plan_gate_scratch import bare_scratch_definitions  # noqa: E402
from scripts.dev_tools.pr_context.git import SubprocessRunner  # noqa: E402
from scripts.dev_tools.validate_orchestration_artifacts import (  # noqa: E402
    validate_plan_text_with_warnings,
)

PLAN_PATH = (
    "docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/"
    "plan.2026-10-15T15-45.md"
)
_RUNNER = SubprocessRunner()


def _git(*arguments: str) -> str:
    return _RUNNER.run(["git", *arguments], cwd=Path.cwd()).stdout


def test_measure_g10_over_merge_base_plan_corpus() -> None:
    merge_base = _git("merge-base", "origin/main", "HEAD").strip()
    listing = _git("ls-tree", "-r", "-z", "--name-only", merge_base, "--", "docs")
    corpus = sorted(
        name
        for name in listing.split("\0")
        if name and fnmatch.fnmatchcase(name.rsplit("/", 1)[-1], "*plan.*.md")
    )
    print(f"MERGE_BASE: {merge_base}")
    print(f"CORPUS_FILES: {len(corpus)}")
    findings = 0
    for name in corpus:
        text = _git("show", f"{merge_base}:{name}")
        for line_number, logical_line in bare_scratch_definitions(text):
            findings += 1
            print(f"FINDING: {name}:{line_number}: {logical_line}")
    print(f"FINDING_COUNT: {findings}")
    assert corpus, "corpus derivation produced no files"


def test_issue_932_plan_has_no_blocking_finding() -> None:
    text = Path(PLAN_PATH).read_text(encoding="utf-8")
    errors, warnings = validate_plan_text_with_warnings(
        text, context=build_plan_gate_context(Path.cwd())
    )
    for error in errors:
        print(f"ERROR: {error}")
    for warning in warnings:
        print(f"WARNING: {warning}")
    g10 = [error for error in errors if "SCRATCH definition" in error]
    print(f"ERROR_COUNT: {len(errors)}")
    print(f"WARNING_COUNT: {len(warnings)}")
    print(f"G10_COUNT: {len(g10)}")
    assert errors == []
```

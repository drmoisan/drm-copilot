# plan-validator-accepts-bare-scratch-paths (Remediation Plan, Cycle 3)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T05-36 (remediation cycle 3; preflight round 1 revision: [P2-T7] deselects the Phase 4 docs node and expects exit 0)
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug. `spec.md` remains the acceptance-criteria source for the item; this cycle's requirements come only from `remediation-inputs.2026-10-16T05-36.md` and the three cycle-2 re-audit artifacts it cites.
- **Branch:** `bug/plan-validator-accepts-bare-scratch-paths-932` (HEAD `ba7c44a15` at authoring time). Base: `main`.
- **Inputs:** `remediation-inputs.2026-10-16T05-36.md`, `policy-audit.2026-10-16T05-25.md`, `code-review.2026-10-16T05-25.md`, `feature-audit.2026-10-16T05-25.md`; prior cycle plan `remediation-plan.2026-10-16T03-19.md`; `spec.md`.
- **Attempt budget:** this is the third and last remediation attempt the loop guard allows for this item.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above applies to preflight rounds only. After preflight returns `PREFLIGHT: ALL CLEAR`, the orchestrator delegates execution separately.

**Fail-closed evidence rule:** Python and TypeScript each have explicit remediation-baseline tasks, final-QA tasks, and coverage-comparison tasks. If any required baseline, QA, or coverage artifact is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with every required field.

## Cycle Scope

In scope: **N-3 (Low, related).** G6 whitespace normalization uses each runtime's native whitespace class. Re-derivation against the current tree:

- Python `scripts/dev_tools/plan_gate_discrimination.py`: `_window_join` filters with `line.strip()` and normalizes with `str.split` (line 258); `_has_cross_line_presence` splits the search literal with `str.split` (line 271) and normalizes each tracked line with `str.split` (line 280).
- TypeScript `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`: `normalizeWhitespace` splits on the JavaScript whitespace class (lines 345-350); `windowJoin` filters with `trim()` (line 394) and maps through `normalizeWhitespace` (line 395); `hasCrossLinePresence` splits the literal on the JavaScript whitespace class (line 419) and normalizes each tracked line with `normalizeWhitespace` (line 429).
- The literal split is included with the two named normalizers because the needle and the tracked text must be normalized with one class; a needle split on a different class than the haystack keeps the divergence.

Decisions:

1. **Location of the shared class.** Direct reuse from the G10 modules is unsuitable in TypeScript: `plan-gate-scratch.ts` imports `PlanGateReport` from `plan-gate-rules.ts` (line 32), so `plan-gate-rules.ts` importing `PLAN_WHITESPACE_CLASS` back from `plan-gate-scratch.ts` would form an import cycle, which both module headers say is avoided. The class therefore moves, once per runtime, to the lower-level command extractor module that every consumer already imports: `scripts/dev_tools/plan_gate_commands.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`. The same module holds the shared normalizer (`normalize_plan_whitespace` / `normalizePlanWhitespace`). The G10 modules import both and keep no second declaration. `PLAN_WHITESPACE_CLASS` was introduced on this unmerged branch in cycle 2 and has no other in-repo consumer, so the move breaks no published API.
2. **Parity test.** `test_whitespace_class_matches_typescript` stays and is pointed at the new location in both runtimes. A new test, `test_whitespace_class_declared_once_per_runtime`, asserts exactly one declaration per runtime, in the extractor module, and none in the G10 or G5/G6 modules.
3. **Moving the escape-bearing lines.** The declaration lines carry six-character `u`-form escapes. Retyping them through the Write or Edit tool decodes them to raw characters (see Conventions). A scratch helper (Appendix C) therefore moves the existing declaration lines verbatim; all other edits use the Edit tool and contain no such escape.
4. **Frozen fixtures.** Four tracked-text cases (Appendix A), added to both literal suites: a NEL-only line and a byte-order-mark-only line (window-join filter), and a NEL inside a line and a byte-order mark inside a line (single-line test). The NEL cases fail in Python before the change and the byte-order-mark cases fail in TypeScript before the change, which covers both directions of the divergence.
5. **Corpus A/B.** The Appendix D helper evaluates the `docs/` plan corpus with the production normalizer, with the pre-change Python normalization, and with an emulation of the pre-change TypeScript normalization, and reports differences in G1-G9 results. Built-in probes for each runtime must differ, which shows that each substitution took effect.

Out of scope (inputs file decisions): the fence-pattern residual (unchanged; its rule-file statement is kept), U-2, U-3, CR-6, CR-7. `extensions/drm-copilot/jest.config.cjs` is not edited.

Planner observation outside this cycle's stated scope (recorded for an orchestrator decision; not implemented by this plan): the plan-quotation exoneration (`_plan_quotes_literal`, `scripts/dev_tools/plan_gate_discrimination.py` lines 248-252; `planQuotesLiteral` through `normalizeWhitespace`, `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` lines 372 and 376) still normalizes plan text with each runtime's native class. It reads the plan document, not a tracked file, and the inputs name only the G6 normalizers. The rule-file and `spec.md` text written in Phase 4 states it as a remaining difference instead of claiming full G5 alignment.

## Conventions

- `<FEATURE>` abbreviates `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932`. Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` (kinds used: `remediation-baseline`, `regression-testing`, `qa-gates`, `other`). Every evidence name written in this cycle carries the suffix `-rc3`.
- Evidence artifacts are named `<name>.<timestamp>.md`. The `<timestamp>` is the UTC write time read from the host clock immediately before the write (for example `date -u +%Y-%m-%dT%H-%M`), in the shape `yyyy-MM-ddTHH-mm`. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage-bearing artifacts carry numeric line and branch percentages in `Output Summary:`.
- Scratch location (issue #900 rule):
  - `SCRATCH` resolves to `<session scratchpad>/issue-932/`.
  - Every scratch file this plan names lives under `SCRATCH`, in the subdirectories `SCRATCH/cov/`, `SCRATCH/corpus/`, and `SCRATCH/stage/`. Nothing is written to the scratchpad root.
  - Evidence and this plan record the literal token `SCRATCH`, never a host path. When pytest, jest, or helper output contains a host path, the executor replaces the scratch prefix with `SCRATCH` and the repository prefix with a repository-relative path before recording it.
  - The untracked `SCRATCH/` directory at the worktree root is orchestrator session state. It is unrelated to the `SCRATCH` token above. It is never staged and never deleted by this plan.
- `<MERGE_BASE>` is the merge-base SHA and `<RC3_BASE>` is the HEAD SHA. [P0-T3] records both in the latest `<FEATURE>/evidence/remediation-baseline/git-baseline-rc3.*.md`. If the branch is rebased later, the executor re-derives `<MERGE_BASE>` with `git merge-base origin/main HEAD` and records the new value in the consuming artifact.
- TypeScript and jest commands run with `extensions/drm-copilot/` as the working directory, so the per-file coverage-threshold keys in `jest.config.cjs` resolve. Python, git, and helper commands run at the repository root.
- Jest per-case output: Jest 30 prints only totals when the `CLAUDECODE` environment variable is set. Every jest command in this plan therefore passes `--reporters=default` after the test paths, which restores the per-case lines.
- Python check-mode commands only: `black --check` and `ruff check --no-fix`. Write-mode formatting is permitted only inside the remediation branch of a check task and is followed by a loop restart.
- Commits: `git add` names each file or evidence folder explicitly. Commit and push at every phase boundary. No force push. No file is deleted. No issue is created. No pull request is opened and nothing is merged. A related finding discovered during execution is fixed inside this item; a completely unrelated finding is recorded in `<FEATURE>/evidence/other/unrelated-findings-rc3.<timestamp>.md`.
- Known local failure (#510): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally because of gitignored state. Locally, only that node is accepted as a failure, and only when its failure message names a gitignored path that is absent from the bundle. Any other failure in that file is a real failure. CI is the authority for that node (AC-23 stays unchecked until CI runs it).
- PowerShell and bats are not in scope. Pester is not run by this plan.
- Agent-worktree command routes: the worktree isolation guard refuses command text containing three shell-host words (the POSIX shell name, the PowerShell 7 executable name, and the Linux-subsystem launcher name), so no task in this plan names them. File copying uses `cp` or the Read-plus-Write fallback; timestamps use `date -u`.
- npm dependencies: if the Glob tool finds no `extensions/drm-copilot/node_modules/jest/package.json` when [P0-T5] starts, the executor stops with `BLOCKED: node_modules absent` and reports to the caller.
- Tool-layer escape hazard: a Write or Edit tool parameter that contains a backslash followed by `u` and four hexadecimal digits is stored as the decoded raw character, not as the six-character escape. The `\x85` form is stored verbatim. This plan therefore (a) moves the existing escape-bearing declaration lines with the Appendix C helper instead of retyping them, (b) writes NEL as `"\x85"` in new test code, and (c) builds the byte-order mark from its code point (`chr(0xFEFF)` in Python, `String.fromCharCode(0xfeff)` in TypeScript). No new or edited text in this cycle contains a `u`-form escape.
- Raw-character rule: the zero-count check uses the Grep tool, output mode count, with the pattern [\x0b\x0c\x1c-\x1f\x{85}\x{a0}\x{1680}\x{2000}-\x{200a}\x{2028}\x{2029}\x{202f}\x{205f}\x{3000}\x{feff}] and must return 0 for each checked file. It returned 0 on every current `plan_gate_*`, `plan-gate-*`, and `test_plan_gate_*` file at planning time.
- 500-line rule: the line count of a file is the Grep tool count for pattern `^`. Pre-change counts at planning time: `plan_gate_commands.py` 403, `plan_gate_scratch.py` 217, `plan_gate_discrimination.py` 398, `plan-gate-commands.ts` 444, `plan-gate-scratch.ts` 226, `plan-gate-rules.ts` 437, `test_plan_gate_scratch_whitespace.py` 150, `test_plan_gate_discrimination_literals.py` 387, `test_plan_gate_scratch_docs.py` 189, `plan-gate-discrimination-literals.test.ts` 314. Every changed non-Markdown file must stay at or under 500.
- Out-of-scope remediation log: whenever a task edits a repository file that is not in the WRITES list of this plan, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation-rc3.<timestamp>.md`. It carries `Timestamp:`, the triggering task ID, one `PATH: ` line per edited repository-relative path, and a one-line reason per path. Those paths are staged in the commit of the phase that edited them.

## Fixture Rule for This Plan

This plan must pass G10. It quotes no bare SCRATCH definition anywhere, and no fixture in this cycle contains SCRATCH definition text. All code and fixture text is in fenced appendices after the last phase, outside every task attribution window.

### Phase 0 — Policy Reads and Remediation Baselines

All Phase 0 commands are read-only check modes. No write-mode formatter runs in this phase. All artifacts go to `<FEATURE>/evidence/remediation-baseline/`.

- [x] [P0-T1] Read the policy files in policy-compliance order and record them in `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read-rc3.<timestamp>.md`
  - Files, in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and a list naming all nine files in that order.
- [x] [P0-T2] Read the cycle inputs and record them in `<FEATURE>/evidence/remediation-baseline/remediation-inputs-read-rc3.<timestamp>.md`
  - Files: `<FEATURE>/remediation-inputs.2026-10-16T05-36.md`, `<FEATURE>/policy-audit.2026-10-16T05-25.md`, `<FEATURE>/code-review.2026-10-16T05-25.md`, `<FEATURE>/feature-audit.2026-10-16T05-25.md`.
  - Acceptance: the artifact carries `Timestamp:` and lists the four files. It lists the in-scope ID `N-3` and the declined items `fence-pattern residual`, `U-2`, `U-3`, `CR-6`, and `CR-7`, each with the reason stated in the inputs file.
- [x] [P0-T3] Record the git baseline in `<FEATURE>/evidence/remediation-baseline/git-baseline-rc3.<timestamp>.md`
  - Commands: `git fetch origin main`, `git rev-parse HEAD`, `git merge-base origin/main HEAD`, `git status --porcelain`.
  - Acceptance: each command records `EXIT_CODE: 0`. The artifact records the HEAD SHA under the label `RC3_BASE:` and the merge-base SHA under the label `MERGE_BASE:`. The porcelain output lists no path other than `SCRATCH/` and `<FEATURE>/remediation-plan.2026-10-16T05-36.md`; either may be absent.
- [x] [P0-T4] Create the scratch subdirectories `SCRATCH/cov/`, `SCRATCH/corpus/`, and `SCRATCH/stage/` and record them in `<FEATURE>/evidence/remediation-baseline/scratch-setup-rc3.<timestamp>.md`
  - Method: the Write tool writes `README.txt` in each of the three subdirectories, each with the one-line content `Issue 932 remediation cycle 3 scratch directory; not committed.`. `SCRATCH` is resolved to its absolute path for the tool calls only.
  - Acceptance: the Glob tool with pattern `*/README.txt`, rooted at the resolved `SCRATCH` directory, returns the three files. The artifact records the method and the relative results using the token `SCRATCH` only.
- [x] [P0-T5] Capture the TypeScript format baseline in `<FEATURE>/evidence/remediation-baseline/ts-format-baseline-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `Output Summary:` quotes either `All matched files use Prettier code style!` or the list of files reported with warnings, and records the observed exit code.
- [x] [P0-T6] Capture the TypeScript lint baseline in `<FEATURE>/evidence/remediation-baseline/ts-lint-baseline-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `Output Summary:` records the error and warning counts (no output on a clean run is recorded as `0 errors, 0 warnings`).
- [x] [P0-T7] Capture the TypeScript production type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-baseline-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count (no output on success).
- [x] [P0-T8] Capture the TypeScript test type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-test-baseline-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count.
- [x] [P0-T9] Capture the full jest coverage baseline in `<FEATURE>/evidence/remediation-baseline/ts-coverage-baseline-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary --reporters=default`
  - Acceptance: `Output Summary:` records:
    - the suite and test pass/fail counts and the `text-summary` totals;
    - every failing suite and any coverage-threshold message;
    - the `lines.pct` and `branches.pct` values for `src/lib/validate/plan-gate-scratch.ts`, `src/lib/validate/plan-gate-commands.ts`, and `src/lib/validate/plan-gate-rules.ts`, read from `extensions/drm-copilot/coverage/coverage-summary.json`.
- [x] [P0-T10] Capture the Python format baseline in `<FEATURE>/evidence/remediation-baseline/python-format-baseline-rc3.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the black summary line (for example `6 files would be left unchanged.`) and records the observed exit code.
- [x] [P0-T11] Capture the Python lint baseline in `<FEATURE>/evidence/remediation-baseline/python-lint-baseline-rc3.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes either `All checks passed!` or the diagnostic count.
- [x] [P0-T12] Capture the Python type-check baseline in `<FEATURE>/evidence/remediation-baseline/python-typecheck-baseline-rc3.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the pyright summary line (`N errors, N warnings, N informations`).
- [x] [P0-T13] Capture the Python coverage baseline for `scripts.dev_tools.plan_gate_commands`, `scripts.dev_tools.plan_gate_scratch`, and `scripts.dev_tools.plan_gate_discrimination` in `<FEATURE>/evidence/remediation-baseline/python-coverage-baseline-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py-rc3.json`
  - Acceptance: `Output Summary:` records:
    - the total `passed` and `failed` counts from the final pytest summary line;
    - the `term-missing` rows for `plan_gate_commands.py`, `plan_gate_scratch.py`, and `plan_gate_discrimination.py`;
    - for each of those three files, the numeric line coverage (`covered_lines / num_statements`) and branch coverage (`covered_branches / num_branches`), read from its `summary` object in `SCRATCH/cov/baseline-py-rc3.json`.
- [x] [P0-T14] Capture the broad dev-tools regression baseline in `<FEATURE>/evidence/remediation-baseline/python-devtools-baseline-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: `Output Summary:` records the pass/fail/error/skip counts and lists every failing or erroring node ID (the reference set for [P5-T6]).
- [x] [P0-T15] Record the line-count and raw-character baseline of the ten code files in the WRITES list in `<FEATURE>/evidence/remediation-baseline/file-size-baseline-rc3.<timestamp>.md`
  - Method: for each of the ten non-Markdown files in the WRITES list, run the Grep tool with pattern `^` and output mode `count`, and run the raw-character zero-count check in Conventions.
  - Acceptance: the artifact lists each file with its line count and raw-character count. Every line count equals the pre-change value in Conventions (a difference is recorded with the observed value and used as the reference instead), and every raw-character count is 0.
- [x] [P0-T16] Commit and push the Phase 0 evidence under `<FEATURE>/evidence/remediation-baseline/` with this plan file
  - Commands: `git add <FEATURE>/evidence/remediation-baseline <FEATURE>/remediation-plan.2026-10-16T05-36.md` (with the concrete folder path), `git commit -m "docs(932): record remediation cycle 3 baselines"`, `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 1 — Red Tests

Static checks for the files written in this phase are deferred to Phase 2 (Python) and Phase 3 (TypeScript). No test in this phase imports a symbol that does not yet exist: the Python parity test reads the constant through `vars()` at run time, the declaration-count test reads source files, and the TypeScript case imports nothing new. No task in this phase runs a test node that a later phase makes pass, except the two `[expect-fail]` runs.

- [x] [P1-T1] Update `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` to pin the class in the extractor modules (N-3)
  - Apply the Appendix E1 changes exactly: the import swap, the TypeScript module path, the parity-test Arrange line and messages, the docstring paragraph, the two new module constants, and the new test `test_whitespace_class_declared_once_per_runtime`.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; no `u`-form escape is added.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for the pattern `^def test_whitespace_class_declared_once_per_runtime\(`, 1 for the pattern `vars\(plan_gate_commands\)`, and 0 for the pattern `plan_gate_scratch as plan_gate_scratch`.
    - The line count (Grep pattern `^`, output mode `count`) is at most 500 (150 before this task).
    - The raw-character zero-count check in Conventions returns 0.
    - The counts are recorded in the [P1-T5] artifact.
- [x] [P1-T2] Add the G6 frozen-expectation fixtures to `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` (N-3)
  - Add the module constants `_NEL`, `_BOM`, `_G5_ABSENT_FINDING`, and `_G6_CROSS_LINE_WARNING`, and the parametrized test `test_g6_normalization_uses_plan_whitespace_class`, exactly as in Appendix E2, after `test_g6_window_split_ignores_form_feed_and_line_separator`.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; no `u`-form escape is added.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for the pattern `^def test_g6_normalization_uses_plan_whitespace_class\(`.
    - It returns 4 for the pattern `id="(nel-only-line|bom-only-line|nel-joined-line|bom-joined-line)"`.
    - The line count is at most 500 (387 before this task).
    - The raw-character zero-count check returns 0.
    - The counts are recorded in the [P1-T5] artifact.
- [x] [P1-T3] Add the rule-file G6 documentation test to `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` (N-3)
  - Add the module constants `_G6_WHITESPACE_PHRASES` and `_SUPERSEDED_DECLARATION_PHRASE` and the test `test_rule_file_states_g6_whitespace_alignment`, exactly as in Appendix E3. The existing `_WHITESPACE_ALIGNMENT_PHRASES` and `test_rule_file_states_g10_whitespace_alignment` are unchanged.
  - Structural rules: Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for the pattern `^def test_rule_file_states_g6_whitespace_alignment\(`.
    - The line count is at most 500 (189 before this task).
    - The counts are recorded in the [P1-T5] artifact.
- [x] [P1-T4] Add the G6 frozen-expectation case to `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts` (N-3)
  - Inside `describe("evaluatePlanGates search literals", ...)` (line 90), after the case `treats a form feed or line separator in a tracked file as part of one line`, add the case in Appendix F3 exactly.
  - Structural rules: plain `it("<literal title>", ...)` only (no `it.each`, no `test(`); no new import; Arrange–Act–Assert comments; no `u`-form escape is added.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for the pattern `it\("normalizes G6 tracked lines with the plan whitespace class"` and 0 for the pattern `it\.each|^\s*test\(`.
    - The line count is at most 500 (314 before this task).
    - The raw-character zero-count check returns 0.
    - The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T5] [expect-fail] Run the Python red set and record `<FEATURE>/evidence/regression-testing/python-red-rc3.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Expected failures, five nodes, each for the stated reason:
    - `test_whitespace_class_matches_typescript`: `KeyError: 'PLAN_WHITESPACE_CLASS'`, because `plan_gate_commands` does not declare the class yet.
    - `test_whitespace_class_declared_once_per_runtime`: `AssertionError`, because the observed counts place the declaration in both G10 modules and in neither extractor module.
    - `test_g6_normalization_uses_plan_whitespace_class[nel-only-line]`: `AssertionError`; Python drops the NEL-only line as blank and reports the G6 cross-line warning instead of the G5 finding.
    - `test_g6_normalization_uses_plan_whitespace_class[nel-joined-line]`: `AssertionError`; Python normalizes NEL to a space, finds the phrase on one line, and reports the G5 finding instead of the G6 warning.
    - `test_rule_file_states_g6_whitespace_alignment`: `AssertionError` naming the missing tokens.
  - Expected passes: `test_g6_normalization_uses_plan_whitespace_class[bom-only-line]` and `[bom-joined-line]`, and every pre-existing test in the three files.
  - Acceptance:
    - The artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
    - It records `ExpectedExitCode:`, set to the observed exit code only when the failing nodes are exactly the five expected nodes with the stated signatures.
    - `Output Summary:` names each failing node with its first error line and each expected-pass node, as printed by the `-v` per-node lines.
    - The artifact also records the Grep counts from [P1-T1], [P1-T2], and [P1-T3].
    - Any unexpected signature halts the task for a plan revision.
- [x] [P1-T6] [expect-fail] Run the TypeScript red set and record `<FEATURE>/evidence/regression-testing/ts-red-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-discrimination-literals.test.ts --reporters=default`
  - Expected failure, one case: `normalizes G6 tracked lines with the plan whitespace class`. The second and fourth elements (the byte-order-mark cases) differ: TypeScript treats the byte-order mark as whitespace, so it reports G6 for the byte-order-mark-only line and G5 for the joined line. The first and third elements (NEL) already match.
  - Expected passes: every pre-existing case in the file.
  - Acceptance:
    - The artifact records `EXIT_CODE: 1` and `ExpectedExitCode: 1`.
    - `Output Summary:` names the failing case and quotes the differing elements from the jest diff.
    - The artifact also records the Grep counts from [P1-T4].
    - Any other failure halts the task for a plan revision.
- [x] [P1-T7] Commit and push the Phase 1 test changes, the `<FEATURE>/evidence/regression-testing/` red artifacts, and the plan check-offs
  - Commands: `git add tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts` plus the two red artifacts and this plan file, `git commit -m "test(932): add remediation cycle 3 red tests for the G6 whitespace class"`, `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`. The red tests are committed before any production file changes.

### Phase 2 — Python Implementation (N-3)

- [x] [P2-T1] Write the declaration-move helper `SCRATCH/stage/move_whitespace_class.py` and record `<FEATURE>/evidence/regression-testing/move-helper-rc3.<timestamp>.md`
  - Method: the Write tool writes the exact content of Appendix C, with `SCRATCH` resolved for the tool call only.
  - Acceptance:
    - The Grep tool, output mode `count`, on the helper returns 0 for the pattern `\\u[0-9a-fA-F]{4}` and 0 for the raw-character pattern in Conventions.
    - It returns 1 for the pattern `^def move_python\(` and 1 for the pattern `^def move_typescript\(`.
    - The artifact records the method and the counts, using the token `SCRATCH` only.
- [x] [P2-T2] Move the Python declaration into `scripts/dev_tools/plan_gate_commands.py` and record `<FEATURE>/evidence/regression-testing/move-python-rc3.<timestamp>.md`
  - Command (repository root): `poetry run python SCRATCH/stage/move_whitespace_class.py python`
  - The helper removes the comment block and the three declaration lines from `scripts/dev_tools/plan_gate_scratch.py` (lines 73-81) and inserts the new comment, the same three declaration lines verbatim, `_PLAN_WHITESPACE_RUN_RE`, and `normalize_plan_whitespace` after `split_plan_lines` in `scripts/dev_tools/plan_gate_commands.py`. It locates every anchor before it writes, and writes nothing when an anchor is missing.
  - Acceptance:
    - `EXIT_CODE: 0`, and the output line `PYTHON_DECLARATIONS: scratch=0 commands=1` is quoted in `Output Summary:`. An `ANCHOR_NOT_FOUND:` line halts the task.
    - The Grep tool, output mode `count`, on `scripts/dev_tools/plan_gate_commands.py` returns 1 for the pattern `^PLAN_WHITESPACE_CLASS = \(`, 1 for the pattern `^def normalize_plan_whitespace\(`, and 0 for the raw-character pattern in Conventions.
    - The `plan_gate_commands.py` line count is at most 500 (403 before; about 438 expected).
- [x] [P2-T3] Complete `scripts/dev_tools/plan_gate_scratch.py` to import the shared class and normalizer (N-3)
  - Apply the Appendix E4 edits with the Edit tool: the import block, the removal of `_normalize_whitespace`, the three call-site renames, and the module-docstring replacement. No other line changes. No edit parameter contains a `u`-form escape.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `^PLAN_WHITESPACE_CLASS = `, 0 for the pattern `_normalize_whitespace`, 3 for the pattern `normalize_plan_whitespace\(`, and 1 for the pattern `^_WHITESPACE_RUN_RE = re\.compile\(PLAN_WHITESPACE_CLASS`.
    - The raw-character zero-count check returns 0, and the line count is at most 500 (217 before).
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_declared_once_per_runtime` exits 0 with 0 failed. The two deselected nodes read the TypeScript modules, which Phase 3 changes; [P3-T6] runs them.
- [x] [P2-T4] Apply the shared class to the G6 normalizers in `scripts/dev_tools/plan_gate_discrimination.py` (N-3)
  - Apply the Appendix E5 edits with the Edit tool: add `normalize_plan_whitespace` to the `plan_gate_commands` import block (between `grep_executable_index` and `split_plan_lines`), and replace the bodies of `_window_join` and `_has_cross_line_presence`. `_plan_quotes_literal` is not changed. The module must look the normalizer up as a module global so the Appendix D helper can substitute it.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 2 for the pattern `\.split\(\)` (5 before, at lines 249, 252, 258, 271, and 280; the two remaining are in `_plan_quotes_literal`), 3 for the pattern `normalize_plan_whitespace\(`, and 1 for the pattern `^    normalize_plan_whitespace,`.
    - The line count is at most 500 (398 before).
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` exits 0 with 0 failed.
- [x] [P2-T5] Run the Python green set with coverage and record `<FEATURE>/evidence/regression-testing/python-green-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_declared_once_per_runtime --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing`
  - Acceptance:
    - `EXIT_CODE: 0` and 0 failed; the pytest summary line reports 2 deselected.
    - `Output Summary:` records the pass count and the `term-missing` rows for the three files.
    - The `plan_gate_scratch.py` row shows `100%` with an empty `Missing` column.
    - No line of `normalize_plan_whitespace` in `plan_gate_commands.py` is listed in its `Missing` column.
- [x] [P2-T6] Write and run the G1-G9 corpus A/B helper and record `<FEATURE>/evidence/regression-testing/g6-whitespace-corpus-ab-rc3.<timestamp>.md`
  - Method: the Write tool writes `SCRATCH/corpus/g6_whitespace_ab.py` with the exact content of Appendix D, with `SCRATCH` resolved for the tool call only. Then, at the repository root, run `poetry run python SCRATCH/corpus/g6_whitespace_ab.py SCRATCH/corpus/g6-whitespace-ab.json` with a 600000 ms tool timeout. The cycle-2 run of a similar helper took about 22 minutes; if the tool layer moves the command to the background, the executor waits for that run to complete and records its exit code and output.
  - The helper evaluates every `plan.*.md` and `remediation-plan.*.md` file under `docs/` three times against one memoized production git seam: with the production normalizer, with the pre-change Python normalization substituted into `plan_gate_discrimination`, and with an emulation of the pre-change TypeScript normalization substituted the same way. It drops G10 findings and compares the G1-G9 Blocking and Warning lists per file. Two built-in probes (a NEL-only tracked line for Python, a byte-order-mark-only tracked line for TypeScript) must each differ from production under their substitution.
  - Acceptance:
    - `EXIT_CODE: 0`.
    - `Output Summary:` quotes the printed lines `PROBE_PYTHON_DIFFERS: True`, `PROBE_TYPESCRIPT_DIFFERS: True`, `PLANS_DIFFERING_PYTHON: 0`, and `PLANS_DIFFERING_TYPESCRIPT: 0`, and the `PLANS_SCANNED:`, `FINDINGS_AFTER:`, `FINDINGS_PYTHON_BEFORE:`, and `FINDINGS_TYPESCRIPT_BEFORE:` lines.
    - `PLANS_SCANNED` is at least 100, and the three findings totals are equal.
    - A `DIFFERS_PYTHON:` or `DIFFERS_TYPESCRIPT:` line, a probe value of `False`, or a non-zero exit halts the task for a plan revision.
- [x] [P2-T7] Run the Python plan-gate regression suites and record `<FEATURE>/evidence/regression-testing/python-plan-gate-regression-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_states_g6_whitespace_alignment`
  - Acceptance:
    - `EXIT_CODE: 0`, 0 failed, and the pytest summary line reports 1 deselected.
    - `Output Summary:` records the pass count and names the deselected node. That node passes only after the Phase 4 rule-file edit; [P4-T1], [P4-T4], and [P5-T5] run it.
    - Any failure halts the task.
- [x] [P2-T8] Run the Python format check on the six Python files and record `<FEATURE>/evidence/regression-testing/python-format-rc3.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary line `6 files would be left unchanged.`
  - Remediation branch: run `poetry run black scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, record its `reformatted` and `left unchanged` summary, rerun the raw-character check on any reformatted file, then rerun from [P2-T5].
- [x] [P2-T9] Run the Python lint check on the same six files and record `<FEATURE>/evidence/regression-testing/python-lint-rc3.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the output line `All checks passed!`. Any suppression added follows `.claude/rules/python-suppressions.md`.
- [x] [P2-T10] Run the Python strict type check on the same six files and record `<FEATURE>/evidence/regression-testing/python-typecheck-rc3.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary `0 errors`.
- [x] [P2-T11] Commit and push `scripts/dev_tools/plan_gate_commands.py`, `scripts/dev_tools/plan_gate_scratch.py`, `scripts/dev_tools/plan_gate_discrimination.py`, the `<FEATURE>/evidence/regression-testing/` artifacts, and the plan check-offs
  - Commands: `git add scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py` plus any file reformatted in [P2-T8], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): share PLAN_WHITESPACE_CLASS with Python G6 from the command extractor module"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 3 — TypeScript Implementation (N-3)

- [x] [P3-T1] Move the TypeScript declaration into `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` and record `<FEATURE>/evidence/regression-testing/move-typescript-rc3.<timestamp>.md`
  - Command (repository root): `poetry run python SCRATCH/stage/move_whitespace_class.py typescript`
  - The helper removes the TSDoc block, the `export const PLAN_WHITESPACE_CLASS` line, the blank line after it, and the `WHITESPACE_RUN_RE` line from `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (lines 67-79), and inserts the new TSDoc, the same declaration line verbatim, `PLAN_WHITESPACE_RUN_RE`, and `normalizePlanWhitespace` after `splitPlanLines` in `plan-gate-commands.ts`.
  - Acceptance:
    - `EXIT_CODE: 0`, and the output line `TYPESCRIPT_DECLARATIONS: scratch=0 commands=1` is quoted in `Output Summary:`. An `ANCHOR_NOT_FOUND:` line halts the task.
    - The Grep tool, output mode `count`, on `plan-gate-commands.ts` returns 1 for the pattern `^export const PLAN_WHITESPACE_CLASS = String\.raw`, 1 for the pattern `^export function normalizePlanWhitespace\(`, and 0 for the raw-character pattern in Conventions.
    - The `plan-gate-commands.ts` line count is at most 500 (444 before; about 474 expected).
- [x] [P3-T2] Complete `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` to import the shared class and normalizer (N-3)
  - Apply the Appendix F1 edits with the Edit tool: the import statement, the removal of `normalizeWhitespace` and its TSDoc, the three call-site renames, and the module-TSDoc bullet replacement. No other line changes. No edit parameter contains a `u`-form escape.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `PLAN_WHITESPACE_CLASS = String\.raw`, 0 for the pattern `\bnormalizeWhitespace\b`, 0 for the pattern `WHITESPACE_RUN_RE`, 3 for the pattern `normalizePlanWhitespace\(`, and 1 for the pattern `LEADING_WHITESPACE_RE = new RegExp`.
    - The raw-character zero-count check returns 0, and the line count is at most 500 (226 before).
    - `npx tsc -p ./ --noEmit` exits 0.
    - `npx jest --config jest.config.cjs test/lib/validate/plan-gate-scratch.test.ts --reporters=default` exits 0 with 0 failed.
- [x] [P3-T3] Apply the shared class to the G6 normalizers in `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` (N-3)
  - Apply the Appendix F2 edits with the Edit tool: add `normalizePlanWhitespace` to the `./plan-gate-commands` import, extend the `normalizeWhitespace` TSDoc, and replace the bodies of `windowJoin` and `hasCrossLinePresence`. `planQuotesLiteral` is not changed.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `\.trim\(\)` (1 before, at line 394), 2 for the pattern `split\(/` (3 before, at lines 347, 419, and 428), 3 for the pattern `normalizeWhitespace\(` (5 before), and 3 for the pattern `normalizePlanWhitespace\(`.
    - The line count is at most 500 (437 before).
    - `npx tsc -p ./ --noEmit` exits 0.
    - `npx jest --config jest.config.cjs test/lib/validate/plan-gate-discrimination-literals.test.ts --reporters=default` exits 0 with 0 failed.
- [x] [P3-T4] Run the TypeScript format check on the four changed TypeScript files and record `<FEATURE>/evidence/regression-testing/ts-format-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check src/lib/validate/plan-gate-commands.ts src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-rules.ts test/lib/validate/plan-gate-discrimination-literals.test.ts`
  - Acceptance: `EXIT_CODE: 0` and the line `All matched files use Prettier code style!`.
  - Remediation branch: run `npx prettier --write` over the reported paths, record each path it reports as `(unchanged)` or rewritten, rerun the raw-character check on any rewritten file, then rerun from [P3-T4].
- [x] [P3-T5] Run the TypeScript lint check on the same four files and record `<FEATURE>/evidence/regression-testing/ts-lint-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-commands.ts src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-rules.ts test/lib/validate/plan-gate-discrimination-literals.test.ts`
  - Acceptance: `EXIT_CODE: 0` with no reported problem line. Any suppression follows `.claude/rules/typescript-suppressions.md`.
- [x] [P3-T6] Run both TypeScript type checks, the validate test directory, and the two Python cross-runtime nodes, and record `<FEATURE>/evidence/regression-testing/ts-green-rc3.<timestamp>.md` (TypeScript commands in `extensions/drm-copilot/`, the pytest command at the repository root)
  - Commands: `npx tsc -p ./ --noEmit`, `npx tsc -p tsconfig.jest.json --noEmit`, `npx jest --config jest.config.cjs --verbose test/lib/validate --reporters=default`, `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_declared_once_per_runtime`.
  - Acceptance:
    - All four exit 0, and the pytest command reports 2 passed.
    - `Output Summary:` records the jest suite and test pass counts and 0 failed.
    - It quotes the verbose passing lines for `normalizes G6 tracked lines with the plan whitespace class`, `decides continuation with the plan whitespace class`, and `normalizes whitespace with the plan whitespace class`.
- [x] [P3-T7] Commit and push `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`, the `<FEATURE>/evidence/regression-testing/` artifacts, and the plan check-offs
  - Commands: `git add extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` plus any file rewritten in [P3-T4], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): share PLAN_WHITESPACE_CLASS with TypeScript G6 from the command extractor module"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 4 — Rule File and Specification Text (N-3)

Every sentence quoted in this phase is inserted verbatim as part of one existing line of the target file. Neither file hard-wraps prose.

- [x] [P4-T1] Update the parity paragraph in `.claude/rules/plan-acceptance-gates.md` (line 153)
  - On line 153, keep the first two sentences unchanged (the one beginning `A continuation line is non-blank` and the one beginning `Both runtimes split the document`).
  - Replace the third sentence, which begins `Both runtimes share one explicit whitespace class` and ends `the Unicode line and paragraph separators.`, with: `Both runtimes share one explicit whitespace class for the blank-line test, the continuation test, and whitespace normalization, declared once per runtime as PLAN_WHITESPACE_CLASS in the command extractor module, with an identical pattern string in both: tab, line feed, vertical tab, form feed, carriage return, space, the Unicode space separators, and the Unicode line and paragraph separators.`
  - Keep the fourth sentence (beginning `NEL, the information separators, and the byte-order mark are outside that class`) unchanged, and insert after it: `G6 uses the same class for its single-line test, its sliding-window join, and the split of the search literal into words, so a tracked file that contains NEL, an information separator, or the byte-order mark produces the same G6 result in both runtimes; the plan-quotation exoneration, which reads the plan text rather than a tracked file, keeps each runtime's native class.`
  - Keep the final sentence (beginning `The fence test keeps the command extractor's fence pattern`) unchanged.
  - In the file, `PLAN_WHITESPACE_CLASS` is written between backticks. The apostrophes are ASCII. No literal bare SCRATCH definition is added outside a fenced block. No other line changes.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_states_g6_whitespace_alignment tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_states_g10_whitespace_alignment tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10_line_rules_and_issue_token_class tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` exits 0 with 4 passed.
- [x] [P4-T2] Copy the rule file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
  - Command (repository root): `cp .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. Fallback when the tool layer refuses `cp`: read the source with the Read tool and write the identical content to the destination with the Write tool.
  - Acceptance:
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical` exits 0 with 1 passed.
    - `git hash-object .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` prints two equal object IDs, which are recorded in the [P4-T4] artifact.
- [x] [P4-T3] Update the NFR-2 note in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md` (line 212)
  - Replace the NFR-2 sub-bullet that begins `  - Remediation cycle 1 and 2 note:` with: `  - Remediation cycle 1 to 3 note: line splitting is aligned on the CR LF, LF, and CR terminators in both runtimes, in the command extractor, and in the G6 cross-line check (cycle 2). The blank-line test, the continuation test, and whitespace normalization share one explicit whitespace class, PLAN_WHITESPACE_CLASS, with an identical pattern string in both runtimes (cycle 2), so NEL, the information separators, and the byte-order mark no longer produce different G10 results. G6 normalizes tracked lines, its sliding-window join, and the search literal with the same class, and the class and its normalizer are declared once per runtime in the command extractor module (cycle 3), so those characters no longer produce different G6 results either. The plan-quotation exoneration keeps each runtime's native class. The fence test keeps the command extractor's fence pattern, whose leading whitespace is each runtime's native class; that difference is shared with G1 through G9 and is documented in .claude/rules/plan-acceptance-gates.md.`
  - In the file, `PLAN_WHITESPACE_CLASS` and the rule-file path are written between backticks. No acceptance-criterion checkbox in `spec.md` changes, and no other line changes.
  - Acceptance:
    - The Grep tool, output mode `count`, on `spec.md` returns 1 for the pattern `Remediation cycle 1 to 3 note` and 0 for the pattern `Remediation cycle 1 and 2 note` (1 before).
    - It returns 2 for the pattern `PLAN_WHITESPACE_CLASS` (2 before: item 6 and the NFR-2 note).
    - The count for the pattern `^- \[x\] ` is 31 and the count for the pattern `^- \[ \] ` is 1, both unchanged from before the edit.
- [x] [P4-T4] Run the documentation, contract, push-down, and frontmatter suites and record `<FEATURE>/evidence/regression-testing/docs-green-rc3.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: 0 failed, or exactly one failure that is the #510 node with the #510 signature described in Conventions. The artifact records which case applies and the two object IDs from [P4-T2].
- [x] [P4-T5] Commit and push `.claude/rules/plan-acceptance-gates.md`, its bundle copy, `spec.md`, the evidence, and the plan check-offs
  - Commands: `git add .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md <FEATURE>/spec.md` (with the concrete folder path) plus the new evidence and this plan file; `git commit -m "docs(932): state the shared G6 whitespace class in the rule file and spec"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 5 — Final QA Loop

Loop rule: [P5-T1] through [P5-T11] form one pass. If any of them fails or changes a file, fix the cause, commit the fix, and restart at [P5-T1]. Each pass writes new artifacts with new timestamps. The loop ends only when one pass completes with every step meeting its acceptance and no file change.

- [x] [P5-T1] Run the final Python format check and record `<FEATURE>/evidence/qa-gates/python-format-final-rc3.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `6 files would be left unchanged.`
  - Remediation branch: run `poetry run black` over the same six paths, record the `reformatted` and `left unchanged` summary, and restart the loop.
- [x] [P5-T2] Run the final Python lint check and record `<FEATURE>/evidence/qa-gates/python-lint-final-rc3.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `All checks passed!`.
- [x] [P5-T3] Run the final Python strict type check and record `<FEATURE>/evidence/qa-gates/python-typecheck-final-rc3.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `0 errors`.
- [x] [P5-T4] Run the final Python coverage gate and record `<FEATURE>/evidence/qa-gates/python-coverage-final-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/final-py-rc3.json`
  - Acceptance:
    - `EXIT_CODE: 0` and 0 failed. The total `passed` count is at least the [P0-T13] count plus 6 (the new declaration-count test, the four new G6 nodes, and the new docs test); the artifact records the exact difference.
    - Read from each file's `summary` object in `SCRATCH/cov/final-py-rc3.json`:
      - `plan_gate_scratch.py` has `covered_lines == num_statements` and `covered_branches == num_branches` (100% line and branch).
      - `plan_gate_commands.py` and `plan_gate_discrimination.py` line and branch percentages are not lower than the [P0-T13] values, and each is at least the policy floor (85% line, 75% branch).
    - No `+` line number in the hunks of `git diff -U0 <RC3_BASE> HEAD -- scripts/dev_tools/plan_gate_commands.py scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py` that is an executable statement appears in that file's `missing_lines`.
    - `Output Summary:` records baseline, post-change, and changed-line figures for the three files.
- [x] [P5-T5] Run the final Python contract and frontmatter suites and record `<FEATURE>/evidence/qa-gates/python-contract-final-rc3.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: 0 failed, or exactly the #510 node with the #510 signature, recorded as `pending-CI` for that node. The artifact quotes the `PASSED` lines of `test_rule_file_bundle_copy_is_byte_identical` and `test_rule_file_states_g6_whitespace_alignment`.
- [x] [P5-T6] Run the final broad dev-tools regression and record `<FEATURE>/evidence/qa-gates/python-devtools-final-rc3.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: every failing or erroring node ID is in the [P0-T14] reference set or is the #510 node, and the artifact lists any node that newly passes or newly fails. A new failure related to this change is fixed inside this item and the loop restarts. When that fix edits a file outside the WRITES list, the out-of-scope remediation log in Conventions applies.
- [x] [P5-T7] Run the final TypeScript format check and record `<FEATURE>/evidence/qa-gates/ts-format-final-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `EXIT_CODE: 0` and `All matched files use Prettier code style!`. If [P0-T5] recorded pre-existing warnings, it is also acceptable for the reported file set to be a subset of the baseline set that contains no file changed by this plan.
  - Remediation branch, for a file changed by this plan: run `npx prettier --write` on that file, record `(unchanged)` or the rewrite, and restart the loop.
- [x] [P5-T8] Run the final repository lint command and record `<FEATURE>/evidence/qa-gates/ts-lint-final-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `EXIT_CODE: 0` with 0 errors and no warning in a file changed by this plan.
- [x] [P5-T9] Run the final TypeScript production type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-final-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T10] Run the final TypeScript test type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-test-final-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T11] Run the final full jest coverage gate and record `<FEATURE>/evidence/qa-gates/ts-coverage-final-rc3.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary --reporters=default`
  - Acceptance:
    - `EXIT_CODE: 0`, 0 failed suites and tests, and no coverage-threshold failure message. Any pre-existing U-2 "Coverage data ... was not found" line is recorded but is not a failure.
    - From `extensions/drm-copilot/coverage/coverage-summary.json`:
      - `src/lib/validate/plan-gate-scratch.ts` has `lines.pct` equal to 100 and `branches.pct` equal to 100;
      - the `src/lib/validate/plan-gate-commands.ts` and `src/lib/validate/plan-gate-rules.ts` percentages are not lower than the [P0-T9] values.
    - From `extensions/drm-copilot/coverage/lcov.info`: no `+` line of `git diff -U0 <RC3_BASE> HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` has a zero-hit `DA:` record.
    - `Output Summary:` records baseline, post-change, and changed-line figures.
- [x] [P5-T12] Confirm a single clean loop pass in `<FEATURE>/evidence/qa-gates/qa-loop-summary-rc3.<timestamp>.md`
  - Acceptance:
    - The latest artifacts of [P5-T1] through [P5-T11] all carry timestamps from one pass that started after the last code commit.
    - Each records an `EXIT_CODE:` that meets its task.
    - `git status --porcelain` lists only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T13] Validate this plan and the cycle-2 plan with the production CLI and record `<FEATURE>/evidence/qa-gates/plan-self-validation-rc3.<timestamp>.md`
  - Commands:
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-plan.2026-10-16T05-36.md`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-plan.2026-10-16T03-19.md`
  - Acceptance: both exit 0, and neither prints a line containing `SCRATCH definition`. The artifact records each exit code and every printed `PLAN GATE WARNING: ` line verbatim.
- [x] [P5-T14] Check file size, raw characters, and temporary-file use for every changed non-Markdown file, and record `<FEATURE>/evidence/qa-gates/file-size-and-tempfile-check-rc3.<timestamp>.md`
  - Method:
    - Run the Grep tool with pattern `^` and output mode `count` on each of the ten non-Markdown files in the WRITES list below.
    - Run the Grep tool with pattern `tmp_path|tempfile|mkdtemp|NamedTemporaryFile|tmpdir|writeFileSync|mkdtempSync` over the four changed test files.
    - Run the raw-character zero-count check in Conventions on all ten files.
  - Acceptance: every line count is at most 500; the temporary-file search returns zero matches; every raw-character count is 0. The artifact lists each file with its pre-change count (from [P0-T15]) and its post-change count.
- [x] [P5-T15] Verify the change scope and record `<FEATURE>/evidence/qa-gates/scope-diff-rc3.<timestamp>.md`
  - Commands: `git diff --name-only <RC3_BASE> HEAD`, `git diff --name-status --diff-filter=D <MERGE_BASE> HEAD`, `git status --porcelain`.
  - Acceptance:
    - Every path listed by the first command is in the WRITES list of this plan, or under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/`, or on a `PATH: ` line of an `out-of-scope-remediation-rc3.*.md` artifact. When no such artifact exists, the scope artifact records `REMEDIATION-LOG: none` together with the Glob search that established it.
    - `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/package.json`, and `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts` are not listed.
    - The deletion listing is empty.
    - The porcelain listing shows only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T16] Commit and push the final evidence under `<FEATURE>/evidence/qa-gates/` and the plan check-offs
  - Commands: `git add` naming the new `<FEATURE>/evidence/qa-gates/` artifacts and this plan file; `git commit -m "docs(932): record remediation cycle 3 final QA evidence"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

## Remediation Acceptance Criteria

- **N3-CODE.** The G6 single-line test, the sliding-window join, and the search-literal split in both runtimes normalize with `PLAN_WHITESPACE_CLASS`. The class and its normalizer are declared once per runtime, in the command extractor module, with identical pattern strings, and the G10 modules import them (pinned by `test_whitespace_class_matches_typescript` and `test_whitespace_class_declared_once_per_runtime`).
- **N3-FIXTURES.** The four frozen G6 fixtures (`nel-only-line`, `bom-only-line`, `nel-joined-line`, `bom-joined-line`) pass in both suites. The NEL cases failed in Python and the byte-order-mark cases failed in TypeScript before the change.
- **N3-AB.** The corpus A/B run reports `PLANS_DIFFERING_PYTHON: 0` and `PLANS_DIFFERING_TYPESCRIPT: 0`, with both probes differing.
- **N3-DOCS.** The rule-file parity paragraph (and its byte-identical bundle copy) and the `spec.md` NFR-2 note state that G6 normalization uses the shared class, name its single declaration per runtime, and keep the fence-pattern residual statement.
- **N3-QUALITY.** Both G10 modules stay at 100% line and branch coverage; the coverage of changed lines and of the other changed production modules does not drop; every changed non-Markdown file is at most 500 lines.

## Acceptance-Criteria Map

| ID | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- |
| N3-CODE | P2-T2, P2-T3, P2-T4, P3-T1, P3-T2, P3-T3 | `test_whitespace_class_matches_typescript`; `test_whitespace_class_declared_once_per_runtime`; existing G10 whitespace fixtures in both suites | python-green-rc3, ts-green-rc3 |
| N3-FIXTURES | P1-T2, P1-T4 | `test_g6_normalization_uses_plan_whitespace_class` (four ids); TS case `normalizes G6 tracked lines with the plan whitespace class` | python-red-rc3, ts-red-rc3, python-green-rc3, ts-green-rc3 |
| N3-AB | P2-T6 | Appendix D helper with two discriminating probes | g6-whitespace-corpus-ab-rc3 |
| N3-DOCS | P4-T1, P4-T2, P4-T3 | `test_rule_file_states_g6_whitespace_alignment`; `test_rule_file_states_g10_whitespace_alignment`; `test_rule_file_bundle_copy_is_byte_identical`; Grep counts in P4-T3 | docs-green-rc3, python-contract-final-rc3 |
| N3-QUALITY | P5-T4, P5-T11, P5-T14 | coverage JSON and lcov checks; Grep line counts | python-coverage-final-rc3, ts-coverage-final-rc3, file-size-and-tempfile-check-rc3 |

## WRITES (repository files outside the feature folder)

- `scripts/dev_tools/plan_gate_commands.py`
- `scripts/dev_tools/plan_gate_scratch.py`
- `scripts/dev_tools/plan_gate_discrimination.py`
- `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`
- `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`
- `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`
- `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py`
- `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
- `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`
- `.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`

The first ten entries are the non-Markdown files that the line-count and raw-character checks cover. Feature-folder writes: this plan, `spec.md` (text only; no checkbox), and evidence under `evidence/remediation-baseline/`, `evidence/regression-testing/`, and `evidence/qa-gates/`.

Scratch files (not committed): `SCRATCH/cov/README.txt`, `SCRATCH/cov/baseline-py-rc3.json`, `SCRATCH/cov/final-py-rc3.json`, `SCRATCH/corpus/README.txt`, `SCRATCH/corpus/g6_whitespace_ab.py`, `SCRATCH/corpus/g6-whitespace-ab.json`, `SCRATCH/stage/README.txt`, `SCRATCH/stage/move_whitespace_class.py`.

## Appendix A — G6 frozen fixtures

All four cases use the existing plan helper (one task, `P2-T1`, acceptance command `grep -F -n 'pinned items occupy' docs/design.md`) and a stub git seam whose `files_containing` answers `["docs/design.md"]` for `pinned` only. NEL is written `"\x85"`; the byte-order mark is built from its code point. G5 ships on the Warning channel, so both expected findings are on the Warning channel and the Blocking channel is empty.

```text
case             tracked text (Python spelling)                                  expected (blocking, warnings)
nel-only-line    "the pinned\n" + NEL + "\nitems occupy\n"                       ([], [G5 absent finding])
bom-only-line    "the pinned\n" + BOM + "\nitems occupy\n"                       ([], [G5 absent finding])
nel-joined-line  "the pinned" + NEL + "items occupy\nthe pinned\nitems occupy\n" ([], [G6 cross-line warning])
bom-joined-line  "the pinned" + BOM + "items occupy\nthe pinned\nitems occupy\n" ([], [G6 cross-line warning])

Before the change:
  nel-only-line    Python drops the NEL line as blank, joins the window -> G6 (red); TypeScript -> G5
  bom-only-line    Python -> G5; TypeScript drops the BOM line as blank -> G6 (red)
  nel-joined-line  Python normalizes NEL to a space, matches one line -> G5 (red); TypeScript -> G6
  bom-joined-line  Python -> G6; TypeScript normalizes the BOM to a space, matches one line -> G5 (red)

G5 absent finding (one string):
  [P2-T1] search literal `pinned items occupy` is absent from the tracked tree and is not
  quoted in the plan; the search returns zero matches whatever the executor does. Quote the
  exact literal the task will create, or assert a literal that exists.
G6 cross-line warning (one string):
  [P2-T1] search literal `pinned items occupy` is present only across adjacent lines of a
  tracked file and matches no single line; a line-oriented search returns zero matches.
  Search a shorter single-line token.
(The line breaks in the two strings above are display wrapping only; each break is one space.)
```

## Appendix B — Whitespace class membership

| Character | Python `str.isspace` | JavaScript whitespace class | In `PLAN_WHITESPACE_CLASS` |
| --- | --- | --- | --- |
| U+0009 to U+000D (tab, LF, VT, FF, CR) | yes | yes | yes |
| U+001C to U+001F (information separators) | yes | no | no |
| U+0020 (space) | yes | yes | yes |
| U+0085 (NEL) | yes | no | no |
| U+00A0, U+1680, U+2000 to U+200A, U+202F, U+205F, U+3000 (Unicode space separators) | yes | yes | yes |
| U+2028, U+2029 (line and paragraph separators) | yes | yes | yes |
| U+FEFF (byte-order mark) | no | yes | no |

## Appendix C — Declaration-move helper `SCRATCH/stage/move_whitespace_class.py`

Throwaway helper under the session scratch directory; not committed and not subject to the repository lint rules. It contains no `u`-form escape: the escape-bearing declaration lines are read from disk and written back unchanged.

```python
"""Issue 932 remediation cycle 3: move PLAN_WHITESPACE_CLASS into the extractor modules.

Usage, from the repository root: poetry run python <helper path> python|typescript
The declaration line or lines are moved verbatim from the G10 module to the
command extractor module, so the escapes in the pattern string are never
retyped through an editor tool. Every anchor is located before any file is
written; a missing anchor prints ANCHOR_NOT_FOUND, exits 2, and writes nothing.
Line endings are preserved.
"""

import sys
from pathlib import Path

PY_SCRATCH = Path("scripts/dev_tools/plan_gate_scratch.py")
PY_COMMANDS = Path("scripts/dev_tools/plan_gate_commands.py")
TS_SCRATCH = Path("extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts")
TS_COMMANDS = Path("extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts")

PY_PREFIX = "PLAN_WHITESPACE_CLASS = ("
TS_PREFIX = "export const PLAN_WHITESPACE_CLASS = String.raw"

PY_COMMENT = [
    "# One explicit whitespace class shared by G6 and G10. The TypeScript twin",
    "# declares the identical pattern string, and a parity test compares the two.",
    "# The class is the set on which the Python whitespace predicate",
    "# (`str.isspace`) and the JavaScript whitespace class agree: NEL, the",
    "# information separators, and the byte-order mark are excluded, so both",
    "# runtimes treat them as ordinary characters.",
]
PY_RUN_RE = '_PLAN_WHITESPACE_RUN_RE = re.compile(PLAN_WHITESPACE_CLASS + "+")'
PY_FUNCTION = [
    "def normalize_plan_whitespace(text: str) -> str:",
    '    """Join runs of `PLAN_WHITESPACE_CLASS` with one space and trim the ends.',
    "",
    "    Purpose:",
    "        Give G6 and G10 one whitespace normalization, byte-identical to the",
    "        TypeScript `normalizePlanWhitespace`.",
    "",
    "    Args:",
    "        text (str): Text to normalize.",
    "",
    "    Returns:",
    "        str: The normalized text, empty when the text holds only class members.",
    "",
    "    Raises:",
    "        None.",
    "",
    "    Side Effects:",
    "        None.",
    '    """',
    "",
    '    return " ".join(filter(None, _PLAN_WHITESPACE_RUN_RE.split(text)))',
]
TS_DOC = [
    "/**",
    " * One explicit whitespace class shared by G6 and G10.",
    " *",
    " * The string is identical to the Python `PLAN_WHITESPACE_CLASS`, and a parity",
    " * test compares the two. The class is the set on which the Python whitespace",
    " * predicate and the JavaScript whitespace class agree: NEL, the information",
    " * separators, and the byte-order mark are excluded, so both runtimes treat",
    " * them as ordinary characters.",
    " */",
]
TS_RUN_RE = [
    "/** One or more consecutive members of `PLAN_WHITESPACE_CLASS`. */",
    "const PLAN_WHITESPACE_RUN_RE = new RegExp(`${PLAN_WHITESPACE_CLASS}+`);",
]
TS_FUNCTION = [
    "/**",
    " * Join runs of `PLAN_WHITESPACE_CLASS` with one space and trim the ends.",
    " *",
    " * G6 and G10 both normalize with this function.",
    " *",
    " * @param value Text to normalize.",
    " * @returns The normalized text, identical to the Python",
    " *     `normalize_plan_whitespace`.",
    " */",
    "export function normalizePlanWhitespace(value: string): string {",
    "  return value",
    "    .split(PLAN_WHITESPACE_RUN_RE)",
    '    .filter((word) => word !== "")',
    '    .join(" ");',
    "}",
]


def read_lines(path):
    with open(path, encoding="utf-8", newline="") as handle:
        text = handle.read()
    eol = "\r\n" if "\r\n" in text else "\n"
    return text.split(eol), eol


def write_lines(path, lines, eol):
    with open(path, "w", encoding="utf-8", newline="") as handle:
        handle.write(eol.join(lines))


def fail(label):
    print(f"ANCHOR_NOT_FOUND: {label}")
    raise SystemExit(2)


def find(lines, predicate, label, start=0):
    for index in range(start, len(lines)):
        if predicate(lines[index]):
            return index
    fail(label)


def move_python():
    scratch, scratch_eol = read_lines(PY_SCRATCH)
    commands, commands_eol = read_lines(PY_COMMANDS)
    comment = find(
        scratch,
        lambda line: line.startswith("# One explicit whitespace class"),
        "python comment",
    )
    declaration = find(scratch, lambda line: line == PY_PREFIX, "python declaration", comment)
    if declaration + 2 >= len(scratch) or scratch[declaration + 2] != ")":
        fail("python declaration close")
    moved = scratch[declaration : declaration + 3]
    split_def = find(
        commands, lambda line: line.startswith("def split_plan_lines("), "python splitter"
    )
    split_end = find(
        commands, lambda line: line == "    return lines", "python splitter end", split_def
    )
    del scratch[comment : declaration + 3]
    block = ["", "", *PY_COMMENT, *moved, PY_RUN_RE, "", "", *PY_FUNCTION]
    commands[split_end + 1 : split_end + 1] = block
    write_lines(PY_SCRATCH, scratch, scratch_eol)
    write_lines(PY_COMMANDS, commands, commands_eol)
    return PY_SCRATCH, PY_COMMANDS, PY_PREFIX


def move_typescript():
    scratch, scratch_eol = read_lines(TS_SCRATCH)
    commands, commands_eol = read_lines(TS_COMMANDS)
    declaration = find(
        scratch, lambda line: line.startswith(TS_PREFIX), "typescript declaration"
    )
    doc = declaration
    while doc > 0 and scratch[doc] != "/**":
        doc -= 1
    run = find(
        scratch,
        lambda line: line.startswith("const WHITESPACE_RUN_RE = "),
        "typescript run pattern",
        declaration,
    )
    if scratch[doc] != "/**" or run != declaration + 2 or scratch[declaration + 1] != "":
        fail("typescript declaration block")
    moved = scratch[declaration]
    split_def = find(
        commands,
        lambda line: line.startswith("export function splitPlanLines("),
        "typescript splitter",
    )
    split_end = find(commands, lambda line: line == "}", "typescript splitter end", split_def)
    del scratch[doc : run + 1]
    block = ["", *TS_DOC, moved, "", *TS_RUN_RE, "", *TS_FUNCTION]
    commands[split_end + 1 : split_end + 1] = block
    write_lines(TS_SCRATCH, scratch, scratch_eol)
    write_lines(TS_COMMANDS, commands, commands_eol)
    return TS_SCRATCH, TS_COMMANDS, TS_PREFIX


def count_prefix(path, prefix):
    lines, _ = read_lines(path)
    return sum(1 for line in lines if line.startswith(prefix))


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("python", "typescript"):
        print("USAGE: move_whitespace_class.py python|typescript")
        return 2
    mover = move_python if sys.argv[1] == "python" else move_typescript
    scratch, commands, prefix = mover()
    label = sys.argv[1].upper()
    print(
        f"{label}_DECLARATIONS: scratch={count_prefix(scratch, prefix)} "
        f"commands={count_prefix(commands, prefix)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

## Appendix D — Corpus A/B helper `SCRATCH/corpus/g6_whitespace_ab.py`

Throwaway helper under the session scratch directory; not committed and not subject to the repository lint rules. The JavaScript whitespace class is built from code points, so the file contains no `u`-form escape. With the native normalizers substituted, `_window_join` and `_has_cross_line_presence` compute exactly what the pre-change code computed: the filter on a non-empty normalized line equals the old `strip()` and `trim()` filters, and `needle.split(" ")` on a native-normalized needle equals the old native word split.

```python
"""Issue 932 remediation cycle 3: G1-G9 corpus A/B for the G6 whitespace class.

Evaluates every plan.*.md and remediation-plan.*.md file under docs/ three
times against one memoized git seam: with the production normalizer, with the
pre-change Python normalization (str.split), and with an emulation of the
pre-change TypeScript normalization (the JavaScript whitespace class), each
substituted for normalize_plan_whitespace in plan_gate_discrimination. G10
findings are dropped. Prints counts and writes the per-plan findings to the
JSON path given as the first argument.
"""

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

import scripts.dev_tools.plan_gate_discrimination as discrimination  # noqa: E402

G10_MARKER = "SCRATCH definition"
JS_WHITESPACE = [
    0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
    *range(0x2000, 0x200B),
    0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
]
JS_RUN_RE = re.compile(
    "[" + "".join(re.escape(chr(code)) for code in JS_WHITESPACE) + "]+"
)
PRODUCTION = discrimination.normalize_plan_whitespace
PROBE_TEXTS = {
    "python": "the pinned\n\x85\nitems occupy\n",
    "typescript": "the pinned\n" + chr(0xFEFF) + "\nitems occupy\n",
}
PROBE_PLAN = "\n".join(
    [
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "  - Acceptance: `grep -F -n 'pinned items occupy' docs/design.md` reports one match.",
        "",
    ]
)


def python_native(text):
    return " ".join(text.split())


def typescript_native(text):
    return " ".join(word for word in JS_RUN_RE.split(text) if word)


VARIANTS = {"python": python_native, "typescript": typescript_native}


class CachedGit:
    def __init__(self, inner):
        self._inner = inner
        self._cache = {}

    def _ask(self, name, argument):
        key = (name, argument)
        if key not in self._cache:
            self._cache[key] = getattr(self._inner, name)(argument)
        return self._cache[key]

    def files_containing(self, literal):
        return self._ask("files_containing", literal)

    def is_tracked_file(self, path):
        return self._ask("is_tracked_file", path)

    def is_tracked_directory(self, path):
        return self._ask("is_tracked_directory", path)

    def read_tracked_text(self, path):
        return self._ask("read_tracked_text", path)


class ProbeGit:
    def __init__(self, text):
        self._text = text

    def files_containing(self, literal):
        return ["docs/design.md"] if literal == "pinned" else []

    def is_tracked_file(self, path):
        return False

    def is_tracked_directory(self, path):
        return False

    def read_tracked_text(self, path):
        return self._text


def g1_to_g9(text, context, normalizer):
    discrimination.normalize_plan_whitespace = normalizer
    try:
        report = discrimination.evaluate_plan_gates(text, context=context)
    finally:
        discrimination.normalize_plan_whitespace = PRODUCTION
    return {
        "blocking": [item for item in report.blocking if G10_MARKER not in item],
        "warnings": [item for item in report.warnings if G10_MARKER not in item],
    }


def count(findings):
    return len(findings["blocking"]) + len(findings["warnings"])


def main():
    root = Path.cwd()
    base = discrimination.build_plan_gate_context(root)
    context = discrimination.PlanGateContext(
        workspace_root=base.workspace_root,
        file_system=base.file_system,
        git=CachedGit(base.git),
    )
    probes = {}
    for name, normalizer in VARIANTS.items():
        probe_context = discrimination.PlanGateContext(
            workspace_root=base.workspace_root,
            file_system=base.file_system,
            git=ProbeGit(PROBE_TEXTS[name]),
        )
        after = g1_to_g9(PROBE_PLAN, probe_context, PRODUCTION)
        before = g1_to_g9(PROBE_PLAN, probe_context, normalizer)
        probes[name] = after != before

    plans = sorted(
        path
        for path in (root / "docs").rglob("*.md")
        if path.name.startswith(("plan.", "remediation-plan."))
    )
    rows = {}
    for path in plans:
        text = path.read_text(encoding="utf-8", errors="replace")
        row = {"after": g1_to_g9(text, context, PRODUCTION)}
        for name, normalizer in VARIANTS.items():
            row[name] = g1_to_g9(text, context, normalizer)
        rows[path.relative_to(root).as_posix()] = row
    differing = {
        name: sorted(plan for plan, row in rows.items() if row[name] != row["after"])
        for name in VARIANTS
    }

    print(f"PROBE_PYTHON_DIFFERS: {probes['python']}")
    print(f"PROBE_TYPESCRIPT_DIFFERS: {probes['typescript']}")
    print(f"PLANS_SCANNED: {len(plans)}")
    print(f"PLANS_DIFFERING_PYTHON: {len(differing['python'])}")
    print(f"PLANS_DIFFERING_TYPESCRIPT: {len(differing['typescript'])}")
    print(f"FINDINGS_AFTER: {sum(count(row['after']) for row in rows.values())}")
    print(f"FINDINGS_PYTHON_BEFORE: {sum(count(row['python']) for row in rows.values())}")
    print(
        f"FINDINGS_TYPESCRIPT_BEFORE: {sum(count(row['typescript']) for row in rows.values())}"
    )
    for name in VARIANTS:
        for plan in differing[name]:
            print(f"DIFFERS_{name.upper()}: {plan}")
    Path(sys.argv[1]).write_text(
        json.dumps(rows, indent=2, sort_keys=True), encoding="utf-8"
    )
    clean = all(probes.values()) and not any(differing.values())
    return 0 if clean else 1


if __name__ == "__main__":
    raise SystemExit(main())
```

## Appendix E — Python test and production edits

### E1 — `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py`

```python
# 1. Replace the import line
#        import scripts.dev_tools.plan_gate_scratch as plan_gate_scratch
#    with
import scripts.dev_tools.plan_gate_commands as plan_gate_commands

# 2. In _TYPESCRIPT_MODULE, replace the last path component "plan-gate-scratch.ts"
#    with "plan-gate-commands.ts".

# 3. Add after _WHITESPACE_CLASS_TS_RE:
_PYTHON_DECLARATION_RE = re.compile(r"^PLAN_WHITESPACE_CLASS = ", re.MULTILINE)
_DECLARATION_COUNTS = {
    "scripts/dev_tools/plan_gate_commands.py": 1,
    "scripts/dev_tools/plan_gate_scratch.py": 0,
    "scripts/dev_tools/plan_gate_discrimination.py": 0,
    "extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts": 1,
    "extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts": 0,
    "extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts": 0,
}

# 4. In test_whitespace_class_matches_typescript:
#    - the Arrange line becomes
#          python_class: str = vars(plan_gate_commands)["PLAN_WHITESPACE_CLASS"]
#    - in both assertion messages, "plan-gate-scratch.ts" becomes "plan-gate-commands.ts".

# 5. Add immediately after test_whitespace_class_matches_typescript:


def test_whitespace_class_declared_once_per_runtime() -> None:
    """Each runtime declares the class once, in its command extractor module."""

    # Arrange
    sources = {
        relative: (_REPO_ROOT / relative).read_text(encoding="utf-8")
        for relative in _DECLARATION_COUNTS
    }

    # Act
    counts = {
        relative: len(
            (
                _PYTHON_DECLARATION_RE
                if relative.endswith(".py")
                else _WHITESPACE_CLASS_TS_RE
            ).findall(source)
        )
        for relative, source in sources.items()
    }

    # Assert
    assert counts == _DECLARATION_COUNTS, (
        f"PLAN_WHITESPACE_CLASS declarations differ: {counts}"
    )


# 6. Module docstring: append this paragraph after the paragraph ending
#    "pin the class against shrinking to ASCII.":
#
#    Since remediation cycle 3 the class and its normalizer are declared once
#    per runtime, in `scripts/dev_tools/plan_gate_commands.py` and
#    `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, and G6
#    uses them as well; the declaration-count test pins that location.
```

### E2 — `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`

```python
# Module constants, added after _ACCEPTANCE:
_NEL = "\x85"
_BOM = chr(0xFEFF)
_G5_ABSENT_FINDING = (
    "[P2-T1] search literal `pinned items occupy` is absent from the tracked "
    "tree and is not quoted in the plan; the search returns zero matches "
    "whatever the executor does. Quote the exact literal the task will "
    "create, or assert a literal that exists."
)
_G6_CROSS_LINE_WARNING = (
    "[P2-T1] search literal `pinned items occupy` is present only across "
    "adjacent lines of a tracked file and matches no single line; a "
    "line-oriented search returns zero matches. Search a shorter single-line "
    "token."
)


# Test, added after test_g6_window_split_ignores_form_feed_and_line_separator:
@pytest.mark.parametrize(
    ("tracked_text", "expected"),
    [
        pytest.param(
            "the pinned\n" + _NEL + "\nitems occupy\n",
            _G5_ABSENT_FINDING,
            id="nel-only-line",
        ),
        pytest.param(
            "the pinned\n" + _BOM + "\nitems occupy\n",
            _G5_ABSENT_FINDING,
            id="bom-only-line",
        ),
        pytest.param(
            "the pinned" + _NEL + "items occupy\nthe pinned\nitems occupy\n",
            _G6_CROSS_LINE_WARNING,
            id="nel-joined-line",
        ),
        pytest.param(
            "the pinned" + _BOM + "items occupy\nthe pinned\nitems occupy\n",
            _G6_CROSS_LINE_WARNING,
            id="bom-joined-line",
        ),
    ],
)
def test_g6_normalization_uses_plan_whitespace_class(
    tracked_text: str, expected: str
) -> None:
    """G6 treats NEL and the byte-order mark as ordinary characters.

    Both are outside `PLAN_WHITESPACE_CLASS`, so a line holding only one of
    them is not blank, and a phrase joined by one of them is not on one line.
    The TypeScript suite holds the same four cases. G5 ships on the Warning
    channel, so both expected findings are Warnings.
    """

    # Arrange
    git = StubGitRepository(
        matches={"pinned": ["docs/design.md"]},
        texts={"docs/design.md": tracked_text},
    )
    text = _plan(_ACCEPTANCE)

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert (report.blocking, report.warnings) == ([], [expected])
```

### E3 — `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`

```python
# Module constants, added after _SUPERSEDED_RESIDUAL_SENTENCE:
_G6_WHITESPACE_PHRASES = (
    "declared once per runtime",
    "G6 uses the same class",
    "plan-quotation exoneration, which reads the plan text",
)
_SUPERSEDED_DECLARATION_PHRASE = "identical pattern string in each module"


# Test, added at the end of the file:
def test_rule_file_states_g6_whitespace_alignment() -> None:
    """The rule file states that G6 shares the whitespace class and where it lives."""

    # Arrange
    text = _RULE_FILE.read_text(encoding="utf-8")

    # Act
    missing = [phrase for phrase in _G6_WHITESPACE_PHRASES if phrase not in text]
    stale = _SUPERSEDED_DECLARATION_PHRASE in text

    # Assert
    assert missing == [], f"rule file lacks {missing}"
    assert not stale, f"rule file still states `{_SUPERSEDED_DECLARATION_PHRASE}`"
```

### E4 — `scripts/dev_tools/plan_gate_scratch.py` (after the [P2-T2] move)

```python
# 1. Replace the import line
#        from scripts.dev_tools.plan_gate_commands import split_plan_lines
#    with
from scripts.dev_tools.plan_gate_commands import (
    PLAN_WHITESPACE_CLASS,
    normalize_plan_whitespace,
    split_plan_lines,
)

# 2. Delete the function _normalize_whitespace (its def line, docstring, blank
#    line, and return line) and the two blank lines that follow it, so that
#    `_WHITESPACE_RUN_RE = re.compile(PLAN_WHITESPACE_CLASS + "+")` is followed by
#    two blank lines and `def _continues_logical_line`.

# 3. Replace each of the three calls `_normalize_whitespace(` with
#    `normalize_plan_whitespace(` (in _continues_logical_line, in the walk-loop
#    blank test, and in the logical_line assignment).

# 4. Module docstring: replace the eight lines from
#        "    The runtime import graph stays acyclic. This module imports only the"
#    through
#        "    TypeScript twin. Every finding renders the logical line between backticks; the"
#    with these ten lines:
#    The runtime import graph stays acyclic. This module imports only the
#    shared line splitter, `PLAN_WHITESPACE_CLASS`, and
#    `normalize_plan_whitespace` from `plan_gate_commands` at runtime, and it
#    reads `PlanGateReport` from `plan_gate_discrimination` under
#    `TYPE_CHECKING` only, because `plan_gate_discrimination` imports this
#    module. Physical lines are split on CR LF, LF, and CR only, matching the
#    TypeScript twin. Blank-line, continuation, and normalization tests use
#    `PLAN_WHITESPACE_CLASS`, which G6 also uses and whose pattern string is
#    identical in the TypeScript twin. Every finding renders the logical line
#    between backticks; the
#    (each line keeps the existing four-space docstring indentation; the next
#    existing line, beginning "f-string conversion flag", is unchanged)
```

### E5 — `scripts/dev_tools/plan_gate_discrimination.py`

```python
# 1. Import block from scripts.dev_tools.plan_gate_commands becomes:
from scripts.dev_tools.plan_gate_commands import (
    KIND_GREP,
    PlanCommand,
    extract_plan_commands,
    grep_executable_index,
    normalize_plan_whitespace,
    split_plan_lines,
)


# 2. _window_join becomes:
def _window_join(lines: list[str], size: int = _WINDOW_SIZE) -> list[str]:
    """Return the whitespace-normalised join of each sliding window of lines.

    Whitespace means `PLAN_WHITESPACE_CLASS`, as in the TypeScript `windowJoin`.
    """

    normalized = [normalize_plan_whitespace(line) for line in lines]
    dense = [line for line in normalized if line]
    # One window per start position keeps the boundary exact: lines further
    # apart than `size` never appear in the same join.
    return [" ".join(dense[index : index + size]) for index in range(len(dense))]


# 3. _has_cross_line_presence becomes:
def _has_cross_line_presence(context: PlanGateContext, literal: str) -> bool:
    """Return whether a tracked file carries the literal only across lines.

    Candidate files are located by searching for the literal's first word,
    which stays contiguous on one line however the literal wraps. The literal
    and every tracked line are normalized with `PLAN_WHITESPACE_CLASS`, as in
    the TypeScript `hasCrossLinePresence`.
    """

    needle = normalize_plan_whitespace(literal)
    words = needle.split(" ")
    if len(words) < 2:
        return False

    # A candidate carries the first word on one line: necessary for a wrap.
    for path in context.git.files_containing(words[0]):
        # Split on CR LF, LF, and CR only, as the TypeScript hasCrossLinePresence does.
        lines = split_plan_lines(context.git.read_tracked_text(path))
        if any(needle in normalize_plan_whitespace(line) for line in lines):
            continue
        if any(needle in window for window in _window_join(lines)):
            return True
    return False
```

## Appendix F — TypeScript test and production edits

### F1 — `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (after the [P3-T1] move)

```ts
// 1. Replace the import line
//      import { splitPlanLines } from "./plan-gate-commands";
//    with
import {
  normalizePlanWhitespace,
  PLAN_WHITESPACE_CLASS,
  splitPlanLines,
} from "./plan-gate-commands";

// 2. Delete the TSDoc block beginning "Join runs of `PLAN_WHITESPACE_CLASS`",
//    the function normalizeWhitespace, and the blank line after it, so that
//    `const LEADING_WHITESPACE_RE = ...` is followed by one blank line and the
//    TSDoc of continuesLogicalLine.

// 3. Replace each of the three calls `normalizeWhitespace(` with
//    `normalizePlanWhitespace(` (in continuesLogicalLine, recordIfBare, and the
//    walk-loop blank test).

// 4. Module TSDoc: replace the two Invariants bullets beginning
//    "The module imports only type declarations" and "Blank-line, continuation,
//    and normalization tests use" with:
//  *     - The module imports only type declarations from `plan-gate-rules.ts`
//  *       and the shared line splitter, `PLAN_WHITESPACE_CLASS`, and
//  *       `normalizePlanWhitespace` from `plan-gate-commands.ts`, so the import
//  *       graph stays acyclic.
//  *     - Blank-line, continuation, and normalization tests use
//  *       `PLAN_WHITESPACE_CLASS`, which G6 also uses and whose pattern string
//  *       is identical in the Python module.
```

### F2 — `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts`

```ts
// 1. The ./plan-gate-commands import becomes:
import {
  COV_FLAG,
  COV_FLAG_PREFIX,
  grepExecutableIndex,
  normalizePlanWhitespace,
  type PlanCommand,
} from "./plan-gate-commands";

// 2. normalizeWhitespace TSDoc: after the line "Mirrors Python `" ".join(value.split())`."
//    add the line
//  * Used by the plan-quotation check only; G6 uses `normalizePlanWhitespace`.

// 3. In windowJoin, the dense computation becomes:
  const dense = lines
    .map((line) => normalizePlanWhitespace(line))
    .filter((line) => line !== "");

// 4. In hasCrossLinePresence, the first statements become:
  const needle = normalizePlanWhitespace(literal);
  const words = needle.split(" ");
  if (words.length < 2) {
    return false;
  }
  const firstWord = words[0] ?? "";
//    and the single-line test becomes:
    if (lines.some((line) => normalizePlanWhitespace(line).includes(needle))) {
//    (the split of the tracked text and the window test are unchanged)
```

### F3 — `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`

```ts
  it("normalizes G6 tracked lines with the plan whitespace class", () => {
    // Arrange: NEL is Python-only whitespace and the byte-order mark is
    // JavaScript-only whitespace; the shared class contains neither. G5 ships
    // on the Warning channel, so both expected findings are Warnings.
    const nel = "\x85";
    const bom = String.fromCharCode(0xfeff);
    const trackedTexts = [
      `the pinned\n${nel}\nitems occupy\n`,
      `the pinned\n${bom}\nitems occupy\n`,
      `the pinned${nel}items occupy\nthe pinned\nitems occupy\n`,
      `the pinned${bom}items occupy\nthe pinned\nitems occupy\n`,
    ];
    const absent =
      "[P2-T1] search literal `pinned items occupy` is absent from the " +
      "tracked tree and is not quoted in the plan; the search returns zero " +
      "matches whatever the executor does. Quote the exact literal the task " +
      "will create, or assert a literal that exists.";
    const crossLine =
      "[P2-T1] search literal `pinned items occupy` is present only " +
      "across adjacent lines of a tracked file and matches no single " +
      "line; a line-oriented search returns zero matches. Search a " +
      "shorter single-line token.";

    // Act
    const results = trackedTexts.map((trackedText) => {
      const git = new StubGitRepository(
        { pinned: ["docs/design.md"] },
        { "docs/design.md": trackedText },
      );
      const report = evaluatePlanGates(plan(ACCEPTANCE), context(git));
      return [report.blocking, report.warnings];
    });

    // Assert
    expect(results).toEqual([
      [[], [absent]],
      [[], [absent]],
      [[], [crossLine]],
      [[], [crossLine]],
    ]);
  });
```

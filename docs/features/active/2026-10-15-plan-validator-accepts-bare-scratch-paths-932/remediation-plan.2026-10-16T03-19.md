# plan-validator-accepts-bare-scratch-paths (Remediation Plan, Cycle 2)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T03-19 (remediation cycle 2, initial authoring)
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug. `spec.md` remains the acceptance-criteria source for the item; this cycle's requirements come only from `remediation-inputs.2026-10-16T03-19.md` and the three cycle-1 re-audit artifacts it cites.
- **Branch:** `bug/plan-validator-accepts-bare-scratch-paths-932` (HEAD `fe6f98566` at authoring time, pushed). Base: `main`.
- **Inputs:** `remediation-inputs.2026-10-16T03-19.md`, `policy-audit.2026-10-16T03-15.md`, `code-review.2026-10-16T03-15.md`, `feature-audit.2026-10-16T03-15.md`; prior cycle plan `remediation-plan.2026-10-16T01-52.md`; original plan `plan.2026-10-15T15-45.md`; `spec.md`.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

The directive line above applies to preflight rounds only. After preflight returns `PREFLIGHT: ALL CLEAR`, the orchestrator delegates execution separately.

**Fail-closed evidence rule:** Python and TypeScript each have explicit remediation-baseline tasks, final-QA tasks, and coverage-comparison tasks. If any required baseline, QA, or coverage artifact is missing, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with every required field.

## Cycle Scope

In scope (remediation IDs from `remediation-inputs.2026-10-16T03-19.md`):

- **N-1 (Low).** Decision: both G10 modules use one explicit, identical whitespace class, `PLAN_WHITESPACE_CLASS`, for all three whitespace decisions they make: the blank-line test, the continuation test, and whitespace normalization. Re-derivation against the current tree found all three diverging on the same two classes:
  - Python `scripts/dev_tools/plan_gate_scratch.py`: line 81 (`line.strip()` and `line[:1].isspace()` in `_continues_logical_line`), line 131 (`line.strip()` in the walk loop), line 143 (`str.split` normalization).
  - TypeScript `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`: lines 70-75 (`normalizeWhitespace`, split on the JavaScript whitespace class), line 88 (`line.trim()` and the leading JavaScript whitespace test in `continuesLogicalLine`), line 160 (`line.trim()` in the walk loop).
  - The class is the exact set on which the Python whitespace predicate (`str.isspace`) and the JavaScript whitespace class agree: tab, line feed, vertical tab, form feed, carriage return, space, the Unicode space separators (U+00A0, U+1680, U+2000 to U+200A, U+202F, U+205F, U+3000), and U+2028 and U+2029. NEL (U+0085) and the information separators (U+001C to U+001F) are excluded (Python-only whitespace), and the byte-order mark (U+FEFF) is excluded (JavaScript-only whitespace). Keeping U+2028 and the form feed in the class preserves the cycle-1 frozen fixtures `form-feed` and `line-separator`. Keeping U+00A0 is pinned by new fixtures so the class cannot silently shrink to ASCII.
  - Frozen fixtures (Appendix B) exercise a NEL-led line, a unit-separator-led line (U+001F), a byte-order-mark-led line, a no-break-space-led line, a space-then-NEL line (blank-line test), and the same characters inside a logical line (normalization). They are added to both suites.
  - A Python test asserts that the TypeScript module declares the identical pattern string.
  - The rule-file note, its byte-identical bundle copy, and the `spec.md` NFR-2 note are updated to state the alignment.
  - Re-derivation also found that the fence test (`FENCE_RE`, the command extractor's pattern, leading whitespace in each runtime's native class; `scripts/dev_tools/plan_gate_commands.py:26`, `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:63`, repeated in both G10 modules and pinned equal by `test_fence_pattern_matches_extractor`) diverges for a fence line that begins with NEL, an information separator, or the byte-order mark. That pattern is shared with G1 through G9 and is not named by the inputs, so it is not changed here; the updated rule-file and `spec.md` text states it as the one remaining difference instead of claiming full alignment.
- **N-2 (Info).** Replace the body comment at `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:268-272` so it names the Python `split_plan_lines` instead of the old Python splitter. Comment text only.
- **U-1 (reclassified as related).** Route the tracked-file split in `_has_cross_line_presence` (`scripts/dev_tools/plan_gate_discrimination.py:277`) through `split_plan_lines`, imported from `scripts.dev_tools.plan_gate_commands` in the existing import block (lines 29-34). The result then matches `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts:428`, which is not changed. A parity fixture (form feed and U+2028 inside a tracked file) is added to both suites; the Python case fails before the change. A corpus A/B run (Appendix D) confirms that no G1-G9 result changes on the existing `docs/` plan corpus.

Out of scope (inputs file decisions): U-2 (jest "Coverage data ... was not found" messages; `extensions/drm-copilot/jest.config.cjs` is not edited, concurrent item #543), U-3 (promotion-path prefix in `issue.md`), CR-6 and CR-7 (declined in cycle 1).

Planner observations outside this cycle's stated scope (recorded for an orchestrator decision; not implemented by this plan):

- The fence-pattern difference described under N-1. It is documented by this plan, not fixed.
- The G5 and G6 literal checks in `scripts/dev_tools/plan_gate_discrimination.py` (`_plan_quotes_literal` lines 248-251, `_window_join` line 257, `_has_cross_line_presence` line 278) normalize with `str.split` and `str.strip`. Their TypeScript counterparts in `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` (lines 347, 394, 419, 429) use the JavaScript whitespace class. This is the same divergent-class family as N-1, but in G5 and G6.
- `_plan_structure_errors` in `scripts/dev_tools/validate_orchestration_artifacts.py:145` splits plan text with `str.splitlines`.

## Conventions

- `<FEATURE>` abbreviates `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932`. Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` (kinds used: `remediation-baseline`, `regression-testing`, `qa-gates`, `other`). Every evidence name written in this cycle carries the suffix `-rc2`.
- Evidence artifacts are named `<name>.<timestamp>.md`. The `<timestamp>` is the UTC write time read from the host clock immediately before the write (for example `date -u +%Y-%m-%dT%H-%M`), in the shape `yyyy-MM-ddTHH-mm`. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage-bearing artifacts carry numeric line and branch percentages in `Output Summary:`.
- Scratch location (issue #900 rule):
  - `SCRATCH` resolves to `<session scratchpad>/issue-932/`.
  - Every scratch file this plan names lives under `SCRATCH`, in the subdirectories `SCRATCH/cov/` and `SCRATCH/corpus/`. Nothing is written to the scratchpad root.
  - Evidence and this plan record the literal token `SCRATCH`, never a host path. When pytest, jest, or helper output contains a host path, the executor replaces the scratch prefix with `SCRATCH` and the repository prefix with a repository-relative path before recording it.
  - The untracked `SCRATCH/` directory at the worktree root is orchestrator session state. It is unrelated to the `SCRATCH` token above. It is never staged and never deleted by this plan.
- `<MERGE_BASE>` is the merge-base SHA and `<RC2_BASE>` is the HEAD SHA. [P0-T3] records both in the latest `<FEATURE>/evidence/remediation-baseline/git-baseline-rc2.*.md`. If the branch is rebased later, the executor re-derives `<MERGE_BASE>` with `git merge-base origin/main HEAD` and records the new value in the consuming artifact.
- TypeScript commands run with `extensions/drm-copilot/` as the working directory. Python and git commands run at the repository root.
- Python check-mode commands only: `black --check` and `ruff check --no-fix`. Write-mode formatting is permitted only inside the remediation branch of a check task and is followed by a loop restart.
- Commits: `git add` names each file or evidence folder explicitly. No force push. No file is deleted. No issue is created. No pull request is opened. A related finding discovered during execution is fixed inside this item; a completely unrelated finding is recorded in `<FEATURE>/evidence/other/unrelated-findings-rc2.<timestamp>.md`.
- Known local failure (#510): `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` can fail locally because of gitignored state. Locally, only that node is accepted as a failure, and only when its failure message names a gitignored path that is absent from the bundle. Any other failure in that file is a real failure. CI is the authority for that node (AC-23 stays unchecked until CI runs it).
- PowerShell and bats are not in scope. Pester is not run by this plan.
- Agent-worktree command routes: the worktree isolation guard refuses command text containing three shell-host words (the POSIX shell name, the PowerShell 7 executable name, and the Linux-subsystem launcher name), so no task in this plan names them. File copying uses `cp` or the Read-plus-Write fallback; timestamps use `date -u`.
- npm dependencies: `extensions/drm-copilot/node_modules/` was present at planning time. If the Glob tool finds no `extensions/drm-copilot/node_modules/jest/package.json` when [P0-T5] starts, the executor stops with `BLOCKED: node_modules absent` and reports to the caller.
- Raw-character rule: every new or changed test file and both G10 modules write NEL, the information separators, the byte-order mark, the no-break space, the form feed, and U+2028 as escapes, never as raw characters. The zero-count check uses the Grep tool, output mode count, with the pattern [\x0b\x0c\x1c-\x1f\x{85}\x{a0}\x{1680}\x{2000}-\x{200a}\x{2028}\x{2029}\x{202f}\x{205f}\x{3000}\x{feff}] and must return 0 for each checked file. The pattern covers every whitespace-class member outside tab, line feed, carriage return, and space, because a Write call can store a `u`-form escape as the raw character. It returned 0 on every current `plan_gate_*`, `plan-gate-*`, and `test_plan_gate_*` file at planning time.
- Jest per-case output: Jest 30 prints only totals when the `CLAUDECODE` environment variable is set. Any jest command whose acceptance quotes per-case lines therefore passes `--reporters=default` after the test paths, which restores the `--verbose` per-case lines.
- Tool-layer escape hazard (observed while authoring this plan): a Write or Edit tool parameter that contains a backslash followed by `u` and four hexadecimal digits was stored as the decoded raw character, not as the six-character escape. The `\x85`, `\x1f`, and `\xa0` forms were stored verbatim. To store a `u`-form escape, first write the backslash and `u` followed by a non-hexadecimal marker (for example `QQ1`). Then replace the marker text with the four hexadecimal digits in a second edit whose old and new strings contain no backslash. The raw-character zero-count check confirms the result.
- Out-of-scope remediation log: whenever a task edits a repository file that is not in the WRITES list of this plan, the executor writes `<FEATURE>/evidence/other/out-of-scope-remediation-rc2.<timestamp>.md`. It carries `Timestamp:`, the triggering task ID, one `PATH: ` line per edited repository-relative path, and a one-line reason per path. Those paths are staged in the commit of the phase that edited them.

## Fixture Rule for This Plan

This plan must pass G10. It therefore quotes no bare SCRATCH definition outside a fenced block. Every new test fixture that contains definition text is listed in Appendix B (fenced), and the tasks refer to each fixture by its id.

### Phase 0 — Policy Reads and Remediation Baselines

All Phase 0 commands are read-only check modes. No write-mode formatter runs in this phase. All artifacts go to `<FEATURE>/evidence/remediation-baseline/`.

- [x] [P0-T1] Read the policy files in policy-compliance order and record them in `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read-rc2.<timestamp>.md`
  - Files, in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and a list naming all nine files in that order.
- [x] [P0-T2] Read the cycle inputs and record them in `<FEATURE>/evidence/remediation-baseline/remediation-inputs-read-rc2.<timestamp>.md`
  - Files: `<FEATURE>/remediation-inputs.2026-10-16T03-19.md`, `<FEATURE>/policy-audit.2026-10-16T03-15.md`, `<FEATURE>/code-review.2026-10-16T03-15.md`, `<FEATURE>/feature-audit.2026-10-16T03-15.md`.
  - Acceptance: the artifact carries `Timestamp:` and lists the four files. It lists the in-scope IDs `N-1`, `N-2`, and `U-1`, and the declined IDs `U-2`, `U-3`, `CR-6`, and `CR-7`, each with the reason stated in Cycle Scope.
- [x] [P0-T3] Record the git baseline in `<FEATURE>/evidence/remediation-baseline/git-baseline-rc2.<timestamp>.md`
  - Commands: `git fetch origin main`, `git rev-parse HEAD`, `git merge-base origin/main HEAD`, `git status --porcelain`.
  - Acceptance: each command records `EXIT_CODE: 0`. The artifact records the HEAD SHA under the label `RC2_BASE:` and the merge-base SHA under the label `MERGE_BASE:`. The porcelain output lists no path other than `SCRATCH/` and `<FEATURE>/remediation-plan.2026-10-16T03-19.md`; either may be absent.
- [x] [P0-T4] Create the scratch subdirectories `SCRATCH/cov/` and `SCRATCH/corpus/` and record them in `<FEATURE>/evidence/remediation-baseline/scratch-setup-rc2.<timestamp>.md`
  - Method: the Write tool writes `SCRATCH/cov/README.txt` and `SCRATCH/corpus/README.txt`, each with the one-line content `Issue 932 remediation cycle 2 scratch directory; not committed.`. `SCRATCH` is resolved to its absolute path for the tool calls only.
  - Acceptance: the Glob tool with pattern `*/README.txt`, rooted at the resolved `SCRATCH` directory, returns both files. The artifact records the method and the relative results using the token `SCRATCH` only.
- [x] [P0-T5] Capture the TypeScript format baseline in `<FEATURE>/evidence/remediation-baseline/ts-format-baseline-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `Output Summary:` quotes either `All matched files use Prettier code style!` or the list of files reported with warnings, and records the observed exit code.
- [x] [P0-T6] Capture the TypeScript lint baseline in `<FEATURE>/evidence/remediation-baseline/ts-lint-baseline-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `Output Summary:` records the error and warning counts (no output on a clean run is recorded as `0 errors, 0 warnings`).
- [x] [P0-T7] Capture the TypeScript production type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-baseline-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count (no output on success).
- [x] [P0-T8] Capture the TypeScript test type-check baseline in `<FEATURE>/evidence/remediation-baseline/ts-typecheck-test-baseline-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `Output Summary:` records the diagnostic count.
- [x] [P0-T9] Capture the full jest coverage baseline in `<FEATURE>/evidence/remediation-baseline/ts-coverage-baseline-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `Output Summary:` records:
    - the suite and test pass/fail counts and the `text-summary` totals;
    - every failing suite and any coverage-threshold message;
    - the `lines.pct` and `branches.pct` values for `src/lib/validate/plan-gate-scratch.ts`, `src/lib/validate/plan-gate-commands.ts`, and `src/lib/validate/plan-gate-rules.ts`, read from `extensions/drm-copilot/coverage/coverage-summary.json`.
- [x] [P0-T10] Capture the Python format baseline in `<FEATURE>/evidence/remediation-baseline/python-format-baseline-rc2.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the black summary line (for example `4 files would be left unchanged.`) and records the observed exit code.
- [x] [P0-T11] Capture the Python lint baseline in `<FEATURE>/evidence/remediation-baseline/python-lint-baseline-rc2.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes either `All checks passed!` or the diagnostic count.
- [x] [P0-T12] Capture the Python type-check baseline in `<FEATURE>/evidence/remediation-baseline/python-typecheck-baseline-rc2.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `Output Summary:` quotes the pyright summary line (`N errors, N warnings, N informations`).
- [x] [P0-T13] Capture the Python coverage baseline for `scripts.dev_tools.plan_gate_scratch` and `scripts.dev_tools.plan_gate_discrimination` in `<FEATURE>/evidence/remediation-baseline/python-coverage-baseline-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py-rc2.json`
  - Acceptance: `Output Summary:` records:
    - the total `passed` and `failed` counts from the final pytest summary line;
    - the `term-missing` rows for `plan_gate_scratch.py` and `plan_gate_discrimination.py`;
    - for each of those two files, the numeric line coverage (`covered_lines / num_statements`) and branch coverage (`covered_branches / num_branches`), read from its `summary` object in `SCRATCH/cov/baseline-py-rc2.json`.
- [x] [P0-T14] Capture the broad dev-tools regression baseline in `<FEATURE>/evidence/remediation-baseline/python-devtools-baseline-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: `Output Summary:` records the pass/fail/error/skip counts and lists every failing or erroring node ID (the reference set for [P5-T6]).
- [x] [P0-T15] Commit and push the Phase 0 evidence under `<FEATURE>/evidence/remediation-baseline/` with this plan file
  - Commands: `git add <FEATURE>/evidence/remediation-baseline <FEATURE>/remediation-plan.2026-10-16T03-19.md` (with the concrete folder path), `git commit -m "docs(932): record remediation cycle 2 baselines"`, `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 1 — Red Tests

Static checks for the files written in this phase are deferred to Phase 2 (Python) and Phase 3 (TypeScript). No test in this phase imports a symbol that does not yet exist: the Python whitespace-class parity test reads the constant through `vars()` at run time, and no TypeScript test imports the new constant. No task in this phase runs a test node that a later phase makes pass, except the two `[expect-fail]` runs.

- [x] [P1-T1] Create `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` (N-1)
  - Module docstring: states that the file pins the G10 whitespace class shared with `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`, issue #932 remediation cycle 2.
  - Imports: `re`, `Path`, `pytest`, the module `scripts.dev_tools.plan_gate_scratch` (as `plan_gate_scratch`), and `bare_scratch_definitions` from it.
  - Module constants:
    - the TypeScript module path (`extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`, built from the repository root as in `test_plan_gate_scratch.py`);
    - the pattern `PLAN_WHITESPACE_CLASS\s*=\s*String\.raw` followed by a backtick-delimited capture group of non-backtick characters, compiled as `_WHITESPACE_CLASS_TS_RE`;
    - `_DEFINITION_LINE`, and the two fixture tuples `_CONTINUATION_FIXTURES` and `_NORMALIZATION_FIXTURES`, exactly as listed in Appendix B with the listed pytest ids.
  - `test_whitespace_class_matches_typescript`:
    - Arrange: first reads the Python constant with `vars(plan_gate_scratch)["PLAN_WHITESPACE_CLASS"]` (annotated `str`), then reads the TypeScript source.
    - Act: searches the source with `_WHITESPACE_CLASS_TS_RE`.
    - Assert: the match is not `None`, with a message naming the constant, and the captured group equals the Python constant. Final assertion: the captured TypeScript class string satisfies `.isascii()`, with an assertion message naming `PLAN_WHITESPACE_CLASS`. The expected red signature in [P1-T6] does not change, because the `KeyError` is raised in Arrange.
  - `test_continuation_uses_plan_whitespace_class`: parametrized over `_CONTINUATION_FIXTURES`; asserts `bare_scratch_definitions(text) == [expected]`.
  - `test_normalization_uses_plan_whitespace_class`: parametrized over `_NORMALIZATION_FIXTURES`; asserts `bare_scratch_definitions(text) == [expected]`.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the new file with the pattern `^def (test_whitespace_class_matches_typescript|test_continuation_uses_plan_whitespace_class|test_normalization_uses_plan_whitespace_class)\(` returns exactly 3.
    - The Grep tool, output mode `count`, with pattern `id="(nel-led|unit-separator-led|bom-led|nbsp-led|space-then-nel|nel-inline|unit-separator-inline|bom-inline|nbsp-inline)"` returns exactly 9.
    - The line count (Grep pattern `^`, output mode `count`) is at most 500.
    - The raw-character zero-count check in Conventions returns 0.
    - The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T2] Add the U-1 parity test to `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`
  - Add `test_g6_window_split_ignores_form_feed_and_line_separator`, parametrized over the two Appendix B tracked-text cases (ids `form-feed` and `line-separator`).
    - Arrange: a `StubGitRepository` with `matches={"pinned": ["docs/design.md"]}` and `texts={"docs/design.md": <case text>}`, and the plan `_plan(_ACCEPTANCE)`.
    - Act: `evaluate_plan_gates(text, context=_context(git))`.
    - Assert: `_channel(report)` equals a one-element list holding the frozen G5 string in Appendix B, and `_other_channel(report) == []`.
  - Structural rules: Arrange–Act–Assert comments; no temporary files; file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file with the pattern `^def test_g6_window_split_ignores_form_feed_and_line_separator\(` returns exactly 1.
    - The line count is at most 500.
    - The raw-character zero-count check returns 0.
    - The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T3] Update the rule-file documentation tests in `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` (N-1)
  - Remove the element `"One parity residual remains"` from `_G10_LINE_RULE_PHRASES` (line 60); the other three elements are unchanged.
  - Add the module constants:
    - `_WHITESPACE_ALIGNMENT_PHRASES`, holding the three tokens `share one explicit whitespace class`, `` `PLAN_WHITESPACE_CLASS` `` (backticks included), and `keeps the command extractor's fence pattern`;
    - `_SUPERSEDED_RESIDUAL_SENTENCE = "One parity residual remains"`.
  - Add `test_rule_file_states_g10_whitespace_alignment`: reads `.claude/rules/plan-acceptance-gates.md`, asserts that every `_WHITESPACE_ALIGNMENT_PHRASES` token is present and that `_SUPERSEDED_RESIDUAL_SENTENCE` is absent, and reports the missing or stale token in the failure message.
  - Structural rules: Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns exactly 1 for the pattern `^def test_rule_file_states_g10_whitespace_alignment\(`.
    - It returns exactly 1 for the pattern `One parity residual remains` (the superseded constant only).
    - The Grep tool with pattern `^`, output mode `count`, on the file returns at most 500 (169 before this task).
    - The counts are recorded in the [P1-T6] artifact.
- [x] [P1-T4] Add the N-1 cases to `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`
  - Inside the existing `describe("plan-gate-scratch G10", ...)` block (line 163), after the case `does not end a physical line at a form feed or a line separator`, add two cases. Each uses the TypeScript escapes in Appendix B and the existing `DEFINITION_LINE` constant (line 67):
    - `it("decides continuation with the plan whitespace class", ...)`: maps the five continuation fixtures through `bareScratchDefinitions` and compares the array of results to the array of their frozen findings, each wrapped in a one-element array.
    - `it("normalizes whitespace with the plan whitespace class", ...)`: the same for the four normalization fixtures.
  - Structural rules:
    - plain `it("<literal title>", ...)` calls only (no `it.each`, no `test(`);
    - no import of a new symbol;
    - Arrange–Act–Assert comments;
    - file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for each of the patterns `it\("decides continuation with the plan whitespace class"` and `it\("normalizes whitespace with the plan whitespace class"`.
    - It returns 0 for the pattern `it\.each|^\s*test\(` and 0 for the pattern `PLAN_WHITESPACE_CLASS`.
    - The Grep tool with pattern `^`, output mode `count`, on the file returns at most 500 (385 before this task).
    - The raw-character zero-count check returns 0.
    - The counts are recorded in the [P1-T7] artifact.
- [x] [P1-T5] Add the U-1 parity case to `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`
  - Inside `describe("evaluatePlanGates search literals", ...)` (line 90) add `it("treats a form feed or line separator in a tracked file as part of one line", ...)`.
    - Arrange: for each of the two Appendix B tracked-text cases (TypeScript escapes), builds `new StubGitRepository({ pinned: ["docs/design.md"] }, { "docs/design.md": <case text> })`.
    - Act: evaluates `plan(ACCEPTANCE)` once per case.
    - Assert: compares the array of `[channel(report), otherChannel(report)]` pairs to two copies of `[[<frozen G5 string>], []]`.
  - Structural rules: plain `it(...)` only; Arrange–Act–Assert comments; file at most 500 lines.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 1 for the pattern `it\("treats a form feed or line separator in a tracked file as part of one line"` and 0 for the pattern `it\.each|^\s*test\(`.
    - The Grep tool with pattern `^`, output mode `count`, on the file returns at most 500 (283 before this task).
    - The raw-character zero-count check returns 0.
    - The counts are recorded in the [P1-T7] artifact.
- [x] [P1-T6] [expect-fail] Run the Python red set and record `<FEATURE>/evidence/regression-testing/python-red-rc2.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Expected failures, nine nodes:
    - `test_whitespace_class_matches_typescript`, with `KeyError: 'PLAN_WHITESPACE_CLASS'`.
    - `test_continuation_uses_plan_whitespace_class[nel-led]`, `[unit-separator-led]`, and `[space-then-nel]`. Python currently treats NEL and U+001F as whitespace and treats a space-then-NEL line as blank; Appendix B lists the current results.
    - `test_normalization_uses_plan_whitespace_class[nel-inline]` and `[unit-separator-inline]`.
    - `test_g6_window_split_ignores_form_feed_and_line_separator[form-feed]` and `[line-separator]`. The current split yields the G6 cross-line warning instead of the G5 finding.
    - `test_rule_file_states_g10_whitespace_alignment`.
  - Expected passes:
    - `test_continuation_uses_plan_whitespace_class[bom-led]` and `[nbsp-led]`;
    - `test_normalization_uses_plan_whitespace_class[bom-inline]` and `[nbsp-inline]`;
    - every pre-existing test in the three files, including `test_rule_file_documents_g10_line_rules_and_issue_token_class`.
  - Acceptance:
    - The artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
    - It records `ExpectedExitCode:`, set to the observed exit code only when the failing nodes are exactly the nine expected nodes with the stated signatures.
    - `Output Summary:` names each failing node with its first error line and each expected-pass node, as printed by the `-v` per-node lines.
    - The artifact also records the Grep counts from [P1-T1], [P1-T2], and [P1-T3].
    - Any unexpected signature halts the task for a plan revision.
- [x] [P1-T7] [expect-fail] Run the TypeScript red set and record `<FEATURE>/evidence/regression-testing/ts-red-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --verbose test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-discrimination-literals.test.ts --reporters=default`
  - Expected failures, two cases:
    - `decides continuation with the plan whitespace class`: the `bom-led` element differs because the JavaScript whitespace class currently continues a line led by the byte-order mark.
    - `normalizes whitespace with the plan whitespace class`: the `bom-inline` element differs.
  - Expected passes: `treats a form feed or line separator in a tracked file as part of one line` (TypeScript already splits on CR LF, LF, and CR), and every pre-existing case in both files.
  - Acceptance:
    - The artifact records `EXIT_CODE: 1` and `ExpectedExitCode: 1`.
    - `Output Summary:` names the two failing cases with their first differing element, and quotes the verbose passing line of the U-1 case.
    - The artifact also records the Grep counts from [P1-T4] and [P1-T5].
    - Any other failure halts the task for a plan revision.
- [x] [P1-T8] Commit and push the Phase 1 test changes, the `<FEATURE>/evidence/regression-testing/` red artifacts, and the plan check-offs
  - Commands: `git add tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts` plus the two red artifacts and this plan file, `git commit -m "test(932): add remediation cycle 2 red tests for the whitespace class and the G6 split"`, `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 2 — Python Implementation (N-1, U-1)

- [x] [P2-T1] Apply the whitespace class to `scripts/dev_tools/plan_gate_scratch.py` (N-1)
  - Add the comment, `PLAN_WHITESPACE_CLASS`, `_WHITESPACE_RUN_RE`, and `_normalize_whitespace` exactly as in Appendix C, placed immediately after the `_NAMESPACE_RE` line (line 69).
  - Replace the first condition of `_continues_logical_line` (line 81) with the Appendix C condition, and append the Appendix C sentence to its docstring.
  - Replace the blank test at line 131 with `if in_fence or not _normalize_whitespace(line):`.
  - Replace the normalization at line 143 with `logical_line = _normalize_whitespace(" ".join(parts))`.
  - Insert the Appendix C module-docstring sentence after the sentence ending `matching the TypeScript twin.` (line 21).
  - No other line changes.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `\.isspace\(|\.strip\(|\.split\(\)`. Before this task it returns 3, at lines 81, 131, and 143.
    - It returns 1 for the pattern `^PLAN_WHITESPACE_CLASS = ` and 1 for the pattern `^def _normalize_whitespace\(`.
    - The raw-character zero-count check in Conventions returns 0 for the file.
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_scratch.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript` exits 0 with 0 failed. The deselected parity node reads the TypeScript constant, which [P3-T1] adds; [P3-T5] runs it.
- [x] [P2-T2] Route the G6 tracked-file split through `split_plan_lines` in `scripts/dev_tools/plan_gate_discrimination.py` (U-1)
  - Add `split_plan_lines` as the last name in the `from scripts.dev_tools.plan_gate_commands import (...)` block (lines 29-34).
  - Replace line 277 with `lines = split_plan_lines(context.git.read_tracked_text(path))`, preceded by the one-line comment `# Split on CR LF, LF, and CR only, as the TypeScript hasCrossLinePresence does.`.
  - No other line changes. The module must look the splitter up as a module global so the Appendix D A/B helper can substitute it.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `read_tracked_text\(path\)\.splitlines\(` (1 before this task, at line 277).
    - It returns 1 for the pattern `split_plan_lines\(context\.git\.read_tracked_text\(path\)\)` and 1 for the pattern `^    split_plan_lines,`.
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` exits 0 with 0 failed.
- [x] [P2-T3] Run the Python green set with coverage and record `<FEATURE>/evidence/regression-testing/python-green-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py --deselect=tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing`
  - Acceptance:
    - `EXIT_CODE: 0` and 0 failed; the pytest summary line reports 1 deselected.
    - `Output Summary:` records the pass count and the `term-missing` rows for both files.
    - The `plan_gate_scratch.py` row shows `100%` with an empty `Missing` column.
- [x] [P2-T4] Run the G1-G9 corpus A/B check for U-1 and record `<FEATURE>/evidence/regression-testing/g1-g9-corpus-ab-rc2.<timestamp>.md`
  - Method: the Write tool writes `SCRATCH/corpus/g1_g9_splitter_ab.py` with the exact content of Appendix D, with `SCRATCH` resolved for the tool call only. Then, at the repository root, run `poetry run python SCRATCH/corpus/g1_g9_splitter_ab.py SCRATCH/corpus/g1-g9-splitter-ab.json`. The executor runs this command with a 600000 ms tool timeout.
  - The helper evaluates every `plan.*.md` and `remediation-plan.*.md` file under `docs/` twice, against one memoized production git seam: once with the production splitter, and once with `str.splitlines` substituted into `plan_gate_discrimination`. It drops G10 findings and compares the G1-G9 Blocking and Warning lists per file. A built-in probe, a stub tracked file containing a form feed, must differ between the two passes, which shows that the substitution took effect.
  - Acceptance:
    - `EXIT_CODE: 0`.
    - `Output Summary:` quotes the printed lines `PROBE_DIFFERS: True` and `PLANS_DIFFERING: 0`, and the `PLANS_SCANNED:`, `FINDINGS_BEFORE:`, and `FINDINGS_AFTER:` lines.
    - `PLANS_SCANNED` is at least 100, and `FINDINGS_BEFORE` equals `FINDINGS_AFTER`.
    - A `DIFFERS:` line, `PROBE_DIFFERS: False`, or a non-zero exit halts the task for a plan revision.
- [x] [P2-T5] Run the Python plan-gate regression suites and record `<FEATURE>/evidence/regression-testing/python-plan-gate-regression-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance:
    - `EXIT_CODE: 1` with exactly one failure, `test_rule_file_states_g10_whitespace_alignment`, because the rule file changes in Phase 4. `ExpectedExitCode: 1` is recorded only in that case.
    - `Output Summary:` records the pass count and names the single failing node.
    - Any other failure halts the task.
- [x] [P2-T6] Run the Python format check on the five Python files and record `<FEATURE>/evidence/regression-testing/python-format-rc2.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary line `5 files would be left unchanged.`
  - Remediation branch: run `poetry run black scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`, record its `reformatted` and `left unchanged` summary, then rerun from [P2-T3].
- [x] [P2-T7] Run the Python lint check on the same five files and record `<FEATURE>/evidence/regression-testing/python-lint-rc2.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the output line `All checks passed!`. Any suppression added follows `.claude/rules/python-suppressions.md`.
- [x] [P2-T8] Run the Python strict type check on the same five files and record `<FEATURE>/evidence/regression-testing/python-typecheck-rc2.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and the summary `0 errors`.
- [x] [P2-T9] Commit and push `scripts/dev_tools/plan_gate_scratch.py`, `scripts/dev_tools/plan_gate_discrimination.py`, the evidence, and the plan check-offs
  - Commands: `git add scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py` plus any file reformatted in [P2-T6], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): share one whitespace class in Python G10 and split G6 tracked text on CR LF only"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 3 — TypeScript Implementation (N-1, N-2)

- [x] [P3-T1] Apply the whitespace class to `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` (N-1)
  - Add the TSDoc, `PLAN_WHITESPACE_CLASS`, `WHITESPACE_RUN_RE`, and `LEADING_WHITESPACE_RE` exactly as in Appendix E, placed immediately after the `NAMESPACE_RE` line (line 62).
  - Replace `normalizeWhitespace` and its TSDoc (lines 64-75) with the Appendix E version.
  - Replace the condition at line 88 with the Appendix E condition, and append the Appendix E sentence to the `continuesLogicalLine` TSDoc.
  - Replace the blank test at line 160 with `if (inFence || normalizeWhitespace(line) === "") {`.
  - Add the Appendix E bullet to the module TSDoc invariants (after line 21).
  - No other line changes.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `\.trim\(\)` (2 before this task, at lines 88 and 160) and 0 for the pattern `split\(/` (1 before, at line 72).
    - It returns 1 for the pattern `^export const PLAN_WHITESPACE_CLASS = String\.raw` and 1 for the pattern `LEADING_WHITESPACE_RE\.test\(line\)`.
    - The raw-character zero-count check in Conventions returns 0 for the file.
    - `npx tsc -p ./ --noEmit` exits 0.
    - `npx jest --config jest.config.cjs test/lib/validate/plan-gate-scratch.test.ts` exits 0.
- [x] [P3-T2] Replace the stale splitter comment in `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` (N-2)
  - Replace the five comment lines 268-272 inside `splitPlanLines` with the five lines in Appendix E (section N-2). No code line changes.
  - Acceptance:
    - The Grep tool, output mode `count`, on the file returns 0 for the pattern `str\.splitlines` (1 before this task, at line 268).
    - It returns 2 for the pattern `split_plan_lines` (1 before, at line 257).
    - The file is at most 500 lines.
- [x] [P3-T3] Run the TypeScript format check on the four changed TypeScript files and record `<FEATURE>/evidence/regression-testing/ts-format-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-commands.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-discrimination-literals.test.ts`
  - Acceptance: `EXIT_CODE: 0` and the line `All matched files use Prettier code style!`.
  - Remediation branch: run `npx prettier --write` over the reported paths, record each path it reports as `(unchanged)` or rewritten, then rerun from [P3-T3].
- [x] [P3-T4] Run the TypeScript lint check on the same four files and record `<FEATURE>/evidence/regression-testing/ts-lint-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint src/lib/validate/plan-gate-scratch.ts src/lib/validate/plan-gate-commands.ts test/lib/validate/plan-gate-scratch.test.ts test/lib/validate/plan-gate-discrimination-literals.test.ts`
  - Acceptance: `EXIT_CODE: 0` with no reported problem line. Any suppression follows `.claude/rules/typescript-suppressions.md`.
- [x] [P3-T5] Run both TypeScript type checks, the validate test directory, and the Python whitespace-class parity node, and record `<FEATURE>/evidence/regression-testing/ts-green-rc2.<timestamp>.md` (TypeScript commands in `extensions/drm-copilot/`, the pytest command at the repository root)
  - Commands: `npx tsc -p ./ --noEmit`, `npx tsc -p tsconfig.jest.json --noEmit`, `npx jest --config jest.config.cjs --verbose test/lib/validate --reporters=default`, `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py::test_whitespace_class_matches_typescript`.
  - Acceptance:
    - All four exit 0, and the pytest command reports 1 passed.
    - `Output Summary:` records the jest suite and test pass counts and 0 failed.
    - It quotes the verbose passing lines for `decides continuation with the plan whitespace class`, `normalizes whitespace with the plan whitespace class`, `treats a form feed or line separator in a tracked file as part of one line`, and `does not end a physical line at a form feed or a line separator`.
- [x] [P3-T6] Commit and push `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` and `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`, the evidence, and the plan check-offs
  - Commands: `git add extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` plus any file rewritten in [P3-T3], the new `<FEATURE>/evidence/regression-testing/` artifacts, and this plan file; `git commit -m "fix(932): share one whitespace class in TypeScript G10 and name split_plan_lines in the splitter comment"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 4 — Rule File and Specification Text (N-1)

Every sentence quoted in this phase is inserted verbatim as part of one line of the target file. The rule file does not hard-wrap prose.

- [x] [P4-T1] Replace the parity-residual sentence in `.claude/rules/plan-acceptance-gates.md` (line 153)
  - On line 153, keep the first two sentences unchanged: the one beginning `A continuation line is non-blank` and the one beginning `Both runtimes split the document`.
  - Replace the third sentence, which begins `One parity residual remains:` and runs to the end of the line, with these three sentences, in order and on the same line:
    - `Both runtimes share one explicit whitespace class for the blank-line test, the continuation test, and whitespace normalization, declared as PLAN_WHITESPACE_CLASS with an identical pattern string in each module: tab, line feed, vertical tab, form feed, carriage return, space, the Unicode space separators, and the Unicode line and paragraph separators.`
    - `NEL, the information separators, and the byte-order mark are outside that class, so in both runtimes a line that begins with one of them ends the logical line, and the character is kept verbatim in the normalized text.`
    - `The fence test keeps the command extractor's fence pattern, whose leading whitespace is each runtime's native class, so a fence line that begins with NEL, an information separator, or the byte-order mark can be recognized differently by the two runtimes, for G1 through G9 as well as for G10.`
  - In the file, `PLAN_WHITESPACE_CLASS` is written between backticks. The apostrophes are ASCII.
  - No literal bare SCRATCH definition is added outside a fenced block. No other line changes.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_states_g10_whitespace_alignment tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10_line_rules_and_issue_token_class tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` exits 0 with 3 passed.
- [x] [P4-T2] Copy the rule file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
  - Command (repository root): `cp .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`. Fallback when the tool layer refuses `cp`: read the source with the Read tool and write the identical content to the destination with the Write tool.
  - Acceptance:
    - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical` exits 0 with 1 passed.
    - `git hash-object .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` prints two equal object IDs, which are recorded in the [P4-T4] artifact.
- [x] [P4-T3] Update the detection contract and the NFR-2 note in `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md`
  - After item 5 of `### Logical lines` (line 70), add item 6: `6. The blank-line test, the continuation test, and whitespace normalization use one explicit whitespace class, PLAN_WHITESPACE_CLASS, with an identical pattern string in both runtimes: tab, line feed, vertical tab, form feed, carriage return, space, the Unicode space separators, and the Unicode line and paragraph separators. NEL, the information separators, and the byte-order mark are not whitespace for these tests. The fence test keeps the command extractor's pattern (item 1) (remediation cycle 2).`
  - Replace the NFR-2 sub-bullet at line 211 with: `  - Remediation cycle 1 and 2 note: line splitting is aligned on the CR LF, LF, and CR terminators in both runtimes, in the command extractor, and in the G6 cross-line check (cycle 2). The blank-line test, the continuation test, and whitespace normalization share one explicit whitespace class, PLAN_WHITESPACE_CLASS, with an identical pattern string in both runtimes (cycle 2), so NEL, the information separators, and the byte-order mark no longer produce different G10 results. The fence test keeps the command extractor's fence pattern, whose leading whitespace is each runtime's native class; that difference is shared with G1 through G9 and is documented in .claude/rules/plan-acceptance-gates.md.`
  - Replace item 4 of `### Logical lines` (line 69) with: `4. The logical line is normalized for matching and for the message by joining each run of the shared whitespace class defined in item 6 with a single space and trimming the ends. The continuation test in item 2 uses the same class, and both runtimes declare that class with an identical pattern string, so they produce byte-identical text.`
  - Replace the risk-table row at line 226, which begins `| Whitespace normalization differs`, with: `| G10 whitespace handling could differ between runtimes because the Python and JavaScript native whitespace classes differ on NEL, the information separators, and the byte-order mark. | G10 normalizes whitespace and detects continuation with one explicit shared whitespace class (detection contract item 6), declared with an identical pattern string in both runtimes and pinned by a parity test; frozen fixtures cover NEL, the unit separator (U+001F), the byte-order mark, and the no-break space. |`
  - In the file, `PLAN_WHITESPACE_CLASS` and the rule-file path are written between backticks. Item 6 and the NFR-2 replacement each name `PLAN_WHITESPACE_CLASS` once; the item 4 and risk-row replacements do not name it, so the count is 2.
  - No acceptance-criterion checkbox in `spec.md` changes.
  - Acceptance:
    - The Grep tool, output mode `count`, on `spec.md` returns 2 for the pattern `PLAN_WHITESPACE_CLASS` (0 before this task).
    - The Grep tool, output mode `count`, on `spec.md` returns 0 for the pattern `windowJoin` (2 before this task, at lines 69 and 226).
    - It returns 1 for the pattern `Remediation cycle 1 and 2 note` and 0 for the pattern `One residual difference remains` (1 before, at line 211).
    - The count for the pattern `^- \[x\] ` is 31 and the count for the pattern `^- \[ \] ` is 1, both unchanged from before the edit.
  - Line numbers in this task are pre-edit values; after item 6 is inserted, locate the NFR-2 sub-bullet by the text `Remediation cycle 1 note` and the risk row by the text `| Whitespace normalization differs`.
- [x] [P4-T4] Run the documentation, contract, push-down, and frontmatter suites and record `<FEATURE>/evidence/regression-testing/docs-green-rc2.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
  - Acceptance: 0 failed, or exactly one failure that is the #510 node with the #510 signature described in Conventions. The artifact records which case applies and the two object IDs from [P4-T2].
- [x] [P4-T5] Commit and push `.claude/rules/plan-acceptance-gates.md`, its bundle copy, `spec.md`, the evidence, and the plan check-offs
  - Commands: `git add .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md <FEATURE>/spec.md` (with the concrete folder path) plus the new evidence and this plan file; `git commit -m "docs(932): state the shared G10 whitespace class in the rule file and spec"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

### Phase 5 — Final QA Loop

Loop rule: [P5-T1] through [P5-T11] form one pass. If any of them fails or changes a file, fix the cause, commit the fix, and restart at [P5-T1]. Each pass writes new artifacts with new timestamps. The loop ends only when one pass completes with every step meeting its acceptance and no file change.

- [x] [P5-T1] Run the final Python format check and record `<FEATURE>/evidence/qa-gates/python-format-final-rc2.<timestamp>.md`
  - Command: `poetry run black --check scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `5 files would be left unchanged.`
  - Remediation branch: run `poetry run black` over the same five paths, record the `reformatted` and `left unchanged` summary, and restart the loop.
- [x] [P5-T2] Run the final Python lint check and record `<FEATURE>/evidence/qa-gates/python-lint-final-rc2.<timestamp>.md`
  - Command: `poetry run ruff check --no-fix scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `All checks passed!`.
- [x] [P5-T3] Run the final Python strict type check and record `<FEATURE>/evidence/qa-gates/python-typecheck-final-rc2.<timestamp>.md`
  - Command: `poetry run pyright scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: `EXIT_CODE: 0` and `0 errors`.
- [x] [P5-T4] Run the final Python coverage gate and record `<FEATURE>/evidence/qa-gates/python-coverage-final-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/final-py-rc2.json`
  - Acceptance:
    - `EXIT_CODE: 0` and 0 failed. The total `passed` count is at least the [P0-T13] count plus 13 (the ten nodes of the new whitespace file, the two new G6 nodes, and the new docs test); the artifact records the exact difference.
    - Read from each file's `summary` object in `SCRATCH/cov/final-py-rc2.json`:
      - `plan_gate_scratch.py` has `covered_lines == num_statements` and `covered_branches == num_branches` (100% line and branch).
      - `plan_gate_discrimination.py` line and branch percentages are not lower than the [P0-T13] values, and each is at least the policy floor (85% line, 75% branch).
    - No `+` line number in the hunks of `git diff -U0 <RC2_BASE> HEAD -- scripts/dev_tools/plan_gate_scratch.py scripts/dev_tools/plan_gate_discrimination.py` that is an executable statement appears in that file's `missing_lines`.
    - `Output Summary:` records baseline, post-change, and changed-line figures for both files.
- [x] [P5-T5] Run the final Python contract and frontmatter suites and record `<FEATURE>/evidence/qa-gates/python-contract-final-rc2.<timestamp>.md`
  - Command: `poetry run pytest -v tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
  - Acceptance: 0 failed, or exactly the #510 node with the #510 signature, recorded as `pending-CI` for that node. The artifact quotes the `PASSED` lines of `test_rule_file_bundle_copy_is_byte_identical` and `test_rule_file_states_g10_whitespace_alignment`.
- [x] [P5-T6] Run the final broad dev-tools regression and record `<FEATURE>/evidence/qa-gates/python-devtools-final-rc2.<timestamp>.md`
  - Command: `poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider`
  - Acceptance: every failing or erroring node ID is in the [P0-T14] reference set or is the #510 node, and the artifact lists any node that newly passes or newly fails. A new failure related to this change is fixed inside this item and the loop restarts. When that fix edits a file outside the WRITES list, the out-of-scope remediation log in Conventions applies.
- [x] [P5-T7] Run the final TypeScript format check and record `<FEATURE>/evidence/qa-gates/ts-format-final-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" eslint.config.mjs`
  - Acceptance: `EXIT_CODE: 0` and `All matched files use Prettier code style!`. If [P0-T5] recorded pre-existing warnings, it is also acceptable for the reported file set to be a subset of the baseline set that contains no file changed by this plan.
  - Remediation branch, for a file changed by this plan: run `npx prettier --write` on that file, record `(unchanged)` or the rewrite, and restart the loop.
- [x] [P5-T8] Run the final repository lint script command and record `<FEATURE>/evidence/qa-gates/ts-lint-final-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx eslint --no-error-on-unmatched-pattern src test`
  - Acceptance: `EXIT_CODE: 0` with 0 errors and no warning in a file changed by this plan.
- [x] [P5-T9] Run the final TypeScript production type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-final-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p ./ --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T10] Run the final TypeScript test type check and record `<FEATURE>/evidence/qa-gates/ts-typecheck-test-final-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx tsc -p tsconfig.jest.json --noEmit`
  - Acceptance: `EXIT_CODE: 0` with no diagnostics.
- [x] [P5-T11] Run the final full jest coverage gate and record `<FEATURE>/evidence/qa-gates/ts-coverage-final-rc2.<timestamp>.md` (working directory `extensions/drm-copilot/`)
  - Command: `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance:
    - `EXIT_CODE: 0`, 0 failed suites and tests, and no coverage-threshold failure message. The pre-existing U-2 "Coverage data ... was not found" lines are recorded but are not failures.
    - From `extensions/drm-copilot/coverage/coverage-summary.json`:
      - `src/lib/validate/plan-gate-scratch.ts` has `lines.pct` equal to 100 and `branches.pct` equal to 100;
      - the `src/lib/validate/plan-gate-commands.ts` and `src/lib/validate/plan-gate-rules.ts` percentages are not lower than the [P0-T9] values.
    - From `extensions/drm-copilot/coverage/lcov.info`: no `+` line of `git diff -U0 <RC2_BASE> HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` has a zero-hit `DA:` record.
    - `Output Summary:` records baseline, post-change, and changed-line figures.
- [x] [P5-T12] Confirm a single clean loop pass in `<FEATURE>/evidence/qa-gates/qa-loop-summary-rc2.<timestamp>.md`
  - Acceptance:
    - The latest artifacts of [P5-T1] through [P5-T11] all carry timestamps from one pass that started after the last code commit.
    - Each records an `EXIT_CODE:` that meets its task.
    - `git status --porcelain` lists only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T13] Validate this plan, the cycle-1 plan, and the original plan with the production CLI and record `<FEATURE>/evidence/qa-gates/plan-self-validation-rc2.<timestamp>.md`
  - Commands:
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-plan.2026-10-16T03-19.md`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-plan.2026-10-16T01-52.md`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/plan.2026-10-15T15-45.md`
  - Acceptance: all three exit 0, and none prints a line containing `SCRATCH definition`. The artifact records each exit code and every printed `PLAN GATE WARNING: ` line verbatim.
- [x] [P5-T14] Check file size and raw-character and temporary-file use for every changed non-Markdown file, and record `<FEATURE>/evidence/qa-gates/file-size-and-tempfile-check-rc2.<timestamp>.md`
  - Method:
    - Run the Grep tool with pattern `^` and output mode `count` on each of the nine non-Markdown files in the WRITES list below.
    - Run the Grep tool with pattern `tmp_path|tempfile|mkdtemp|NamedTemporaryFile|tmpdir|writeFileSync|mkdtempSync` over the five changed test files.
    - Run the raw-character zero-count check in Conventions on the five changed test files and on `scripts/dev_tools/plan_gate_scratch.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`.
  - Acceptance: every line count is at most 500; the temporary-file search returns zero matches; every raw-character count is 0. The artifact lists each file with its counts.
- [x] [P5-T15] Verify the change scope and record `<FEATURE>/evidence/qa-gates/scope-diff-rc2.<timestamp>.md`
  - Commands: `git diff --name-only <RC2_BASE> HEAD`, `git diff --name-status --diff-filter=D <MERGE_BASE> HEAD`, `git status --porcelain`.
  - Acceptance:
    - Every path listed by the first command is in the WRITES list of this plan, or under `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/`, or on a `PATH: ` line of an `out-of-scope-remediation-rc2.*.md` artifact. When no such artifact exists, the scope artifact records `REMEDIATION-LOG: none` together with the Glob search that established it.
    - `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/package.json`, and `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` are not listed.
    - The deletion listing is empty.
    - The porcelain listing shows only new evidence files, this plan file, and `SCRATCH/`.
- [x] [P5-T16] Commit and push the final evidence under `<FEATURE>/evidence/qa-gates/` and the plan check-offs
  - Commands: `git add` naming the new `<FEATURE>/evidence/qa-gates/` artifacts and this plan file; `git commit -m "docs(932): record remediation cycle 2 final QA evidence"`; `git push origin HEAD`.
  - Acceptance: the push exits 0, and after the push `git status --porcelain` lists no path other than `SCRATCH/`.

## Remediation Acceptance Criteria

- **N-1.** Both G10 modules make their blank-line, continuation, and normalization decisions with `PLAN_WHITESPACE_CLASS`, and the two pattern strings are identical (pinned by `test_whitespace_class_matches_typescript`). The frozen NEL, unit-separator, byte-order-mark, no-break-space, and space-then-NEL fixtures pass in both suites. The rule file (and its byte-identical bundle copy) and the `spec.md` NFR-2 note state the alignment, and name the fence pattern as the one remaining difference. Both modules stay at 100% line and branch coverage.
- **N-2.** The `splitPlanLines` body comment names the Python `split_plan_lines`, and no longer names the old Python splitter.
- **U-1.** `_has_cross_line_presence` splits tracked text with `split_plan_lines`. The form-feed and U+2028 parity fixtures pass in both suites, and the Python fixture failed before the change. The corpus A/B run reports `PLANS_DIFFERING: 0` with a differing probe.

## Acceptance-Criteria Map

| ID | Implementation | Tests / verification | Evidence |
| --- | --- | --- | --- |
| N-1 | P2-T1, P3-T1, P4-T1, P4-T2, P4-T3 | `test_whitespace_class_matches_typescript`; `test_continuation_uses_plan_whitespace_class`; `test_normalization_uses_plan_whitespace_class`; `test_rule_file_states_g10_whitespace_alignment`; `test_rule_file_bundle_copy_is_byte_identical`; TS cases `decides continuation with the plan whitespace class` and `normalizes whitespace with the plan whitespace class` | python-red-rc2, ts-red-rc2, python-green-rc2, ts-green-rc2, docs-green-rc2, python-coverage-final-rc2, ts-coverage-final-rc2 |
| N-2 | P3-T2 | Grep counts in [P3-T2]; `npx eslint` and `npx tsc` in [P3-T4], [P3-T5] | ts-lint-rc2, ts-green-rc2, ts-coverage-final-rc2 |
| U-1 | P2-T2 | `test_g6_window_split_ignores_form_feed_and_line_separator`; TS case `treats a form feed or line separator in a tracked file as part of one line`; corpus A/B helper (Appendix D) | python-red-rc2, python-green-rc2, g1-g9-corpus-ab-rc2, python-coverage-final-rc2 |

## WRITES (repository files outside the feature folder)

- `scripts/dev_tools/plan_gate_scratch.py`
- `scripts/dev_tools/plan_gate_discrimination.py`
- `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`
- `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`
- `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` (new)
- `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py`
- `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`
- `extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`
- `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts`
- `.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`

Feature-folder writes: this plan, `spec.md` (text only; no checkbox), and evidence under `evidence/remediation-baseline/`, `evidence/regression-testing/`, and `evidence/qa-gates/`.

Scratch files (not committed): `SCRATCH/cov/README.txt`, `SCRATCH/cov/baseline-py-rc2.json`, `SCRATCH/cov/final-py-rc2.json`, `SCRATCH/corpus/README.txt`, `SCRATCH/corpus/g1_g9_splitter_ab.py`, `SCRATCH/corpus/g1-g9-splitter-ab.json`.

## Appendix A — Whitespace class membership

| Character | Python `str.isspace` | JavaScript whitespace class | In `PLAN_WHITESPACE_CLASS` |
| --- | --- | --- | --- |
| U+0009 to U+000D (tab, LF, VT, FF, CR) | yes | yes | yes |
| U+001C to U+001F (information separators) | yes | no | no |
| U+0020 (space) | yes | yes | yes |
| U+0085 (NEL) | yes | no | no |
| U+00A0, U+1680, U+2000 to U+200A, U+202F, U+205F, U+3000 (Unicode space separators) | yes | yes | yes |
| U+2028, U+2029 (line and paragraph separators) | yes | yes | yes |
| U+FEFF (byte-order mark) | no | yes | no |

## Appendix B — New Test Fixtures

Python literals are shown with Python escapes, and TypeScript uses `\u0085`, `\u001f`, `\ufeff`, and `\u00a0` for the same characters. No test file contains a raw NEL, information separator, byte-order mark, no-break space, form feed, or U+2028 character. `DEF` is `_DEFINITION_LINE` (Python, defined in the new file) or the existing `DEFINITION_LINE` (TypeScript), with the value shown on the first line below. Each G10 fixture has one frozen finding. The column "current" is the result before the Phase 2 and Phase 3 changes, and is shown for the red runs only.

```text
DEF = "- SCRATCH means the session scratchpad."

Continuation fixtures (P1-T1 _CONTINUATION_FIXTURES, P1-T4 first case):
  nel-led                DEF + "\n\x85continued text"
                         -> (1, "- SCRATCH means the session scratchpad.")
                         current: Python continues (red); TypeScript matches
  unit-separator-led     DEF + "\n\x1fcontinued text"
                         -> (1, "- SCRATCH means the session scratchpad.")
                         current: Python continues (red); TypeScript matches
  bom-led                DEF + "\n\ufeffcontinued text"
                         -> (1, "- SCRATCH means the session scratchpad.")
                         current: Python matches; TypeScript continues (red)
  nbsp-led               DEF + "\n\xa0continued text"
                         -> (1, "- SCRATCH means the session scratchpad. continued text")
                         current: both match
  space-then-nel         DEF + "\n \x85"
                         -> (1, "- SCRATCH means the session scratchpad. \x85")
                         current: Python treats the line as blank (red); TypeScript matches

Normalization fixtures (P1-T1 _NORMALIZATION_FIXTURES, P1-T4 second case):
  nel-inline             "intro\x85SCRATCH is the session scratchpad."
                         -> (1, "intro\x85SCRATCH is the session scratchpad.")
                         current: Python normalizes NEL to a space (red)
  unit-separator-inline  "intro\x1fSCRATCH is the session scratchpad."
                         -> (1, "intro\x1fSCRATCH is the session scratchpad.")
                         current: Python normalizes U+001F to a space (red)
  bom-inline             "intro\ufeffSCRATCH is the session scratchpad."
                         -> (1, "intro\ufeffSCRATCH is the session scratchpad.")
                         current: TypeScript normalizes the BOM to a space (red)
  nbsp-inline            "intro\xa0SCRATCH is the session scratchpad."
                         -> (1, "intro SCRATCH is the session scratchpad.")
                         current: both match

U-1 tracked-text cases (P1-T2, P1-T5); stub match {"pinned": ["docs/design.md"]}:
  form-feed              "the pinned\fitems occupy the cohort\n"
  line-separator         "the pinned\u2028items occupy the cohort\n"
  Frozen result on the G5 channel (task P2-T1), other channel empty:
    "[P2-T1] search literal `pinned items occupy` is absent from the tracked
     tree and is not quoted in the plan; the search returns zero matches
     whatever the executor does. Quote the exact literal the task will create,
     or assert a literal that exists."
  (one string; the line breaks above are display wrapping only, each joined
   by a single space)
  current: Python splits on the separator and reports the G6 cross-line
  warning instead (red); TypeScript matches
```

## Appendix C — Python changes in `scripts/dev_tools/plan_gate_scratch.py`

```python
# Inserted after the `_NAMESPACE_RE` line.

# One explicit whitespace class for the blank-line test, the continuation test,
# and whitespace normalization. The TypeScript twin declares the identical
# pattern string, and a parity test compares the two. The class is the set on
# which the Python whitespace predicate (`str.isspace`) and the JavaScript
# whitespace class agree: NEL, the information separators, and the byte-order
# mark are excluded, so both runtimes treat them as ordinary characters.
PLAN_WHITESPACE_CLASS = (
    r"[\t\n\v\f\r \u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]"
)
_WHITESPACE_RUN_RE = re.compile(PLAN_WHITESPACE_CLASS + "+")


def _normalize_whitespace(text: str) -> str:
    """Join runs of `PLAN_WHITESPACE_CLASS` with one space and trim the ends."""

    return " ".join(filter(None, _WHITESPACE_RUN_RE.split(text)))


# `_continues_logical_line`: new first condition (replaces line 81).
    if not _normalize_whitespace(line) or _WHITESPACE_RUN_RE.match(line) is None:
        return False

# `_continues_logical_line` docstring: sentence appended to the paragraph.
#     Whitespace here means `PLAN_WHITESPACE_CLASS`.

# Module docstring: sentence inserted after "matching the TypeScript twin."
#     Blank-line, continuation, and normalization tests use
#     `PLAN_WHITESPACE_CLASS`, whose pattern string is identical in the
#     TypeScript twin.
```

## Appendix D — Corpus A/B helper `SCRATCH/corpus/g1_g9_splitter_ab.py`

This is a throwaway helper under the session scratch directory. It is not committed and is not subject to the repository lint rules.

```python
"""Issue 932 remediation cycle 2: G1-G9 corpus A/B for the G6 line splitter.

Evaluates every plan.*.md and remediation-plan.*.md file under docs/ twice
against one memoized git seam: once with the production splitter and once with
str.splitlines substituted into plan_gate_discrimination. Prints counts and
writes the per-plan findings to the JSON path given as the first argument.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path.cwd()))

import scripts.dev_tools.plan_gate_discrimination as discrimination  # noqa: E402

G10_MARKER = "SCRATCH definition"
PROBE_TEXT = "the pinned\fitems occupy the cohort\n"
PROBE_PLAN = "\n".join(
    [
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "  - Acceptance: `grep -F -n 'pinned items occupy' docs/design.md` reports one match.",
        "",
    ]
)


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
    def files_containing(self, literal):
        return ["docs/design.md"] if literal == "pinned" else []

    def is_tracked_file(self, path):
        return False

    def is_tracked_directory(self, path):
        return False

    def read_tracked_text(self, path):
        return PROBE_TEXT


def g1_to_g9(text, context):
    report = discrimination.evaluate_plan_gates(text, context=context)
    return {
        "blocking": [item for item in report.blocking if G10_MARKER not in item],
        "warnings": [item for item in report.warnings if G10_MARKER not in item],
    }


def before_and_after(text, context):
    production = discrimination.split_plan_lines
    after = g1_to_g9(text, context)
    discrimination.split_plan_lines = str.splitlines
    try:
        before = g1_to_g9(text, context)
    finally:
        discrimination.split_plan_lines = production
    return before, after


def total(rows, side):
    return sum(
        len(row[side]["blocking"]) + len(row[side]["warnings"]) for row in rows.values()
    )


def main():
    root = Path.cwd()
    base = discrimination.build_plan_gate_context(root)
    context = discrimination.PlanGateContext(
        workspace_root=base.workspace_root,
        file_system=base.file_system,
        git=CachedGit(base.git),
    )
    probe_context = discrimination.PlanGateContext(
        workspace_root=base.workspace_root,
        file_system=base.file_system,
        git=ProbeGit(),
    )
    probe_before, probe_after = before_and_after(PROBE_PLAN, probe_context)
    probe_differs = probe_before != probe_after

    plans = sorted(
        path
        for path in (root / "docs").rglob("*.md")
        if path.name.startswith(("plan.", "remediation-plan."))
    )
    rows = {}
    for path in plans:
        text = path.read_text(encoding="utf-8", errors="replace")
        before, after = before_and_after(text, context)
        rows[path.relative_to(root).as_posix()] = {"before": before, "after": after}
    differing = sorted(name for name, row in rows.items() if row["before"] != row["after"])

    print(f"PROBE_DIFFERS: {probe_differs}")
    print(f"PLANS_SCANNED: {len(plans)}")
    print(f"PLANS_DIFFERING: {len(differing)}")
    print(f"FINDINGS_BEFORE: {total(rows, 'before')}")
    print(f"FINDINGS_AFTER: {total(rows, 'after')}")
    for name in differing:
        print(f"DIFFERS: {name}")
    Path(sys.argv[1]).write_text(
        json.dumps(rows, indent=2, sort_keys=True), encoding="utf-8"
    )
    return 0 if probe_differs and not differing else 1


if __name__ == "__main__":
    raise SystemExit(main())
```

## Appendix E — TypeScript changes

```ts
// plan-gate-scratch.ts: inserted after the NAMESPACE_RE line.

/**
 * One explicit whitespace class for the blank-line test, the continuation
 * test, and whitespace normalization.
 *
 * The string is identical to the Python `PLAN_WHITESPACE_CLASS`, and a parity
 * test compares the two. The class is the set on which the Python whitespace
 * predicate and the JavaScript whitespace class agree: NEL, the information
 * separators, and the byte-order mark are excluded, so both runtimes treat
 * them as ordinary characters.
 */
export const PLAN_WHITESPACE_CLASS = String.raw`[\t\n\v\f\r \u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]`;

const WHITESPACE_RUN_RE = new RegExp(`${PLAN_WHITESPACE_CLASS}+`);
const LEADING_WHITESPACE_RE = new RegExp(`^${PLAN_WHITESPACE_CLASS}`);

// plan-gate-scratch.ts: replaces normalizeWhitespace and its TSDoc (lines 64-75).

/**
 * Join runs of `PLAN_WHITESPACE_CLASS` with one space and trim the ends.
 *
 * @param value Text to normalize.
 * @returns The normalized text, identical to the Python `_normalize_whitespace`.
 */
function normalizeWhitespace(value: string): string {
  return value
    .split(WHITESPACE_RUN_RE)
    .filter((word) => word !== "")
    .join(" ");
}

// plan-gate-scratch.ts: continuesLogicalLine condition (replaces line 88).
  if (normalizeWhitespace(line) === "" || !LEADING_WHITESPACE_RE.test(line)) {

// plan-gate-scratch.ts: continuesLogicalLine TSDoc, sentence appended to the
// first paragraph:
//   Whitespace here means `PLAN_WHITESPACE_CLASS`.

// plan-gate-scratch.ts: module TSDoc, bullet appended to Invariants / Constraints:
//  *     - Blank-line, continuation, and normalization tests use
//  *       `PLAN_WHITESPACE_CLASS`, whose pattern string is identical in the
//  *       Python module.

// plan-gate-commands.ts, N-2: replaces the comment lines 268-272 in splitPlanLines.
  // The Python `split_plan_lines` yields no trailing empty line for text that
  // ends with a line terminator, while `String.prototype.split` does. Dropping
  // that element keeps every record field identical across the two runtimes,
  // including the newline-joined whole-window task text. No record was ever
  // produced from the dropped element, so no existing finding changes.
```

# 2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans — Remediation Plan (Cycle 1)

- **Issue:** #486
- **Remediation cycle:** 1 of the R1–R5 loop
- **Owner:** drmoisan
- **Last Updated:** 2026-08-20T14-09
- **Status:** Ready for Preflight
- **Work Mode:** full-feature (AC sources: `spec.md`, `user-story.md`)
- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`

## Source Artifacts

- Remediation inputs: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-inputs.2026-08-20T14-09.md`
- Code review: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/code-review.2026-08-20T14-09.md`
- Feature audit: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/feature-audit.2026-08-20T14-09.md`
- Policy audit: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/policy-audit.2026-08-20T14-09.md`
- Executed feature plan (task IDs [P5-T3], [P12-T13], [P12-T14] referenced below): `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md`
- Spec under reconciliation: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`

## Findings in Scope

- **R1 (Blocking).** TypeScript changed-line coverage regression on `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` (lines 117-118 uncovered; the combined blocking-error-plus-warning message path has no test).
- **R2 (Blocking).** Spec AC7 states a one-conjunct biconditional that does not handle the vacuous zero-finding G5 measurement; the shipped two-conjunct rule (plan [P5-T3]) is correct and unchanged. Spec AC7, the line-64 pre-declared rule, two `## Definition of Done` items, and plan tasks [P12-T13]/[P12-T14] require reconciliation and check-off.
- **R3 (Minor).** `scripts/dev_tools/validate_orchestration_artifacts.py` line 359 (the `plan`-route short-circuit in `_validate_from_args`) is uncovered.
- **R4 (Minor).** No single synthetic plan exercises all three confirmed failure modes (G1, G5, G6) in one evaluation; spec `## Seeded Test Conditions` item 2 is unchecked.

## Do Not Do (binding, from remediation-inputs)

- Do not change `G5_SEVERITY` or any other severity constant, in either runtime.
- Do not modify `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, or any file under `.github/instructions/`; keep the `extensions/drm-copilot/resources/claude-customizations/` mirrors byte-identical if any mirrored file is ever touched (none should be).
- Do not modify or regenerate `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` or any other committed evidence artifact.
- Do not weaken jest `coverageThreshold` entries or add any coverage `exclude` for a production path.
- No scope creep: no new gate rules, no severity-override mechanisms, no grandfathering lists.
- Evidence for this cycle is written only under `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`; `artifacts/baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change` are forbidden.

## Acceptance-Command Discipline (this plan dogfoods its own subject matter)

- Every coverage assertion below uses the dotted-module form (`--cov=scripts.dev_tools.<module>`), never a `--cov=<path>.py` or `--cov=<path>` form, and always the `=` form (never space-separated).
- Every `grep`-style acceptance below either supplies `-F` against a literal already present elsewhere in the tracked tree, or uses a Markdown-checkbox anchor pattern (`^- \[x\]` / `^- \[ \]`) that carries regular-expression metacharacters, so none of them is a checkable literal under G5/G6 and none can produce a false rejection of this plan.
- Where a grep's expected result is "no match", the expected exit code (`1`) is stated explicitly in the task text.
- New test names below are given as literal `it(...)`/`test_...` identifiers so each acceptance command targets exactly one test.

## Toolchain Commands

- Python: `poetry run black`, `poetry run ruff`, `poetry run pyright`, `poetry run pytest` — all run from the worktree root and resolve correctly via `poetry run`. A direct `poetry run python -m scripts.dev_tools.<module>` invocation must be prefixed with `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d` because this worktree's active virtualenv editable install otherwise resolves `scripts.dev_tools.*` to the main checkout.
- TypeScript: run from `extensions/drm-copilot` using `npx prettier`, `npx eslint`, `npx tsc`, and `node run-jest.cjs`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`, and `.claude/rules/plan-acceptance-gates.md` (the rule this cycle reconciles spec text against, without modifying it), and record the read
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/phase0-instructions-read.<ts>.md` exists and contains `Timestamp:`, `Policy Order:`, and one line naming each of the six files above.
- [x] [P0-T2] Restore this worktree's own TypeScript dependency tree — currently absent, since `extensions/drm-copilot/node_modules` does not exist and no ancestor `node_modules` inside the worktree exists either, which is why `npx eslint` currently resolves the scoped devDependency `@eslint/js` from the main checkout's hoisted tree rather than from this worktree — by running `npm ci` from `extensions/drm-copilot`, then confirm `npx eslint --version` succeeds and `extensions/drm-copilot/node_modules/@eslint/js` exists. This task is sequenced immediately before the TypeScript coverage baseline task ([P0-T3]) rather than after it, because [P5-T8]'s final coverage measurement necessarily runs against the restored dependency tree (all downstream phases require a working `node_modules`), and the baseline must therefore be captured under that same locked dependency set to remain comparable to the final measurement in [P5-T9]'s delta check, rather than under the incidental hoisted-ancestor resolution currently in effect.
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/npm-ci.<ts>.md` exists carrying `Timestamp:`, `Command: npm ci`, `EXIT_CODE: 0`, and an `Output Summary:` confirming `extensions/drm-copilot/node_modules/@eslint/js` is present and that `npx eslint --no-error-on-unmatched-pattern src test` (run once, read-only) exits 0 without a module-resolution error.
- [x] [P0-T3] Capture the TypeScript coverage baseline for the file this cycle must restore, using the dependency tree restored in [P0-T2], by running `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/typescript-test.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the line and branch coverage percentages for `src/lib/validate/validate-orchestration-service-call.ts` read from `coverage/lcov.info`, expected to show the regressed starting state (98.51% line / 81.25% branch).
- [x] [P0-T4] Capture the Python coverage baseline for the module this cycle must restore by running `poetry run pytest -q --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/python-test.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the passed count, the numeric line and branch percentages for `scripts/dev_tools/validate_orchestration_artifacts.py`, and that line `359` appears in the `Missing` column.

### Phase 1 — R1: TypeScript Changed-Line Coverage Regression

- [x] [P1-T1] Add a test named `throws the combined error-and-warning message when both channels are non-empty` to `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts`, using a new plan fixture constant containing one task whose acceptance line supplies a `--cov` value that is a filesystem path ending in the Python suffix (producing a G1 Blocking finding on the errors channel) and a second task whose acceptance line supplies a `--cov` value in the space-separated form (producing a G4 Warning finding on the warnings channel), then asserting that `validateOrchestrationServiceCall(...)` throws an `Error` whose message equals the pre-change error-block format followed immediately by a newline and by the `warnings.map((warning) => ...)` block joined with newlines, each line prefixed with the exported `PLAN_GATE_WARNING_PREFIX` constant
  - Acceptance: `node run-jest.cjs test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts -t "throws the combined error-and-warning message"` from `extensions/drm-copilot` reports 1 passed.
- [x] [P1-T2] Run the full TypeScript suite with coverage using `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` from `extensions/drm-copilot` and confirm the file is restored
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-restore-r1.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that `coverage/lcov.info` records no `DA:117,0` or `DA:118,0` entry for `src/lib/validate/validate-orchestration-service-call.ts` and that the file's line coverage is 100.00% and branch coverage is at or above 84.61%.

### Phase 2 — R2: Spec AC7/DoD Reconciliation and Plan Check-off

- [x] [P2-T1] Edit the pre-declared-rule paragraph at `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` (the blockquote beginning "The implementation runs G5 against the acceptance-line grep commands") to state the two-conjunct rule — ships G5 as Blocking if and only if the total G5 finding count is greater than 0 and the measured false-positive count is 0, otherwise Warning — and append a deviation note citing plan task `[P5-T3]` and the measurement artifact `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md`, stating that the prior one-conjunct wording did not account for the vacuous zero-finding measurement obtained
  - Acceptance: `grep -c -F "two-conjunct" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` reports at least 1, and the edited paragraph names `[P5-T3]` and `g5-corpus-measurement.2026-08-20T12-02.md`.
- [x] [P2-T2] Edit AC7 in the same file's `## Acceptance Criteria` section to state the two-conjunct rule — G5's shipped severity is Blocking if and only if the recorded finding count is greater than 0 and the recorded false-positive count is 0 — citing the measurement artifact and the `G5_SEVERITY` constant location in both runtimes as evidence, then change its checkbox from `- [ ]` to `- [x]`
  - Acceptance: `grep -n "^- \[x\] \*\*AC7" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` returns exactly one line.
- [x] [P2-T3] Change the first `## Definition of Done` checkbox ("Every acceptance criterion below is checked off...") from `- [ ]` to `- [x]` in the same file, now true because AC7 is checked and AC1-AC6/AC8-AC12 are already checked
  - Acceptance: reading `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`, the first `## Definition of Done` bullet begins `- [x]`.
- [x] [P2-T4] Edit the second `## Definition of Done` bullet (the G5 corpus measurement item) in the same file to reference the two-conjunct rule applied to the recorded finding count and false-positive count, citing the measurement artifact, and change its checkbox from `- [ ]` to `- [x]`
  - Acceptance: `grep -c "^- \[x\]" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` reports exactly 22 (19 at cycle entry, plus AC7, DoD item 1, and DoD item 2).
- [x] [P2-T5] Change the `[P12-T13]` checkbox in `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` from `- [ ]` to `- [x]`, appending to the task line the evidence citation of `evidence/qa-gates/ac-reconciliation.2026-08-20T13-50.md` plus AC7's new evidence citation from [P2-T2]
  - Acceptance: `grep -n "^- \[x\] \[P12-T13\]" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` returns exactly one line.
- [x] [P2-T6] Change the `[P12-T14]` checkbox in the same plan file from `- [ ]` to `- [x]`, appending to the task line a citation of the coverage values recorded in `evidence/qa-gates/coverage-delta.2026-08-20T13-36.md`
  - Acceptance: `grep -n "^- \[x\] \[P12-T14\]" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` returns exactly one line.
- [x] [P2-T7] Verify no unchecked task line remains in the executed feature plan
  - Acceptance: `grep -n "^- \[ \] \[P" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` returns no lines (expected exit code 1, meaning no match found).

### Phase 3 — R3: Python Line 359 Coverage

- [x] [P3-T1] Add a test named `test_validate_from_args_returns_blocking_channel_only_for_plan` to `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`, monkeypatching `_read_text` to return the module's existing `_G1_PLAN` fixture, constructing `argparse.Namespace(path="plan.md", artifact_type="plan", workspace_root=".")`, and asserting `validator._validate_from_args(args)` equals `validator._plan_channels(args)[0]` and is non-empty
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::test_validate_from_args_returns_blocking_channel_only_for_plan -q` reports 1 passed.
- [x] [P3-T2] Confirm line 359 is no longer uncovered by running `poetry run pytest -q --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-restore-r3.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that the `Missing` column for `scripts/dev_tools/validate_orchestration_artifacts.py` no longer includes `359`, plus the module's numeric line and branch percentages.

### Phase 4 — R4: Combined Three-Failure-Mode Integration Scenario

- [x] [P4-T1] Add a test named `test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation` to `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py`, building one plan document with three tasks — one whose `--cov` acceptance argument is a filesystem path ending in the Python suffix, one whose grep acceptance argument is a checkable literal a stub git adapter reports absent from the tracked tree and that the plan does not otherwise quote, and one whose grep acceptance argument is a checkable literal a stub git adapter reports present only across an adjacent-line window join of a tracked file — and asserting that one `validate_plan_text_with_warnings` call over that plan with the stub context returns exactly one Blocking finding (the G1 finding) and exactly two Warning findings (the G5 and G6 findings, one each)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::test_combined_plan_produces_g1_g5_g6_findings_in_one_evaluation -q` reports 1 passed.
- [x] [P4-T2] Add a test named `produces one G1 Blocking finding and two Warnings (G5, G6) in a single combined-plan evaluation` to `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts`, building the parity three-task plan fixture described in [P4-T1] and a `CommandRunner` stub answering the G5 literal's tracked-tree query with empty output and the G6 literal's first-word query with a tracked path whose stubbed file-system content wraps the literal across two lines, then asserting that one `validateArtifactWithWarnings` call over that plan with the stub context returns exactly one entry in `errors` and exactly two entries in `warnings`
  - Acceptance: `node run-jest.cjs test/lib/validate/orchestration-artifacts-plan-gates.test.ts -t "produces one G1 Blocking finding and two Warnings"` from `extensions/drm-copilot` reports 1 passed.
- [x] [P4-T3] Change the `## Seeded Test Conditions` item 2 checkbox ("Integration scenarios: ...") in `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` from `- [ ]` to `- [x]`, citing the two tests added in [P4-T1] and [P4-T2] as evidence, text otherwise unchanged
  - Acceptance: `grep -n "^- \[x\] Integration scenarios" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` returns exactly one line.

### Phase 5 — Final QC Loop (Coverage Mode, Both Runtimes)

- [x] [P5-T1] Run Python formatting with `poetry run black scripts tests` from the worktree root and restart this phase from [P5-T1] if any file is reformatted
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating `0 files reformatted` on the final pass.
- [x] [P5-T2] Run Python linting with `poetry run ruff check scripts tests` from the worktree root and restart this phase from [P5-T1] if any file is auto-fixed
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-lint.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating zero diagnostics and zero fixes applied on the final pass.
- [x] [P5-T3] Run Python type checking with `poetry run pyright` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-typecheck.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `0 errors`.
- [x] [P5-T4] Run the full Python suite with coverage using `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_discrimination --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-test-final.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the passed count and the numeric line and branch percentages for each of the three named modules, each line percentage at or above 85 and each branch percentage at or above 75, with `scripts/dev_tools/validate_orchestration_artifacts.py` at or above its Phase 0 baseline on both axes.
- [x] [P5-T5] Run TypeScript formatting with `npx prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from `extensions/drm-copilot` and restart this phase from [P5-T5] if any file changes
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that no file was rewritten on the final pass.
- [x] [P5-T6] Run TypeScript linting with `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-lint.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording zero errors and zero warnings.
- [x] [P5-T7] Run TypeScript type checking with `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-typecheck.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording zero diagnostics.
- [x] [P5-T8] Run the full TypeScript suite with coverage using `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-test-final.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording suite/test pass counts and the numeric line and branch percentages for `src/lib/validate/validate-orchestration-service-call.ts` (expected 100.00% line, at or above 84.61% branch), `src/lib/validate/plan-gate-commands.ts`, `src/lib/validate/plan-gate-discrimination.ts`, and `src/lib/validate/orchestration-artifacts.ts`, each line percentage at or above 85 and each branch percentage at or above 75.
- [x] [P5-T9] Record the remediation-baseline-versus-final coverage delta for both runtimes
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-delta-remediation.<ts>.md` exists and tabulates, for `src/lib/validate/validate-orchestration-service-call.ts` and `scripts/dev_tools/validate_orchestration_artifacts.py`, the [P0-T3]/[P0-T4] baseline line and branch percentages, the [P5-T8]/[P5-T4] final percentages, the signed delta, and a pass/fail verdict against the no-regression rule; both files must show a non-negative delta.
- [x] [P5-T10] Validate this remediation plan document with the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool using `artifact_type: "plan"` and `artifact_path: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T14-09.md`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/plan-self-validation.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` carrying the verbatim success summary string returned by the tool.
- [x] [P5-T11] Run the plan-acceptance gate directly against this document using `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T14-09.md --workspace-root .`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/self-gate-run-remediation.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE: 0`, the full stderr text, and an explicit disposition line for every `PLAN GATE WARNING: ` emitted, if any.

## Exit Condition

This remediation cycle exits when all 29 tasks above are checked `[x]`, both blocking findings (R1, R2) and both minor findings (R3, R4) are closed with cited evidence, and Phase 5 completes in a single pass with zero blocking gate findings and zero coverage regressions.

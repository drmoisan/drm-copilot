# 2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans — Remediation Plan (Cycle 2)

- **Issue:** #486
- **Remediation cycle:** 2 of the R1–R5 loop
- **Owner:** drmoisan
- **Last Updated:** 2026-08-20T16-10
- **Status:** Ready for Preflight
- **Work Mode:** full-feature (AC sources: `spec.md`, `user-story.md`)
- **Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486`

## Source Artifacts

- Remediation inputs: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-inputs.2026-08-20T16-10.md`
- Code review: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/code-review.2026-08-20T16-10.md`
- Feature audit: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/feature-audit.2026-08-20T16-10.md`
- Policy audit: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/policy-audit.2026-08-20T16-10.md`
- Governing rule (read-only this cycle): `.claude/rules/plan-acceptance-gates.md` § Graceful degradation
- Spec under reconciliation (AC10 only): `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md`

## Findings in Scope

- **R5 (Blocking).** The Python graceful-degradation guard omits the G2/G3 coverage path. `scripts/dev_tools/plan_gate_discrimination.py` `_evaluate_cov_value` performs the tracked-tree lookups (`is_tracked_file`, `is_tracked_directory`, lines 283-297 at cycle entry) with no exception guard, so a raising repository seam escapes `evaluate_plan_gates` when the plan carries a path-separator `--cov` value. The escape is reachable in production (`subprocess.run` raises `FileNotFoundError` when `git` is absent from `PATH`; `allow_error=True` suppresses only non-zero exits, not exceptions). This violates `.claude/rules/plan-acceptance-gates.md` § Graceful degradation and spec AC10, and diverges from the TypeScript runtime, whose `plan-gate-rules.ts` wraps the equivalent lookups (`evaluateTrackedCovValue` invocation, lines 236-241) in try/catch.
- **AC10 checkbox reconciliation (Info).** Spec AC10's checked state becomes accurate once the R5 guard lands and the new named test passes. A one-line verification addendum naming the new test is added; the criterion's meaning and checkbox state are not altered.

## M1 Disposition — Deferred (explicit decision)

M1 (non-zero-exit seam semantics diverging from the rule prose, identically in both runtimes) is **deferred from this cycle** and recorded as a potential entry instead. Reasoning:

1. The remediation inputs classify M1 as advisory and deferrable, with impact confined to the Warning channel and identical across runtimes; no runtime divergence exists for it.
2. The inputs' Do Not Do list prohibits adapter exit-code rework under R5. Folding M1 in would require coordinated adapter changes in both runtimes plus new parity tests — a scope expansion beyond the single Blocking finding this cycle exists to close.
3. Deferral is not silent: task [P3-T3] records M1 as `docs/features/potential/2026-08-20-plan-gate-nonzero-exit-seam-semantics.md`, preserving both remediation options the inputs name (distinguish fatal exits in both adapters, or reconcile the rule prose to shipped semantics) for a deliberately scoped later cycle.

## Verification Lesson Applied (fail-before discipline)

The existing test `test_failing_git_adapter_produces_no_findings` passes only because its fixture raises in `files_containing`, which drives the already-guarded literal path; `is_tracked_file` in that stub returns `False` and never exercises the unguarded coverage path. The new R5 test therefore must be shown to **fail against the current code** (Phase 1, `[expect-fail]`) and pass only after the Phase 2 fix, with both runs recorded as evidence.

## Do Not Do (binding, from remediation-inputs)

- Do not change any finding string, severity constant (`G5_SEVERITY` included), rule ordering, or channel routing in either runtime.
- Do not modify `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, or any file under `.github/instructions/`.
- Do not modify the TypeScript production modules — they already implement the required guard; the change is Python-side plus tests. Keep the `extensions/drm-copilot/resources/claude-customizations/` mirrors byte-identical (no mirrored file is touched).
- Do not modify or regenerate committed evidence artifacts from prior cycles.
- Do not weaken jest `coverageThreshold` entries or add any coverage `exclude` for a production path.
- No scope creep: no new gate rules, no severity-override mechanisms, no grandfathering lists, and no adapter exit-code rework (that is M1, deferred per the disposition above).
- Evidence for this cycle is written only under `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`; `artifacts/baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change` are forbidden.

## Acceptance-Command Discipline (this plan dogfoods its own subject matter)

- Every coverage assertion below uses the dotted-module form (`--cov=scripts.dev_tools.plan_gate_discrimination`), never a path form, and always the `=` form.
- Test-fixture coverage values are described in prose (flag and value named separately), never spelled as a runnable command string, so no fixture description is extracted as a command span.
- Every `grep`-style acceptance below either supplies `-F` against a literal this plan quotes in prose outside the command span, or uses a Markdown-checkbox anchor pattern carrying regular-expression metacharacters, so none is a false-rejection candidate under G5/G6.
- Where an acceptance's expected result is a failing run or a no-match grep, the expected non-zero exit code is stated explicitly in the task text.
- New test names are given as literal `test_...` identifiers so each acceptance command targets exactly one test.

## Toolchain Commands

- Python: `poetry run black`, `poetry run ruff`, `poetry run pyright`, `poetry run pytest` — all run from the worktree root and resolve correctly via `poetry run`. A direct `poetry run python -m scripts.dev_tools.<module>` invocation must carry the prefix `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`, because the active virtualenv editable install otherwise resolves `scripts.dev_tools.*` to the main checkout.
- TypeScript: run from `extensions/drm-copilot` using `npx prettier`, `npx eslint`, `npx tsc`, and `node run-jest.cjs`. The dependency tree (`extensions/drm-copilot/node_modules`) was restored by cycle 1 and is present.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation Baseline (Cycle 2)

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`, and `.claude/rules/plan-acceptance-gates.md` (the rule whose graceful-degradation clause R5 restores, read-only), and record the read
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/phase0-instructions-read.<ts>.md` exists and contains `Timestamp:`, `Policy Order:`, and one line naming each of the six files above.
- [x] [P0-T2] Capture the Python coverage baseline for the module this cycle changes by running `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing tests/scripts/dev_tools` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/python-test.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the passed count and the numeric line and branch percentages for `scripts/dev_tools/plan_gate_discrimination.py`, expected at cycle entry to be 98.21% line / 90.54% branch.
- [x] [P0-T3] Capture the TypeScript coverage baseline by running `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/remediation-baseline/typescript-test.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording suite/test pass counts and the numeric line and branch percentages for `src/lib/validate/plan-gate-rules.ts` and `src/lib/validate/plan-gate-discrimination.ts`, which the final QC phase must reproduce unchanged because no TypeScript production file is modified this cycle.

### Phase 1 — R5 Fail-Before Regression Test

- [x] [P1-T1] Add a test named `test_failing_git_adapter_skips_g2_g3_without_raising` to `tests/scripts/dev_tools/test_plan_gate_discrimination_context.py`. Arrange a local stub class extending that module's `StubGitRepository` whose `is_tracked_file` and `is_tracked_directory` overrides raise `RuntimeError`, and a one-task plan (via the module's `_plan` helper) whose acceptance command is `poetry run pytest` carrying a `--cov` flag whose value is `scripts/dev_tools/missing`, supplied in the `=` form so no G4 warning muddies the assertion. Act by calling `evaluate_plan_gates` with the raising context. Assert `report.blocking == []` and `report.warnings == []` — the degraded run must produce zero G2/G3 findings and no exception.
  - Acceptance: `grep -c -F "test_failing_git_adapter_skips_g2_g3_without_raising" tests/scripts/dev_tools/test_plan_gate_discrimination_context.py` reports exactly 1 (the definition line).
- [x] [P1-T2] [expect-fail] Run the new test against the current, unguarded code with `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q` from the worktree root; the run is expected to FAIL with exit code 1 because the raising seam propagates `RuntimeError` out of `evaluate_plan_gates`. This failure is the proof the test discriminates; a passing run here invalidates the test and requires rework of [P1-T1] before proceeding.
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/r5-fail-before.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, and an `Output Summary:` quoting the `RuntimeError` propagation from the failing run (1 failed).

### Phase 2 — R5 Python Graceful-Degradation Guard

- [x] [P2-T1] In `scripts/dev_tools/plan_gate_discrimination.py`, mirror the TypeScript structure: extract the G2/G3 tracked-tree block of `_evaluate_cov_value` (the `is_tracked_file` check, the `is_tracked_directory` check, and the G3 warning append) into a helper whose definition line begins `def _evaluate_tracked_cov_value`, and invoke it from `_evaluate_cov_value` inside a broad `try`/`except Exception: return` guard carrying the same contract comment used by `_evaluate_literal_rules` (a validation run must never fail because the repository could not be queried; spec AC10, graceful degradation). Do not change any finding string, severity, or the cascade order; G1 and G4 remain outside the guard because they are context-free.
  - Acceptance: `grep -c -F "_evaluate_tracked_cov_value" scripts/dev_tools/plan_gate_discrimination.py` reports at least 2 (definition plus guarded invocation), and `grep -c -F "def _evaluate_tracked_cov_value" scripts/dev_tools/plan_gate_discrimination.py` reports exactly 1.
- [x] [P2-T2] Re-run the named test with `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q` from the worktree root and confirm it now passes, completing the fail-before/pass-after pair
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/r5-pass-after.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording 1 passed.
- [x] [P2-T3] Add a companion test named `test_raising_adapter_reports_only_context_free_findings` to `tests/scripts/dev_tools/test_plan_gate_discrimination_context.py` so the degradation suite covers both rule groups explicitly in one evaluation. Arrange the same fully raising stub adapter and a plan with two tasks: one whose acceptance command carries a `--cov` flag whose value is a filesystem path ending in the Python suffix (a context-free G1 Blocking finding), and one whose acceptance command carries a `--cov` flag whose value is `scripts/dev_tools/missing` supplied space-separated (a context-free G4 Warning finding plus a degraded G2/G3 lookup). Assert exactly one Blocking finding (the G1 finding) and exactly one Warning finding (the G4 finding), proving the context-free rules still report while the raising coverage path degrades silently.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_raising_adapter_reports_only_context_free_findings -q` reports 1 passed.
- [x] [P2-T4] Run the full dev-tools Python suite with `poetry run pytest tests/scripts/dev_tools -q` from the worktree root to confirm no existing test regressed, including `test_failing_git_adapter_produces_no_findings` on the literal path
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/python-suite-r5.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the passed count and 0 failed.

### Phase 3 — Cross-Runtime Parity and AC10 Reconciliation

- [x] [P3-T1] Verify the two runtimes agree on graceful degradation for this input class (raising repository seam plus a path-separator `--cov` value): run `node run-jest.cjs test/lib/validate/plan-gate-discrimination-literals.test.ts -t "skips the tracked-tree cov rules when the adapter throws"` from `extensions/drm-copilot` (the pre-existing TypeScript test at line 264 asserting empty blocking and warning channels) and `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q` from the worktree root (the new Python test asserting the same empty channels for the equivalent fixture), then confirm no TypeScript production file changed by running `git diff --name-only extensions/drm-copilot/src` from the worktree root, whose expected output is empty with exit code 0
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/parity-r5.<ts>.md` exists with `Timestamp:`, all three `Command:` lines each with `EXIT_CODE: 0`, and an `Output Summary:` stating both tests pass, both assert empty blocking and warning channels for the raising-seam path-separator coverage input, and the TypeScript production diff is empty.
- [x] [P3-T2] Append a one-line verification addendum to AC10 in `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` naming `test_failing_git_adapter_skips_g2_g3_without_raising` as the coverage-path degradation evidence, without altering the criterion's meaning, its existing text, or its checked `[x]` state
  - Acceptance: `grep -c -F "test_failing_git_adapter_skips_g2_g3_without_raising" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` reports at least 1, and the AC10 checkbox line still begins `- [x]`.
- [x] [P3-T3] Record the M1 deferral as a potential entry by creating `docs/features/potential/2026-08-20-plan-gate-nonzero-exit-seam-semantics.md` describing the finding (both adapters translate every non-zero `git` exit into a negative answer, so a fatal exit 128 can yield a spurious G3 or G5 Warning instead of a skip; `git grep` exit 1 is the ordinary no-match answer and is correct by design), its Warning-channel-only impact, and the two remediation options from the cycle-2 remediation inputs (distinguish fatal exits in both adapters with parity tests, or reconcile the rule prose to the shipped semantics)
  - Acceptance: `docs/features/potential/2026-08-20-plan-gate-nonzero-exit-seam-semantics.md` exists and names both affected files (`scripts/dev_tools/plan_gate_discrimination.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts`) and the governing rule file `.claude/rules/plan-acceptance-gates.md`.

### Phase 4 — Final QC Loop (Coverage Mode, Both Runtimes)

- [x] [P4-T1] Run Python formatting with `poetry run black scripts tests` from the worktree root and restart this phase from [P4-T1] if any file is reformatted
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating `0 files reformatted` on the final pass.
- [x] [P4-T2] Run Python linting with `poetry run ruff check scripts tests` from the worktree root and restart this phase from [P4-T1] if any file is auto-fixed
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-lint.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating zero diagnostics and zero fixes applied on the final pass.
- [x] [P4-T3] Run Python type checking with `poetry run pyright` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-typecheck.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording `0 errors`.
- [x] [P4-T4] Run the full Python suite with coverage using `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing` from the worktree root
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-test-final.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording the passed count and the numeric line and branch percentages for `scripts/dev_tools/plan_gate_discrimination.py`, with the line percentage at or above 85, the branch percentage at or above 75, and both at or above the [P0-T2] baseline values (no regression from 98.21% line / 90.54% branch).
- [x] [P4-T5] Run TypeScript formatting with `npx prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from `extensions/drm-copilot` and restart this phase from [P4-T5] if any file changes
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-format.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` stating that no file was rewritten on the final pass.
- [x] [P4-T6] Run TypeScript linting with `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-lint.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording zero errors and zero warnings.
- [x] [P4-T7] Run TypeScript type checking with `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-typecheck.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording zero diagnostics.
- [x] [P4-T8] Run the full TypeScript suite with coverage using `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` from `extensions/drm-copilot`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-test-final.<ts>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording suite/test pass counts and the numeric line and branch percentages for `src/lib/validate/plan-gate-rules.ts` and `src/lib/validate/plan-gate-discrimination.ts`, each line percentage at or above 85, each branch percentage at or above 75, and each value equal to its [P0-T3] baseline (no TypeScript production change this cycle).
- [x] [P4-T9] Record the remediation-baseline-versus-final coverage delta for both runtimes
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-delta-remediation.<ts>.md` exists and tabulates, for `scripts/dev_tools/plan_gate_discrimination.py`, `src/lib/validate/plan-gate-rules.ts`, and `src/lib/validate/plan-gate-discrimination.ts`, the [P0-T2]/[P0-T3] baseline line and branch percentages, the [P4-T4]/[P4-T8] final percentages, the signed delta, and a pass/fail verdict against the no-regression rule; every file must show a non-negative delta.
- [x] [P4-T10] Validate this remediation plan document with the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool using `artifact_type: "plan"`, `artifact_path: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md`, and `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/plan-self-validation.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` carrying the verbatim success summary string returned by the tool.
- [x] [P4-T11] Run the plan-acceptance gate directly against this document using `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md --workspace-root .`
  - Acceptance: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/self-gate-run-remediation.<ts>.md` records `Timestamp:`, `Command:`, `EXIT_CODE: 0`, the full stderr text, and an explicit disposition line for every `PLAN GATE WARNING: ` emitted, if any.

## Exit Condition

This remediation cycle exits when all 17 tasks above are checked `[x]`, the Blocking finding R5 is closed with the fail-before/pass-after evidence pair and the cross-runtime parity artifact, the AC10 addendum is in place, the M1 deferral is recorded as a potential entry, and Phase 4 completes in a single pass with zero blocking gate findings and zero coverage regressions.

# Remediation Inputs — reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486)

- Entry timestamp: 2026-08-20T14-09
- Cycle: 1
- Producing audit artifacts:
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/policy-audit.2026-08-20T14-09.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/code-review.2026-08-20T14-09.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/feature-audit.2026-08-20T14-09.md`
- Supporting executor evidence:
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/coverage-delta.2026-08-20T13-36.md` (records finding R1 as remediation-required)
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` (the measurement behind finding R2)
- Blocking finding count: **2** (R1, R2). Minor items: 2 (R3, R4).
- Handoff: per `remediation-handoff-atomic-planner`, the remediation plan is authored by `atomic-planner` from these inputs, preflighted by `atomic-executor`, executed task-by-task, and reaudited by `feature-review`.

## Remediation-Required Findings

### R1 (Blocking) — TypeScript changed-line coverage regression

- **File:** `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts`
- **Defect:** lines 117–118 (the `warnings` receiver and `.map((warning) => ...)` callback inside the `warningBlock` construction) were added by this branch and are uncovered. File coverage regressed from 100.00% line / 84.61% branch (baseline) to 98.51% / 81.25%. Absolute thresholds still pass, so no jest gate fired; the violation is the uniform "No regression on changed lines" gate (`.claude/rules/quality-tiers.md`; `.claude/rules/general-unit-test.md`).
- **Expected behavior after fix:** the combined path — a validation returning at least one blocking error AND at least one warning in the same call — throws a message consisting of the pre-change error block followed by a newline-joined block of `PLAN GATE WARNING: `-prefixed warning lines.
- **Fix:** add one named test to `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts` driving a stub that returns >= 1 error and >= 1 warning, asserting the thrown message's error lines and appended warning block exactly. No production-code change is expected.
- **Verification commands (from `extensions/drm-copilot`):**
  - `node run-jest.cjs test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts` — the new test passes.
  - `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` — exit 0; `coverage/lcov.info` shows `src/lib/validate/validate-orchestration-service-call.ts` at 100% line (no `DA:<n>,0` entries) and branch coverage >= 84.61%.

### R2 (Blocking) — spec AC7 text defect; AC7/DoD/check-off reconciliation

- **Files:** `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` (AC7 at line 192; the pre-declared rule paragraph at line 64; DoD items 1–2 at lines 176–177), plus check-offs in `plan.2026-08-17T15-00.md` ([P12-T13], [P12-T14]).
- **Defect:** spec AC7 and the line-64 pre-declared rule use the one-conjunct biconditional "Blocking if and only if the recorded false-positive count is 0", which does not handle the vacuous measurement actually obtained (0 G5 findings over 166 plans / 100 candidate literals, hence FP count 0 with zero information content). The approved plan [P5-T3] pre-declared the two-conjunct rule (Blocking iff finding count > 0 AND FP count == 0), explicitly predicted the vacuous branch, and terminally disposed it as Warning; the implementation, the rule file `.claude/rules/plan-acceptance-gates.md`, and the measurement artifact are all consistent with it. The audit verdict is that the spec sentence is the defective artifact; the implementation is correct and must not change.
- **Expected behavior after fix:** spec.md states the two-conjunct rule in AC7, the line-64 rule paragraph, and DoD item 2, with a short recorded deviation note citing plan [P5-T3] and the measurement artifact; AC7 is then checked `[x]` with the measurement artifact and the two severity constants named as evidence; DoD items 1 and 2 are checked `[x]`; plan tasks [P12-T13] and [P12-T14] are completed and checked `[x]` (naming the verifying test or evidence artifact per their task text).
- **Constraint:** do not change `G5_SEVERITY` in either runtime; do not modify `.claude/rules/plan-acceptance-gates.md`; do not modify or re-run the measurement artifact. This is a documentation reconciliation following the precedent of the AC-F3 reconciliation on issue #489.
- **Verification commands:**
  - `grep -n "greater than" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` — the two-conjunct wording is present in AC7.
  - `grep -c "^- \[x\]" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` — count increases by 3 (AC7, DoD 1, DoD 2) relative to this cycle's entry state.
  - `grep -n "^- \[ \] \[P" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md` — returns no lines.

### R3 (Minor) — uncovered added Python line

- **File:** `scripts/dev_tools/validate_orchestration_artifacts.py`, line 359 (`if args.artifact_type == "plan": return _plan_channels(args)[0]` inside `_validate_from_args`).
- **Defect:** a new defensive line with zero coverage; unreachable through `main()`, which routes plan through `_validate_from_args_with_warnings` first. Not a threshold or file-regression failure (the file improved on both axes), recorded for changed-line completeness.
- **Fix:** add a direct unit test calling `_validate_from_args` with a plan-type namespace and asserting it returns the blocking channel only.
- **Verification:** `poetry run pytest -q --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools` — line 359 no longer appears in the `Missing:` column.

### R4 (Minor) — combined three-failure-mode integration scenario (spec seeded condition 2)

- **Files:** one new test each in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py` (or a sibling) and `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts`.
- **Defect:** spec `## Seeded Test Conditions` item 2 requires a synthetic plan carrying one instance of each confirmed failure mode (G1 `.py`-path coverage argument, G5 interpolated/absent literal, G6 wrapped phrase) producing three distinct findings at their specified severities (one Blocking, two Warnings) in a single evaluation. No such combined fixture exists; each mode is covered only in isolation.
- **Fix:** add the combined-fixture test per runtime with a stub repository seam configured so G5 and G6 fire, asserting one G1 finding on the blocking channel and the G5 and G6 findings on the warnings channel in one call; then check off spec seeded-condition item 2.
- **Verification:** the named tests pass in both suites; `grep -n "^- \[x\] Integration scenarios" docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/spec.md` returns the checked line.

## Do Not Do

- Do not change `G5_SEVERITY` or any other severity constant, in either runtime.
- Do not modify `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, or any file under `.github/instructions/` in this cycle; keep the `extensions/drm-copilot/resources/claude-customizations/` mirrors byte-identical if any mirrored file is ever touched (none should be).
- Do not modify or regenerate `evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md` or any other committed evidence artifact.
- Do not weaken jest `coverageThreshold` entries or add any coverage `exclude` for a production path.
- No scope creep: no new gate rules, no severity-override mechanisms, no grandfathering lists (the rule file's "Scope of Invocation" section prohibits them).
- Write all new evidence to `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`; the `artifacts/baselines|qa|evidence|coverage` paths are forbidden.

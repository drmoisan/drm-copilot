# Remediation Inputs — reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486)

- Entry timestamp: 2026-08-20T17-11
- Cycle: 3
- Producing audit artifacts:
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/policy-audit.2026-08-20T17-11.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/code-review.2026-08-20T17-11.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/feature-audit.2026-08-20T17-11.md`
- Prior cycle: the cycle-2 Blocking finding (R5, `remediation-inputs.2026-08-20T16-10.md`) verified CLOSED by commit `450a8f47` (source inspection, named tests, independent reviewer probe, no coverage regression). M1 verified dispositioned as the potential entry `docs/features/potential/2026-08-20-plan-gate-nonzero-exit-seam-semantics.md`. This cycle addresses one new finding introduced by the R5 fix itself.
- Blocking finding count: **1** (R6). Minor items: 1 (N1, foldable into R6). Info items: 0.
- Handoff: per `remediation-handoff-atomic-planner`, the remediation plan is authored by `atomic-planner` from these inputs, preflighted by `atomic-executor`, executed task-by-task, and reaudited by `feature-review`.

## Remediation-Required Findings

### R6 (Blocking) — `plan_gate_discrimination.py` exceeds the 500-line production-file ceiling

- **File:** `scripts/dev_tools/plan_gate_discrimination.py` (505 lines at head `450a8f47`; 490 at `9e5c141d`; the cycle-2 guard extraction added 15 lines).
- **Policy:** `.claude/rules/general-code-change.md` § File Size Limit — "No production code, test code, or reusable script file may exceed 500 lines." No listed exception (throwaway script, raw text fixture, Markdown) applies.
- **Expected behavior after fix:** every production and test file on the branch is at or below 500 lines (`wc -l`); zero behavior change — every finding string, severity, cascade order, channel routing, and the public `evaluate_plan_gates` / `PlanGateContext` / `GitPlanGateRepository` surface is byte-identical in effect; both full suites pass unchanged; module and repo-wide coverage do not regress (floors: 98.28% lines / 90.54% branches on the gate logic taken together; repo-wide 92.59% / 85.16%).
- **Fix:** split the module by extracting one cohesive rule group into a sibling module under `scripts/dev_tools/` — either (a) the G5/G6 literal-rule functions (`_pattern_operand`, `_is_checkable_literal`, `_evaluate_literal_rules`, and their helpers) or (b) the G1-G4 coverage cascade (`_evaluate_cov_value`, `_evaluate_tracked_cov_value`, `_dotted_remedy`, and the `--cov` extraction helpers). Prefer whichever yields two files comfortably under the ceiling (target <= 450 each) with the fewest cross-module imports. Re-export nothing publicly beyond what callers already import from `plan_gate_discrimination`; keep `G5_SEVERITY` and every message constant importable from their current names (an internal `from` import in `plan_gate_discrimination` is acceptable).
- **Critical guard — parity-test target set:** `tests/scripts/dev_tools/test_plan_gate_parity.py` asserts the Python gate module contains neither `!r` nor `repr(`, and the TypeScript companion asserts no `pythonRepr(` in the three TS gate modules (`.claude/rules/plan-acceptance-gates.md` § Message Formatting). If finding-string code moves to a new module, extend the Python-side assertion to cover the new module as well (assert over the set of gate modules, not one file), so the prohibition cannot be silently escaped by the split. Do not weaken the assertion.
- **While in the file (Minor N1, folded):** have `_evaluate_cov_value` pass `truncated` into `_evaluate_tracked_cov_value` as a parameter instead of recomputing it inside the helper, matching the TypeScript signature (`evaluateTrackedCovValue(report, task, cov, truncated, context)`). Behaviorally identical; removes a duplicate computation and keeps the runtimes structurally aligned.
- **Tests to add/update:**
  - No new behavior, so no new behavioral test is required. Update the parity-test module-source assertion per the critical guard above if the split moves finding-string code.
  - Add or keep a simple import-surface check only if the planner deems it useful; the existing byte-identity, parity, and dispatch suites are the primary regression guard and must pass unchanged.
- **Verification commands (from the worktree root):**
  - `wc -l scripts/dev_tools/plan_gate_discrimination.py scripts/dev_tools/<new-module>.py` — both at or below 500 (target <= 450).
  - `poetry run pytest -q` — 4059+ passed, 0 failed, same 5 pre-existing skips.
  - `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov=scripts.dev_tools.<new-module> --cov-branch --cov-report=term-missing tests/scripts/dev_tools` — combined gate-logic coverage at or above 98.28% lines / 90.54% branches; no changed-line regression.
  - `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py -q` — parity and no-`repr` assertions pass against the post-split module set.
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md --workspace-root .` — exit 0 with the same two expected self-referential warnings, byte-identical messages.
  - From `extensions/drm-copilot`: `node run-jest.cjs` — TypeScript suite unchanged and green (no TS change is expected or permitted).
  - Full toolchain re-run per `atomic-plan-contract` final QA (black, ruff, pyright, pytest; prettier, eslint, tsc, jest) — all green in a single pass.

## Do Not Do

- Do not change any finding string, severity constant (`G5_SEVERITY` included), rule ordering, channel routing, guard placement, or the graceful-degradation behavior in either runtime.
- Do not modify any TypeScript production module (all TS gate modules are under the ceiling; largest is `plan-gate-rules.ts` at 437 lines).
- Do not modify `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, any file under `.github/instructions/`, or any `extensions/drm-copilot/resources/claude-customizations/` mirror.
- Do not weaken or narrow the parity-test no-`repr` assertions; extend them to the new module instead.
- Do not weaken jest `coverageThreshold` entries or add any coverage `exclude` for a production path.
- Do not modify or regenerate committed evidence artifacts from prior cycles.
- Do not reduce the split to a comment/docstring trim that squeezes under 500 without extracting logic; the policy remedy for an oversized module is extraction, and a trim would recreate the finding on the next edit.
- No scope creep: do not consume the M1 potential entry in this cycle; no new gate rules; no adapter exit-code rework.
- Write all new evidence to `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`; the `artifacts/baselines|qa|evidence|coverage` paths are forbidden.

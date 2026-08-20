# Remediation Inputs — reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486)

- Entry timestamp: 2026-08-20T16-10
- Cycle: 2
- Producing audit artifacts:
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/policy-audit.2026-08-20T16-10.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/code-review.2026-08-20T16-10.md`
  - `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/feature-audit.2026-08-20T16-10.md`
- Prior cycle: all four cycle-1 findings (R1-R4, `remediation-inputs.2026-08-20T14-09.md`) verified CLOSED by commit `9e5c141d`. This cycle addresses one new finding established by reviewer probe execution.
- Blocking finding count: **1** (R5). Minor items: 1 (M1, deferrable). Info items: 1 (AC10 checkbox note, resolves with R5).
- Handoff: per `remediation-handoff-atomic-planner`, the remediation plan is authored by `atomic-planner` from these inputs, preflighted by `atomic-executor`, executed task-by-task, and reaudited by `feature-review`.

## Remediation-Required Findings

### R5 (Blocking) — Python graceful-degradation guard omits the G2/G3 coverage path

- **File:** `scripts/dev_tools/plan_gate_discrimination.py`
- **Defect:** `_evaluate_cov_value` performs the G2/G3 tracked-tree lookups (`context.git.is_tracked_file(truncated + PYTHON_SUFFIX)` and `context.git.is_tracked_directory(truncated)`, currently lines 283-297) with no exception guard on the call path from `evaluate_plan_gates`. A repository seam that raises therefore escapes the evaluation entry point when the plan carries a path-separator `--cov` value. Reproduced by the reviewer with a stub adapter raising `RuntimeError` and the plan line `` `poetry run pytest --cov=scripts/dev_tools -q` ``: the exception propagated out of `evaluate_plan_gates`. The production path is reachable — `SubprocessRunner.run` suppresses only non-zero exits via `allow_error=True`, while `subprocess.run` itself raises (for example `FileNotFoundError` when `git` is not on `PATH`), and nothing between the adapter and CLI `main` catches on this path. This violates `.claude/rules/plan-acceptance-gates.md` § Graceful degradation ("No finding is produced and no exception escapes the evaluation entry point... A validation run must never fail because the repository could not be queried") and spec AC10, and it diverges from the TypeScript runtime, whose `plan-gate-rules.ts` wraps the equivalent lookups (`evaluateTrackedCovValue`, lines 236-241) in try/catch.
- **Expected behavior after fix:** with a context whose git adapter raises, a plan carrying a path-separator `--cov` value produces zero G2/G3 findings, no exception escapes `evaluate_plan_gates`, and the context-free rules (G1, G4) still report normally. The TypeScript runtime's behavior for the same inputs is unchanged, and the two runtimes agree.
- **Fix:** mirror the TypeScript structure. Extract the G2/G3 tracked-tree block of `_evaluate_cov_value` into a helper (for example `_evaluate_tracked_cov_value`) and invoke it inside a broad `try`/`except Exception: return` guard carrying the same contract comment used by `_evaluate_literal_rules` (spec AC10, graceful degradation). Do not change any finding string, severity, or the cascade order; G4 and G1 remain outside the guard because they are context-free.
- **Tests to add:**
  - Python: one named test (suggested `test_failing_git_adapter_skips_g2_g3_without_raising`, in `tests/scripts/dev_tools/test_plan_gate_discrimination_context.py` or the literals module) driving a raising git adapter through a plan whose acceptance command carries a path-separator `--cov` value, asserting `report.blocking == []` and `report.warnings == []` apart from the expected context-free G4 warning if the fixture uses the space-separated form (prefer the `=` form so both channels assert empty).
  - Python: extend the existing raising-adapter test fixture (or add a companion) so the degradation suite covers both rule groups (literal path and coverage path) explicitly.
  - Optional parity assertion: a shared-fixture case (raising seam + path-separator `--cov` value) asserting identical empty finding sets in both runtimes, if the parity harness supports seam injection; otherwise the per-runtime tests suffice.
- **Verification commands (from the worktree root):**
  - `poetry run pytest tests/scripts/dev_tools -q` — all tests pass including the new named test(s).
  - `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing tests/scripts/dev_tools` — module coverage does not regress from 98.21% lines / 90.54% branches.
  - From `extensions/drm-copilot`: `node run-jest.cjs` — TypeScript suite unchanged and green.
  - Full toolchain re-run per `atomic-plan-contract` final QA (black, ruff, pyright, pytest; prettier, eslint, tsc, jest) — all green in a single pass.
- **AC10 reconciliation:** once the guard lands and the named test passes, spec AC10's checked `[x]` state becomes accurate; no documentation edit is required. If the planner prefers an explicit record, a one-line addendum to AC10's verification sentence naming the new test is acceptable, but do not alter the criterion's meaning.

## Minor (deferrable, not blocking)

### M1 (Minor) — Non-zero-exit seam semantics diverge from the rule prose (both runtimes, identically)

- **Files:** `scripts/dev_tools/plan_gate_discrimination.py` (`GitPlanGateRepository`), `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` (TypeScript twin), `.claude/rules/plan-acceptance-gates.md` § Graceful degradation.
- **Observation:** the rule prose says a seam reporting a non-zero exit causes G2/G3/G5/G6 to be skipped with no finding; the shipped adapters translate every non-zero `git` exit into a negative answer, so a fatal `git` failure (exit 128) can yield a spurious G3 or G5 Warning instead of a skip. For `git grep`, exit 1 is the ordinary no-match answer, so the translation is partially correct by design. Impact is Warning-channel only and identical across runtimes.
- **Disposition:** advisory. Either distinguish fatal exits in both adapters (code > 1 for `git grep`; any non-zero for `ls-files`/`show`) in a later cycle with parity tests, or reconcile the rule-file prose to the shipped semantics. May be carried as a potential-entry rather than consumed by this cycle. Do not fold it into the R5 change unless the planner scopes it deliberately with both runtimes updated together.

## Do Not Do

- Do not change any finding string, severity constant (`G5_SEVERITY` included), rule ordering, or channel routing in either runtime.
- Do not modify `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, or any file under `.github/instructions/` in this cycle; keep the `extensions/drm-copilot/resources/claude-customizations/` mirrors byte-identical if any mirrored file is ever touched (none should be).
- Do not modify the TypeScript production modules — they already implement the required guard; the change is Python-side plus tests.
- Do not modify or regenerate committed evidence artifacts from prior cycles.
- Do not weaken jest `coverageThreshold` entries or add any coverage `exclude` for a production path.
- No scope creep: no new gate rules, no severity-override mechanisms, no grandfathering lists, and no adapter exit-code rework under R5 (that is M1, separately scoped or deferred).
- Write all new evidence to `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/<kind>/`; the `artifacts/baselines|qa|evidence|coverage` paths are forbidden.

# Code Review: reject-unfalsifiable-acceptance-gates-in-atomic-plans (Issue #486) — Remediation Cycle 3 Reaudit

**Review Date:** 2026-08-20
**Reviewer:** feature-review agent (delegated session, cycle-3 reaudit)
**Branch:** `feature/reject-unfalsifiable-acceptance-gates-in-atomic-plans-486` @ `afdbe62673a9b6686e84419f7d085f4b77258074`
**Base:** `main` @ merge-base `8092d391f50c44571145c73e161bbd1dafe0f035`
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` (read directly from the bundled path; this delegated session's tool set does not include the MCP server tools).

## Executive Summary

Scope is the full branch diff `8092d391..afdbe626` (6 commits, 145 files). The prior code reviews (`code-review.2026-08-20T14-09.md`, `16-10`, `17-11`) covered the feature implementation and cycles 1–2 in depth; this review re-verified those conclusions at the new head and reviewed the cycle-3 delta line by line: the new module `scripts/dev_tools/plan_gate_coverage.py` (243 lines), the reduction of `scripts/dev_tools/plan_gate_discrimination.py` (505 → 387 lines), and the generalized no-`repr` parity assertion in `tests/scripts/dev_tools/test_plan_gate_parity.py`.

The cycle-3 extraction is high quality. The G1–G4 cascade moved as a cohesive unit with byte-identical finding strings, unchanged cascade order and channel routing, and the graceful-degradation guard intact. The new module carries a complete contract docstring (purpose, scope boundary, invariants, side effects) and Google-style sections on every function; the reverse type dependency on `plan_gate_discrimination` is `TYPE_CHECKING`-gated, keeping the runtime import graph acyclic with exactly one edge. The N1 fold (passing `truncated` into `_evaluate_tracked_cov_value` instead of recomputing) aligns the Python signature with the TypeScript twin. The parity guard was strengthened, not just preserved: the assertion now iterates a named module set with per-module failure messages, and the executor committed a mutation fail/revert pair proving the generalized assertion actually reads the new module (`evidence/regression-testing/parity-guard-mutation-fail.2026-08-20T21-39.md`, `parity-guard-mutation-reverted.2026-08-20T21-39.md`).

The recorded helper-visibility deviation (public `is_placeholder`, `cov_values`, `evaluate_cov_value` instead of the plan's underscore-prefixed spelling) was judged on its merits and accepted: pyright strict `reportPrivateUsage` makes the private spelling unimplementable without a prohibited suppression or strictness reduction, the chosen names follow the `_parallel_state_common.py` precedent, module-internal helpers correctly keep their underscore prefixes, and the public surface of `plan_gate_discrimination` is unchanged. Toolchain: black, ruff, pyright (strict, 0 errors), pytest (4059 passed), prettier, eslint, tsc, jest (2645 passed) — all green this session at head `afdbe626`. No TypeScript file was touched by cycle 3 (verified by `git show --stat afdbe626`).

**Blockers: 0. Major: 0. Minor: 1. Info: 1.**

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev_tools/validate_orchestration_artifacts.py` | whole file (495 lines) | The dispatcher sits 5 lines under the 500-line production ceiling. Unchanged by cycle 3, but the R6 history on this branch shows a compliant file crossing the ceiling through an unrelated 15-line fix. | No change for this feature. Budget an extraction (for example, the per-artifact-type subparser registrations) before the next edit that adds lines to this file. | The 500-line ceiling in `.claude/rules/general-code-change.md` is enforced only at review time; a near-ceiling file converts any small future fix into a Blocking finding, as R6 demonstrated. | `wc -l scripts/dev_tools/validate_orchestration_artifacts.py` → 495 (this session). |
| Info | `.claude/rules/plan-acceptance-gates.md` | § Enforcement (first bullet) and header paragraph | The rule prose names `scripts/dev_tools/plan_gate_discrimination.py` as the evaluating module but does not mention the extracted sibling `scripts/dev_tools/plan_gate_coverage.py`, which now holds the G1–G4 cascade. Functionally still accurate (the named module remains the entry point and invokes the cascade), and the cycle-3 remediation inputs explicitly forbade editing the rule file, so the executor could not amend it in this cycle. | In a follow-up change, add a clause naming `plan_gate_coverage.py` alongside the extractor modules, and update the byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/`. | Rule prose is the artifact reviewers cite; naming the actual module layout avoids a future reviewer concluding the cascade is unimplemented in the named file. | Diff of `afdbe626`; `grep -n "plan_gate_discrimination" .claude/rules/plan-acceptance-gates.md`; remediation-inputs Do-Not-Do list. |

## Cycle-3 Delta Review Notes

- **Behavior preservation verified directly.** The six finding strings in the moved cascade were compared against the pre-split text in the `afdbe626` diff: byte-identical. Finding-string count conserved at six across the two modules (two in `plan_gate_discrimination.py`, four in `plan_gate_coverage.py`). The self-gate run against the committed plan reproduces the same two self-referential warnings with exit 0 (re-run this session).
- **Import hygiene.** `plan_gate_coverage.py` imports only `COV_FLAG`/`COV_FLAG_PREFIX` at runtime; `PlanCommand`, `PlanGateContext`, and `PlanGateReport` are `TYPE_CHECKING`-only. `plan_gate_discrimination.py` no longer defines `PLACEHOLDER_MARKERS`, `PATH_SEPARATORS`, `PYTHON_SUFFIX`, or `PYTEST_NODE_SEPARATOR`; the constants moved with their consumers. No duplicate definitions remain (grep this session).
- **Error handling.** The single broad `except Exception` moved intact and retains the contract comment citing spec AC10; `_evaluate_tracked_cov_value` documents that seam errors propagate to the caller's guard. This matches the documented graceful-degradation contract in `.claude/rules/plan-acceptance-gates.md`.
- **Coverage.** The extracted module measures 100.00% lines / 100.00% branches; the combined gate-logic figure (98.31% / 90.54%) meets the R6 floor with the identical miss set relocated, independently recomputed this session from `artifacts/python/lcov.info` (uncovered lines 208, 247, 276 in the post-split discrimination module).
- **Test delta.** Only the parity module changed. The assertion strengthening is the pattern the remediation inputs required ("assert over the set of gate modules, not one file") and the mutation evidence demonstrates discrimination — the strongest form of proof for a source-scanning guard.

## Verdict

No blockers. The cycle-3 remediation is complete, behavior-preserving, and verifiably strengthens the parity guard. Ready for PR authoring.

# Recorded Deviation — Cross-Module Helper Visibility in the R6 Split (Issue #486)

Timestamp: 2026-08-20T21-39
Related tasks: [P1-T1], [P1-T2], [P4-T3]
Scope: naming only. No behavior, finding string, severity, ordering, routing, or guard placement changed.

## What the plan text said

`[P1-T2]` names the runtime import line as
`from scripts.dev_tools.plan_gate_coverage import _cov_values, _evaluate_cov_value, _is_placeholder`,
that is, three underscore-prefixed names imported across a module boundary.

## What was implemented

The three cross-module symbols are defined and imported without the leading underscore:

```
from scripts.dev_tools.plan_gate_coverage import (
    cov_values,
    evaluate_cov_value,
    is_placeholder,
)
```

The two symbols that are used only inside `scripts/dev_tools/plan_gate_coverage.py` keep their
underscore prefix: `_dotted_remedy` and `_evaluate_tracked_cov_value`.

## Why the change was mechanically necessary

The plan's own `[P4-T3]` requires `poetry run pyright` to report zero errors, and the repository
gate matrix in `.claude/rules/quality-tiers.md` requires "Type errors: 0" uniformly. Pyright runs in
`typeCheckingMode = "strict"` (`pyproject.toml`). With the underscore-prefixed names as written, the
first pyright run after the split produced five errors:

```
scripts/dev_tools/plan_gate_coverage.py:90:5 - error: Function "_cov_values" is not accessed (reportUnusedFunction)
scripts/dev_tools/plan_gate_coverage.py:123:5 - error: Function "_evaluate_cov_value" is not accessed (reportUnusedFunction)
scripts/dev_tools/plan_gate_discrimination.py:35:5 - error: "_cov_values" is private and used outside of the module in which it is declared (reportPrivateUsage)
scripts/dev_tools/plan_gate_discrimination.py:36:5 - error: "_evaluate_cov_value" is private and used outside of the module in which it is declared (reportPrivateUsage)
scripts/dev_tools/plan_gate_discrimination.py:37:5 - error: "_is_placeholder" is private and used outside of the module in which it is declared (reportPrivateUsage)
```

Neither `.claude/rules/python.md` nor `.claude/rules/python-suppressions.md` authorizes a
`# type: ignore` for `reportPrivateUsage` or `reportUnusedFunction`, and `.claude/rules/python.md`
lists "Reducing typing strictness to make Pyright pass" as a Prohibited Behavior, so suppressing or
relaxing the check was not available. Renaming the three boundary-crossing symbols is the only
remedy that leaves both the strictness setting and the behavior untouched.

The chosen naming also matches the established repository convention for extracted validator helper
modules: `scripts/dev_tools/_parallel_state_common.py` exposes public function names
(`enum_error`, `item_context`, `validate_items`, `scan_prohibited_keys`) to
`scripts/dev_tools/validate_parallel_orchestrator_state.py` and reserves the underscore prefix for
module-internal helpers (`_validate_merge_status`, `_prohibited_key_errors`).

## Every stated acceptance criterion still passes verbatim

| Task | Acceptance command | Required | Observed |
| --- | --- | --- | --- |
| [P1-T1] | `grep -c -F "def _evaluate_tracked_cov_value" scripts/dev_tools/plan_gate_coverage.py` | exactly 1 | **1** |
| [P1-T1] | `grep -c -F "value.split(PYTEST_NODE_SEPARATOR" scripts/dev_tools/plan_gate_coverage.py` | exactly 1 | **1** |
| [P1-T2] | `grep -c -F "from scripts.dev_tools.plan_gate_coverage import" scripts/dev_tools/plan_gate_discrimination.py` | exactly 1 | **1** |
| [P1-T2] | `grep -c -F "def _evaluate_cov_value" scripts/dev_tools/plan_gate_discrimination.py` | 0, exit 1 | **0, exit 1** |

The deviation is confined to three identifiers that are internal to the two gate modules. No name in
the public surface changed: `evaluate_plan_gates`, `PlanGateReport`, `PlanGateContext`,
`PlanGateGitRepository`, `GitPlanGateRepository`, `build_plan_gate_context`, `G5_SEVERITY`,
`PlanCommand`, and `extract_plan_commands` are all still defined in or importable from
`scripts.dev_tools.plan_gate_discrimination` under their current names, verified by a direct import
smoke check that also confirmed `G5_SEVERITY == "warning"` is unchanged. No caller outside the two
modules imported any of the renamed helpers before the split, confirmed by a repository-wide search.

Output Summary: A naming-only deviation from the illustrative import line in `[P1-T2]` was required
to satisfy `[P4-T3]`'s zero-pyright-error acceptance without adding a prohibited suppression or
weakening strictness. All four stated Phase 1 acceptance criteria pass verbatim, the public surface
is unchanged, and the finding-string count is conserved at six across the two modules (two in
`plan_gate_discrimination.py`, four in `plan_gate_coverage.py`; six in the pre-split module).

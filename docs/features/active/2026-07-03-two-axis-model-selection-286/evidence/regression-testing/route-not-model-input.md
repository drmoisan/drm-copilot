# Route Is Not a Model-Selection Input

Timestamp: 2026-07-03T16-43

Command: `grep -rin "route" <config model_policy/model_budget> <reference impls> <validators> <skill Model Selection sections>`
EXIT_CODE: 0

## SearchScope

- `config/orchestration-routing.json` — `model_policy` and `model_budget` blocks only.
- `scripts/dev_tools/compute_complexity_floor.py`
- `scripts/dev_tools/resolve_delegation_model.py`
- `scripts/dev_tools/_orchestrator_state_complexity.py`
- `scripts/dev_tools/_orchestrator_state_model_routing.py`
- `.claude/skills/orchestrate/SKILL.md` (`## Model Selection` section)
- `.claude/skills/epic-orchestrate/SKILL.md` (`## Model Selection` section)

## SearchPatterns

- `route` (case-insensitive), scoped to model-selection code paths and documentation.

## SearchResult

No model-selection code path or documented rule *reads* `route`. `SearchResult: none` for any functional read of `route` in a model-selection path.

Every `route` occurrence found is an explicit negative assertion that `route` is NOT a model-selection input, which is the intended contract, not a violation:

- `resolve_delegation_model.py:30` (module docstring): "`route` is never an input to model selection; only `agent`, `band`, and `fable_policy` participate."
- `config/orchestration-routing.json` `model_policy.description`: "It is not a route input, and route is not an input to model selection."
- `orchestrate/SKILL.md` `## Model Selection`: "Model selection is a second axis, strictly separate from `route`. ... `route` is NOT an input to model selection anywhere."
- `epic-orchestrate/SKILL.md` `## Model Selection`: "`route` is never an input to model selection; `route` remains file-count driven and governs only agents, skills, and MCP tools."

The reference implementations take only `(agent, band, fable_policy)` (resolve) and `(signals_present)` (floor). The validators read only `complexity_assessments`/`model_routing_receipts` fields (`agent`, `complexity_band`, `fable_policy`, `table_model`, `clamped_from`, `model`, `band`, `floor`, `signals_present`, `rationale`). None consume `route`.

Determination: PASS. `complexity_band` is the sole feature-level input to the delegation model tier; `route` is not read anywhere in the model-selection path.

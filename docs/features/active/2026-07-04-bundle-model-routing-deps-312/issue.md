# bundle-model-routing-deps (Issue #312)

- Date captured: 2026-07-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundle-model-routing-deps/ (Issue #312)

- Issue: #312
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/312
- Last Updated: 2026-07-05
- Work Mode: full-bug

## Problem / Why

The distributed `orchestrate` skill (`.claude/skills/orchestrate/SKILL.md`) depends on
model-routing resources that live outside the `.claude/` tree and are therefore never
delivered by the `Push Down Claude Customizations` command. The push-down is hard-scoped to
the `.claude` tree (`scripts/dev_tools/push_down_claude_customizations.py:101`,
`ROOT_FOLDERS = (Path(".claude"),)`), and no pack manifest references `scripts/dev_tools/**`
or `config/orchestration-routing.json`. As a result, a destination that receives the
pushed-down customizations gets a skill that references missing files, breaking model-routing
reconciliation and orchestrator-state validation in that destination.

Missing-in-destination dependencies referenced by the skill:

- `scripts/dev_tools/compute_complexity_floor.py` (pure; no config read)
- `scripts/dev_tools/resolve_delegation_model.py` (pure; no config read)
- `scripts/dev_tools/_orchestrator_state_complexity.py`
- `scripts/dev_tools/_orchestrator_state_model_routing.py`
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`
- `config/orchestration-routing.json` (`model_policy` / `model_budget`; authoritative-source
  document, not a runtime dependency of the two pure scripts)

## Proposed Behavior

Relocate the model-routing dependencies under `.claude/` (Option 1) so they travel with the
`.claude`-only push-down. Update skill references, validator import paths, and the `core` pack
manifest accordingly. After the change, a push-down of the `.claude` customizations delivers a
self-contained `orchestrate` skill with all model-routing dependencies present in the
destination.

## Acceptance Criteria (early draft)

- [ ] The model-routing dependency files are reachable under `.claude/` and are delivered by
      the `.claude`-only push-down.
- [ ] The `orchestrate` skill references and validator import paths resolve to the relocated
      locations with no broken references.
- [ ] The `core` pack manifest lists the relocated dependencies.
- [ ] All existing tests under `tests/scripts/dev_tools/` pass against the new locations, and
      the full toolchain (format, lint, type-check, test) passes in a single pass.

## Constraints & Risks

- Relocating the two reference scripts breaks `scripts.dev_tools.*` package imports consumed by
  `validate_orchestrator_state.py`, the three `_orchestrator_state_*` helpers, and roughly five
  test files under `tests/scripts/dev_tools/`, plus the bundled mirror and pack manifest.
- Research must resolve the relocate-vs-mirror design tradeoff: (a) physically move under
  `.claude/` and rewrite all `scripts.dev_tools` imports, versus (b) mirror copies under
  `.claude/` delivered by push-down while originals stay put (adds parity-maintenance burden).
- Change budget is LARGE (cross-cutting).

## Test Conditions to Consider

- [ ] Import resolution for validator and helper modules from the relocated paths.
- [ ] Push-down delivery test confirming the dependencies land in the destination.
- [ ] Pack-manifest coverage test confirming the relocated paths are listed.

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Create `docs/features/active/bundle-model-routing-deps/` folder from the template

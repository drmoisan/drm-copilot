# In-File Documentation Updated (P6-T8, spec AC14)

Timestamp: 2026-10-16T01-06
Command: grep -n -F -e 'per-feature receipt' scripts/dev_tools/validate_epic_planner_state.py; grep -n -F -e 'per-feature receipt' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
EXIT_CODE: 0
Output Summary:
Python match lines (3):
- 264:    When ``key_gated`` is true (no Codex flag), each per-feature receipt check   (inside the `_validate_ready_features` docstring)
- 308:    evidence, the per-feature receipt checks, and the planner ``topology_receipt``   (inside the `validate_epic_planner_state_text` docstring)
- 350:        # Launch evidence and the per-feature receipt checks   (comment above `key_gated`, line 354)

TypeScript match lines (2):
- 293: * `keyGated` is true (no Codex flag), each per-feature receipt check runs only   (inside the `validateReadyFeatures` JSDoc)
- 433:    // Launch evidence and the per-feature receipt checks   (comment above `requireLaunchPaths`)

Reading confirmation: each of the five docstrings or comments was read in full. Each names `model_routing_receipt` and `topology_receipt` and states that the per-feature receipt checks are key-gated (run only for a feature carrying the key) when no Codex flag is asserted: the two ready-feature docstrings state this through "When key_gated/keyGated is true (no Codex flag)", the `validate_epic_planner_state_text` docstring states that the Codex flags make the checks unconditional and that without them each check runs only for features that carry that key, and both comments state "key-gated per feature ... unless a Codex flag is asserted".

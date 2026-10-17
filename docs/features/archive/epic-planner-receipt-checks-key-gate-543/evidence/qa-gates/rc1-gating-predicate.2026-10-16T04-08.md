# Remediation Cycle 1 Gating Predicate and Call Sites (P4-T3)

Timestamp: 2026-10-16T04-08
Command: grep -n -F -e 'if not key_gated or "model_routing_receipt" in feature:' -e 'if not key_gated or "topology_receipt" in feature:' -e 'errors.extend(_validate_ready_features(indexed_features, key_gated=key_gated))' -e 'indexed_features: list[tuple[int, dict[str, Any]]], *, key_gated: bool = False' -e 'for index, feature in indexed_features:' -e 'checkpoint_entries, require_launch_paths=key_gated' scripts/dev_tools/validate_epic_planner_state.py; grep -n -F -e 'if (!keyGated || "model_routing_receipt" in feature) {' -e 'if (!keyGated || "topology_receipt" in feature) {' -e 'keyGated: boolean,' -e 'indexedFeatures.forEach(([index, feature]) => {' -e 'requireLaunchPaths,' -e 'featureResult.entries, {' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts; source read around each match
EXIT_CODE: 0
Output Summary:
Python (9 match lines):
- 171: for index, feature in indexed_features:  (dependency-wave uniqueness loop)
- 186: for index, feature in indexed_features:  (dependency-wave resolution loop)
- 214: for index, feature in indexed_features:  (dependency-wave wave loop)
- 265: indexed_features: list[tuple[int, dict[str, Any]]], *, key_gated: bool = False  (ready-gate parameter line)
- 278: for index, feature in indexed_features:  (ready-gate per-feature loop)
- 291: if not key_gated or "model_routing_receipt" in feature:
- 293: if not key_gated or "topology_receipt" in feature:
- 374: errors.extend(_validate_ready_features(indexed_features, key_gated=key_gated))
- 377: checkpoint_entries, require_launch_paths=key_gated  (launch-binding argument line)
TypeScript (9 match lines):
- 219: indexedFeatures.forEach(([index, feature]) => {  (dependency-wave uniqueness loop)
- 278: indexedFeatures.forEach(([index, feature]) => {  (dependency-wave wave loop)
- 303: keyGated: boolean,
- 312: indexedFeatures.forEach(([index, feature]) => {  (ready-gate per-feature loop)
- 339: if (!keyGated || "model_routing_receipt" in feature) {
- 367: if (!keyGated || "topology_receipt" in feature) {
- 457: requireLaunchPaths,  (second argument of the wrapped validateReadyFeatures( call)
- 461: ...validateEpicPlannerChildLaunchBindings(featureResult.entries, {
- 462: requireLaunchPaths,  (launch-binding options object)
Reading confirmation: both gates sit inside the per-feature loop (Python loop at 278, gates at 291/293; TypeScript forEach at 312, gates at 339/367). The Python ready call passes key_gated=key_gated; the TypeScript ready call passes requireLaunchPaths. Both launch-binding calls still pass the key-gate flag (require_launch_paths=key_gated / { requireLaunchPaths }). The non-Codex per-feature checks are not conditioned (spec AC10 holds).

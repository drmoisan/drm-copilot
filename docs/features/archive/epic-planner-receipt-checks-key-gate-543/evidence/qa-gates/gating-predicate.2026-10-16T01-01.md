# Gating Predicate Verification (P6-T1, spec AC10)

Timestamp: 2026-10-16T01-01
Command: grep -n -F -e 'if not key_gated or "model_routing_receipt" in feature:' -e 'if not key_gated or "topology_receipt" in feature:' -e 'errors.extend(_validate_ready_features(features, key_gated=key_gated))' -e 'features: list[dict[str, Any]], *, key_gated: bool = False' scripts/dev_tools/validate_epic_planner_state.py; grep -n -F -e 'if (!keyGated || "model_routing_receipt" in feature) {' -e 'if (!keyGated || "topology_receipt" in feature) {' -e '...validateReadyFeatures(featureResult.features, requireLaunchPaths),' -e 'keyGated: boolean,' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
EXIT_CODE: 0
Output Summary:
Python match lines (4; exit 0):
- 260:    features: list[dict[str, Any]], *, key_gated: bool = False
- 285:        if not key_gated or "model_routing_receipt" in feature:
- 287:        if not key_gated or "topology_receipt" in feature:
- 364:        errors.extend(_validate_ready_features(features, key_gated=key_gated))

TypeScript match lines (4; exit 0):
- 299:  keyGated: boolean,
- 335:    if (!keyGated || "model_routing_receipt" in feature) {
- 363:    if (!keyGated || "topology_receipt" in feature) {
- 451:      ...validateReadyFeatures(featureResult.features, requireLaunchPaths),

Source-reading confirmation:
- Python: lines 285 and 287 sit inside `for index, feature in enumerate(features):` (line 272) of `_validate_ready_features`. The model block (line 286) only calls `_validate_feature_model_receipt(feature, prefix=prefix)`, whose body holds only the model-receipt checks; the topology block (lines 288-293) holds only the `_validate_child_topology_receipt` call. The call site at line 364 passes `key_gated=key_gated` (computed at line 354 from the Codex flags).
- TypeScript: lines 335 and 363 sit inside `features.forEach((feature, index) => {` (line 308) of `validateReadyFeatures`. The model block (lines 336-361) holds only the model-receipt checks; the topology block (lines 364-369) holds only the `validateChildTopologyReceipt` push. The call site at line 451 passes `requireLaunchPaths` as `keyGated`.
- Both runtimes: the issue_num, feature_folder, research_path, plan_path, preparation_status, and preflight_status checks and the at-least-two-features check carry no new condition. Presence uses key membership (`in`), not value truthiness.

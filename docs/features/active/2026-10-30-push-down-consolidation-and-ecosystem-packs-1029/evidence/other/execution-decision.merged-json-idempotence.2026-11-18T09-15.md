# Execution Decision: Merged JSON Paths Skip a JSON-Equivalent Write

Timestamp: 2026-11-18T09-15
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension (probe over the tree with the P4-T4 real-bundle suite)
EXIT_CODE: 1
Output Summary: The real-bundle case `second apply is a no-op` failed for all three ecosystems: the second apply rewrote `config/orchestration-routing.json`. On the first apply the destination has no routing document, so `RoutingMergeFileSystem` writes the bundle text unchanged (pinned behavior, D2). On the second apply it writes the merged document re-serialized as two-space `JSON.stringify` output, which differs from the bundle's formatting even though the JSON value is identical, so the write-if-changed base did not skip it. That breaks spec Behavior 12 (idempotence, O-11).

## Decision

Recommended option, taken under OD-1 and the cost-benefit rule (OD-4): `WriteIfChangedFileSystem` takes an optional `jsonEquivalentPaths` list. For those paths only, a write is also skipped when the current and new texts parse to the same JSON value. Each layer builder (`buildSharedLayer`, `buildCodexLayer`, `composeClaudeLayer`) passes its merged paths. New tests: `skips a JSON-equivalent write only for a merged JSON path` and `writes a merged JSON path whose value changed or does not parse`. After the change the push-down selection passes except the two named P4-T1 completeness cases, which fail by design until P4-T2 and P4-T3.

## Reason

- Merged paths have no manifest entry, so skipping a formatting-only rewrite cannot create a conflict or a stale hash.
- Payload files keep exact-text comparison, so an `update` is never skipped.
- Changing `RoutingMergeFileSystem` instead would alter behavior pinned by the routing-merge parity tests and the Python port.
- The alternative of accepting a rewrite on the second run fails Behavior 12.

## P4-T1 test placement

The P4-T1 completeness test was drafted early and fails by design until P4-T2 and P4-T3. It was moved to `SCRATCH` and is restored when P4-T1 runs, so the Phase 2 and Phase 3 gates do not carry a later phase's expected failures.

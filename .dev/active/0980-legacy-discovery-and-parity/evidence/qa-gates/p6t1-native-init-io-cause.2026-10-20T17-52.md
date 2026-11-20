Timestamp: 2026-10-20T17-52
Command: `SCRATCH/issue-980-p6t1-gateway-init-io-finding.py`
EXIT_CODE: 0
Output Summary: NIO1 production root-identity mismatch established without service replay.

The retained Windows request uses backslashes. The installed local factory stores the same trusted root with forward slashes. Core pure-path comparison accepts the identity; local authorization compares raw strings and raises PermissionError before bootstrap. The observed SERVICE_IO envelope is the expected classification of that pre-context failure.

Repair scope: `path_policy.py` (bounded public exposure of the existing canonical parser), `gateway_local.py` (three root comparisons), and `test_gateway_boundaries.py` (equivalence and invalid/distinct-root controls). Preserve POSIX semantics and all host-marker refusals. No implementation or behavior was changed by this diagnosis.

Exact retained evidence, source bindings, metadata facts and required controls: `p6t1-native-init-io-cause.2026-10-20T17-52.json`.

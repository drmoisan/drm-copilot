Timestamp: 2026-08-25T22-31
Command: SHA-256 equality comparison of `config/orchestration-routing.json` and its bundled resource, plus every root/bundled `.codex/agents/commit-steward*.toml` pair.
EXIT_CODE: 0
Output Summary: The root and bundled routing configuration is byte-identical. All six root/bundled commit-steward profile pairs are byte-identical. This source-only revision has not invoked customization publication or modified a bundled runtime payload.

Results:
- Routing configuration: equal.
- `commit-steward-c1.toml`: equal.
- `commit-steward-c2.toml`: equal.
- `commit-steward-c3-elevated.toml`: equal.
- `commit-steward-c3.toml`: equal.
- `commit-steward-c4.toml`: equal.
- `commit-steward.toml`: equal.

The initial byte-array comparison command failed because the available PowerShell runtime does not expose `AsSpan()` on the pipeline-enumerated byte values. The SHA-256 comparison above completed successfully and did not alter files.

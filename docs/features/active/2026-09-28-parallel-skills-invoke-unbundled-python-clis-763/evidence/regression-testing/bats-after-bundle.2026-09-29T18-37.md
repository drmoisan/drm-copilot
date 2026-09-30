# Local Bats Suites After the Bundle Update (P5-T10)

Timestamp: 2026-09-29T18-37
Command: npx --yes bats tests/shell/parallel_abandon.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_ba?h_manifest_membership.bats
EXIT_CODE: 0
Output Summary:
- TAP plan `1..34`; 34 `ok` lines; no `not ok` line.
- `tests/shell/parallel_abandon.bats`: ok 1-14 (all 14 tests).
- B29 tests: `ok 26 the payload directory carries the abandon entry point`,
  `ok 27 the abandon shim PATH exposes no Python interpreter`,
  `ok 28 the payload abandons an item without Python on PATH`.
- B30 test: `ok 34 the five CLI entry points are present in both trees`.
- The P0-T20 local baseline failure set is empty, and no `not ok` line appears here.

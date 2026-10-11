# Phase 3 Parity and Manifest-Completeness Tests (issue #897, epic child E1)

Timestamp: 2026-10-11T12-59
Task: [P3-T7]

## Python parity tests

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py -v`
EXIT_CODE: 0
Output Summary: `22 passed in 0.26s`; every node PASSED. No failure, so no register comparison was needed.

Recorded statuses:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` PASSED
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` PASSED
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest` PASSED
- all 14 nodes of `test_push_down_claude_resource_contracts.py` PASSED; all 6 nodes of `test_claude_planning_integrity_contracts.py` PASSED (same node list as `evidence/baseline/p0-pytest-parity.md`).

## Jest manifest-completeness test

Command: `npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts` (run from `extensions/drm-copilot`)
EXIT_CODE: 0
Output Summary: `Tests:       16 passed, 16 total`; 1 suite passed; no failing test.

```text
Test Suites: 1 passed, 1 total
Tests:       16 passed, 16 total
Snapshots:   0 total
Time:        0.232 s, estimated 1 s
```

## [P3-T6] manifest checks

Command: `Get-Content -Raw extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | ConvertFrom-Json`; count of `paths` entries equal to `.claude/hooks/subagentstop-envelope.ps1`; `(Get-Content <manifest>).Count`.
EXIT_CODE: 0
Output Summary: JSON parses; `paths` contains `.claude/hooks/subagentstop-envelope.ps1` exactly once (217 paths total); line count 223 = [P0-T5] value 222 + 1; the entry sits at line 68 immediately after `".claude/hooks/persist-session-id.ps1",` and before `".claude/hooks/validate-bash.ps1",`.

```text
JSON_PARSE: ok
PATHS_COUNT: 217
HELPER_ENTRIES: 1
LINES: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | 223
INSERT_LINE: 68
PREV_LINE: ".claude/hooks/persist-session-id.ps1",
NEXT_LINE: ".claude/hooks/validate-bash.ps1",
```

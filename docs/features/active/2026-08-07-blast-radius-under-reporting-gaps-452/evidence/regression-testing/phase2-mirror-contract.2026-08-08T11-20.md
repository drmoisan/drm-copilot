# Phase 2 — Bundled-Mirror Contract Verification

Timestamp: 2026-08-08T11-20
Task: [P2-T6]

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

EXIT_CODE: 0

## Raw output

```
collected 7 items

test_bundled_claude_payload_contains_required_runtime_files PASSED       [ 14%]
test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED   [ 28%]
test_pack_manifests_are_outside_the_parity_scope PASSED                  [ 42%]
test_bundled_claude_payload_excludes_settings_local_json PASSED          [ 57%]
test_bundled_claude_payload_excludes_variant_subtree_from_parity PASSED  [ 71%]
test_variant_subtree_is_bundle_only_and_non_colliding PASSED             [ 85%]
test_bundled_agent_memory_scopes_are_well_formed PASSED                  [100%]

7 passed in 0.14s
```

## Supporting byte-identity check performed at [P2-T3]

| File | Repo bytes | Mirror bytes | SHA-256 (first 16) | Identical | CRLF |
| --- | ---: | ---: | --- | --- | --- |
| `BlastRadiusExtraction.psm1` | 17499 | 17499 | `da8194d03e0bedd2` | yes | no |
| `BlastRadiusGlob.psm1` | 13234 | 13234 | `a0241d6c1fcd6db6` | yes | no |

The comparison hashes raw bytes, so line endings are part of the identity check. Both files are
LF-only on both sides.

Output Summary: EXIT_CODE 0 with 7 passed and 0 failed.
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` — the test that enforces content
identity, not mere existence, between `.claude/**` and
`extensions/drm-copilot/resources/claude-customizations/.claude/**` — PASSED. Both modules edited
in Phase 2 have content-identical bundled counterparts, confirmed independently by SHA-256 over
raw bytes.

# Change-Set Line Counts (P7-T3, AC20)

Timestamp: 2026-09-29T17-58
Command: wc -l <the 16 non-JSON code and test paths of the Execution Conventions change set, listed below>
EXIT_CODE: 0

Output Summary:
- 16 counts recorded; every count is below 500 (maximum 444).

Production (6):
- scripts/dev_tools/push_down_claude_routing_merge.py: 155
- scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py: 238
- scripts/dev_tools/push_down_claude_blast_radius_derive_core.py: 231
- scripts/dev_tools/push_down_claude_blast_radius_derive.py: 153
- scripts/dev_tools/push_down_claude_destination_writes.py: 314
- scripts/dev_tools/push_down_claude_customizations.py: 444 (baseline 403)

Tests (10):
- tests/scripts/dev_tools/test_push_down_claude_parity.py: 438
- tests/scripts/dev_tools/test_push_down_claude_routing_merge.py: 259
- tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_manifests.py: 211
- tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py: 282
- tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core_guard.py: 103
- tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive.py: 193
- tests/scripts/dev_tools/test_push_down_claude_destination_writes.py: 407
- tests/scripts/dev_tools/test_push_down_claude_config_carriage.py: 258
- extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts: 164
- tests/scripts/dev_tools/test_push_down_claude_customizations.py: 284 (baseline 284)

Excepted by AC20: tests/fixtures/push_down/routing-merge-parity.json (JSON fixture) and Markdown files.

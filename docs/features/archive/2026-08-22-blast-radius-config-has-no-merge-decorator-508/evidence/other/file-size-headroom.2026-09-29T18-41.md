# File-Size Headroom (P0-T10)

Timestamp: 2026-09-29T18-41
Command: wc -l extensions/drm-copilot/src/lib/push-down/claude-customizations.ts extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_destination_writes.py; test -e tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py
EXIT_CODE: 0
Output Summary:
```
  361 extensions/drm-copilot/src/lib/push-down/claude-customizations.ts
  311 extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts
  461 extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts
  254 extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts
  288 extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts
  444 scripts/dev_tools/push_down_claude_customizations.py
  314 scripts/dev_tools/push_down_claude_destination_writes.py   (REGISTRY_MODULE)
 2433 total
```
- PARITY_TARGET (tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py) does not exist yet (`test -e` exit 1); no count.
- claude-config-carriage.test.ts: 461, equal to the planning-time value.

P1_T1_LINE_ALLOWANCE: 35   (496 - 461)
REGISTRY_MODULE_LINE_ALLOWANCE: 186   (500 - 314)
Gate result: PASS (35 >= 28; 186 >= 60)

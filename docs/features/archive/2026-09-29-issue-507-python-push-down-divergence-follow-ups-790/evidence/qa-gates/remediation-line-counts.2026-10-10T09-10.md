# P3-T1 Per-File Physical Line Counts (AC-19)

Timestamp: 2026-10-10T09-10
Command: wc -l scripts/dev_tools/push_down_claude_gitignore_merge.py scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/push_down_claude_pack_selection.py scripts/dev_tools/push_down_claude_filesystem.py extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts tests/fixtures/push_down/gitignore-merge-parity.json tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
- 176 scripts/dev_tools/push_down_claude_gitignore_merge.py
- 461 scripts/dev_tools/push_down_claude_customizations.py
- 442 scripts/dev_tools/push_down_claude_pack_selection.py
- 489 scripts/dev_tools/push_down_claude_filesystem.py
- 332 extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts
- 59 tests/fixtures/push_down/gitignore-merge-parity.json
- 229 tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py
- 69 tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py
- 325 tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py
- 458 tests/scripts/dev_tools/test_push_down_claude_customizations.py
- 488 tests/scripts/dev_tools/test_push_down_claude_parity.py
- 417 tests/scripts/dev_tools/test_push_down_claude_pack_selection.py
- 447 tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py (TEST-FILE: greater than 390, at most 500)
- 131 extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts
- 412 extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts
- 483 extensions/drm-copilot/jest.config.cjs
Comparison with evidence/qa-gates/line-counts.2026-10-10T08-30.md, line by line: the 15 shared files are identical (customizations is 458); the only new row is TEST-FILE at 447. Maximum per-file count: 489. Every count is at most 500. Result: PASS.

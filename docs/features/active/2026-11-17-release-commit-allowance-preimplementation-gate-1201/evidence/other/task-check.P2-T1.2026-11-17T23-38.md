# Task check - P2-T1

Timestamp: 2026-11-17T23-38
Changed files:
- extensions/drm-copilot/src/lib/push-down/claude-customizations.ts: `EXCLUDED_RELATIVE_PATHS` gains `.claude/release-commit-allowance.json` (497 lines).
- scripts/dev_tools/push_down_claude_customizations.py: the `EXCLUDED_RELATIVE_PATHS` tuple gains `Path(".claude/release-commit-allowance.json")` (one tuple entry; no new Python module or test).
- extensions/drm-copilot/test/lib/push-down/claude-customizations-release-allowance.test.ts (new): AC-25 constant row; AC-26 rows with no pack selection and with `packs: new Set(["core"])` (the seeded core manifest lists the allowance path, so the row would publish the file without the exclusion).
Selection rule: the mirrored Jest file of the changed TypeScript file plus the new Jest file; the Python test that reads the Python tuple (test_push_down_claude_overlay_parity.py).

Commands:
1. Command: sh SCRATCH/issue-1201-static-py-ts.sh tc-p2t1 (Black check, Ruff, Pyright on the Python file; Prettier check, ESLint, TSC for extensions/drm-copilot)
   EXIT_CODE: 0 (each of the 7 steps); findings 0.
2. Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=push-down/claude-customizations(-release-allowance)?\.test\.ts" --json --outputFile=SCRATCH/issue-1201-tc-p2t1-jest.json
   EXIT_CODE: 0
   Output Summary: Test Suites 2 passed of 2 (claude-customizations.test.ts unmodified and the new file, both named in the JSON results); Tests 17 passed of 17; the three new tests report status passed.
3. Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py
   EXIT_CODE: 0
   Output Summary: 5 passed (unmodified).
The coverageThreshold entry of claude-customizations.ts is checked by the P2-T5 Jest coverage gate.

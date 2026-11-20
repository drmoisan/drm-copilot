Timestamp: 2026-11-19T15-46
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=lcov --coverageReporters=text-summary
EXIT_CODE: 0
Output Summary: Phase 0 baseline of the extension Jest gate (one run, normal parallel workers). Test Suites: 376 passed, 376 total; Tests: 6208 passed, 6208 total; 0 failed. Pre-existing failures: none.
Repo-wide coverage (extensions/drm-copilot/coverage/lcov.info): lines 97.44% (69097/70909), branches 94.67% (10720/11324).
Per-file coverage of EDITED-TS (read from extensions/drm-copilot/coverage/lcov.info):
- src/mcp-tools.ts: lines 96.86% (463/478), branches 93.14% (95/102)
- src/mcp-tool-definitions.ts: lines 100.00% (471/471), branches 100% (no branches)
- src/mcp-repo-automation-tool-definitions.ts: lines 100.00% (434/434), branches 100% (no branches)
- src/repo-automation-tool-names.ts: lines 100.00% (53/53), branches 100% (no branches)
- src/repo-automation-service.ts: lines 100.00% (494/494), branches 93.75% (45/48)
- src/repo-automation-service-contract.ts: no executable lines (type-only module; the v8 provider lists 0/327 lines because the module is never loaded at runtime)
- src/lib/push-down/push-down-harness.ts: lines 100.00% (292/292), branches 96.92% (63/65)
- src/lib/push-down/push-down-ecosystem-registry.ts: lines 100.00% (152/152), branches 100.00% (16/16)

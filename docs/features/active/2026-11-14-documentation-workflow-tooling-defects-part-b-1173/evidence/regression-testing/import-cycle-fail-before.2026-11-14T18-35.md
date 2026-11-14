# Fail-Before: Import Cycle Between the Docs Input Modules (P1-T1)

Timestamp: 2026-11-14T18-35
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --testPathPatterns=import-graph --verbose
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: current head with the new test file extensions/drm-copilot/test/mcp-tool-inputs-docs.import-graph.test.ts and no production change.
- Test Suites: 1 failed, 1 total. Tests: 3 failed, 1 passed, 4 total.
- PASS (by design): reports a two-module cycle in an in-memory graph.
- FAIL (by design): has no import cycle reachable from mcp-tool-inputs-docs.ts; received "mcp-tool-inputs-docs.ts -> mcp-tool-inputs-docs-ledger-batch.ts -> mcp-tool-inputs-docs.ts".
- FAIL (by design): has no import cycle reachable from mcp-tool-inputs-docs-ledger-batch.ts; received "mcp-tool-inputs-docs-ledger-batch.ts -> mcp-tool-inputs-docs.ts -> mcp-tool-inputs-docs-ledger-batch.ts".
- FAIL (by design): keeps mcp-tool-inputs-docs-grammar.ts free of imports of either docs input module; "module mcp-tool-inputs-docs-grammar.ts cannot be read." (module absent).

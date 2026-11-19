Timestamp: 2026-11-19T17-09
Task: [P2-T3]
Changed files:
- Registration lines only (C6): extensions/drm-copilot/src/repo-automation-tool-names.ts (two names after validate_docs_artifacts; 53 to 55 lines), src/mcp-repo-automation-tool-definitions.ts and src/mcp-tool-definitions.ts (one import and one spread after ...DOCS_TOOL_DEFINITIONS each; 434 to 436 and 471 to 473 lines), src/mcp-tools.ts (imports, the optional `integration` field and two case lines; 478 to 488 lines), src/repo-automation-service-contract.ts (imports and two optional methods; 327 to 338 lines), src/repo-automation-service.ts (imports and two delegations; 494 to 513 lines).
- New: src/mcp-handlers/push-down-integration-handlers.ts, src/repo-automation-service-push-down-integration.ts, test/mcp-handlers/push-down-integration-handlers.test.ts, test/repo-automation-service-push-down-integration-tools.test.ts (file name per DEV-1 in evidence/other/deviations.2026-11-19T16-52.md).
- S46 cases added to test/mcp-push-down-integration-tool-definitions.test.ts.
- Existing tests updated: test/mcp-server-test-service.ts (`EXPECTED_REPO_AUTOMATION_TOOL_NAMES` gains both names after validate_docs_artifacts; count comment 49 to 51), test/mcp-discovery-authority-tool-definitions.test.ts (`advertises all nineteen discovery tools in union order`: REPO_AUTOMATION_TOOLS length pin 49 to 51), test/mcp-docs-tool-definitions.test.ts (`spreads the same definition objects into both definition surfaces`: next name after the docs slice is detect_push_down_integration).
- Existing tests unchanged and passing: registers the semantic repo automation tools (through the updated list), defines one schema entry for every advertised repo automation tool, declares the same input-schema properties and required arrays on both tool-definition surfaces, lists workspace_root in inputSchema.required for every repo automation tool (all 28), mcp-discovery-tool-definitions.test.ts, exposes one shared tool set to the standalone server and the extension provider.
Selection: every Jest test path matching `mcp`, `repo-automation`, `push-down-integration` or `packaging` (each test that imports a changed registration module, the new modules, or the packaging contracts); rule: atomic-plan-contract Test Cadence task check.
Commands and exit codes (from extensions/drm-copilot through the SCRATCH task-check script):
- npx prettier --write, then npx prettier --check <changed files>: EXIT_CODE 0
- npx eslint <changed files>: EXIT_CODE 0
- npx tsc -p ./ --noEmit && npx tsc -p tsconfig.jest.json --noEmit: EXIT_CODE 0
- First Jest run (after seven queue timeouts with exit 75): EXIT_CODE 1, Test Suites: 1 failed, 77 passed; the new handler test lacked the virtual `vscode` module mock that mcp-tools tests use (Cannot find module 'vscode' from 'src/command-runtime.ts'). Fixed by adding `jest.mock("vscode", () => ({}), { virtual: true })`.
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension mcp repo-automation push-down-integration packaging: EXIT_CODE 0 (Test Suites: 78 passed, 78 total; Tests: 961 passed, 961 total)
Rule tokens: push-down-integration-handlers.test.ts holds S42, S45 and S47; repo-automation-service-push-down-integration-tools.test.ts holds S48; mcp-push-down-integration-tool-definitions.test.ts holds S46 (positive and negative each).
EXIT_CODE: 0
Output Summary: task check passed.

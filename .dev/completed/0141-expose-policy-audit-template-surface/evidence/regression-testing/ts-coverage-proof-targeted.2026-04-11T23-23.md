Timestamp: 2026-04-11T23:58:47-04:00
Command: node run-jest.cjs --runTestsByPath test/mcp-tool-inputs.test.ts test/mcp-server.test.ts test/workflow-command-arguments.test.ts --coverage --coverageReporters=text-summary --coverageReporters=json-summary
EXIT_CODE: 0
Output Summary:
- Passed targeted suites:
  - `test/mcp-tool-inputs.test.ts`
  - `test/mcp-server.test.ts`
  - `test/workflow-command-arguments.test.ts`
- Targeted Jest result: `3/3` suites passed, `78/78` tests passed, `0` failed.
- Coverage headline values from the focused run:
  - Statements: `67.31%` (`1823/2708`)
  - Branches: `79.11%` (`125/158`)
  - Functions: `52.63%` (`50/95`)
  - Lines: `67.31%` (`1823/2708`)
- Produced a fresh `extensions/drm-copilot/coverage/lcov.info`.
- Focused proof result against the refreshed executable inventory in `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/ts-changed-line-inventory.2026-04-11T22-54.md`:
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`: `PASS` (`31/31` executable changed lines covered)
  - `extensions/drm-copilot/src/mcp-tools.ts`: `PASS` (`36/36` executable changed lines covered)
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`: `PASS` (`31/31` executable changed lines covered)
- The targeted run removed the executable uncovered lines identified in `P0-T2`. Remaining structural exclusions are documented in `ts-coverage-proof-basis.2026-04-11T23-23.md`.

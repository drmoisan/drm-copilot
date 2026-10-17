# P2-T2 [expect-fail] TypeScript parity reader against the unfixed validator

Timestamp: 2026-09-30T07-35
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-promotion-type-parity.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Tests:       4 failed, 11 passed, 15 total`; `Test Suites: 1 failed, 1 total`.
- The four failing cases:
  - bug-large-bug-tool-declared-and-recorded
  - bug-large-feature-tool-only
  - bug-small-bug-tool-declared-and-recorded
  - bug-preparation-bug-tool-declared-and-recorded
- The three guard tests and the eight non-substituting cases pass.
- Failure shape: the unfixed validator returns `[]` for `bug-large-feature-tool-only` (expected two errors) and returns `required_mcp_tools must match routing matrix` plus `missing successful MCP receipt: new_potential_entry.` for the three bug-tool-declared cases (expected `[]`). This reproduces the reported defect: the TypeScript validator ignores `promotion-type: bug`.
- P2-T1 reader line count: `wc -l extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts` printed 216 (below 500).
- Deviation note: the working-directory rule was satisfied with `npm --prefix extensions/drm-copilot` per the delegation's environment constraints.

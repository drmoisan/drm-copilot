Timestamp: 2026-11-19T16-52
Command: none (record of execution deviations)
EXIT_CODE: 0
Output Summary: three plan-named Jest files are renamed to stay out of the local integration lane; non-blocking.

## DEV-1: Jest file names that end in `-integration.test.ts`

- Rule: `config/test-execution-policy.json` declares the lane `integration` with the file-name suffix `-integration.test.ts`; the test-execution launcher excludes that lane from every local gate and task check, and CI runs it as a separate lane.
- Effect: three plan-named unit-test files end with that suffix and would never run in a local gate or coverage run:
  - [P2-T2] `EXT/test/mcp-tool-inputs-push-down-integration.test.ts`
  - [P2-T3] `EXT/test/repo-automation-service-push-down-integration.test.ts`
  - [P2-T4] `EXT/test/mcp-server.push-down-integration.test.ts`
- Decision (autonomous mode, recommended option): keep each file a unit test and append `-tools` before `.test.ts`: `mcp-tool-inputs-push-down-integration-tools.test.ts`, `repo-automation-service-push-down-integration-tools.test.ts`, `mcp-server.push-down-integration-tools.test.ts`. Content, rule tokens and cases are those the plan specifies; only the file name differs.
- Reason: renaming keeps the tests in the local Jest gate and the coverage run that judges the new modules; leaving the names would silently drop S42, S48 and S50 coverage from every local gate.

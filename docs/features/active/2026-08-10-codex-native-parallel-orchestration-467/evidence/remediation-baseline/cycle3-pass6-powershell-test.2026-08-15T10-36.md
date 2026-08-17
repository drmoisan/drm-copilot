# Cycle 3 Pass 6 PowerShell Test Baseline

Timestamp: 2026-08-15T11:52:13-04:00
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25` and the repository-default scan configuration
EXIT_CODE: 0
Output Summary: The required `drm-copilot` MCP test runner returned `ok=true`. Fresh JUnit reports 2,456 tests, 0 failures, 0 errors, and 9 disabled tests.

- Required MCP operation: PowerShell testing
- MCP tool called: `run_poshqc_test`
- Scan folders argument: omitted; repository-default configuration used
- MCP response `ok`: `true`
- MCP response `isError`: `false`
- MCP summary: `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25'.`
- Calling contract satisfied: `true`

## JUnit result

- Root: `Pester`
- Tests: `2456`
- Failures: `0`
- Errors: `0`
- Disabled: `9`
- Reported duration seconds: `130.226`
- Test suites: `126`
- Test cases: `2456`
- Failure nodes: `0`
- Error nodes: `0`
- Skipped nodes: `9`

## Fresh output artifacts

| Path | Before UTC | Before SHA-256 | After UTC | After bytes | After SHA-256 | Fresh |
|---|---|---|---|---:|---|---|
| `artifacts/pester/pester-junit.xml` | `2026-08-15T05:57:01.9451220Z` | `340324928F81839E26E6D0A714655107D808FCB0E552C2F5157B6E1896FC2EB1` | `2026-08-15T15:52:11.9694085Z` | 930619 | `119D402F428CE6CBFDF3A4E6653BEBBFF29BA6D1346CC93A5EA38E62A51980A2` | true |
| `artifacts/pester/powershell-coverage.xml` | `2026-08-15T05:55:58.9234390Z` | `C329461C8A2F0E32F6876325979577AF6F7C9C3147436305415DE357C5566D24` | `2026-08-15T15:50:52.3120592Z` | 361851 | `B750B029C0C0530062C4408133A6791286BED4D7E647767A5AF7F4E46A8ECE93` | true |

Both report timestamps and hashes changed during this invocation, and both after-timestamps fall within the test-run window `2026-08-15T11:48:30-04:00` through `2026-08-15T11:52:13-04:00`.

# Fail-Before: mcp-server prepack (Issue #697, AC-4.13 red)

Timestamp: 2026-09-25T22-35
Command: npm --prefix extensions/drm-copilot run test -- test/packaging/mcp-server-prepack.test.ts; Test-Path -LiteralPath packages/mcp-server/resources
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `Tests:       4 failed, 4 total`.
- `exports shouldCopy and performs no copy when required` -- `Expected number of calls: 0`, `Received number of calls: 1` (the unfixed script runs `cpSync` on load; the no-op spy absorbed the call). AC-4.13 red.
- The other three cases fail with `TypeError: The "path" argument must be of type string. Received undefined` because the unfixed script exports nothing (`SOURCE_DIR` is undefined).
- `Test-Path -LiteralPath packages/mcp-server/resources`: False -- the red run copied nothing.

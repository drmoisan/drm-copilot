Timestamp: 2026-09-27T15-20

Six helper scripts written to `<scratchpad>` (outside the repository; never committed):
1. `<scratchpad>/run-ps.sh`
2. `<scratchpad>/pester-counts.ps1`
3. `<scratchpad>/anchor-count.ps1`
4. `<scratchpad>/old-vs-new-form.ps1`
5. `<scratchpad>/line-counts.ps1`
6. `<scratchpad>/file-hashes.ps1`

Each script body matches the plan's P0-T13 verbatim specification exactly.

Command: sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
EXIT_CODE: 0
Output Summary: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 LineCount=203 — exact match to the expected smoke-test output.

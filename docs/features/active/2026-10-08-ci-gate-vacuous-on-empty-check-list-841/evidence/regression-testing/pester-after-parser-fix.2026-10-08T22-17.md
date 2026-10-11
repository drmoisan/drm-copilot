# Pester Pass-After Run Following the Parser Fix (#841, P2-T8)

Timestamp: 2026-10-10T09-23
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-lib/ci-gate"]; then Read artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- MCP call disposition: returned normally (ok=true); no "Command exited with code N" was raised, consistent with zero failed tests.
- Folder totals (testsuites element): TotalCount=35 PassedCount=35 FailedCount=0 (tests="35" errors="0" failures="0" disabled="0")
- Per-file: CiGate.Manifest.Tests.ps1 tests=2 failures=0 errors=0 skipped=0; Invoke-CiGateParser.Tests.ps1 tests=33 failures=0 errors=0 skipped=0
- FAILED lines: none (no `<failure` element in the JUnit file)
- COVERAGE file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 LinePercent=97.83 (LINE covered=45 missed=1); baseline PARSER_BASE_PCT=94.12
- MISSED lines: 338 (the `$NowProvider` default delegate in the `Invoke-CiGateParser` param block; every test injects a clock)

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ci-gate` was replaced by the A2 substitute: the MCP test call over the folder followed by reading the JUnit file the installed runner writes. Coverage (A3 substitute) was read from the JaCoCo file in the same run.

## Freshness

`artifacts/pester/pester-junit.xml` modified 2026-10-10 09:23:34 -0400 and `artifacts/pester/powershell-coverage.xml` modified 2026-10-10 09:23:32 -0400; both after this MCP call was issued (previous run 09:17:42). Local time read immediately after: 09:23:44.

## JUnit attributes

- `<testsuites ... name="Pester" tests="35" errors="0" failures="0" disabled="0" time="0.761">`
- testsuite `...tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`: tests="2" errors="0" failures="0" skipped="0"
- testsuite `...tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: tests="33" errors="0" failures="0" skipped="0"

## Coverage (JaCoCo package ending `.claude/lib/ci-gate`, sourcefile `Invoke-CiGateParser.ps1`)

- LINE counter: missed="1" covered="45" -> 45 / 46 = 97.83%
- INSTRUCTION counter: missed="2" covered="53"
- HIT lines: 104, 168, 169, 172, 177, 178, 179, 181, 186, 189, 193, 196, 197, 200, 205, 206, 207, 208, 213, 214, 215, 216, 223, 230, 231, 236, 237, 240, 277, 278, 279, 280, 281, 282, 351, 354, 360, 362, 366, 368, 377, 378, 381, 391, 392
- MISSED lines: 338
- The baseline miss at the `process` block call (pre-change line 321, now 391-392) is now hit by the new script entry-point forwarding test.

TotalCount=35
PassedCount=35
FailedCount=0
LinePercent=97.83

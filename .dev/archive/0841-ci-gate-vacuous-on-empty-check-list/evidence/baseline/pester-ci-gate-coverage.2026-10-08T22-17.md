# Pester Test and Coverage Baseline (#841, P0-T12)

Timestamp: 2026-10-10T09-14
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-lib/ci-gate"]; then Read artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- MCP call disposition: returned normally (ok=true). The MCP result carries no per-test output.
- TotalCount=17 PassedCount=17 FailedCount=0 (testsuites tests="17" failures="0" errors="0")
- Per-file: CiGate.Manifest.Tests.ps1 tests=2 failures=0; Invoke-CiGateParser.Tests.ps1 tests=15 failures=0
- COVERAGE file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 LinePercent=94.12 (LINE covered=32 missed=2)
- PARSER_BASE_PCT=94.12
- MISSED lines: 270, 321

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pester-coverage.ps1 -TestPath tests/scripts/claude-lib/ci-gate -CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1 ...` was replaced by the A2/A3 substitute: the MCP test call followed by reading the JUnit and JaCoCo files the installed runner writes. The installed runner registers `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` for coverage. Coverage was read from the repository-local gitignored `artifacts/pester/` output rather than SCRATCH.

## Freshness

`artifacts/pester/pester-junit.xml` modified 2026-10-10 09:11:43 -0400 and `artifacts/pester/powershell-coverage.xml` modified 2026-10-10 09:11:41 -0400, both after the MCP call was issued in this run.

## JUnit totals

- `<testsuites ... name="Pester" tests="17" errors="0" failures="0" disabled="0" time="0.646">`
- testsuite `...tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`: tests="2" errors="0" failures="0" skipped="0"
- testsuite `...tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: tests="15" errors="0" failures="0" skipped="0"
- FAILED lines: none

## Coverage (JaCoCo package ending `.claude/lib/ci-gate`, sourcefile `Invoke-CiGateParser.ps1`)

- LINE counter: missed="2" covered="32" -> 32 / 34 = 94.12%
- INSTRUCTION counter: missed="3" covered="40"
- HIT lines: 85, 132, 133, 138, 142, 145, 146, 149, 154, 155, 156, 157, 163, 170, 171, 174, 211, 212, 213, 214, 215, 216, 280, 283, 289, 291, 295, 297, 306, 307, 310, 320
- MISSED lines: 270, 321

TotalCount=17
FailedCount=0
LinePercent=94.12
PARSER_BASE_PCT=94.12

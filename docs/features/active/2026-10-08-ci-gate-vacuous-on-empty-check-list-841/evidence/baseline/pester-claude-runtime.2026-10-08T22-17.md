# Pester Claude-Runtime Regression Baseline (#841, P0-T13)

Timestamp: 2026-10-10T09-15
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-runtime"]; then Read artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- MCP call disposition: returned normally (ok=true). The MCP result carries no per-test output.
- TotalCount=83 PassedCount=83 FailedCount=0 (testsuites tests="83" errors="0" failures="0" disabled="0")
- FAILED lines: none
- RUNTIME_FAIL_0 = (empty set)

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime` was replaced by the A2 substitute: the MCP test call over `tests/scripts/claude-runtime` followed by reading the JUnit file.

## Freshness

`artifacts/pester/pester-junit.xml` modified 2026-10-10 09:13:00 -0400, after this MCP call was issued (the previous P0-T12 file was 09:11:43).

## Per-file testsuites

- checkpoint-hygiene-skill-contract.Tests.ps1: tests=11 failures=0 errors=0
- claude-architecture-doc.Tests.ps1: tests=6 failures=0 errors=0
- claude-runtime-structure.Tests.ps1: tests=6 failures=0 errors=0
- claude-settings.Tests.ps1: tests=5 failures=0 errors=0
- enforcement-hooks-checkpoint-path-explicit.Tests.ps1: tests=8 failures=0 errors=0
- enforcement-hooks-no-python-invocation.Tests.ps1: tests=27 failures=0 errors=0
- legacy-discovery-agent-roles.Tests.ps1: tests=15 failures=0 errors=0
- test-name-uniqueness.Tests.ps1: tests=5 failures=0 errors=0

Sum: 83. No testsuite carries a nonzero `skipped` attribute; no `<failure` or `<error` element is present in the file.

TotalCount=83
PassedCount=83
FailedCount=0
RUNTIME_FAIL_0=none

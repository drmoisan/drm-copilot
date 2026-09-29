# Codex Python Routing Tests Before the Fix (P5-T2, expect-fail)

Timestamp: 2026-09-29T20-10
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
TotalCount=34
PassedCount=0
FailedCount=34
All 34 Appendix B8 cases fail against the unfixed XPYHOOK (no ReadCheckpoint, LargePathRoute, or entry-point function; mandatory TestCap; old deny text). A2 reports failures in its output, not its exit code. XPYRTEST LineCount=389 (P5-T1, at most 500).
FAILED lines (34, prefix `Codex enforce-python-batch-budget.ps1 large-path routing.`), by context:
- direct mode (13): D1, D2, D3, D4, and the nine `<Name> checkpoint enforces direct mode for the 4th production path` rows
- large path (5): large, remediation, preparation route rows; the decision with LargePathRoute allows without recording; a path_selected-only large checkpoint allows the 4th production path
- test paths (3): P1, P2, P3
- removed cap overrides (4): legacy state; persisted prodCap below the default; a fresh state carries no test-file keys; ConvertTo state ignores persisted prodCap, testCap, and testFiles
- checkpoint seam (6): S1 default reader; S2 checkpoint path; S3 throwing reader; S4 malformed tool_input JSON; S5 non-Python path; S6 tool_input without file_path
- entry point (3): E1 large-route Write payload; E2 deny envelope without state; E3 exit code 2 for an empty payload

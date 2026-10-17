# Claude Python Routing Tests Before the Fix (P2-T2, expect-fail)

Timestamp: 2026-09-29T19-35
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
TotalCount=32
PassedCount=0
FailedCount=32
All 32 Appendix B4 cases fail against the unfixed CPYHOOK (no ReadCheckpoint or LargePathRoute parameter, mandatory TestCap, CLAUDE_PYTHON_BUDGET references, old deny text). A2 reports test failures in its output, not its exit code. CPYRTEST LineCount=368 (P2-T1, at most 500).
FAILED lines (32), by context:
- direct mode (13): allows the first three distinct production paths and denies the 4th with no checkpoint; names the routing target, counted paths, requested path, and observed route; omits every prohibited remedy phrase and the state-file path from the deny reason; allows a repeated production path without a state write; nine `<Name> checkpoint enforces direct mode for the 4th production path` rows (route_id small, terminal next_step complete, terminal S12_complete, null route_id with path_selected large, blank route_id with path_selected large, unknown route, malformed, non-object, empty)
- large path (5): large, remediation, preparation route allows six distinct production paths without touching state; the decision with LargePathRoute allows without recording; a path_selected-only large checkpoint allows the 4th production path
- test paths (3): allows five distinct tests/ paths in direct mode without recording them; allows a root-level test_ file after three production paths without recording it; allows both test path forms on the large path without touching state
- removed cap overrides (5): loads a legacy state ... still denies the 4th production path; a persisted prodCap below the default does not lower the threshold; ignores CLAUDE_PYTHON_BUDGET_PROD and _TEST set in the test scope; the hook and helper sources contain no CLAUDE_PYTHON_BUDGET reference; a fresh state carries no test-file keys
- checkpoint seam (6): the default reader yields direct mode when the checkpoint file is absent; reads the checkpoint from artifacts/orchestration/orchestrator-state.json under the root; treats a throwing checkpoint reader as direct mode without raising; still denies an unreadable envelope when the checkpoint route is large; does not read the checkpoint for a non-Python path; does not read the checkpoint when the envelope carries no file_path

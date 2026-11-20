# Task Check P1-T2 [expect-fail]

Timestamp: 2026-11-15T23-43
Changed files: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1 (header comment extended to define ClassifyWrappedFunctionRows and ClassifyWrappedGateRows; both tables added).
Selection rule: the test files that dot-source the changed Cases file (both classify Tests.ps1 files). The new tables have no consuming It until P1-T3, so the expected failures are recorded by P1-T4.
Command: sh SCRATCH/issue-1195-tc.sh P1-T2 (scoped no-write format and PSScriptAnalyzer on the Cases file; then the launcher pester suite with -TestPath and the two classify Tests.ps1 files); SCRATCH/issue-1195-rowprint.ps1 dot-sources the Cases file and prints the row counts and the two depth rows.
EXIT_CODE: 0
Output Summary:
- Format: would change 0. PSScriptAnalyzer: 0 findings. Pester selection: exit code 0 (existing rows unaffected).
- Tables: ClassifyWrappedFunctionRows 31 rows; ClassifyWrappedGateRows 34 rows (Positive 16, Negative 14, Control 4). The Negative row beyond the spec lists is sh -c "grep pytest docs".
- Expected values: each function row's Indexes and each gate row's before/after value were confirmed against the SCRATCH prototype of the design before writing (all match); the base64 literal cAB5AHQAZQBzAHQA is re-derived in P1-T4.
- Depth rows parse to the exact prototype strings (depth 4 returns 1, depth 5 returns none in the prototype).

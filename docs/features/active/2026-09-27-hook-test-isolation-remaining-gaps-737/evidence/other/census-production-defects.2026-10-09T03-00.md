# P1-T12 Production-defect screen

Timestamp: 2026-10-09T03-00
PRODUCTION-DEFECTS: 0

Inputs reviewed: the P1-T11 differential (evidence/regression-testing/differential-before.2026-10-09T03-00.md) and the P1-T6 census (evidence/regression-testing/census-fail-before.2026-10-09T02-47.md).

Reviewed item 1. The only difference (tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1) carries Failed=1 in the baseline run and in the run with the hostile epic checkpoint present, so the hostile epic file changes no suite result in this tree (176 of 177 suites report EQUAL). The failing row spawns each registered Codex handler from the real repository root; .codex/hooks/enforce-epic-wave-barrier.ps1 reads the cwd-relative item checkpoint artifacts/orchestration/orchestrator-state.json and denies Bash, shell_command, apply_patch, Edit, Write, and MCP tool calls while the recorded child has unmet depends_on edges (file .codex/hooks/enforce-epic-wave-barrier.ps1, function Test-CodexWaveMutatingTool). The hook treats every Bash call as mutating by design, and reading the local checkpoint is its specified input. The dependence lies in the test (child process working directory and ambient file), so no production defect is recorded.

Reviewed item 2. The census flags hook-local content seams (for example Get-CheckpointContent, Get-EpicCheckpointContent, Get-ParallelCheckpointContent, the merge-gate and removal-gate checkpoint readers) as read seams in many closures. These are injectable by design and are test-side coverage gaps, not production defects.

No hook or library file is edited under this feature (AC-26).

# Task Check P2-T1

Timestamp: 2026-11-16T00-13
Changed files: .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 (new Get-OrchestrationGateWrappedPatternIndex and one private helper Get-OrchestrationGateWrapperPayloadText; .DESCRIPTION and .NOTES extended), copied byte-for-byte to .codex/hooks/, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/, and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/ (one SHA256 across the four copies; 223 physical lines).
Selection rule: the test files that dot-source or read the classify sibling: both classify Tests.ps1 files and tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1.
Command: sh SCRATCH/issue-1195-tc.sh P2-T1 (scoped no-write format and PSScriptAnalyzer on the four copies; launcher pester suite with -TestPath and the three test files); per-file results from artifacts/pester/parallel/shard-1..3 by SCRATCH/issue-1195-shards.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Format: 4 files, would change 0. PSScriptAnalyzer: 0 findings.
- claude-hooks classify suite: 121 passed, 16 failed; codex-hooks classify suite: 121 passed, 16 failed. All 31 wrapped function rows pass on each surface (AC-1). The 16 failures per surface are exactly the Positive rows of ClassifyWrappedGateRows, which P2-T2 makes pass.
- Classify parity suite: 8 passed, 0 failed (byte identity and the 500-line bound).
- Design notes (autonomous decision under OD-1): the encoded-command check walks the host flags after the host word and stops at the payload flag (-c, -cwa, -CommandWithArgs, or a -Command prefix of length 4 or more), mirroring the flag walk of enforce-orchestration-preimplementation-gate-commands.ps1, so an encoded flag after a valued option (for example -ExecutionPolicy Bypass -e) is also declined. The unbalanced-record skip and the env -S decline are as in the plan. The empty-input step needs no separate branch: Read-CommandLineSegment returns no record for empty or whitespace text.
- Existing functions Get-OrchestrationGateJoinedWordText and Get-OrchestrationGateSupplementalPatternIndex and the four OrchestrationGateSupplement pattern values are unedited; no dot-source and no PSScriptRoot reference added.

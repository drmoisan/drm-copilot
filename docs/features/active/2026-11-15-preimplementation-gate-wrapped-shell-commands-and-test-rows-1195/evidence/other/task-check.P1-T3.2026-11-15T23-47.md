# Task Check P1-T3 [expect-fail]

Timestamp: 2026-11-15T23-47
Changed files: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1 and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1 (SYNOPSIS/DESCRIPTION name issue #1195; one It -ForEach over ClassifyWrappedGateRows; one Context whose BeforeAll dot-sources the surface classify sibling and reads the five stage-1 patterns from the implementationCommandPatterns assignment inside Test-ImplementationCommand of the surface gate through the PowerShell parser, with one It -ForEach over ClassifyWrappedFunctionRows).
Selection rule: the two changed test files.
Command: sh SCRATCH/issue-1195-tc.sh P1-T3 (scoped no-write format and PSScriptAnalyzer on both files; launcher pester suite with -TestPath and both files); per-row results read from artifacts/pester/parallel/shard-1 and shard-2 pester-junit.xml by SCRATCH/issue-1195-shards.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Format: 2 files, would change 0. PSScriptAnalyzer: 0 findings.
- Discovery succeeded on both files: 274 test cases (2 surfaces x (probe + 33 gate rows + 37 function rows + I2 + 34 wrapped gate rows + 31 wrapped function rows)).
- 180 passed, 94 failed: the 16 Positive wrapped gate rows per surface (32, each "Expected $true ... but got $false") and the 31 wrapped function rows per surface (62, CommandNotFoundException for Get-OrchestrationGateWrappedPatternIndex). No other test failed.
- New It names carry the row Command ("classifies wrapped <Kind> row <Command> as <Expected>") or Name ("W <Name>").

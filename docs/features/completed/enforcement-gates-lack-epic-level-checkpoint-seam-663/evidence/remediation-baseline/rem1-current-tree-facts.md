# Remediation Cycle 1 Current-Tree Facts ([P0-T4])

Timestamp: 2026-09-25T21-10
Command: sh <SCRATCHPAD>/rem1/runout.sh p0-facts  (fresh PowerShell 7 process; Get-Content line indexing @(Get-Content -LiteralPath <path>)[<line> - 1] and @(Get-Content -LiteralPath <path>).Count)
EXIT_CODE: 0
Output Summary: All 29 quoted lines contain their tokens and all 10 line counts equal the plan values (helpers copies 488, module copies 366, suites 466/473/352/310). Mismatches: 0.

## Output

```
## Quoted lines
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:110 [contains] token `function Test-OrchestrationCommandTextUnresolvable`
  `function Test-OrchestrationCommandTextUnresolvable {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:119 [contains] token `Backslash escapes are not modelled`
  ``>`) answers true only outside a quoted span. Backslash escapes are not modelled, so`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:120 [contains] token `apostrophe idiom leaves its tail unquoted`
  `the single-quoted apostrophe idiom leaves its tail unquoted and still denies.`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:130 [contains] token `$openQuote = [char]0`
  `$openQuote = [char]0`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:141 [contains] token `if ($openQuote -ne [char]0) {`
  `if ($openQuote -ne [char]0) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:147 [contains] token `$script:RedirectionCommandCharacters -contains $character`
  `} elseif ($script:RedirectionCommandCharacters -contains $character) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:458 [contains] token `# Row 12: interpolation anywhere and redirection outside quotes`
  `# Row 12: interpolation anywhere and redirection outside quotes are not statically`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:460 [contains] token `if (Test-OrchestrationCommandTextUnresolvable -CommandText $CommandText) {`
  `if (Test-OrchestrationCommandTextUnresolvable -CommandText $CommandText) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:464 [contains] token `$split = Split-OrchestrationCommandLine -CommandText $CommandText`
  `$split = Split-OrchestrationCommandLine -CommandText $CommandText`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:14 [contains] token `leg with no branch signal, the HEAD branch`
  `leg with no branch signal, the HEAD branch of the effective worktree (the -C selector`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:291 [contains] token `when the text carries no branch signal,`
  `Match the effective worktree's HEAD branch when the text carries no branch signal,`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:313 [contains] token `$branch = Find-WorktreeResolutionBranchSignal -Text $Text`
  `$branch = Find-WorktreeResolutionBranchSignal -Text $Text`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:334 [contains] token `# Decide the matched branch`
  `# Decide the matched branch: an explicit branch signal decides on its own; otherwise`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:337 [contains] token `if ($null -ne $branch) {`
  `if ($null -ne $branch) {`
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1:354 [contains] token `Test-EpicScopeMergeInProgress -WorktreeRoot $effectiveRoot`
  `$mergeInProgress = [bool](Test-EpicScopeMergeInProgress -WorktreeRoot $effectiveRoot)`
- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:61 [contains] token `$script:BranchPattern`
  `$script:BranchPattern = '(?i)(?:(?<![\w-])--(?:head|branch)(?:=|\s+)|\bbranch:\s*)(?<name>[A-Za-z0-9][A-Za-z0-9._/-]*)'`
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:82 [contains] token `$token[1] -ceq '-C'`
  `if ($token.Count -ge 3 -and $token[0] -ceq 'git' -and $token[1] -ceq '-C' -and $token[2]) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:117 [contains] token `-MatchWorktreeHead`
  `$scope = Resolve-EpicScopeCheckpoint -Text ([string]$Command) -SessionRoot (Get-Location).Path -WorktreeSelector $selector -MatchWorktreeHead`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:155 [contains] token `Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand`
  `if ($index -eq 0 -and (Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand)) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:390 [contains] token `Get-OrchestrationEpicScopeDecision -Command $command -FilePath $filePath`
  `$epicDecision = Get-OrchestrationEpicScopeDecision -Command $command -FilePath $filePath`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:429 [contains] token `Implementation operations require artifacts/orchestration/orchestrator-state.json`
  `return Get-OrchestrationPreimplementationGateBlockDecision -Reason 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'`
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:16 [contains] token `enforce-orchestration-preimplementation-gate-helpers.ps1`
  `. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-helpers.ps1')`
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170 [contains] token `Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand`
  `if ($index -eq 0 -and (Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand)) {`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:432 [contains] token `issue #663 quote-aware angle brackets`
  `Context 'issue #663 quote-aware angle brackets' {`
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:439 [contains] token `issue #663 quote-aware angle brackets`
  `Context 'issue #663 quote-aware angle brackets' {`
- tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1:58 [contains] token `Resolve-EpicScopeCheckpoint epic-scope matches`
  `Describe 'Resolve-EpicScopeCheckpoint epic-scope matches' {`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:215 [contains] token `an epic checkpoint whose integration_branch differs from HEAD`
  `It 'an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path' {`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:228 [contains] token `issue #663 relocated read seams`
  `Context 'issue #663 relocated read seams and the no-leg guard of the epic-scope sibling' {`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:51 [contains] token `Should -BeLessOrEqual 500`
  `Should -BeLessOrEqual 500 -Because "$path must stay within the repository file-size limit"`

## Line counts
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 488 (expected 488, equal)
- .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 488 (expected 488, equal)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 488 (expected 488, equal)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 488 (expected 488, equal)
- .claude/lib/worktree-resolution/EpicScopeResolution.psm1: 366 (expected 366, equal)
- extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1: 366 (expected 366, equal)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1: 466 (expected 466, equal)
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1: 473 (expected 473, equal)
- tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1: 352 (expected 352, equal)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1: 310 (expected 310, equal)

Mismatches: 0
PROCESS_EXIT_CODE: 0
```

# Task check [P5-T2]

Timestamp: 2026-11-14T04-42
Command: sh SCRATCH/issue-1159-taskcheck.sh <parity suite and corpus files> tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (Invoke-Formatter compare, Invoke-ScriptAnalyzer with pssa.settings.psd1, Invoke-Pester Run.Path = the suite)
EXIT_CODE: 1
Output Summary: format 0 files needing change; analyzer 0 findings (PSUseShouldProcessForStateChangingFunctions on Start-ParityProcess fixed by renaming it Invoke-ParityProcess); Pester 79 passed, 2 failed, 5 skipped on Windows. All 26 envelope parity rows (13 Claude, 13 Codex) passed. Both failures are the arrivals [P7-T1] handles.

## Changed files
- tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1 (new, 295 physical lines)

## Selection and rule
The new suite (it invokes both corpus files).

## Expected failures (acceptance is evaluated in [P7-T4])
- registers exactly one PreToolUse entry, the dispatcher, in .claude/settings.json: 2 entries; enforce-owner-directive-pass-down.ps1 (issue 1157, arrived from origin/main) is registered beside the dispatcher until [P7-T1] moves it into the registry.
- loads each stateless shared module once per call: .claude/lib/worktree-resolution/AgentTargetWorktree.psm1 loaded twice in one call; the guarded Import-Module ... -Force lines that issue 1163 added to D6-set hooks are unhandled (b) members for [P7-T1].

## Skipped 'has parity envelopes for <hook leaf>' rows
- claude: enforce-model-routing-receipt.ps1, enforce-docs-role-write-scope.ps1
- codex: enforce-epic-root-invocation.ps1, enforce-codex-model-routing.ps1, enforce-epic-planning-only.ps1

## CI-dependent
The suite's result in poshqc / PowerShell hook suites (Linux) is verified on the PR head at the CI green gate.

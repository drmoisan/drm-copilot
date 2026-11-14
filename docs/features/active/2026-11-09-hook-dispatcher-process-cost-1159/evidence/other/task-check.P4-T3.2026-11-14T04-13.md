# Task check [P4-T3]

Timestamp: 2026-11-14T04-13
Command: sh SCRATCH/issue-1159-taskcheck.sh <changed files> <selection> (Invoke-Formatter compare, Invoke-ScriptAnalyzer with pssa.settings.psd1, Invoke-Pester Run.Path = selection)
EXIT_CODE: 1
Output Summary: format 0 files needing change; analyzer 0 findings (one indentation finding in the mode-resolution suite fixed before this run); Pester 148 passed, 3 failed, all three caused by bundle copies that [P6-T1] creates or refreshes.

## Changed files
- tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 (registrations read from .codex/hooks/pretooluse-dispatch.json; new It 'registers one PreToolUse table invoking the dispatcher in command and command_windows'; TOML parser kept for the AC-20 rows)
- tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 (fixed counts replaced by counts derived from the bundle registry and config; process It reads the registry)
- tests/scripts/codex-hooks/discovery-capability.Tests.ps1 (artifact and planning gate registrations read from the registry; stop validator stays on config.toml)
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 (reads only registry groups that list the gate)
- tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 (PreToolUse gate names read from the registry; UserPromptSubmit, SubagentStart and SubagentStop names and the other config assertions stay on config.toml)

## Selection and rule
The changed test files plus the two suites the plan names as verified unaffected (legacy-codex-hook-contracts.Tests.ps1, tests/scripts/claude-hooks/discovery-capability.Tests.ps1); both passed.

## Expected failures (acceptance is evaluated in [P7-T4])
- codex-bundle-hook-probe: both rows -- the bundle .codex/hooks/pretooluse-dispatch.json does not exist until [P6-T1].
- codex-epic-runtime-contracts: keeps root and tracked bundle runtime copies byte-identical -- the bundle config.toml is refreshed in [P6-T1].

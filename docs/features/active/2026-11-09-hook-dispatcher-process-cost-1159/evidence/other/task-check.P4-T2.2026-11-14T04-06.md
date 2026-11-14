# Task check [P4-T2]

Timestamp: 2026-11-14T04-06
Command: sh SCRATCH/issue-1159-taskcheck.sh <changed files> <selection> (Invoke-Formatter compare, Invoke-ScriptAnalyzer with pssa.settings.psd1, Invoke-Pester Run.Path = selection)
EXIT_CODE: 0
Output Summary: format 0 files needing change; analyzer 0 findings; Pester 1174 passed, 0 failed, 0 skipped.

## Changed files
- tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 (Get-HookRegistration enumerates both registries through new Get-HookGraphRegistryEntry; a registry ReadText returns as null adds no entry)
- tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 (ReasonPrefix entry for .claude/hooks/invoke-pretooluse-dispatch.ps1 = HOOK_DISPATCH_BLOCKED:)
- tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 (ReasonPrefix entry for .codex/hooks/invoke-pretooluse-dispatch.ps1 = HOOK_DISPATCH_BLOCKED:)
- .claude/hooks/invoke-pretooluse-dispatch.ps1 and .codex/hooks/invoke-pretooluse-dispatch.ps1: related in-item fix. The first run of this check failed S6 (hook-dependency-guard-completeness) for both dispatcher entries, which are registered hooks since [P3-T3]: their decision functions returned a Decision/Results wrapper instead of the dependency decision first. Each decision function now returns the decision directly and adds per-hook results to an optional -ResultSink list read by the entry point for -PerHookTrace. No decision, deny code or reason text changed.
- tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1 and tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1: the decision-function It reads the decision directly (updated for the return-shape change above).

## Selection and rule
The five suites named by [P4-T2] (they dot-source the changed helper or carry the changed maps) plus both dispatcher entry-script suites (mirrored tests of the changed entry scripts).

## Discovered test counts in the P0-T5 JUnit (for the [P7-T4] comparison; JUnit copy kept in SCRATCH)
- hook-dependency-guard-completeness.Tests.ps1: 731
- hook-dependency-failure.Claude.Tests.ps1: 221
- hook-dependency-failure.Codex.Tests.ps1: 100
- hook-imported-modules-no-stdout.Tests.ps1: 25
- hook-dependency-failure.SpecialCases.Tests.ps1: 17

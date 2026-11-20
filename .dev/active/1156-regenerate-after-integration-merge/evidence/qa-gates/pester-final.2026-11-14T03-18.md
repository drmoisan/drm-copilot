# Pester Final Gate, run 1 — [P6-T2] (failed)

Timestamp: 2026-11-14T03-18
Command: sh SCRATCH/issue-1156-pester-gate.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; launcher exits with the returned ExitCode)
EXIT_CODE: 1
Output Summary: one Invoke-PoshQCParallelTest run, workers=8, wall-clock 709 s, exit 1 (shards 1 and 6 non-zero); no merged JUnit or coverage written, so counts come from the shard logs: 23293 passed, 3 failed, 10 skipped. Two other repositories' parallel gates (other worktrees) ran on the host at the same time.

## Failures

1. enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, AC-4 for tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1: the six closure seams had no baseline null Mock in the outermost BeforeAll of either Describe. Fixed in the suite (baseline mocks, helper load, and an interception-probe It per Describe, in the form of enforce-epic-merge-gate-docs-only.Tests.ps1).
2. Same guard, AC-6 for tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1: no interception-probe call inside an It. Fixed (helper load and probe It, in the form of enforce-epic-merge-gate.ReviewGuard.Tests.ps1).
3. tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1, "reports no Python invocation beyond the allowlist across the guarded tree": .claude/lib/regeneration/Invoke-RegenerationPath.ps1, Invoke-RegenerationProcess -Invoker default, DynamicInvocation (ampersand-invoked variable $FilePath is not a [scriptblock] parameter). NOT fixed: see the blocking note below.

Debugging run after fixes 1 and 2 (not a gate): Discovery guard plus both edited suites, 609 passed, 0 failed.

## Blocking note for failure 3

The guarded tree of the no-Python scan includes .claude/lib, and the scan fails closed on any call-operator invocation of a non-scriptblock variable; its allowlist is pinned to exactly one entry by "ships exactly the D3 allowlist entry". The plan's own AST check (h) in tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1 requires the process seam default to be exactly one call-operator invocation whose command element is the variable FilePath. The two assertions cannot both hold for the entry point that runs a destination-declared argv. Resolving it needs one assertion change: either an allowlist entry for .claude/lib/regeneration/Invoke-RegenerationPath.ps1 / Invoke-RegenerationProcess (changes the pinned allowlist count outside the plan's file set), or a different process-start mechanism with check (h) rewritten (changes a plan-specified assertion). The executor stopped for an owner decision; no assertion was changed.

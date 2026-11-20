# P8-T6 #732 checks

Timestamp: 2026-10-13T12-19
Command: git grep -n -i -e Get-OrchestrationTargetResult -- . ":(exclude)docs"; git grep -n -E "^.{121,}" -- .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Command 1 (`git grep -n -i -e Get-OrchestrationTargetResult -- . ":(exclude)docs"`): EXIT_CODE 1, no output. The old name no longer appears in any of the four targets copies or elsewhere outside `docs`.
- Command 2 (`git grep -n -E "^.{121,}" -- .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`): EXIT_CODE 1, no output. No line of the Codex copy exceeds 120 characters.
- Before-state reference: `git grep -n -i -e Get-OrchestrationTargetResult HEAD -- . ":(exclude)docs"` against the Phase 7 commit 6a80c4263 matched 36 lines (9 per copy), matching the plan's stated before count.
- Both commands exit 1 as expected (ExpectedExitCode 1 applies to both).

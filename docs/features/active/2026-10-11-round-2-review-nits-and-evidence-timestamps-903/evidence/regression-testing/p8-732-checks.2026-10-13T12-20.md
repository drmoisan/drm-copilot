# P8-T6 #732 checks (rerun after the P8-T9 formatter rewrite)

Timestamp: 2026-10-13T12-20
Command: git grep -n -i -e Get-OrchestrationTargetResult -- . ":(exclude)docs"; git grep -n -E "^.{121,}" -- .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Rerun required by P8-T9: the formatter re-indented continuation lines in the Claude and Codex targets copies, so the Claude copy was recopied to its three other copies (P8-T5, all three `git diff --no-index --exit-code` exit 0) and P8-T4 and P8-T6 were rerun.
- Command 1 (`git grep -n -i -e Get-OrchestrationTargetResult -- . ":(exclude)docs"`): EXIT_CODE 1, no output.
- Command 2 (`git grep -n -E "^.{121,}" -- .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`): EXIT_CODE 1, no output.
- P8-T4 rerun: `git grep -n -E "^.{121,}" -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` EXIT_CODE 1; `wc -l` 373 (at most 400).
- Before-state reference (Phase 7 commit 6a80c4263): the first command matched 36 lines (9 per copy).
- This artifact supersedes `p8-732-checks.2026-10-13T12-19.md` (same results, recorded before the format rewrite).

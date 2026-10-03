# r1 P7-T4 — AC-1 and AC-2 re-verification

Timestamp: 2026-10-03T13-22
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p7-t4.ps1 -Worktree WORKTREE (A0; `& "$Scratch/resolver-ast-check.ps1" -Path '.claude/hooks/hook-command-invocation.ps1'; $claudeAst = $LASTEXITCODE; "AST-EXIT=$claudeAst"`; the same for '.codex/hooks/hook-command-invocation.ps1'; the Test-CommandLineRawContainment location search over .claude/hooks/*.ps1 and .codex/hooks/*.ps1; the BASE_SHA-anchored numstat of both hook-command-invocation.ps1 copies; and the P7-T4 RELAY line)
EXIT_CODE: 0
Output Summary:
- Claude copy: RAWINVOCATION=1, RAWCONTAINMENT=0, AST-EXIT=0
- Codex copy: RAWINVOCATION=1, RAWCONTAINMENT=0, AST-EXIT=0
- Containment locations: hook-command-invocation.ps1:94, hook-command-invocation.ps1:490, hook-command-invocation.ps1:94, hook-command-invocation.ps1:490 (the same four P0-T7 recorded; CLAUDE-RAW and CODEX-RAW contribute none)
- numstat printed nothing (hook-command-invocation.ps1 unchanged in both roots)
- RELAY reported the larger A3 exit code, 0.

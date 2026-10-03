# P4-T3 AC-1: R2 predicate on both surfaces

Timestamp: 2026-10-03T10-00
Command: & "SCRATCH/resolver-ast-check.ps1" -Path '.claude/hooks/hook-command-invocation.ps1'; $LASTEXITCODE; same for '.codex/hooks/hook-command-invocation.ps1'; Select-String -SimpleMatch 'Test-CommandLineRawInvocation -RawText $segment.RawText' over both files
EXIT_CODE: 0
Output Summary:
- .claude/hooks/hook-command-invocation.ps1 AST check (body of Resolve-CommandLineInvocation): RAWINVOCATION=1, RAWCONTAINMENT=0; exit 0
- .codex/hooks/hook-command-invocation.ps1 AST check: RAWINVOCATION=1, RAWCONTAINMENT=0; exit 0
- Grep: .claude\hooks\hook-command-invocation.ps1:211 and .codex\hooks\hook-command-invocation.ps1:211 (exactly one line per surface)
- Result: PASS

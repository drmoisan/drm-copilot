# r2 P7-T3 AC-1 and AC-2 re-verification

Timestamp: 2026-10-03T16-23
Command: step script SCRATCH/steps/r2-p7-t3.ps1 (A3 resolver AST check on both hook-command-invocation.ps1 copies; A5 raw-predicate AST check on both hook-command-raw-invocation.ps1 copies; Test-CommandLineRawContainment hit, definition, and Test-CommandLineMention-caller counts; RELAY of the largest AST exit code)
EXIT_CODE: 0
Output Summary:
- A3 on .claude and .codex hook-command-invocation.ps1: RAWINVOCATION=1 RAWCONTAINMENT=0, RESOLVER-AST-EXIT=0 each
- A5 on .claude and .codex hook-command-raw-invocation.ps1: WORDPRESENT=1 SEQUENCEMATCH=0, PREDICATE-AST-EXIT=0 each
- CONTAINMENT-HITS=4 DEFINITIONS=2 MENTION-CALLERS=2 (definition and Test-CommandLineMention caller on each surface)
- Order independence is evidenced by R824-P26 to R824-P30 on PASSED lines in FEATURE/evidence/regression-testing/r2-pass-after-pester.2026-10-03T16-20.md.

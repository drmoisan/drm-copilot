# P0-T6 Root-BeforeAll Module-Scoped Mock Probe (D2)

Timestamp: 2026-09-27T10-02
Command: Route C (scratchpad p0t6.ps1 = the plan's P0-T6 in-memory probe followed by `exit $code`, run by `pwsh -NoProfile -File` via `sh` from the worktree root). The probe uses New-PesterContainer -ScriptBlock and creates no file.
EXIT_CODE: 0
Output Summary:
Tests Passed: 1, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PROBE: Passed=1 | Failed=0
EXIT_CODE_COMPUTED: 0
Process exit code: 0 (matches EXIT_CODE_COMPUTED)
Conclusion: a module-scoped Mock declared in a file-level BeforeAll applies inside nested Describe/Context blocks (Pester 5.6.1).

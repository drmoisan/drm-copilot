# r3 PA-3 Suite Edit Verification (P2-T1, P2-T2)

Timestamp: 2026-10-16T21-44
Command: git diff --numstat 7558c7e42ec8c8955cb5f9997cca41afc6e3b797 -- tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1; export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $f = "tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1"; ParseFile error count; (Get-Content -LiteralPath $f).Count; Select-String -SimpleMatch line numbers of "Remove-Module -Name" and the first "Register-EpicStateBaselineMock -Seam"; @(Select-String -LiteralPath $f -SimpleMatch -Pattern "Invoke-EpicStateInterceptionProbe -Surface").Count' (SCRATCH/issue-953-r3-p2-t2.sh)
EXIT_CODE: 0
Output Summary:
- numstat: `4	0	tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (4 added, 0 deleted)
- PARSE_ERRORS=0
- LINES=118 (AC-15: at most 500)
- REMOVE_MODULE_LINES=25 (exactly once)
- FIRST_REGISTER_LINE=26 (the Remove-Module line is directly before the first Register-EpicStateBaselineMock line)
- PROBE_CALLS=1 (probe call unchanged)
- Result: PASS.

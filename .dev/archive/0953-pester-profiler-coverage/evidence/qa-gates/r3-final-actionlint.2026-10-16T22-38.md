# r3 Final actionlint (P5-T11)

Timestamp: 2026-10-16T22-38
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { 'ACTIONLINT: NOT-AVAILABLE'; exit 1 }' (SCRATCH/issue-953-r3-p5-t11.sh)
EXIT_CODE: 0
Output Summary:
- GET_COMMAND resolved to the WinGet-installed actionlint.exe.
- actionlint output: none.
- Result: PASS.

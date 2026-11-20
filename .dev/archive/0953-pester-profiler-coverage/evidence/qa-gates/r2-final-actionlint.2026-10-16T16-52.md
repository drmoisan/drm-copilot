# r2 final actionlint (P5-T7)

Timestamp: 2026-10-16T16-52
Command: sh "SCRATCH/issue-953-r2-p5-t7.sh" (pwsh text: $cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { 'ACTIONLINT: NOT-AVAILABLE'; exit 1 })
EXIT_CODE: 0
Output Summary: GET_COMMAND=<WinGet package path>\rhysd.actionlint_Microsoft.Winget.Source_8wekyb3d8bbwe\actionlint.exe; actionlint printed no output (no findings).

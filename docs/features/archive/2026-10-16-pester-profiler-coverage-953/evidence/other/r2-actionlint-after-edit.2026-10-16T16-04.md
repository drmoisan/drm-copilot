# r2 actionlint after workflow edit (P2-T14)

Timestamp: 2026-10-16T16-04
Command: sh "SCRATCH/issue-953-r2-p2-t14.sh" (pwsh text: $cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { 'ACTIONLINT: NOT-AVAILABLE'; exit 1 })
EXIT_CODE: 0
Output Summary: GET_COMMAND=<WinGet package path>\rhysd.actionlint_Microsoft.Winget.Source_8wekyb3d8bbwe\actionlint.exe; actionlint printed no output. The ${{ strategy.job-total }} expression is accepted.

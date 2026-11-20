# Final Workflow Lint (issue #953, P6-T10, post-split restart pass)

Timestamp: 2026-10-16T09-58
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; "ACTIONLINT_EXIT=$LASTEXITCODE"; exit $LASTEXITCODE } else { "ACTIONLINT: NOT-AVAILABLE" }' (script SCRATCH/issue-953-p6-t10.sh, run with sh)
EXIT_CODE: 0
Output Summary: Get-Command resolved actionlint (WinGet package rhysd.actionlint). actionlint .github/workflows/_poshqc.yml on the edited workflow exited 0 with no findings.

ACTIONLINT: AVAILABLE

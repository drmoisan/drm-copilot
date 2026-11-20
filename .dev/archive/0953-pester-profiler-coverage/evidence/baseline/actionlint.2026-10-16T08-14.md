# Workflow-Lint Baseline (issue #953, P0-T26)

Timestamp: 2026-10-16T08-14
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $cmd = Get-Command actionlint -ErrorAction SilentlyContinue; "GET_COMMAND=$($cmd.Source)"; if ($cmd) { actionlint .github/workflows/_poshqc.yml; "ACTIONLINT_EXIT=$LASTEXITCODE"; exit $LASTEXITCODE } else { "ACTIONLINT: NOT-AVAILABLE" }' (script SCRATCH/issue-953-p0-t26.sh, run with sh)
EXIT_CODE: 0
Output Summary: Get-Command resolved actionlint (WinGet package rhysd.actionlint). actionlint .github/workflows/_poshqc.yml exited 0 with no output (no findings).

ACTIONLINT: AVAILABLE

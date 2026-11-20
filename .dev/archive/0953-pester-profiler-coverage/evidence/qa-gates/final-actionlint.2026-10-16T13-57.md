# Final QC: actionlint (P8-T16 / P6-T10, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t10.sh" — `$cmd = Get-Command actionlint -ErrorAction SilentlyContinue; if ($cmd) { actionlint .github/workflows/_poshqc.yml; exit $LASTEXITCODE } else { "ACTIONLINT: NOT-AVAILABLE" }`
EXIT_CODE: 0

Output Summary:
- `Get-Command actionlint` resolved to the WinGet-installed `actionlint.exe`.
- `actionlint .github/workflows/_poshqc.yml` exited 0 with no output, run on the sharded workflow (jobs poshqc-static, poshqc-shard, poshqc, poshqc-linux-hooks).
- Result: PASS.

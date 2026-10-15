# Final QC (Remediation Cycle 1, Iteration 1): PR-Context Fail Rows (PA-3 pass-after)

Timestamp: 2026-10-08T20-49
Command: (1) poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt (Bash, exit 0); (2) $m = @(Select-String -LiteralPath artifacts/pr_context.summary.txt -SimpleMatch -Pattern 'Normalized result: fail' -Context 4,0); 'FAIL-ROWS=' + $m.Count; $m | ForEach-Object { 'FAIL-SOURCE ' + (($_.Context.PreContext | Where-Object { $_ -match 'Source: ' }) -replace '^\s*- Source: ', '') }; exit ([int]($m.Count -gt 0))
Shell: (2) sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T26.ps1 (same FAILROWS body as the fail-before run)
EXIT_CODE: 0
Output Summary: COLLECT exited 0. FAILROWS printed FAIL-ROWS=0 and exited 0. Fail-before: remediation-baseline/pr-context-fail-rows.2026-10-08T20-20.md (FAIL-ROWS=1, the relocated analyze-selfhosted.1 artifact). Supporting count: the regenerated summary contains 113 "Normalized result: pass" rows, so the zero-fail result is read from a populated verification section.

```
Wrote context summary to: artifacts\pr_context.summary.txt
Wrote context appendix to: artifacts\pr_context.appendix.txt
FAIL-ROWS=0
```

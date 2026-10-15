# Remediation Baseline: PR-Context Fail Rows (PA-3 fail-before)

Timestamp: 2026-10-08T20-20
Command: (1) poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt (Bash, exit 0); (2) $m = @(Select-String -LiteralPath artifacts/pr_context.summary.txt -SimpleMatch -Pattern 'Normalized result: fail' -Context 4,0); 'FAIL-ROWS=' + $m.Count; $m | ForEach-Object { 'FAIL-SOURCE ' + (($_.Context.PreContext | Where-Object { $_ -match 'Source: ' }) -replace '^\s*- Source: ', '') }; exit ([int]($m.Count -gt 0))
Shell: (2) sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T26.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: COLLECT exited 0. FAILROWS printed FAIL-ROWS=1 and one FAIL-SOURCE line ending evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md, which is the PA-3 artifact. The Phase 4 relocation set is that one file; no addition is required.

```
Wrote context summary to: artifacts\pr_context.summary.txt
Wrote context appendix to: artifacts\pr_context.appendix.txt
FAIL-ROWS=1
FAIL-SOURCE docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md
```

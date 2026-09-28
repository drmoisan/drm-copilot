# PowerShell Analyze (Remediation Cycle 1, P1-T11)

Timestamp: 2026-09-27T19-58
Command: sh SCRATCH/run-ps.sh SCRATCH/poshqc-analyze.ps1 -Root "." -ScanFolder .claude/lib/blast-radius,tests/scripts/claude-lib/blast-radius
EXIT_CODE: 0

## Output (verbatim; the host path is replaced with ROOT)

```text
PSScriptAnalyzer passed: no findings under ROOT
ANALYZE-DONE folders=.claude/lib/blast-radius,tests/scripts/claude-lib/blast-radius
```

The fixed string "PSScriptAnalyzer reported" occurs 0 times in the output (grep -c -F).

Output Summary: PASS. Exit 0; the output carries "ANALYZE-DONE folders=.claude/lib/blast-radius,tests/scripts/claude-lib/blast-radius" and no line containing "PSScriptAnalyzer reported".

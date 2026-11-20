# Baseline PowerShell Coverage Reference (P0-T12)

Timestamp: 2026-10-12T16-19
Task: P0-T12

## Step 1
Command: git show HEAD:docs/features/active/2026-10-08-ci-gate-vacuous-on-empty-check-list-841/evidence/qa-gates/final-pester-coverage.2026-10-08T22-17.md
EXIT_CODE: 0
Relevant lines from the shown file (verbatim):
```
- COVERAGE file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 AnalyzedLines=46 CoveredLines=45 LinePercent=97.83
- MISSED lines: 338
- LINE counter: missed="1" covered="45" -> 45 / 46 = 97.83%
- MISSED lines: 338 (the `$NowProvider` default delegate in the `Invoke-CiGateParser` param block; every test injects a clock)
```

## Step 2
Command: git rev-parse HEAD:.claude/lib/ci-gate/Invoke-CiGateParser.ps1
EXIT_CODE: 0
Output: 7c81ef17c6d627676472ca6311c8c1f4fdecdc5d

Output Summary:
PS_BASE_REF_PCT=97.83
PS_BASE_REF_LINES=45/46
PS_BASE_REF_MISSED=338
BLOB_MATCH=true (printed blob 7c81ef17c6d627676472ca6311c8c1f4fdecdc5d equals the #841 final parser blob)
Source: committed #841 CI-equivalent evidence read with git show; no MCP result is the source of this value.

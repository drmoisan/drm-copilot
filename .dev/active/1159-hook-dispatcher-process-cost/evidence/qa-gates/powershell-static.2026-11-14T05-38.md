# PowerShell final-QC static loop, pass 2 ([P7-T2], restart after the [P7-T4] run 1 fix)

Timestamp: 2026-11-14T05-38
Command: sh SCRATCH/issue-1159-taskcheck.sh <files> "" -- per file: Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text (check mode, writes nothing), then Invoke-ScriptAnalyzer with the same settings
EXIT_CODE: 0
Output Summary: 124 new or changed .ps1/.psm1 files (git diff --name-only --diff-filter=ACMR <merge base 063504dc4b2ea08a2c5bd39b57d70ce5963815ed> HEAD). Format step: exit 0, 0 files changed. Analyzer step: exit 0, 0 findings.

| Step | Command | Exit code | Finding count | Files changed |
|---|---|---|---|---|
| Format (check mode) | Invoke-Formatter with pssa.settings.psd1 | 0 | 0 | 0 |
| Analyze | Invoke-ScriptAnalyzer with pssa.settings.psd1 | 0 | 0 | n/a |
| Type check | not applicable to PowerShell | n/a | n/a | n/a |

Correction to the pass-1 record: the 124-path list is the branch diff against the merge base, so it holds only files the branch changed; files that reached main through the merges and that the branch did not change are not in it.

# Coverage Comparison (#841, P6-T13)

Timestamp: 2026-10-10T09-42
Command: git diff -U0 5431ccdd471c184917493c4211afcd715bb4b95c -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1; added-line ranges intersected with the `line` elements of sourcefile `Invoke-CiGateParser.ps1` in artifacts/pester/powershell-coverage.xml from the P6-T3 run (09:37:10)
EXIT_CODE: 0
Output Summary:
- Loop iteration 1.
- PARSER_BASE_PCT=94.12 (P0-T12, LINE 32/34)
- PARSER_POST_PCT=97.83 (P6-T3, LINE 45/46); >= 85 and >= PARSER_BASE_PCT (+3.71 points)
- CHANGED-LINES file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 ChangedLines=79 ExecutableChanged=13 CoveredChanged=13 ChangedLinePercent=100
- CHANGED-MISSED file=.claude/lib/ci-gate/Invoke-CiGateParser.ps1 Lines= (none)
- PY_BASE_PCT=96 (P0-T15); PY_POST_PCT=96 (P6-T8); equal
- PowerShell has no branch-coverage threshold (Pester does not measure branch coverage).

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/changed-line-coverage.ps1 -ReportPath SCRATCH/cov-parser-final.txt -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -BaseSha 5431ccdd471c184917493c4211afcd715bb4b95c` was replaced by the A8 substitute: the zero-context diff's added-line ranges (from each `@@ ... +first,len @@` header) intersected by hand with the coverage XML `line` elements for the sourcefile; only lines the XML lists as executable are counted.

## Added-line ranges (post-change numbering)

28-35, 62-68, 78-81, 106-108, 134-138, 140-147, 160-163, 166-176, 178-180, 188-190, 209-218, 234-239, 310-311, 340-342, 362, 398. Total 79 lines.

## Intersection with the coverage XML

| Range | Executable lines listed in XML | Hit (ci > 0) | Missed |
|---|---|---|---|
| 28-35, 62-68, 78-81, 106-108, 134-138, 140-147, 160-163 | none (help text and param declarations) | — | — |
| 166-176 | 168, 169, 172 | 168, 169, 172 | none |
| 178-180 | 178, 179 | 178, 179 | none |
| 188-190 | 189 | 189 | none |
| 209-218 | 213, 214, 215, 216 | 213, 214, 215, 216 | none |
| 234-239 | 236, 237 | 236, 237 | none |
| 310-311, 340-342 | none (help text and param declaration) | — | — |
| 362 | 362 | 362 | none |
| 398 | none (continuation line of the call statement recorded at 391-392) | — | — |

The only missed executable line in the file, 338 (the `$NowProvider` default delegate), lies outside every added range; it is pre-existing code (baseline line 270, also missed at baseline).

PARSER_BASE_PCT=94.12
PARSER_POST_PCT=97.83
ChangedLinePercent=100
PY_BASE_PCT=96
PY_POST_PCT=96

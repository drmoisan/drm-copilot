# PowerShell Coverage Comparison (issue #997)

Timestamp: 2026-10-29T16-54
Command: pwsh SCRATCH/issue-997-read-results.ps1 (per-file LINE counters from artifacts/pester/powershell-coverage.xml after the fresh single-process run recorded in qa-gates/pester-full.2026-10-29T16-54.md; baseline from baseline/pester-full-baseline.2026-10-29T16-24.md)
EXIT_CODE: 0
Output Summary: both files at 100.00 percent line coverage, above the 85 percent threshold; no regression. Pester measures no branch coverage, so no branch gate applies.

| File | Baseline line coverage | Post-change line coverage | Threshold | Result |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 129/129 = 100.00 percent | 132/132 = 100.00 percent | 85 percent | PASS, no regression |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | not present (new file) | 56/56 = 100.00 percent | 85 percent | PASS |
| `.claude/hooks/hook-docs-only-diff.ps1` (reused, not edited) | 124/127 = 97.64 percent | 125/127 = 98.43 percent | 85 percent | informational |

Repository total line coverage: 92.93 percent at baseline, 92.95 percent after the change.

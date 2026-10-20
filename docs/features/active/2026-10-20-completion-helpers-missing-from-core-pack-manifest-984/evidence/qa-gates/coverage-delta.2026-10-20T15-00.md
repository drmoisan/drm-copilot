# QA Gate: PowerShell Coverage Delta (Issue #984)

Timestamp: 2026-10-20T15-00
Command: baseline from evidence/baseline/ps-tests.2026-10-20T13-11.md; post-change from evidence/qa-gates/ps-tests.2026-10-20T15-00.md (loop pass 3); changed lines from git diff -U0 MB -- <hook> (added or modified line numbers in the new file) evaluated against artifacts/pester/powershell-coverage.xml by sh SCRATCH/issue-984-ps.sh issue-984-changed-lines.ps1
EXIT_CODE: 0
Output Summary: every repository hook rose or held its line coverage, and every changed executable line is covered (changed-line coverage 100% for all six hooks); each post-change and changed-line value is at least 85%.

MB = `git merge-base origin/main HEAD`.

| Repository hook | Baseline | Post-change | Changed lines (new-file numbers) | Changed-line coverage |
|---|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 93.29% | 95.33% | 53 and 54 (comments, not executable), 55, 405 | 2 of 2 executable = 100% |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 95.65% | 100.00% | 39, 204 | 2 of 2 = 100% |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 90.58% | 93.53% | 64, 377 | 2 of 2 = 100% |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 90.58% | 93.53% | 64, 374 | 2 of 2 = 100% |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 95.24% | 95.28% | 55, 222 | 2 of 2 = 100% |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 95.24% | 95.28% | 55, 219 | 2 of 2 = 100% |

Pester measures line coverage only; no branch gate applies to PowerShell.

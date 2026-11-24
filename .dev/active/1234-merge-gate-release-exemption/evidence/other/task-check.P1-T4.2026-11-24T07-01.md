# Task Check P1-T4

Timestamp: 2026-11-24T07-01
Command: sh SCRATCH/issue-1234-taskcheck.sh "tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Ci.Tests.ps1" "tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Ci.Tests.ps1" "" (static; launcher `pester -TestPath` selection)
EXIT_CODE: 0
Output Summary:
- Changed files: new `tests/scripts/claude-hooks/enforce-epic-merge-gate-release.Ci.Tests.ps1` (282 lines, below 500).
- Selection rule: the new suite itself (it dot-sources the changed leg from both trees).
- First pass (2026-11-24T06-50): Pester exit 1, 26 passed, 18 failed. Cause in the test fixture: `ConvertTo-Json -InputObject @($Run) -AsArray` emits a nested array (`[[...]]`, confirmed by a SCRATCH probe), so every run-list row read as no CI run. Fix: removed `-AsArray`; the leg was not changed.
- Second pass: formatter 0 `Formatted: ` lines; analyzer 0 findings; Pester exit 0 after 1 queue timeout (exit 75, re-run), 44 tests (22 rows per tree), 0 failures.
- Rows: AC-01 unit allow with --merge, --squash, --rebase, and a 64-character head; AC-15 (3); AC-16 (2); AC-17 (2); AC-18 (1); AC-19 (9 across the three bands); AC-20 (1).

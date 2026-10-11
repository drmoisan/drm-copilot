# PowerShell Coverage Delta (P9-T3, Issue #849)

Timestamp: 2026-10-10T15-12
Command: git diff -U0 --merge-base origin/main -- .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 ; python -S (session scratchpad script) listing the `line` elements (`nr`, `ci`) of sourcefile `OrchestratorStateIssueAdoption.psm1` in package `WORKTREE_ROOT/.claude/lib/orchestrator-state` of the H1 copy `evidence/qa-gates/poshqc-local/powershell-coverage.xml`
EXIT_CODE: 0
Source: B (H0 run 38057875117, H1 run 38060952234)

## Line coverage

| Measure | Baseline (RB_PS_LINE, H0) | Post-change (P8-T5, H1) | Threshold | Result |
|---|---|---|---|---|
| Line | 112 / (0 + 112) = 100.00% | 116 / (0 + 116) = 100.00% | >= 85.0 | met, not below baseline |

## Changed-line coverage

Hunk headers from the `-U0` diff (added ranges on the `+` side):

- `@@ -45,0 +46,2 @@` -> 46-47
- `@@ -266,0 +269,7 @@` -> 269-275
- `@@ -278 +287,8 @@` -> 287-294
- `@@ -280,0 +297,4 @@` -> 297-300
- `@@ -359,2 +379,3 @@` -> 379-381

Added line numbers (24): 46, 47, 269-275, 287-294, 297, 298, 299, 300, 379, 380, 381.

Added lines that appear as `line` elements in the H1 coverage (the remaining added lines are comments, comment-based help, parameter declarations, a closing brace, and a blank line, which Pester does not instrument):

| nr | ci |
|---|---|
| 47 | 2 |
| 297 | 3 |
| 298 | 1 |
| 379 | 2 |
| 380 | 2 |
| 381 | 2 |

- Changed-line coverage: covered (ci > 0) / instrumented = 6 / 6 = 100.00% (>= 85.0).

## Branch coverage

Pester measures no branch coverage, so no PowerShell branch figure exists and no branch threshold applies.

Output Summary: PASS. OrchestratorStateIssueAdoption.psm1 line coverage 100.00% (112/112) -> 100.00% (116/116), >= 85.0 and not below baseline; changed-line 6/6 = 100.00% (lines 47, 297, 298, 379, 380, 381, all ci > 0); Pester measures no branch coverage (AC-18 coverage leg).

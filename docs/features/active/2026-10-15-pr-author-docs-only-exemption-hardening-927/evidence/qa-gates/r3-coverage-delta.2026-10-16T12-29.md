# R3 coverage delta, loop pass 1 (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-29
Command: git diff -U0 bcdc5990963c6a1f732908141a3361a29af6bafe HEAD -- .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: Loop pass 1. Repo-wide line 90.33% (baseline) to 90.37% (post); every one of the seven files is at or above 85% and at or above its baseline; helper copies 97.54% to 97.60%. Changed executable lines on the canonical helper: 4 of 4 covered (100.00%), including the read check at line 214 (ci=1) and the catch body at line 217 (ci=1). CR-N2: Codex trim line 226 ci=1.

Hunk headers: @@ -169,0 +170 @@; @@ -203 +204 @@; @@ -210,0 +212,8 @@
CHANGED_LINES: 170,204,212,213,214,215,216,217,218,219

Command 2: grep -n -F -e '$null = $pendingRead.Wait(0)' .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_2: 0
READ_CHECK_LINE: 214

Command 3: grep -n -F -e '$text = $text.Substring(0, $text.Length - 1)' .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE_3: 0
TRIM_LINE: 226

REPO_LINE_BASELINE: 90.33 (16644/18426; R3_BASE REPORT_LINE, r3-coverage-baseline.2026-10-16T11-57.md)
REPO_LINE_POST: 90.37 (16656/18431; r3-pester-route-b.2026-10-16T12-28.md)

FILE_BASELINE: .claude/hooks/hook-docs-only-diff.ps1 97.54
FILE_BASELINE: .codex/hooks/hook-docs-only-diff.ps1 97.54
FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 100.0
FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.ps1 92.98
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate.ps1 99.29
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 95.65
FILE_BASELINE: .codex/hooks/enforce-epic-merge-gate.ps1 88.41
FILE_POST: .claude/hooks/hook-docs-only-diff.ps1 97.6
FILE_POST: .codex/hooks/hook-docs-only-diff.ps1 97.6
FILE_POST: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 100.0
FILE_POST: .claude/hooks/enforce-pr-author-skill.ps1 92.98
FILE_POST: .claude/hooks/enforce-epic-merge-gate.ps1 99.29
FILE_POST: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 95.65
FILE_POST: .codex/hooks/enforce-epic-merge-gate.ps1 88.41

Command 4: poetry run python -I SCRATCH/r3/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1:170,204,212,213,214,215,216,217,218,219 .codex/hooks/hook-docs-only-diff.ps1:170,204,212,213,214,215,216,217,218,219
EXIT_CODE_4: 0
COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=170 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=204 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=212 ci=2 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=213 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=214 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=215 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=216 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=217 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=218 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=219 NOT_EXECUTABLE_OR_ABSENT
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=170 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=204 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=212 ci=2 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=213 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=214 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=215 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=216 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=217 ci=0 mi=1
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=218 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=219 NOT_EXECUTABLE_OR_ABSENT

Command 5: poetry run python -I SCRATCH/r3/read_coverage_927.py artifacts/pester/powershell-coverage.xml .codex/hooks/hook-docs-only-diff.ps1:226
EXIT_CODE_5: 0
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=226 ci=1 mi=0

CHANGED_CODE: .claude/hooks/hook-docs-only-diff.ps1 covered=4 executable=4 pct=100.00
CHANGED_CODE_INFO: .codex/hooks/hook-docs-only-diff.ps1 line 217 (catch body) ci=0; suite D has no faulting-read row (decision D-R3-2, information only)
CR_N2_TRIM_LINE: .codex/hooks/hook-docs-only-diff.ps1 nr=226 ci=1 (above 0)
LOOP_PASS: 1
R3_COVERAGE_DELTA: SATISFIED

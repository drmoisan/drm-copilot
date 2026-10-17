# R2 Coverage Delta, Loop Pass 1 (Issue #927)

Timestamp: 2026-10-16T10-53
Command: git diff -U0 df6c9d6cc411d9c445d7c8820ac8a897f5f74071 HEAD -- .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: Repo-wide line coverage went from 90.26% (CI baseline) to 90.33% (local full-population route B XML). Every file is at or above 85.00%. Both helper copies went from 97.52% to 97.54%. On the canonical helper, changed executable lines are 14 of 14 covered (100.00%), and the `$process.Dispose()` line 227 has ci=1. The Codex copy's changed lines are 13 of 14 covered and are recorded for information under D-R2-3.

Baseline source: `r2-coverage-baseline.2026-10-16T10-07.md` (R2_BASE_CI lines). Post-change source: `r2-pa1r-route-b.2026-10-16T10-53.md` (route B, loop pass 1).

## Changed lines

Hunk headers from Command 1: `@@ -168,0 +169 @@`, `@@ -200,5 +201,12 @@`, `@@ -206,2 +214,10 @@`, `@@ -209,10 +224,0 @@` (d=0, skipped), `@@ -220,2 +226,2 @@`.

CHANGED_LINES: 169,201,202,203,204,205,206,207,208,209,210,211,212,214,215,216,217,218,219,220,221,222,223,226,227

- Command 2: `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES> .codex/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES>`
  - EXIT_CODE_2: 0
- Command 3: `grep -n -F -e '$process.Dispose()' .claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_3: 0
  - Output: `227:        $process.Dispose()`

## Repo and file values

REPO_LINE_BASELINE: 90.26% (16580/18369, CI run 38876469175)
REPO_LINE_POST: 90.33% (16644/18426, local route B)

FILE_BASELINE: .claude/hooks/hook-docs-only-diff.ps1 97.52% (118/121)
FILE_BASELINE: .codex/hooks/hook-docs-only-diff.ps1 97.52% (118/121)
FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 100.00% (54/54)
FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.ps1 92.98% (53/57)
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate.ps1 99.29% (139/140)
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 95.65% (44/46)
FILE_BASELINE: .codex/hooks/enforce-epic-merge-gate.ps1 88.41% (145/164)

FILE_POST: .claude/hooks/hook-docs-only-diff.ps1 97.54% (119/122)
FILE_POST: .codex/hooks/hook-docs-only-diff.ps1 97.54% (119/122)
FILE_POST: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 100.00% (54/54)
FILE_POST: .claude/hooks/enforce-pr-author-skill.ps1 92.98% (53/57)
FILE_POST: .claude/hooks/enforce-epic-merge-gate.ps1 99.29% (139/140)
FILE_POST: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 95.65% (44/46)
FILE_POST: .codex/hooks/enforce-epic-merge-gate.ps1 88.41% (145/164)

## Line results (verbatim)

LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=169 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=201 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=202 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=203 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=204 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=205 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=206 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=207 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=208 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=209 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=210 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=211 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=212 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=214 ci=2 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=215 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=216 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=217 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=218 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=219 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=220 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=221 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=222 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=223 ci=1 mi=0
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=226 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 nr=227 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=169 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=201 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=202 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=203 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=204 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=205 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=206 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=207 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=208 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=209 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=210 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=211 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=212 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=214 ci=2 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=215 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=216 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=217 ci=0 mi=1
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=218 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=219 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=220 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=221 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=222 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=223 ci=1 mi=0
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=226 NOT_EXECUTABLE_OR_ABSENT
LINE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 nr=227 ci=1 mi=0

CHANGED_CODE: .claude/hooks/hook-docs-only-diff.ps1 covered=14 executable=14 pct=100.00
CHANGED_CODE_INFO: .codex/hooks/hook-docs-only-diff.ps1 covered=13 executable=14 pct=92.86 (line 217, the `$text = $text.Substring(...)` statement for a trailing LF, is not reached by suite D; recorded for information per D-R2-3; whole-file 97.54% is at or above the 97.52% baseline)

## Acceptance

- REPO_LINE_POST 90.33% >= 85.00%: PASS
- Each FILE_POST >= 85.00%: PASS
- Helper copies FILE_POST 97.54% >= FILE_BASELINE 97.52%: PASS
- Canonical helper covered equals executable (14 = 14), and line 227 ci=1 > 0: PASS

# R1 Coverage Delta (Issue #927, PA-1: baseline vs post-change vs changed code)

Timestamp: 2026-10-16T09-11
Command: Coverage delta from r1-ci-coverage-baseline and r1-ci-coverage
EXIT_CODE: 0
Output Summary: Baseline is merge-base CI run 38852748136; post-change is CI run 38876469175 on R1_FINAL_CODE_COMMIT 7966e1564. Repo-wide PowerShell line coverage is 90.26% (baseline 90.42%), above the 85.00% floor. Every pre-existing hook file is at or above its baseline; the new helper copies are at 97.52%. Changed-code coverage is at or above 85.00% for every edited canonical hook file, or N/A where no executable line changed.

REPO_LINE_BASELINE: covered=16381 missed=1735 line_pct=90.42 (run 38852748136)
REPO_LINE_POST: covered=16580 missed=1789 line_pct=90.26 (run 38876469175)

FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=57 missed=4 line_pct=93.44
FILE_POST: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0
FILE_BASELINE: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98
FILE_POST: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate.ps1 covered=132 missed=1 line_pct=99.25
FILE_POST: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29
FILE_BASELINE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=40 missed=2 line_pct=95.24
FILE_POST: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65
FILE_BASELINE: .codex/hooks/enforce-epic-merge-gate.ps1 covered=138 missed=19 line_pct=87.9
FILE_POST: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41
FILE_BASELINE: .claude/hooks/hook-docs-only-diff.ps1 N/A (new file)
FILE_POST: .claude/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52
FILE_BASELINE: .codex/hooks/hook-docs-only-diff.ps1 N/A (new file)
FILE_POST: .codex/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52

CHANGED_CODE: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=8 executable=8 pct=100.00
CHANGED_CODE: .claude/hooks/enforce-pr-author-skill.ps1 covered=0 executable=0 pct=N/A
CHANGED_CODE: .claude/hooks/enforce-epic-merge-gate.ps1 covered=8 executable=8 pct=100.00
CHANGED_CODE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=4 executable=4 pct=100.00
CHANGED_CODE: .codex/hooks/enforce-epic-merge-gate.ps1 covered=8 executable=9 pct=88.89 (line 403 entry-point statement, D-R1-12)
CHANGED_CODE: .claude/hooks/hook-docs-only-diff.ps1 whole-file pct=97.52
CHANGED_CODE: .codex/hooks/hook-docs-only-diff.ps1 whole-file pct=97.52

CHECK REPO_LINE_POST >= 85.00: PASS (90.26)
CHECK each FILE_POST >= 85.00: PASS (minimum 88.41)
CHECK each pre-existing FILE_POST >= FILE_BASELINE: PASS (all five equal or higher)
CHECK each CHANGED_CODE >= 85.00 or N/A: PASS (minimum 88.89)
COVERAGE_DELTA: PASS

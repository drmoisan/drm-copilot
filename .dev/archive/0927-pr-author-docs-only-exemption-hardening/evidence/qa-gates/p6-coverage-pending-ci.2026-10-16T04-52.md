# P6-T12 Final-QC Coverage Record (issue #927, loop pass 2)

Timestamp: 2026-10-16T04-52
Command: Coverage source per rule R-COV: CI artifact poshqc-test-results of job poshqc / PowerShell QC (pending PR)
EXIT_CODE: 0
Output Summary: Post-change PowerShell coverage is read only from the Windows CI artifact (rule 3, rule R-COV), so it is pending the pull request run at [P8-T3]. The baseline values from [P0-T12] are carried forward. AC9_LINES (rule R-COV C2) are 78,79,82,84, the values Appendix H applied verbatim produces. CHANGED_LINES (rule R-COV C3) are derived from `git diff -U0 origin/main...HEAD` hunk headers with d > 0 for the five edited canonical hook files; the helper copies are new files and are measured by whole-file coverage.

COVERAGE_STATUS: PENDING_CI

## Baseline (from p0-ci-coverage-baseline.2026-10-16T00-48.md, CI run 38730332356 at MERGE_BASE)

COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=57 missed=4 line_pct=93.44 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=132 missed=1 line_pct=99.25 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=40 missed=2 line_pct=95.24 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=138 missed=19 line_pct=87.9 threshold=85.00 result=PASS

## AC-9 statement lines (rule R-COV C2)

- `grep -n -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs'` -> 78
- `grep -n -F -e '$code = $LASTEXITCODE'` -> 79
- `grep -n -F -e 'return $failure'` -> 75 and 82 (larger: 82, the catch-block return)
- `grep -n -F -e 'ExitCode = [int]$code'` -> 84

AC9_LINES: 78,79,82,84

## Changed lines (rule R-COV C3)

Hunk headers (`git diff -U0 origin/main...HEAD -- <file>`): docs-only +15,5 +21,2 +30,3 +39,2 +44 +59,3 +69,2 +78 +115,5 +139,4 +158,0(skipped) +191 +219; pr-author +29,7 +38,5; Claude gate +36,11 +80,2 +417,9 +430; resolution +27,2 +246,33; Codex gate +4,13 +27,2 +144,2 +194,9 +207 +402.

CHANGED_LINES .claude/hooks/enforce-pr-author-skill.docs-only.ps1: 15,16,17,18,19,21,22,30,31,32,39,40,44,59,60,61,69,70,78,115,116,117,118,119,139,140,141,142,191,219
CHANGED_LINES .claude/hooks/enforce-pr-author-skill.ps1: 29,30,31,32,33,34,35,38,39,40,41,42
CHANGED_LINES .claude/hooks/enforce-epic-merge-gate.ps1: 36,37,38,39,40,41,42,43,44,45,46,80,81,417,418,419,420,421,422,423,424,425,430
CHANGED_LINES .claude/hooks/enforce-epic-merge-gate-resolution.ps1: 27,28,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278
CHANGED_LINES .codex/hooks/enforce-epic-merge-gate.ps1: 4,5,6,7,8,9,10,11,12,13,14,15,16,27,28,144,145,194,195,196,197,198,199,200,201,202,207,402

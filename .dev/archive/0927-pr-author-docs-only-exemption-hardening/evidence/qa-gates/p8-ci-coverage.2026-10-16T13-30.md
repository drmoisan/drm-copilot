# P8-T3 PR-head CI coverage (issue #927; AC-9, AC-21, AC-M24)

Timestamp: 2026-10-16T13-30
Command: gh run download 38905372728 -n poshqc-test-results -D SCRATCH/927/ci-head/38905372728
EXIT_CODE: 0
Output Summary: Artifact poshqc-test-results of run 38905372728 (job poshqc / PowerShell QC, PR head f82da3681f059f437573bf3b773f9a72a77b592b) downloaded into a new empty directory (files: pester-junit.xml, powershell-coverage.koverage.xml, powershell-coverage.xml). Reader exit 0. AC-21: docs-only 100.0% PASS, pr-author 92.98% PASS. AC-M24: both helper copies 97.6% PASS; every changed executable line of the three merge-gate files has ci > 0 except Codex gate line 403 (the permitted entry-point statement, ci=0). AC-9: lines 78, 79, 82, 84 have ci 2, 1, 1, 4.

Note: `gh` was run with `--repo drmoisan/drm-copilot` added. HEAD_CI_RUN_ID: 38905372728 (from p8-ci-run).

## C2 - AC9_LINES derivation at the PR head

Command 2: grep -n -F -e '& $GitInvoker -C $WorktreeRoot @GitArgs' -e '$code = $LASTEXITCODE' -e 'return $failure' -e 'ExitCode = [int]$code' .claude/hooks/enforce-pr-author-skill.docs-only.ps1
EXIT_CODE_2: 0
Matches: 75 (return $failure), 78 (& $GitInvoker ...), 79 ($code = $LASTEXITCODE), 82 (return $failure), 84 (ExitCode = [int]$code). The larger `return $failure` line (catch-block return) is 82.
AC9_LINES: 78,79,82,84

## C3 - CHANGED_LINES derivation at the PR head

Command 3: git diff -U0 origin/main...HEAD -- <file> (merge base 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea)
EXIT_CODE_3: 0

| File | Hunk headers (new side, d > 0) | CHANGED_LINES |
|---|---|---|
| .claude/hooks/enforce-pr-author-skill.docs-only.ps1 | +15,5 +21,2 +30,3 +39,2 +44 +59,3 +69,2 +78 +115,5 +139,4 +191 +219 (+158,0 excluded) | 15-19,21,22,30-32,39,40,44,59-61,69,70,78,115-119,139-142,191,219 |
| .claude/hooks/enforce-pr-author-skill.ps1 | +29,7 +38,5 | 29-35,38-42 |
| .claude/hooks/enforce-epic-merge-gate.ps1 | +36,12 +81,2 +418,9 +431 | 36-47,81,82,418-426,431 |
| .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | +27,2 +246,33 | 27,28,246-278 |
| .codex/hooks/enforce-epic-merge-gate.ps1 | +4,14 +28,2 +145,2 +195,9 +208 +403 | 4-17,28,29,145,146,195-203,208,403 |

## C1 - reader

Command 4: poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-head/38905372728/powershell-coverage.xml .claude/hooks/enforce-pr-author-skill.docs-only.ps1:<AC9_LINES>,<docs-only CHANGED_LINES> .claude/hooks/enforce-pr-author-skill.ps1:<CHANGED_LINES> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1:<CHANGED_LINES> .claude/hooks/enforce-epic-merge-gate-resolution.ps1:<CHANGED_LINES> .codex/hooks/enforce-epic-merge-gate.ps1:<CHANGED_LINES> (lists expanded from the C2 and C3 values above)
EXIT_CODE_4: 0

### COVERAGE_RESULT lines (verbatim)

COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

### AC-9 LINE_RESULT lines (verbatim)

LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=78 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=79 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=82 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=84 ci=4 mi=0

### Changed-line LINE_RESULT summary

- `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`: executable changed lines 44 (ci=2), 70 (ci=1), 78 (ci=2), 139 (ci=2), 140 (ci=1), 142 (ci=1), 191 (ci=3), 219 (ci=2); all other changed lines NOT_EXECUTABLE_OR_ABSENT. 8 of 8 covered.
- `.claude/hooks/enforce-pr-author-skill.ps1`: all 12 changed lines (29-35, 38-42) NOT_EXECUTABLE_OR_ABSENT. 0 executable changed lines.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: executable changed lines 82 (ci=3), 419 (ci=1), 420 (ci=1), 421 (ci=1), 422 (ci=1), 423 (ci=1), 425 (ci=1), 431 (ci=2); lines 36-47, 81, 418, 424, 426 NOT_EXECUTABLE_OR_ABSENT. 8 of 8 covered.
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: executable changed lines 272 (ci=2), 273 (ci=1), 274 (ci=1), 277 (ci=1); all other changed lines NOT_EXECUTABLE_OR_ABSENT. 4 of 4 covered.
- `.codex/hooks/enforce-epic-merge-gate.ps1`: executable changed lines 29 (ci=2 mi=1), 196 (ci=1), 197 (ci=1), 198 (ci=1), 199 (ci=1), 200 (ci=1), 202 (ci=1), 208 (ci=1), 403 (ci=0 mi=1); lines 4-17, 28, 145, 146, 195, 201, 203 NOT_EXECUTABLE_OR_ABSENT. 8 of 9 covered.

Verbatim Codex LINE_RESULT for the exception:

LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=403 ci=0 mi=1

Command 5: grep -n -F -e '$decision = Invoke-CodexEpicMergeDecision -PayloadRaw' .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_5: 0
Match: line 403 (the Codex gate entry-point statement).

UNCOVERED_CHANGED_LINE: .codex/hooks/enforce-epic-merge-gate.ps1 nr=403 ci=0 reason=Codex gate entry-point statement beginning `$decision = Invoke-CodexEpicMergeDecision -PayloadRaw`; it runs only when the hook executes as a process, which the in-process Pester suites do not do (AC-M24, spec revision 1.3; decision D-R1-12).

## Verdicts

AC21_RESULT: PASS (docs-only 100.0, pr-author 92.98; both result=PASS)
ACM24_RESULT: PASS (helper copies 97.6 and 97.6 result=PASS; merge-gate changed lines all ci > 0 or NOT_EXECUTABLE_OR_ABSENT except the permitted line 403)
AC9_RESULT: PASS (lines 78, 79, 82, 84 ci 2, 1, 1, 4)
P8_CI_COVERAGE: SATISFIED

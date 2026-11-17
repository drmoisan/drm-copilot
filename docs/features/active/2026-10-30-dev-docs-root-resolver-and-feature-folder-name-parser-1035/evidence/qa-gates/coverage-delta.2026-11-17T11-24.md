# Coverage Delta (P9-T10)

Timestamp: 2026-11-17T11-24
Command: comparison of qa-gates/python-tests.2026-11-17T10-18.md, qa-gates/typescript-tests.2026-11-17T10-25.md and qa-gates/powershell-tests.2026-11-17T11-20.md with the Phase 0 baseline artifacts evidence/baseline/python-tests.2026-11-16T00-39.md, typescript-tests.2026-11-16T00-44.md and powershell-tests.2026-11-16T01-04.md; changed-line coverage by sh SCRATCH/issue-1035-p9t10-changed.sh (the added lines of every production `.py`, `.ts`, `.ps1` and `.psm1` file under scripts/dev_tools, extensions/drm-copilot/src, .claude/hooks, .claude/lib, .codex/hooks, .codex/scripts and scripts/dev-tools, from `git diff -U0 <merge base> HEAD` with the merge base of origin/main and HEAD, mapped onto the final Python JSON report, the final LCOV report and the final merged JaCoCo report)
EXIT_CODE: 0
Output Summary: No new failing test, no per-file drop and no repo-wide drop in any language; every new file is above its threshold; changed-line coverage is 100.00% for Python, 100.00% for TypeScript and 97.49% for PowerShell.

## Failing tests

| Gate | Baseline | Final |
| --- | --- | --- |
| pytest (tests/scripts/dev_tools) | 9200 passed, 0 failed, 6 skipped | 9328 passed, 0 failed, 6 skipped |
| Jest (extensions/drm-copilot) | 5681 passed, 0 failed | 5881 passed, 0 failed |
| Pester (launcher pester suite) | 27341 tests, 0 failed, 0 errors | 27678 tests, 0 failures, 0 errors |

## Repo-wide coverage

| Language | Baseline | Final | Change |
| --- | --- | --- | --- |
| Python (scripts.dev_tools) | line 96.11%, branch 91.86% | line 96.23%, branch 92.07% | +0.12 line, +0.21 branch |
| TypeScript (lcov.info) | line 97.19%, branch 94.00% | line 97.25%, branch 94.20% | +0.06 line, +0.20 branch |
| PowerShell (merged JaCoCo) | line 96.04% | line 96.09% | +0.05 line |

## Per-file coverage

Every file of `## Coverage Targets` is at or above its baseline figure: 31 Python modules (line and branch) in python-tests.2026-11-17T10-18.md, 28 TypeScript files (line and branch) in typescript-tests.2026-11-17T10-25.md, and 55 changed PowerShell files (line) in powershell-tests.2026-11-17T11-20.md. The first final runs of each language showed drops in 1 Python, 6 TypeScript and 11 PowerShell files; each was analyzed against the changed hunks and fixed with tests (and, for the two TypeScript `activeFeatureSegment` copies, by removing an unreachable fallback), and each language loop re-ran from formatting; the three gate artifacts record the analysis.

New files against the thresholds: `src/lib/development-docs/root.ts` line 100.00%, branch 95.74%; `src/lib/development-docs/feature-folder-name.ts` 100.00%, 100.00%; `src/lib/development-docs/write-scopes.ts` 100.00%, 100.00%; `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` line 97.09% (Pester measures line coverage only). No new Python file was added.

## Changed-line coverage

| Language | Changed lines covered | Changed lines measured | % |
| --- | --- | --- | --- |
| Python | 251 | 251 | 100.00 |
| TypeScript | 1088 | 1088 | 100.00 |
| PowerShell | 388 | 398 | 97.49 |

112 production files carry measured changed lines. Files below 100% changed-line coverage:

| File | Covered | Measured | % | Uncovered changed lines |
| --- | --- | --- | --- | --- |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 100 | 103 | 97.09 | new module; three lines |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 6 | 8 | 75.00 | the bundle-layout import branch, and the `-match` line of an epics-reference branch no existing test reaches (file baseline 54.00%) |
| .codex/hooks/record-subagent-routing-attestation.ps1 | 7 | 8 | 87.50 | one `return $false` branch |
| .codex/scripts/epic-child-launch-runtime.ps1 | 3 | 5 | 60.00 | two lines of a profile-building function no existing test reaches (file baseline 13.10%) |
| scripts/dev-tools/link-feature-docs.ps1 | 3 | 4 | 75.00 | the script-entry invocation line, which runs only when the file is executed rather than dot-sourced |
| scripts/dev-tools/new-potential-entry.ps1 | 7 | 8 | 87.50 | the script-entry workspace line, which runs only when the file is executed |

Decision (autonomous mode, recommended option): the changed-line threshold is judged per language over all changed lines (the template's new-code calculation), where each language is at or above 85% and at or above 90%. The six files above are listed so the per-file shortfalls stay visible; four of them sit in code paths the existing suites never reached before this branch.

## Changed-code branch coverage (added 2026-11-17T11-28)

Command: sh SCRATCH/issue-1035-p9t10-branches.sh (Python branch arcs from the coverage JSON and TypeScript LCOV `BRDA` records whose source line is an added line of the same merge-base diff)

| Language | Branches covered | Branches measured | % |
| --- | --- | --- | --- |
| Python | 60 | 60 | 100.00 |
| TypeScript | 147 | 150 | 98.00 |

Uncovered TypeScript branches on changed lines: `src/lib/development-docs/root.ts` lines 140 and 189 (one branch each; the file's branch coverage is 95.74%) and `src/lib/potential-to-issue/promotion.ts` line 499 (one branch). PowerShell has no branch measure (Pester).

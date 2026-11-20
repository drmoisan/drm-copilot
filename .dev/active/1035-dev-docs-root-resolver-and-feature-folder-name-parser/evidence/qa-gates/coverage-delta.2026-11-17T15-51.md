# Coverage Delta (Remediation Cycle 1, P3-T5)

Timestamp: 2026-11-17T15-51
Command: sh SCRATCH/issue-1035-pycmp.sh (Python per-module comparison of the P0-T2 and P3-T2 JSON reports); sh SCRATCH/issue-1035-pscmp.sh p0 p3b (Pester per-file comparison and changed-line coverage from `git diff -U0 <Baseline-Head>` against the line records of the coverage XML); sh SCRATCH/issue-1035-files.sh (`git diff --name-status <Baseline-Head> HEAD`, `git status --porcelain`, logical line counts with `awk 'END { print NR }'`)
EXIT_CODE: 0
Output Summary: Every F1 row meets its target and none dropped; both seam files reach at least 90% changed-line coverage; no changed file reaches 500 logical lines; every changed file is in the allowed set. Sources: python-tests.2026-11-17T15-04.md and powershell-tests.2026-11-17T15-50.md (qa-gates), and python-tests.2026-11-17T12-36.md and powershell-tests.2026-11-17T12-57.md (remediation-baseline). Baseline-Head is 4ba9c6ab33076366b1d40e0ccb3d61142e1278d4; HEAD at the comparison is 520d78e8aa3a9f9f591bb76d3286e43dc2ad1247.

## F1 rows

| File | Baseline | Post-change | Target | Status |
| --- | --- | --- | --- | --- |
| scripts/dev_tools/copy_research_to_issue.py | line 50.00 (41/82), branch 46.15 (12/26) | line 100.00 (82/82), branch 100.00 (26/26) | line 85, branch 75 | met |
| scripts/dev_tools/plan_progress_report.py | line 82.35 (84/102), branch 84.62 (22/26) | line 99.02 (101/102), branch 96.15 (25/26) | line 85 | met |
| scripts/dev_tools/atomic_executor/cli.py | line 89.07 (163/183), branch 73.08 (38/52) | line 93.44 (171/183), branch 82.69 (43/52) | branch 75 | met |
| .codex/hooks/authorize-root-epic-invocation.ps1 | line 55.66 (59/106) | line 98.23 (111/113) | line 85 | met |
| .codex/hooks/enforce-completion-helpers.ps1 | line 83.58 (56/67) | line 100.00 (67/67) | line 85 | met |
| .codex/scripts/epic-child-launch-contract.ps1 | line 82.20 (194/236) | line 94.07 (222/236) | line 85 | met |
| .codex/scripts/epic-child-launch-runtime.ps1 | line 20.69 (48/232) | line 93.64 (221/236) | line 85 | met |
| scripts/dev-tools/link-feature-docs.ps1 | line 82.61 (38/46) | line 91.30 (42/46) | line 85 | met |
| scripts/dev-tools/new-potential-entry.ps1 | line 82.42 (75/91) | line 91.21 (83/91) | line 85 | met |

## Repo-wide deltas

| Language | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Python (`--cov=scripts`) | line 96.24 (17649/18338), branch 92.07 (6161/6692) | line 96.60 (17715/18338), branch 92.38 (6182/6692) | +0.36 line, +0.31 branch |
| PowerShell (merged Pester XML) | line 96.13 (45471/47304) | line 96.69 (45747/47315) | +0.56 line |
| TypeScript root / extension (D-R5 references) | 98.21 / 97.25 line, 93.98 / 94.20 branch | identical | 0 (no TypeScript change) |

Per-file comparisons: Python 229 modules, no line drop; one branch difference in scripts/dev_tools/atomic_executor/cli_copilot_runtime.py (70.45 to 69.32), a timing-dependent arc in unchanged code recorded in python-tests.2026-11-17T15-04.md. PowerShell 465 files, 0 drops. TypeScript 290 and 261 files, 0 drops.

## Changed-line coverage of the seam files (instrumented changed lines against Baseline-Head)

| File | Changed lines | Instrumented | Covered | Percent | Missed |
| --- | --- | --- | --- | --- | --- |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 77 | 30 | 28 | 93.33 | the one-line body of Invoke-RootEpicGitExe; the one-line entry block |
| .codex/scripts/epic-child-launch-runtime.ps1 | 18 | 8 | 8 | 100.00 | none |

The first read (powershell-tests.2026-11-17T15-24.md) gave 79.31% for the hook; the fix recorded in other/task-check.P3-T5.2026-11-17T15-29.md raised it, and the PowerShell static loop and Pester gate were re-run after the fix commit.

## Logical line counts of changed files (all below 500)

| Lines | File |
| --- | --- |
| 288 | .codex/hooks/authorize-root-epic-invocation.ps1 (and its bundle copy) |
| 463 | .codex/scripts/epic-child-launch-runtime.ps1 (and its bundle copy) |
| 256 | tests/scripts/codex-hooks/authorize-root-epic-invocation.Tests.ps1 |
| 244 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 |
| 203 | tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1 |
| 307 | tests/scripts/codex-hooks/epic-child-launch-contract.Tests.ps1 |
| 352 | tests/scripts/codex-hooks/epic-child-launch-runtime.Tests.ps1 |
| 314 | tests/scripts/dev-tools/link-feature-docs.Tests.ps1 |
| 88 | tests/scripts/dev-tools/new-potential-entry.EntryGuards.Tests.ps1 |
| 108 | tests/scripts/dev_tools/atomic_executor/test_cli_compat_proxies.py |
| 451 | tests/scripts/dev_tools/test_copy_research_to_issue.py |
| 355 | tests/scripts/dev_tools/test_plan_progress_report.py |

## Cycle file list

`git diff --name-status <Baseline-Head> HEAD` lists: M .codex/hooks/authorize-root-epic-invocation.ps1; M .codex/scripts/epic-child-launch-runtime.ps1; M and the same two paths under extensions/drm-copilot/resources/codex-and-agents-customizations/; A tests/scripts/codex-hooks/authorize-root-epic-invocation.Tests.ps1, enforce-completion-helpers.Tests.ps1, epic-child-launch-contract.Tests.ps1, epic-child-launch-runtime.Tests.ps1; M tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1; M tests/scripts/dev-tools/link-feature-docs.Tests.ps1; A tests/scripts/dev-tools/new-potential-entry.EntryGuards.Tests.ps1; A tests/scripts/dev_tools/atomic_executor/test_cli_compat_proxies.py; M tests/scripts/dev_tools/test_copy_research_to_issue.py and test_plan_progress_report.py; A the remediation plan; A evidence files under evidence/other/, evidence/qa-gates/ and evidence/remediation-baseline/. `git status --porcelain` before this artifact listed only the two untracked re-run artifacts powershell-static.2026-11-17T15-50.md and powershell-tests.2026-11-17T15-50.md under evidence/qa-gates/. Every path is in the allowed set of `## Scope and Standing Rules`: test files named in the tasks, the two seam files and their bundle copies, the plan, and evidence. No other production file, no TypeScript file, and no new Python module changed.

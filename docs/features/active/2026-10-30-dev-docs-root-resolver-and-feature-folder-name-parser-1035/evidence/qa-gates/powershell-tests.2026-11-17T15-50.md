# PowerShell Test Gate, Re-run (Remediation Cycle 1, P3-T3 after the P3-T5 fix)

Timestamp: 2026-11-17T15-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (sh SCRATCH/issue-1035-pester.sh p3b; one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded; the P0-T3 form). Figures read with SCRATCH/issue-1035-psfig.ps1 from copies under SCRATCH/pester-p3b/; per-file comparison with the Phase 0 coverage XML and changed-line coverage by SCRATCH/issue-1035-pscmp.sh p0 p3b.
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 758.88 s, exit code 0. Merged JUnit: 836 suites, 27974 tests, 0 failures, 0 errors, 22 disabled or skipped. Repo-wide line coverage 96.69% (45747/47315); Phase 0 96.13% (45471/47304). Run 2026-11-17T15-37-40 to 15-50-20 UTC at HEAD 520d78e8aa3a9f9f591bb76d3286e43dc2ad1247. This run supersedes powershell-tests.2026-11-17T15-24.md as the gate after the last PowerShell commit.

| File | Line % Phase 0 | Line % final | Target | Status |
| --- | --- | --- | --- | --- |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 55.66 (59/106) | 98.23 (111/113) | 85 | met |
| .codex/hooks/enforce-completion-helpers.ps1 | 83.58 (56/67) | 100.00 (67/67) | 85 | met |
| .codex/scripts/epic-child-launch-contract.ps1 | 82.20 (194/236) | 94.07 (222/236) | 85 | met |
| .codex/scripts/epic-child-launch-runtime.ps1 | 20.69 (48/232) | 93.64 (221/236) | 85 | met |
| scripts/dev-tools/link-feature-docs.ps1 | 82.61 (38/46) | 91.30 (42/46) | 85 | met |
| scripts/dev-tools/new-potential-entry.ps1 | 82.42 (75/91) | 91.21 (83/91) | 85 | met |

Per-file comparison with the Phase 0 coverage XML: 465 files in both runs, 0 files with a lower line percentage.

Report freshness: the last commit touching a `.ps1` file is 520d78e8aa3a9f9f591bb76d3286e43dc2ad1247, committed 2026-11-17T10:30:10-05:00 (15:30:10 UTC); artifacts/pester/powershell-coverage.xml was written 2026-11-17T15-50-20 UTC, after that commit.

Changed-line coverage against Baseline-Head (instrumented changed lines): .codex/hooks/authorize-root-epic-invocation.ps1 28 of 30 (93.33%; missed: the one-line body of Invoke-RootEpicGitExe and the one-line entry block, neither of which runs under a dot-sourcing test); .codex/scripts/epic-child-launch-runtime.ps1 8 of 8 (100.00%).

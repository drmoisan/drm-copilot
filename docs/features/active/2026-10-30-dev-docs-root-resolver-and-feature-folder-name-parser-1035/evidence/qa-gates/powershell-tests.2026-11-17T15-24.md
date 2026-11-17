# PowerShell Test Gate (Remediation Cycle 1, P3-T3)

Timestamp: 2026-11-17T15-24
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (sh SCRATCH/issue-1035-pester.sh p3; one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json, integration and golden lanes excluded; the P0-T3 form). Figures read with SCRATCH/issue-1035-psfig.ps1 from copies under SCRATCH/pester-p3/; the per-file comparison with the Phase 0 coverage XML by SCRATCH/issue-1035-pscmp.sh p0 p3.
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 1022.97 s, exit code 0. Merged JUnit: 836 suites, 27971 tests, 0 failures, 0 errors, 22 disabled or skipped. Repo-wide line coverage 96.68% (45742/47314); Phase 0 96.13% (45471/47304). Run 2026-11-17T15-06-02 to 15-23-07 UTC at HEAD e10f769352dffd18ac3608d74c41fd2c4db6244c.

| File | Line % Phase 0 | Line % final | Target | Status |
| --- | --- | --- | --- | --- |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 55.66 (59/106) | 94.64 (106/112) | 85 | met |
| .codex/hooks/enforce-completion-helpers.ps1 | 83.58 (56/67) | 100.00 (67/67) | 85 | met |
| .codex/scripts/epic-child-launch-contract.ps1 | 82.20 (194/236) | 94.07 (222/236) | 85 | met |
| .codex/scripts/epic-child-launch-runtime.ps1 | 20.69 (48/232) | 93.64 (221/236) | 85 | met |
| scripts/dev-tools/link-feature-docs.ps1 | 82.61 (38/46) | 91.30 (42/46) | 85 | met |
| scripts/dev-tools/new-potential-entry.ps1 | 82.42 (75/91) | 91.21 (83/91) | 85 | met |

Per-file comparison with the Phase 0 coverage XML: 465 files in both runs, 0 files with a lower line percentage.

Report freshness: the last commit touching a `.ps1` file is e10f769352dffd18ac3608d74c41fd2c4db6244c, committed 2026-11-17T09:53:32-05:00 (14:53:32 UTC); artifacts/pester/powershell-coverage.xml was written 2026-11-17T15-23-06 UTC, after that commit.

Changed-line read for P3-T5 from the same run: .codex/scripts/epic-child-launch-runtime.ps1 8 of 8 instrumented changed lines covered; .codex/hooks/authorize-root-epic-invocation.ps1 23 of 29 (79.31%), missed: the two body lines of Invoke-RootEpicGitExe and the four lines of the entry block.

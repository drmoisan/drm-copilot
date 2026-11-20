# PowerShell Test Baseline (Remediation Cycle 1, P0-T3)

Timestamp: 2026-11-17T12-57
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (sh SCRATCH/issue-1035-pester.sh p0; the launcher pester suite runs one Invoke-PoshQCParallelTest over the scan folders of config/poshqc-scan.json with the integration and golden lanes excluded). Figures read with SCRATCH/issue-1035-psfig.ps1 (emitted by sh SCRATCH/issue-1035-psfig-only.sh p0) from copies of artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml under SCRATCH/pester-p0/.
EXIT_CODE: 0
Baseline-Head: 4ba9c6ab33076366b1d40e0ccb3d61142e1278d4
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 1122.98 s, exit code 0. Merged JUnit: 831 suites, 27827 tests, 0 failures, 0 errors, 22 disabled or skipped. Repo-wide line coverage 96.13% (45471/47304). Run 2026-11-17T12-37-28 to 12-56-11 UTC; the merged JUnit and coverage files were written 2026-11-17T12-56-11 UTC, after the run start.

| File | Line % (covered/total) |
| --- | --- |
| .codex/hooks/authorize-root-epic-invocation.ps1 | 55.66 (59/106) |
| .codex/hooks/enforce-completion-helpers.ps1 | 83.58 (56/67) |
| .codex/scripts/epic-child-launch-contract.ps1 | 82.20 (194/236) |
| .codex/scripts/epic-child-launch-runtime.ps1 | 20.69 (48/232) |
| scripts/dev-tools/link-feature-docs.ps1 | 82.61 (38/46) |
| scripts/dev-tools/new-potential-entry.ps1 | 82.42 (75/91) |

The first figure pass passed the six paths as one comma-joined string and matched no file; the reader was corrected to split the list and re-run against the same copied XML files. The suite was not re-run.

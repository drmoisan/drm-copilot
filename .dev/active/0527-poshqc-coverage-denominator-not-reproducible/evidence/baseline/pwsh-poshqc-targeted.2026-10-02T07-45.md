# Baseline Targeted PoshQC Tests (P0-T8)

Timestamp: 2026-10-02T07-45
Command: CI-evidence deviation DEV-P0-T8 (replaces TR args 'tests/scripts/powershell/PoshQC', ''). Source: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job `poshqc / PowerShell QC` https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219; baseline pester-junit.xml filtered by the orchestrator with `poetry run python artifacts/ci/ci_evidence.py tr artifacts/ci/run-36978425380/pester-junit.xml tests/scripts/powershell/PoshQC` (JUnit filter equivalent to rule TR) into artifacts/ci/run-36978425380/tr-poshqc.txt, read with the Read tool; container check by `grep -o '<testsuite [^>]*PoshQC[^>]*>' artifacts/ci/run-36978425380/pester-junit.xml`.
EXIT_CODE: 0
Output Summary: PASSED=111 FAILED=0 SKIPPED=7 MISSING_REQUIRED=0 FAILED_CONTAINERS=0
- The JUnit filter prints no FAILED_CONTAINERS field. FAILED_CONTAINERS=0 is derived from the ten `testsuite` elements under tests/scripts/powershell/PoshQC, each with errors="0" and failures="0" (a container that fails discovery is reported by Pester as a suite with errors).
- Ten suites (the ten existing PoshQC test files): Get-PoshQCFileList.Excludes (1), PoshQC.Comprehensive (33, 7 skipped), PoshQC.EntryPoints (5), PoshQC.ScanConfig (12), PoshQC.ScanFolders (17), PoshQC.TestingCoveragePruning (4), PoshQC.TestingInvokeConfigPaths (5), PoshQC.TestingInvokeSummary (3), PoshQC.TestingSeamDefaults (4), PoshQC.Tests (34); total 118 = 111 passed + 7 skipped.
- EXIT_CODE is the CI job conclusion (success). Measured tree identical to the branch baseline.
- Acceptance: EXIT_CODE 0, FAILED=0, FAILED_CONTAINERS=0. Met.

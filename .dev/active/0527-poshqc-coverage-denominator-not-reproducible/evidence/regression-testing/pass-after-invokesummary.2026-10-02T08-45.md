# Pass-After: PoshQC.TestingInvokeSummary.Tests.ps1 (P4-T4)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P4-TR (replaces TR args 'tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1', ''). Source: run A https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194 (a987ebfb). Reduced by the orchestrator with `poetry run python artifacts/ci/ci_evidence.py tr artifacts/ci/run-36983551836/pester-junit.xml PoshQC.TestingInvokeSummary` into `artifacts/ci/run-36983551836/tr-invokesummary.txt`, read with the Read tool.
EXIT_CODE: 0
Output Summary: PASSED=3 FAILED=0 SKIPPED=0 MISSING_REQUIRED=0 FAILED_CONTAINERS=0
- FAILED_CONTAINERS=0 derived from the absence of any container/discovery failure line and of any `##[error][-]` line in the run A job log.
- The two D14 tests that failed on the pre-adaptation head (P4-T2) pass here; the edit itself is recorded under DEV-P4-T4 in the plan-deviations register.
- Acceptance: FAILED=0 and FAILED_CONTAINERS=0. Met.

# Pass-After: All PoshQC Test Files (P4-T6)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P4-TR (replaces TR args 'tests/scripts/powershell/PoshQC', ''). Source: run A https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194 (a987ebfb). Orchestrator reduction `poetry run python artifacts/ci/ci_evidence.py tr artifacts/ci/run-36983551836/pester-junit.xml tests/scripts/powershell/PoshQC` (tr-poshqc.txt); executor re-ran the same filter this segment as `poetry -C <ROOT> run python <ROOT>/artifacts/ci/ci_evidence.py tr <ROOT>/artifacts/ci/run-36983551836/pester-junit.xml tests/scripts/powershell/PoshQC`, exit 0, identical output.
EXIT_CODE: 0
Output Summary: PASSED=141 FAILED=0 SKIPPED=7 MISSING_REQUIRED=0 FAILED_CONTAINERS=0
- Covers the twelve PoshQC test files (ten existing plus the two Phase 2 files). The 30 new nodes account for the increase from the P0-T8 baseline.
- FAILED_CONTAINERS=0 derived from the absence of container/discovery failure lines in the run A job log and JX `ERRORS=0`.
- Acceptance: FAILED=0 and FAILED_CONTAINERS=0. Met.

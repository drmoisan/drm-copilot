# Phase 0 Baseline - Pester Gate (P0-T3)

Timestamp: 2026-11-23T13-00
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml with SCRATCH/issue-1221-pester-summary.ps1
EXIT_CODE: 0
Output Summary: Launcher exit 0 (no queue timeout). tests=29478, passed=29460, failures=0, errors=0, skipped=18 (disabled=22 in the JUnit root). Repo-wide line coverage 96.85% (47360 covered, 1541 missed). Per-file line coverage: DocsValidation.psm1 98.72% (154/156), DocsValidateCommands.psm1 100% (102/102), DocsCoverageReport.psm1 100% (78/78), DocsLedgerCommands.psm1 99.69% (325/326). DocsFamilyCheck.psm1 does not exist yet (new file; judged against the thresholds at the final gate).

## Failing Tests

None. FAILED_COUNT=0, so no pre-existing failure is carried into the phase gates.

## Run Facts

- Wall clock: 781.42 s (Invoke-PoshQCParallelTest: workers=8; exit code=0).
- Merged JUnit and coverage files were written, which happens only after a fully green run.
- Copies of both merged files were kept under SCRATCH/baseline-pester/ for the final comparison.

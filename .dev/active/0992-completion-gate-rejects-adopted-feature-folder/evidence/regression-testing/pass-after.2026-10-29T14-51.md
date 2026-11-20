# Pass-After Run (P6-T1)

Timestamp: 2026-10-29T14-51
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py -p no:cacheprovider --no-cov -v
EXIT_CODE: 0
Output Summary: The P1-T11 set passes in all three runtimes after the fix. Python 112 passed; Jest 138 passed in 3 suites; Pester 170 passed (JUnit). The unchanged cases `waives-validate-orchestration-artifacts`, `case-variant-tool-name`, and `absent-key-large-missing-receipt` pass in all three parity suites (AC-4, AC-6).

| Runtime | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| Python | pytest command above | 0 | 112 passed, 0 failed |
| TypeScript | `node run-jest.cjs test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts test/lib/validate/orchestrator-state-issue-adoption.test.ts test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts --json --outputFile=SCRATCH/issue-992-jest-passafter.json` (in extensions/drm-copilot) | 0 | 3 suites passed; 138 passed, 0 failed |
| PowerShell | Invoke-Pester, one process, JUnit to SCRATCH/issue-992-passafter-junit.xml, over `OrchestratorStateIssueAdoption.Parity.Tests.ps1`, `OrchestratorStateIssueAdoption.Tests.ps1`, `OrchestratorStateFeatureFolderRecord.Tests.ps1`, `validate-orchestrator-output.FeatureFolder.Tests.ps1` | 0 | JUnit: tests=170, failures=0, errors=0, skipped=0 (per file: 51, 49, 48, 22 passed) |

## Named unchanged cases (AC-4, AC-6)

| Case | Python | Jest | Pester |
| --- | --- | --- | --- |
| waives-validate-orchestration-artifacts | PASSED | passed (no failure messages) | present in JUnit, no failure |
| case-variant-tool-name | PASSED | passed (no failure messages) | present in JUnit, no failure |
| absent-key-large-missing-receipt | PASSED | passed (no failure messages) | present in JUnit, no failure |

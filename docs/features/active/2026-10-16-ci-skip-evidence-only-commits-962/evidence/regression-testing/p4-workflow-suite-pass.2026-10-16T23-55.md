# Workflow suite passes after the gating edits (P4-T11, AC-23 pass-after)

Timestamp: 2026-10-16T23-55
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -NamePatternList "*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*"
EXIT_CODE: 0
Output Summary: SUITE Passed=39 Failed=0; NAMED totals AC-18 5, AC-19 9, AC-20 21, AC-21 3, AC-36 1, all Failed=0; EXIT_CODE_COMPUTED: 0. Fail-before counterpart: expect-fail-new-suites.2026-10-16T23-42.md (W suite Passed=7, Failed=32). AC-36 is not checked here (P7-T3). CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-18)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-19)* | Passed=9 | Failed=0 | Total=9
NAMED: *(AC-20)* | Passed=21 | Failed=0 | Total=21
NAMED: *(AC-21)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares the changes job as Change scope with actions read and contents read (AC-18)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | binds the changes job output code to steps.scope.outputs.code (AC-18)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | checks out the pull request head with fetch-depth 0, filter blob:none, and persist-credentials false (AC-18)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | runs scripts/ci/Invoke-CiChangeScope.ps1 in a pwsh step with id scope and continue-on-error true (AC-18)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares full-run-marker as CI full run that needs changes and runs only when code is not false (AC-18)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires quality-checks7 with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires security-scan with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires build-check with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires poshqc with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires shell-coverage with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | wires drm-copilot-extension-tests with needs changes, if !cancelled(), and run-heavy from the changes output (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | skips root-typescript-tests at job level when code is false (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | skips npm-audit-gate at job level when code is false (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | keeps docs-validation without needs and without if (AC-19)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _quality-checks.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _security-scan.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _build-check.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _shell-coverage.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _drm-copilot-extension-tests.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | declares run-heavy as a boolean defaulting to true under both triggers in _poshqc.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of quality-checks7 on inputs.run-heavy in _quality-checks.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of security-scan on inputs.run-heavy in _security-scan.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of build-check on inputs.run-heavy in _build-check.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of shell-coverage on inputs.run-heavy in _shell-coverage.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of drm-copilot-extension-tests on inputs.run-heavy in _drm-copilot-extension-tests.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every step of poshqc on inputs.run-heavy in _poshqc.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | combines run-heavy with the poetry cache-miss condition in _quality-checks.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | combines run-heavy with the 3.13-only condition in _quality-checks.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | combines run-heavy with the kcov cache-miss condition in _shell-coverage.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _quality-checks.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _security-scan.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _build-check.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _shell-coverage.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _drm-copilot-extension-tests.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | leaves no bare always() step condition outside a job gated at job level on run-heavy in _poshqc.yml (AC-20)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | skips every _poshqc.yml job other than poshqc at job level unless run-heavy (AC-21)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | keeps the poshqc job-level condition free of run-heavy and keeps if always() in the sharded shape (AC-21)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | gates every poshqc step, including any step whose name begins Require, on run-heavy (AC-21)
ROW: Passed | tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | runs the security scan under bash after installing the Poetry export plugin and without continue-on-error (AC-36)
TOTAL: Passed=39 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```

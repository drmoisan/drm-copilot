# Edit points re-derived on the head (P0-T9, PD-2)

Timestamp: 2026-10-16T23-23
Command: sh SCRATCH/tools/run-cr.sh cr-inventory
EXIT_CODE: 0
Output Summary: Head 69907850a carries the sharded `_poshqc.yml` of #953 (jobs poshqc, poshqc-linux-hooks, poshqc-shard, poshqc-static; aggregator `if: always()`; one `Require` step). ci.yml has no merge_group trigger, so A2 is not applicable. The A4 and A4C targets each occur exactly once (lines 85 and 51). All block checks pass. Seven W rows are expected to pass before Phase 4.

## Derived lines

POSHQC-SHAPE: sharded
CI-MERGE-GROUP: absent
POSHQC-AGGREGATOR-IF: always()
POSHQC-REQUIRE-STEP: Require the static and shard jobs to succeed
A2-APPLICABLE: no
LIST-EDITED-SUITES: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
LIST-EXISTING-SUITES: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
W-PASS-BEFORE: W8, W14 (_quality-checks.yml), W14 (_security-scan.yml), W14 (_build-check.yml), W14 (_shell-coverage.yml), W14 (_drm-copilot-extension-tests.yml), W16 (7 rows; the W14 row for _poshqc.yml fails before Phase 4 because poshqc-shard and poshqc-linux-hooks have `always()` step conditions and no job-level run-heavy gate yet)

EDIT-TARGET-A2: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A2B: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=85
EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=51

BLOCK-CHECKS: B1=pass B2=pass B3=pass B4=pass B5=pass B6=pass B7=pass

Block-check derivation:

- B1: `POSHQC-SHAPE: sharded` (not unknown).
- B2: sharded shape; `JOB-IF: .github/workflows/_poshqc.yml | poshqc | always()`.
- B3: sharded shape; exactly one poshqc step name begins `Require` (step 1).
- B4: `Install dependencies` and `Upload coverage to Codecov` present in `_quality-checks.yml`; `Build kcov from source` present in `_shell-coverage.yml`.
- B5: the nine ci.yml caller jobs (quality-checks7, security-scan, docs-validation, build-check, poshqc, shell-coverage, drm-copilot-extension-tests, root-typescript-tests, npm-audit-gate) are present.
- B6: A4 count=1 (line 85) and A4C count=1 (line 51); no candidate lines.
- B7: A2 and A2B both absent (count=0), so `A2-APPLICABLE: no`.

## Full CR output

```
RUN-CR: cr-inventory
ONBLOCK-START: .github/workflows/ci.yml | line=3
JOBS-LINE: .github/workflows/ci.yml | line=10
JOB: .github/workflows/ci.yml | quality-checks7 | line=11
JOB: .github/workflows/ci.yml | security-scan | line=14
JOB: .github/workflows/ci.yml | docs-validation | line=17
JOB: .github/workflows/ci.yml | build-check | line=20
JOB: .github/workflows/ci.yml | poshqc | line=23
JOB: .github/workflows/ci.yml | shell-coverage | line=26
JOB: .github/workflows/ci.yml | drm-copilot-extension-tests | line=29
JOB: .github/workflows/ci.yml | root-typescript-tests | line=32
JOB: .github/workflows/ci.yml | npm-audit-gate | line=35
ONBLOCK-START: .github/workflows/_quality-checks.yml | line=3
JOBS-LINE: .github/workflows/_quality-checks.yml | line=7
JOB: .github/workflows/_quality-checks.yml | quality-checks7 | line=8
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 1 | Check out repository
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 2 | Set up Python ${{ matrix.python-version }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 3 | Install Poetry
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 4 | Load cached venv
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 5 | Install dependencies
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 5 | steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 6 | Install project
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 7 | Verify poetry.lock is in sync
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 8 | Check formatting with Black
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 9 | Lint with Ruff
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 10 | Type check with Pyright
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 11 | Verify Codex agent deployment profiles
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 12 | tier-classification
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 13 | Run tests with Pytest
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 14 | Enforce Python coverage thresholds
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 15 | Upload coverage to Codecov
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 15 | matrix.python-version == '3.13'
ONBLOCK-START: .github/workflows/_security-scan.yml | line=3
JOBS-LINE: .github/workflows/_security-scan.yml | line=7
JOB: .github/workflows/_security-scan.yml | security-scan | line=8
STEP: .github/workflows/_security-scan.yml | security-scan | 1 | Check out repository
STEP: .github/workflows/_security-scan.yml | security-scan | 2 | Set up Python
STEP: .github/workflows/_security-scan.yml | security-scan | 3 | Install Poetry
STEP: .github/workflows/_security-scan.yml | security-scan | 4 | Check for security vulnerabilities
ONBLOCK-START: .github/workflows/_build-check.yml | line=3
JOBS-LINE: .github/workflows/_build-check.yml | line=7
JOB: .github/workflows/_build-check.yml | build-check | line=8
STEP: .github/workflows/_build-check.yml | build-check | 1 | Check out repository
STEP: .github/workflows/_build-check.yml | build-check | 2 | Set up Python
STEP: .github/workflows/_build-check.yml | build-check | 3 | Install Poetry
STEP: .github/workflows/_build-check.yml | build-check | 4 | Build package
STEP: .github/workflows/_build-check.yml | build-check | 5 | Verify package can be installed
STEP: .github/workflows/_build-check.yml | build-check | 6 | Shell QC smoke (native)
ONBLOCK-START: .github/workflows/_shell-coverage.yml | line=3
JOBS-LINE: .github/workflows/_shell-coverage.yml | line=7
JOB: .github/workflows/_shell-coverage.yml | shell-coverage | line=8
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 1 | Check out repository
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 2 | Install shell tooling (shellcheck, shfmt, bats)
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 3 | Cache kcov build
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 4 | Build kcov from source
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 4 | steps.cache-kcov.outputs.cache-hit != 'true'
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 5 | Install kcov from cache
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 6 | Run shell-qc check (shfmt diff + shellcheck)
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 7 | Run shell-qc test with coverage
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 8 | Upload shell coverage artifacts
ONBLOCK-START: .github/workflows/_drm-copilot-extension-tests.yml | line=3
JOBS-LINE: .github/workflows/_drm-copilot-extension-tests.yml | line=7
JOB: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | line=8
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 1 | Check out repository
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 2 | Set up Node.js
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 3 | Install extension dependencies
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 4 | Type-check extension source and test tree
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 5 | Run extension unit/integration tests
ONBLOCK-START: .github/workflows/_poshqc.yml | line=3
JOBS-LINE: .github/workflows/_poshqc.yml | line=7
JOB: .github/workflows/_poshqc.yml | poshqc-static | line=8
STEP: .github/workflows/_poshqc.yml | poshqc-static | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-static | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-static | 3 | Format PowerShell
STEP: .github/workflows/_poshqc.yml | poshqc-static | 4 | Analyze PowerShell
JOB: .github/workflows/_poshqc.yml | poshqc-shard | line=40
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 3 | Test PowerShell
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 4 | Upload PowerShell shard test artifacts
STEP-IF: .github/workflows/_poshqc.yml | poshqc-shard | 4 | always()
JOB: .github/workflows/_poshqc.yml | poshqc | line=75
JOB-NEEDS: .github/workflows/_poshqc.yml | poshqc | [poshqc-static, poshqc-shard]
JOB-IF: .github/workflows/_poshqc.yml | poshqc | always()
STEP: .github/workflows/_poshqc.yml | poshqc | 1 | Require the static and shard jobs to succeed
STEP: .github/workflows/_poshqc.yml | poshqc | 2 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc | 3 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc | 4 | Download PowerShell shard test artifacts
STEP: .github/workflows/_poshqc.yml | poshqc | 5 | Verify shard completeness
STEP: .github/workflows/_poshqc.yml | poshqc | 6 | Merge PowerShell shard coverage
STEP: .github/workflows/_poshqc.yml | poshqc | 7 | Upload PowerShell test artifacts
JOB: .github/workflows/_poshqc.yml | poshqc-linux-hooks | line=150
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 3 | Test PowerShell hook suites
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 4 | Upload PowerShell hook-suite test results
STEP-IF: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 4 | always()
POSHQC-JOB-SET: poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static
POSHQC-SHAPE: sharded
CI-MERGE-GROUP: absent
EDIT-TARGET-A2: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A2B: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=85
EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=1 | lines=51
WORKFLOW-REFERENCING-SUITE: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
LIST-EXISTING-SUITES: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
EXIT_CODE_COMPUTED: 0
```

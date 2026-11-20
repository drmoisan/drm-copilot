# Edit points re-derived after re-integration (rule 17 RI-2 re-run of P0-T9)

Timestamp: 2026-10-17T00-09
Command: sh SCRATCH/tools/run-cr.sh cr-inventory
EXIT_CODE: 0
Output Summary: Head 32350256b (merge of origin/main b8fcd7790, #952) keeps the sharded _poshqc.yml and now carries the merge_group trigger. The #952 event-field row of CiWorkflow.Tests.ps1 is present (A2 target line 232, A2B anchor line 236, each count=1), so A2 applies. A4 and A4C were applied in P4-T6 and are unchanged by the merge (candidates are the replacement texts; B6 passes under plan-trivial-fixes Fix 2). All block checks pass. LIST-EXISTING-SUITES now also lists the new CiChangeScopeWorkflow.Tests.ps1 (plan-trivial-fixes Fix 3).

## Derived lines

POSHQC-SHAPE: sharded
CI-MERGE-GROUP: present
POSHQC-AGGREGATOR-IF: always()
POSHQC-REQUIRE-STEP: Require the static and shard jobs to succeed
A2-APPLICABLE: yes
LIST-EDITED-SUITES: tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
LIST-EXISTING-SUITES: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
W-PASS-BEFORE: W8, W14 (_quality-checks.yml), W14 (_security-scan.yml), W14 (_build-check.yml), W14 (_shell-coverage.yml), W14 (_drm-copilot-extension-tests.yml), W16 (mechanical derivation unchanged; informational only, because Phase 1 is not re-run by rule 17)

EDIT-TARGET-A2: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=1 | lines=232
EDIT-TARGET-A2B: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=1 | lines=236
EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4-CANDIDATE: line=85 |             if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {
EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4C-CANDIDATE: line=51 |         # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.

BLOCK-CHECKS: B1=pass B2=pass B3=pass B4=pass B5=pass B6=pass B7=pass

Block-check derivation:

- B1: POSHQC-SHAPE: sharded.
- B2: JOB-IF for poshqc is `always()`.
- B3: exactly one poshqc step name begins `Require` (step 1).
- B4: `Install dependencies` (step 5) and `Upload coverage to Codecov` (step 15) in _quality-checks.yml, `Build kcov from source` (step 4) in _shell-coverage.yml are present.
- B5: the nine ci.yml caller jobs are present (plus the changes and full-run-marker jobs added by G7).
- B6: A4 and A4C counts are 0 with exactly one candidate each, and each candidate text is the section 7 replacement text (A4 already applied; Fix 2).
- B7: A2 (line 232) and A2B (line 236) are both present exactly once, so A2-APPLICABLE: yes.

## Recipe output (JOB, STEP, and summary lines)

```
RUN-CR: cr-inventory
JOBS-LINE: .github/workflows/ci.yml | line=12
JOB: .github/workflows/ci.yml | changes | line=13
STEP: .github/workflows/ci.yml | changes | 1 | Check out the pull request head
STEP: .github/workflows/ci.yml | changes | 2 | Decide the change scope
JOB: .github/workflows/ci.yml | full-run-marker | line=46
JOB-NEEDS: .github/workflows/ci.yml | full-run-marker | changes
JOB-IF: .github/workflows/ci.yml | full-run-marker | ${{ !cancelled() && needs.changes.outputs.code != 'false' }}
STEP: .github/workflows/ci.yml | full-run-marker | 1 | Record that the heavy jobs run in full
JOB: .github/workflows/ci.yml | quality-checks7 | line=55
JOB-NEEDS: .github/workflows/ci.yml | quality-checks7 | changes
JOB-IF: .github/workflows/ci.yml | quality-checks7 | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | security-scan | line=62
JOB-NEEDS: .github/workflows/ci.yml | security-scan | changes
JOB-IF: .github/workflows/ci.yml | security-scan | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | docs-validation | line=69
JOB: .github/workflows/ci.yml | build-check | line=72
JOB-NEEDS: .github/workflows/ci.yml | build-check | changes
JOB-IF: .github/workflows/ci.yml | build-check | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | poshqc | line=79
JOB-NEEDS: .github/workflows/ci.yml | poshqc | changes
JOB-IF: .github/workflows/ci.yml | poshqc | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | shell-coverage | line=86
JOB-NEEDS: .github/workflows/ci.yml | shell-coverage | changes
JOB-IF: .github/workflows/ci.yml | shell-coverage | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | drm-copilot-extension-tests | line=93
JOB-NEEDS: .github/workflows/ci.yml | drm-copilot-extension-tests | changes
JOB-IF: .github/workflows/ci.yml | drm-copilot-extension-tests | ${{ !cancelled() }}
JOB: .github/workflows/ci.yml | root-typescript-tests | line=100
JOB-NEEDS: .github/workflows/ci.yml | root-typescript-tests | changes
JOB-IF: .github/workflows/ci.yml | root-typescript-tests | ${{ !cancelled() && needs.changes.outputs.code != 'false' }}
JOB: .github/workflows/ci.yml | npm-audit-gate | line=105
JOB-NEEDS: .github/workflows/ci.yml | npm-audit-gate | changes
JOB-IF: .github/workflows/ci.yml | npm-audit-gate | ${{ !cancelled() && needs.changes.outputs.code != 'false' }}
JOBS-LINE: .github/workflows/_quality-checks.yml | line=19
JOB: .github/workflows/_quality-checks.yml | quality-checks7 | line=20
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 1 | Check out repository
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 2 | Set up Python ${{ matrix.python-version }}
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 3 | Install Poetry
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 4 | Load cached venv
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 4 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 5 | Install dependencies
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 5 | ${{ inputs.run-heavy && steps.cached-poetry-dependencies.outputs.cache-hit != 'true' }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 6 | Install project
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 6 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 7 | Verify poetry.lock is in sync
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 7 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 8 | Check formatting with Black
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 8 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 9 | Lint with Ruff
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 9 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 10 | Type check with Pyright
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 10 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 11 | Verify Codex agent deployment profiles
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 11 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 12 | tier-classification
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 12 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 13 | Run tests with Pytest
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 13 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 14 | Enforce Python coverage thresholds
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 14 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_quality-checks.yml | quality-checks7 | 15 | Upload coverage to Codecov
STEP-IF: .github/workflows/_quality-checks.yml | quality-checks7 | 15 | ${{ inputs.run-heavy && matrix.python-version == '3.13' }}
JOBS-LINE: .github/workflows/_security-scan.yml | line=19
JOB: .github/workflows/_security-scan.yml | security-scan | line=20
STEP: .github/workflows/_security-scan.yml | security-scan | 1 | Check out repository
STEP-IF: .github/workflows/_security-scan.yml | security-scan | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_security-scan.yml | security-scan | 2 | Set up Python
STEP-IF: .github/workflows/_security-scan.yml | security-scan | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_security-scan.yml | security-scan | 3 | Install Poetry
STEP-IF: .github/workflows/_security-scan.yml | security-scan | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_security-scan.yml | security-scan | 4 | Install the Poetry export plugin
STEP-IF: .github/workflows/_security-scan.yml | security-scan | 4 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_security-scan.yml | security-scan | 5 | Check for security vulnerabilities
STEP-IF: .github/workflows/_security-scan.yml | security-scan | 5 | ${{ inputs.run-heavy }}
JOBS-LINE: .github/workflows/_build-check.yml | line=19
JOB: .github/workflows/_build-check.yml | build-check | line=20
STEP: .github/workflows/_build-check.yml | build-check | 1 | Check out repository
STEP-IF: .github/workflows/_build-check.yml | build-check | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_build-check.yml | build-check | 2 | Set up Python
STEP-IF: .github/workflows/_build-check.yml | build-check | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_build-check.yml | build-check | 3 | Install Poetry
STEP-IF: .github/workflows/_build-check.yml | build-check | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_build-check.yml | build-check | 4 | Build package
STEP-IF: .github/workflows/_build-check.yml | build-check | 4 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_build-check.yml | build-check | 5 | Verify package can be installed
STEP-IF: .github/workflows/_build-check.yml | build-check | 5 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_build-check.yml | build-check | 6 | Shell QC smoke (native)
STEP-IF: .github/workflows/_build-check.yml | build-check | 6 | ${{ inputs.run-heavy }}
JOBS-LINE: .github/workflows/_shell-coverage.yml | line=19
JOB: .github/workflows/_shell-coverage.yml | shell-coverage | line=20
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 1 | Check out repository
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 2 | Install shell tooling (shellcheck, shfmt, bats)
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 3 | Cache kcov build
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 4 | Build kcov from source
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 4 | ${{ inputs.run-heavy && steps.cache-kcov.outputs.cache-hit != 'true' }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 5 | Install kcov from cache
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 5 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 6 | Run shell-qc check (shfmt diff + shellcheck)
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 6 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 7 | Run shell-qc test with coverage
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 7 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_shell-coverage.yml | shell-coverage | 8 | Upload shell coverage artifacts
STEP-IF: .github/workflows/_shell-coverage.yml | shell-coverage | 8 | ${{ inputs.run-heavy }}
JOBS-LINE: .github/workflows/_drm-copilot-extension-tests.yml | line=19
JOB: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | line=20
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 1 | Check out repository
STEP-IF: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 2 | Set up Node.js
STEP-IF: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 3 | Install extension dependencies
STEP-IF: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 4 | Type-check extension source and test tree
STEP-IF: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 4 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 5 | Run extension unit/integration tests
STEP-IF: .github/workflows/_drm-copilot-extension-tests.yml | drm-copilot-extension-tests | 5 | ${{ inputs.run-heavy }}
JOBS-LINE: .github/workflows/_poshqc.yml | line=19
JOB: .github/workflows/_poshqc.yml | poshqc-static | line=20
JOB-IF: .github/workflows/_poshqc.yml | poshqc-static | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc-static | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-static | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-static | 3 | Format PowerShell
STEP: .github/workflows/_poshqc.yml | poshqc-static | 4 | Analyze PowerShell
JOB: .github/workflows/_poshqc.yml | poshqc-shard | line=53
JOB-IF: .github/workflows/_poshqc.yml | poshqc-shard | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 3 | Test PowerShell
STEP: .github/workflows/_poshqc.yml | poshqc-shard | 4 | Upload PowerShell shard test artifacts
STEP-IF: .github/workflows/_poshqc.yml | poshqc-shard | 4 | always()
JOB: .github/workflows/_poshqc.yml | poshqc | line=89
JOB-NEEDS: .github/workflows/_poshqc.yml | poshqc | [poshqc-static, poshqc-shard]
JOB-IF: .github/workflows/_poshqc.yml | poshqc | always()
STEP: .github/workflows/_poshqc.yml | poshqc | 1 | Require the static and shard jobs to succeed
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 1 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 2 | Check out repository
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 2 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 3 | Install PoshQC tooling
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 3 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 4 | Download PowerShell shard test artifacts
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 4 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 5 | Verify shard completeness
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 5 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 6 | Merge PowerShell shard coverage
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 6 | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc | 7 | Upload PowerShell test artifacts
STEP-IF: .github/workflows/_poshqc.yml | poshqc | 7 | ${{ inputs.run-heavy }}
JOB: .github/workflows/_poshqc.yml | poshqc-linux-hooks | line=171
JOB-IF: .github/workflows/_poshqc.yml | poshqc-linux-hooks | ${{ inputs.run-heavy }}
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 1 | Check out repository
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 2 | Install PoshQC tooling
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 3 | Test PowerShell hook suites
STEP: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 4 | Upload PowerShell hook-suite test results
STEP-IF: .github/workflows/_poshqc.yml | poshqc-linux-hooks | 4 | always()
POSHQC-JOB-SET: poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static
POSHQC-SHAPE: sharded
CI-MERGE-GROUP: present
EDIT-TARGET-A2: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=1 | lines=232
EDIT-TARGET-A2B: tests/scripts/workflows/CiWorkflow.Tests.ps1 | count=1 | lines=236
EDIT-TARGET-A4: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4-CANDIDATE: line=85 |             if ($gate -match '(?m)^ {8}if:' -and $gate -notmatch '(?m)^ {8}if:[ \t]*\$\{\{ inputs\.run-heavy \}\}[ \t]*$') {
EDIT-TARGET-A4C: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | count=0 | lines=
EDIT-TARGET-A4C-CANDIDATE: line=51 |         # -or, exits 1, carries no step-level if condition other than the issue #962 run-heavy gate, and precedes the completeness and merge steps.
WORKFLOW-REFERENCING-SUITE: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1
WORKFLOW-REFERENCING-SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
LIST-EXISTING-SUITES: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
EXIT_CODE_COMPUTED: 0
```

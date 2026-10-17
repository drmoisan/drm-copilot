# Final QA pass 2: scope, history, and dependency re-check (P6-T10; AC-22, AC-28, AC-30)

Timestamp: 2026-10-17T00-21
Command: git fetch origin
EXIT_CODE: 0
Output Summary: Dependency re-check after the rule 17 re-integration: origin/main is still b8fcd7790; RECHECK-DEP-952: present and RECHECK-DEP-953: present equal DEP-952 and DEP-953 of dependency-state.2026-10-17T00-09.md, so DEPENDENCY-RECHECK: UNCHANGED. CR-SCOPE (merge commit 32350256b from reintegration.2026-10-17T00-09.md): SCOPE-FORBIDDEN-PRESENT: 0, SCOPE-POLICY-PRESENT: 0, SCOPE-OUTSIDE-WRITE-SET: 0, SCOPE-HISTORY-REWRITES: 0, SCOPE-MERGE-COMMIT-CONTAINED: True, EXIT_CODE_COMPUTED: 0 (with the pre-execution promotion lifecycle record added to the allowed list, plan-trivial-fixes Fix 5; the first CR-SCOPE run of this pass reported SCOPE-OUTSIDE-WRITE-SET: 1 for that record only). CR-ONBLOCK: ONBLOCK-IDENTICAL: True. The unchanged parser, its bundle mirror, and both skill files are absent from the changed list (AC-28).

## Dependency re-check commands and exit codes

- `git fetch origin` EXIT_CODE: 0 (no output)
- `git rev-parse origin/main` EXIT_CODE: 0 -> `b8fcd77905a51284cfbca54226a2da2a7916a836`
- `git rev-parse origin/bug/ci-merge-queue-for-main-952` EXIT_CODE: 0 -> `5c8fff171a45ef042f878170de8765ef49c02db9`
- `git rev-parse origin/bug/pester-profiler-coverage-953` EXIT_CODE: 0 -> `9285674cfc95b01ba1a5c8eca2216e58d61c2b2d`
- `git grep -c -E -e '^  merge_group:[[:space:]]*$' origin/main -- .github/workflows/ci.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/ci.yml:1`
- `git grep -c -E -e '^  poshqc-shard:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^  poshqc-static:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^    name: PowerShell QC[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`

TOKEN-merge_group: present (1)
TOKEN-poshqc-shard: present (1)
TOKEN-poshqc-static: present (1)
TOKEN-PowerShell QC: present (1)
RECHECK-DEP-952: present
RECHECK-DEP-953: present
DEPENDENCY-RECHECK: UNCHANGED

## D6 lines quoted from workflow-suite-adjustment.2026-10-17T00-12.md

D6-ADJUSTMENT: tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py | test_threshold_step_runs_on_every_matrix_leg
D6-ADJUSTMENT: tests/scripts/workflows/CiWorkflow.Tests.ps1 | reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph
D6-ADJUSTMENT: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | $script:GetResultGateViolation (used by rows WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE and WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS)
D6-NOT-APPLICABLE: A3 | withdrawn by PD-15 (the poshqc-shard upload step keeps if: always() inside its job-gated job)

The SCOPE-CHANGED list names tests/scripts/workflows/PoshQcWorkflow.Tests.ps1, which has a D6-ADJUSTMENT line. tests/scripts/workflows/CiWorkflow.Tests.ps1 is not yet committed (it appears only as a porcelain entry) and also has a D6-ADJUSTMENT line.

## CR-SCOPE command (corrected allowed list)

`sh SCRATCH/tools/run-cr.sh cr-scope -AllowedList ".github/workflows/ci.yml,.github/workflows/_quality-checks.yml,.github/workflows/_security-scan.yml,.github/workflows/_build-check.yml,.github/workflows/_shell-coverage.yml,.github/workflows/_drm-copilot-extension-tests.yml,.github/workflows/_poshqc.yml,.github/workflows/README.md,config/ci-docs-only-paths.json,scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1,quality-tiers.yml,tests/scripts/ci/CiChangeScope.Tests.ps1,tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1,tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1,tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py,tests/shell/test_shell_qc_commands.bats,docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md" -MergeCommit "32350256beae992969272327b61dbe92953b4d04"` EXIT_CODE: 0

## CR-SCOPE output (the 48 SCOPE-CHANGED lines under docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/ are omitted; all are inside the feature folder)

```
RUN-CR: cr-scope
SCOPE-EMBEDDED-ALLOWED: scripts/bash/shell_qc_lib.sh,scripts/bash/shell-qc.sh
SCOPE-CHANGED: .github/workflows/README.md
SCOPE-CHANGED: .github/workflows/_build-check.yml
SCOPE-CHANGED: .github/workflows/_drm-copilot-extension-tests.yml
SCOPE-CHANGED: .github/workflows/_poshqc.yml
SCOPE-CHANGED: .github/workflows/_quality-checks.yml
SCOPE-CHANGED: .github/workflows/_security-scan.yml
SCOPE-CHANGED: .github/workflows/_shell-coverage.yml
SCOPE-CHANGED: .github/workflows/ci.yml
SCOPE-CHANGED: config/ci-docs-only-paths.json
SCOPE-CHANGED: docs/features/potential/promoted/2026-10-16-ci-skip-evidence-only-commits.md
SCOPE-CHANGED: quality-tiers.yml
SCOPE-CHANGED: scripts/bash/shell-qc.sh
SCOPE-CHANGED: scripts/bash/shell_qc_lib.sh
SCOPE-CHANGED: scripts/ci/CiChangeScope.psm1
SCOPE-CHANGED: scripts/ci/Invoke-CiChangeScope.ps1
SCOPE-CHANGED: tests/scripts/ci/CiChangeScope.Tests.ps1
SCOPE-CHANGED: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1
SCOPE-CHANGED: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1
SCOPE-CHANGED: tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
SCOPE-CHANGED: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1
SCOPE-CHANGED: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1
SCOPE-CHANGED: tests/shell/test_shell_qc_commands.bats
SCOPE-PORCELAIN:  M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/plan-trivial-fixes.2026-10-16T23-15.md
SCOPE-PORCELAIN:  M docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md
SCOPE-PORCELAIN:  M tests/scripts/workflows/CiWorkflow.Tests.ps1
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/commit-phase-5.2026-10-17T00-00.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/dependency-state.2026-10-17T00-09.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/edit-points.2026-10-17T00-09.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/reintegration.2026-10-17T00-09.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/other/workflow-suite-adjustment.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/qa-gates/
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-actionlint.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-ci-suite-edit.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-existing-suites.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-onblock.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-poshqc-suite-edit.2026-10-17T00-12.md
SCOPE-PORCELAIN: ?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/regression-testing/p4-workflow-suite-pass.2026-10-17T00-12.md
SCOPE-FORBIDDEN-PRESENT: 0
SCOPE-POLICY-PRESENT: 0
SCOPE-OUTSIDE-WRITE-SET: 0
SCOPE-PORCELAIN-ENTRIES: 15
SCOPE-HISTORY-REWRITES: 0
SCOPE-MERGE-COMMIT-CONTAINED: True
EXIT_CODE_COMPUTED: 0
```

## CR-ONBLOCK output (EXIT_CODE: 0)

`sh SCRATCH/tools/run-cr.sh cr-onblock`

```
RUN-CR: cr-onblock
MERGE-BASE: b8fcd77905a51284cfbca54226a2da2a7916a836
ONBLOCK-LINES: base=9 | head=9
ONBLOCK-HAS-MERGE-GROUP: True
ONBLOCK-IDENTICAL: True
EXIT_CODE_COMPUTED: 0
```

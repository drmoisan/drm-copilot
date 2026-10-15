# Git Baseline (P0-T3)

Timestamp: 2026-09-30T13-46
Task: [P0-T3]
Location: worktree root

Branch substitution (orchestrator decision): the plan names `bug/promotion-gate-lacks-preexisting-issue-branch-509`, which is checked out in a locked planning worktree. Per the orchestrator's recorded decision 1 in the execution delegation, execution uses `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509`, and this task accepts that branch name instead of returning `BLOCKED: WRONG BRANCH`. Later evidence that records a branch name records the branch actually used.

## 1. Fetch

Command: git fetch origin epic/orchestrator-state-contract-correctness-integration
EXIT_CODE: 0
Output Summary: `* branch epic/orchestrator-state-contract-correctness-integration -> FETCH_HEAD`. The remote-tracking ref `origin/epic/orchestrator-state-contract-correctness-integration` resolves to `fa934a792255a780b5835fa79659d7d8b993a055` (tip commit `fa934a79 docs(771): record wave-0 merges and #509 launch in epic-status`, one documentation commit beyond `815a962f`).

## 2. Branch

Command: git rev-parse --abbrev-ref HEAD
EXIT_CODE: 0
Output Summary: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (accepted under the orchestrator branch substitution above).

## 3. HEAD

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: `127635e94f51e855c7b82f21c87d575bf5acfdad` (40 characters).

## 4. Merge base

Command: git merge-base HEAD origin/epic/orchestrator-state-contract-correctness-integration
EXIT_CODE: 0
Output Summary: `815a962f0575ad10919c8014185e444727991eb5` (40 characters). This is the integration tip that the orchestrator merged into this branch (orchestrator decision 2). The integration branch has since advanced by one commit (`fa934a79`, documentation only), which is not in HEAD.

## 5. Porcelain status

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/
```

Both entries are this execution's own Phase 0 writes (P0-T1 and P0-T2 check-offs in the plan, and the two evidence artifacts written by those tasks). The tree was clean at the start of execution (`git status --short --branch` printed only the branch line).

## 6. Three-dot name listing (pre-existing committed set allowed by P8-T19)

Command: git diff --name-only origin/epic/orchestrator-state-contract-correctness-integration...HEAD
EXIT_CODE: 0
Output Summary: 72 paths. They arrive through commits on the branch beyond the merge base (`git log --oneline 815a962f..HEAD` lists the #512 branch history merged from `main` via PR #799, commit `021b37e6`, and the integration merge `127635e9`). Listing verbatim:

```
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/code-review.2026-09-30T12-05.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/feature-audit.2026-09-30T12-05.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/policy-audit.2026-09-30T12-05.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/remediation-inputs.2026-09-30T12-05.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/remediation-plan.2026-09-30T12-05.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-45-audit/code-review.2026-09-30T12-45.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-45-audit/feature-audit.2026-09-30T12-45.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-45-audit/policy-audit.2026-09-30T12-45.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/black-check-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/branch-commit-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/file-line-count-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/pyright-file-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/pytest-collect-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/pytest-coverage-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/pytest-pass-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/ruff-file-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/baseline/ruff-repo-baseline.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/coverage-comparison.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-black.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-black.2026-09-30T12-04.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-coverage-comparison.2026-09-30T12-06.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-full-suite-coverage.2026-09-30T12-06.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-lcov-sums.2026-09-30T12-06.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-pyright.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-pyright.2026-09-30T12-04.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-pytest-coverage.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-pytest-target-pass.2026-09-30T12-04.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-qc-loop-pass.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-qc-loop-pass.2026-09-30T12-06.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-ruff-file.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-ruff-file.2026-09-30T12-04.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/final-ruff-repo.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/followups-recorded.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/header-new-status-presence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/header-old-values-absence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/independent-reverification.2026-09-30T11-55.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/r1-disposition.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/r2-new-figure-presence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/r2-old-figure-absence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/repo-wide-coverage-record.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/scope-check.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/scope-check.2026-09-30T12-06.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/spec-17-tests-absence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/qa-gates/spec-20-tests-presence.2026-09-30T12-03.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/black-check-after-rename.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/fail-before-delta-check.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/file-line-count-after.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/new-name-single-definition.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/noqa-absence.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/old-name-absence.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/pytest-collect-after.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/rename-delta-check.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/renamed-test-node-pass.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/ruff-e501-fail-before.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/regression-testing/ruff-e501-pass-after.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/black-check-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/commit-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/lcov-sums-baseline.2026-09-30T12-02.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/phase0-instructions-read.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/pyright-file-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/pytest-full-suite-coverage-baseline.2026-09-30T12-02.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/pytest-target-pass-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/ruff-file-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/status-baseline.2026-09-30T11-59.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/issue.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/plan.2026-09-29T15-16.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/research/2026-09-29T19-20-noqa-e501-rename.research.md
docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/spec.md
tests/scripts/dev_tools/test_blast_radius_config_parity.py
```

Result: branch accepted under the orchestrator substitution; both SHAs are 40-character values; three-dot listing and porcelain listing recorded verbatim.

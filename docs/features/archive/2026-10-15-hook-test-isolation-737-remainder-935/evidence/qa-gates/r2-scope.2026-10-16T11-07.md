# R2 Scope (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T11-07
Task: [P4-T7]
Command: git diff --name-only b8d8a16b009a97353d41f7b8d060598c5cc26540..HEAD; git diff --name-only origin/main...HEAD; git status --porcelain
EXIT_CODE: 0

Output Summary:
- Cycle diff: only tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 and FEATURE paths (CallTarget file absent: COV-1 status blocked).
- Branch diff: the 18 spec Write-Set code paths and FEATURE paths only; no .claude/, .codex/, .github/, extensions/, scripts/ or config/ path; no AC-6 suite, validate- suite, hook-dependency-failure suite, preimplementation-gate-modes suite or epic-scope suite.
- Porcelain: only FEATURE paths (this phase's uncommitted evidence and the plan).
- Acceptance: PASS.

## git diff --name-only b8d8a16b009a97353d41f7b8d060598c5cc26540..HEAD

```
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-branch-state.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-comparison-tree.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-coverage-baseline.2026-10-16T08-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-phase0-instructions-read.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-analyze.2026-10-16T09-00.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-format.2026-10-16T08-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-test.2026-10-16T09-12.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-token-counts.2026-10-16T08-58.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-base.2026-10-16T10-05.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-head.2026-10-16T09-49.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-investigation.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u1.2026-10-16T10-36.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u2.2026-10-16T10-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u3.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u5.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-lib-only.2026-10-16T09-33.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-reproduction.2026-10-16T10-05.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-cov-status.2026-10-16T10-52.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-p1-ps-test.2026-10-16T09-31.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/r2-cr-r1-fail-before.2026-10-16T09-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T07-55.md
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
```

## git diff --name-only origin/main...HEAD

```
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T03-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T07-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/branch-state.2026-10-16T00-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ci-baseline-source.2026-10-16T00-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ci-baseline.2026-10-16T00-11.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/line-counts.2026-10-16T00-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/phase0-instructions-read.2026-10-16T00-25.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-analyze.2026-10-16T00-31.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-format.2026-10-16T00-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/ps-test.2026-10-16T00-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-branch-state.2026-10-16T04-37.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-coverage-baseline.2026-10-16T04-40.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-coverage-population.2026-10-16T04-39.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-line-counts.2026-10-16T04-38.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-phase0-instructions-read.2026-10-16T04-37.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-ps-analyze.2026-10-16T04-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-ps-format.2026-10-16T04-40.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-ps-test.2026-10-16T05-11.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r1-token-counts.2026-10-16T04-38.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-branch-state.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-comparison-tree.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-coverage-baseline.2026-10-16T08-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-phase0-instructions-read.2026-10-16T08-57.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-analyze.2026-10-16T09-00.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-format.2026-10-16T08-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-ps-test.2026-10-16T09-12.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/r2-token-counts.2026-10-16T08-58.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/split-anchors.2026-10-16T00-28.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/withheld-source.2026-10-16T00-29.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r1-dispositions.2026-10-16T05-13.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-base.2026-10-16T10-05.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-head.2026-10-16T09-49.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-investigation.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u1.2026-10-16T10-36.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u2.2026-10-16T10-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u3.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u4.2026-10-16T10-50.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-iso-u5.2026-10-16T10-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-lib-only.2026-10-16T09-33.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/r2-cov-reproduction.2026-10-16T10-05.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ac-status.2026-10-16T03-11.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/coverage-comparison.2026-10-16T06-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/decisions-present.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/determinism-search.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/fixture-names.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/i3-consumers-unchanged.2026-10-16T01-01.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/line-counts.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/loop-status.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p1-ps-test.2026-10-16T01-51.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p2-reapply-state.2026-10-16T01-53.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p3-split.2026-10-16T01-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p4-fixture-names.2026-10-16T01-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p4-ps-test.2026-10-16T02-18.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/p5-ps-test.2026-10-16T02-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-analyze.2026-10-16T02-48.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-format.2026-10-16T02-45.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-format.2026-10-16T02-46.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/ps-test.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-coverage-pre.2026-10-16T06-28.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-coverage-run.2026-10-16T06-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-determinism-search.2026-10-16T06-28.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-findings-status.2026-10-16T06-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-fixture-names.2026-10-16T05-47.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-line-counts.2026-10-16T06-27.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-loop-status.2026-10-16T06-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-p1-ps-test.2026-10-16T05-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-p2-ps-test.2026-10-16T05-46.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-p3-ps-test.2026-10-16T06-09.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-ps-analyze.2026-10-16T06-11.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-ps-format.2026-10-16T06-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-ps-test.2026-10-16T06-26.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r1-scope.2026-10-16T06-27.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-cov-status.2026-10-16T10-52.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-p1-ps-test.2026-10-16T09-31.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/scope.2026-10-16T03-10.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/f1-f2-reapply.2026-10-16T01-53.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-ac6.2026-10-16T01-54.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-exception.f3.2026-10-16T02-21.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/fail-before-exception.r1-r2.2026-10-16T01-59.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/r1-cr-n3-fail-before.2026-10-16T05-56.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/r2-cr-r1-fail-before.2026-10-16T09-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T03-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T07-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T03-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T07-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T03-20.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T07-30.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-inputs.2026-10-16T07-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T03-40.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T07-55.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/research/research.2026-10-15T22-03.md
docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md
tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1
tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1
tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1
tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1
tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

## git status --porcelain (before writing this file)

```
 M docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T07-55.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-coverage-delta.2026-10-16T11-06.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-line-counts.2026-10-16T11-06.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-loop-status.2026-10-16T11-05.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-ps-analyze.2026-10-16T10-53.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-ps-format.2026-10-16T10-53.md
?? docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/r2-ps-test.2026-10-16T11-05.md
```

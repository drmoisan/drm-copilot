# Change Scope, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-58
Task: P4-T9 (remediation-plan.2026-10-16T08-40.md)
Command: git diff --name-only origin/main...HEAD; git status --porcelain (HEAD d9ce4757ea3f7fa83b6c5a4694e2826f33ec2bfc)
EXIT_CODE: 0
Output Summary: Every listed path is one of the four targets copies, the new PathNotLocal suite, the two gate suites, or lies under docs/features/active/exempt-operand-unc-path-leg-937/. The source suite enforce-orchestration-preimplementation-gate-targets.Tests.ps1 is not listed. Porcelain lists only FEATURE paths (uncommitted P4 evidence and plan check-offs). No excluded path appears in either output (AC-13).

## git diff --name-only origin/main...HEAD

```text
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
docs/features/active/exempt-operand-unc-path-leg-937/code-review.2026-10-16T03-39.md
docs/features/active/exempt-operand-unc-path-leg-937/code-review.2026-10-16T08-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/ci-baseline-run.2026-10-16T01-32.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/coverage-baseline.2026-10-16T01-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/git-baseline.2026-10-16T00-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/inputs-read.2026-10-16T00-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/phase0-instructions-read.2026-10-16T00-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/poshqc-analyze-baseline.2026-10-16T00-35.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/poshqc-format-baseline.2026-10-16T00-59.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/poshqc-test-baseline.2026-10-16T00-58.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/python-contract-baseline.2026-10-16T00-58.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/baseline/targets-hash-baseline.2026-10-16T00-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/ac-evidence-map-c1.2026-10-16T08-26.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/ac-evidence-map.2026-10-16T03-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/pathleg-rows-after-edit-c1.2026-10-16T06-17.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/pathleg-rows-after-edit-c2.2026-10-16T10-49.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/pathleg-rows-after-move-c2.2026-10-16T10-36.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/plan-deviation-accepted.2026-10-16T08-26.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-additions-only.2026-10-16T02-24.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-diff-shape-c1.2026-10-16T07-06.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-diff-shape-c2.2026-10-16T11-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity-c1.2026-10-16T07-06.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity-c2.2026-10-16T11-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity.2026-10-16T02-24.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check-c1.2026-10-16T07-06.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check-c2.2026-10-16T11-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check.2026-10-16T02-24.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-edit-shape-c1.2026-10-16T06-16.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-edit-shape-c2.2026-10-16T10-49.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-edit-shape.2026-10-16T01-36.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/test-move-shape-c2.2026-10-16T10-35.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/ci-pass-after-c1.2026-10-16T08-22.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/ci-pass-after.2026-10-16T03-29.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-canonical.2026-10-16T08-24.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-delta-c1.2026-10-16T08-25.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-delta.2026-10-16T03-32.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-final-c1.2026-10-16T08-23.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-final.2026-10-16T03-32.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/invariants-diff-c1.2026-10-16T07-51.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/invariants-diff.2026-10-16T03-06.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-final-c1.2026-10-16T07-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-final.2026-10-16T02-48.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-hooks-c1.2026-10-16T07-09.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-hooks-c2.2026-10-16T11-31.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-hooks.2026-10-16T02-26.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-tests-c1.2026-10-16T06-19.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-tests-c2.2026-10-16T10-51.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-tests-move-c2.2026-10-16T10-37.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-tests.2026-10-16T01-38.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-final-c1.2026-10-16T07-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-final.2026-10-16T02-46.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-hooks-c1.2026-10-16T07-09.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-hooks-c2.2026-10-16T11-31.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-hooks.2026-10-16T02-25.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-tests-c1.2026-10-16T06-18.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-tests-c2.2026-10-16T10-50.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-tests-move-c2.2026-10-16T10-36.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-tests.2026-10-16T01-37.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-test-final-c1.2026-10-16T07-49.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-test-final.2026-10-16T03-05.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-after-fix-c1.2026-10-16T07-28.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-after-fix-c2.2026-10-16T11-41.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-after-fix.2026-10-16T02-44.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-final-c1.2026-10-16T07-49.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-final.2026-10-16T03-05.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/qa-loop-pass-c1.2026-10-16T07-49.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/qa-loop-pass.2026-10-16T03-05.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/scope-diff-c1.2026-10-16T07-51.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/scope-diff.2026-10-16T03-07.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/targets-eol-parity-c1.2026-10-16T07-51.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/targets-eol-parity.2026-10-16T03-05.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-fail-before-c1.2026-10-16T06-32.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-fail-before-c2.2026-10-16T11-00.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-fail-before.2026-10-16T01-56.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-move-c2.2026-10-16T10-46.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-pass-after-c1.2026-10-16T07-28.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-pass-after-c2.2026-10-16T11-40.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/poshqc-test-pass-after.2026-10-16T02-44.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/ps-fail-before-c1.2026-10-16T07-02.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/ps-fail-before-c2.2026-10-16T11-27.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/regression-testing/ps-fail-before.2026-10-16T02-20.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/ci-baseline-run-c2.2026-10-16T10-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/ci-baseline-run.2026-10-16T06-12.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-ci-baseline-c2.2026-10-16T10-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-ci-baseline.2026-10-16T06-12.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-local-baseline-c2.2026-10-16T10-04.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-local-baseline.2026-10-16T05-52.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/coverage-local-baseline.2026-10-16T06-11.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/git-baseline-c2.2026-10-16T09-47.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/git-baseline.2026-10-16T05-31.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/inputs-read-c2.2026-10-16T09-44.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/inputs-read.2026-10-16T05-27.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/pathleg-rows-baseline-c2.2026-10-16T09-46.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/pathleg-rows-baseline.2026-10-16T05-30.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/phase0-instructions-read-c2.2026-10-16T09-43.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T05-27.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-analyze-baseline-c2.2026-10-16T09-48.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-analyze-baseline.2026-10-16T05-33.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-format-baseline-c2.2026-10-16T10-05.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-format-baseline.2026-10-16T05-53.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-test-baseline-c2.2026-10-16T10-04.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/poshqc-test-baseline.2026-10-16T05-51.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/python-contract-baseline-c2.2026-10-16T10-04.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/python-contract-baseline.2026-10-16T05-53.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/scratch-helpers-c2.2026-10-16T09-44.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/scratch-helpers-new-c2.2026-10-16T09-45.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/scratch-helpers.2026-10-16T05-28.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/targets-hash-baseline-c2.2026-10-16T09-47.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/targets-hash-baseline.2026-10-16T05-31.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/test-files-baseline-c2.2026-10-16T09-48.md
docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/test-long-lines-baseline.2026-10-16T05-32.md
docs/features/active/exempt-operand-unc-path-leg-937/feature-audit.2026-10-16T03-39.md
docs/features/active/exempt-operand-unc-path-leg-937/feature-audit.2026-10-16T08-30.md
docs/features/active/exempt-operand-unc-path-leg-937/issue.md
docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
docs/features/active/exempt-operand-unc-path-leg-937/policy-audit.2026-10-16T03-39.md
docs/features/active/exempt-operand-unc-path-leg-937/policy-audit.2026-10-16T08-30.md
docs/features/active/exempt-operand-unc-path-leg-937/remediation-inputs.2026-10-16T03-39.md
docs/features/active/exempt-operand-unc-path-leg-937/remediation-inputs.2026-10-16T08-40.md
docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T03-39.md
docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
docs/features/active/exempt-operand-unc-path-leg-937/research/research.2026-10-15T17-46.md
docs/features/active/exempt-operand-unc-path-leg-937/spec.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## Non-FEATURE paths in the name list

```text
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```

## git status --porcelain

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T08-40.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-canonical-c2.2026-10-16T11-57.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/invariants-diff-c2.2026-10-16T11-58.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-analyze-final-c2.2026-10-16T11-56.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-format-final-c2.2026-10-16T11-56.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/poshqc-test-final-c2.2026-10-16T11-56.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/python-contract-final-c2.2026-10-16T11-56.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/qa-loop-pass-c2.2026-10-16T11-56.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/scope-diff-c2.2026-10-16T11-58.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/targets-eol-parity-c2.2026-10-16T11-58.md
```

## Acceptance

- Every listed path is an allowed path: met (seven non-FEATURE paths: four targets copies, the new suite, two gate suites).
- Source suite not listed: met.
- Porcelain lists nothing other than allowed paths: met.
- None of the excluded paths (epic-scope hook copies, WorktreeRunResolution.psm1, WorktreeTargetResolution.psm1, parser files, pack-manifests/core.json, the Discovery, AcceptanceCases, and Issue824 suites, config/poshqc-coverage.json, scripts/powershell/PoshQC/settings/, .claude/rules/, .github/instructions/) appears: met.

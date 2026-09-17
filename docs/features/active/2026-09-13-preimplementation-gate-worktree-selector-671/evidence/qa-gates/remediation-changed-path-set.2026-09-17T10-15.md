# Remediation Changed-Path Set (issue #671, R1)

Timestamp: 2026-09-17T10-00
Task: [P5-T4]
Command: `git diff --name-status 79fd5a95c00cd99238b69a3195788206ae96f4cd` and `git status --porcelain`
EXIT_CODE: 0

## `git diff --name-status 79fd5a95c00cd99238b69a3195788206ae96f4cd` (verbatim)

```
M	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/code-review.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/hook-surface-hashes-and-line-counts.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/phase0-instructions-read.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-analyze.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-format.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/poshqc-test-coverage.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/baseline/python-pushdown-contracts.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/issue-updates/issue-671.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/batch-budget-reset.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/follow-up-candidates.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/git-attached-selector-probe.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/helpers-surface-parity.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/requirements-sources-read.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/acceptance-criteria-reconciliation.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/accepted-widening-record.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/changed-path-set.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-additive-only-test-suites.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-gate-files.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-helpers.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-modes-files.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/diff-confinement-shared-parser.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/helpers-purity.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/must-not-regress-rollup.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-analyze.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-format.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/python-pushdown-contracts.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/canonical-copy-check.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/codex-exemption-suite.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/exemption-regression-guards.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/helpers-parity-suite.2026-09-14T00-20.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/feature-audit.2026-09-17T08-40.md
M	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/policy-audit.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-inputs.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
M	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
A	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
M	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
M	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

## `git status --porcelain` (verbatim)

The capture is identical to the one recorded in `remediation-diff-confinement-protected.2026-09-17T10-15.md` (taken in the same step, with no file change in between):

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
 M tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-batch-budget-reset.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-helpers-surface-parity.2026-09-17T09-30.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-inputs-read.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/spec-amendment-r1.2026-09-17T09-10.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-canonical-copy-check.2026-09-17T09-30.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-exemption-suites.2026-09-17T10-00.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-fail-before-probe.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-pass-after-probe.2026-09-17T09-30.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-regression-guards.2026-09-17T10-00.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-suite-edits.2026-09-17T09-45.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/remediation-baseline/
```

## Union of `.ps1` paths from both captures

Outside `tests/` (4):
1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

Under `tests/` (3):
1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`
2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
3. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`

Paths ending in `.py`: none in either capture.

Output Summary: exactly four `.ps1` paths outside `tests/`, all named `enforce-orchestration-preimplementation-gate-helpers.ps1`; exactly three `.ps1` paths under `tests/` (the two command-exemption suites and the parity suite); no `.py` path. PASS.

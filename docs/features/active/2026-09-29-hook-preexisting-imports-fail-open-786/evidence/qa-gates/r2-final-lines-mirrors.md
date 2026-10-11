# Remediation Cycle 2 Final Line Counts and Mirrors ([P3-T7])

Timestamp: 2026-10-10T21-24
Pass: 1
Command: sh <SCRATCHPAD>/r.sh r2-p3t7list (PowerShell paths listed by git diff --name-only f72a63752fc43c8d78fe3d952bd68c68a2b62547 together with git status --porcelain); sh <SCRATCHPAD>/r.sh r2-lines -LinesList <SCRATCHPAD>/r2-p3t7-lines.list -MirrorList <SCRATCHPAD>/r2-wchangedprod.txt (R-LINES for those paths plus .codex/hooks/enforce-orchestration-preimplementation-gate.ps1; R-MIRROR for the 57 W-CHANGED-PROD files)
EXIT_CODE: 0
Output Summary: the listed PowerShell paths are exactly the six section 3 files (128, 94, 181, 213, 113, 199 lines, all at most 500); the Codex preimplementation gate reads exactly 500; 57 MIRROR lines, all equal.

## Changed-path listing

```text
DIFF:
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-ac24-baseline.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-baseline-green.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-ci-linux-junit.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-execution-route.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-inputs-read.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-lines-and-mirrors.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-pester-coverage.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-phase0-instructions-read.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-poshqc-analyze.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-poshqc-format.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-pre-state.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-pytest-guards.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-scoped-baseline.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/r2-ci-diagnosis.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-cmr.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-csr.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-eri.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-ewb.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-frc.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-fix-e-hdf.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-isolation.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-postfix-local.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/regression-testing/r2-drive-simulation.md
  docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/remediation-plan.2026-10-10T19-25.md
  tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
  tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
  tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
  tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
  tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
  tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
PORCELAIN:
   M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/commits.md
   M docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/remediation-plan.2026-10-10T19-25.md
  ?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-poshqc-analyze.md
  ?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-poshqc-format.md
  ?? docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pytest-guards.md
PS-PATHS-COUNT: 6
PS-PATH: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
PS-PATH: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
PS-PATH: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
PS-PATH: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
PS-PATH: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
PS-PATH: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
```

## Line counts and mirrors

```text
LINES: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | 128
LINES: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | 94
LINES: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | 181
LINES: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | 213
LINES: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | 113
LINES: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | 199
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 500
MIRROR: .claude/hooks/check-powershell-test-purity.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-powershell-test-purity.ps1 | equal
MIRROR: .claude/hooks/check-python-test-purity.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/check-python-test-purity.ps1 | equal
MIRROR: .claude/hooks/enforce-checkpoint-monotonic.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-checkpoint-monotonic.ps1 | equal
MIRROR: .claude/hooks/enforce-completion-consistency.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1 | equal
MIRROR: .claude/hooks/enforce-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-discovery-artifact-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-invocation-origin.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-invocation-origin.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-merge-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-wave-barrier.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | equal
MIRROR: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-evidence-locations.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1 | equal
MIRROR: .claude/hooks/enforce-feature-folder-order.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1 | equal
MIRROR: .claude/hooks/enforce-mermaid-validation.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-mermaid-validation.ps1 | equal
MIRROR: .claude/hooks/enforce-model-routing-receipt.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1 | equal
MIRROR: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | equal
MIRROR: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-parallel-abandon-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1 | equal
MIRROR: .claude/hooks/enforce-parallel-drift-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | equal
MIRROR: .claude/hooks/enforce-powershell-batch-budget.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 | equal
MIRROR: .claude/hooks/enforce-pr-author-skill.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 | equal
MIRROR: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | equal
MIRROR: .claude/hooks/enforce-prd-feature-before-planner.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1 | equal
MIRROR: .claude/hooks/enforce-promotion-mcp-only.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1 | equal
MIRROR: .claude/hooks/enforce-python-batch-budget.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 | equal
MIRROR: .claude/hooks/hook-dependency-guard.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1 | equal
MIRROR: .claude/hooks/validate-bash.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 | equal
MIRROR: .claude/hooks/validate-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | equal
MIRROR: .claude/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | equal
MIRROR: .claude/hooks/validate-orchestrator-output-resolution.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-resolution.ps1 | equal
MIRROR: .claude/hooks/validate-orchestrator-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | equal
MIRROR: .claude/hooks/validate-planner-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | equal
MIRROR: .claude/hooks/validate-pr-author-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | equal
MIRROR: .claude/hooks/validate-prd-feature-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | equal
MIRROR: .codex/hooks/check-powershell-test-purity.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-powershell-test-purity.ps1 | equal
MIRROR: .codex/hooks/check-python-test-purity.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/check-python-test-purity.ps1 | equal
MIRROR: .codex/hooks/codex-epic-child-launch-attestation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/codex-epic-child-launch-attestation.ps1 | equal
MIRROR: .codex/hooks/enforce-checkpoint-monotonic.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-checkpoint-monotonic.ps1 | equal
MIRROR: .codex/hooks/enforce-codex-model-routing.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-codex-model-routing.ps1 | equal
MIRROR: .codex/hooks/enforce-completion-consistency.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-merge-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-planning-only.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-root-invocation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-root-invocation.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-wave-barrier.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-wave-barrier.ps1 | equal
MIRROR: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1 | equal
MIRROR: .codex/hooks/enforce-evidence-locations.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1 | equal
MIRROR: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | equal
MIRROR: .codex/hooks/enforce-powershell-batch-budget.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1 | equal
MIRROR: .codex/hooks/enforce-promotion-mcp-only.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1 | equal
MIRROR: .codex/hooks/enforce-python-batch-budget.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1 | equal
MIRROR: .codex/hooks/hook-dependency-guard.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1 | equal
MIRROR: .codex/hooks/validate-bash.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 | equal
MIRROR: .codex/hooks/validate-codex-subagent-routing.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-codex-subagent-routing.ps1 | equal
MIRROR: .codex/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | equal
MIRROR-COUNT: 57
MIRROR-UNEQUAL: 0
```

# Remediation Diff Confinement — Protected Files (issue #671, R1)

Timestamp: 2026-09-17T10-00
Task: [P5-T1]
Command: `git diff --stat 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1`; then `git status --porcelain`
EXIT_CODE: 0

## `git diff --stat` output (verbatim)

```
```

(empty)

## `git status --porcelain` output (verbatim)

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

Output Summary: the `git diff --stat` output is empty, and none of the thirteen protected paths (four gate files, four modes files, four `hook-command-invocation.ps1` copies, `.claude/hooks/enforce-epic-merge-gate.ps1`) appears in the porcelain capture. The protected files' hashes also still equal the [P0-T4] values. PASS.

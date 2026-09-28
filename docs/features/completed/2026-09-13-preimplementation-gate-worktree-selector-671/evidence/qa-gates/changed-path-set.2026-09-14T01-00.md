# Changed-Path Set (issue #671)

Timestamp: 2026-09-17T08-20
Task: [P5-T6]
Command: git -C <worktree root> status --porcelain ; git -C <worktree root> diff --merge-base main --name-only
EXIT_CODE: 0

Output Summary:
- Exclusion set, read from `evidence/baseline/poshqc-format.2026-09-13T22-40.md` under `Formatter-rewritten paths:`: `none`. No path is excluded.
- Production `.ps1` paths in the union: exactly 4, all ending in `enforce-orchestration-preimplementation-gate-helpers.ps1`: `.claude/hooks/...`, `.codex/hooks/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...`. Both canonical and both bundled copies are present.
- Test `.ps1` paths in the union: the two modified command-exemption suites (tracked) and the new parity suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, which the porcelain capture reports as untracked (`??`).
- Paths ending in `.py`: none.
- The remaining name-only entries are Markdown documents under `docs/features/` (the epic manifest, kickoff, promoted records, and sibling feature folders). They are present because this branch is based on `epic/worktree-scoped-state-resolution-integration`, whose documentation commits are not yet on `main`. They are not production code.

## Porcelain capture

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
 M tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/
?? tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
```

## Name-only capture

```
.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/issue.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/plan.2026-09-13T20-49.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/research/2026-09-13T21-30-collect-pr-context-explicit-target-research.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/issue.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/research/2026-09-13T21-10-epic-merge-gate-authorization-record-research.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/issue.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/2026-09-13T22-10-false-approval-elimination-research.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-1-delta.2026-09-13T21-50.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-2-delta.2026-09-13T22-40.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-3-delta.2026-09-13T22-37.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-4-delta.2026-09-13T23-05.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/issue.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/research/2026-09-13T21-05-prd-feature-gate-target-resolution-research.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/issue.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/issue.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/research/2026-09-13T21-15-target-worktree-resolution-module-research.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/user-story.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/issue.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/plan.2026-09-13T20-48.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/research/2026-09-13T22-15-taskmaster-push-down-and-resume-research.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/confirm-taskmaster-run-resume.runbook.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/reload-vscode-window-for-mcp-payload.runbook.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/spec.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/user-story.md
docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md
docs/features/epics/worktree-scoped-state-resolution/epic.md
docs/features/potential/promoted/2026-09-13-collect-pr-context-explicit-target.md
docs/features/potential/promoted/2026-09-13-epic-merge-gate-authorization-record.md
docs/features/potential/promoted/2026-09-13-false-approval-elimination-pr-author-model-routing.md
docs/features/potential/promoted/2026-09-13-prd-feature-gate-target-resolution.md
docs/features/potential/promoted/2026-09-13-preimplementation-gate-worktree-selector.md
docs/features/potential/promoted/2026-09-13-target-worktree-resolution-module.md
docs/features/potential/promoted/2026-09-13-taskmaster-push-down-and-resume.md
docs/features/potential/promoted/2026-09-17-worktree-scoped-state-resolution.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

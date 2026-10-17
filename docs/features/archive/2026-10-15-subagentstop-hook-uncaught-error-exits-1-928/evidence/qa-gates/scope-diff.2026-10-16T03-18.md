# Scope Diff (issue #928, P6-T14, loop pass 1)

Timestamp: 2026-10-16T03-18
Command: git diff --name-only MERGE_BASE
EXIT_CODE: 0

Second command: git status --porcelain (exit 0)

MERGE_BASE: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99

Output Summary: every listed path is under FEATURE/ or in the spec's `## Files In Scope` list, and all 31 spec paths are listed. Mechanical check: the 31 non-FEATURE paths of `git diff --name-only MERGE_BASE` were sorted and compared with `comm` against the 31 sorted spec paths; both one-sided outputs were empty. The porcelain output lists only FEATURE/ paths and three in-scope test files.

## git diff --name-only MERGE_BASE (non-FEATURE paths, 31)

```text
.agents/skills/translate-claude-to-codex/SKILL.md
.claude/agents/epic-orchestrator.md
.claude/hooks/enforce-epic-wave-barrier.ps1
.claude/hooks/subagentstop-envelope.ps1
.claude/hooks/validate-discovery-artifact-gate.ps1
.claude/hooks/validate-executor-output.ps1
.claude/hooks/validate-orchestrator-output.ps1
.claude/hooks/validate-planner-output.ps1
.claude/hooks/validate-pr-author-output.ps1
.claude/hooks/validate-prd-feature-output.ps1
.claude/hooks/validate-required-artifact-output.ps1
.claude/hooks/validate-task-researcher-output.ps1
.claude/skills/epic-orchestrate/SKILL.md
docs/engineering/claude-code-architecture.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md
tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1
```

FEATURE/ paths in the diff: evidence/baseline (11 files), evidence/qa-gates (6 files), evidence/regression-testing (2 files), issue.md, plan.2026-10-15T15-44.md, research/research.2026-10-15T16-10.md, spec.md.

## git status --porcelain

```text
 M docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/plan.2026-10-15T15-44.md
 M tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1
 M tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
 M tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/excluded-paths-diff.2026-10-16T03-17.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/feature-review-unchanged.2026-10-16T03-17.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/limited-diff.2026-10-16T03-17.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/line-counts.2026-10-16T03-16.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/mirror-hashes.2026-10-16T03-16.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/poshqc-analyze.2026-10-16T02-58.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/poshqc-coverage.2026-10-16T03-15.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/poshqc-format.2026-10-16T02-58.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/poshqc-test.2026-10-16T03-00.md
?? docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/pytest-bundle-parity.2026-10-16T03-16.md
```

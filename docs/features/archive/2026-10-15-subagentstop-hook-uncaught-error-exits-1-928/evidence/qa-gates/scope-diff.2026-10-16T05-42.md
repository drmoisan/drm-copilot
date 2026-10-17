# Scope Diff (remediation cycle 1 final QC, pass 1)

Timestamp: 2026-10-16T05-42
Command: git diff --name-only CYCLE_BASE
EXIT_CODE: 0
CYCLE_BASE: b08496681062990d39ccc4e1a07767b9854701d3
NEW_MERGE_BASE: 97559c3e0dcfceb807ae330d3c9e6ae4c5d67964
Output Summary:

`git diff --name-only CYCLE_BASE` (22 paths): the five cycle files plus FEATURE paths only.
- .claude/hooks/subagentstop-envelope.ps1
- docs/engineering/claude-code-architecture.md
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1
- tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
- tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
- FEATURE/remediation-plan.2026-10-16T03-45.md, FEATURE/spec.md
- FEATURE/evidence/qa-gates/: architecture-doc-tokens.2026-10-16T05-26.md, help-rewrap.2026-10-16T05-24.md, test-file-constraints.2026-10-16T05-22.md
- FEATURE/evidence/regression-testing/: lastexitcode-fail-before.2026-10-16T05-10.md, statement-terminating-after.2026-10-16T05-21.md
- FEATURE/evidence/remediation-baseline/: git-state.2026-10-16T04-20.md, line-counts.2026-10-16T04-22.md, mirror-hashes.2026-10-16T04-22.md, phase0-instructions-read.2026-10-16T04-20.md, poshqc-analyze.2026-10-16T04-29.md, poshqc-coverage.2026-10-16T04-51.md, poshqc-format.2026-10-16T04-24.md, poshqc-test.2026-10-16T04-29.md, pytest-bundle-parity.2026-10-16T04-52.md, width-and-doc-tokens.2026-10-16T04-23.md
- All five cycle files are listed in the CYCLE_BASE diff (committed in P1-T7, P2-T5, P3-T7).

`git diff --name-only NEW_MERGE_BASE`: 31 non-FEATURE paths plus FEATURE paths. The 31 non-FEATURE paths are exactly the 31 entries of spec.md `## Files In Scope`:
- .agents/skills/translate-claude-to-codex/SKILL.md; .claude/agents/epic-orchestrator.md; .claude/hooks/enforce-epic-wave-barrier.ps1; .claude/hooks/subagentstop-envelope.ps1; .claude/hooks/validate-discovery-artifact-gate.ps1; .claude/hooks/validate-executor-output.ps1; .claude/hooks/validate-orchestrator-output.ps1; .claude/hooks/validate-planner-output.ps1; .claude/hooks/validate-pr-author-output.ps1; .claude/hooks/validate-prd-feature-output.ps1; .claude/hooks/validate-required-artifact-output.ps1; .claude/hooks/validate-task-researcher-output.ps1; .claude/skills/epic-orchestrate/SKILL.md; docs/engineering/claude-code-architecture.md
- extensions/drm-copilot/resources/claude-customizations/: .claude/agents/epic-orchestrator.md, .claude/hooks/enforce-epic-wave-barrier.ps1, .claude/hooks/subagentstop-envelope.ps1, .claude/hooks/validate-discovery-artifact-gate.ps1, .claude/hooks/validate-executor-output.ps1, .claude/hooks/validate-orchestrator-output.ps1, .claude/hooks/validate-planner-output.ps1, .claude/hooks/validate-pr-author-output.ps1, .claude/hooks/validate-prd-feature-output.ps1, .claude/hooks/validate-required-artifact-output.ps1, .claude/hooks/validate-task-researcher-output.ps1, .claude/skills/epic-orchestrate/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md
- tests/scripts/claude-hooks/: subagentstop-envelope-orchestrator-family.Registration.Tests.ps1, subagentstop-envelope.Tests.ps1, subagentstop-uncaught-error.Tests.ps1, validate-required-artifact-output.Envelope.Tests.ps1
- All remaining paths are under FEATURE/ (review artifacts, issue.md, spec.md, plans, research, and evidence).

`git status --porcelain` (before the P4-T14 commit): FEATURE only.
- ` M FEATURE/remediation-plan.2026-10-16T03-45.md`
- `?? FEATURE/evidence/qa-gates/`: citation-width.2026-10-16T05-41.md, excluded-paths-diff.2026-10-16T05-42.md, feature-review-unchanged.2026-10-16T05-42.md, limited-diff.2026-10-16T05-41.md, line-counts.2026-10-16T05-41.md, mirror-hashes.2026-10-16T05-40.md, poshqc-analyze.2026-10-16T05-28.md, poshqc-coverage.2026-10-16T05-40.md, poshqc-format.2026-10-16T05-27.md, poshqc-test.2026-10-16T05-39.md, pytest-bundle-parity.2026-10-16T05-40.md

FEATURE = docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928

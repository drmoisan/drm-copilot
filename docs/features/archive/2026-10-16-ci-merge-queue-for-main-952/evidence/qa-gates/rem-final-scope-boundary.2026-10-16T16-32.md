# Final scope boundary of remediation cycle 1

Timestamp: 2026-10-16T16-32
Task: [P5-T10]
Command: git diff --name-only f9d18c2bd605b94bd63805df3f6e092d6ae79607 HEAD; git status --porcelain; git diff -U0 f9d18c2bd605b94bd63805df3f6e092d6ae79607 HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md
EXIT_CODE: 0
Output Summary: OUTSIDE_PATHS=10 FEATURE_NON_EVIDENCE_PATHS=3 PY_PATHS=0 FROZEN_EPIC_SURFACES_CHANGED=0 PLAN_NONCHECKBOX_CHANGES=0

REM_BASE_SHA=f9d18c2bd605b94bd63805df3f6e092d6ae79607 (P0-T2); HEAD at the time of the check: 205d31a361cb7fc7a08b3cb406884949df89ece3.

## Union of name-only and porcelain paths, excluding FEATURE/evidence/

Outside the feature folder (10; equals `## Files Written`: 1 created, 9 modified):
- .claude/hooks/enforce-epic-merge-gate-command.ps1
- .codex/hooks/enforce-epic-merge-gate-command.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1
- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 (created)
- tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1

Feature folder, non-evidence (3):
- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-plan.2026-10-16T12-51.md (also ` M` in porcelain: Phase 5 checklist state)
- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md
- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md

All other listed paths (name-only and porcelain `??` lines) are under docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/.

## Absent paths

`.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `config/poshqc-coverage.json`, `.github/workflows/_poshqc.yml`, every path under `.claude/rules/` and `.github/instructions/`, and every `.py` path are absent from the union.

## Plan diff

The committed plan diff has 48 removed and 48 added lines. Every removed line begins `- [ ] [P` and its paired added line is identical except that `[ ]` became `[x]` (P0-T1 through P4-T5). No other line of the plan changed.

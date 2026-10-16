# Final Line Counts (issue #928, P6-T10, loop pass 1)

Timestamp: 2026-10-16T03-16
Command: wc -l <15 files of P0-T4> tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 <10 PowerShell mirrors of P5-T1>
EXIT_CODE: 0

Baseline sources: `FEATURE/evidence/baseline/line-counts.2026-10-16T01-06.md` for the 15 P0-T4 files; `git show MERGE_BASE:<path> | wc -l` for the two test files edited in P6-T1 and P6-T2; no baseline for the new suite.

Output Summary: every `.ps1` count is at most 500 (largest 442); `.claude/hooks/validate-planner-output.ps1` is 442 (at most 443).

| File | Lines | Baseline |
| --- | --- | --- |
| .claude/hooks/subagentstop-envelope.ps1 | 191 | 191 |
| .claude/hooks/validate-discovery-artifact-gate.ps1 | 255 | 253 |
| .claude/hooks/validate-executor-output.ps1 | 324 | 322 |
| .claude/hooks/validate-feature-review-coverage.ps1 | 205 | 205 |
| .claude/hooks/validate-orchestrator-output.ps1 | 346 | 344 |
| .claude/hooks/validate-planner-output.ps1 | 442 | 440 |
| .claude/hooks/validate-pr-author-output.ps1 | 131 | 129 |
| .claude/hooks/validate-prd-feature-output.ps1 | 120 | 118 |
| .claude/hooks/validate-required-artifact-output.ps1 | 201 | 199 |
| .claude/hooks/validate-task-researcher-output.ps1 | 292 | 290 |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 380 | 380 |
| tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | 278 | 278 |
| .claude/skills/epic-orchestrate/SKILL.md | 359 | 359 |
| .claude/agents/epic-orchestrator.md | 168 | 168 |
| .agents/skills/translate-claude-to-codex/SKILL.md | 297 | 297 |
| tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 | 134 | (new suite, no baseline) |
| tests/scripts/claude-hooks/subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 | 157 | 157 (MERGE_BASE) |
| tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | 217 | 217 (MERGE_BASE) |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1 | 191 | 191 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | 255 | 253 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1 | 324 | 322 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 | 346 | 344 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1 | 442 | 440 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | 131 | 129 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | 120 | 118 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1 | 201 | 199 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | 292 | 290 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1 | 380 | 380 |

Mirror baselines equal their sources' baselines (all 14 pairs were IDENTICAL at P0-T5).

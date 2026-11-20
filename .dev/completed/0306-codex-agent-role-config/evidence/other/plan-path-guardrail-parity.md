Timestamp: 2026-07-04T14-25
Command: Verify root and bundled plan-path guardrail skill parity for issue #306
EXIT_CODE: 0
Output Summary:
- PASS: .agents/skills/orchestrate/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md - root contains plan*.md enumeration.
- PASS: .agents/skills/orchestrate/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md - bundle contains plan*.md enumeration.
- PASS: .agents/skills/orchestrate/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md - root contains issue 306 invariant.
- PASS: .agents/skills/orchestrate/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md - bundle contains issue 306 invariant.
- PASS: .agents/skills/orchestrate/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md - root and bundle are byte-identical.
- PASS: .agents/skills/orchestrator-workflow/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md - root contains plan*.md enumeration.
- PASS: .agents/skills/orchestrator-workflow/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md - bundle contains plan*.md enumeration.
- PASS: .agents/skills/orchestrator-workflow/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md - root contains issue 306 invariant.
- PASS: .agents/skills/orchestrator-workflow/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md - bundle contains issue 306 invariant.
- PASS: .agents/skills/orchestrator-workflow/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md - root and bundle are byte-identical.
- PASS: .agents/skills/feature-promotion-lifecycle/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md - root contains plan*.md enumeration.
- PASS: .agents/skills/feature-promotion-lifecycle/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md - bundle contains plan*.md enumeration.
- PASS: .agents/skills/feature-promotion-lifecycle/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md - root contains issue 306 invariant.
- PASS: .agents/skills/feature-promotion-lifecycle/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md - bundle contains issue 306 invariant.
- PASS: .agents/skills/feature-promotion-lifecycle/SKILL.md / extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md - root and bundle are byte-identical.

Issue #306 Invariant Text:
Issue #306 invariant: when `${feature-folder}` is `docs/features/active/2026-07-04-codex-agent-role-config-306`, `${plan-path}` must be `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`; do not create or delegate against `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.md`.

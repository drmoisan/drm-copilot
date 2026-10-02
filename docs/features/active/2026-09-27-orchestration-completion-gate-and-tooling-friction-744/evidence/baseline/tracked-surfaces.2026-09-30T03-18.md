# Tracked Surfaces

Timestamp: 2026-10-02T01-17
Command: git ls-files -- <the 26 paths named in plan task P0-T10>; test -e tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py; test -e tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
EXIT_CODE: 0
Output Summary:
- `git ls-files` exit 0, printed 26 lines, one per named path (all 26 edited surfaces are tracked).
- `test -e tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` exit 1 (absent).
- `test -e tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` exit 1 (absent).
- Stop condition not triggered.

Paths printed:
.agents/skills/acceptance-criteria-tracking/SKILL.md
.agents/skills/evidence-and-timestamp-conventions/SKILL.md
.agents/skills/orchestrate/SKILL.md
.claude/agents/feature-review.md
.claude/agents/parallel-orchestrator.md
.claude/skills/acceptance-criteria-tracking/SKILL.md
.claude/skills/evidence-and-timestamp-conventions/SKILL.md
.claude/skills/orchestrate/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
.github/skills/acceptance-criteria-tracking/SKILL.md
.github/skills/evidence-and-timestamp-conventions/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md
extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts
extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts
scripts/dev_tools/pr_context/verification_evidence.py
tests/scripts/dev_tools/pr_context/test_verification_evidence.py

# Permission Surface — Excluded Literals Absent

Timestamp: 2026-10-10T08-41
Task: [P6-T7]
Command: (1) grep -c -F "poetry run python -m" .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md; (2) grep -c -F "Bash(bash .claude/lib/bash/*)" .claude/settings.json extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
EXIT_CODE: 1, 1
ExpectedExitCode: 1

Output Summary:
- (1) `.claude/agents/parallel-orchestrator.md:0`, `extensions/.../.claude/agents/parallel-orchestrator.md:0`; exit 1.
- (2) `.claude/settings.json:0`, `extensions/.../.claude/settings.json:0`; exit 1.
- The module-form grant is removed from the agent file and its mirror, and no bash-library wildcard grant exists in either settings file.

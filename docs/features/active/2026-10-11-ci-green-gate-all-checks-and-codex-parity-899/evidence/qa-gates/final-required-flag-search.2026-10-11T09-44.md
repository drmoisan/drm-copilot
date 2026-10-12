# Final --required Flag Search (P2-T12)

Timestamp: 2026-10-12T16-30
Task: P2-T12
Command: git grep -n -F -e "--required" -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .agents/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md .claude/lib/ci-gate/Invoke-CiGateParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: No output; git grep exits 1 when nothing matches. No `--required` query remains in the edited gate surfaces, their mirrors, or the parser and its mirror.

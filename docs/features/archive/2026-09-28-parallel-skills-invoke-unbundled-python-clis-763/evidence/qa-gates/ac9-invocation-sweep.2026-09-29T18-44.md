# AC9 Invocation Sweep (P6-T3)

Timestamp: 2026-09-29T18-44
Command: git grep -n -E 'python3?[[:space:]]+(-m[[:space:]]+)?scripts[./]dev_tools[./]parallel_(drift_detection|mutation_abandon)_cli' -- .claude extensions/drm-copilot/resources/claude-customizations/.claude ; git grep -n -E '<same pattern>' 12db46245ba7683b5d6ccb676312a4b22a39b0ce -- .claude extensions/drm-copilot/resources/claude-customizations/.claude ; git status --porcelain -- .claude extensions/drm-copilot/resources/claude-customizations/.claude
EXIT_CODE: 0
Output Summary:
- Sweep over the current tracked trees: exit 1, no output (no match).
- Negative control at BASE_SHA (`12db46245ba7683b5d6ccb676312a4b22a39b0ce`): exit 0, exactly four
  lines, the two SKILL invocation lines in the repository tree and the same two in the bundle tree:
  - `.claude/skills/parallel-orchestrate/SKILL.md:884` (the drift CLI module-form invocation)
  - `.claude/skills/parallel-remove/SKILL.md:112` (the abandon CLI path-form invocation)
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:884`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md:112`
  This proves the pattern matches the pre-change invocations.
- Porcelain status over the two swept trees: empty, so the tracked-file search saw every file.

This is the tracked-file equivalent of the spec AC9 ripgrep command. The artifact's EXIT_CODE
records that all three observations matched the acceptance (sweep exit 1 with no output, control
exit 0 with four lines, empty porcelain).

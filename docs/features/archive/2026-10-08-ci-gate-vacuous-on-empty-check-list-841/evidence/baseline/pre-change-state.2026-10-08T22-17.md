# Pre-Change State Reproduction (#841, P0-T19)

Timestamp: 2026-10-10T09-19
Command: six commands, each run separately and recorded below
EXIT_CODE: 0
Output Summary:
- CR-1/CR-4 reproduced: "when all required checks pass" and "that the required checks were observed against" each present once in `.claude/skills/orchestrate/SKILL.md` and its Claude bundle mirror.
- PA-N9 reproduced: "whose head SHA matches the current branch head" present once in the Claude feature-review skill and its mirror.
- #795 reproduced: "### modified-workflow-needs-green-run" absent from the .agents feature-review skill and its Codex mirror (exit 1, no output).
- CR-1 parser: "RequireWorkflow" absent from the parser (exit 1, no output).
- New pytest file untracked and absent (git ls-files empty; Glob returns no file).
- All acceptance conditions met. EXIT_CODE above is the task-level result; per-command exit codes below.

## Per-command results

1. `git grep -c -F -e 'when all required checks pass' -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
   EXIT_CODE: 0
   - `.claude/skills/orchestrate/SKILL.md:1`
   - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md:1`
2. `git grep -c -F -e 'that the required checks were observed against' -- .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
   EXIT_CODE: 0
   - `.claude/skills/orchestrate/SKILL.md:1`
   - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md:1`
3. `git grep -c -F -e 'whose head SHA matches the current branch head' -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md`
   EXIT_CODE: 0
   - `.claude/skills/feature-review-workflow/SKILL.md:1`
   - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md:1`
4. `git grep -c -F -e '### modified-workflow-needs-green-run' -- .agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`
   EXIT_CODE: 1 (no output)
5. `git grep -c -F -e 'RequireWorkflow' -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1`
   EXIT_CODE: 1 (no output)
6. `git ls-files -- tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`
   EXIT_CODE: 0 (no output)
   - Glob `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`: No files found

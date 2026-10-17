# Documentation Token Checks and Deferred Surface — P7-T9

Timestamp: 2026-09-30T14-44
Task: P7-T9
Working directory: worktree root

## 1

Command: grep -c -F -e "issue_adoption" .claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md .claude/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md .codex/agents/orchestrator.toml
EXIT_CODE: 0
Output Summary:
```
.claude/rules/orchestrator-state.md:4
.claude/skills/orchestrate/SKILL.md:2
.claude/skills/feature-promotion-lifecycle/SKILL.md:2
.agents/skills/orchestrate/SKILL.md:1
.agents/skills/feature-promotion-lifecycle/SKILL.md:1
.agents/skills/orchestrator-workflow/SKILL.md:2
.codex/agents/orchestrator.toml:1
```
Every file is at least 1; `.agents/skills/orchestrator-workflow/SKILL.md` is 2 (at least 2 required).

## 2

Command: grep -c -F -e "## Invariants (issue_adoption object)" .claude/rules/orchestrator-state.md
EXIT_CODE: 0
Output Summary: `1`

## 3

Command: grep -c -F -e "_orchestrator_state_issue_adoption.py" .claude/rules/orchestrator-state.md
EXIT_CODE: 0
Output Summary: `1`

## 4

Command: git status --porcelain -- .github/skills/feature-promotion-lifecycle/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md
EXIT_CODE: 0
Output Summary: empty listing; the deferred `.github` surface and its bundle copy are untouched.

Result: PASS

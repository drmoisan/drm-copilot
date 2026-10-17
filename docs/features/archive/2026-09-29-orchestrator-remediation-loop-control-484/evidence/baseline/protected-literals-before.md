# Protected Literals Baseline (P0-T12)

Timestamp: 2026-10-01T21-08
Task: P0-T12
Tree: working tree at HEAD aee08d8569918bbdbd7a59b5f573be2131d13f57

## Command 1

Command: git grep -c -F "python -m" -- .claude/skills/orchestrate/SKILL.md .claude/skills/feature-review-workflow/SKILL.md .claude/skills/remediation-handoff-atomic-planner/SKILL.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md
EXIT_CODE: 1
Output: (none)

## Command 2

Command: git grep -c -F "is not modified by this" -- .claude/skills/parallel-orchestrate/SKILL.md
EXIT_CODE: 0
Output: `.claude/skills/parallel-orchestrate/SKILL.md:1`

## Command 3

Command: git grep -c -F "issue_adoption" -- .agents/skills/orchestrator-workflow/SKILL.md
EXIT_CODE: 0
Output: `.agents/skills/orchestrator-workflow/SKILL.md:2`

## Command 4

Command: git grep -c -F "Blocked-reason partition:" -- .agents/skills/orchestrator-workflow/SKILL.md
EXIT_CODE: 0
Output: `.agents/skills/orchestrator-workflow/SKILL.md:1`

## Command 5

Command: git grep -c -F "MUST be one of:" -- .agents/skills/orchestrator-workflow/SKILL.md
EXIT_CODE: 0
Output: `.agents/skills/orchestrator-workflow/SKILL.md:1`

## Output Summary:

- `python -m`: no matches in the five Claude skill files (exit 1).
- `is not modified by this`: 1 (parallel-orchestrate SKILL.md).
- `issue_adoption`: 2; `Blocked-reason partition:`: 1; `MUST be one of:`: 1 (all in .agents/skills/orchestrator-workflow/SKILL.md).
- These outputs and exit codes are the comparison values for P6-T27.

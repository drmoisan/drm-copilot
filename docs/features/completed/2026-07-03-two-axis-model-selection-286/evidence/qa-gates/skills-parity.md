# Skills Parity — orchestrate and epic-orchestrate

Timestamp: 2026-07-03T16-43

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
EXIT_CODE: 0

Output Summary: 7 passed. Both edited skill files pass byte-identity against their bundled mirrors:
- `.claude/skills/orchestrate/SKILL.md` — new `## Model Selection` section (between `## Delegation Model` and `## PR Authoring`), the two commit points delegating message generation to `Agent(commit-message)` while `git commit` stays on the orchestrator, and the exception-runbook requirement delegating authoring to `Agent(human-exception-runbook)` while the orchestrator records `runbook_path`.
- `.claude/skills/epic-orchestrate/SKILL.md` — new `## Model Selection` section after `## Merge-on-Green Kickoff Parameter`, documenting the `model_budget.fable_policy` kickoff marker and both reference implementations.

`cmp` confirmed byte-identity for both files before the contract test.

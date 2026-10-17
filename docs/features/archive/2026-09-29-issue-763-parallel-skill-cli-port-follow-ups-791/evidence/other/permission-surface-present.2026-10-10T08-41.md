# Permission Surface — Required Literals Present

Timestamp: 2026-10-10T08-41
Task: [P6-T6]
Command: (1) grep -c -F "Bash(poetry run python -c *)" .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md; (2) grep -c -F "Bash(bash .claude/lib/bash/remove-parallel-item.sh*)" .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md .claude/settings.json extensions/drm-copilot/resources/claude-customizations/.claude/settings.json; (3) grep -c -F "Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)" .claude/settings.json extensions/drm-copilot/resources/claude-customizations/.claude/settings.json; (4) grep -c -F "#791" .claude/agents/parallel-orchestrator.md
EXIT_CODE: 0, 0, 0, 0

Output Summary:
- (1) `-c` grant: `.claude/agents/parallel-orchestrator.md:1`, `extensions/.../.claude/agents/parallel-orchestrator.md:1`.
- (2) remove grant: agent `:1`, agent mirror `:1`, `.claude/settings.json:1`, settings mirror `:1`.
- (3) abandon grant: `.claude/settings.json:1`, settings mirror `:1`.
- (4) `#791` in the agent file: `2`.
- Supporting checks: `grep -n -F "Bash(bash .claude/lib/bash/" .claude/settings.json` prints lines 8-12 in the order abandon, compute-cohorts, compute-concurrency-batches, remove, validate-parallel-manifest ([P6-T1]); `poetry run python -m json.tool .claude/settings.json` exit 0; `cmp` of both settings and both agent-file pairs exit 0 with no output ([P6-T2], [P6-T5]).

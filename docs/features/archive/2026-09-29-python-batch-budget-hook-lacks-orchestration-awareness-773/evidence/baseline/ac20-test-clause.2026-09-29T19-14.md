# AC-20 Test-Clause Non-Vacuity Baseline (P0-T26)

Timestamp: 2026-09-29T19-14
Command: git grep -n -i -E -e '>[[:space:]]*`?3`?[[:space:]]*test' -- <the six AC-20 files of Appendix G>; git grep -n -i -F -e '1-3 test Python files' -- <the six AC-20 files of Appendix G>
EXIT_CODE: 0
Output Summary:
Regex search (exit 0), 8 lines naming all six AC-20 files:
- .codex/agents/python-orchestrator.toml:31
- .github/agents/python-orchestrator.agent.md:100, :246
- .github/prompts/orchestrate-python-work.prompt.md:26
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/python-orchestrator.toml:31
- extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md:100, :246
- extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-python-work.prompt.md:26
Fixed-string search (exit 0), 2 lines:
- .github/agents/python-orchestrator.agent.md:129
- extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md:129

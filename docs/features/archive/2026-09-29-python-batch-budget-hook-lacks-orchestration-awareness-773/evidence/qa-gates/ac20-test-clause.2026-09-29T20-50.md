# AC-20 Test-Clause Check (P10-T3)

Timestamp: 2026-09-29T20-50
Command: git grep -n -i -E -e '>[[:space:]]*`?3`?[[:space:]]*test' -- <six AC-20 files>; git grep -n -i -F -e '1-3 test Python files' -- <six AC-20 files>; git grep -c -F -e 'production Python files' -- <six AC-20 files>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Regex search: exit 1, no output (baseline matched 8 lines across all six files).
- Fixed-string search: exit 1, no output (baseline matched 2 lines).
- Positive search (exit 0) printed six path:count lines: .codex/agents/python-orchestrator.toml:2, .github/agents/python-orchestrator.agent.md:7, .github/prompts/orchestrate-python-work.prompt.md:3, and the same counts for the three bundle mirrors.
The six AC-20 files: .github/agents/python-orchestrator.agent.md, .github/prompts/orchestrate-python-work.prompt.md, .codex/agents/python-orchestrator.toml, and their mirrors under extensions/drm-copilot/resources/customizations/.github/ and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/.

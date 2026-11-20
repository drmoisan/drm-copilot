# Execution-Environment Brief Hashes (issue #1009)

Timestamp: 2026-10-30T17-45
Command: cp .claude/skills/execution-environment/SKILL.md to the five other copies, then sha256sum over all six
EXIT_CODE: 0
Output Summary: all six copies are byte-identical (SHA-256 f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4). `test_execution_environment_brief_contracts.py` and `test_single_pass_preflight_contracts.py` pass (31 passed); the full contract set is gated in [P9-T7].

| Copy | SHA-256 |
|---|---|
| `.claude/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |
| `.agents/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |
| `.github/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | f1b1080bb3b31e568ec72a424caf5ffd578003011e4f92dbb1d3ad5fb81672c4 |

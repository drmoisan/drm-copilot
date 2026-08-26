Timestamp: 2026-08-26T07-40
Policy Order:
1. AGENTS.md
2. AGENTS.md — cross-language code-change section
3. AGENTS.md — cross-language unit-test section
4. .agents/skills/python/SKILL.md
5. .agents/skills/python-suppressions/SKILL.md

Files Read:
- AGENTS.md
- .agents/skills/general-code-change/SKILL.md
- .agents/skills/general-unit-test/SKILL.md
- .agents/skills/python/SKILL.md
- .agents/skills/python-suppressions/SKILL.md

Output Summary:
- Modified production, test, and reusable-script files must not exceed 500 lines.
- Unit tests must not create or use temporary files.
- Required Python toolchain order is Black, Ruff, Pyright, then Pytest; restart at Black if an earlier command changes files or a later command fails.
- Suppressions require a pre-authorized pattern or explicit user approval; no suppression is authorized for this remediation.

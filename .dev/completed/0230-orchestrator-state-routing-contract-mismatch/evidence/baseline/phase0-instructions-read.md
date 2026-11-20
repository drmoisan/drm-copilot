# Phase 0 — Policy Instructions Read

Timestamp: 2026-06-24T17-47

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/python.md
5. .claude/rules/python-suppressions.md
6. .claude/rules/self-explanatory-code-commenting.md
7. .claude/rules/quality-tiers.md

Files Read (explicit list):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/self-explanatory-code-commenting.md
- .claude/rules/quality-tiers.md

Scope: Python is the only language with code/test changes in this plan. The
config change (`config/orchestration-routing.json` and its bundled mirror) is
JSON data, and the orchestrate skill change is Markdown documentation. The
applicable language toolchain is Python (black, ruff, pyright, pytest).

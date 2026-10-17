# SKILL.md Literals Before (Issue #464)

Timestamp: 2026-09-30T08-23
Command: git grep -c -F "local CLI" -- .claude/skills/orchestrate/SKILL.md
Command: git grep -c -F "python -m" -- .claude/skills/orchestrate/SKILL.md
EXIT_CODE: 0 (first command), 1 (second command)
Output Summary:
- First command printed `.claude/skills/orchestrate/SKILL.md:2` (matches expected).
- Second command printed nothing and exited 1 (matches expected).

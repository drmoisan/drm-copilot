# Phase 0 — Policy Instructions Read

Timestamp: 2026-07-18T11-12

Policy Order:
1. CLAUDE.md (standing instructions, tone and policy-compliance order)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/python.md (Python toolchain and coding standards)
5. .claude/rules/python-suppressions.md (Python suppression authorization policy)

Files Read (in required order):
- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a20770a51a7c54e8a\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a20770a51a7c54e8a\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a20770a51a7c54e8a\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a20770a51a7c54e8a\.claude\rules\python.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a20770a51a7c54e8a\.claude\rules\python-suppressions.md

Output Summary: All five policy files read in the required order. Key constraints applied for this feature: Black -> Ruff -> Pyright -> Pytest toolchain loop with restart-on-change; line coverage >= 85% and branch coverage >= 75% uniform across tiers; no runtime temp files in tests (use mem_fs_path fixture); production and test files each under 500 lines; suppressions require pre-authorized patterns or explicit approval; fail-fast error handling with specific exceptions.

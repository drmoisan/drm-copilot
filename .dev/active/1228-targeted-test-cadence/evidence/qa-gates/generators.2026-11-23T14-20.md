# Generators - Issue #1228 ([P1-T5]; AC-11, AC-12)

Timestamp: 2026-11-23T14-20
Command: sh <item worktree>/artifacts/issue-1228/gen.sh, which runs at the item worktree root with VIRTUAL_ENV unset, in order: `git status --porcelain` (before); `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1` (write, all surfaces); `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write); `git status --porcelain` (after); `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary:
- Harness generation write: EXIT_CODE 0. Codex variant generator write: EXIT_CODE 0.
- Invoke-HarnessGeneration.ps1 -Check: EXIT_CODE 0, "harness-generation: no drift" (AC-11).
- Invoke-HarnessGeneration.ps1 -Surface instructions -Check: EXIT_CODE 0, "harness-generation: no drift" (AC-11; covers the AGENTS.md bundle drift and EMBEDDED-RULE checks).
- generate_codex_agent_variants --check: EXIT_CODE 0, no drift reported (AC-12).
- Observation beyond the exit code: `git status --porcelain` before the write runs held 25 entries; after them it held 125 entries. The 100 added entries are generated targets only: `.agents/skills/{csharp,general-code-change,powershell,python,typescript}/SKILL.md`; `.claude/agents/{atomic-executor,atomic-planner,csharp-typed-engineer,powershell-typed-engineer,python-typed-engineer}.md`; `.claude/rules/{csharp,general-code-change,powershell,python,shell,typescript}.md`; `.claude/skills/{execution-environment,remediation-handoff-atomic-planner,test-execution-policy}/SKILL.md`; `.codex/agents/{atomic-executor,atomic-planner,csharp-typed-engineer,powershell-typed-engineer,python-typed-engineer}` base and `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` TOML files (30); `.github/instructions/general-code-change.instructions.md`; and the bundle copy of each of these under `extensions/drm-copilot/resources/` (claude-customizations, codex-and-agents-customizations, customizations). No entry was removed and no hand-authored path was added.
- Run window: 2026-11-23T14-14 (UTC).

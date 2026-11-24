# Generators - Issue #1228 ([P1-T5] re-run on resume; AC-11, AC-12)

Timestamp: 2026-11-24T04-05
Command: sh <item worktree>/artifacts/issue-1228/gen.sh, which runs at the item worktree root with VIRTUAL_ENV unset, in order: `git status --porcelain` (before); `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1` (write, all surfaces); `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write); `git status --porcelain` (after); `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary:
- Run on the tree after the `origin/main` merge (the paused run's generator outputs were committed in the work-in-progress commit). Run window 2026-11-24T04-00 (UTC).
- Harness generation write: EXIT_CODE 0 ("harness-generation: no drift"). Codex variant generator write: EXIT_CODE 0.
- Invoke-HarnessGeneration.ps1 -Check: EXIT_CODE 0, "harness-generation: no drift" (AC-11).
- Invoke-HarnessGeneration.ps1 -Surface instructions -Check: EXIT_CODE 0, "harness-generation: no drift" (AC-11).
- generate_codex_agent_variants --check: EXIT_CODE 0, no drift reported (AC-12).
- Observation beyond the exit code: `git status --porcelain` before and after the two write runs is identical (4 entries: the plan file and three new task-check files of this resume run), so the write runs changed no tracked or untracked file. Every generated target already equals the rendering of its source.
- The earlier artifact `generators.2026-11-23T14-20.md` (kept unchanged) records the original write runs, which added the 100 generated targets and bundle copies.

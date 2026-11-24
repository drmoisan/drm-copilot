# Generator Runs - [P1-T2] - Issue #1228, remediation cycle 1

Timestamp: 2026-11-24T08-07
Plan: remediation-plan.2026-11-24T07-15.md
Command: `sh <item worktree>/artifacts/issue-1228/gen.sh`, which runs at the item worktree root with VIRTUAL_ENV unset: `git status --porcelain` (before); `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1` (write); `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write); `git status --porcelain` (after); `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check`; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary:
- Run 2026-11-24T08-06 (UTC), after the edit of `scripts/harness-generation/sources/agents/feature-review.md` (both halves of `## Coverage Verification`).
- Harness write: EXIT_CODE 0. Codex variant write: EXIT_CODE 0.
- `-Check`: EXIT_CODE 0, "harness-generation: no drift". `-Surface instructions -Check`: EXIT_CODE 0, "harness-generation: no drift". Codex generator `--check`: EXIT_CODE 0.
- `git status --porcelain` before versus after the write runs: exactly four entries added, all ` M`: `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`. No other entry changed.
- Token counts in the generated `.claude/agents/feature-review.md` / `.codex/agents/feature-review.toml`: `supplies per-file figures only` 1/1, `from the final-QC artifact and` 1/1, `over the branch's test selection` 1/1, `never runs the full suite` 1/1, `a full-suite final-QC artifact` 1/1; `does NOT rerun coverage generation` 0/0, `rather than rerunning coverage generation` 0/0, `local artifact that shows the` 0/0. Kept: `governing repo-wide threshold` 1 (Claude), `Enforce Python coverage thresholds` 1/1, `regression on changed lines` 1/1, `vendored-coverage-exemptions.json` 1/1, `hand-written` 1/1, `payload_version` 1/1.

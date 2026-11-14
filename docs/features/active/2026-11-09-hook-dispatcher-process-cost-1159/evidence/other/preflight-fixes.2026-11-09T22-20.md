# Preflight Fixes

Timestamp: 2026-11-09T22-20
Plan: docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/plan.2026-11-09T16-31.md

## Fixes

1. [P0-T3] | literal formatting (unsatisfiable tool mode) | `Invoke-PoshQCFormat` in `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` has no check mode, so "PoshQC format check" in check mode had no command. Reworded to a format check through `Invoke-Formatter` with the PoshQC settings, comparing its output with each file's text and writing nothing. The assertion (no rewrite before capture; count of files needing formatting) is unchanged.
2. [P4-T1] | ambiguous path | `enforce-worktree-poetry-venv.Tests.ps1` exists under both `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`; only the Claude file reads `.claude/settings.json`. Replaced the bare name with `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` and recorded the Codex file as unchanged. Also gave `enforce-orchestration-preimplementation-gate.Tests.ps1` its full path.
3. [P4-T1] | missing disposition for an existing asserting test | `claude-settings.Tests.ps1` `It` `requires .claude/settings.json to omit a default agent and declare canonical worker hook coverage` reads `hooks.PreToolUse`; recorded as unchanged (the worker names it requires are present in `SubagentStop`, verified by reading `.claude/settings.json`; `hooks.PreToolUse` stays non-empty).
4. [P4-T3] | ambiguous path | `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` exists under both test folders; only the `tests/scripts/codex-hooks/` file reads `.codex/config.toml`. Replaced the bare name with the full Codex path.
5. [P6-T3] | missing disposition for an existing asserting test | `test_brief_batch_budget_section_states_cap_codes_and_exemptions` in `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pins tokens of the `## Batch Budget` section that [P6-T3] edits; the task now states that those tokens are kept. The test already runs in [P7-T4].

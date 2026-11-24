# Contract and Scope Checks (P4-T5)

Timestamp: 2026-11-24T09-47
Command: scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check (through SCRATCH/issue-1234-harness.ps1); env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.generate_codex_agent_variants --check; @(Get-Content -LiteralPath <path>).Count per file (SCRATCH/issue-1234-sizes.ps1); git diff --name-only MB...HEAD and git status --porcelain, where MB is the merge base of origin/main and HEAD
EXIT_CODE: 0
Output Summary:
- `Invoke-HarnessGeneration.ps1 -Check`: exit 0, `harness-generation: no drift`.
- Codex generator `--check`: exit 0.
- Scope: `git diff --name-only MB...HEAD` lists the 8 committed planning documents of the feature folder and the promoted potential file (the implementation is uncommitted by instruction); `git status --porcelain` lists 52 entries. Neither list contains `hook-release-allowance-context.ps1`, `enforce-orchestration-preimplementation-gate-release.ps1`, `enforce-epic-merge-gate-child-ci.ps1`, `hook-docs-only-diff.ps1`, `hook-command-invocation-operands.ps1`, `enforce-epic-merge-gate-review.ps1`, `enforce-epic-merge-gate-regeneration.ps1`, `config/harness-parity-matrix.json`, `.claude/settings.json`, `.codex/config.toml`, either `pretooluse-dispatch.json`, or any `release-commit-allowance.json` (each count 0 in both lists).
- Sizes (logical lines, `@(Get-Content).Count`), P0-T1 value in parentheses where measured: `.claude/hooks/enforce-epic-merge-gate.ps1` 500 (498; at the 500 cap); `.codex/hooks/enforce-epic-merge-gate.ps1` 456 (445); `.claude/hooks/hook-release-pull-request-context.ps1` 119 (116); `.codex/hooks/hook-release-pull-request-context.ps1` 119 (new); `.claude/hooks/enforce-epic-merge-gate-release.ps1` 303 (new); `.codex/hooks/enforce-epic-merge-gate-release.ps1` 303 (new); new suites 434, 282, 233, 189, 176; edited suites 246 and 85. Every new file is below 500 and no changed file exceeds 800 (AC-28, AC-32, AC-33, AC-36).

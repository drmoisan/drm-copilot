# Fail-before: worktree Poetry venv guard suites (P1-T2)

Timestamp: 2026-11-08T14-29
Command: sh SCRATCH/issue-1127-focused.sh (focused debugging run, not a gate: Invoke-Pester with Run.PassThru over tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1 and tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1, which load tests/scripts/claude-hooks/WorktreePoetryVenv.Cases.ps1; the launcher exits 1 when FailedCount is above 0)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result object: PassedCount 0, FailedCount 150, SkippedCount 0, TotalCount 150
- Cause: the hook and helper files are absent. Each BeforeAll block fails to dot-source its target:
  - helper Describe: `.claude/hooks/worktree-poetry-venv-policy.ps1` is not recognized
  - decision Describe: `.claude/hooks/enforce-worktree-poetry-venv.ps1` is not recognized
  - Codex Describe: `.codex/hooks/enforce-worktree-poetry-venv.ps1` is not recognized
- The registration Describe fails because neither `.claude/settings.json` nor `.codex/config.toml` registers the hook.

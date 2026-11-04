# Fixture Run: post-codex-worktree-session.Tests.ps1 (P5-T5)

Timestamp: 2026-11-04T04-08
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=13 Passed=13 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 tests=13 failed=0 (baseline: 1 failed)
- Changes: in `falls back deterministically to the repository root implied by the script path`, `-ScriptRoot` is built from the portable root `post-codex-worktree-session-root`, and the expected value is the repository root with the production normalization applied (`.Replace('\', '/')` and trailing-slash trim). The opaque `C:/repo` and `C:/repo-wt` strings in the other tests are never joined and stay.

# Task check P2-T2

Timestamp: 2026-11-15T18-57
Command: `sh SCRATCH/issue-1192-sync-hook-copies.sh` (copies `.claude/hooks/test-execution-policy.ps1` over the three copies and fails unless `cmp -s` finds each equal), then `git status --porcelain`.
EXIT_CODE: 0
Output Summary:
- The script printed `equal:` for `.codex/hooks/test-execution-policy.ps1` and the two bundle copies under `extensions/drm-copilot/resources/` (claude-customizations and codex-and-agents-customizations); exit 0.
- `git status --porcelain` lists exactly four production paths as modified: the `.claude/hooks`, `.codex/hooks`, and the two bundle copies of `test-execution-policy.ps1`; `git diff --numstat` is 11 added and 4 removed for each of the four.
- Selection rule: byte identity is the check; the mirror contract tests run in P2-T4.

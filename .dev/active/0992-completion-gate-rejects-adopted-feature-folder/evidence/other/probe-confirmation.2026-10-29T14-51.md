# Manual Probe Confirmation (P6-T2, AC-19)

Timestamp: 2026-10-29T14-51
Command: sh SCRATCH/issue-992-probe.sh (git ls-files -- docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973; git cat-file -t HEAD:docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973; git cat-file -t HEAD:docs/features/active/issue-992-probe-absent)
EXIT_CODE: 0
Output Summary: The committed folder prints `tree` with exit 0; the path absent from HEAD exits 128. An additional check on an untracked folder present on disk also exits 128.

| Probe | Exit code | Output |
| --- | --- | --- |
| `git ls-files -- docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973` | 0 | 35 tracked files listed (the folder is committed) |
| `git cat-file -t HEAD:docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973` | 0 | `tree` |
| `git cat-file -t HEAD:docs/features/active/issue-992-probe-absent` | 128 | `fatal: path 'docs/features/active/issue-992-probe-absent' does not exist in 'HEAD'` |
| `git cat-file -t HEAD:docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992` (untracked on disk; `git status --porcelain` shows `??`) | 128 | `fatal: path '...-992' exists on disk, but not in 'HEAD'` |

These are direct git runs in the item worktree, not runs of the hook. The hook's handling of these outcomes is covered by `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1` with injected invokers.

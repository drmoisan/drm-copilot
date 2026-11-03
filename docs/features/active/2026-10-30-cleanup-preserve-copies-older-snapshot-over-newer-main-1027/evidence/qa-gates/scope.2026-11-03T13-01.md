# QA Gate: Scope Check

Timestamp: 2026-11-03T13-01
Task: [P7-T7]
Command: git diff --name-status <merge base of origin/main and HEAD> HEAD (merge base: the `Merge pull request #1060` commit, after `git fetch origin main`), plus git status --porcelain
EXIT_CODE: 0
Output Summary: 202 changed paths since the merge base, plus 2 modified and 4 untracked evidence and tracking files in the feature folder. Every path inside the four checked roots (`.claude/`, `extensions/drm-copilot/resources/claude-customizations/`, `tests/`, and the feature folder) is inside `## Declared Blast Radius`. One path is outside the checked roots: `docs/features/potential/promoted/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main.md`, the promoted lifecycle record that the orchestration committed before execution began (recorded in the 2026-11-03 preflight record). This run did not change it.

| Root | Changed paths | Declared blast-radius entry |
|---|---|---|
| `.claude/skills/cleanup-merged-worktrees/` | `SKILL.md` (M), `scripts/cleanup-worktrees.sh` (M), `scripts/cleanup_worktrees_preserve_lib.sh` (M), `scripts/cleanup_worktrees_preserve_merge_lib.sh` (A) | Production |
| `extensions/drm-copilot/resources/claude-customizations/` | the same four files under `.claude/skills/cleanup-merged-worktrees/` (3 M, 1 A), `pack-manifests/core.json` (M) | Mirrors and manifest |
| `tests/shell/` | `test_cleanup_worktrees_preserve.bats`, `_preserve_eol.bats`, `_preserve_failures.bats` (M); `_preserve_merge.bats`, `_preserve_merge_fallback.bats` (A) | Tests |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | M | Tests |
| `tests/fixtures/cleanup_worktrees/preserve/` | 166 added files under `merge-repro/`, `merge-clean/`, `merge-eof-union/`, `merge-already-on-main/`, `merge-g1/`, `merge-error/`, `merge-g2/`, `merge-g3/`, `merge-nobase-head/`, `merge-nobase-mergebase/`, `merge-nobase-absent/`, `merge-nobase-renamed/`, `merge-untracked/`, `merge-duplicate/`; `commit-failures/merge-blob/cat-file.merged01.out` and `commit-failures/merge-blob-fails/cat-file.merged01.rc` (A); `modified/jq.out` and `modified/manifest.json` (M) | Fixtures |
| feature folder | `issue.md`, `spec.md`, `plan.2026-10-30T20-58.md`, `research/2026-10-30T21-30-preserve-modified-merge-research.md`, and evidence under `baseline/`, `regression-testing/`, `qa-gates/`, `other/` (committed and uncommitted) | Feature documents and evidence |

Not changed, as declared: `cleanup_worktrees_preserve_eol_lib.sh`, `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, `.agents/`, `.github/`, `.codex/`, the execution-environment brief, `config/file-size-baseline.json`, `quality-tiers.yml`.

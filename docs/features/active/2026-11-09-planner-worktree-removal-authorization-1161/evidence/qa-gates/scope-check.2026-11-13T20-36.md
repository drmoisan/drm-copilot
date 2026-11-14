# Scope and invariant check ([P4-T6])

Timestamp: 2026-11-13T20-36
Command: git fetch origin main; MB = git merge-base origin/main HEAD; git diff --name-only MB HEAD; git diff --name-only --diff-filter=A MB HEAD; git status --porcelain; a drive-rooted and home-directory pattern search (a letter, a colon, and a slash or backslash not preceded by a letter; `/Users/`; `/home/`; a backslash Users segment; `AppData`) over every added file
EXIT_CODE: 1
Output Summary: Merge base equals origin/main (no main movement since the merge); 111 changed paths, 72 added, porcelain empty before this artifact. Frozen and registration files absent from the diff (0 of 4). All 73 changed paths outside the feature folder are named by the plan. Host-path search: no fixture, corpus, test, or production file matches; one evidence artifact written in this run matches (exception E1 below), so the AC-27 condition does not hold as written. EXIT_CODE 1 records that one sub-check found a match.

## Anchor

- Merge base of origin/main and HEAD: the origin/main tip itself, which carries #1157, #1163, and #1164 through the branch's merge of origin/main. Main-only files that arrived through that merge are not in the diff from the merge base.
- `git status --porcelain`: 0 entries after the last commit, so no untracked or uncommitted file is outside the diff.

## Frozen and registration files

`git diff --name-only MB HEAD` lists none of `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/settings.json`, `.codex/config.toml` (0 matches). The `PINNED_FROZEN_SURFACE_HASHES` rows pass in `pytest-gate.2026-11-13T20-08.md`.

## Changed file set against the plan

Every one of the 73 paths outside the feature folder is named by the plan: 57 by full path and the 16 corpus fixtures by name under `tests/fixtures/epic_planner_state_planner_worktrees/` (P1-T1). No path outside the plan's file set and the `## Existing Test Dispositions` list changed.

Deviations from the stated dispositions, each a related finding fixed inside this item:

- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` and `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` are listed as unchanged; each gained one `Reset-EpicStateProbeModuleBinding` call to fix a test-order dependence that is pre-existing on main (`evidence/other/task-check.P2-T6.2026-11-13T18-50.md`). No assertion changed.
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` is listed as gaining a git-seam mock; it also gained one entry-point row so that the Codex gate keeps its Phase 0 line coverage (`evidence/other/task-check.P4-T3.2026-11-13T19-44.md`).
- `tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1` (load order) and both `pack-manifests/core.json` files (entry position) changed after P3-T4 to satisfy the discovery guard and the process-reduction ledger chain (`evidence/other/task-check.P4-T3.2026-11-13T19-22.md`); both are in the plan's file set.

## Host-path search (AC-27)

- Fixtures and corpus: the only drive-shaped value is the drive-only token in `tests/fixtures/epic_planner_state_planner_worktrees/path-drive-prefix.json`, which the search pattern does not match because no slash follows the colon. No other fixture matches.
- Tests and production files: no match. The one drive-rooted synthetic value in `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1` was replaced in this task by a synthetic UNC pair (commit subject `test(hooks): use a synthetic UNC root in the path-equality row (#1161)`).
- `issue.md`: the earlier, looser search matched the `https://` URL; the pattern used here excludes a colon preceded by a letter, and the URL is not a host path.
- Exception E1 (open): `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md`, written in this run, quotes in its reason paragraph the drive-rooted synthetic value that the fix removed. It names no real host, user, or directory, but it is a drive-shaped value other than the rejection-row token, so the second clause of AC-27 does not hold literally. Evidence is append-only, so the artifact is not edited. This needs an owner decision: accept the quotation as a synthetic value that carries no host data, or authorize a redaction of that one artifact.

## Result

All sub-checks pass except E1. AC-27 and the matching user-story criterion stay unchecked pending the owner decision.

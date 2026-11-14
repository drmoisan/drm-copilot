# Scope and invariant check ([P4-T6], supersedes scope-check.2026-11-13T20-36.md)

Timestamp: 2026-11-14T00-18
Command: sh SCRATCH/issue-1161-scope-check.sh (git fetch origin main; MB = git merge-base origin/main HEAD; git diff --name-only MB HEAD; git diff --name-only --diff-filter=A MB HEAD; git status --porcelain; an extended-regex host-path search over every added file for a drive letter followed by a colon, a separator, and a name character, for a user-profile or home segment followed by a name, for the per-user application-data folder name, and for a tilde home prefix; a count of the drive-only token in the rejection corpus file; a check that each changed path outside the feature folder is named in the plan)
EXIT_CODE: 0
Output Summary: Head 101d8fcb6; merge base equals the origin/main tip; 114 changed paths, 75 added, porcelain empty. Frozen and registration files: 0 of 4 in the diff. All 73 changed paths outside the feature folder are named by the plan. Host-path search: two hits, both in evidence artifacts of this feature. Hit E1 is the accepted non-blocking exception under owner directive OD-10. Hit E2 holds no path; it matches only because a search-token name is quoted. No other added file matches. AC-27 is satisfied apart from the accepted exception E1.

## Anchor

- Merge base of origin/main and HEAD: the origin/main tip (fetched in this run; 0 commits behind).
- `git status --porcelain`: 0 entries before this artifact was written, so no untracked or uncommitted file lies outside the diff.

## Frozen and registration files

`git diff --name-only MB HEAD` lists none of `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.claude/settings.json`, `.codex/config.toml` (result: none).

## Changed file set against the plan

All 73 changed paths outside the feature folder appear in the plan text, by full path or by file name (the 16 corpus fixtures under `tests/fixtures/epic_planner_state_planner_worktrees/`, P1-T1). The script reported no path as `NOT NAMED`. The changed set therefore stays inside the files the plan names, including the updated suites and the helper of `## Existing Test Dispositions`. The three disposition deviations recorded in `scope-check.2026-11-13T20-36.md` (two order-dependence fixes, one added Codex entry-point row, one load-order fix, and the manifest entry position) are unchanged since that record. Each is a related finding that was fixed inside this item.

## Host-path search (AC-27)

- Corpus: `tests/fixtures/epic_planner_state_planner_worktrees/path-drive-prefix.json` holds the drive-only token once (count 1). No separator follows its colon, so the search does not match it, and it is the rejection-row value that AC-27 permits.
- Fixtures, tests, production files, mirrors, and documents: no match.
- E1: `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md`, in its reason paragraph. It quotes the drive-rooted synthetic test value that P4-T6 of the earlier run removed from the test suite. It carries no host data. Disposition: accepted non-blocking exception per owner directive OD-10 (accept_nonblocking_deviation), evidence unedited.
- E2: `evidence/qa-gates/scope-check.2026-11-13T20-36.md`, in its `Command:` field. The match comes only from the application-data folder name, quoted there as a search token. The line holds no path, drive, or user name, so it is not a host path. It is a quotation of a search token that the search then matches. Evidence unedited (append-only). This artifact describes its own search tokens in words so that a re-run does not match it.
- UNC values: the synthetic UNC pair that replaced the removed value in `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1` is neither drive-rooted nor home-directory, and the search does not match it.

## Result

Every sub-check passes. The only drive-shaped value outside the permitted corpus token is E1, which OD-10 accepts as a non-blocking exception. AC-27 holds apart from that accepted exception.

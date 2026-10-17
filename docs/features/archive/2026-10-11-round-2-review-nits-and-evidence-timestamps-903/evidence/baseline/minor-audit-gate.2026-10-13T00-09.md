# Minor-Audit Fail-Closed Gate (P0-T12)

Timestamp: 2026-10-13T00-09
Command: git ls-files -- <FEATURE>/spec.md <FEATURE>/user-story.md ; ls <FEATURE> ; git grep -n -E -e "^## Acceptance Criteria$" -- <FEATURE>/issue.md ; git grep -c -F -e "- [ ] AC-" -- <FEATURE>/issue.md
EXIT_CODE: 0

`<FEATURE>` = `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903`. All commands were run with `git -C <worktree>` from the worktree.

## Check 1 — tracked spec.md / user-story.md

Command: `git ls-files -- <FEATURE>/spec.md <FEATURE>/user-story.md`
EXIT_CODE: 0
Output: (empty)

## Check 2 — feature folder listing

Command: `ls <FEATURE>`
EXIT_CODE: 0
Output:
```
evidence/
issue.md
plan.2026-10-11T10-39.md
research/
```

## Check 3 — exactly one `## Acceptance Criteria` line

Planned command: `git grep -n -x -F -e "## Acceptance Criteria" -- <FEATURE>/issue.md`
Planned-command EXIT_CODE: 129
Planned-command output: `error: unknown switch `x'` followed by the git grep usage text (git version 2.53.0.windows.1; `git grep` has no `-x` option).

Deviation: `git grep` does not support `-x`. The whole-line fixed match was run in the equivalent anchored form `git grep -n -E -e "^## Acceptance Criteria$" -- <FEATURE>/issue.md`, which matches the same set of lines (a line consisting exactly of the heading text; the heading contains no regex metacharacters).

Command: `git grep -n -E -e "^## Acceptance Criteria$" -- <FEATURE>/issue.md`
EXIT_CODE: 0
Output:
```
docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md:29:## Acceptance Criteria
```

## Check 4 — AC checkbox count

Command: `git grep -c -F -e "- [ ] AC-" -- <FEATURE>/issue.md`
EXIT_CODE: 0
Output:
```
docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md:50
```

Output Summary: PASS. No `spec.md` or `user-story.md` is tracked or present in `<FEATURE>`; `issue.md` contains exactly one `## Acceptance Criteria` line (line 29); the AC checkbox count is 50. Deviation: the planned `git grep -x` form exits 129 (unsupported switch); the anchored `-E "^...$"` equivalent was used for check 3.

# Phase 4 Skill-Text Verification — `.claude/skills/cleanup-merged-worktrees/SKILL.md`

Timestamp: 2026-09-08T04-05

Task: [P4-T6]

Command:
`git grep -c -F "<token>" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`, run once per token
for the six tokens transcribed in the table below.

EXIT_CODE: 0

The `EXIT_CODE:` row above is the outcome of this task's verification as a whole and is `0` because
all six searches produced their expected results. The per-command exit codes are transcribed in the
`Exit status` column of the table below rather than as their own rows, because
`scripts/dev_tools/pr_context/verification_evidence.py:122-128` parses every line whose text before
the first colon is exactly `EXIT_CODE` and the last such row wins; a bare row carrying the `396`
search's exit status of 1 would become this artifact's rendered result and the artifact would render
as a failed gate. This file carries exactly one line whose pre-colon text is exactly `EXIT_CODE`.

A fixed-string search that matches nothing prints no line and exits non-zero, so an absence is
recorded below as the absence of a printed line rather than as a printed zero.

## Commands re-run and their observed results

| # | Command | Exit status | Printed output |
| --- | --- | --- | --- |
| 1 | `git grep -c -F "cleanup-worktrees-manifest.json" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 0 | `.claude/skills/cleanup-merged-worktrees/SKILL.md:1` |
| 2 | `git grep -c -F "manifest-authorized removal" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 0 | `.claude/skills/cleanup-merged-worktrees/SKILL.md:1` |
| 3 | `git grep -c -F "Bash(git worktree remove *)" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 0 | `.claude/skills/cleanup-merged-worktrees/SKILL.md:1` |
| 4 | `git grep -c -F "worktree remove --force" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 1 | no output line printed |
| 5 | `git grep -c -F "396" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 1 | no output line printed |
| 6 | `git grep -c -F "cryptographic or security boundary" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 0 | `.claude/skills/cleanup-merged-worktrees/SKILL.md:1` |

`git grep -c` counts matching lines rather than matching occurrences. Search 2's count of 1 is one
matching line carrying two occurrences of the token, both on the source line
`   manifest-authorized removal. A manifest-authorized removal is a single`.

## Additional token presence recorded for AC-32

P4-T1's acceptance requires six further field tokens in addition to the manifest path. Each was
searched with the same command shape and each printed a count of at least 1:
`removal_disposition` (2), `branch_state` (2), `preserved_files` (4), `schema_version` (2),
`generated_at` (2), and `run_id` (2).

## Per-criterion rows

| Acceptance criterion | Search that verifies it | Observed result |
| --- | --- | --- |
| AC-32 | Search 1, plus the six field-token searches recorded above | Count 1 for `cleanup-worktrees-manifest.json`, and a count of at least 1 for each of `removal_disposition`, `branch_state`, `preserved_files`, `schema_version`, `generated_at`, and `run_id`. The new `## Sanctioned Removal Manifest` section specifies the top-level fields, the `removals[]` fields, and the `preserved_files[]` fields as `spec.md` defines them. |
| AC-33 | Search 2 | Count 1. The token was added inside the numbered step 9 of the Dirty Worktree Triage Procedure, confirmed by `git diff d250cf72ee24139735e7f08b07d002ae0e4f1d00 -- .claude/skills/cleanup-merged-worktrees/SKILL.md`, whose hunk `@@ -268,13 +268,20 @@` sits inside that step's `SAFE_TO_DELETE` paragraph. |
| AC-34 | Searches 3 and 4 | Search 3 printed a count of `1`; search 4 printed no output line. The entry `Bash(git worktree remove *)` sits in the YAML frontmatter immediately after `Bash(git worktree list*)`, with no force spelling. The force-flag prohibition is restated inside the step-9 text at the sentence beginning `Never pass a force flag to that command`. |
| AC-35 | Search 5 | Printed no output line: the literal `396` no longer occurs anywhere in the file. The replacement paragraph names `.claude/skills/pr-author/SKILL.md` and defers the body-file and receipt contract to it. |
| AC-36 | Search 6 | Count 1. The `### Accepted residual` subsection records the `bash <file>` indirection using the `enforce-pr-author-skill.ps1` posture and states that this design does not close that indirection. |

## Line-number correction recorded during execution

The plan's P4-T3 text cites `SKILL.md:236-237` as the location of the existing force-flag
prohibition. That is its location on `main`. On this branch it sits at `:294-295` in the pre-change
file, moved by issue 545's merge into the epic integration branch. The prohibition was read at the
branch location and restated using its wording, which names the flag only as "a force flag" rather
than spelling it literally, so search 4's absence assertion remains satisfiable. The two acceptance
searches for P4-T3 are locator-independent and were unaffected.

## Scope boundaries observed

No text added in Phase 4 asserts that the `bash <file>` indirection is closed, prevented, or
blocked, and no text asserts a permission-layer block. Both absences are required by `spec.md` D8
and D3.

Output Summary: All six searches re-run and all six produced their expected results. Searches 1, 2,
3, and 6 each printed a count of `1`; searches 4 and 5 each printed no output line and reported exit
status 1, which is the expected form for a fixed-string search that matches nothing. AC-32, AC-33,
AC-34, AC-35, and AC-36 are each verified by the rows above. `SKILL.md` grew from 332 lines to 472
lines; Markdown is exempt from the 500-line cap under `.claude/rules/general-code-change.md`.

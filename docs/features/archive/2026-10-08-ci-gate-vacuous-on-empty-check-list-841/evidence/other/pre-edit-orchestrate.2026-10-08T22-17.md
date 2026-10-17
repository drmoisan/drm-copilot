# Pre-Edit Re-Read of Orchestrate S9 (#841, P3-T1)

Timestamp: 2026-10-10T09-25
Command: git grep -c -F -e 'check must succeed before' -- .claude/skills/orchestrate/SKILL.md; git grep -c -F -e 'when all required checks pass' -- .claude/skills/orchestrate/SKILL.md; git grep -c -F -e 'that the required checks were observed against' -- .claude/skills/orchestrate/SKILL.md; git fetch origin main; git log --oneline HEAD..origin/main -- .claude/skills/orchestrate/SKILL.md
EXIT_CODE: 0
Output Summary:
- `check must succeed before` -> `.claude/skills/orchestrate/SKILL.md:1`
- `when all required checks pass` -> `.claude/skills/orchestrate/SKILL.md:1`
- `that the required checks were observed against` -> `.claude/skills/orchestrate/SKILL.md:1`
- `git fetch origin main` -> exit 0 (`* branch main -> FETCH_HEAD`)
- `git log --oneline HEAD..origin/main -- .claude/skills/orchestrate/SKILL.md` -> no output (no commit on main touches this file beyond HEAD; no #798 conflict indicated)
- All three counts are 1; the Appendix E anchors match the current text. No stop.

Route: git commands ran exactly as written.

## Line positions (current tree, after the origin/main merge reconciliation)

`## Step S9 — CI Green Gate` line 283; epic-child paragraph line 292; step 3 line 294; `## Checkpoint Schema — CI Gate Fields` line 303; `head_sha` bullet line 308; `## Remediation Loop — CI-Failure Handling` line 341. These are each +1 from the plan's recorded positions, as stated in the delegation's merge-reconciliation note.

## Verbatim quotes

Step 2 epic-child paragraph (line 292):

> Epic-child rule: when the PR base branch is an `epic/<slug>-integration` branch (checkpoint `epic_mode` is `true`), run the step 2 query without `--required`, because integration branches carry no required-status-check protection and `--required` then returns an empty set. An empty check list, including an empty `gh pr checks --required` result, is not accepted as green for such a PR: the gate must observe at least one check whose `workflow` is `CI` against the child head SHA, and every observed `CI` check must succeed before `ci_gate.conclusion` is accepted as `success`.

Step 3 line (line 294):

> 3. Parse the JSON by running `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <head-sha>`, which emits the `ci_gate` object defined below and derives `ci_gate.conclusion` as `success` when all required checks pass, `failure` when any required check failed, and `pending` when any required check is still in progress.

`head_sha` schema bullet (line 308):

>   - `head_sha` — the PR head SHA that the required checks were observed against.

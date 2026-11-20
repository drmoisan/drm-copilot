# QA Gate — Minor-Audit Document-Set Invariant (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T9]
Folder under verification: `docs/features/active/2026-08-28-atomic-preflight-convergence-586/`

The invariant is the `minor-audit` clause of `## Mode-Specific Mandatory Plan Gates` in `.claude/skills/atomic-plan-contract/SKILL.md`: execution fails closed when `spec.md` or `user-story.md` exists unexpectedly in the active folder, or when the explicit `## Acceptance Criteria` section is missing from `issue.md`. Three commands are recorded.

## Command 1 — folder listing

Command: ls docs/features/active/2026-08-28-atomic-preflight-convergence-586/

EXIT_CODE: 0

Output Summary:

The command printed three entries:

```
evidence/
issue.md
plan.2026-08-28T20-02.md
```

Neither `spec.md` nor `user-story.md` is present. The `minor-audit` fail-closed condition on unexpected full-mode documents does not fire. `research.md` is also absent; per the plan's `## Requirements Source` section, `research.md` is not named by the `minor-audit` clause and is neither a fail-closed condition nor checked by this task.

## Command 2 — explicit acceptance-criteria section present

Command: grep -c -F -e "## Acceptance Criteria" docs/features/active/2026-08-28-atomic-preflight-convergence-586/issue.md

EXIT_CODE: 0

Output Summary:

The command printed `1`. The explicit `## Acceptance Criteria` section required of a `minor-audit` plan is present exactly once in `issue.md`, so it is unambiguous as the sole AC source. The fail-closed condition on a missing acceptance-criteria section does not fire.

## Command 3 — work-mode marker present

Command: grep -c -F -e "- Work Mode: minor-audit" docs/features/active/2026-08-28-atomic-preflight-convergence-586/issue.md

EXIT_CODE: 0

Output Summary:

The command printed `1`. The persisted work-mode marker resolving this feature to `minor-audit` is present exactly once, which satisfies item 1 of `## Mode source precedence (Mandatory)` and means the mode does not fall through to the `full-feature` fail-closed default.

## Tool Choice Note

`grep` is used for commands 2 and 3 rather than `git grep`. A pattern beginning with `-` is read by `git grep` as an option and exits 129 unless introduced with `-e`; the `-e` form is used with `grep` for the same reason. `git grep` would also resolve here, since the feature folder is tracked as of commit `56dcad93`, but `grep` reads the working-tree file directly and does not depend on the folder's tracked state, which is the property this invariant check needs.

## Ordering Note

[P2-T8] ran before this task and rewrote five leading `- [ ]` markers to `- [x]` in the `## Acceptance Criteria` section of the same `issue.md`. Neither search above targets a criterion line: command 2 targets the `## Acceptance Criteria` heading line and command 3 targets the `- Work Mode: minor-audit` metadata line, and [P2-T8] modified neither. Both counts are therefore the same whether this task runs before or after [P2-T8].

## Verdict

All three commands exited 0. Neither `spec.md` nor `user-story.md` is present; both searches printed `1`. The invariant holds and no fail-closed condition fires. Gate passes.

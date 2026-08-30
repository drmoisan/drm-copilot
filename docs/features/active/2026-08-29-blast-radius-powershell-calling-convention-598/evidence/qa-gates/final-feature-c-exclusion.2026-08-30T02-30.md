# Feature C exclusion verified against FAS — issue #598

Timestamp: 2026-08-30T02-30
Task: [P10-T8]

Ref values substituted from `evidence/baseline/git-postmerge-baseline.2026-08-29T23-10.md`, written
by `[P0-T11]`: `BaseRef:` `main`, `PreMergeRef:`
`6942dee8e10720693d55ccb5f121b2446862d6f8`, `MergeRef:` `f4d4f958808a5a420f11189f6fa02ee007a66525`.

The pathspec used by the first two commands, six paths:

```
.claude/skills/parallel-plan/SKILL.md
.claude/skills/parallel-add/SKILL.md
.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
```

Command:
1. `git diff --name-only main...6942dee8e10720693d55ccb5f121b2446862d6f8 -- <that pathspec>`
2. `git diff --name-only f4d4f958808a5a420f11189f6fa02ee007a66525..HEAD -- <that pathspec>`
3. `git status --porcelain`

EXIT_CODE: 0

All three commands exited 0.

Output Summary:

Command 1 (`FAS` span 1) printed no line. Output is empty.

Command 2 (`FAS` span 2) printed no line. Output is empty.

Command 3 (`FAS` span 3) printed 10 entries, all of them this feature's own plan file and its Phase 9
and Phase 10 evidence artifacts:

```
 M docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/plan.2026-08-29T16-05.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-bundle-parity.2026-08-30T02-28.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-line-coverage.2026-08-30T02-24.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-mirror-parity.2026-08-30T02-29.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-per-module-coverage.2026-08-30T02-26.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-pester-suite.2026-08-30T02-22.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-poshqc-analyze.2026-08-30T02-18.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/final-poshqc-format.2026-08-30T02-17.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-change-set-exclusion.2026-08-30T02-15.md
?? docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/item3-truthiness-verification.2026-08-30T02-14.md
```

None of those 10 entries is one of the six Feature C paths.

## Why the porcelain span is required

An anchored name-listing diff enumerates tracked changes only and cannot report a newly created
untracked path, so the two diffs alone could not detect a Feature C file this feature created but
had not committed. Command 3 covers that case. Command 3 is run without a pathspec here, so its
output also serves as the full uncommitted-and-untracked component of `FAS` for `[P10-T10]`.

## Why the two-span form replaces `<BaseRef>...HEAD`

`main` is an ancestor of the merged-in branch, so a `main...HEAD` span now also reports every file
the merge brought in. The `MAS` list recorded by `[P0-T11]` contains
`.claude/skills/parallel-add/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` together with
their bundle mirrors: those are merged-in modifications made by a sibling feature, and a
`main...HEAD` span would report them as though this feature had made them. They are in `MAS` and
absent from `FAS`, which is the correct classification under the attribution contract.

## Acceptance evaluation

- Both diff outputs are empty.
- The porcelain output names none of the six Feature C paths.

Both acceptance conditions hold. This feature made no change to the Feature C surface.

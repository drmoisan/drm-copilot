# Item-3 change-set exclusion — issue #598

Timestamp: 2026-08-30T02-15
Task: [P9-T2]

Ref values substituted from `evidence/baseline/git-postmerge-baseline.2026-08-29T23-10.md`, written
by `[P0-T11]`:

- `BaseRef:` `main`
- `PreMergeRef:` `6942dee8e10720693d55ccb5f121b2446862d6f8`
- `MergeRef:` `f4d4f958808a5a420f11189f6fa02ee007a66525`

Command:
1. `git diff --name-only main...6942dee8e10720693d55ccb5f121b2446862d6f8 -- tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 .claude/lib/blast-radius/BlastRadius.psm1`
2. `git diff --name-only f4d4f958808a5a420f11189f6fa02ee007a66525..HEAD -- tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 .claude/lib/blast-radius/BlastRadius.psm1`
3. `git status --porcelain -- tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 .claude/lib/blast-radius/BlastRadius.psm1`
4. `git diff --name-status f4d4f958808a5a420f11189f6fa02ee007a66525..HEAD -- .claude/lib/blast-radius/BlastRadius.psm1`

EXIT_CODE: 0

All four commands exited 0.

Output Summary:

Command 1 (`FAS` span 1, pre-merge feature commits) printed no line. Output is empty.

Command 2 (`FAS` span 2, post-merge feature commits) printed exactly one line:

```
.claude/lib/blast-radius/BlastRadius.psm1
```

Command 3 (`FAS` span 3, uncommitted and untracked) printed no line. Output is empty. HEAD is
`2f4d8292e7217e0901f2e6adeb72cc20e48676b5` and the worktree is clean for these two pathspecs.

Command 4 printed exactly one line, verbatim, with a tab between the status field and the path:

```
M	.claude/lib/blast-radius/BlastRadius.psm1
```

The status field is `M`. `--name-only` prints no status field, which is why command 4 is required
to distinguish a modification from a deletion.

## Span complementarity

Agreement between the three `FAS` spans is not required and is not asserted here. They are
complementary by construction: the two anchored diffs report committed changes only and are blind to
untracked paths, and the porcelain span goes empty for any path already committed. The empty
command 3 output is therefore the expected result on a clean tree at a committed HEAD, and it does
not contradict command 2.

`.claude/lib/blast-radius/BlastRadius.psm1` appears on span 2 and not on span 1 because batch B13,
which applies the item-1 guard to it, was committed after the merge.

## Formatter-drift exception branch

The exception branch of this task's acceptance does not fire.
`evidence/baseline/poshqc-format-postmerge.2026-08-29T23-10.md:32`, written by `[P0-T14]`, records
`CombinedPreExistingFormatterDrift: none`. The drift list is empty, so it names
`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` on no line and no drift entry
needs to be quoted here.

## Acceptance evaluation

- Neither diff output names `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1`
  on any line. Command 1 is empty; command 2 names only `.claude/lib/blast-radius/BlastRadius.psm1`.
- The porcelain output names that test file on no line. Command 3 is empty.
- `.claude/lib/blast-radius/BlastRadius.psm1` appears on at least one of the three spans: it appears
  on span 2.
- Command 4 printed exactly one line and its status field is `M`.

All acceptance conditions hold. The item-3 test file is absent from `FAS`, so this feature made no
change to it, which is the exclusion the spec's item-3 criteria require.

# D6 Must-Not-Touch List Intact In Both Gate Hooks

Timestamp: 2026-09-08T04-17

Task: [P7-T4]

Command:
`git diff --unified=0 d250cf72ee24139735e7f08b07d002ae0e4f1d00 -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
`git status --porcelain -- .claude/hooks`

EXIT_CODE: 0

## Anchor choice

The comparison point is `d250cf72ee24139735e7f08b07d002ae0e4f1d00`, compared against the working
tree. The three-dot form is not used: it compares against the commit `HEAD`, which on this
uncommitted tree is that same commit, so it would emit no hunks at all and the check would pass
vacuously. The merge base with `main` is not used either: it predates issue 545's edits to both gate
hooks, and the resulting hunks would overlap protected constructs this feature never touched.

## Hunk inventory

Six hunks, three per file. Every hunk header carries the `-N,0` form, which means **zero lines were
removed from either file**. Every change is a pure insertion.

| File | Hunk header | New-file lines inserted | Content |
| --- | --- | --- | --- |
| epic gate | `@@ -62,0 +63,3 @@` | 63-65 | Comment pair plus the manifest-module `Import-Module` |
| epic gate | `@@ -69,0 +73,4 @@` | 73-76 | Comment block plus `$script:CleanupWorktreeManifestPath` |
| epic gate | `@@ -390,0 +398,16 @@` | 398-413 | Comment block plus the manifest authorization branch |
| parallel gate | `@@ -32,0 +33,3 @@` | 33-35 | Comment pair plus the manifest-module `Import-Module` |
| parallel gate | `@@ -40,0 +44,4 @@` | 44-47 | Comment block plus `$script:CleanupWorktreeManifestPath` |
| parallel gate | `@@ -259,0 +267,15 @@` | 267-281 | Comment block plus the manifest authorization branch |

Hunk count per file: **3** for `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and **3** for
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.

Line-count corroboration. The epic gate measured 444 lines by `wc -l` at P0-T2 and measures 467 now;
444 + 3 + 4 + 16 = 467. The parallel gate measured 313 at P0-T3 and measures 335 now;
313 + 3 + 4 + 15 = 335. Both totals are accounted for entirely by the recorded insertions, so no
line was silently replaced.

## Porcelain companion

```text
 M .claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
```

Exit status 0. The companion is scoped to the whole `.claude/hooks` directory, so it would report an
untracked hook file added anywhere under it. It lists exactly the two files this phase expects to be
modified and no other, which confirms that no third hook file was created or changed.

Both subsidiary commands exited with exit status 0. Those statuses are transcribed in this wording
rather than as their own `EXIT_CODE:` rows because
`scripts/dev_tools/pr_context/verification_evidence.py:122-128` takes the last row whose text
before the first colon is exactly `EXIT_CODE` as the artifact's rendered result. This file carries
exactly one such line, the `EXIT_CODE: 0` row above.

## Protected constructs, re-derived in this task

Every line number in the re-derived column below was re-derived against the current working tree in
this task, not carried forward from P0-T2 or P0-T3.

The base column records the pre-change value for comparison. P0-T2 and P0-T3 recorded only their six
named anchors each, so the base value for every other protected construct was **read directly out of
the anchor commit's copy of each file** in this task rather than computed by subtracting an offset:

`git show d250cf72ee24139735e7f08b07d002ae0e4f1d00:.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
`git show d250cf72ee24139735e7f08b07d002ae0e4f1d00:.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

Both `git show` invocations exited with exit status 0. Where a construct is one of the six anchors,
the value read here agrees with the value P0-T2 or P0-T3 recorded, which is noted in the table. The
drift between the two columns equals the number of inserted lines that precede each construct:
+7 for an epic-gate construct below line 69 of the base file and +23 for one below line 390; +7 for a
parallel-gate construct below line 40 of the base file and +22 for one below line 259.

### `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (467 lines)

| Protected construct | Base line (anchor commit) | Re-derived line / span | Inside any hunk? |
| --- | --- | --- | --- |
| Detection helper `Get-EpicWorktreeRemovalCommandPath`, whole body | 135-174 | **142-181** | No |
| Structural operand read inside that body (`Test-CommandLineFlag`, `Get-CommandLineOperand`) | 164-165 | **171-172** | No |
| Trigger guard (`Test-CommandLineInvocation` with subcommand path `worktree`, `remove`) | 373 | **380** | No |
| Deny reason string, final return | 391 (agrees with P0-T2 anchor 6) | **414** | No |
| Decision constructor `Get-EpicWorktreeGateAllowDecision` | 312-323 | **319-330** | No |
| Decision constructor `Get-EpicWorktreeGateBlockDecision` | 325-340 | **332-347** | No |
| Entry point `Invoke-EpicWorktreeRemovalGateEntryPoint` | 394-430 | **417-453** | No |
| Thin tail (dot-source guard through the `exit` statement) | 432-445 | **455-468** | No |
| `$script:AllowedMergeStatuses` assignment | 69 (agrees with P0-T2 anchor 2) | **72** | No |

### `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (335 lines)

| Protected construct | Base line (anchor commit) | Re-derived line / span | Inside any hunk? |
| --- | --- | --- | --- |
| Detection helper `Get-ParallelWorktreeRemovalCommandPath`, whole body | 60-104 | **67-111** | No |
| Structural operand read inside that body (`Test-CommandLineFlag`, `Get-CommandLineOperand`) | 94-95 | **101-102** | No |
| Trigger guard (`Test-CommandLineInvocation` with subcommand path `worktree`, `remove`) | 239 | **246** | No |
| Deny reason string, final return | 260 (agrees with P0-T3 anchor 6) | **282** | No |
| Decision constructor `Get-ParallelWorktreeGateAllowDecision` | 178-189 | **185-196** | No |
| Decision constructor `Get-ParallelWorktreeGateBlockDecision` | 191-206 | **198-213** | No |
| Entry point `Invoke-ParallelWorktreeRemovalGateEntryPoint` | 263-299 | **285-321** | No |
| Thin tail (dot-source guard through the `exit` statement) | 301-314 | **323-336** | No |
| `$script:AllowedMergeStatuses` assignment | 40 (agrees with P0-T3 anchor 2) | **43** | No |

### Overlap determination

The epic gate's inserted line ranges are 63-65, 73-76 and 398-413. None of them intersects any span
in the epic table above: 63-65 and 73-76 sit between the pre-existing `Import-Module` at 62 and the
first function definition at 78, and 398-413 sits between the second positive-predicate block that
closes at 396 and the final deny return at 414.

The parallel gate's inserted line ranges are 33-35, 44-47 and 267-281. None of them intersects any
span in the parallel table above: 33-35 and 44-47 sit between the pre-existing `Import-Module` at 32
and the first function definition at 49, and 267-281 sits between the positive-predicate block that
closes at 265 and the final deny return at 282.

**No hunk in either file contains any protected line.**

## Recorded state of the extraction regex and its trim call

`spec.md` D6 names the extraction regex strings and their trim calls as protected. A search of both
hooks in the current tree for a case-insensitive inline regex option token and for a `.Trim(` call
returns no match in either file. Issue 545, already merged into the epic integration tip this branch
is based on, replaced the raw-text regex extraction with the structural helpers
`Test-CommandLineFlag`, `Get-CommandLineOperand`, and `Test-CommandLineInvocation`. The protected
role — resolving the removal target from the command text — is therefore now carried by the helper
call sites recorded in the tables above, and those call sites are unchanged by this feature. The
absence of the regex literal is 545's merged state at the anchor commit, not a change this feature
made: the anchored diff reports zero deleted lines in both files, so this feature removed nothing
from either. The same search run against the anchor commit's own copy of each file, obtained through
`git show`, also returns a match count of 0 for both files, which confirms the construct was already
absent before this feature made any edit rather than having been removed here.

The two deny reason strings were compared against the `Deny Reason Verbatim:` blocks recorded by
P0-T2 and P0-T3 and are unchanged character for character. That is corroborated mechanically by the
zero-deletion property of every hunk: a reason-string edit would appear as a deleted line.

Output Summary: The anchored `--unified=0` diff produced 3 hunks for the epic gate and 3 for the
parallel gate, all six carrying the `-N,0` pure-insertion form, so zero lines were deleted from
either file. Every protected construct named by `spec.md` D6 was re-derived against the current tree
in this task and recorded beside its P0 value; no inserted line range intersects any protected span
in either file. The two deny reason strings match their P0 verbatim records. The extraction regex
and its trim call no longer exist in either hook as a consequence of issue 545's merged change at
the anchor commit, and the structural helper call sites that replaced them are unchanged here.
Satisfies AC-31.

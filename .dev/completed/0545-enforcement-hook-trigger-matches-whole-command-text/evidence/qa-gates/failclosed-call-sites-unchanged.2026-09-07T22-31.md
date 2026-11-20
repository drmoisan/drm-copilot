# Final QA — the six fail-closed-correct call sites are byte-unchanged

Task: `[P5-T3]`
Timestamp: 2026-09-07T22-31

Anchor: the **cycle-scope** anchor `26dba29533ba70f6cd80d14ac3c87ac24ca82aca`. This task asks what
cycle 2 changed, so the cycle-scope anchor is the correct base. The feature-wide anchor is used only
by `[P5-T5]`.

Command, run once per file:
`git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- <file>`
For the two edited files the diff was additionally taken with `-U0` so hunk boundaries are exact
rather than padded by three lines of context.

EXIT_CODE: 0

## The six-row determination

Enclosing-function boundaries are the ones `[P0-T10]` recorded. For the two edited files the
boundaries were re-derived against the current tree with `grep -n '^function '`, so the row states
where the function sits now, not where it sat before the edits.

| # | File | Enclosing function | Hunk boundaries from the anchored diff | Function body outside every hunk |
|---|---|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:164` | `Get-EpicWorktreeRemovalCommandPath`, lines 135–175 | none — the anchored diff produced no output for this file | yes, vacuously: the file has no hunk |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:94` | `Get-ParallelWorktreeRemovalCommandPath`, lines 60–105 | none — no output | yes, vacuously |
| 3 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:58` | `Get-CodexWorktreeRemovalPath`, lines 36–69 | none — no output | yes, vacuously |
| 4 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:109` | `Test-EpicBaseBranchOverride`, lines 45–115 | none — no output | yes, vacuously |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1:169` | `Get-EpicMergeGateCommandPrNumber`, lines 131–176 | two hunks, both inside `Invoke-EpicMergeGateDecision` (starts line 357): `@@ -395,0 +396,5 @@` and `@@ -397,0 +403,9 @@` | yes — lowest changed line is 396, which is 220 lines below the function's last line 176 |
| 6 | `.codex/hooks/enforce-epic-merge-gate.ps1:61` | `Get-CodexMergeCommandPrNumber`, lines 34–68 | two hunks, both inside `Invoke-CodexEpicMergeDecision` (starts line 114): `@@ -129 +129,4 @@` and `@@ -131,0 +135,9 @@` | yes — lowest changed line is 129, which is 61 lines below the function's last line 68 |

No `+` or `-` line falls inside any of the six function bodies.

## Rows 1 through 4 — the four files this cycle does not edit

Command:
`git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 .codex/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
EXIT_CODE: 0

```
(no output)
```

The anchored diff produced no output at all for all four files, which is what this task requires of
them.

## Rows 5 and 6 — the two files this cycle edits

Both edits land in the gate's decision function, not in the PR-number resolver. Full `-U0` diffs:

`.claude/hooks/enforce-epic-merge-gate.ps1`:

```
@@ -395,0 +396,5 @@ function Invoke-EpicMergeGateDecision {
+    #
+    # The flag leg needs a raw-scan fallback: a wrapper's quoted argument collapses into ONE
+    # token, so a flag inside it is never read as a token, and the token-only read took
+    # bash -c "gh pr merge --merge 688" out of scope. The fallback reads only the segments the
+    # scanner already scans raw, so a masked mention in a non-wrapper segment stays out.
@@ -397,0 +403,9 @@ function Invoke-EpicMergeGateDecision {
+    if (-not $hasMergeFlag) {
+        foreach ($segment in @(Read-CommandLineSegment -CommandText $commandText)) {
+            if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
+                $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
+                $hasMergeFlag = $true
+                break
+            }
+        }
+    }
```

14 insertions, 0 deletions. Every hunk carries the `Invoke-EpicMergeGateDecision` function context
marker supplied by `git diff` itself, which is independent confirmation that no hunk lies in
`Get-EpicMergeGateCommandPrNumber`.

`.codex/hooks/enforce-epic-merge-gate.ps1`:

```
@@ -129 +129,4 @@ function Invoke-CodexEpicMergeDecision {
-    # quoted mention of the phrase no longer brings a command into scope.
+    # quoted mention of the phrase no longer brings a command into scope. The flag leg needs
+    # a raw-scan fallback: a wrapper's quoted argument collapses into ONE token, so a flag
+    # inside it is never read as a token, and the token-only read took
+    # bash -c "gh pr merge --merge 688" out of scope.
@@ -131,0 +135,9 @@ function Invoke-CodexEpicMergeDecision {
+    if (-not $hasMergeFlag) {
+        foreach ($segment in @(Read-CommandLineSegment -CommandText $command)) {
+            if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
+                $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
+                $hasMergeFlag = $true
+                break
+            }
+        }
+    }
```

The single `-` line in either file is at line 129 of the Codex copy. It is a comment line inside
`Invoke-CodexEpicMergeDecision` that the edit superseded by continuing the same sentence across four
lines; it is 61 lines below the last line of `Get-CodexMergeCommandPrNumber` and carries no code.

## Independent confirmation — the six reader lines read back unchanged

Command: `sed -n '<line>p' <file>` for each of the six.
EXIT_CODE: 0

| # | Call site | Observed line |
|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:164` | `$hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:94` | `$hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| 3 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:58` | `$hasForce = Test-CommandLineFlag -CommandText $Command -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| 4 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:109` | `$baseValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--base'` |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1:169` | `$flagValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'` |
| 6 | `.codex/hooks/enforce-epic-merge-gate.ps1:61` | `$flagValue = Get-CommandLineFlagValue -CommandText $Command -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'` |

Every reader is still at the line number the Scope table records and reads exactly as the Scope
table records it. Sites 5 and 6 are still at 169 and 61 respectively, which additionally shows the
edits sit below them and shifted nothing above them.

## Binding prohibition

`Test-CommandLineFlag` and `Get-CommandLineFlagValue` in `hook-command-invocation.ps1` were not
changed on either runtime. Neither file appears in this cycle's changed-file set (see `[P5-T4]`).
The fix was applied at the four fail-open call sites only, so the six fail-closed-correct readers
above continue to receive `$null`/`$false` on an unreadable flag and continue to deny.

## Output Summary

All six fail-closed-correct call sites are byte-unchanged. The four files this cycle does not edit
produce no anchored-diff output at all. The two files it does edit carry hunks only inside their
decision functions — lowest changed line 396 in the Claude copy versus a function ending at 176, and
129 in the Codex copy versus a function ending at 68 — so no `+` or `-` line falls inside any of the
six function bodies. All six reader lines read back verbatim at their recorded line numbers.

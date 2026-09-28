# AC-19 and AC-20 Byte-Identity Verification (issue #673)

Timestamp: 2026-09-19T19-16

Command: `git diff b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD -- tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`, then the same diff filtered to lines containing an `It '` or a `Should ` token.

EXIT_CODE: 0

## `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`

**The diff is empty** — `git diff` produced zero lines of output. This file is byte-identical to its state at the merge base.

That is the outcome RS-8 predicted: its end-to-end row resolves `NoTarget` in a real child process, so it never reads the script-variable pin at `:97`, and no edit was needed to keep it passing after the pin's declaration became null. Three of AC-19's seven protected rows live here and all three are untouched.

## `enforce-model-routing-receipt.Tests.ps1`

The diff contains **only the `[P7-T3]` insertion**: nine added lines and zero removed lines.

```
+    # Issue #673 routes the checkpoint through a resolution seam. Defaulting it to the
+    # session root keeps these rows exercising presence gating, and independent of
+    # whichever worktrees exist on the machine running them.
+    BeforeEach {
+        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith {
+            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
+        }
+    }
+
```

This is AC-19 edit form (c), the form #687 itself used on the two pr-author suites. Three of AC-19's seven protected rows live in this file and every one is byte-identical: no existing line appears with a leading minus.

AC-20 is satisfied by the same observation. All six decision branches of the model-routing gate keep their semantics, and this suite — which covers the envelope-anomaly branch, the scope filter, the orchestrator exclusion, the receipt-present allow, and the two fail-closed reader cases — passes with no assertion weakened, reordered, or removed, because no assertion line changed at all.

## `enforce-pr-author-skill.epic-base-branch.Tests.ps1`

The diff contains **only the seven `[P5-T6]` argument additions**. Each is a paired removal and addition of the same line, differing by one appended argument, rendered here as `<APPENDED-ARG>` for the literal ` -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')`:

```
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
-            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
+            $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' <APPENDED-ARG>
```

The unrendered literal is quoted in full in `evidence/regression-testing/r3-protected-row-edits.md`, which records all nine of this plan's form-(a) edits, seven here and two in the trigger-scoping sibling.

## Per-row verdict

| # | Protected row | File | Verdict |
| --- | --- | --- | --- |
| 1 | `:26-37` at spec, now `:35-46` | `OrchestratorStatePreflight.Tests.ps1` | byte-identical |
| 2 | `:39-51` at spec, now `:48-60` | `OrchestratorStatePreflight.Tests.ps1` | byte-identical |
| 3 | `:64-102` at spec, now `:73-115` | `OrchestratorStatePreflight.Tests.ps1` | byte-identical |
| 4 | `:62-68` | `enforce-model-routing-receipt.Tests.ps1` | byte-identical; only an insertion above it |
| 5 | `:71-92` | `enforce-model-routing-receipt.Tests.ps1` | byte-identical; only an insertion above it |
| 6 | `:20-58` | `enforce-model-routing-receipt.Tests.ps1` | byte-identical; only an insertion above it |
| 7 | `:22-42` at spec, now `:31-51` | `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | two call lines gained the appended argument; every assertion byte-identical |

## No `It` name and no `Should` line changed

Filtering the combined diff to lines carrying an `It '` or a `Should ` token returns **0 lines**. No row was renamed, and no assertion was added, weakened, reordered, or removed in any of the three files.

Output Summary: All four acceptance conditions hold. The diff for `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` is empty; the diff for `enforce-model-routing-receipt.Tests.ps1` contains only the nine-line `[P7-T3]` insertion with no removals; the diff for `enforce-pr-author-skill.epic-base-branch.Tests.ps1` contains only the seven `[P5-T6]` argument additions, each differing from its before-line by one appended argument; and no line carrying an `It` name or a `Should` assertion changed in any of the three files.

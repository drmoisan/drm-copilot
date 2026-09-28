# The #518 four-segment slice survived the Phase 2 edits byte-unmodified

Timestamp: 2026-09-17T13-56

Task: `[P2-T6]` of `remediation-plan.2026-09-17T12-29.md`
Criterion this protects: criterion 20 (`spec.md` line 639), which requires the #518 depth-insensitivity fix to
survive.

## Corrected citation, carried by this task

The remediation inputs and the delivery plan locate the byte-unmodified #518 slice at
`.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 272-277. That citation is **stale after the
helpers extraction**. Re-derived against the current tree: lines 272-277 of the parent hook are not the slice.
The slice lives in `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, inside
`ConvertTo-PrdFeatureFolderToken`.

Measured positions in the current tree, after this phase's edits:

- `ConvertTo-PrdFeatureFolderToken` begins at line **98**.
- `if ($segments.Count -lt 4) {` is at line **156**.
- `$segments[0..3]` is at line **160**.

The plan cites the slice at lines 142-154 pre-edit and `[P0-T4]` measured `$segments[0..3]` at line **154**
before any file was touched. It now sits at line 160, a shift of exactly **+6** lines, which is the number of
lines `[P2-T5]` added to the file-level help block above it. The shift is positional only; the slice's text is
unchanged.

Command:

- `Select-String -SimpleMatch -Pattern '$segments[0..3]' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'`
- `Select-String -SimpleMatch -Pattern 'if ($segments.Count -lt 4) {' -Path '.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1'`
- `git merge-base --is-ancestor 1b150689c2d6bbda848ae10ec92e4ccc018a5560 HEAD`
- `git diff 1b150689c2d6bbda848ae10ec92e4ccc018a5560 -- .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`

EXIT_CODE: 0

- `git merge-base --is-ancestor` exit code: **0**.
- `git diff` exit code: 0.
- Both `Select-String` invocations exit code: 0.

Anchor precondition: `<baselineHead>` is bound to `1b150689c2d6bbda848ae10ec92e4ccc018a5560`, the commit
`[P0-T2]` recorded. The ancestry check exits 0, so the halt branch stated in `[P1-T5]` is not taken and the
diff spans this remediation's change set only.

Output Summary:

## Slice searches

| asserted token | count | line | required |
| --- | --- | --- | --- |
| `$segments[0..3]` | **1** | 160 | exactly 1 |
| `if ($segments.Count -lt 4) {` | **1** | 156 | exactly 1 |

Both searches return exactly one match. `-SimpleMatch` is mandatory on both: `$segments[0..3]` contains `$`,
`[`, `.`, and `]`, and `if ($segments.Count -lt 4) {` contains `(`, `.`, and `{`, so without it neither token
would match anything the file contains.

## Anchored diff — verbatim, the whole diff for this file

```
diff --git a/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 b/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
index 27c4a25c..d3130044 100644
--- a/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
+++ b/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
@@ -10,7 +10,13 @@
     cap as target resolution grows.

     The file declares no file-scope parameter block, no requires directive, and no
-    entrypoint. It is loaded for its declarations only.
+    entrypoint. Apart from its function declarations,
+    its only file-scope statement is the resolution-module import
+    that follows this block, which brings in issue #669's path normalisation and
+    ambiguity reason code. That import is deliberately unguarded, for the same
+    reason the parent hook's is: a resolution module that cannot be loaded is
+    itself the target-not-resolvable state, so letting the failure surface fails
+    the gate closed rather than degrading it to a permissive path.
 .NOTES
     Compatible with PowerShell 7+. Read-only resolution logic.
 #>
```

The diff is a **single hunk** beginning at line 10 and spanning 7 lines of the post-change file. The
file-level comment-based-help block runs from line 1 to the `#>` terminator, so every added and removed line
in the diff lies wholly inside it. The hunk's last two unchanged context lines are the `.NOTES` line and the
`#>` terminator, which bound the help block and confirm the hunk does not extend past it.

**No hunk touches `ConvertTo-PrdFeatureFolderToken`.** That function begins at line 98, 76 lines after the
single hunk ends, and the diff contains exactly one hunk. The `Import-Module` statement, which the plan also
requires to be untouched, is likewise absent from the diff: it sits below the `#>` terminator and is unchanged.

## `[P2-T5]` acceptance, verified in the same run

| asserted token | count | line | required |
| --- | --- | --- | --- |
| `It is loaded for its declarations only` | **0** | none | 0 against a recorded pre-change count of 1 |
| `its only file-scope statement is the resolution-module import` | **1** | 14 | exactly 1 |

The pre-change count of 1, at line 13, is the value `[P0-T4]` measured before any file was edited.

The replacement also states in the same paragraph that the import is deliberately unguarded so an unloadable
module fails the gate closed, which `[P2-T5]` requires. That wording is visible in the diff above.

## File size

The helpers sibling measures **320** physical lines, against 314 before Phase 2 and a 500-line cap. The +6
change is the help-block replacement. Headroom remaining: 180 lines. `[P2-T7]` records the measurement
formally.

Acceptance: each search returns exactly 1 match, and the diff's added and removed lines lie wholly inside the
file-level comment-based-help block with no hunk touching `ConvertTo-PrdFeatureFolderToken`. Satisfied.

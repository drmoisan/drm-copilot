# Diff Confinement — Helpers File (issue #671)

Timestamp: 2026-09-17T08-18
Task: [P5-T4]
Command: git -C <worktree root> status --porcelain ; git -C <worktree root> diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 ; git -C <worktree root> diff --merge-base main --unified=0 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 ; SHA256 of the canonical helpers file
EXIT_CODE: 0

Output Summary:
- Removed content lines: 3. All three are the pre-change comment at lines 227-229, which lies inside the pre-change 227-236 block quoted in the research artifact (R1).
- No hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks. Hunks 1 and 2 are pure insertions; hunk 1 is placed after the `$script:PathspecWildcardCharacters` block, and hunk 2 falls between the closing brace of `Test-ExemptOrchestrationOperand` and the declaration of `Test-ExemptOrchestrationSegmentToken`.
- Added content lines: 87 (16 + 59 + 4 + 8). Post-change file length is 433 = 349 + 87 - 3.
- The porcelain capture is identical to the [P5-T1] capture.

## Removed content lines

| Pre-change line | Text | Region |
| --- | --- | --- |
| 227 | `    # Row 14: the command name leads and the subcommand follows immediately. Anything in` | pre-change 227-236 block (`Test-ExemptOrchestrationSegmentToken` prologue comment) |
| 228 | `    # between - a relocating option or an env-style prefix - moves the pathspec base and is` | pre-change 227-236 block (same comment) |
| 229 | `    # rejected here rather than modelled.` | pre-change 227-236 block (same comment) |

## Zero-context hunk headers and derived post-image numbers

| Hunk header | Removed | Added (d) | Post-image lines |
| --- | --- | --- | --- |
| `@@ -38,0 +39,16 @@` | 0 | 16 | 39-54 |
| `@@ -205,0 +222,59 @@` | 0 | 59 | 222-280 |
| `@@ -227,3 +302,4 @@` | 3 (227-229) | 4 | 302-305 |
| `@@ -232,0 +309,8 @@` | 0 | 8 | 309-316 |

## Changed-line set:

39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 302, 303, 304, 305, 309, 310, 311, 312, 313, 314, 315, 316

Count of numbers listed: 87, which equals the count of added content lines in the diff.

Helpers hash at capture: 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1

## Default-context diff capture

```diff
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
index af23b04c..964880ee 100644
--- a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
@@ -36,6 +36,22 @@ $script:UnresolvableCommandCharacters = [char[]]@('$', '`', '>', '<')
 # first of these is prefix-tested.
 $script:PathspecWildcardCharacters = [char[]]@('*', '?', '[')
 
+# The single repository selector modelled between the command name and the subcommand: D4
+# row 14 as narrowed by issue #671, the Lexical Absolute-Canonical Selector (LACS) rule in
+# docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md.
+# Compared case-sensitively; no other relocating spelling is modelled.
+$script:OrchestrationSelectorOptionName = '-C'
+
+# Accepted widening (issue #671): a selector naming a nested subdirectory of a worktree
+# passes L1 through L8 lexically yet relocates what a relative operand denotes, so
+# `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt`
+# stages `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. Measured
+# exposure in this repository is seven Markdown test fixtures under the
+# resolve_execute_plan_prompt fixture tree, all of which the gate's file_path leg already
+# classifies as non-implementation. This module stays pure string logic; the epic's F1
+# resolution module composes upstream to close the escape later without a schema change,
+# the same posture D4 row 16 takes toward issue #516.
+
 function Split-OrchestrationCommandLine {
     <#
     .SYNOPSIS
@@ -203,6 +219,65 @@ function Test-ExemptOrchestrationOperand {
     return $false
 }
 
+function Test-ExemptOrchestrationSelector {
+    <#
+    .SYNOPSIS
+        Tests the repository selector of one tokenized segment against LACS L1 through L8.
+    .DESCRIPTION
+        Realizes D4 row 14 as narrowed by issue #671 (the Lexical Absolute-Canonical Selector
+        rule in docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md).
+        Returns true only when the segment reads `git -C <value> <subcommand> ...` and the
+        value is decidable from the command text alone: exactly one case-sensitive `-C`, at
+        index 1 (L1, L2); a value at index 2 and the subcommand at index 3 (L3); a
+        drive-lettered or rooted, non-UNC value after separator normalization (L4); no `.` or
+        `..` segment (L5); no wildcard (L6); no colon other than the drive colon (L7); and a
+        non-empty value (L8). Each rejection writes a diagnostic token through Write-Debug.
+        The tokens are not contractual and change no decision.
+    .OUTPUTS
+        System.Boolean
+    #>
+    [CmdletBinding()]
+    [OutputType([bool])]
+    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)
+
+    $selector = $script:OrchestrationSelectorOptionName
+    if ($Token.Count -lt 2 -or $Token[1] -cne $selector) {
+        Write-Debug 'PREIMPL_SELECTOR_UNMODELLED_OPTION: the token after the command name is not the -C selector.'
+        return $false
+    }
+    if (@($Token | Where-Object { $_ -ceq $selector }).Count -gt 1) {
+        Write-Debug 'PREIMPL_SELECTOR_REPEATED: the segment carries more than one -C selector.'
+        return $false
+    }
+    if ($Token.Count -lt 4 -or $Token[3].StartsWith('-')) {
+        Write-Debug 'PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.'
+        return $false
+    }
+    $value = $Token[2]
+    if (-not $value) {
+        Write-Debug 'PREIMPL_SELECTOR_MALFORMED: the selector value is empty.'
+        return $false
+    }
+
+    $normalized = $value -replace '\\', '/'
+    $isDriveRooted = $normalized -match '^[A-Za-z]:/'
+    if ($normalized.StartsWith('//') -or -not ($isDriveRooted -or $normalized.StartsWith('/'))) {
+        Write-Debug 'PREIMPL_SELECTOR_NOT_ROOTED: the selector value is relative or UNC.'
+        return $false
+    }
+    $segments = $normalized -split '/'
+    if ($segments -contains '..' -or $segments -contains '.') {
+        Write-Debug 'PREIMPL_SELECTOR_TRAVERSAL: the selector value carries a dot segment.'
+        return $false
+    }
+    $afterDrive = if ($isDriveRooted) { $normalized.Substring(2) } else { $normalized }
+    if ($normalized.IndexOfAny($script:PathspecWildcardCharacters) -ge 0 -or $afterDrive.Contains(':')) {
+        Write-Debug 'PREIMPL_SELECTOR_NOT_LITERAL: the selector value carries a wildcard or a stray colon.'
+        return $false
+    }
+    return $true
+}
+
 function Test-ExemptOrchestrationSegmentToken {
     <#
     .SYNOPSIS
@@ -224,12 +299,21 @@ function Test-ExemptOrchestrationSegmentToken {
         return $false
     }
 
-    # Row 14: the command name leads and the subcommand follows immediately. Anything in
-    # between - a relocating option or an env-style prefix - moves the pathspec base and is
-    # rejected here rather than modelled.
+    # Row 14, narrowed by issue #671: the command name leads and the subcommand follows it,
+    # either immediately or after one lexically absolute `-C <value>` selector (LACS L1-L8).
+    # Anything else in between - an unmodelled or unresolvable relocating option, or an
+    # env-style prefix - moves the pathspec base undecidably and is rejected here.
     if ($Token[0] -cne 'git') {
         return $false
     }
+    if ($Token[1] -cne 'add' -and $Token[1] -cne 'commit') {
+        if (-not (Test-ExemptOrchestrationSelector -Token $Token)) {
+            return $false
+        }
+        # Drop the accepted selector and its value so the subcommand is again at index 1
+        # and operand collection below starts at index 2 exactly as before.
+        $Token = @($Token[0]) + @($Token[3..($Token.Count - 1)])
+    }
     $subcommand = $Token[1]
     if ($subcommand -cne 'add' -and $subcommand -cne 'commit') {
         return $false
```

## Zero-context capture (hunk headers)

```
@@ -38,0 +39,16 @@ $script:PathspecWildcardCharacters = [char[]]@('*', '?', '[')
@@ -205,0 +222,59 @@ function Test-ExemptOrchestrationOperand {
@@ -227,3 +302,4 @@ function Test-ExemptOrchestrationSegmentToken {
@@ -232,0 +309,8 @@ function Test-ExemptOrchestrationSegmentToken {
```

The zero-context body lines are the same added and removed lines shown in the default-context capture above.

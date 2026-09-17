# Remediation Diff Confinement — Helpers (issue #671, R1)

Timestamp: 2026-09-17T10-00
Task: [P5-T2]
Command: `git diff 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `git diff --unified=0 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
EXIT_CODE: 0
Helpers hash at capture: AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989

Output Summary: the diff removes 8 content lines and adds 100. Each removed line is assigned to class (a), (b), or (c) of Payload S9. The class (b) counterpart differs only by the inserted `[AllowEmptyString()]`. The insertion hunks fall outside every protected function body and after the last pre-existing `$script:` constant block, and no hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, or the three pre-existing `$script:` constant blocks. `Changed-line set:` holds 100 entries, equal to the added-line count. PASS.

## Removed content lines and classification

Pre-change line numbers come from the hunk headers and the context lines of the full diff. Hunk `@@ -218,18 +295,27 @@` starts at pre-change line 218 (`    #>`): 219 `[CmdletBinding()]`, 220 `[OutputType([bool])]`, 221 removed, 222 blank, 223–225 the count guard, 226 blank, 227–229 removed. Hunk `@@ -339,11 +425,17 @@` starts at pre-change line 339 (`        return $false`): 340 `    }`, 341 blank, 342–345 removed, 346 `        }` and 347 `    }` kept as context.

| Pre-change line | Removed text | Class | Justification |
| --- | --- | --- | --- |
| 221 | `    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)` | (b) | Re-added at post line 298 as `    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)`; the only difference is the inserted `[AllowEmptyString()]`. |
| 227 | `    # Row 14: the command name leads and the subcommand follows immediately. Anything in` | (a) | Inside pre-change lines 227–236. |
| 228 | `    # between - a relocating option or an env-style prefix - moves the pathspec base and is` | (a) | Inside pre-change lines 227–236. |
| 229 | `    # rejected here rather than modelled.` | (a) | Inside pre-change lines 227–236. |
| 342 | `    foreach ($segment in $segments) {` | (c) | Trimmed text equals post line 431 `        foreach ($segment in $segments) {`, inside the `try` block (430–436). |
| 343 | `        $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)` | (c) | Trimmed text equals post line 432, inside the `try` block. |
| 344 | `        if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {` | (c) | Trimmed text equals post line 433, inside the `try` block. |
| 345 | `            return $false` | (c) | Trimmed text equals post line 434 `                return $false`, inside the `try` block (not the `catch` line 438). |

## Hunk placement against the protected regions

| Hunk (zero-context) | Kind | Location | Touches a protected region? |
| --- | --- | --- | --- |
| `@@ -38,0 +39,16 @@` | insertion only | after pre-change line 38 (the blank line after the `$script:PathspecWildcardCharacters` block ending at line 37) | no: no constant-block line is removed or modified |
| `@@ -205,0 +222,61 @@` | insertion only | after pre-change line 205 (the blank line after the closing `}` of `Test-ExemptOrchestrationOperand` at line 204) | no: the new function sits between two functions |
| `@@ -221 +298 @@` | replace 1 | `Test-ExemptOrchestrationSegmentToken` parameter declaration | permitted class (b) |
| `@@ -227,3 +304,4 @@` | replace 3 with 4 | `Test-ExemptOrchestrationSegmentToken` row-14 comment | permitted class (a) |
| `@@ -232,0 +311,8 @@` | insertion only | `Test-ExemptOrchestrationSegmentToken` prologue, between pre-change lines 232 and 233 | permitted (the LACS absorption) |
| `@@ -342,4 +428,8 @@` | replace 4 with 8 | `Test-ExemptOrchestrationStagingCommand` per-segment loop | permitted class (c) |
| `@@ -346,0 +437,2 @@` | insertion only | `Test-ExemptOrchestrationStagingCommand`, after the loop's closing brace | permitted (the fail-closed `catch`) |

Changed-line set:
39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 298, 304, 305, 306, 307, 311, 312, 313, 314, 315, 316, 317, 318, 428, 429, 430, 431, 432, 433, 434, 435, 437, 438

Derivation: `+39,16` → 39–54 (16); `+222,61` → 222–282 (61); `+298` → 298 (1); `+304,4` → 304–307 (4); `+311,8` → 311–318 (8); `+428,8` → 428–435 (8); `+437,2` → 437–438 (2). Total 100 = the diff's added-line count (16 + 61 + 1 + 4 + 8 + 8 + 2).

## `git diff 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (verbatim)

```diff
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
index af23b04c..9d137658 100644
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
@@ -203,6 +219,67 @@ function Test-ExemptOrchestrationOperand {
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
+        L3 checks only that a non-option token follows the value; the caller
+        Test-ExemptOrchestrationSegmentToken rejects any subcommand other than add or commit.
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
@@ -218,18 +295,27 @@ function Test-ExemptOrchestrationSegmentToken {
     #>
     [CmdletBinding()]
     [OutputType([bool])]
-    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)
+    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)
 
     if ($Token.Count -lt 2) {
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
@@ -339,11 +425,17 @@ function Test-ExemptOrchestrationStagingCommand {
         return $false
     }
 
-    foreach ($segment in $segments) {
-        $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
-        if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
-            return $false
+    # Fail closed (issue #671): an error raised while classifying any segment is a parse
+    # ambiguity, so it answers false instead of letting the caller continue past it.
+    try {
+        foreach ($segment in $segments) {
+            $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
+            if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
+                return $false
+            }
         }
+    } catch {
+        return $false
     }
     return $true
 }
```

## `git diff --unified=0 79fd5a95c00cd99238b69a3195788206ae96f4cd -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (verbatim; hunk headers and removed/added lines)

```diff
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
index af23b04c..9d137658 100644
--- a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
@@ -38,0 +39,16 @@ $script:PathspecWildcardCharacters = [char[]]@('*', '?', '[')
+# (16 added lines: identical to the first `+` block of the full diff above)
@@ -205,0 +222,61 @@ function Test-ExemptOrchestrationOperand {
+# (61 added lines: identical to the `Test-ExemptOrchestrationSelector` block of the full diff above, including its trailing blank line)
@@ -221 +298 @@ function Test-ExemptOrchestrationSegmentToken {
-    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)
+    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Token)
@@ -227,3 +304,4 @@ function Test-ExemptOrchestrationSegmentToken {
-    # Row 14: the command name leads and the subcommand follows immediately. Anything in
-    # between - a relocating option or an env-style prefix - moves the pathspec base and is
-    # rejected here rather than modelled.
+    # Row 14, narrowed by issue #671: the command name leads and the subcommand follows it,
+    # either immediately or after one lexically absolute `-C <value>` selector (LACS L1-L8).
+    # Anything else in between - an unmodelled or unresolvable relocating option, or an
+    # env-style prefix - moves the pathspec base undecidably and is rejected here.
@@ -232,0 +311,8 @@ function Test-ExemptOrchestrationSegmentToken {
+    if ($Token[1] -cne 'add' -and $Token[1] -cne 'commit') {
+        if (-not (Test-ExemptOrchestrationSelector -Token $Token)) {
+            return $false
+        }
+        # Drop the accepted selector and its value so the subcommand is again at index 1
+        # and operand collection below starts at index 2 exactly as before.
+        $Token = @($Token[0]) + @($Token[3..($Token.Count - 1)])
+    }
@@ -342,4 +428,8 @@ function Test-ExemptOrchestrationStagingCommand {
-    foreach ($segment in $segments) {
-        $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
-        if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
-            return $false
+    # Fail closed (issue #671): an error raised while classifying any segment is a parse
+    # ambiguity, so it answers false instead of letting the caller continue past it.
+    try {
+        foreach ($segment in $segments) {
+            $tokens = @(ConvertTo-OrchestrationCommandToken -Segment $segment)
+            if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {
+                return $false
+            }
@@ -346,0 +437,2 @@ function Test-ExemptOrchestrationStagingCommand {
+    } catch {
+        return $false
```

Note on the zero-context capture: every hunk header and every removed or changed line is reproduced verbatim. The bodies of the two pure-insertion hunks (16 and 61 lines) are byte-identical to the corresponding `+` blocks of the full diff above, so they are summarized rather than repeated.

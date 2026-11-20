Timestamp: 2026-07-21T21-11

Command: git diff scripts/powershell/PoshQC/PoshQC.psm1 && wc -l scripts/powershell/PoshQC/PoshQC.psm1
EXIT_CODE: 0

# P1-T1 — Finalize Candidate A parse-once-cache edit in PoshQC.psm1

## Confirmations

- Only the bootstrap-loop region (original lines 82-106) is changed. The `git diff` hunks are
  confined to (a) the comment block immediately above the loop and (b) the `foreach` loop body;
  no other line in the file is touched.
- File line count: 147 lines (<= 500 limit).
- Parse-error-fails-fast `throw` is preserved on a cache-miss parse:
  `throw "Failed to parse sub-module '$subModuleName': $($parseErrors -join '; ')"` remains inside
  the `if (-not $cachedScriptBlock)` cache-miss branch.
- Both rationale comments present: the pre-existing issue #344 remediation-cycle-1 comment is
  retained verbatim, and the new issue #392 remediation-cycle-2 comment documents the
  process-lifetime AppDomain cache rationale (avoids repeated fresh AST parse/compile per `-Force`
  reimport within one process without changing `-Force`'s reimport-and-rebind semantics; `$global:`
  avoided per PSAvoidGlobalVars).

## git diff (bootstrap-loop region only)

```
@@ -89,6 +89,27 @@ function Install-PoshQCTool {
 # ... issue #344 comment retained ...
 # outside the coverage denominator.  Parse errors fail module import fast.
+#
+# issue #392 remediation cycle 2: ... process-lifetime AppDomain data slot ...
+$script:PoshQCSubModuleCacheKey = 'PoshQC.ParsedSubModuleScriptBlocks'
+$subModuleCache = [System.AppDomain]::CurrentDomain.GetData($script:PoshQCSubModuleCacheKey)
+if (-not $subModuleCache) {
+    $subModuleCache = @{}
+    [System.AppDomain]::CurrentDomain.SetData($script:PoshQCSubModuleCacheKey, $subModuleCache)
+}
 foreach ($subModuleName in @( ... )) {
     $subModulePath = Join-Path $script:ModuleRoot $subModuleName
-    $parseErrors = $null
-    $ast = [System.Management.Automation.Language.Parser]::ParseFile(...)
-    if ($parseErrors) { throw ... }
+    $cachedScriptBlock = $subModuleCache[$subModulePath]
+    if (-not $cachedScriptBlock) {
+        $parseErrors = $null
+        $ast = [System.Management.Automation.Language.Parser]::ParseFile(...)
+        if ($parseErrors) { throw ... }
+        $cachedScriptBlock = $ast.GetScriptBlock()
+        $subModuleCache[$subModulePath] = $cachedScriptBlock
+    }
-    . ($ast.GetScriptBlock())
+    . $cachedScriptBlock
 }
```

The full diff is reproduced from `git diff scripts/powershell/PoshQC/PoshQC.psm1` at
HEAD 92bf1f29659da829e4cbf4d0bcc4af2182d87b06 + working-tree edit.

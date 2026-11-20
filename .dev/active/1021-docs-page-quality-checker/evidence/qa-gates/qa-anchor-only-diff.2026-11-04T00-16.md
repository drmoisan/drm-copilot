# QA Anchor-Only Diff of the 1020 Edit Points - Issue #1021

Timestamp: 2026-11-04T00-16
Task: [P6-T9]
Command: `git diff --unified=0 MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1 .claude/lib/docs/DocsSchema.psm1 .claude/lib/docs/DocsProfileCommands.psm1` (MERGE_BASE is `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`); base lines read with `git show MERGE_BASE:<path>`
EXIT_CODE: 0
Output Summary: 4 hunks, 8 added lines, 0 removed lines. Each hunk adds lines directly below its file's 1021 anchor (`# --- 1021: page-check configuration ---` in `DocsProfileCommands.psm1`, `# --- 1021: page-metadata ---` in `Get-DocsSchemaName`, `# --- 1021: check ---` in `Invoke-DocsCommand.ps1`) or, for the `Get-DocsSchemaPath` row, as the last entry of that map per the CR-2 fallback recorded in `1020-precondition` (`Get-DocsSchemaPath` carries no 1021 anchor). Result: PASS.

## Output

```text
diff --git a/.claude/lib/docs/DocsProfileCommands.psm1 b/.claude/lib/docs/DocsProfileCommands.psm1
--- a/.claude/lib/docs/DocsProfileCommands.psm1
+++ b/.claude/lib/docs/DocsProfileCommands.psm1
@@ -44,0 +45,5 @@ function Get-DocsInitTemplate {
+        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/markdownlint.json'; Destination = '.markdownlint.json' }
+        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale.ini'; Destination = '.vale.ini' }
+        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml'; Destination = '.vale/styles/DocsBase/HeadingPunctuation.yml' }
+        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml'; Destination = '.vale/styles/DocsBase/Placeholders.yml' }
+        [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale/Project/accept.txt'; Destination = '.vale/styles/config/vocabularies/Project/accept.txt' }
diff --git a/.claude/lib/docs/DocsSchema.psm1 b/.claude/lib/docs/DocsSchema.psm1
--- a/.claude/lib/docs/DocsSchema.psm1
+++ b/.claude/lib/docs/DocsSchema.psm1
@@ -57,0 +58 @@ function Get-DocsSchemaName {
+        'page-metadata'
@@ -78,0 +80 @@ function Get-DocsSchemaPath {
+        'page-metadata'              = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/page-metadata.schema.json')
diff --git a/.claude/lib/docs/Invoke-DocsCommand.ps1 b/.claude/lib/docs/Invoke-DocsCommand.ps1
--- a/.claude/lib/docs/Invoke-DocsCommand.ps1
+++ b/.claude/lib/docs/Invoke-DocsCommand.ps1
@@ -57,0 +58 @@ function Get-DocsCommandTable {
+        [pscustomobject]@{ Name = 'check'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageCheck.psm1'); Function = 'Invoke-DocsCheckCommand'; Option = @{ Profile = 'value'; Path = 'multi' } }
```

## Base line each hunk follows (`git show MERGE_BASE:<path>`)

| Hunk | Base line | Base text |
|---|---|---|
| `DocsProfileCommands.psm1` `@@ -44,0 +45,5 @@` | 44 | `# --- 1021: page-check configuration ---` |
| `DocsSchema.psm1` `@@ -57,0 +58 @@` | 57 | `# --- 1021: page-metadata ---` |
| `DocsSchema.psm1` `@@ -78,0 +80 @@` | 78 | the last `Get-DocsSchemaPath` entry, `'docs-command-envelope' = (Join-Path ...)` (CR-2 fallback) |
| `Invoke-DocsCommand.ps1` `@@ -57,0 +58 @@` | 57 | `# --- 1021: check ---` |

The hunk headers above are diff output quoted as evidence of the asserted result; they are not plan anchors.

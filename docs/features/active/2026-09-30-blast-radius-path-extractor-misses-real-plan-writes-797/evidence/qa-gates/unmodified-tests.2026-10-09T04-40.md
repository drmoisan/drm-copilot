# Pre-Existing Tests Unmodified (P8-T4, AC-8)

Timestamp: 2026-10-09T04-40
Command: git diff --numstat 3d5a8446d6e39f66dd593a53280e47aedd83ba1c -- tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1; git diff -U0 3d5a8446d6e39f66dd593a53280e47aedd83ba1c -- tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1; git status --porcelain
EXIT_CODE: 0
Output Summary: the numstat deleted column is 0 for all three files (additions only: 160, 88, 67). In the second diff every deleted line belongs to the two permitted regions: the accepting test's parameter list (line 205, reflowed to add alpha/beta.unknownext), the rejecting test's parameter list (line 231, alpha/beta.unknownext removed), and the single inverted Pester It (lines 148-149 and 155-156). No deleted line belongs to a directory-shaped, root-surface, or placeholder-marker test. Porcelain is empty (all changes committed). The diffs run in the shell with the literal SHA recorded in P0-T3 because inline `pwsh` is denied (denial text in evidence/baseline/requirements-source.2026-10-09T02-51.md).

## Output

```text
160	0	tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1
88	0	tests/scripts/dev_tools/test_blast_radius_extraction_rules.py
67	0	tests/scripts/dev_tools/test_blast_radius_token_shapes.py

BlastRadiusExtraction.Path.Tests.ps1
@@ -148,2 +148,2 @@ Describe 'Get-PathTokenKind' {
-        It 'rejects a token outside the known segments with an unrecognized extension' {
-            # Arrange: a path-shaped token with an unknown extension.
+        It 'accepts a token outside the known segments with an unlisted letter-led extension' {
+            # Arrange: a letter-led extension names a file (issue #797).
@@ -155,2 +155,2 @@ Describe 'Get-PathTokenKind' {
-            # Assert: failing both shape rules drops the token.
-            $kind | Should -BeNullOrEmpty
+            # Assert: a letter-led extension names a file, so it is recorded (issue #797).
+            $kind | Should -Be 'concrete'

test_blast_radius_extraction.py
@@ -205 +205,6 @@ def test_classify_path_token_accepts_each_known_top_level_segment(
-    ["src/app/main.ts", "vendor/module/Thing.psm1", "build/output/report.json"],
+    [
+        "src/app/main.ts",
+        "vendor/module/Thing.psm1",
+        "build/output/report.json",
+        "alpha/beta.unknownext",
+    ],
@@ -231 +235,0 @@ def test_classify_path_token_records_wildcard_tokens_as_globs(token: str) -> Non
-        "alpha/beta.unknownext",
```

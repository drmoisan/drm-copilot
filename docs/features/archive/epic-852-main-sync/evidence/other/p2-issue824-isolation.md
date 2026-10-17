# Phase 2 Issue824 Suite Isolation (#737 guard)

Timestamp: 2026-10-11T00-19
Task: [P2-T10]
Command: Edit tool on tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 ; git diff 0ac05da8f4309c6dfb4865ef676f90de59b9e785 -- tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 ; wc -l <file>
EXIT_CODE: 0

ISSUE824-ISOLATION: edited (cites [P1-T7], which recorded `ISSUE824-ISOLATION: failing`)

Describe-level BeforeAll before the edit held the Claude hook dot-source `. "$PSScriptRoot/../../../.claude/hooks/validate-feature-review-coverage.ps1"` (merged-tree line 23); no assignment in that block was used only by that statement, so no assignment was removed.

Steps applied:

- (a) File-level BeforeAll inserted before the first `Describe`: hook dot-source, four `${function:...}` captures, `Mock Get-ArtifactFileContent { $null }`, and the three conditional `$null` mocks.
- (b) Describe-level BeforeAll: hook dot-source removed; three `Mock ... -MockWith $script:Real...` restores added.
- (c) F824-9: Arrange comment replaced by the two specified lines.

REMOVED: `        . "$PSScriptRoot/../../../.claude/hooks/validate-feature-review-coverage.ps1"`   (step b)
REMOVED: `            # Arrange: no mock; this test file is the tracked file that is read.`   (step c)

Anchored diff:

```diff
diff --git a/tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 b/tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
index 34edc23c1..6ba5b0d93 100644
--- a/tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
+++ b/tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
@@ -18,9 +18,23 @@
     one absent path; nothing is written, no process is started, and no clock is read.
 #>
 
+BeforeAll {
+    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1')
+    $script:RealGetArtifactFileContent = ${function:Get-ArtifactFileContent}
+    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
+    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
+    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
+    Mock Get-ArtifactFileContent { $null }
+    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
+    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
+    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }
+}
+
 Describe 'validate-feature-review-coverage.ps1 (issue #824)' {
     BeforeAll {
-        . "$PSScriptRoot/../../../.claude/hooks/validate-feature-review-coverage.ps1"
+        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
+        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
+        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
 
         function ConvertTo-FeatureReviewPayload {
             <#
@@ -226,7 +240,8 @@ Describe 'validate-feature-review-coverage.ps1 (issue #824)' {
         }
 
         It 'F824-9 reads a tracked file and reports a missing one' -Tag 'Issue824' {
-            # Arrange: no mock; this test file is the tracked file that is read.
+            # Arrange: restore the real Get-ArtifactFileContent over the file-level null mock; this test file is the tracked file that is read.
+            Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent
             $absentPath = 'docs/features/active/__absent__/none.md'
 
             # Act
```

DIFF_REMOVED_LINES: 2 (exactly the two REMOVED entries above)
IT_NAME_OR_SHOULD_LINE_CHANGED: no
LINE_COUNT: 289

Output Summary: the Issue824 suite now takes the reference isolation shape; the anchored diff holds only added lines plus the two specified removals; no It name or Should line changed; 289 lines.

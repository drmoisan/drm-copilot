# CodeCoverage.Path Diff (Post-Fix vs Pre-Fix)

Timestamp: 2026-07-04T12-00
Command: `git diff scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Diff:

```diff
diff --git a/scripts/powershell/PoshQC/settings/pester.runsettings.psd1 b/scripts/powershell/PoshQC/settings/pester.runsettings.psd1
index 18a61ba..58946b4 100644
--- a/scripts/powershell/PoshQC/settings/pester.runsettings.psd1
+++ b/scripts/powershell/PoshQC/settings/pester.runsettings.psd1
@@ -47,6 +47,12 @@
             '.claude/hooks/enforce-pr-author-skill.ps1'
             '.claude/hooks/validate-orchestrator-output.ps1'
             '.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1'
+            # Issue #301 remediation cycle 1 (fix #1): measure the completion-consistency
+            # hook set (Claude and Codex variants) so their Pester coverage is captured.
+            '.claude/hooks/enforce-completion-consistency.ps1'
+            '.claude/hooks/enforce-completion-helpers.ps1'
+            '.codex/hooks/enforce-completion-consistency.ps1'
+            '.codex/hooks/enforce-completion-helpers.ps1'
         )
         # Optional: don't fail the run on coverage percentage
         CoveragePercentTarget = 0
```

Verification against baseline:
- All 16 pre-existing entries from `baseline-codecoverage-path-entries.2026-07-04T12-00.md` are present unchanged, in the same order, at the same relative positions — the diff contains zero removed lines (no `-` lines except the diff context markers), confirming no drop and no rename.
- Both occurrences of the pre-existing duplicate `.claude/hooks/enforce-pr-author-skill.ps1` entry are untouched and not deduplicated (still present at their original positions, now lines 34 and 47 of the file).
- Exactly 4 new entries added: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`.
- Total entry count verified via `grep -cE "^\s+'\.claude|^\s+'\.codex|^\s+'scripts/" scripts/powershell/PoshQC/settings/pester.runsettings.psd1` = 20.

Output Summary: Diff confirms 16 pre-existing entries preserved (0 dropped, 0 renamed) + 4 new entries added = 20 total `CodeCoverage.Path` entries. New-entry comment references Issue #301 following the existing Issue #272/#214/#275 comment convention.

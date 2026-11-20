# CodeCoverage.Path Exclusion Check (both runsettings copies)

Timestamp: 2026-09-17T08:27:56-04:00
Command: for each runsettings copy: locate the line matching '^\s*Path\s+= @\(\s*$', slice to the first later line whose trimmed text is ')', discard lines whose trimmed text begins with '#', count remaining lines containing 'extensions/drm-copilot/resources/'; then Select-String -LiteralPath <file> -SimpleMatch -Pattern '.claude/lib/worktree-resolution/WorktreeResolution.psm1' (and '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1')
EXIT_CODE: 0
Output Summary: Both slices are 268 lines long (greater than 100); both comment-stripped prefix counts are 0 (162 comment lines discarded in each; the unstripped count is 1 in each, from the pre-existing policy comment); all four module-path match counts are 1.

| File | Anchor line | Slice lines | Slice length | Comment lines discarded | Unstripped prefix count | Comment-stripped prefix count | WorktreeResolution.psm1 matches | WorktreeTargetResolution.psm1 matches |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 23 | 23..290 | 268 | 162 | 1 | 0 | 1 | 1 |
| extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 23 | 23..290 | 268 | 162 | 1 | 0 | 1 | 1 |

In each file exactly one line matched the anchor expression, so the slice is the `CodeCoverage.Path`
array and not `Run.Path`.

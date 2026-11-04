---
name: pssa-hashtable-alignment-breaks-added-lines-only-diffs
description: PoshQC pssa settings enable PSAlignAssignmentStatement with CheckHashtable, so adding a longer key to an aligned hashtable rewrites every sibling line; "only added lines" diff criteria then cannot pass
metadata:
  type: feedback
---

`scripts/powershell/PoshQC/settings/pssa.settings.psd1` enables `PSAlignAssignmentStatement` with `CheckHashtable = $true`. Adding a key longer than the current longest key to an aligned hashtable literal (for example a new member in a `[pscustomobject]@{...}` return) forces whitespace changes on every existing key line, or the analyzer reports findings.

**Why:** issue #1034 revision (2026-11-04): spec criterion demanded `git diff <merge-base>` show only added lines in a shared entry script while two longer member names were added to `New-DocsCommandContext`; the literal criterion was unsatisfiable.

**How to apply:** when a plan asserts an additive-only diff of a PowerShell file whose edit adds hashtable keys, assert it on `git diff --ignore-all-space` and bound the whitespace-sensitive removed lines to the named realigned lines; record the deviation in plan Notes. Also prefer appending new comment-help lines over editing an existing member-list sentence.

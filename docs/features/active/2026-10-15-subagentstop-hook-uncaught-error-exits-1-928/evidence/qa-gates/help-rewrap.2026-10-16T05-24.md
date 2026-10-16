# Help Rewrap (remediation cycle 1, P2-T4)

Timestamp: 2026-10-16T05-24
Command: git diff -U0 NEW_MERGE_BASE -- .claude/hooks/subagentstop-envelope.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
EXIT_CODE: 0
NEW_MERGE_BASE: 97559c3e0dcfceb807ae330d3c9e6ae4c5d67964
Output Summary:

Citation counts (commands: `grep -c -F "docs/features/archive/subagentstop-envelope-core-897/spec.md"`, `grep -c -F "docs/features/active/subagentstop-envelope-core-897/spec.md"`, `grep -c -F "docs/features/active/subagentstop-envelope-core-897/ until the archive move"`):
- .claude/hooks/subagentstop-envelope.ps1: 1, 0, 1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1: 1, 0, 1
- tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1: 1, 0, 1

Diff hunks (one per file):
- helper `@@ -12,2 +12,3 @@`
  - `-    docs/features/active/subagentstop-envelope-core-897/spec.md (issue #897). Where this file and any`
  - `-    other document differ, that section governs.`
  - `+    docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at`
  - `+    docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file`
  - `+    and any other document differ, that section governs.`
- mirror `@@ -12,2 +12,3 @@` (identical lines to the helper)
- test `@@ -9,2 +9,3 @@`
  - `-    docs/features/active/subagentstop-envelope-core-897/spec.md: the three-function surface, the`
  - `-    source constraints (no environment read, no import or dot-source, no success, host, information`
  - `+    docs/features/archive/subagentstop-envelope-core-897/spec.md (at`
  - `+    docs/features/active/subagentstop-envelope-core-897/ until the archive move): the three-function`
  - `+    surface, the source constraints (no environment read, no import or dot-source, no success, host, information`

Placement: every added line begins with four spaces. `grep -n -x '#>'` reports helper line 19, mirror line 19, test line 16; the added lines (12-14 helper and mirror, 9-11 test) lie before those closing markers, inside the comment-based help block.

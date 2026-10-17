# Limited Diff (remediation cycle 1 final QC, pass 1)

Timestamp: 2026-10-16T05-41
Command: git diff -U0 NEW_MERGE_BASE -- .claude/hooks/subagentstop-envelope.ps1 .claude/hooks/enforce-epic-wave-barrier.ps1 .claude/agents
EXIT_CODE: 0
NEW_MERGE_BASE: 97559c3e0dcfceb807ae330d3c9e6ae4c5d67964
CYCLE_BASE: b08496681062990d39ccc4e1a07767b9854701d3
Output Summary:

Diff against NEW_MERGE_BASE:
- `.claude/agents/epic-orchestrator.md`: single hunk `@@ -133,3 +133,3 @@` (the only `.claude/agents` file listed)
  - `-report it to the operator and halt. Its runtime effect is likely to depend on the `SubagentStop``
  - `-transport and exit-code defect recorded in`
  - `-`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.`
  - `+report it to the operator and halt. The `SubagentStop` transport and exit-code defect this check`
  - `+previously depended on was resolved by epic #904 and issue #928: a violation blocks the stop with`
  - `+exit 2 and a stderr reason.`
- `.claude/hooks/enforce-epic-wave-barrier.ps1`: single hunk `@@ -34,2 +34,2 @@`
  - `-    That hook's runtime effect is likely to depend on the SubagentStop transport defect recorded in`
  - `-    docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md.`
  - `+    The SubagentStop transport and exit-code defect that hook depended on was resolved by epic #904`
  - `+    and issue #928: a violation blocks the stop with exit 2 and a stderr reason.`
- `.claude/hooks/subagentstop-envelope.ps1`: single hunk `@@ -12,2 +12,3 @@`, inside the comment-based help block (closing `#>` at line 19)
  - `-    docs/features/active/subagentstop-envelope-core-897/spec.md (issue #897). Where this file and any`
  - `-    other document differ, that section governs.`
  - `+    docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at`
  - `+    docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file`
  - `+    and any other document differ, that section governs.`

Whitespace-normalization commands and outputs:
- Command: git show CYCLE_BASE:.claude/hooks/subagentstop-envelope.ps1 | awk -v ORS=' ' 'FNR >= 12 && FNR <= 13 { $1 = $1; print }'
  Output: `docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file and any other document differ, that section governs. `
- Command: awk -v ORS=' ' 'FNR >= 12 && FNR <= 14 { $1 = $1; print }' .claude/hooks/subagentstop-envelope.ps1
  Output: `docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file and any other document differ, that section governs. `
- Command: git show CYCLE_BASE:tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | awk -v ORS=' ' 'FNR >= 9 && FNR <= 10 { $1 = $1; print }'
  Output: `docs/features/archive/subagentstop-envelope-core-897/spec.md (at docs/features/active/subagentstop-envelope-core-897/ until the archive move): the three-function surface, the source constraints (no environment read, no import or dot-source, no success, host, information `
- Command: awk -v ORS=' ' 'FNR >= 9 && FNR <= 11 { $1 = $1; print }' tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
  Output: `docs/features/archive/subagentstop-envelope-core-897/spec.md (at docs/features/active/subagentstop-envelope-core-897/ until the archive move): the three-function surface, the source constraints (no environment read, no import or dot-source, no success, host, information `
- String comparison: helper pair IDENTICAL; test pair IDENTICAL.

Conclusion (AC4, AC11, AC12 re-verification): the rewrap changes only line breaks and indentation; the helper's content change against NEW_MERGE_BASE remains the citation that starts at line 12 (AC4).

# Canonical Edit Checks (Issue #710, AC-7)

Timestamp: 2026-09-27T02-12
Command: git merge-base --is-ancestor b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb HEAD; sh <SCRATCHPAD>/r-detect.sh (R-DETECT); sh <SCRATCHPAD>/r-fmt.sh (R-FMT on the canonical file); git diff --numstat b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1; git diff -U0 b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1; git status --porcelain
EXIT_CODE: 0
Output Summary: Edits E1 to E3 applied inside Split-OrchestrationCommandLine (lines 58 to 108). Line count 497 before and after; no carriage return; numstat 5 added / 5 deleted; three hunks at pre-image lines 63, 77, and 78, all within [58, 108]; formatter-stable. The canonical copy now differs from the three unedited copies (BYTE_IDENTICAL: False), which is expected until [P2-T3] and [P3-T2].

BASE_ANCESTOR_EXIT: 0
PRE_EDIT_LINE_COUNT: 497
POST_EDIT_LINE_COUNT: 497

## R-DETECT

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 5BB872E2DE58734D6AAA7CE25343C5C9796839C3EEB8610562DB365D17881D7F
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 5BB872E2DE58734D6AAA7CE25343C5C9796839C3EEB8610562DB365D17881D7F
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 5BB872E2DE58734D6AAA7CE25343C5C9796839C3EEB8610562DB365D17881D7F
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
BYTE_IDENTICAL: False
FUNC_START: 58
FUNC_END: 108
ANCHOR: OLD_DESC_1 count=0 line=0
ANCHOR: OLD_DESC_2 count=0 line=0
ANCHOR: OLD_DESC_3 count=0 line=0
ANCHOR: OLD_DESC_4 count=0 line=0
ANCHOR: NEW_DESC_1 count=1 line=63
ANCHOR: NEW_DESC_2 count=1 line=64
ANCHOR: NEW_DESC_3 count=1 line=65
ANCHOR: OPENQUOTE count=1 line=75
ANCHOR: FOREACH count=1 line=77
ANCHOR: ESCAPED_INIT count=1 line=76
ANCHOR: ESCAPE_IF count=1 line=78
LINE_AFTER_OPENQUOTE: escaped-init
LINE_AFTER_FOREACH: escape-if
ESCAPE_LINES: 2
```

Canonical `CR_PRESENT:` False, equal to its [P0-T5] value (False).

## R-FMT

```text
FORMAT_STABLE: True
FORMATTED_LINE_COUNT: 497
```

## Numstat

```text
5	5	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
```

## Zero-Context Diff

```diff
diff --git a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
index c90627e6..9b64e745 100644
--- a/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
+++ b/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
@@ -63,4 +63,3 @@ function Split-OrchestrationCommandLine {
-        Realizes D4 row 13. Quote state is tracked while scanning so a chain operator
-        inside a quoted span does not split. The returned `Balanced` flag reports whether
-        the scan ended outside every quote; unbalanced text is not splittable and the
-        caller denies (D4 rows 11 and 13). Empty and whitespace-only segments are dropped.
+        Realizes D4 row 13. Quote state and POSIX backslash escapes (issue #710) are tracked, so a quoted or
+        escaped chain operator does not split. `Balanced` reports whether the scan ended outside every quote;
+        the caller denies unbalanced text (D4 rows 11 and 13). Empty and whitespace-only segments are dropped.
@@ -77 +76 @@ function Split-OrchestrationCommandLine {
-
+    $escaped = $false
@@ -78,0 +78 @@ function Split-OrchestrationCommandLine {
+        if ($escaped -or ($character -eq '\' -and $openQuote -ne "'")) { $escaped = -not $escaped; [void]$current.Append($character); continue }
```

## Hunk Headers and Pre-Image Start Lines

| Hunk header | Pre-image start line | Within [58, 108] |
| --- | --- | --- |
| `@@ -63,4 +63,3 @@` | 63 | yes |
| `@@ -77 +76 @@` | 77 | yes |
| `@@ -78,0 +78 @@` | 78 | yes |

## Porcelain

```text
 M .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md
?? docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/
?? tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
```

Paths outside the feature folder: the canonical helper file and the new test file only.

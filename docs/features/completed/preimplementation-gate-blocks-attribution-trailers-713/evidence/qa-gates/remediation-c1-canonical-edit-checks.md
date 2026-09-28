# Remediation Cycle 1 - Canonical Edit Checks ([P2-T3])

Timestamp: 2026-09-27T05-07

Command: sh <SCRATCHPAD>/c1-detect.sh (R-DETECT-C1, launcher `exec pwsh -NoProfile -File "$(dirname "$0")/c1-detect.ps1"`)

EXIT_CODE: 0

Output Summary: Pass 1 (first run). Canonical LINES 497 (equal to PRE_EDIT_LINE_COUNT 497); NON_ASCII_BYTES 0; CR_PRESENT False (same as [P0-T5]). O1 to O11 count=0. N1 to N4 count=1 region=preamble; N5 to N9 count=1 region=Test-OrchestrationCommandTextUnresolvable; N10 and N11 count=1 region=Test-ExemptOrchestrationStagingCommand. All eleven KEEP_ labels count=1 in their original regions (KEEP_K5 moved from line 36 to 35 inside the preamble). TOKEN_663_713_LINES 2; TOKEN_COMMENT_INTRODUCER_LINES 1; TOKEN_TYPOGRAPHIC_CONSTANT_LINES 2; REDIRECTION_REF_LINES 0. R-FMTPROBE FORMAT_STABLE True. Numstat against HEAD_SHA 11/11. Every -U0 hunk lies in the four section-3 blocks. Porcelain lists the canonical helpers file and otherwise only feature-folder paths. BYTE_IDENTICAL False is the expected between-batch state (plan rule 5). Result: PASS.

POST_EDIT_LINE_COUNT: 497

## R-DETECT-C1 output

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
NON_ASCII_BYTES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
BYTE_IDENTICAL: False
FUNCTION: Split-OrchestrationCommandLine start=58
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=110
FUNCTION: ConvertTo-OrchestrationCommandToken start=163
FUNCTION: Test-ExemptOrchestrationOperand start=220
FUNCTION: Test-ExemptOrchestrationSelector start=278
FUNCTION: Test-ExemptOrchestrationSegmentToken start=339
FUNCTION: Test-ExemptOrchestrationStagingCommand start=438
ANCHOR: O1 count=0 line=0 region=none
ANCHOR: O2 count=0 line=0 region=none
ANCHOR: O3 count=0 line=0 region=none
ANCHOR: O4 count=0 line=0 region=none
ANCHOR: O5 count=0 line=0 region=none
ANCHOR: O6 count=0 line=0 region=none
ANCHOR: O7 count=0 line=0 region=none
ANCHOR: O8 count=0 line=0 region=none
ANCHOR: O9 count=0 line=0 region=none
ANCHOR: O10 count=0 line=0 region=none
ANCHOR: O11 count=0 line=0 region=none
ANCHOR: N1 count=1 line=31 region=preamble
ANCHOR: N2 count=1 line=32 region=preamble
ANCHOR: N3 count=1 line=33 region=preamble
ANCHOR: N4 count=1 line=36 region=preamble
ANCHOR: N5 count=1 line=118 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: N6 count=1 line=119 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: N7 count=1 line=120 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: N8 count=1 line=130 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: N9 count=1 line=131 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: N10 count=1 line=467 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: N11 count=1 line=468 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: KEEP_K5 count=1 line=35 region=preamble
ANCHOR: KEEP_U1 count=1 line=115 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U2 count=1 line=116 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U3 count=1 line=117 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U5 count=1 line=138 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U6 count=1 line=140 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_U7 count=1 line=156 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: KEEP_S1 count=1 line=396 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S2 count=1 line=402 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S3 count=1 line=403 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: KEEP_S4 count=1 line=410 region=Test-ExemptOrchestrationSegmentToken
TOKEN_663_713_LINES: 2
TOKEN_COMMENT_INTRODUCER_LINES: 1
TOKEN_TYPOGRAPHIC_CONSTANT_LINES: 2
REDIRECTION_REF_LINES: 0
```

## R-FMTPROBE output

Command: sh <SCRATCHPAD>/x713-fmtprobe-helpers.sh (EXIT_CODE: 0)

```text
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
FORMAT_STABLE: True
FORMATTED_LINE_COUNT: 497
```

## git diff --numstat 819369ccef370a195b3c39a966f1ab0c8d565ef7 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1

```text
11	11	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
```

## git diff -U0 819369ccef370a195b3c39a966f1ab0c8d565ef7 -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1

Hunks: `@@ -31,4 +31,3 @@` (E1 comments), `@@ -36,0 +36 @@` (E1 N4), `@@ -118,3 +118,3 @@` (E2), `@@ -130,2 +130,2 @@` (E3), `@@ -467,2 +467,2 @@` (E4). All lie within the four section-3 blocks.

```text
@@ -31,4 +31,3 @@ $script:OrchestrationBookkeepingTrees = @(
-# issues #663 and #713). Interpolation characters are unresolvable outside quotes and in a
-# double-quoted span, which still expands them; a single-quoted span keeps them literal.
-# Outside-quote characters (`<`, `>`, and the `#` comment introducer) are unresolvable only
-# outside a quoted span, so a quoted Co-Authored-By trailer or a quoted `#` is literal text.
+# issues #663 and #713): interpolation characters outside single quotes; outside-quote
+# characters (`<`, `>`, and the `#` comment introducer) outside any quote; and typographic
+# quotes (U+2018 to U+201E) anywhere, because a PowerShell host reads them as quotes.
@@ -36,0 +36 @@ $script:OutsideQuoteCommandCharacters = [char[]]@('>', '<', '#')
+$script:TypographicQuoteCharacters = [char[]]@(0x2018, 0x2019, 0x201A, 0x201B, 0x201C, 0x201D, 0x201E)
@@ -118,3 +118,3 @@ function Test-OrchestrationCommandTextUnresolvable {
-        only outside a quoted span. Backslash escapes are not modelled, so a
-        backslash before any quote character, or anywhere inside a double-quoted span,
-        answers true: the shell may end the span where this scan does not (fail closed).
+        only outside a quoted span. A typographic quote (U+2018 to U+201E), a backslash before
+        any quote character, or a backslash inside a double-quoted span answers true anywhere:
+        a shell may end the span where this scan does not (fail closed).
@@ -130,2 +130,2 @@ function Test-OrchestrationCommandTextUnresolvable {
-    # An escaped quote moves a span boundary the scan cannot model (issue #663 remediation CR-1).
-    if ($CommandText.Contains('\"') -or $CommandText.Contains("\'")) {
+    # An escaped or typographic quote moves a span boundary the scan cannot model (#663, #713).
+    if ($CommandText.Contains('\"') -or $CommandText.Contains("\'") -or $CommandText.IndexOfAny($script:TypographicQuoteCharacters) -ge 0) {
@@ -467,2 +467,2 @@ function Test-ExemptOrchestrationStagingCommand {
-    # Row 12: interpolation anywhere, redirection outside quotes, and unmodelled backslash
-    # escapes are not statically resolvable, so the operand list cannot be trusted.
+    # Row 12: `$` or backtick outside single quotes, `<`, `>`, or `#` outside quotes, any
+    # typographic quote, and unmodelled backslash escapes make the operand list untrustworthy.
```

## git status --porcelain

```text
 M .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/remediation-c1-commits-log.md
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/remediation-c1-pre-edit-ancestry.md
```

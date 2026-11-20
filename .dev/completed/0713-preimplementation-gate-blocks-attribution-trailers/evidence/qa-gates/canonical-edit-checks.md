# P2-T2 Canonical Edit Checks

Timestamp: 2026-09-27T03-36
Command: git diff --numstat 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
EXIT_CODE: 0
Output Summary: The canonical helpers file changed by 16 added and 16 deleted lines against BASE_SHA; all 16 old anchors are gone and all 16 new anchors occur once in their expected regions. Line count is unchanged at 497, LF only, formatter-stable. The rename is complete (0 RedirectionCommandCharacters references, 2 OutsideQuoteCommandCharacters references). Ancestry checks pass under deviation X1.

Other commands (each EXIT_CODE 0 unless stated):

- `git merge-base --is-ancestor 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD`: exit 0
- `git merge-base --is-ancestor 6747ee7729939467b2181b99a9893599de7ade55 HEAD` (X1): exit 0
- `git rev-parse HEAD`: 911359bc4919e68f113bf522b86f87978b50db35
- `git log --format=%h%x20%s 6747ee7729939467b2181b99a9893599de7ade55..HEAD` (X1)
- `sh <SCRATCHPAD>/x713-detect.sh` (R-DETECT)
- `sh <SCRATCHPAD>/x713-fmtprobe-helpers.sh` (R-FMTPROBE on the canonical helpers file)
- `git diff -U0 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- `git status --porcelain`
- `git diff --name-status 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD` (X1 porcelain companion)

BASE_ANCESTOR_EXIT: 0
HEAD_ANCESTOR_EXIT: 0
HEAD_NOW: 911359bc4919e68f113bf522b86f87978b50db35
PRE_EDIT_LINE_COUNT: 497
POST_EDIT_LINE_COUNT: 497

## Deviation X1 reading of the HEAD condition

Plan rule 6 requires `HEAD_NOW` to equal the [P0-T3] `HEAD_SHA` (6747ee7729939467b2181b99a9893599de7ade55). Deviation X1 replaces that clause: `HEAD_SHA` is an ancestor of HEAD (exit 0) and every commit in `HEAD_SHA..HEAD` is a phase-boundary commit recorded in `evidence/other/commits-log.md`:

```text
911359bc test(hooks): add attribution-trailer regression suite for issue #713
8f621b60 docs(evidence): record phase 0 baseline for issue #713
```

## R-DETECT output

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 9E84AF141F7166F1BE27A2E62B53437CB1537E1AC4230CCC054C11295AF1BAE7
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
BYTE_IDENTICAL: False
FUNCTION: Split-OrchestrationCommandLine start=58
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=110
FUNCTION: ConvertTo-OrchestrationCommandToken start=163
FUNCTION: Test-ExemptOrchestrationOperand start=220
FUNCTION: Test-ExemptOrchestrationSelector start=278
FUNCTION: Test-ExemptOrchestrationSegmentToken start=339
FUNCTION: Test-ExemptOrchestrationStagingCommand start=438
ANCHOR: K1_OLD count=0 line=0 region=none
ANCHOR: K2_OLD count=0 line=0 region=none
ANCHOR: K3_OLD count=0 line=0 region=none
ANCHOR: K4_OLD count=0 line=0 region=none
ANCHOR: K5_OLD count=0 line=0 region=none
ANCHOR: U1_OLD count=0 line=0 region=none
ANCHOR: U2_OLD count=0 line=0 region=none
ANCHOR: U3_OLD count=0 line=0 region=none
ANCHOR: U4_OLD count=0 line=0 region=none
ANCHOR: U5_OLD count=0 line=0 region=none
ANCHOR: U6_OLD count=0 line=0 region=none
ANCHOR: U7_OLD count=0 line=0 region=none
ANCHOR: S1_OLD count=0 line=0 region=none
ANCHOR: S2_OLD count=0 line=0 region=none
ANCHOR: S3_OLD count=0 line=0 region=none
ANCHOR: S4_OLD count=0 line=0 region=none
ANCHOR: K1_NEW count=1 line=31 region=preamble
ANCHOR: K2_NEW count=1 line=32 region=preamble
ANCHOR: K3_NEW count=1 line=33 region=preamble
ANCHOR: K4_NEW count=1 line=34 region=preamble
ANCHOR: K5_NEW count=1 line=36 region=preamble
ANCHOR: U1_NEW count=1 line=115 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U2_NEW count=1 line=116 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U3_NEW count=1 line=117 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U4_NEW count=1 line=118 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U5_NEW count=1 line=138 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U6_NEW count=1 line=140 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U7_NEW count=1 line=156 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: S1_NEW count=1 line=396 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S2_NEW count=1 line=402 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S3_NEW count=1 line=403 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S4_NEW count=1 line=410 region=Test-ExemptOrchestrationSegmentToken
REDIRECTION_REF_LINES: 0
OUTSIDE_QUOTE_REF_LINES: 2
SIBLING_710_PRESENT: True
TOKEN_663_713_LINES: 2
TOKEN_COMMENT_INTRODUCER_LINES: 1
```

`BYTE_IDENTICAL: False` is expected at this point: the three non-canonical copies are updated by [P2-T3] and [P3-T2] (rule 9, batches 1 and 2).

## R-FMTPROBE output

```text
FILE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
FORMAT_STABLE: True
FORMATTED_LINE_COUNT: 497
```

## Numstat

```text
16	16	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
```

## Zero-context diff

```diff
@@ -31,4 +31,4 @@ $script:OrchestrationBookkeepingTrees = @(
-# issue #663). Interpolation characters are unresolvable in every quote state, because a
-# double-quoted span still expands them. Redirection characters are unresolvable only
-# outside a quoted span: inside single or double quotes the shell treats `<` and `>` as
-# literal text, so a quoted Co-Authored-By trailer is not a redirection.
+# issues #663 and #713). Interpolation characters are unresolvable outside quotes and in a
+# double-quoted span, which still expands them; a single-quoted span keeps them literal.
+# Outside-quote characters (`<`, `>`, and the `#` comment introducer) are unresolvable only
+# outside a quoted span, so a quoted Co-Authored-By trailer or a quoted `#` is literal text.
@@ -36 +36 @@ $script:InterpolationCommandCharacters = [char[]]@('$', '`')
-$script:RedirectionCommandCharacters = [char[]]@('>', '<')
+$script:OutsideQuoteCommandCharacters = [char[]]@('>', '<', '#')
@@ -115,4 +115,4 @@ function Test-OrchestrationCommandTextUnresolvable {
-        Realizes D4 row 12 as narrowed by issue #663. Quote state is tracked with the same
-        state machine as Split-OrchestrationCommandLine. An interpolation character (`$` or
-        backtick) answers true in any quote state; a redirection character (`<` or `>`)
-        answers true only outside a quoted span. Backslash escapes are not modelled, so a
+        Realizes D4 row 12 as narrowed by issues #663 and #713, with quote state tracked as in
+        Split-OrchestrationCommandLine. `$` or backtick answers true outside quotes or inside
+        double quotes (single quotes keep it literal); `<`, `>`, or a `#` comment answers true
+        only outside a quoted span. Backslash escapes are not modelled, so a
@@ -138 +138 @@ function Test-OrchestrationCommandTextUnresolvable {
-    # redirection characters are judged only where the shell would honour them.
+    # outside-quote characters are judged only where the shell would honour them.
@@ -140 +140 @@ function Test-OrchestrationCommandTextUnresolvable {
-        if ($script:InterpolationCommandCharacters -contains $character) {
+        if ($openQuote -ne "'" -and $script:InterpolationCommandCharacters -contains $character) {
@@ -156 +156 @@ function Test-OrchestrationCommandTextUnresolvable {
-        } elseif ($script:RedirectionCommandCharacters -contains $character) {
+        } elseif ($script:OutsideQuoteCommandCharacters -contains $character) {
@@ -396 +396 @@ function Test-ExemptOrchestrationSegmentToken {
-                # The message option is the only modelled option on either subcommand. Rows
+                # Only the message and trailer options of commit are modelled (issue #713). Rows
@@ -402,2 +402,2 @@ function Test-ExemptOrchestrationSegmentToken {
-                if ($candidate -ceq '-m' -or $candidate -ceq '--message') {
-                    # The message value is the following token and is not a pathspec.
+                if ($candidate -ceq '-m' -or $candidate -ceq '--message' -or $candidate -ceq '--trailer') {
+                    # The message or trailer value is the following token and is not a pathspec.
@@ -410 +410 @@ function Test-ExemptOrchestrationSegmentToken {
-                if ($candidate.StartsWith('--message=') -or
+                if ($candidate.StartsWith('--message=') -or $candidate.StartsWith('--trailer=') -or
```

## Porcelain

```text
 M .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/commits-log.md
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
```

Porcelain reading under deviation X1: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` appears in the porcelain output. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` was committed at the Phase 1 boundary (911359bc) and appears as `A` in `git diff --name-status 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD`. No other path outside the feature folder appears in either list.

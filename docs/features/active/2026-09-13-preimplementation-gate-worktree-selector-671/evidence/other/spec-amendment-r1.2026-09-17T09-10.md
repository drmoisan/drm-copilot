# Spec Amendment R1 — Record (issue #671)

Timestamp: 2026-09-17T09-50
Task: [P1-T15]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/speccounts.ps1` (`Select-String -SimpleMatch` counts over spec.md; lines beginning `- [` between `## Acceptance Criteria` and the next level-1/2 heading); Git route: `git diff --unified=0 03f4f305765e15745b9275f3a8fd42758f2c6873 -- docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` and `git status --porcelain`.
EXIT_CODE: 0

Output Summary:
- spec.md `- [x] ` lines: `22`
- spec.md `- [ ] ` lines: `9`
- Lines under `## Acceptance Criteria` beginning `- [`: `26` (spec lines 679–704)
- Removed content lines in the diff against `03f4f305…`: `13`, each one an old text quoted in Payload S1, S2, S3, S5, S6, S7, S9, S10, S11, or S14 (table below). No removed line falls outside that set; no allow row or regression-guard row was changed.
- All acceptance values match ([x] 22, [ ] 9, AC 26, removed 13).

## Removed content lines

| # | Pre-amendment line (03f4f305) | Removed text (abbreviated where long) | Payload |
| --- | --- | --- | --- |
| 1 | 6 | `- **Last Updated:** 2026-09-13T22-10` | S14 |
| 2 | 8 | `- **Version:** 0.2` | S14 |
| 3 | 275 | `  (\`Test-ExemptOrchestrationStagingCommand\`, helpers lines 342–347) stays byte-unchanged. LACS is` | S6 (old second line) |
| 4 | 276 | `  evaluated per segment.` | S6 (old third line) |
| 5 | 314 | `\| \`Test-ExemptOrchestrationSegmentToken\` — selector absorption in the prologue, between the current lines 232 and 233 \| … \| about 14 changed or added lines \|` | S7 (old row 1) |
| 6 | 315 | `\| \`Split-OrchestrationCommandLine\`, \`ConvertTo-OrchestrationCommandToken\`, \`Test-ExemptOrchestrationOperand\`, \`Test-ExemptOrchestrationStagingCommand\` \| \`-helpers.ps1\` \| **unchanged** \| 0 \|` | S7 (old row 2) |
| 7 | 476 | `the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites.` | S5 |
| 8 | 490 | `Context \`issue #671 worktree selector deny cases\` — 17 rows, all NEW:` | S3 |
| 9 | 497 | `\| \`issue #671 LACS L3a - selector with no subcommand after the value\` \| \`git -C C:/repo/wt\` \| deny \|` | S1 |
| 10 | 498 | `\| \`issue #671 LACS L3b - subcommand not immediately after the selector value\` \| \`git -C C:/repo/wt -- docs/features/active/x/spec.md\` \| deny \|` | S2 |
| 11 | 630 | `- [x] The helpers diff is confined to one axis: in …` (old criterion 11) | S9 |
| 12 | 638 | `- [ ] Line coverage is at or above 85% for the PowerShell coverage run, … and coverage on the changed lines of the helpers file does not regress. …` (old criterion 19) | S10 |
| 13 | 639 | `- [ ] The full PowerShell toolchain passes in a single pass: … reports no file changed on a second invocation, … reports zero failed tests.` (old criterion 20) | S11 |

The old first line of S6 (`- **INV-6 — Chaining semantics unchanged.** The all-segments rule`) is also the first new line, so the diff keeps it as unchanged context.

## `git diff --unified=0 03f4f305765e15745b9275f3a8fd42758f2c6873 -- docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md` (verbatim)

```diff
diff --git a/docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md b/docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
index 2fe693c4..e99b26a1 100644
--- a/docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
+++ b/docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
@@ -6 +6 @@
-- **Last Updated:** 2026-09-13T22-10
+- **Last Updated:** 2026-09-17T08-44
@@ -8 +8 @@
-- **Version:** 0.2
+- **Version:** 0.3
@@ -275,2 +275,5 @@ one new predicate and one new constant.
-  (`Test-ExemptOrchestrationStagingCommand`, helpers lines 342–347) stays byte-unchanged. LACS is
-  evaluated per segment.
+  (`Test-ExemptOrchestrationStagingCommand`, pre-change helpers lines 342–347) keeps its
+  semantics. Remediation R1 wraps that per-segment loop, unchanged except for indentation, in a
+  fail-closed `try`/`catch` whose `catch` returns `$false`, so an error raised while classifying
+  any segment answers false instead of letting the caller reach `return $true`. LACS is evaluated
+  per segment.
@@ -314,2 +317,3 @@ No other production or test file is edited. In particular: no gate file, no mode
-| `Test-ExemptOrchestrationSegmentToken` — selector absorption in the prologue, between the current lines 232 and 233 | `-helpers.ps1` | modified | about 14 changed or added lines |
-| `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand` | `-helpers.ps1` | **unchanged** | 0 |
+| `Test-ExemptOrchestrationSegmentToken` — selector absorption in the prologue, between the pre-change lines 232 and 233, plus `[AllowEmptyString()]` on the `$Token` parameter declaration at pre-change line 221 (remediation R1) | `-helpers.ps1` | modified | about 15 changed or added lines |
+| `Test-ExemptOrchestrationStagingCommand` — per-segment loop wrapped in a fail-closed `try`/`catch` (remediation R1) | `-helpers.ps1` | modified | about 6 added lines |
+| `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand` | `-helpers.ps1` | **unchanged** | 0 |
@@ -380,0 +385,5 @@ None. No new configuration key, no settings entry, no manifest entry, no runsett
+- **Remediation R1 exception (narrowing only).** A command line whose segment carries an empty
+  quoted token was allowed before remediation R1 only because the token failed parameter binding
+  and the caller continued past the error. Such a line now allows only when every operand is
+  exempt, and denies otherwise; the fail-closed guard denies on any other classification error. No
+  command line that denied before remediation R1 allows after it.
@@ -476 +485,3 @@ Added as two new `Context` blocks per suite, using the existing `-ForEach` table
-the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites.
+the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites,
+and remediation R1 adds the same further 22 nodes to both suites (one row in the selector deny
+Context and the two Contexts described below it), for 46 new nodes per suite.
@@ -490 +501 @@ Context `issue #671 worktree selector allow cases` — 7 rows, all NEW:
-Context `issue #671 worktree selector deny cases` — 17 rows, all NEW:
+Context `issue #671 worktree selector deny cases` — 18 rows, all NEW (the row immediately after the L8 row was added by remediation R1):
@@ -497,2 +508,2 @@ Context `issue #671 worktree selector deny cases` — 17 rows, all NEW:
-| `issue #671 LACS L3a - selector with no subcommand after the value` | `git -C C:/repo/wt` | deny |
-| `issue #671 LACS L3b - subcommand not immediately after the selector value` | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | deny |
+| `issue #671 LACS L3a - selector with no subcommand after the value` | `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` | deny |
+| `issue #671 LACS L3b - subcommand not immediately after the selector value` | `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` | deny |
@@ -505,0 +517 @@ Context `issue #671 worktree selector deny cases` — 17 rows, all NEW:
+| `issue #671 selector followed by an unmodelled subcommand` | `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` | deny |
@@ -514,0 +527,47 @@ and the row must isolate the selector axis.
+Every row in these tables must be classified by the gate's staging trigger, meaning it contains a
+`git add` or `git commit` invocation, or the gate allows it without consulting the exemption and
+the row cannot fail for the reason its label states. Remediation R1 replaced the original L3a and
+L3b commands for that reason: neither carried a subcommand the trigger recognizes.
+
+Context `issue #671 empty-token fail-closed cases` — 5 rows, all NEW (remediation R1):
+
+| Label | Command | Expected |
+| --- | --- | --- |
+| `issue #671 empty commit message beside an exempt operand` | `git commit -m "" -- docs/features/active/x/spec.md` | allow |
+| `issue #671 empty token beside a non-exempt operand` | `git add "" -- src/foo.ps1` | deny |
+| `issue #671 empty token after the separator beside a non-exempt operand` | `git add -- "" scripts/powershell/Sample.ps1` | deny |
+| `issue #671 trailing empty token after a non-exempt operand` | `git add -- src/foo.ts ""` | deny |
+| `issue #671 empty commit message beside a non-exempt operand` | `git commit -m "" -- src/foo.ts` | deny |
+
+Decision (remediation R1): an empty message value is consumed by `-m` and is not a pathspec, so
+`git commit -m "" -- <exempt operand>` allows. That command already allowed before remediation R1,
+through the empty-token fail-open, so its row pins an unchanged decision. The four deny rows pin
+decisions that remediation R1 changes from allow to deny.
+
+Context `issue #671 selector predicate and fail-closed guard` — 16 nodes, all NEW (remediation R1).
+The accept and reject rows call `Test-ExemptOrchestrationSelector -Token` directly through
+`It 'accepts <Label>'` and `It 'rejects <Label>'`. The guard node
+`It 'returns false when segment classification raises an error'` mocks
+`Test-ExemptOrchestrationSegmentToken` to throw and asserts that
+`Test-ExemptOrchestrationStagingCommand` returns false. The predicate checks only that a
+non-option token follows the selector value; the caller rejects any subcommand other than `add` or
+`commit`, and accept row 3 pins that division.
+
+| Label | Token array | Expected |
+| --- | --- | --- |
+| `issue #671 predicate accept 1 - drive-letter selector followed by add` | `git`, `-C`, `C:/repo/wt`, `add`, `--`, `docs/features/active/x/spec.md` | true |
+| `issue #671 predicate accept 2 - rooted selector followed by commit` | `git`, `-C`, `/repo/wt`, `commit`, `-m`, `msg`, `--`, `docs/features/active/x/spec.md` | true |
+| `issue #671 predicate accept 3 - non-option token after the value is left to the caller` | `git`, `-C`, `C:/repo/wt`, `status` | true |
+| `issue #671 predicate L1a - single token segment` | `git` | false |
+| `issue #671 predicate L1b - option other than the selector at index 1` | `git`, `-c`, `core.worktree=C:/repo/wt`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L2 - repeated selector` | `git`, `-C`, `C:/repo/wt`, `-C`, `C:/repo/other`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L3a - no token after the selector value` | `git`, `-C`, `C:/repo/wt` | false |
+| `issue #671 predicate L3b - option token after the selector value` | `git`, `-C`, `C:/repo/wt`, `--no-pager`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L4a - relative selector` | `git`, `-C`, `subdir`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L4b - UNC selector` | `git`, `-C`, `//server/share/wt`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L5a - parent-directory segment` | `git`, `-C`, `C:/repo/wt/../other`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L5b - current-directory segment` | `git`, `-C`, `C:/repo/./wt`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L6 - wildcard` | `git`, `-C`, `C:/repo/wt-?`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L7 - stray colon` | `git`, `-C`, `C:/repo/wt:branch`, `add`, `docs/features/active/x/spec.md` | false |
+| `issue #671 predicate L8 - empty selector value` | `git`, `-C`, (empty string), `add`, `docs/features/active/x/spec.md` | false |
+
@@ -630 +689 @@ Phase 0 fail-before capture. No manual step substitutes for an executed capture.
-- [x] The helpers diff is confined to one axis: in `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line's text occurs within the pre-change lines 227–236 block, and no hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks.
+- [ ] The helpers diff is confined to one axis plus the remediation R1 fail-closed repair: in `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line is one of (a) a line whose text occurs within the pre-change lines 227–236 block, (b) the pre-change line 221 `$Token` parameter declaration of `Test-ExemptOrchestrationSegmentToken`, re-added with `[AllowEmptyString()]` as its only change, or (c) a line of the pre-change per-segment loop at lines 342–347 of `Test-ExemptOrchestrationStagingCommand` whose whitespace-trimmed text equals the whitespace-trimmed text of a line added inside that function's fail-closed `try` block; and no other hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks.
@@ -638,2 +697,2 @@ Phase 0 fail-before capture. No manual step substitutes for an executed capture.
-- [ ] Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`, and coverage on the changed lines of the helpers file does not regress. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
-- [ ] The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` reports no file changed on a second invocation, `mcp__drm-copilot__run_poshqc_analyze` reports zero findings for the four edited helpers copies and the three test files, and `mcp__drm-copilot__run_poshqc_test` reports zero failed tests.
+- [ ] Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`; the per-file line coverage of the `.claude/hooks` copy of `enforce-orchestration-preimplementation-gate-helpers.ps1`, read from `artifacts/pester/powershell-coverage.xml`, is at or above its pre-change baseline of 94.92% (112 covered of 118); and every instrumented line of that file listed in the changed-line set of the helpers diff has a hit count above zero. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
+- [ ] The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` leaves the SHA256 hash of each of the four helpers copies and the three test files unchanged, as recorded by paired `Get-FileHash` captures taken before and after the call; a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` reports zero findings for each of those seven files, alongside a `mcp__drm-copilot__run_poshqc_analyze` call that returns without error; and `mcp__drm-copilot__run_poshqc_test` writes an `artifacts/pester/pester-junit.xml` whose failing nodes are none, or only one or both of the two failures present at the pre-change baseline (`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`), with no failing node whose name contains `issue #671`.
@@ -643,0 +703,2 @@ Phase 0 fail-before capture. No manual step substitutes for an executed capture.
+- [ ] The remediation R1 regression rows pass: nodes `denies issue #671 LACS L8 - empty selector value`, `denies issue #671 selector followed by an unmodelled subcommand`, `denies issue #671 empty token beside a non-exempt operand`, `denies issue #671 empty token after the separator beside a non-exempt operand`, `denies issue #671 trailing empty token after a non-exempt operand`, `denies issue #671 empty commit message beside a non-exempt operand`, and `allows issue #671 empty commit message beside an exempt operand` pass in both command-exemption suites, and an executed probe records `Test-ExemptOrchestrationStagingCommand` returning `False` with zero error records for `git add "" -- src/foo.ps1` and `git add -- "" scripts/powershell/Sample.ps1`.
+- [ ] The selector predicate and the fail-closed guard are pinned at the unit level (remediation R1): in both command-exemption suites, under the Context `issue #671 selector predicate and fail-closed guard`, the three `accepts issue #671 predicate accept` nodes, the twelve `rejects issue #671 predicate` nodes, and node `returns false when segment classification raises an error` all pass.
@@ -690,0 +752,20 @@ Phase 0 fail-before capture. No manual step substitutes for an executed capture.
+  - **Remediation R1 amendment (2026-09-17).** The first review
+    (`remediation-inputs.2026-09-17T08-40.md`) found three blocking defects. This amendment changes
+    criterion wording and fixture tables only; it adds no feature scope.
+    - The L3a and L3b fixtures carried no `add` or `commit` subcommand, so the gate never consulted
+      the exemption for them. They are replaced with commands the staging trigger classifies and
+      that reach the L3 rejection.
+    - A pre-existing empty-token fail-open let `Test-ExemptOrchestrationStagingCommand` answer true
+      after a parameter-binding error. The amendment permits exactly two further helpers edits:
+      `[AllowEmptyString()]` on the `$Token` parameter of `Test-ExemptOrchestrationSegmentToken`,
+      and a fail-closed `try`/`catch` around the per-segment loop of
+      `Test-ExemptOrchestrationStagingCommand`. The one-axis diff criterion is widened to exactly
+      those edits. The earlier statements that exactly one function body changes and that
+      `Test-ExemptOrchestrationStagingCommand` is unchanged are superseded to that extent.
+    - Direction: the amendment only narrows what the gate allows. Command lines that allowed only
+      through the fail-open now deny unless every operand is exempt. No command line that denied
+      before the amendment allows after it.
+    - Coverage: a deny row whose accepted selector is followed by a subcommand other than `add` or
+      `commit` restores coverage of the subcommand rejection in
+      `Test-ExemptOrchestrationSegmentToken`, and unit-level rows call
+      `Test-ExemptOrchestrationSelector` directly.
```

## `git status --porcelain` (verbatim)

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-batch-budget-reset.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-inputs-read.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/remediation-fail-before-probe.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/remediation-baseline/
```

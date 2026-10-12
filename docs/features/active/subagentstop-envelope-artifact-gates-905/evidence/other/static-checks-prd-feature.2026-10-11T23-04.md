# Static checks: validate-prd-feature-output (issue #905)

## [P5-T1] Rule R2 in Test-SpecNumericCriterion

Timestamp: 2026-10-11T23-04
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-prd-feature-output.ps1 -Simple '(?:all|exactly|the|these|those)\s+(?:[1-9]\d*|two|three||.github/copilot-instructions.md||.*\b\d+\b'''
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; `-SimpleMatch` counts are 1 for `(?:all|exactly|the|these|those)\s+(?:[1-9]\d*|two|three`, 1 for `.github/copilot-instructions.md`, and 0 for `.*\b\d+\b'` (the line-68 pattern tail). The function signature and the section regex line are unchanged; line 68 is replaced by the R2 loop of section 3.2. R-RESET: `P5-T1: none present`.

```text
FILE: .claude/hooks/validate-prd-feature-output.ps1
PARSE-ERRORS: 0
SIMPLE-COUNT: (?:all|exactly|the|these|those)\s+(?:[1-9]\d*|two|three | 1
SIMPLE-COUNT: .github/copilot-instructions.md | 1
SIMPLE-COUNT: .*\b\d+\b' | 0
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 109
```

## [P5-T2] Rule R3 in Test-NumericDerivationEvidence (prd-feature)

Timestamp: 2026-10-11T23-05
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r3-check.ps1 -Hook .claude/hooks/validate-prd-feature-output.ps1 -BaseSha 1011d98d7830aea7e53511a972b0868b323d5a44
EXIT_CODE: 0
Output Summary: MERGE_BASE (`git merge-base origin/epic/subagentstop-envelope-integration HEAD`) = 1011d98d7830aea7e53511a972b0868b323d5a44. BASE-OLD-PATTERN-COUNT: 1; CURRENT-NEW-PATTERN-COUNT: 1; CURRENT-OLD-PATTERN-COUNT: 0; R3-ONLY-CHANGE: YES; R3-PATTERN lines True, True, True, False for the four values. ParseFile reports 0 errors; `does not declare an exhaustive repository search scope.` count is 1. R-RESET: `P5-T2: none present`.

```text
HOOK: .claude/hooks/validate-prd-feature-output.ps1
BASE: 1011d98d7830aea7e53511a972b0868b323d5a44
BASE-OLD-PATTERN-COUNT: 1
CURRENT-NEW-PATTERN-COUNT: 1
CURRENT-OLD-PATTERN-COUNT: 0
R3-ONLY-CHANGE: YES
R3-PATTERN: entire worktree. | True
R3-PATTERN: the whole worktree, all directories. | True
R3-PATTERN: entire repository | True
R3-PATTERN: the hooks folder | False
```

```text
FILE: .claude/hooks/validate-prd-feature-output.ps1
PARSE-ERRORS: 0
SIMPLE-COUNT: does not declare an exhaustive repository search scope. | 1
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 109
```

## [P5-T3] Conversion of .claude/hooks/validate-prd-feature-output.ps1

Timestamp: 2026-10-11T23-06
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-prd-feature-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||RawPayload||\.output\b' -Simple '<line E>||Read-SubagentStopEnvelope -InputText $InputText||Exit-SubagentStopBlock -Message||<four pinned strings>' -TrimLine '<line E>||Set-StrictMode -Version Latest'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `RawPayload`, `\.output\b` returns no match; counts are 1 for the line E text, 1 for `Read-SubagentStopEnvelope -InputText $InputText`, and 0 for `Exit-SubagentStopBlock -Message`; line E (line 17) precedes `Set-StrictMode -Version Latest` (line 19); the four strings pinned at `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:86-93` (`narrow named-pattern`, `repeats the primary search strategy or query expression`, `count does not match its independently enumerated member set`, `numeric acceptance criterion requires an existing research-path`) are each present once. R-RESET: `P5-T3: none present`.

```text
FILE: .claude/hooks/validate-prd-feature-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , RawPayload , \.output\b | matches=0
SIMPLE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1
SIMPLE-COUNT: Read-SubagentStopEnvelope -InputText $InputText | 1
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 0
SIMPLE-COUNT: narrow named-pattern | 1
SIMPLE-COUNT: repeats the primary search strategy or query expression | 1
SIMPLE-COUNT: count does not match its independently enumerated member set | 1
SIMPLE-COUNT: numeric acceptance criterion requires an existing research-path | 1
TRIMLINE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1 | lines=17
TRIMLINE-COUNT: Set-StrictMode -Version Latest | 1 | lines=19
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 118
```

## [P5-T4] Pure-function tests of validate-prd-feature-output.Tests.ps1

Timestamp: 2026-10-11T23-06
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 -Absent 'RawPayload'
EXIT_CODE: 0
Output Summary: the scan for `RawPayload` returns no match; R-ITS prints PARSE-ERRORS: 0. `rejects empty, malformed, and output-free invocation payloads` is replaced by `rejects an invalid envelope and a blank assistant message` (four `.Ok` false assertions: `''`, `'{bad'`, `'{}'`, blank-message envelope); every `-RawPayload (@{ output = ... })` call is converted to `-InputText (New-SubagentStopEnvelopeJson -AssistantMessage ...)`; the builder is added to the top-level `BeforeAll`; the existing unfiltered mocks are left as they are. R-RESET: `P5-T4: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: RawPayload | matches=0
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | 222
```

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
IT-TITLE: allows a spec without numeric acceptance criteria | TAGS: NONE
IT-TITLE: detects a numeric spec acceptance criterion | TAGS: NONE
IT-TITLE: does not count numeric boxes outside Acceptance Criteria | TAGS: NONE
IT-TITLE: rejects a numeric claim without a complete research record | TAGS: NONE
IT-TITLE: rejects a research record whose independent cross-check disagrees | TAGS: NONE
IT-TITLE: accepts an independently exhaustive complete-family research record | TAGS: NONE
IT-TITLE: rejects an invalid envelope and a blank assistant message | TAGS: NONE
IT-TITLE: rejects missing and nonexistent spec paths | TAGS: NONE
IT-TITLE: accepts a nonnumeric spec without research evidence | TAGS: NONE
IT-TITLE: rejects numeric specs with missing or nonexistent research paths | TAGS: NONE
IT-TITLE: accepts matching numeric provenance and extracts artifact labels | TAGS: NONE
IT-TITLE: rejects every missing numeric-evidence field and a missing section | TAGS: NONE
IT-TITLE: rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records | TAGS: NONE
IT-TITLE: R2 triggers on <Name> | TAGS: NONE
IT-TITLE: R2 does not trigger on <Name> | TAGS: NONE
IT-TITLE: R3 accepts the exhaustive scope <Name> | TAGS: NONE
IT-TITLE: R3 rejects the exhaustive scope <Name> | TAGS: NONE
PARSE-ERRORS: 0
```

## [P5-T5] validate-prd-feature-output.Coverage.Tests.ps1

Timestamp: 2026-10-11T23-07
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 -Absent 'Invoke-PrdFeatureOutputEntry||CLAUDE_HOOK_INPUT is empty'
EXIT_CODE: 0
Output Summary: the issue #786 `Describe` (function `Invoke-PrdFeatureOutputEntry` and `blocks when CLAUDE_HOOK_INPUT is empty`) is deleted and the header `.DESCRIPTION` is rewritten for stdin-envelope feeding. The scan returns no match; R-ITS prints exactly the twelve F1 to F12 titles ([P2-T9] added no probe) and PARSE-ERRORS: 0. R-RESET: `P5-T5: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: Invoke-PrdFeatureOutputEntry , CLAUDE_HOOK_INPUT is empty | matches=0
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 200
```

```text
FILE: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
IT-TITLE: exits 2 with a stderr reason when last_assistant_message lacks an existing spec-path | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message carries an existing spec-path whose spec has no derived numeric criterion | TAGS: E3-Entry
IT-TITLE: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with the empty-message reason when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the spec-path file cannot be read | TAGS: E3-Entry
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a spec-path | TAGS: E3-Entry
IT-TITLE: exits 0 without a research-path when the acceptance criteria contain only non-derived numerals | TAGS: E3-Entry
IT-TITLE: exits 2 with a stderr reason when the research-path file cannot be read | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P6-T1] Blocking switch of .claude/hooks/validate-prd-feature-output.ps1

Timestamp: 2026-10-11T23-10
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-prd-feature-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||\bexit 1\b||Write-Error' -Simple 'Exit-SubagentStopBlock -Message' -TrimLine 'exit 0'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `\bexit 1\b`, `Write-Error` returns no match; `Exit-SubagentStopBlock -Message` count is 1; the trimmed line `exit 0` matches exactly one line (118). Only the tail block line changed (`git diff --stat 14aaf7c52 -- .claude/hooks/validate-prd-feature-output.ps1`: 1 insertion, 1 deletion). R-RESET: `P6-T1: none present`.

```text
FILE: .claude/hooks/validate-prd-feature-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , \bexit 1\b , Write-Error | matches=0
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 1
TRIMLINE-COUNT: exit 0 | 1 | lines=118
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 118
```

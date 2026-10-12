# Static checks: validate-task-researcher-output (issue #905)

## [P9-T1] Rule R1 in Test-IsValidResearchFileName

Timestamp: 2026-10-11T23-19
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-task-researcher-output.ps1 -Simple '<section 3.4 R1 literal>||T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$||<line 262 rejection message tail>'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the section 3.4 R1 literal occurs exactly once; `T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` occurs 0 times; the line 262 rejection message (`... does not match the required filename convention `<timestamp>-<short-name>-research.md` under docs/features/<feature>/research/ or docs/research/.`) is present once and unchanged. `git diff -U0 HEAD` shows a single hunk `@@ -97 +97 @@` (the regex literal line only). R-RESET: `P9-T1: none present`.

```text
FILE: .claude/hooks/validate-task-researcher-output.ps1
PARSE-ERRORS: 0
SIMPLE-COUNT: ^(?:(?:\d{4}-\d{2}-\d{2}(?:T\d{2}-?\d{2})?|\d{8})-[A-Za-z0-9][A-Za-z0-9-]*[-.]research|research(?:-addendum)?\.\d{4}-\d{2}-\d{2}(?:T\d{2}-\d{2})?)\.md$ | 1
SIMPLE-COUNT: T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$ | 0
SIMPLE-COUNT: does not match the required filename convention `<timestamp>-<short-name>-research.md` under docs/features/<feature>/research/ or docs/research/. | 1
LINES: .claude/hooks/validate-task-researcher-output.ps1 | 294
```

## [P9-T2] Rule R3 in Test-NumericDerivationEvidence (task-researcher)

Timestamp: 2026-10-11T23-19
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r3-check.ps1 -Hook .claude/hooks/validate-task-researcher-output.ps1 -BaseSha 1011d98d7830aea7e53511a972b0868b323d5a44
EXIT_CODE: 0
Output Summary: MERGE_BASE = 1011d98d7830aea7e53511a972b0868b323d5a44. BASE-OLD-PATTERN-COUNT: 1; CURRENT-NEW-PATTERN-COUNT: 1; CURRENT-OLD-PATTERN-COUNT: 0; R3-ONLY-CHANGE: YES; R3-PATTERN lines True, True, True, False (the values stated in [P5-T2]). ParseFile reports 0 errors; `does not declare an exhaustive repository search scope.` count is 1. R-RESET: `P9-T2: none present`.

```text
HOOK: .claude/hooks/validate-task-researcher-output.ps1
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
FILE: .claude/hooks/validate-task-researcher-output.ps1
PARSE-ERRORS: 0
SIMPLE-COUNT: does not declare an exhaustive repository search scope. | 1
LINES: .claude/hooks/validate-task-researcher-output.ps1 | 294
```

## [P9-T3] Conversion of .claude/hooks/validate-task-researcher-output.ps1 (#786 guard, prologue, tail)

Timestamp: 2026-10-11T23-20
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-task-researcher-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||RawPayload||\.output\b' -Simple '<line B>||<line E>||exit $dependencyDecision.ExitCode||Read-SubagentStopEnvelope -InputText $InputText||Exit-SubagentStopBlock -Message||<three pinned strings>' -TrimLine 'param()||<line B>||<line E>||Set-StrictMode -Version Latest'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `RawPayload`, `\.output\b` returns no match; counts are exactly 1 for line B, line E, `exit $dependencyDecision.ExitCode`, and `Read-SubagentStopEnvelope -InputText $InputText`, and 0 for `Exit-SubagentStopBlock -Message`; `param()` is line 26, line B is line 27 (the first statement after `param()`), line E is line 28, and `Set-StrictMode -Version Latest` is line 30, so line E precedes it; the strings pinned at `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:85-91` for the research hook (`narrow named-pattern`, `repeats the primary search strategy or query expression`, `count does not match its independently enumerated member set`) are present. R-RESET: `P9-T3: none present`.

```text
FILE: .claude/hooks/validate-task-researcher-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , RawPayload , \.output\b | matches=0
SIMPLE-COUNT: $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true } | 1
SIMPLE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1
SIMPLE-COUNT: exit $dependencyDecision.ExitCode | 1
SIMPLE-COUNT: Read-SubagentStopEnvelope -InputText $InputText | 1
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 0
SIMPLE-COUNT: narrow named-pattern | 1
SIMPLE-COUNT: repeats the primary search strategy or query expression | 1
SIMPLE-COUNT: count does not match its independently enumerated member set | 1
TRIMLINE-COUNT: param() | 1 | lines=26
TRIMLINE-COUNT: $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true } | 1 | lines=27
TRIMLINE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1 | lines=28
TRIMLINE-COUNT: Set-StrictMode -Version Latest | 1 | lines=30
LINES: .claude/hooks/validate-task-researcher-output.ps1 | 290
```

## [P9-T4] Pure-function tests of validate-task-researcher-output.Tests.ps1

Timestamp: 2026-10-11T23-21
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 -Absent 'RawPayload||CLAUDE_HOOK_INPUT'
EXIT_CODE: 0
Output Summary: the scan for `RawPayload` and `CLAUDE_HOOK_INPUT` returns no match; R-ITS prints PARSE-ERRORS: 0; R-SIZE (the `LINES:` line) is 417 (at most 500). The two anomaly tests are renamed `blocks with a payload anomaly when the input text is empty` and `blocks with a payload anomaly when the input text is malformed JSON`, each asserting `task-researcher hook: payload anomaly`; `blocks when the output field is empty` is renamed `blocks with the existing empty-output reason when the assistant message is blank` with a blank-message envelope; the twelve `$raw = @{ output = ... }` plus `-RawPayload $raw` pairs were converted to `-InputText (New-SubagentStopEnvelopeJson -AssistantMessage ...)` by `<SCRATCHPAD>/e905-tr-convert.ps1` (`CONVERTED-PAIRS: 12`); the builder is added to the top-level `BeforeAll`. R-RESET: `P9-T4: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: RawPayload , CLAUDE_HOOK_INPUT | matches=0
LINES: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | 417
```

```text
FILE: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
IT-TITLE: blocks with a payload anomaly when the input text is empty | TAGS: NONE
IT-TITLE: blocks when the output does not advertise a research-path token | TAGS: NONE
IT-TITLE: blocks with a payload anomaly when the input text is malformed JSON | TAGS: NONE
IT-TITLE: blocks with the existing empty-output reason when the assistant message is blank | TAGS: NONE
IT-TITLE: blocks when the research-path is not under a tracked research root | TAGS: NONE
IT-TITLE: blocks when the research-path filename does not match the documented convention | TAGS: NONE
IT-TITLE: allows termination when the research-path is valid and the file exists | TAGS: NONE
IT-TITLE: blocks when the advertised research file does not exist on disk | TAGS: NONE
IT-TITLE: accepts a feature-folder research path | TAGS: NONE
IT-TITLE: accepts a one-off research path under docs/research/ | TAGS: NONE
IT-TITLE: rejects the retired artifacts/research/ path with a message naming the new roots | TAGS: NONE
IT-TITLE: rejects a feature path that lacks a /research/ segment | TAGS: NONE
IT-TITLE: rejects a feature research path whose filename does not conform | TAGS: NONE
IT-TITLE: extracts a quoted research-path value | TAGS: NONE
IT-TITLE: returns true for valid research filenames | TAGS: NONE
IT-TITLE: returns false for invalid research filenames | TAGS: NONE
IT-TITLE: passes a non-matching research artifact unaffected | TAGS: NONE
IT-TITLE: blocks a matching artifact (by filename) missing the Automation Feasibility section | TAGS: NONE
IT-TITLE: passes a matching artifact (by content) that includes the Automation Feasibility section | TAGS: NONE
IT-TITLE: blocks a matching artifact whose body is empty | TAGS: NONE
IT-TITLE: blocks termination when a matching artifact omits the Automation Feasibility section | TAGS: NONE
IT-TITLE: extracts a research-path from a markdown link form | TAGS: NONE
IT-TITLE: returns null for a whitespace-only markdown-link path | TAGS: NONE
IT-TITLE: accepts research without a numeric spec criterion | TAGS: NONE
IT-TITLE: blocks a numeric spec claim without numeric derivation evidence | TAGS: NONE
IT-TITLE: blocks an incomplete family record and missing inclusion rules | TAGS: NONE
IT-TITLE: blocks disagreeing independent cross-check counts | TAGS: NONE
IT-TITLE: accepts an independently exhaustive complete-family derivation | TAGS: NONE
IT-TITLE: rejects a copied count that does not match the cross-check member set | TAGS: NONE
IT-TITLE: rejects a normalized duplicate search strategy | TAGS: NONE
IT-TITLE: rejects missing primary or cross-check evidence | TAGS: NONE
IT-TITLE: rejects mismatched member sets and missing comparison | TAGS: NONE
IT-TITLE: rejects missing complete-family declaration and exhaustive scope | TAGS: NONE
IT-TITLE: rejects a narrow named-pattern search that does not cover the declared family | TAGS: NONE
PARSE-ERRORS: 0
```

## [P10-T1] Blocking switch of .claude/hooks/validate-task-researcher-output.ps1

Timestamp: 2026-10-11T23-25
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-task-researcher-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||\bexit 1\b||Write-Error' -Simple 'Exit-SubagentStopBlock -Message' -TrimLine 'exit 0'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `\bexit 1\b`, `Write-Error` returns no match; `Exit-SubagentStopBlock -Message` count is 1; the trimmed line `exit 0` matches exactly one line (290). Only the tail block line changed (`git diff --stat fe96ab715 -- .claude/hooks/validate-task-researcher-output.ps1`: 1 insertion, 1 deletion). R-RESET: `P10-T1: none present`.

```text
FILE: .claude/hooks/validate-task-researcher-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , \bexit 1\b , Write-Error | matches=0
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 1
TRIMLINE-COUNT: exit 0 | 1 | lines=290
LINES: .claude/hooks/validate-task-researcher-output.ps1 | 290
```

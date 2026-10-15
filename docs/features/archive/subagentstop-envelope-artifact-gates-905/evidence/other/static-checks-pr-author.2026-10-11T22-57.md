# Static checks: validate-pr-author-output (issue #905)

## [P3-T1] Conversion of .claude/hooks/validate-pr-author-output.ps1

Timestamp: 2026-10-11T22-57
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-pr-author-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||HookInputRaw||\.output\b' -Simple '<line E>||Read-SubagentStopEnvelope -InputText $InputText||Exit-SubagentStopBlock -Message||PR_AUTHOR_OUTPUT_MISSING:||PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly||PR_AUTHOR_OUTPUT_EMPTY||PR_AUTHOR_OUTPUT_NO_PR'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the Select-String scan for `CLAUDE_HOOK_INPUT`, `HookInputRaw`, `\.output\b` returns no match; `-SimpleMatch` counts are 1 for the line E text, 1 for `Read-SubagentStopEnvelope -InputText $InputText`, and 0 for `Exit-SubagentStopBlock -Message`; the tokens `PR_AUTHOR_OUTPUT_MISSING:` (4), `PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly` (2), `PR_AUTHOR_OUTPUT_EMPTY` (2), and `PR_AUTHOR_OUTPUT_NO_PR` (2) are present. The file has 129 lines. R-RESET: `P3-T1: none present`.

Change summary (section 3.1, conversion bullet): help `.DESCRIPTION` rewritten for the stdin envelope; line E inserted directly after the bootstrap; `Test-PrAuthorOutputReportsPr` `.PARAMETER OutputText` rewritten; `Get-PrAuthorOutputDecision` help rewritten, `-HookInputRaw` replaced by `[AllowNull()] [AllowEmptyString()] [string] $InputText`, the two dependency statements kept, the payload parsing replaced by prologue P(PR_AUTHOR_OUTPUT_MALFORMED:), EMPTY and NO_PR reasons rewritten; the tail replaced by I(Get-PrAuthorOutputDecision).

```text
FILE: .claude/hooks/validate-pr-author-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , HookInputRaw , \.output\b | matches=0
SIMPLE-COUNT: try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ } | 1
SIMPLE-COUNT: Read-SubagentStopEnvelope -InputText $InputText | 1
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 0
SIMPLE-COUNT: PR_AUTHOR_OUTPUT_MISSING: | 4
SIMPLE-COUNT: PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly | 2
SIMPLE-COUNT: PR_AUTHOR_OUTPUT_EMPTY | 2
SIMPLE-COUNT: PR_AUTHOR_OUTPUT_NO_PR | 2
LINES: .claude/hooks/validate-pr-author-output.ps1 | 129
```

## [P3-T2] Pure-function tests of validate-pr-author-output.Tests.ps1

Timestamp: 2026-10-11T22-57
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 -Absent 'HookInputRaw||CLAUDE_HOOK_INPUT||Should -Be 1'
EXIT_CODE: 0
Output Summary: the Select-String scan for `HookInputRaw`, `CLAUDE_HOOK_INPUT`, and `Should -Be 1` returns no match; R-ITS prints PARSE-ERRORS: 0. The seven allow and block tests pass `-InputText (New-SubagentStopEnvelopeJson -AssistantMessage '<text>')`; the two renamed anomaly tests assert `PR_AUTHOR_OUTPUT_MALFORMED: payload anomaly`; `blocks when output is empty` is renamed `blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank`; the three environment-variable entry-point tests are deleted and P9 is kept ([P2-T9] added no probe). R-RESET: `P3-T2: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: HookInputRaw , CLAUDE_HOOK_INPUT , Should -Be 1 | matches=0
LINES: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | 113
```

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
IT-TITLE: allows when output contains a GitHub PR URL | TAGS: NONE
IT-TITLE: allows when output contains a PR #<n> reference | TAGS: NONE
IT-TITLE: allows when output contains a gh pr create confirmation with a PR number | TAGS: NONE
IT-TITLE: allows when output contains a gh pr edit confirmation with a PR number | TAGS: NONE
IT-TITLE: blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank | TAGS: NONE
IT-TITLE: blocks when output has no PR URL or number | TAGS: NONE
IT-TITLE: blocks with a payload anomaly when the input text is empty | TAGS: NONE
IT-TITLE: blocks with a payload anomaly when the input text is malformed JSON | TAGS: NONE
IT-TITLE: blocks when the output mentions gh pr create but has no PR number | TAGS: NONE
IT-TITLE: returns false for null/empty/whitespace output | TAGS: NONE
IT-TITLE: returns true for a PR URL | TAGS: NONE
IT-TITLE: returns false for prose with no PR reference | TAGS: NONE
IT-TITLE: exits 2 in a separate process when the stdin envelope lacks a PR reference | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P3-T3] validate-pr-author-output.Coverage.Tests.ps1

Timestamp: 2026-10-11T22-58
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 -Absent 'Should -Be 1||Invoke-PrAuthorOutputEntry'
EXIT_CODE: 0
Output Summary: the issue #786 `Describe` (function `Invoke-PrAuthorOutputEntry` and its two tests) is deleted and the header `.DESCRIPTION` describes stdin-envelope feeding. The scan for `Should -Be 1` and `Invoke-PrAuthorOutputEntry` returns no match; R-ITS prints exactly the eight P1 to P8 titles ([P2-T9] added no probe) and PARSE-ERRORS: 0. R-RESET: `P3-T3: none present`.

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: Should -Be 1 , Invoke-PrAuthorOutputEntry | matches=0
LINES: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 139
```

```text
FILE: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
IT-TITLE: exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference | TAGS: E3-Entry
IT-TITLE: exits 0 when last_assistant_message reports a pull request URL | TAGS: E3-Entry
IT-TITLE: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT | TAGS: E3-Entry
IT-TITLE: exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for empty stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason for malformed stdin | TAGS: E3-Entry
IT-TITLE: exits 2 with a payload anomaly reason when last_assistant_message is absent | TAGS: E3-Entry
IT-TITLE: keeps validating when stop_hook_active is true | TAGS: E3-Entry
PARSE-ERRORS: 0
```

## [P4-T1] Blocking switch of .claude/hooks/validate-pr-author-output.ps1

Timestamp: 2026-10-11T23-02
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/e905-static.ps1 -File .claude/hooks/validate-pr-author-output.ps1 -Absent 'CLAUDE_HOOK_INPUT||\bexit 1\b||Write-Error' -Simple 'Exit-SubagentStopBlock -Message' -TrimLine 'exit 0'
EXIT_CODE: 0
Output Summary: ParseFile reports 0 errors; the scan for `CLAUDE_HOOK_INPUT`, `\bexit 1\b`, `Write-Error` returns no match; `Exit-SubagentStopBlock -Message` count is 1; the trimmed line `exit 0` matches exactly one line (129). Only the tail block line changed (`git diff --stat 53cf0fb1f -- .claude/hooks/validate-pr-author-output.ps1`: 1 insertion, 1 deletion). R-RESET: `P4-T1: none present`.

```text
FILE: .claude/hooks/validate-pr-author-output.ps1
PARSE-ERRORS: 0
PATTERN-SCAN: CLAUDE_HOOK_INPUT , \bexit 1\b , Write-Error | matches=0
SIMPLE-COUNT: Exit-SubagentStopBlock -Message | 1
TRIMLINE-COUNT: exit 0 | 1 | lines=129
LINES: .claude/hooks/validate-pr-author-output.ps1 | 129
```

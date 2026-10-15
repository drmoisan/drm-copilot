# Phase 3 Helper Suite Pass-After Run (issue #897, epic child E1)

Timestamp: 2026-10-11T12-58
Task: [P3-T3]
Command: `Import-Module Pester -MinimumVersion 5.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1'); $cfg.Run.PassThru = $true; $cfg.Run.Exit = $false; $cfg.Output.Verbosity = 'Detailed'; $r = Invoke-Pester -Configuration $cfg` followed by the R-TARGETED container, failure, and total printers.
EXIT_CODE: 0
Output Summary: TOTAL passed=78 failed=0 skipped=0; `passed` equals `$r.TotalCount` (78); no `FAILED:` line. The helper implementation was not corrected after this run; no test was changed.

## Helper facts recorded for [P3-T1] and [P3-T2]

- `Get-Command Get-SubagentStopEnvelopeAnomalyReason` and `Get-Command Read-SubagentStopEnvelope` resolve after dot-sourcing (the AC-1 surface test passed).
- `(Get-Content .claude/hooks/subagentstop-envelope.ps1).Count`: 191 (at most 500).
- Parse: `[System.Management.Automation.Language.Parser]::ParseFile` reports 0 errors.
- Read-only format check: `Formatted: ` 0, `Already formatted: ` 1; analyzer: `PSScriptAnalyzer passed: no findings under .`.

## AC-to-test mapping used by [P3-T4]

- AC-1: `defines Read-SubagentStopEnvelope, Get-SubagentStopEnvelopeAnomalyReason and Exit-SubagentStopBlock`
- AC-4: Context `source constraints` (3 tests)
- AC-5: `classifies valid envelope ...`, `classifies ISO-date string message ...`, `returns the root fields of a valid envelope`, `keeps an ISO-8601 date-form message as the exact string`
- AC-6: `classifies empty string message ...`
- AC-7: `classifies null input ...`, `classifies empty string input ...`, `classifies whitespace-only input ...`, `classifies BOM-only input ...`
- AC-8: `classifies non-JSON text ...`, `classifies case-duplicate keys ...`
- AC-9: `classifies empty array ...`, `classifies single-element array ...`, `classifies multi-element array ...`, `classifies number root ...`, `classifies string root ...`, `classifies boolean root ...`, `classifies JSON null root ...`
- AC-10: `classifies object without last_assistant_message ...`
- AC-11: `classifies null last_assistant_message ...`
- AC-12: `classifies number|boolean|object|array last_assistant_message ...` (4 tests)
- AC-13: `emits exactly one object with exactly the seven contract properties for <Name>` (22 tests)
- AC-14: Context `derived fields` (10 tests)
- AC-15: Context `BOM and CRLF input` (2 tests)
- AC-16: Context `stdin default` (3 tests)
- AC-17: Context `anomaly reasons` (11 tests)
- AC-18: `blocks through the & route with stderr and exit code 2`
- AC-19: `rejects an empty or null Message at parameter binding without exiting`

## Detailed per-test results

```text
Describing subagentstop-envelope helper
  [+] defines Read-SubagentStopEnvelope, Get-SubagentStopEnvelopeAnomalyReason and Exit-SubagentStopBlock
 Context source constraints
   [+] reads no environment variable
   [+] imports and dot-sources nothing
   [+] writes nothing to the success, host, information or warning streams
 Context input-to-result rows
   [+] classifies valid envelope with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies ISO-date string message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies empty string message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies null input with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies empty string input with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies whitespace-only input with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies BOM-only input with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies non-JSON text with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies case-duplicate keys with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies empty array with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies single-element array with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies multi-element array with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies number root with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies string root with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies boolean root with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies JSON null root with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies object without last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies null last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies number last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies boolean last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies object last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] classifies array last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText
   [+] returns the root fields of a valid envelope
   [+] keeps an ISO-8601 date-form message as the exact string
   [+] emits exactly one object with exactly the seven contract properties for valid envelope
   [+] emits exactly one object with exactly the seven contract properties for ISO-date string message
   [+] emits exactly one object with exactly the seven contract properties for empty string message
   [+] emits exactly one object with exactly the seven contract properties for null input
   [+] emits exactly one object with exactly the seven contract properties for empty string input
   [+] emits exactly one object with exactly the seven contract properties for whitespace-only input
   [+] emits exactly one object with exactly the seven contract properties for BOM-only input
   [+] emits exactly one object with exactly the seven contract properties for non-JSON text
   [+] emits exactly one object with exactly the seven contract properties for case-duplicate keys
   [+] emits exactly one object with exactly the seven contract properties for empty array
   [+] emits exactly one object with exactly the seven contract properties for single-element array
   [+] emits exactly one object with exactly the seven contract properties for multi-element array
   [+] emits exactly one object with exactly the seven contract properties for number root
   [+] emits exactly one object with exactly the seven contract properties for string root
   [+] emits exactly one object with exactly the seven contract properties for boolean root
   [+] emits exactly one object with exactly the seven contract properties for JSON null root
   [+] emits exactly one object with exactly the seven contract properties for object without last_assistant_message
   [+] emits exactly one object with exactly the seven contract properties for null last_assistant_message
   [+] emits exactly one object with exactly the seven contract properties for number last_assistant_message
   [+] emits exactly one object with exactly the seven contract properties for boolean last_assistant_message
   [+] emits exactly one object with exactly the seven contract properties for object last_assistant_message
   [+] emits exactly one object with exactly the seven contract properties for array last_assistant_message
 Context derived fields
   [+] sets StopHookActive from a stop_hook_active value that is boolean true
   [+] sets StopHookActive from a stop_hook_active value that is boolean false
   [+] sets StopHookActive from a stop_hook_active value that is absent
   [+] sets StopHookActive from a stop_hook_active value that is string "true"
   [+] sets AgentType when the root field is present as a string
   [+] sets AgentType when the root field is absent
   [+] sets AgentType when the root field is the non-string 5
   [+] sets HookEventName when the root field is present as a string
   [+] sets HookEventName when the root field is absent
   [+] sets HookEventName when the root field is the non-string 5
 Context BOM and CRLF input
   [+] accepts a BOM-prefixed valid envelope
   [+] accepts a CRLF-formatted valid envelope
 Context stdin default
   [+] reads the envelope from stdin when InputText is not bound
   [+] treats a stdin read failure as EmptyPayload
   [+] prefers a bound empty InputText over non-empty stdin
 Context anomaly reasons
   [+] returns a non-empty clause for EmptyPayload
   [+] returns a non-empty clause for UnparseableJson
   [+] returns a non-empty clause for NonObjectEnvelope
   [+] returns a non-empty clause for MissingAssistantMessage
   [+] returns a non-empty clause for NullAssistantMessage
   [+] returns a non-empty clause for NonStringAssistantMessage
   [+] returns six pairwise distinct clauses
   [+] throws ArgumentException for an unknown code
   [+] throws ArgumentException for null
   [+] throws ArgumentException for an empty string
   [+] throws ArgumentException for a case variant
 Context Exit-SubagentStopBlock
   [+] blocks through the & route with stderr and exit code 2
   [+] rejects an empty or null Message at parameter binding without exiting
```

## R-TARGETED output (after R-REDACT)

```text
CONTAINER: tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | result=Passed | passed=78 | failed=0
TOTAL: passed=78 failed=0 skipped=0
TOTALCOUNT: 78
```

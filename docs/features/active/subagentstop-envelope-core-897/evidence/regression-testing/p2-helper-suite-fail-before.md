# Phase 2 Helper Suite Fail-Before Run (issue #897, epic child E1)

Timestamp: 2026-10-11T12-54
Task: [P2-T9] [expect-fail]
Command: `Import-Module Pester -MinimumVersion 5.0 -Force; $cfg = New-PesterConfiguration; $cfg.Run.Path = @('tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1'); $cfg.Run.PassThru = $true; $cfg.Run.Exit = $false; $cfg.Output.Verbosity = 'Detailed'; $r = Invoke-Pester -Configuration $cfg` followed by the R-TARGETED container, failure, and total printers.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: expected failure observed. 78 tests discovered; passed=5 failed=73 skipped=0. The 5 passing tests are the three AC-4 source-constraint tests and the two AC-18/AC-19 exit-block tests. The 73 failures are: 1 surface test (AC-1) reporting a null `Get-Command` result; 61 tests reporting `Read-SubagentStopEnvelope` is not recognized; 7 tests reporting `Get-SubagentStopEnvelopeAnomalyReason` is not recognized; 4 `Should -Throw -ExceptionType ([System.ArgumentException])` tests reporting that the exception type was `[System.Management.Automation.CommandNotFoundException]`. No failure falls outside the AC-1 and AC-5 to AC-17 groups.

## Suite facts recorded for [P2-T1] to [P2-T8]

- `(Get-Content tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1).Count`: 278 (at most 450)
- Parse: `[System.Management.Automation.Language.Parser]::ParseFile` reports 0 errors.
- [P2-T5] BOM check: `(Get-Content -Raw tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1).IndexOf([char]0xFEFF, 1)` = -1 (no BOM character stored in the file body); the file contains no literal carriage return (`CRLF_LITERAL_CR_IN_FILE: False`).
- [P2-T5] CRLF test source line (line 174 after the [P2-T2] restructuring; the line is unchanged), quoted verbatim, uses the backtick-r escape rather than a literal carriage return:

```powershell
$result = Read-SubagentStopEnvelope -InputText "{`r`n  ""last_assistant_message"": ""crlf""`r`n}"
```

- Analyzer note: the first draft of `Get-HelperCommandAst` referenced its `Names` parameter only inside a nested `FindAll` scriptblock, which `PSReviewUnusedParameter` reported as unused; the function was restructured to filter in a `foreach` loop before this run. Read-only format check: `Formatted: ` 0, `Already formatted: ` 1; analyzer: `PSScriptAnalyzer passed: no findings under .`.

## Passing tests (5)

```text
Context source constraints
  [+] reads no environment variable
  [+] imports and dot-sources nothing
  [+] writes nothing to the success, host, information or warning streams
Context Exit-SubagentStopBlock
  [+] blocks through the & route with stderr and exit code 2
  [+] rejects an empty or null Message at parameter binding without exiting
```

## Failure message groups (73)

```text
  1  Expected a value, but got $null or empty.   (surface test, AC-1)
 61  The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
  7  The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
  4  Expected an exception with type [System.ArgumentException] to be thrown, but the exception type was [System.Management.Automation.CommandNotFoundException]. from .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1:250 char:15
```

## R-TARGETED output (after R-REDACT)

```text
CONTAINER: tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | result=Failed | passed=5 | failed=73
FAILED: subagentstop-envelope helper.defines Read-SubagentStopEnvelope, Get-SubagentStopEnvelopeAnomalyReason and Exit-SubagentStopBlock | Expected a value, but got $null or empty.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies valid envelope with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies ISO-date string message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies empty string message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies null input with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies empty string input with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies whitespace-only input with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies BOM-only input with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies non-JSON text with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies case-duplicate keys with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies empty array with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies single-element array with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies multi-element array with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies number root with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies string root with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies boolean root with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies JSON null root with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies object without last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies null last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies number last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies boolean last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies object last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.classifies array last_assistant_message with the expected IsValid, Anomaly, Envelope and AssistantText | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.returns the root fields of a valid envelope | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.keeps an ISO-8601 date-form message as the exact string | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for valid envelope | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for ISO-date string message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for empty string message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for null input | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for empty string input | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for whitespace-only input | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for BOM-only input | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for non-JSON text | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for case-duplicate keys | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for empty array | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for single-element array | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for multi-element array | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for number root | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for string root | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for boolean root | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for JSON null root | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for object without last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for null last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for number last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for boolean last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for object last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.input-to-result rows.emits exactly one object with exactly the seven contract properties for array last_assistant_message | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets StopHookActive from a stop_hook_active value that is boolean true | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets StopHookActive from a stop_hook_active value that is boolean false | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets StopHookActive from a stop_hook_active value that is absent | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets StopHookActive from a stop_hook_active value that is string "true" | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets AgentType when the root field is present as a string | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets AgentType when the root field is absent | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets AgentType when the root field is the non-string 5 | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets HookEventName when the root field is present as a string | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets HookEventName when the root field is absent | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.derived fields.sets HookEventName when the root field is the non-string 5 | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.BOM and CRLF input.accepts a BOM-prefixed valid envelope | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.BOM and CRLF input.accepts a CRLF-formatted valid envelope | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.stdin default.reads the envelope from stdin when InputText is not bound | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.stdin default.treats a stdin read failure as EmptyPayload | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.stdin default.prefers a bound empty InputText over non-empty stdin | The term 'Read-SubagentStopEnvelope' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for EmptyPayload | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for UnparseableJson | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for NonObjectEnvelope | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for MissingAssistantMessage | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for NullAssistantMessage | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns a non-empty clause for NonStringAssistantMessage | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.returns six pairwise distinct clauses | The term 'Get-SubagentStopEnvelopeAnomalyReason' is not recognized as a name of a cmdlet, function, script file, or executable program.
FAILED: subagentstop-envelope helper.anomaly reasons.throws ArgumentException for an unknown code | Expected an exception with type [System.ArgumentException] to be thrown, but the exception type was [System.Management.Automation.CommandNotFoundException]. from .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1:250 char:15
FAILED: subagentstop-envelope helper.anomaly reasons.throws ArgumentException for null | Expected an exception with type [System.ArgumentException] to be thrown, but the exception type was [System.Management.Automation.CommandNotFoundException]. from .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1:250 char:15
FAILED: subagentstop-envelope helper.anomaly reasons.throws ArgumentException for an empty string | Expected an exception with type [System.ArgumentException] to be thrown, but the exception type was [System.Management.Automation.CommandNotFoundException]. from .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1:250 char:15
FAILED: subagentstop-envelope helper.anomaly reasons.throws ArgumentException for a case variant | Expected an exception with type [System.ArgumentException] to be thrown, but the exception type was [System.Management.Automation.CommandNotFoundException]. from .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1:250 char:15
TOTAL: passed=5 failed=73 skipped=0
```

# Upstream contract record (issue #905, AC-01)

Timestamp: 2026-10-11T14-41
Command: git ls-tree -r --name-only HEAD -- docs/features (filtered to the line ending subagentstop-envelope-core-897/spec.md)
EXIT_CODE: 0
Output Summary: E1 spec located at docs/features/active/subagentstop-envelope-core-897/spec.md (one line). Its Authoritative Helper Contract (lines 10-82) names the three function headings, the seven result fields, the six anomaly codes, and consumer-policy item 3 naming -InputText. All UCR contract fields hold permitted values.

## Filled record

```text
UCR-E1-SPEC-PATH: docs/features/active/subagentstop-envelope-core-897/spec.md
UCR-HELPER-PATH: .claude/hooks/subagentstop-envelope.ps1
UCR-READ-SIGNATURE: Read-SubagentStopEnvelope [-InputText <string>], InputText declared [AllowNull()][AllowEmptyString()][string]
UCR-RESULT-FIELDS: IsValid, Anomaly, Envelope, AssistantText, StopHookActive, AgentType, HookEventName
UCR-ANOMALY-CODES: EmptyPayload, UnparseableJson, NonObjectEnvelope, MissingAssistantMessage, NullAssistantMessage, NonStringAssistantMessage
UCR-REASON-SIGNATURE: Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>
UCR-EXIT-SIGNATURE: Exit-SubagentStopBlock -Message <string>
UCR-CONSUMER-POLICY-INPUTTEXT: YES
UCR-ISINPUTREDIRECTED-MATCHES: 0
```

## Source lines (E1 spec)

- Line 24: `### \`Read-SubagentStopEnvelope [-InputText <string>]\``
- Line 26: `- \`-InputText\` is declared \`[AllowNull()][AllowEmptyString()][string]\`.`
- Lines 35-41: result-field table rows `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`.
- Lines 47-52: anomaly codes `EmptyPayload`, `UnparseableJson`, `NonObjectEnvelope`, `MissingAssistantMessage`, `NullAssistantMessage`, `NonStringAssistantMessage`.
- Line 59: `### \`Get-SubagentStopEnvelopeAnomalyReason -Anomaly <string>\``
- Line 65: `### \`Exit-SubagentStopBlock -Message <string>\``
- Line 75: `3. Validator pure entry points take \`-InputText\` (passed through to \`Read-SubagentStopEnvelope\`) instead of \`-RawPayload $env:CLAUDE_HOOK_INPUT\`.`

## Helper surface ([P0-T7], fresh process through R-ROUTE option b)

```text
PARSE-ERRORS: 0
FUNCTION: Get-SubagentStopEnvelopeAnomalyReason
FUNCTION: Read-SubagentStopEnvelope
FUNCTION: Exit-SubagentStopBlock
PARAM: Get-SubagentStopEnvelopeAnomalyReason -Anomaly | [Parameter()][AllowNull()][AllowEmptyString()][string]
PARAM: Read-SubagentStopEnvelope -InputText | [Parameter()][AllowNull()][AllowEmptyString()][string]
PARAM: Exit-SubagentStopBlock -Message | [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]
ISINPUTREDIRECTED-MATCHES: 0
ISINPUTREDIRECTED-TEXT-MATCHES: 0
HASH: .claude/hooks/subagentstop-envelope.ps1 | 2cc85967e7755907f77ee7263298f0af7739d7aa
HASH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1 | 2cc85967e7755907f77ee7263298f0af7739d7aa
```

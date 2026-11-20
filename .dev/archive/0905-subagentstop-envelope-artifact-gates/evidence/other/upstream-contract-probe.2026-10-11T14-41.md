# Upstream contract probe (issue #905, AC-01)

Timestamp: 2026-10-11T14-41
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/probe-helper.ps1
EXIT_CODE: 0
Output Summary: valid/blank envelopes IsValid=True with the expected text; missing, empty, malformed map to MissingAssistantMessage, EmptyPayload, UnparseableJson; each reason clause non-empty; stdin read returns probe-text-905; Exit-SubagentStopBlock in process sets LASTEXITCODE 2 and writes probe-block-905 to stderr. UCR-PROBE: PASS, UCR-IN-PROCESS-EXIT: 2.

## Printed lines

```text
PROBE: valid | IsValid=True | Anomaly= | Text=probe-text-905 | StopHookActive=True
PROBE: blank | IsValid=True | Anomaly= | Text= | StopHookActive=True
PROBE: missing | IsValid=False | Anomaly=MissingAssistantMessage | Text= | StopHookActive=True
PROBE: empty | IsValid=False | Anomaly=EmptyPayload | Text= | StopHookActive=False
PROBE: malformed | IsValid=False | Anomaly=UnparseableJson | Text= | StopHookActive=False
REASON: MissingAssistantMessage | the SubagentStop payload has no last_assistant_message field
REASON: EmptyPayload | the SubagentStop payload on stdin was empty
REASON: UnparseableJson | the SubagentStop payload is not valid JSON
PROBE-STDIN-TEXT: probe-text-905
PROBE-EXIT: 2
PROBE-STDERR: probe-block-905
```

UCR-PROBE: PASS
UCR-IN-PROCESS-EXIT: 2

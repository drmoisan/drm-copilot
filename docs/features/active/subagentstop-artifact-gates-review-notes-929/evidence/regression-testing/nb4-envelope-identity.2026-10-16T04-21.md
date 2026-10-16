# NB-4 Envelope Identity (P8-T13)

Timestamp: 2026-10-16T04-21

Command: sh SCRATCH/929/P8-T13-1.sh
Script: `. ./tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1; 'HAS_AGENTTYPE=' + (Get-Command ConvertTo-SubagentStopEnvelopeJson).Parameters.ContainsKey('AgentType'); 'A=' + ((ConvertTo-SubagentStopEnvelopeJson -AgentType 'prd-feature' -AssistantMessage 'x') -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"prd-feature","stop_hook_active":false,"last_assistant_message":"x"}'); 'B=' + ((ConvertTo-SubagentStopEnvelopeJson -OmitAssistantMessage -OutputField 'y') -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"general-purpose","stop_hook_active":false,"output":"y"}'); 'C=' + ((ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -StopHookActive) -ceq '{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"task-researcher","stop_hook_active":true,"last_assistant_message":""}')`
EXIT_CODE: 0
Output:
```
HAS_AGENTTYPE=True
A=True
B=True
C=True
```

Output Summary: `HAS_AGENTTYPE=True`, `A=True`, `B=True`, `C=True`. The shared helper produces case-sensitively identical JSON to the removed local builders for the three inputs; B also confirms the `general-purpose` default (AC-07).

# D13 real process output — main-sync cycle 1 ([P0-T5], finding F2)

Timestamp: 2026-11-14T07-19
Command: sh SCRATCH/issue-1159-c1-d13.sh -- pwsh 7: for each registered hook whose content changed between merge bases 063504dc4b2ea08a2c5bd39b57d70ce5963815ed and 2c8dee6dd3a82f210561d9efe623767ae902de51, one `pwsh -NoProfile -File <hook>` process per envelope, with the envelope on redirected stdin and the worktree root as working directory. The in-function decision is read by a separate `pwsh -NoProfile -File SCRATCH/issue-1159-c1-d13-inproc.ps1` process. That process dot-sources the hook and calls its decision entry (Invoke-DocsCompleteGateEntryPoint, Invoke-OrchestrationPreimplementationGateEntryPoint, or Invoke-ModelRoutingReceiptDecision) with the same text on a redirected console. git status --porcelain is compared before and after.
EXIT_CODE: 0
Output Summary: 4 hooks and 8 runs (one allow-shaped and one deny-shaped envelope each). FailOpen: no for all 4. Every deny-shaped envelope produces a process-level deny. The three Claude hooks print the deny JSON on stdout with exit 0. The Codex preimplementation gate exits 2 with a stderr reason. Unhandled set (a) from [P0-T4] is empty, so no further hook was probed. No hook wrote a file (git status --porcelain unchanged). [P1-T2] takes its N/A branch.

Definitions: a process decision is deny when the process exits 2 or its stdout carries `"permissionDecision":"deny"`; `FailOpen: yes` means the deny-shaped envelope has an in-function decision of deny and a process decision other than deny.

## `.claude/hooks/enforce-docs-complete-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Bash git status | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"DOCS_COMPLETE_GATE_BLOCKED: PAYLOAD_ANOMALY: the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.claude/hooks/enforce-model-routing-receipt.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"MODEL_ROUTING_RECEIPT_BLOCKED: payload anomaly - the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Bash git status | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"PREIMPLEMENTATION_GATE_BLOCKED: payload anomaly - the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Bash git status | 0 | (empty) | (empty) | none | n/a (inline tail, no entry function; the process decision is the decision) |
| deny: malformed envelope {not-json | 2 | (empty) | `enforce-orchestration-preimplementation-gate hook input is malformed JSON: Conversion from JSON failed with error: Invalid JavaScript property identifier character: -. Path '', line 1, position 4.` | deny | n/a (inline tail; exit 2 from its catch block) |

FailOpen: no

Envelopes: the allow envelopes carry session_id d13-probe, hook_event_name PreToolUse, the worktree root as cwd (replaced at run time, not recorded), and the tool named in the row. The deny envelope is the malformed text `{not-json`. Payload files were written under SCRATCH only.

# Regression testing — Post-fix merge-gate differential (AC-2, AC-3, AC-4 complement) (#501)

Timestamp: 2026-08-22T00-10

Task: [P5-T3]

Session: atomic-executor subagent session. Commands issued through a `pwsh -NoProfile -File` probe script run from the worktree root, so each case states its own full environment and is independently reproducible out of sequence.

Baseline for comparison: `evidence/baseline/2026-08-21T22-11-merge-gate-differential-prefix.md` ([P0-T6]).

## Preconditions (unchanged from the baseline)

```
artifacts/orchestration contents: orchestrator-state.json
epic_mode=False step9_status=pending
epic checkpoint present=False
parallel checkpoint present=False
```

No allow-branch of `Invoke-EpicMergeGateDecision` is satisfiable, so a correctly-functioning gate must deny.

## Case 1 (AC-2) — both environment variables unset, nested envelope piped on stdin

Command:

```powershell
Remove-Item Env:CLAUDE_TOOL_INPUT -ErrorAction SilentlyContinue
Remove-Item Env:CLAUDE_HOOK_INPUT -ErrorAction SilentlyContinue
'{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}' | pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
```

In-case environment verification: `CLAUDE_TOOL_INPUT set=False CLAUDE_HOOK_INPUT set=False`

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == \"passed\", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == \"success\" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == \"parallel\" whose target item (matched by pr_number) has merge_status == \"ci_green\". No checkpoint satisfied this gate."}}
```

Result: **deny**, reason begins `EPIC_MERGE_GATE_BLOCKED:`. Baseline was **allow**. AC-2 satisfied.

## Case 2 (AC-3) — `CLAUDE_HOOK_INPUT` unset and verified in-case, `CLAUDE_TOOL_INPUT` = nested envelope, empty stdin

Empty stdin is produced by piping an empty string, which gives a redirected, whitespace-only stdin that the reader's precedence rule skips in favour of the environment fallback.

Command:

```powershell
Remove-Item Env:CLAUDE_HOOK_INPUT -ErrorAction SilentlyContinue
$env:CLAUDE_TOOL_INPUT = '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}'
'' | pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
```

In-case environment verification: `CLAUDE_HOOK_INPUT set=False CLAUDE_TOOL_INPUT set=True`

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == \"passed\", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == \"success\" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == \"parallel\" whose target item (matched by pr_number) has merge_status == \"ci_green\". No checkpoint satisfied this gate."}}
```

Result: **deny**, same `EPIC_MERGE_GATE_BLOCKED:` reason as case 1. Baseline was **allow**. AC-3 satisfied, and the shape fix is demonstrated independently of the transport fix.

## Case 3 (AC-4 complement) — `CLAUDE_HOOK_INPUT` unset and verified in-case, `CLAUDE_TOOL_INPUT` = flat shape, empty stdin

Command:

```powershell
Remove-Item Env:CLAUDE_HOOK_INPUT -ErrorAction SilentlyContinue
$env:CLAUDE_TOOL_INPUT = '{"command":"gh pr merge 999 --merge"}'
'' | pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
Remove-Item Env:CLAUDE_TOOL_INPUT
```

In-case environment verification: `CLAUDE_HOOK_INPUT set=False CLAUDE_TOOL_INPUT set=True`; after the case, `CLAUDE_TOOL_INPUT set=False`.

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: payload anomaly - the hook received a JSON payload with no tool_input key (the legacy flat root shape is an envelope anomaly, not a supported payload). The gate fails closed on an envelope it cannot read."}}
```

Result: **deny**, naming the missing-`tool_input` envelope anomaly. Baseline was a deny for the *decision-logic* reason (the flat shape was the only shape the pre-fix hook could read). The reason text is now the anomaly clause, confirming the strict reader rejects the legacy flat shape rather than honouring it.

## Live-gate observation recorded during this task

The first attempt to write this artifact used a Bash heredoc whose body quotes the merge command. `enforce-epic-merge-gate.ps1` — migrated in batch B1 and therefore live against this session — denied that tool call with `EPIC_MERGE_GATE_BLOCKED:`. The artifact was written through the Write tool instead. This is an incidental in-session confirmation that the gate is enforcing against real tool calls, consistent with the [P7-T6] probe.

## Output Summary

All three cases deny and all three exit 0. The differential against the [P0-T6] baseline is:

| Case | Pre-fix | Post-fix |
| --- | --- | --- |
| 1 — stdin, nested envelope | allow | deny, `EPIC_MERGE_GATE_BLOCKED:` (checkpoint reason) |
| 2 — `CLAUDE_TOOL_INPUT`, nested envelope | allow | deny, `EPIC_MERGE_GATE_BLOCKED:` (checkpoint reason) |
| 3 — `CLAUDE_TOOL_INPUT`, flat shape | deny (checkpoint reason) | deny, `EPIC_MERGE_GATE_BLOCKED: payload anomaly - ... no tool_input key` |

Command: the three cases above, driven from `scratchpad/p5t3_differential.ps1`.

EXIT_CODE: 0 (every hook invocation, and the driving script)

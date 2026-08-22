# Baseline — Pre-fix merge-gate differential (fail-before for AC-2 / AC-3) (#501)

Timestamp: 2026-08-21T22-11

Task: [P0-T6]

Session: atomic-executor subagent session (not the main orchestrator session). Commands were issued through a `pwsh -NoProfile -File` probe script run from the worktree root.

## Preconditions verified

`artifacts/orchestration/orchestrator-state.json` is the only checkpoint present in `artifacts/orchestration/`. Its `epic_mode` is `False` and its `step9_status` is `pending`; `epic-orchestrator-state.json` and `parallel-orchestrator-state.json` do not exist. No allow-branch of `Invoke-EpicMergeGateDecision` is therefore satisfiable, so a correctly-functioning gate must deny.

Command: `python -c "import json; d=json.load(open('artifacts/orchestration/orchestrator-state.json')); print(d.get('epic_mode'), d.get('step9_status'))"`

EXIT_CODE: 0

Output Summary (preconditions): `epic_mode False`, `step9_status pending`; `ls artifacts/orchestration/` lists only `orchestrator-state.json`.

## Case 1 — `CLAUDE_TOOL_INPUT` set to the nested envelope

Command:

```powershell
$env:CLAUDE_TOOL_INPUT = '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}'
Remove-Item Env:CLAUDE_HOOK_INPUT -ErrorAction SilentlyContinue
pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
```

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

Result: **allow** — the defective pre-fix result. The shape defect (root read of `command`) makes `$commandText` null, so the guard returns the allow decision before any checkpoint logic runs.

## Case 2 — `CLAUDE_TOOL_INPUT` set to the flat shape

Command:

```powershell
$env:CLAUDE_TOOL_INPUT = '{"command":"gh pr merge 999 --merge"}'
pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
```

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == \"passed\", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == \"success\" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == \"parallel\" whose target item (matched by pr_number) has merge_status == \"ci_green\". No checkpoint satisfied this gate."}}
```

Result: **deny**, reason begins `EPIC_MERGE_GATE_BLOCKED:` — the decision logic is sound; only the shape it reads is wrong.

## Case 3 — env vars removed, nested envelope piped on stdin (true harness transport)

Command:

```powershell
Remove-Item Env:CLAUDE_TOOL_INPUT -ErrorAction SilentlyContinue
Remove-Item Env:CLAUDE_HOOK_INPUT -ErrorAction SilentlyContinue
'{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}' | pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
```

EXIT_CODE: 0

Emitted decision, verbatim:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

Result: **allow** — the defective pre-fix result. The transport defect (env-only read, stdin never read) makes `$ToolInputRaw` empty, so the hook returns allow one guard earlier still.

## Output Summary

Pre-fix differential recorded as (1) allow, (2) deny with reason beginning `EPIC_MERGE_GATE_BLOCKED:`, (3) allow — matching the research Q8 prediction exactly. Cases 1 and 3 are the fail-before evidence for AC-3 and AC-2 respectively: both must become `EPIC_MERGE_GATE_BLOCKED:` denies after the fix ([P5-T3]). Case 2 must become a deny naming the missing-`tool_input` envelope anomaly after the fix, because the flat shape is an envelope anomaly under the strict reader. All three cases exited 0.

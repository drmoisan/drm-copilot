# Phase 4 Inline SubagentStop Command: Per-Agent Matcher Statement (issue #897, epic child E1)

Timestamp: 2026-10-11T13-01
Task: operator corpus false-positive gate, written before [P4-T1] and [P4-T2] delete the inline command.
Sources: `docs/features/active/subagentstop-envelope-core-897/spec.md` section `### Inline SubagentStop command analysis` (per-agent table and decision) and `docs/features/active/subagentstop-envelope-core-897/research/research.2026-10-11T12-15.md` section `R3. The inline SubagentStop command` (per-agent analysis with agent-file citations and the Numeric Derivation Evidence for the count of fifteen).

## The command being deleted

`.claude/settings.json` line 218 (identical in the bundled copy), JSON-unescaped:

```text
pwsh -NoProfile -Command "$input = $env:CLAUDE_HOOK_INPUT | ConvertFrom-Json; $output = $input.output; if (-not ($output -match '(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)')) { Write-Error 'Subagent stopped without required completion artifact path'; exit 1 }; exit 0"
```

Its pattern is `(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)`, matched case-insensitively. The command reads `CLAUDE_HOOK_INPUT` (never set on a real SubagentStop), takes `output` off the parsed root (absent on the real envelope), and blocks with `exit 1` (non-blocking), so it has never blocked a stop.

## Per-agent statement (fifteen agents in the group matcher at line 214)

| # | Agent | Pattern classification | Basis |
| --- | --- | --- | --- |
| 1 | atomic-planner | REDUNDANT (pattern correct: `PREFLIGHT`, `plan-path`) | `validate-planner-output.ps1` already requires `plan-path`, an exact preflight signal, and an existing plan file (research R3 row 1) |
| 2 | atomic-executor | REDUNDANT (pattern correct: `plan-path`) | `validate-executor-output.ps1` already requires `plan-path` (research R3 row 2) |
| 3 | feature-review | WRONG | Contract returns `policy-audit-path:`, `code-review-path:`, `feature-audit-path:`; none contains a pattern token (spec row 3) |
| 4 | task-researcher | REDUNDANT (pattern correct: `research-path`) | `validate-task-researcher-output.ps1` already requires `research-path` (research R3 row 4) |
| 5 | prd-feature | WRONG | `research-path:` is present only when numeric acceptance criteria exist; wrong for the common case (spec row 5) |
| 6 | staged-review | WRONG | Contract returns `staged-review-path:` (spec row 6) |
| 7 | epic-review | WRONG | Contract returns `epic-audit-path:` (spec row 7) |
| 8 | status-updater | WRONG | Contract returns `status-sync-path:` (spec row 8) |
| 9 | python-typed-engineer | WRONG | No final-token contract (spec row 9) |
| 10 | powershell-typed-engineer | WRONG | No final-token contract; stop conditions return without artifacts (spec row 10) |
| 11 | csharp-typed-engineer | WRONG | No final-token contract (spec row 11) |
| 12 | typescript-engineer | WRONG | No final-token contract (spec row 12) |
| 13 | orchestrator | WRONG | Epic-mode eight-field return contains no pattern token (spec row 13) |
| 14 | epic-orchestrator | WRONG | No token requirement; long-running with interim stops (spec row 14) |
| 15 | epic-planner | SUCCESS-ONLY | The pattern holds only on successful completion (`plan-path:` list); the epic-worthiness early stop and interim stops carry no token (spec row 15) |

Counts: WRONG for 11 of 15 agents (rows 3, 5-14); REDUNDANT for 3 (atomic-planner, atomic-executor, task-researcher); SUCCESS-ONLY for 1 (epic-planner). The fifteen-agent count is derived in the research record's Numeric Derivation Evidence (primary count 15 from splitting the matcher on `|`; cross-check 15 from the 24 agent files minus the 9 not in the matcher).

## Decision and rationale

Decision (prepared in the spec, applied by [P4-T1] and [P4-T2]): delete the inline command object (lines 216-219) in both settings copies; keep the group, its matcher string unchanged, and the `pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1` entry unchanged.

Rationale:

1. For eleven agents the pattern is wrong or not part of the agent's contract. Converting the command to an exit-2 gate would refuse correct returns and push subagents to fabricate tokens.
2. For atomic-planner, atomic-executor and task-researcher a stricter dedicated validator already checks the same token, including file existence; the inline check is redundant.
3. For epic-planner the pattern holds only on success; refusing the worthiness-gate stop or an interim stop would be incorrect, and a state-aware gate is a new validation rule, which the epic lists as a non-goal.
4. The command has never blocked (exit 1, unset variable, absent key), so deleting it removes no enforcement.
5. Keeping the matcher unchanged keeps the existing matcher assertions in `claude-settings.Tests.ps1` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` green. No test depends on the inline command.

Rejected alternative (spec): a file-based hook using the new helper with the matcher narrowed to `atomic-planner|atomic-executor|task-researcher|epic-planner`; rejected because it duplicates three stricter validators, is incorrect for epic-planner's non-success stops, and adds a registered hook with guard-test, mirror and manifest obligations for no enforcement gain.

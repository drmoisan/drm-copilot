# D13 real process output before any change ([P0-T11])

Timestamp: 2026-11-11T04-37
Command: sh SCRATCH/issue-1159-d13.sh SCRATCH/issue-1159-d13.out (pwsh 7: for each D13-set hook of pretooluse-inventory.2026-11-10T03-48.md, one `pwsh -NoProfile -File <hook>` process per envelope with the envelope on redirected stdin and the worktree root as working directory; the in-function decision is read by a separate `pwsh -NoProfile -File SCRATCH/issue-1159-d13-inproc.ps1` process that dot-sources the hook and calls its `Invoke-...EntryPoint` with the same text and redirected console writers)
EXIT_CODE: 0
Output Summary: 7 D13-set hooks, 14 runs (one allow-shaped and one deny-shaped envelope each). FailOpen: yes for 3 hooks (enforce-epic-wave-barrier.ps1, enforce-parallel-cohort-barrier.ps1, enforce-parallel-drift-gate.ps1): the in-function decision is deny, and the process exits 0 with empty stdout, because `exit (Invoke-...EntryPoint)` collects the decision JSON written by Write-Output into the exit operand. FailOpen: no for the four Codex hooks, whose entry points write the decision with [Console]::Out.WriteLine or return 2 with a stderr reason.

Definitions: a process decision is deny when the process exits 2 or its stdout carries `"permissionDecision":"deny"`; `FailOpen: yes` means the deny-shaped envelope has an in-function decision of deny and a process decision other than deny.

## `.claude/hooks/enforce-epic-wave-barrier.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | (empty) | (empty) | none | allow (0) |
| deny: malformed envelope {not-json | 0 | (empty) | (empty) | none | deny (0) |

FailOpen: yes

## `.claude/hooks/enforce-parallel-cohort-barrier.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | (empty) | (empty) | none | allow (0) |
| deny: malformed envelope {not-json | 0 | (empty) | (empty) | none | deny (0) |

FailOpen: yes

## `.claude/hooks/enforce-parallel-drift-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | (empty) | (empty) | none | allow (0) |
| deny: malformed envelope {not-json | 0 | (empty) | (empty) | none | deny (0) |

FailOpen: yes

## `.codex/hooks/enforce-discovery-artifact-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: apply_patch to docs/hook-cost-probe.md | 0 | (empty) | (empty) | none | none (0) |
| deny: malformed envelope {not-json | 2 | (empty) | `DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly - the hook received no envelope object. The gate fails closed on an envelope it cannot read.` | deny | deny (2) |

FailOpen: no

## `.codex/hooks/enforce-discovery-planning-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: apply_patch to docs/hook-cost-probe.md | 0 | (empty) | (empty) | none | none (0) |
| deny: malformed envelope {not-json | 2 | (empty) | `DISCOVERY_PLANNING_GATE_BLOCKED: payload anomaly - the hook received no envelope object. The gate fails closed on an envelope it cannot read.` | deny | deny (2) |

FailOpen: no

## `.codex/hooks/enforce-evidence-locations.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: apply_patch to docs/hook-cost-probe.md | 0 | (empty) | (empty) | none | none (0) |
| deny: apply_patch to artifacts/qa/d13-probe.md | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EVIDENCE_LOCATION_BLOCKED: 'artifacts/qa/d13-probe.md' is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead. See .agents/skills/evidence-and-timestamp-conventions/SKILL.md for the canonical scheme."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.codex/hooks/enforce-file-size-limit.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: apply_patch to docs/hook-cost-probe.md | 0 | (empty) | (empty) | none | none (0) |
| deny: apply_patch adding an 801-line scripts/dev-tools/d13-size-probe.ps1 | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"FILE_SIZE_LIMIT_BLOCKED: 'scripts/dev-tools/d13-size-probe.ps1' would have 801 logical lines, above the 800-line hard limit. File-size policy tiers: 500 lines is guidance (look for a logical split), 700 lines is advisory (split more aggressively; reviewers report a non-blocking Warning), and above 800 lines a split is enforced regardless of logical separability. Split the file into smaller files so each stays at or below 800 lines."}}` | (empty) | deny | deny (0) |

FailOpen: no

Envelopes: Claude allow = Agent call with subagent_type task-researcher; Claude deny = the malformed text `{not-json` (payload anomaly deny). Codex allow = apply_patch updating docs/hook-cost-probe.md; Codex deny = `{not-json` for the two discovery gates, apply_patch adding artifacts/qa/d13-probe.md for the evidence gate, and apply_patch adding an 801-line scripts/dev-tools/d13-size-probe.ps1 for the file-size gate. Payload `cwd` is the repository-root token replaced at run time. No hook wrote a file (`git status --porcelain` unchanged).

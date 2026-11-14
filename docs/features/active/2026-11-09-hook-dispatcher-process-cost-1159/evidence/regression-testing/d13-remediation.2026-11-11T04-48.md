# D13 fail-open remediation ([P1-T1], [P1-T2])

Timestamp: 2026-11-11T04-48
Command: sh SCRATCH/issue-1159-d13.sh SCRATCH/issue-1159-d13-after.out (the [P0-T11] procedure re-run on the seven changed hooks after the tail rewrite)
EXIT_CODE: 0
Output Summary: Fail-before: evidence/baseline/d13-tail-output.2026-11-11T04-37.md records FailOpen: yes for enforce-epic-wave-barrier.ps1, enforce-parallel-cohort-barrier.ps1 and enforce-parallel-drift-gate.ps1. Change: the final statement of all seven D13-set hooks (the three Claude hooks and the four Codex hooks .codex/hooks/enforce-discovery-artifact-gate.ps1, enforce-discovery-planning-gate.ps1, enforce-evidence-locations.ps1, enforce-file-size-limit.ps1) was rewritten from `exit (Invoke-<X>EntryPoint ...)` to the family (C) form already used by .claude/hooks/enforce-evidence-locations.ps1 (`$entryPointResult = @(Invoke-<X>EntryPoint ...)`, the leading elements written with Write-Output, then `exit ([int]$entryPointResult[-1])`), and each was copied byte-identically to its bundle hooks folder. No decision function, deny code or reason text changed. Pass-after: every changed hook emits a decision for its deny-shaped envelope (FailOpen: no for all seven). New rule: It 'registers no hook whose tail passes an entry-point pipeline to exit' in tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1, applied to registered PreToolUse hooks enumerated through Get-HookRegistration. This change is excluded from the Phase 5 parity claim.

## After record (per hook)

## `.claude/hooks/enforce-epic-wave-barrier.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: payload anomaly - the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.claude/hooks/enforce-parallel-cohort-barrier.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"PARALLEL_COHORT_BARRIER_BLOCKED: payload anomaly - the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

## `.claude/hooks/enforce-parallel-drift-gate.ps1`

| Envelope | Exit code | Stdout | Stderr | Process decision | In-function decision (return code) |
|---|---|---|---|---|---|
| allow: Agent task-researcher | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` | (empty) | allow | allow (0) |
| deny: malformed envelope {not-json | 0 | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"PARALLEL_DRIFT_GATE_BLOCKED: payload anomaly - the hook received a payload that is not parseable JSON. The gate fails closed on an envelope it cannot read."}}` | (empty) | deny | deny (0) |

FailOpen: no

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

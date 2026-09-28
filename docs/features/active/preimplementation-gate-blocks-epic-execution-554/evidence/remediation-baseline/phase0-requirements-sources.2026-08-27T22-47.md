# Phase 0 — Requirement and Finding Sources Read (remediation cycle 1)

Timestamp: 2026-08-27T23-49
Cycle Timestamp: 2026-08-27T22-47
Task: [P0-T2]
Command: Read tool invocations against the four sources listed below (no shell command)
EXIT_CODE: 0

## Work Mode

Work Mode: full-bug

Resolved from `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md`
line 4 (`- Work Mode: full-bug`) and confirmed by `spec.md` line 9 (`- **Work Mode:** `full-bug``)
and line 10 (`- **Acceptance-Criteria Source:** this file, exclusively`).

Under `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the authoritative
acceptance-criteria source to `spec.md` only. `user-story.md` is deliberately absent for this
feature and `issue.md` carries a pointer section, not a second source.

**Sole acceptance-criteria source:**
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, `## Acceptance
Criteria` section, 35 items.

## Sources read

1. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` (999 lines)
2. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/remediation-inputs.2026-08-27T22-47.md` (211 lines)
3. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md` (332 lines)
4. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/code-review.2026-08-27T22-47.md` (231 lines)

## The single unchecked acceptance criterion, quoted verbatim

Located at `spec.md` line 899, the only `- [ ]` item among the 35:

```text
- [ ] Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either modified hook loses coverage.
```

The other 34 criteria are already `- [x]`. This criterion is re-evaluated at [P3-T15], and its text
must not be amended under any outcome.

## The four Blocking findings

| ID | Title | Closing phase |
| --- | --- | --- |
| **R1** (audit B1) | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is a new production file at 81.82% line coverage (24 uncovered of 132). The decision-D5 transport exemption does not cover its uncovered lines, because every uncovered function takes a `[string]` and returns a `[string]`, so calling one constructs no `Agent` envelope. Uncovered: line 197 (unknown-mode `return ''`), lines 228-250 (`Find-OrchestrationDelegationTargetFolder` body), lines 268-274 (`Find-OrchestrationDelegationIssueNumber` body), plus the accepted 94/95 `Write-Debug` residual. | Phase 1 |
| **R2** (audit B2) | `Test-PreparationModeDelegation` at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 153-186 is orphaned: its only production call site was the pre-change `Test-ImplementationDelegation`, which this branch replaced. Lines 170-185 — ten measurable lines covered at the merge base — are now uncovered. This is a coverage regression on pre-existing lines, prohibited by `.claude/rules/general-unit-test.md`. Closed test-only; the production-side removal alternative is explicitly not taken. | Phase 2 |
| **R3** (audit B3) | `Get-OrchestrationModeDenyReason` is uncovered on the Codex surface at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 352-353. It is a pure string builder with two mandatory string parameters, so D5 does not apply. It implements acceptance criterion (Amendment 3). | Phase 1 |
| **R4** (audit B4) | The classifier's non-orchestrator allow branch at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 210 (`if ($subagentType -ne 'orchestrator') { return $false }`) is untested on the Claude surface, which is the only surface where the `Agent` transport is reachable. This is the one uncovered added line the executor's four-group characterization did not account for. | Phase 2 |

## Accepted residuals recorded by the inputs (record, do not remediate)

- 16 measurable lines — the injected read seams `Get-EpicCheckpointContent` and
  `Get-ParallelCheckpointContent` on both surfaces. Reason: real filesystem I/O.
- 3 measurable lines — `.claude/…gate.ps1` line 408 (non-injected `else` arm) and `.codex/…gate.ps1`
  lines 421-422 (the `declared-checkpoint-path` deny return, uncovered for the D5 transport reason).
- 39 measurable lines — the decision-D5 transport-constrained Codex remainder.
- 4 measurable lines — `Get-OrchestrationModeProperty` `Write-Debug` catch at lines 94-95 of both
  `-modes.ps1` copies.
- Plus the reconciling line: `.claude/…gate.ps1` line 210, closed by R4. 62 + 1 = 63.

## The one shipping exception

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 426-443, 15 measurable lines:
the epic/parallel decision branch. Driving it requires constructing a delegation payload for the
Codex decision function, which decision D5 prohibits because `.codex/config.toml` registers no
`PreToolUse` matcher admitting an `Agent` or `Task` tool name. Linked to **issue #555**, which is
out of scope for this remediation.

## Non-blocking items noted

N1 (per-group counts corrected to 16/3/39/4), N3 (order dependence in
`Find-OrchestrationDelegationIssueNumber`), N4 (permissive widening, closed by [P2-T4]),
N5 (Codex pack-manifest omission, pre-existing), N6 (issue #510 did not reproduce in this worktree),
N7 (`.codex/…gate.ps1` at 495 of 500 lines).

Output Summary: All four sources read. Work Mode is `full-bug`; `spec.md` is the sole
acceptance-criteria source; exactly one of its 35 criteria is unchecked and it is quoted verbatim
above; the four Blocking findings R1 through R4 are enumerated with their locations and closing
phases.

# Remediation Cycle 1 AC-24 Decision ([P2-T11])

Timestamp: 2026-10-10T17-36
Source: orchestrator decision of 2026-10-10 resolving OPERATOR-DECISION-REQUIRED: AC-24 coverage measurement route

DECISION: AC-24 reads "measured per file from the Pester coverage XML" and does not name the combined run. For the Codex files in T-SET whose combined-run value is below 85% or below baseline, AC-24 is evaluated from a per-surface Pester coverage XML: the Codex suite set S (tests/scripts/codex-hooks/) run alone through the H2/R-PESTER hosting on the current tree, and the same S scope on the BASE tree extraction (the [P0-T10] r1-base extraction of 86e457a0…) for the "no changed line loses coverage" clause. The combined-run figures are retained and reported unchanged next to the per-surface figures. The final gate route, thresholds, exclusions and PoshQC configuration remain unchanged. No production or test code change is required for AC-24 under this decision.

AC-24-LINE: - [ ] AC-24: Line coverage is >= 85% for each changed or created PowerShell production file (each hook, each dot-sourced sibling, and both helper copies), measured per file from the Pester coverage XML and recorded under `evidence/qa-gates/`, with the bootstrap `exit 2` lines listed as known uncovered lines; no changed line loses coverage.
AC-24-SHA256: 4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66

CYCLE-1-VERDICT: VERDICT: measurement artifact
CYCLE-1-CLOSED: [P2-T2] to [P2-T10] checked off on their Cycle 1 (H2) records (remediation plan rule 5)

T-SET-FIGURES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | combined-c0=74.70 | xs-h2=95.78
T-SET-FIGURES: .codex/hooks/enforce-epic-planning-only.ps1 | combined-c0=82.25 | xs-h2=95.86
T-SET-FIGURES: .codex/hooks/hook-dependency-guard.ps1 | combined-c0=57.89 | xs-h2=100.00
T-SET-FIGURES: .codex/hooks/validate-bash.ps1 | combined-c0=80.25 | xs-h2=100.00
T-SET-FIGURES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | combined-c0=86.55 | xs-h2=100.00
T-SET-FIGURES: .codex/hooks/enforce-epic-merge-gate.ps1 | combined-c0=98.09 | xs-h2=98.73

ROUTE-UNCHANGED: R-PESTER final gate, 85.00 line threshold, no coverage exclusion, PoshQC configuration unchanged

## Verification

Command: sh <SCRATCHPAD>/r.sh r1-p2t11 -Verify (fresh process)

```text
CHECK: decision-line-in-r1-ac24-decision | pass | count=1
CHECK: decision-line-in-blocked-state | pass | count=1
CHECK: resolution-headings | pass | resolution lines=36,74; halt line=44
CHECK: resumed-p2t11 | pass | count=1
CHECK: ac24-sha256 | pass | recorded=4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66; inputs=4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66; live=4f0e53d36ec728f7f2fbcaf6b319096ecb70be79e9b025e1161aae15de51aa66
CHECK: cycle-1-verdict | pass | line=CYCLE-1-VERDICT: VERDICT: measurement artifact
CHECK: t-set-figures | pass | count=6
CHECK: operator-decision-resolved | pass | count=1
VERIFY-RESULT: pass
```

## Phase 3 skip branch

NOT-RUN: [P3-T1] | not run: measurement artifact (orchestrator decision)
NOT-RUN: [P3-T2] | not run: measurement artifact (orchestrator decision)
NOT-RUN: [P3-T3] | not run: measurement artifact (orchestrator decision)
NOT-RUN: [P3-T4] | not run: measurement artifact (orchestrator decision)
NOT-RUN: [P3-T5] | not run: measurement artifact (orchestrator decision)

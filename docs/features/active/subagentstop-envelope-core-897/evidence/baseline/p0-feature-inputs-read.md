# Phase 0 Feature Inputs Read (issue #897, epic child E1)

Timestamp: 2026-10-11T12-30
Task: [P0-T2]

## Inputs read (in order)

1. `docs/features/active/subagentstop-envelope-core-897/spec.md` (read first: section `## Authoritative Helper Contract`, then the remainder including `## Acceptance Criteria`)
2. `docs/features/active/subagentstop-envelope-core-897/issue.md` (Work Mode: full-bug)
3. `docs/features/active/subagentstop-envelope-core-897/research/research.2026-10-11T12-15.md`
4. `docs/features/epics/subagentstop-envelope/epic.md`

## Acceptance criteria count

Command: `grep -c '^- \[[ x]\] AC-' docs/features/active/subagentstop-envelope-core-897/spec.md`
EXIT_CODE: 0
Output Summary: 29 checkbox lines beginning with `- [ ] AC-` or `- [x] AC-`; all 29 are under the `## Acceptance Criteria` heading (the only AC checkbox section in the file) and all 29 are unchecked at this point.

AC_COUNT: 29

## Contract facts carried into execution

- Helper path `.claude/hooks/subagentstop-envelope.ps1`; three functions `Read-SubagentStopEnvelope`, `Get-SubagentStopEnvelopeAnomalyReason`, `Exit-SubagentStopBlock`; seven-property result; six anomaly codes; `ConvertFrom-Json -NoEnumerate -DateKind String`.
- No function signature, result-object shape, anomaly code, or consumer rule may change relative to the committed spec.

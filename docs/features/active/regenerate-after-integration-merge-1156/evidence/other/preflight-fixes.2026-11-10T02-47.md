# Preflight Fixes

Timestamp: 2026-11-10T02-47
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Branch: feature/regenerate-after-integration-merge-1156-r8
Issue: #1156

Earlier preflight-fixes and reversal files in this folder are unchanged; this record is append-only.

## Fixes

1. [P2-T1] | factual correction of an explanatory parenthetical, assertion unchanged | The R73-shaped round-trip case said the `ConvertTo-Json` default depth of 2 "flattens `event.classifier` to a string". A direct PowerShell 7 run of the R73 shape at default depth (scratch probe under SCRATCH) kept `event.classifier` as an object and serialized `event.classifier.unmatched_paths` as `""`. The parenthetical now names that observed effect. The asserted values (zero-element `unmatched_paths` array, and the other round-trip assertions) are unchanged, and the case still fails at default depth.
2. [P2-T1] | satisfiability clarification, assertion unchanged | The R73-shaped round-trip case built the event "with the R73 cells" but its parenthetical omitted `-Trigger`, while [P1-T3] has `New-RegenerationEvent` throw for a trigger outside `integration_sync`/`main_sync`, which includes `$null`. The parenthetical now adds `-Trigger main_sync`, `-UnitGate not_run`, and `-DeltaCheck pass` (the R73 cells), so the builder call cannot throw.
3. [P3-T2] | satisfiability clarification, assertion unchanged | The R73 `Context` built the event from the R73 cells without `-Trigger`, with the same throw consequence. The parenthetical now adds `-Trigger main_sync`. The three asserted decisions are unchanged.
4. [P1-T1] | literal clarification, assertion unchanged | The value-preservation case lists `unit_gate` argvs `ut-a`, `1` and `ut-b`, `2`; written as JSON integers they would violate rule 9 and make the "valid document" premise false. The task now states that every argv element is a JSON string.

## Substantive defects returned (not fixed in place)

None.

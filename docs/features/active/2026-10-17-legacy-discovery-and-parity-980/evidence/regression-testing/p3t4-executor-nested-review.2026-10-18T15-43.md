# P3-T4 consolidated nested transition findings

Timestamp: 2026-10-18T15-43
Command: poetry run python SCRATCH/issue-980-p3t4-nested-probes.py
EXIT_CODE: 1
Output Summary: One control passed and two boundary assertions failed. Both production source hashes remained unchanged during this three-case run. All workspace data and writes were memory-only.

Exact assertions, findings and source hashes: [current nested probe result](p3t4-executor-nested-probes.2026-10-18T15-43.json).

1. **Nested completed observation bypass.** An inferred state-transition summary with a verified `entries[0].before` observation and usable existing evidence passes `plan_contract`. The draft creation boundary rejects the same verified state on a direct dimension, but only examines the transition summary's `behavior`; it does not apply that creation rule to before/action/after phases. P3-T4 requires truthful draft creation without promotion to verified observation.
2. **Missing unresolved dimension linkage.** An unknown `entries[0].before` observation explicitly referencing the generated `unknown-feature-feature` question fails the accepted graph validator with `CLAIM_UNRESOLVED` at `/state_transitions/entries/0/before`. The generator leaves `state_transitions` out of the question's dimensions when its summary is inferred. P3-T4 requires required unresolved records to be generated for unknown behavior.

The unchanged inferred-phase control passes the same real planner with the same captured evidence. The requested correction is bounded to the current draft-contract implementation and prescribed tests: inspect every before/action/after observation, reject prohibited completed states consistently, append generated links for unknown/contradictory phases, and include their transition dimension in the generated question. Preserve supplied inference and the accepted mutation planner. No prior runtime, schema, policy or task change is requested.

These findings were sent together to the implementation owner and coordinator. P3-T4 remains unchecked; no acceptance criterion was changed.

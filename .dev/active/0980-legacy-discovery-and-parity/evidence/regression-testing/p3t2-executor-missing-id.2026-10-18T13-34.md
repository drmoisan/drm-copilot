# P3-T2 focused malformed-artifact verification

- Timestamp: 2026-10-18T13:34Z
- Command: `poetry run python SCRATCH/issue-980-p3t2-missing-id-probe.py`
- EXIT_CODE: 0
- Output summary: Five of five parseable missing-ID artifact cases passed. Scope, coverage ledger, unresolved behavior collection, decision collection, and parity matrix each produced the exact typed conflict path, actionable original findings, and no file, directory, revocation, or retained-handle effects, including with `force=True`.
- Source binding: All three implementation hashes were captured before imports and remained unchanged through exit. The corrected flow hash is `6e3a6ffbe467055de32747244272a0c05956555d09dc0d4c922fe9fd86e71720`.
- Change inspection: Compared with WIP `667cb753aa512b518cd0625750dadaf1e11d89b4`, only `_plan_initialization` has a changed function AST. Removing the new `if not snapshot.ok` rejection restores its exact prior AST. All other flow functions and the complete I/O and projection module bytes are unchanged.
- Retained evidence: The seven bootstrap and two handoff cases in the 13-28 JSON receipts remain historical executions. Their I/O and projection byte bindings and unchanged handoff function ASTs were verified. They were not re-executed or relabeled as a new nine-case run.
- Remaining acceptance: Complete stable task unit and coverage gates, compatibility/resource contracts, actual local-provider integration, and final staged/prior-path audit. P3-T2 and AC-16 through AC-19 remain unchecked.

Machine-readable results: [p3t2-executor-missing-id.2026-10-18T13-34.json](p3t2-executor-missing-id.2026-10-18T13-34.json).

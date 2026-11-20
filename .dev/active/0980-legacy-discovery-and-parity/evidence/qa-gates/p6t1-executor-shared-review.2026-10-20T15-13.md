# P6-T1 shared contract review

SCOPED_FINDINGS_COMPLETE. Candidate: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-shared-candidate.2026-10-20T14-58.json` (`1081c36750ce9cce889436fe6b5c2a90acb6845d8ffd2c995ebf723c5e04c934`).

- **SR1:** Exact string guards must precede enum equality in the runtime-error, request-error, result and authority carriers. Counted equality executes once at each tested boundary; authority and request-error values retain the non-string token. This demonstrates constructor inconsistency, not execution or publication authority.
- **SR2:** A 4,096-character manifest path is scanned with 1,982 work units left from a 2,048-unit budget, then projected and hashed before final rejection. Reserve aggregate variable-text/structural/serialization work before these operations; preserve manifest semantics.
- **ST1:** Correct the positive approval and wrong-kind negative fixtures to use structured evidence references. Preserve assertions and strict schema validation.
- **SC1:** Close the six exact named-body gaps retained in the JSON receipt with focused type/count, manifest and invalid-schema controls.

Existing proof remains **115 passed, 1 fixture failure, 116 collected**. No suite was repeated. The fixed 30-operation field/required-input matrix matches; canonical/packaged result schema bindings match. All three production files remain within 500 lines.

Exact probe bytes: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-shared-probe.2026-10-20T15-13.json`. Detailed locations, counters, repair bounds and coverage ranges: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-shared-review.2026-10-20T15-13.json`.

No open probe remains. No implementation or acceptance checkoff occurred. The coordinator controls repair release after the existing shared dependency window.

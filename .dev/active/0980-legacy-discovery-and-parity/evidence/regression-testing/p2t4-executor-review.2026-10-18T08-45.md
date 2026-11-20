# P2-T4 bounded executor review

Timestamp: 2026-10-18T08-45
Command: poetry run python SCRATCH/issue-980-p2t4-boundary-probe.py
EXIT_CODE: 0
Output Summary: Four schema-valid graphs resolve all references and emit no claim findings. Three expose structured consistency gaps; the minimum prior-runtime provenance rule is referred to the coordinator. This diagnostic run is not a passing acceptance gate.

The [machine receipt](p2t4-executor-review.2026-10-18T08-45.json) records the reviewed source hash and actual outcomes. The preceding independent run passed twenty cases covering verified source proof, confidence separation, dimension-specific unresolved backlinks, first observations, runtime evidence/capture integrity, mismatched summaries, mixed histories and honest unexecuted plans.

- **P2T4-R1 — feature-wide unresolved backlink.** A feature remains `verified` when an existing same-feature open question has an empty dimensions array and the feature omits its reference. Current dimension checks do not see this record and the summary ignores its open backlinks. Preserve optional-dimension behavior while detecting a feature-wide unresolved contradiction.
- **P2T4-R2 — evidence-type masking.** A source-type evidence record appears in both `source_evidence_refs` and `runtime_evidence_refs`; valid source proof lets the verified summary pass without classifying the runtime-designated reference. Validate the declared runtime evidence type independently of the source alternative; a source proof cannot become a runtime capture through its field location.
- **P2T4-R3 — unsupported known source expectation.** A passed scenario and matching passed run use `expected_result_basis=source-contract`, while their sole linked contract and every behavior dimension are explicitly unknown, with no known statements or acceptance criteria. Its unresolved links are valid. A basis label plus nonempty text currently substitutes for established source behavior. Check the minimum deterministic support available through existing feature links and observed fields; do not infer arbitrary prose equivalence.
- **P2T4-R4 — prior-runtime interpretation.** A passed scenario declares `prior-runtime-observation` but its only recorded run is the current comparison. The existing support rule verifies current summary consistency, not the declared prior basis. The coordinator is resolving the minimum support rule within existing runs, evidence and feature links. No schema addition, new chronological summary policy or full decision-validation dependency is requested.

The specialist received one consolidated review return while its current ordered gates continue. Production, repository tests, plan checkboxes, acceptance criteria and the orchestration checkpoint were not changed by this review. Final acceptance must bind corrected source bytes and actual completed gate results.

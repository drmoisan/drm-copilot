# P2-T8 parity rule handoff

Timestamp: 2026-10-18T10-19
Command: poetry run python SCRATCH/issue-980-p2t8-task-audit.py 6
EXIT_CODE: 0
Output Summary: Five staged paths; 77 focused/77 reversed tests; 245/245 lines and 121/124 branch arcs; all 21 measured unit ranges at 100.000000%; 198 prior and 24 frozen paths unchanged; no findings.

## Exact scope

- packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py: 485 physical lines
- packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py: 303 physical lines
- tests/discovery_runtime/test_parity_rules.py: 440 physical lines
- tests/discovery_runtime/test_parity_clients.py: 499 physical lines
- tests/discovery_runtime/parity_test_support.py: 229 physical lines

Only P2-T8 is implemented. Plan line 28 permits the recorded same-component splits: parity_target_rules.py holds target identity/implementation/evidence/coordinate checks; parity_test_support.py contains fresh in-memory graph builders shared by the two prescribed tests. No prior accepted production/test/schema bytes, dependency, suppression, threshold, plan/AC or checkpoint changed. The coordinator staged only the five requested additions.

## Interface and semantics

validate_parity(snapshot, complete=False, index=None, evidence=None, revisions=None, decisions=None, dimensions=None) returns immutable ParityValidation findings. Accepted immutable graph, evidence, revision, current-decision and dimension assessments may be reused. The rule performs no I/O, execution or source mutation. Schema/reference/revision/claim/discovery/acceptance prerequisites remain separate results for P2-T9 composition; this family does not independently grant aggregate completion.

Every row resolves one immutable source contract at its declared repository/pin/raw-byte hash and one configured target client/pin. Duplicate source-feature/client rows fail. Target implementation and test paths must retain exact target identity and captured bytes; every cited execution proof must be locally verified target test/runtime/observation evidence. URI-only and static source/documentation payloads cannot establish execution. Source-contract proof remains source proof even when source and target share a repository and pin; renaming evidence metadata around the same source payload does not create target proof. Captured runtime environment must match the client and requested platform/mode. Test evidence without environment uses the enclosing test's explicit axes. Neither document HEAD advancement nor a different local target revision invalidates a correctly pinned imported historical source.

Full parity requires independent target implementation, row evidence, passing required dimensions, no blockers, passing validation, and target test/capture coverage across every inherited platform/mode coordinate. Every linked implementation must pass; one passing record cannot mask a failed or not-run component. Different passing records may divide required coordinates. Present passed/failed implementation and dimension claims are checked in structural mode. Honest unassessed/partial/missing/conflicting drafts remain structural; required-only completion rejects those states and absent required rows. Optional incomplete features do not block required completion.

Changed parity needs current linked approvals scoped to this feature/client and relevant axes; required completion additionally needs target verification. Retirement requires approval covering the complete obligation. Retirement still validates supplied classifications, evidence and links. Required non-applicability needs rationale and current covering approval; it is a disposition, never a synthetic pass. Direct online/offline/mobile classifications must agree with duplicate dimensions records, and both supplied proof sets are independently checked. Mobile behavior uses configured platform identity; it does not assume a literal platform named mobile. Unconfigured optional dimensions create no obligations or fabricated results. Approved target policy never rewrites or promotes uncertain source observations.

## Verification

Clean ordered pass 6: Black and Ruff pass all five paths; full repository Pyright reports zero diagnostics; 77 focused tests pass. Reversed module order passes 77. Static audit verifies docstrings, physical limits, whitespace, no suppressions and no unit-test temporary-file/process/network calls. Mutable documents/captures are reconstructed per test; only immutable catalogs/profiles are shared. Deterministic input-order permutations preserve findings and manifest identity. Tracked quality-tier and package-resource contracts pass.

- packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py: 146/146 lines (100.000000%); 73/74 branch arcs (98.648649%).
- packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py: 99/99 lines (100.000000%); 48/50 branch arcs (96.000000%).

All 21 module/class/method ranges reach 100.000000% line coverage. Raw statement/branch execution and owned SHA-256 values are retained in the linked artifacts. Phase 0 baseline remains zero Ruff/Pyright diagnostics, 7,336 passed/six existing skips, 94.111715% lines and 88.783742% branches. New modules have zero baseline statements; lint/type/test-failure deltas are zero. 198 accepted latest task hashes and 24 frozen v1/export paths are unchanged, preserving prior changed-line evidence. Full repository test/coverage QA remains Phase 11.

Retained corrections: pass 2 lint identified import ordering, message width and one missing test constant; pass 3 types required an explicit selected-record list and narrow synthetic kwargs. The independent consolidated review found four current-scope gaps: retired rows skipped supplied claims, optional rows blocked required completion, mobile proof assumed a literal platform, and one passed implementation masked another linked failed/not-run component. Direct regressions cover each. All 65 pass-4 tests passed, but its callable audit measured source_payload at 87.5% and implementation at 88.888889%; this was not task acceptance. Additional direct error/context regressions raised all callable ranges to 100% without changing production bytes. The 53-case corrected independent behavior passed provisionally but its first command correctly failed source-stability binding during formatting. Final source-bound executor verification remains separately retained and executor-owned.

Metrics: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t8-coverage-metrics.2026-10-18T10-19.json
Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t8-coverage.2026-10-18T10-19.json
Individual command receipts: evidence/regression-testing/p2t8-pass6-*.md. Earlier lint/type/coverage and initial/corrected executor evidence remain retained; no failing receipt was replaced.

TASK_READY_FOR_VERIFICATION. P2-T9 remains unreleased.

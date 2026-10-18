# P2-T6 scope and inventory accounting handoff

Timestamp: 2026-10-18T09-31
Command: poetry run python SCRATCH/issue-980-p2t6-task-audit.py 9
EXIT_CODE: 0
Output Summary: Four staged paths; 92 focused/92 reversed tests; 248/248 production lines and 140/140 branch arcs; all 18 callable/class ranges >= 100.000000%; 189 prior and 24 frozen paths unchanged; no findings.

## Scope and approved boundary

- packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py: 340 physical lines
- packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py: 428 physical lines
- tests/discovery_runtime/test_coverage_rules.py: 497 physical lines
- tests/discovery_runtime/test_coverage_scope.py: 490 physical lines

Only P2-T6 is implemented. The coordinator-approved coverage_scope_rules.py split follows plan line 28: scope selection, captured input/exclusion accounting and the shared configuration digest stay separate from ledger/disposition/evidence/runtime checks. Both prescribed test modules remain. All additions are staged for exact diff review. No accepted earlier path, dependency, suppression, coverage setting, plan/AC or checkpoint was changed by this worker.

validate_coverage(snapshot, complete=False, index=None, evidence=None, claims=None) returns immutable CoverageValidation findings. It reuses the accepted immutable graph, ClaimContext, evidence assessment, revision byte lookup and claim results. Complete=False preserves structural drafts, blocked/unassigned observations and missing dispositions without asserting discovery completion. Complete=True adds configured scope/current-inventory/disposition/runtime prerequisites. The later mode validator still composes schema, references, revisions, decisions and remaining completion rules; this result alone is not a complete-workspace pass.

Ledger/scope/inventory share trusted repository and pin and the same resolved inventory set. Additive root/component selectors use path segments; feature-only scope conservatively includes every inventory component and scan input, including inputs that failed before component detection. Selected components must occur exactly once; foreign rows, duplicated IDs and rewritten path/type/hash/symbol/span provenance are rejected. Functional dispositions require actual inspection and update evidence. Exclusions require the same confirmed scope, matching explicit pattern and rationale. Detected test relationships require retained test bytes at the pin plus local evidence; they do not claim a test pass or measured coverage. Declared runtime need requires valid observed/passed characterization at the ledger's own repository and pin.

inventory_configuration_digest(profile) hashes canonical JSON for production_roots, test_roots, project_entry_points, documentation_roots, evidence_roots, artifacts, excluded_paths and analyzers. Known selector arrays are normalized; opaque analyzer options preserve order. Owners, completion policy and revision/HEAD do not affect this scan identity. Later analyzers must call this helper when emitting scan_configuration_sha256. Configuration/current captured-input comparisons apply only to local origin-free artifacts at the exact local repository/pin; transported historical inventories are not compared with consumer settings or checkout inputs. This makes no claim about remote freshness.

All captured source/test/documentation inputs must be accounted for, including explicit skipped paths with substantive exclusions. Local inspected file rows must match actual retained path/hash/size. Global and selected-path blocking/error diagnostics and unjustified unreadable/excluded required inputs prevent completion; unrelated path diagnostics do not silently widen scope.

## Verification

Clean ordered pass 9: Black and Ruff pass all four paths; full repository Pyright reports zero diagnostics; 92 focused tests pass. Reversed module order passes 92 tests. Raw coverage and per-module/callable metrics are linked below. Static docstrings, 500-line limits, suppressions, whitespace and test external-I/O checks pass; staged quality-tier/resource contracts pass. Shared fixtures are immutable profiles/catalogs; each test builds fresh documents, payloads and graph state in memory. No unit test uses temporary files, subprocesses or network.

Accepted Phase 0 baseline: zero Ruff/Pyright diagnostics, 7,336 passing tests with six existing skips, 94.111715% line and 88.783742% branch coverage. These files are new (zero baseline executable lines); lint/type/test-failure deltas are zero. Latest accepted per-path hashes preserve all prior task bytes and changed-line coverage. Full repository test/coverage QA remains Phase 11 and was not repeated for this task.

Retained separate failure/correction receipts: pass 2 lint found long text and unused imports; pass 3 typing found invariant test containers and an untyped empty nested fixture; explicit Sequence and typed fixture values corrected these. Pass 4 was stopped before tests to replace an unsupported synthetic analyzer option with max_file_bytes. Pass 5 passed 90 tests. The independent schema-valid review identified feature-only unclassified-input omission, imported same-ID historical inputs compared against the target checkout, and target-only runtime observation accepted for source characterization. All three were corrected in current-task modules with focused regressions. Runtime regression expansion briefly exceeded the test line limit and exposed possible empty-tuple indexing in passes 7/8; fixture simplification and explicit nonempty narrowing corrected both. No suppression, schema weakening or accepted prior-file change was used. Independent final acceptance is executor-owned.

P2-T5 integration carry-forward remains unchanged: an approved target-policy resolution does not turn unknown legacy facts into verified observations; a separate explicitly linked open legacy-observation question must preserve that uncertainty. Full decision/completion composition remains P2-T9.

Metrics and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t6-coverage-metrics.2026-10-18T09-31.json
Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t6-coverage.2026-10-18T09-31.json
Separate command receipts: evidence/regression-testing/p2t6-<step>-pass9.*.md, with earlier failed/abandoned passes retained individually. Independent review evidence: p2t6-executor-review.2026-10-18T09-23.json/md and subsequent runtime-identity review receipts.

TASK_READY_FOR_VERIFICATION. P2-T7 and later tasks remain unreleased.

# P2-T3 evidence and revision handoff

Timestamp: 2026-10-18T08-35
Command: poetry run python SCRATCH/issue-980-p2t3-task-audit.py 8
EXIT_CODE: 0
Output Summary: Four staged files; 90 focused and 90 reversed tests pass; 296/297 lines and 148/150 branches covered; 178 prior accepted paths and 24 frozen paths unchanged; no findings.

## Scope and interfaces

- packages/discovery-runtime/src/drm_copilot_discovery/evidence_rules.py (306 physical lines)
- packages/discovery-runtime/src/drm_copilot_discovery/revision_rules.py (458 physical lines)
- tests/discovery_runtime/test_evidence_rules.py (462 physical lines)
- tests/discovery_runtime/test_revision_rules.py (483 physical lines)

All four files are new, with zero baseline executable lines. No additional split, dependency, suppression, coverage setting, prior production/test path, plan/AC or checkpoint was changed by this worker. The coordinator staged the exact four source/test files; their maximum physical length is 483.

EvidenceAssessment and EvidenceValidation expose immutable local integrity assessments through assess_evidence(inputs, record) and validate_evidence(snapshot, index=...). Runtime/manual capture metadata uses the accepted RFC3339 validator, explicit author/environment/method data and exact local SHA-256 payload bytes. A distinct runtime_artifact.path is separately bound to that checksum. One-based inclusive spans support JSON integer-valued floats and arbitrarily large integer endpoints without float coercion. URI-only records remain descriptive and cannot supply local completion proof. can_prove requires the requested repository, revision and evidence type; it does not infer observed truth, confidence, approval or target test results.

RevisionInputs reads only captured snapshot bytes and immutable objects. Source/test evidence requires exact pinned content; runtime revision metadata does not require a runtime capture at the application's Git commit. Imported payloads stay beneath their captured transport root and source identity. validate_revisions(snapshot, index=...) checks configured selected source/test bytes, typed artifact hashes/pins, source-versus-target declarations, inspected source row hashes/sizes, and transported entry hashes/sizes. Imported historical declarations retain their own immutable pin, while consuming references must match configured expected pins. Documentation-only HEAD changes preserve matching selected source bytes. Remote freshness is explicitly unknown.

Both rules reuse the supplied immutable index/catalog and perform no I/O. Their findings remain separate from upstream schema/reference findings, which the later validation task must compose. Claim/decision/completion semantics remain later tasks. Source-snapshot export/import operations and canonical manifest self-digest verification remain P3-T6.

## Verification

Clean ordered pass 8: Black and Ruff pass all four files; full repository Pyright reports zero diagnostics; 90 focused tests pass. Reversed module order passes 90 tests in one process. Every new class/callable has at least 93.33% line coverage. New modules exceed 90% lines and 75% branches. All prior accepted hashes are unchanged, preserving their accepted changed-line coverage. The accepted Phase 0 repository baseline is 7,336 passed, six existing skips, 94.111715% line coverage and 88.783742% branch coverage; full feature QA remains Phase 11.

| Module | Covered lines | Covered branches |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/evidence_rules.py | 110/110 | 42/42 |
| packages/discovery-runtime/src/drm_copilot_discovery/revision_rules.py | 186/187 | 106/108 |

Tests use immutable schema/profile fixtures and fresh in-memory documents, manifests and payloads. They create no temporary files and invoke no network or subprocess. Static checks report no missing function/class docstrings, physical-limit violation, suppression, external unit-test operation or trailing whitespace. Staged whitespace, tracked quality-tier classification and all 33 packaged schema resources pass their contracts.

Failed evidence is retained. The independent initial review found redundant timestamp parsing and integer-to-float overflow; direct lowercase/leap-second/huge-endpoint regressions now pass. Early Ruff runs stopped on message/docstring widths; typing stopped on an int/float predicate and two untyped empty sets, corrected without suppressions. Pass 5 reported 66 passed and 22 fixture failures because a configured target profile lacked its required client; supplying an explicit client corrected the fixture, with no rule-semantic change. Its raw failed coverage is preserved separately. Pass 6 passed 88 tests but the callable audit found _references at 17/19 lines (89.47%); two transport-link regressions cover inherited identity and missing targets without changing production bytes. The added test required formatting before clean pass 8. The final independent bounded probe passes 52/52 against the frozen production hashes. Final acceptance remains executor-owned.

Aggregate commands: evidence/regression-testing/p2t3-gates.2026-10-18T08-27.md.
Initial review: evidence/regression-testing/p2t3-executor-review.2026-10-18T08-22.json.
Exact staged hashes, prior/frozen inventories and callable ranges: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-coverage-metrics.2026-10-18T08-35.json.
Raw final coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-coverage.2026-10-18T08-35.json.

TASK_READY_FOR_VERIFICATION. No P2-T4 or later task is released by this handoff.


## Command-receipt format correction — 2026-10-18T09-02

The retained aggregate command log was normalized into individual write-time-stamped receipts without rerunning commands or changing their recorded results. Original capture/start timestamps, commands, exit codes and output are preserved. See the [verified extraction index](../regression-testing/p2-command-receipt-normalization-verification.2026-10-18T09-02.md) for the one-to-one mapping and unchanged aggregate hashes. This note corrects evidence format only; the task acceptance and production-byte verification above are unchanged.

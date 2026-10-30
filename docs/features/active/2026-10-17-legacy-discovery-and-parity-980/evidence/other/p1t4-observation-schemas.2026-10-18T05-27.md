# P1-T4 observation and evidence schema handoff

Timestamp: 2026-10-18T05-27
Command: poetry run python SCRATCH/issue-980-p1t4-task-audit.py
EXIT_CODE: 0
Output Summary: Exact 18 staged task paths; 619 focused tests and 260 reversed-order tests passed; all 13 packaged schema bytes/digests match; resource coverage remains 100% lines/branches.

## Scope and decisions

Approved P1-T4 only. Added strict Draft 2020-12 feature-contract, evidence-reference and runtime-characterization-scenario schemas with exact v2 kind/version identities, three synthetic passing examples and three invalid fixtures. Closed core objects and namespaced extensions use the unchanged P1-T3 common definitions.

Feature contracts retain every specified behavior dimension, before/action/after transitions, evidence references, independent confidence/observation/lifecycle/target/product-decision fields and ready/pending acceptance criteria. Verified claims need proof and no unresolved links. Unknown/contradictory dimensions require typed unresolved links without invented statements. Offline/mobile fields may remain honestly unknown when not required by the profile; this task introduces no forced platform investigation.

Evidence records separate source/test pins and local checksums from manual or automated runtime captures with environment, actor and timestamp. URI-only documentation remains descriptive and cannot satisfy the runtime-capture shape. Runtime scenarios separate observation plans, pre/post capture results, known/unknown expectations, per-run outcomes, repeatability and unresolved findings. A first observed result does not become a passing test; passed/failed comparisons require known expectations and evidence.

Test files were split within the approved schema-test component to respect the 500-line limit. The existing helper now discovers the committed v2 schemas for its offline registry and explicitly registers its test-local format checks. Tests read immutable examples into fresh objects; they create no temporary files and invoke no external processes or network services.

## Exact task-owned paths

- examples/discovery/v2/evidence-reference.example.yaml
- examples/discovery/v2/feature-contract.example.yaml
- examples/discovery/v2/runtime-characterization-scenario.example.yaml
- packages/discovery-runtime/resource-manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/evidence-reference.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/feature-contract.schema.json
- packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/runtime-characterization-scenario.schema.json
- schemas/discovery/v2/evidence-reference.schema.json
- schemas/discovery/v2/feature-contract.schema.json
- schemas/discovery/v2/runtime-characterization-scenario.schema.json
- tests/fixtures/discovery_schemas/v2/evidence-reference.invalid.yaml
- tests/fixtures/discovery_schemas/v2/feature-contract.invalid.yaml
- tests/fixtures/discovery_schemas/v2/runtime-characterization-scenario.invalid.yaml
- tests/schemas/discovery/test_v2_format_schemas.py
- tests/schemas/discovery/test_v2_observation_schemas.py
- tests/schemas/discovery/test_v2_runtime_schemas.py
- tests/schemas/discovery/v2_schema_test_support.py

Fourteen paths are authored/configured and four are generated. All are staged with current bytes. Maximum physical file length: 338. The audit verified 50 prior-task paths retain their recorded hashes, including common/profile/scope schemas, runtime implementation, dependency declarations and lockfile. Frozen v1 schemas, fixtures and asserting tests are unchanged.

## Ordered gate and supporting results

| Step | Actual result | Evidence in regression-testing |
| --- | --- | --- |
| Black check | Exit 0; four unchanged files | p1t4-format-pass3.2026-10-18T05-25.md |
| Ruff | Exit 0; zero findings | p1t4-lint-pass3.2026-10-18T05-25.md |
| Full Pyright | Exit 0; zero errors/warnings | p1t4-types-pass3.2026-10-18T05-25.md |
| Focused Pytest | Exit 0; 619 passed | p1t4-tests-pass3.2026-10-18T05-26.md |
| Reversed new modules | Exit 0; 260 passed | p1t4-reversed-schema-modules.2026-10-18T05-26.md |
| Resource staging check | Exit 0; no changed paths; 13 resources | p1t4-stage-check.2026-10-18T05-26.md |

Resources.py retains 103/103 executable lines and 34/34 branch arcs; build_discovery_runtime.py retains 209/209 lines and 98/98 arcs. Aggregate 312/312 lines and 132/132 arcs; coverage delta is zero. This schema/test-only task adds zero executable production lines; the new-code denominator is zero and no percentage is invented. Phase 0 full-repository baseline remains applicable to final QA.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t4-coverage.2026-10-18T05-27.json
Exact staged paths, counts, prior hashes and metrics: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t4-coverage-metrics.2026-10-18T05-27.json
Generated resource manifest SHA-256: 46dc9ee7dc399ae4113d770fba0351bb1513c634c171aef19685615ddf202b06

## Failure retained and bounded format repair

Initial Ruff reported four long literal lines; narrow wrapping corrected them and the ordered loop restarted. Pass2 then exposed the retained impossible-date negative: 524 tests passed and one failed. The diagnostic probe confirmed jsonschema 4.26.0 lacked both optional date-time and uri checkers; unknown formats silently succeeded. Failed gate/probe records remain under regression-testing, including p1t4-tests-pass2.2026-10-18T05-19.md and p1t4-format-dependency-probe.2026-10-18T05-20.md.

The coordinator authorized explicit instance-local standard-library format checkers within test support, without new dependencies or early production-catalog work. Registration availability and isolation from jsonschema global defaults are asserted. Ninety-four boundary cases cover impossible and leap dates, exact ASCII timestamp syntax, UTC/offset limits, fractions, known leap-second instants, malformed HTTP authorities, IP literals, percent escapes and per-component character restrictions. The original invalid-date assertion remains unchanged.

RFC 3339 syntax and Gregorian calendar rules are applied before any datetime arithmetic. Positive leap seconds are accepted only at the corresponding UTC minute on the fixed IANA/IERS insertion dates through 2016-12-31; local offset forms may enter 2017-01-01. Unknown future insertions fail closed. Updating that compact set after an official future insertion is an explicit maintenance limitation; it performs no live lookup. There have been no negative insertions in the cited source. The code validates timestamp syntax against that historical set, not the truth of an evidence capture.

The URI function is explicitly named is_http_evidence_uri. It implements the current HTTP(S) evidence-reference contract rather than claiming all generic URI scheme semantics. It checks ASCII/component grammar, complete hexadecimal percent escapes, nonempty HTTP authority, RFC IP literals, and numeric port syntax. It does not decode percent escapes, resolve hostnames, infer reachability or retrieve content. Encoded octets remain descriptive data. Registration under uri is limited to this schema-test instance, where the only uri declaration is the evidence HTTP(S) property.

Primary sources:
- [jsonschema format validation](https://python-jsonschema.readthedocs.io/en/stable/validate/) documents optional format dependencies and unknown-format success.
- [RFC 3339 sections 5.6-5.8](https://www.rfc-editor.org/rfc/rfc3339#section-5.6) define the timestamp grammar, date/offset limits and leap-second examples.
- [RFC 3986 sections 2-3](https://www.rfc-editor.org/rfc/rfc3986#section-2.1) define URI characters, escapes, authority and components.
- [RFC 9110 section 4.2](https://www.rfc-editor.org/rfc/rfc9110#section-4.2.1) defines HTTP(S) and the nonempty host requirement.
- [IANA public-domain leap-second data](https://data.iana.org/time-zones/data/leap-seconds.list) supplies the 27 known insertion dates; the retrieved file states expiry 2027-06-28.

A read-only shell inspection was rejected before process creation because its command text contained a NUL byte: Rejected("Failed to create unified exec process: nul byte found in provided data"). Zero files were mutated; the corrected plain read was run. No policy bypass or dependency change occurred.

## Sequential handoff

TASK_READY_FOR_VERIFICATION is limited to P1-T4. The executor owns acceptance/checkoff and the coordinator owns staging/checkpoints. P1-T5 is not released. P1-T9 must implement authoritative installed-runtime format validation with equivalent boundaries and fail closed when a required checker is missing; this test support does not substitute for that task. Semantic graph links, evidence-byte validation, equality of repeated IDs, range ordering, dimension unions and completion gates remain assigned to their later plan tasks. Schema validity alone does not claim those behaviors or full-feature completion.

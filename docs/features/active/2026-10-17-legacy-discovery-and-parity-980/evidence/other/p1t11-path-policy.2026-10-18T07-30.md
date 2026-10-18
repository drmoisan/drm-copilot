# P1-T11 path-policy and Phase 1 interface handoff

Timestamp: 2026-10-18T07-30
Command: poetry run python SCRATCH/issue-980-p1t11-task-audit.py 4
EXIT_CODE: 0
Output Summary: 5 exact staged paths; 241 focused and 241 reversed tests pass; 251/251 lines and 116/116 arcs. 160 prior accepted paths unchanged.

## Scope and behavior

- packages/discovery-runtime/src/drm_copilot_discovery/path_models.py
- packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py
- tests/discovery_runtime/test_path_policy.py
- tests/discovery_runtime/test_path_resolution.py
- tests/discovery_runtime/test_path_collisions.py

All five paths are new; baseline executable lines are zero. No existing source/test, schema, resource, dependency, policy, plan/AC or checkpoint file changed. All files remain below 500 physical lines; maximum 472. Only the coordinator stages changes, and only the executor checks off tasks.

PathPolicy accepts a validated ProfileV2, an explicit absolute workspace, an injected PathMetadataReader and additive trusted protected paths. Relative inputs retain exact POSIX spelling. Drive-relative/rooted/UNC/device inputs, traversal, ADS, control/unsafe characters, Windows device stems and trailing dots/spaces fail before metadata access. Component keys use Unicode NFC and casefold for conservative cross-host collision checks; permission checks retain exact authored spelling. A sibling textual prefix never establishes containment. Native/configuration/framework roots, production/test/project paths, extension schemas and nested standing-policy names remain protected.

validate_configuration inspects all configured locations and classifies missing optional roots honestly. resolve_read admits configured input/artifact scope. resolve_write requires one exact WriteGrant(artifact_kind, artifact_id, path), routes only supported output kinds to their configured location, and rejects directory replacement. The profile parent root is never a blanket write grant. Default accepted profile layouts, custom Unicode hierarchies and separate custom output roots are covered. The closed routes exclude configuration and authority writes; root initialization/import operations remain their separately approved later integrations.

The injected reader must return non-following metadata, stable filesystem identity, absolute canonical location and complete immediate directory names. Symlinks and reparse entries are conservatively rejected, including internal targets. Resolved components must stay inside the explicit workspace with exact spelling. Repeated ancestor identities, inconsistent listing/inspection, unreadable metadata and ambiguous namespaces fail. ResolvedPath retains immutable parent/leaf stamps; revalidate_write reads current metadata and rejects parent/target replacement, newly created parents, links and aliases. Unrelated sibling creation is allowed. The later I/O layer must combine revalidation with exclusive creation or digest-matched atomic replacement; this pure boundary neither writes bytes nor claims to eliminate OS races or mint native authority.

Windows name/namespace constraints follow [Microsoft naming guidance](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file). Pure path operations are only lexical; injected metadata supplies physical observations as distinguished by [Python pathlib documentation](https://docs.python.org/3.10/library/pathlib.html).

## Validation

Clean ordered pass 4: Black, Ruff, full Pyright and all 241 focused path-module tests. Reversed new modules: 241 passed. The earlier broader run retained 537 passing path/profile/legacy-profile/package cases and the one corrected test-setup failure; production bytes were unchanged for both runs. Its unaffected compatibility results remain reusable. New tests use only fresh in-memory filesystem fakes and immutable profile/catalog fixtures, with no temporary files, subprocesses or network. Custom-profile cases reuse the immutable installed catalog instead of rebuilding it per case; mutable documents and fake filesystem state remain local. Deterministic properties cover spelling idempotence, component containment, collision permutation/order invariance and cross-host resolution.

| Production module | Covered lines | Covered branch arcs |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/path_models.py | 98/98 | 34/34 |
| packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py | 153/153 | 82/82 |

Every new callable/class meets 90%; all detailed ranges and final SHA-256 values are in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t11-coverage-metrics.2026-10-18T07-30.json. Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t11-coverage.2026-10-18T07-30.json. 160 accepted prior-task paths retain their latest verified hashes. The 24 frozen v1/export paths remain unchanged against HEAD. Resource closure and tracked quality-tier evidence are listed below. Phase 0 full Python baseline remains 7,336 passed, six existing skips, 94.111715% lines and 88.783742% arcs; final feature-wide QA belongs to Phase 11.

Initial formatting and five Ruff E501 comment/docstring diagnostics are retained. The first focused run confirmed one test arranged a project entry at docs, which correctly failed the earlier protected/output-overlap check; its case was adjusted to the production input src so it exercises the intended file/directory conflict. No production safety rule was weakened. The executor's bounded independent review reported 94 probes passing before final acceptance.

Canonical command records:
- p1t11-format-fixtures.2026-10-18T07-29.md
- p1t11-format-initial.2026-10-18T07-23.md
- p1t11-format-pass1.2026-10-18T07-23.md
- p1t11-format-pass2.2026-10-18T07-24.md
- p1t11-format-pass3.2026-10-18T07-28.md
- p1t11-format-pass4.2026-10-18T07-29.md
- p1t11-lint-pass1.2026-10-18T07-23.md
- p1t11-lint-pass2.2026-10-18T07-24.md
- p1t11-lint-pass4.2026-10-18T07-29.md
- p1t11-resource-check.2026-10-18T07-30.md
- p1t11-tests-pass2.2026-10-18T07-27.md
- p1t11-tests-pass4.2026-10-18T07-30.md
- p1t11-tests-reversed.2026-10-18T07-30.md
- p1t11-tracked-tiers.2026-10-18T07-30.md
- p1t11-types-pass2.2026-10-18T07-24.md
- p1t11-types-pass4.2026-10-18T07-29.md

## Phase 1 interfaces and remaining integration boundaries

- One installable packages/discovery-runtime package is authoritative. Existing safe imports are thin adapters; frozen valid v1 readers remain explicit compatibility paths.
- Packaged resources contain seven v1 and twenty-six v2 schemas. The exact offline catalog, pinned extension schemas and explicit expected-kind/version validation reject fallback/network retrieval. Activation and service-result retain their specifically closed wire envelopes.
- Strict parsing produces immutable JSON values and bounded deterministic findings. Parser byte/depth/record/expanded-alias budgets remain finite. Reserved truncation markers stay blocking and unique.
- ProfileV2 exposes all immutable profile sections, inherited platform/mode/dimension requirements, non-disableable claim rules, finite typed limits and exact local repository/client/extension bindings. ActivationLocator is inert configuration, not authority.
- PathPolicy now provides the shared lexical, configured-scope, physical-metadata and revalidation boundary. Later filesystem adapters must supply trustworthy metadata and protect OS-level read/write races; path values are not host permissions.
- Phase 2 still owns snapshots, graph/reference/evidence/decision/coverage/parity/completion semantics. It must reject duplicate explicit versus dimensions mode classifications and preserve source observations separately from target tests.
- Phase 3 still owns controlled mutation, initialization/activation, templates, source transport and v1 migration. Imported snapshot content must remain under its configured transport root with exact kinds/IDs/paths, and root-only configuration cannot be admitted through analyst grants.
- Remaining phases own analyzers, acceptance generation/reports, CLI/service/hosts, native authority/hooks, publication/documentation and complete repository QA/review. None is claimed implemented by this foundation handoff.
- The RFC3339 leap-second checker uses the explicit supported insertion table through 2016; future announced insertions require its source-cited update. HTTP(S) evidence URI validation remains offline and syntactic. Unsupported extension formats fail explicitly. Schema migration is exact-version, never inferred.

Prior independently accepted Phase 1 task receipts:
- p1t1-executor-verification.2026-10-18T04-38.md
- p1t2-executor-verification.2026-10-18T04-56.md
- p1t3-executor-verification.2026-10-18T05-10.md
- p1t4-executor-verification.2026-10-18T05-30.md
- p1t5-executor-verification.2026-10-18T05-39.md
- p1t6-executor-verification.2026-10-18T05-52.md
- p1t7-executor-verification.2026-10-18T06-10.md
- p1t8-executor-verification.2026-10-18T06-25.md
- p1t9-executor-verification.2026-10-18T06-46.md
- p1t10-executor-verification.2026-10-18T07-14.md

P1-T11 and Phase 1 acceptance remain contingent on the executor's final verification. No Phase 2 implementation was performed.

# Issue #980 — Legacy discovery and parity implementation plan

- Work Mode: full-feature
- Feature: docs/features/active/2026-10-17-legacy-discovery-and-parity-980
- Plan of record: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md
- Requirements: issue.md, spec.md, user-story.md, and requirements-traceability.md in this feature.
- Research: research/2026-10-18T02-40-core-contracts-and-analyzers-research.md and research/2026-10-18T02-40-runtime-publishing-research.md in this feature.
- Execution order: ascending phases and task numbers. Implementation begins only after the required executor preflight clears this same file.
- Scope: extend the existing capability; Python owns artifact semantics, native adapters own host enforcement, and consuming repositories own observations, decisions, and tests.
- Delivery excludes inspecting or modifying consumer repositories and excludes publishing to external package registries. Build, installation verification, repository delivery, and exact publication instructions are included.

## Size Justification

The feature changes versioned artifacts, an installable Python runtime, twelve analyzer adapters, protected native authority, three host integrations, four specialist roles, nine workflows, conversion, and publication. Independently verifiable transitions and complete baseline/final evidence require more than 40 tasks and 400 lines. Keeping these distinct avoids a single implementation or testing bucket. Each implementation task includes its own tests; final QA verifies integration and repository-wide invariants.

## Governing contracts and ownership

Apply .agents/skills/atomic-plan-contract/SKILL.md, .agents/skills/execution-environment/SKILL.md, .agents/skills/policy-compliance-order/SKILL.md, .agents/skills/evidence-and-timestamp-conventions/SKILL.md, and .agents/skills/acceptance-criteria-tracking/SKILL.md. Execution-environment exclusively defines tool routes, launchers, command restrictions, hook context, and CI shape; this plan does not duplicate them.

The orchestrator owns delegation, durable checkpoint transitions, review, commits, PR creation, and exact-head CI. It delegates each implementation task or contiguous compatible group to an appropriately routed Python, TypeScript, PowerShell, or customization specialist; no specialist changes another task's requirements. The executor checks each task only after its acceptance proof exists and reports the task transition to the orchestrator. Re-evaluate scope/model receipts before launches. No policy text is directly edited outside the canonical authoring/conversion mechanism.

After each verified task, update only satisfied existing AC checkboxes in this feature's spec.md and user-story.md, mirror the corresponding issue.md status, and attach the proof in requirements-traceability.md. Preserve all 66 requested criteria, seven Definition of Done items, and twelve seeded test conditions; do not create executor-authored criteria. Generated discovery acceptance specifications never check off implementation criteria.

SCRATCH resolves to <session scratchpad>/issue-980/. Concurrent runs for this same issue use <session scratchpad>/issue-980-<yyyy-MM-ddTHH-mm>/. All temporary helpers, staged builds/installations, isolated operational smoke workspaces, mutation copies, and transient coverage files stay under SCRATCH. Unit tests use injected memory stores and the existing mem_fs_path fixture; they create no temporary files and invoke no external process/service.

FEATURE resolves to the feature path above. Evidence is written only to FEATURE/evidence/baseline/, FEATURE/evidence/regression-testing/, FEATURE/evidence/qa-gates/, FEATURE/evidence/other/, or FEATURE/evidence/issue-updates/. Each command step gets its own write-time-stamped artifact, named <purpose>.<timestamp>.md, containing Timestamp, Command, EXIT_CODE, and Output Summary; coverage steps include numeric line/branch/new-code values. Consumers select the lexicographically greatest matching artifact. A missing value or artifact blocks completion; an invocation receipt alone is not a test result.

The following literal path aliases keep the file sets readable; append the named relative suffix exactly. Braces enumerate finite filenames, not implementation choices. New modules may be split only inside their named component when necessary for the 500-physical-line limit, with exact resulting files recorded in task evidence and the same behavior/tests retained.

| Alias | Exact workspace-relative root |
| --- | --- |
| R | packages/discovery-runtime/src/drm_copilot_discovery |
| PT | tests/discovery_runtime |
| DT | scripts/dev_tools |
| DTTEST | tests/scripts/dev_tools |
| OLDTEST | tests/scripts/dev_tools/discovery |
| ES | extensions/drm-copilot/src |
| ET | extensions/drm-copilot/test |
| S2 | schemas/discovery/v2 |
| E2 | examples/discovery/v2 |
| F2 | tests/fixtures/discovery_schemas/v2 |
| DOC | docs/engineering/legacy-discovery-and-parity |
| CH | .claude/hooks |
| XH | .codex/hooks |
| CL | .claude/lib/discovery-validation |
| CPTEST | tests/scripts/claude-hooks |
| XPTEST | tests/scripts/codex-hooks |
| LPTEST | tests/scripts/claude-lib/discovery-validation |

## Existing assertion dispositions

These sets are part of the named tasks' explicit file scope. A task citing a set owns its affected tests, including the named assertions and their parametrized cases. All other tests in that set retain their behavioral guarantees. Compatibility adapters retain public symbols where safe; safety corrections are explicit updated expectations, not waived tests.

| Set | Existing files and required disposition |
| --- | --- |
| A: value models and I/O | OLDTEST/test_{package_exports,domain_profile,profile_cli,io,rendering,init_models,domain_neutrality}.py: preserve v1 model/default/parser and pure rendering behavior; update authoritative import/patch seams after extraction. Keep all invalid-input/neutrality assertions. Profile CLI changes are owned by P6-T3. |
| B: schema and dispatch | DTTEST/test_validate_discovery_profile.py, test_validate_discovery_schema_artifacts.py, test_validate_discovery_schema_artifacts_more.py, test_validate_discovery_artifacts_dispatch.py: replace obsolete legacy_source_path successes, artifact-selected schema mocks, and main_all type-probing assertions with trusted expected-kind/version and workspace validation; retain individual wrapper dispatch/error coverage. tests/schemas/discovery/test_v1_{schema_documents,fixtures}.py and v1 fixture bytes stay unchanged. |
| C: initialization | OLDTEST/test_init_{flow,cli,models}.py and test_domain_neutrality.py: update force/nonempty-directory/overwrite assertions to no-overwrite skip/conflict/dry-run behavior; keep template/error reporting and neutral output guarantees. |
| D: reports | OLDTEST/test_{coverage_report,parity_report,completion_report,rendering,io}.py: update test_build_completion_summary_reports_entry_counts_and_readiness and missing-entry successes, rows/entries counts, main input/exit/report assertions to validated graph modes; preserve deterministic sort/serialization and I/O failure propagation. |
| E: acceptance | DTTEST/test_generate_acceptance_scenarios.py: update resolve_discovery_schema fallback, test_projection_* field assumptions, test_positive_generation_*, CLI input/output/check fixtures, and main negative-input assertions to real v1 compatibility or v2 schemas; preserve stable-ID/order/digest/neutrality checks. Split by projection, generation, and CLI before exceeding 500 lines. |
| F: analyzers | OLDTEST/analyzer/test_{models,pipeline,emitter,inventory,inventory_e2e,cli,stack_cli,source_text,dotnet_inventory,vsto_office,domain_neutrality,stack_neutrality}.py: preserve masking and valid legacy detections; update automatic-write, default marker, timestamp/digest, working-directory, eager optional-adapter, and source-re-read expectations to the specified v2 behavior. Legacy CLI adapter assertions are finalized in P6-T3. |
| G: shared host surfaces | ET/repo-automation-execute-discovery.test.ts, mcp-tool-inputs-discovery.test.ts, repo-automation-service.discovery.test.ts, extension.discovery-commands.test.ts, mcp-tools.discovery.test.ts, mcp-server.discovery.test.ts: replace positional Python dispatch, exactly-nine-kind/seven-tool assumptions, forced three generation inputs, completion pair inputs, no-parsed-artifacts success, and force-write assertions with the versioned request/result contract. Preserve cancellation, workspace choice, error propagation, and absence of terminal creation. |
| H: service callers | ET/mcp-server-test-service.ts and ET/{mcp-plan-gate-warning-projection,mcp-repo-automation-tool-definitions,mcp-server-epic-validation,mcp-server-parallel-validation,mcp-tools.codex-native-converter,mcp-tools.potential-to-issue-target-repository,mcp-tools.workspace-root,mcp-tools.push-down-claude}.test.ts: add required service stubs and updated tool enumeration only; existing nondiscovery behavior assertions remain unchanged. |
| I: discovery hook behavior | CPTEST/enforce-discovery-artifact-gate{,.ValidatorDispatch}.Tests.ps1 and validate-discovery-artifact-gate{,.ValidatorDispatch,.Dispatch}.Tests.ps1: replace unconditional Edit/missing-path/absent-profile/blank-message/transcript-path success and old-schema dispatch with activated identity/grant/current-output checks. Inactive unrelated behavior remains allowed. Existing malformed stdin, dependency failure, nonzero block, stop_hook_active, and domain-neutrality checks remain. |
| J: semantic module and helper delivery | LPTEST/DiscoveryValidation{,.VersionFloor}.Tests.ps1: P9-T7 retains export/host compatibility while replacing placeholder/Test-Json semantics with a validation-required result that cannot create authority. LPTEST/DiscoveryValidation.Manifest.Tests.ps1: P9-T1 extends ExpectedPaths, module completeness, manifest membership/uniqueness and byte mirrors when helpers first appear; P9-T7 only preserves/reruns these delivery assertions after changing compatibility semantics. tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 remains unchanged. |
| K: roles and skills | tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 and DTTEST/test_legacy_discovery_skills_contracts.py: update old Write(discovery/**), legacy-parity-analyst parity ownership, v1-only schema paths, seven-name-only and Fan-in reconciliation assumption assertions to four constrained roles, nine workflows, and seven thin aliases; preserve professional metadata, neutrality, valid routing, and mirror assertions. |
| L: routing/publication | DTTEST/test_{resolve_codex_topology,resolve_codex_deployment,generate_codex_agent_variants,codex_model_policy_config_parity,codex_model_routing_skill,codex_agent_wrapper_contracts,codex_handoff_contract_parity}.py; tests/scripts/claude-lib/codex-routing/Codex{Topology.Parity,Deployment.Parity,Deployment.GeneratedFamilies.Parity,Routing.Manifest}.Tests.ps1: expand fixed family/operation inventories and direct-discovery receipts; retain ordinary and epic routing/profile guarantees. tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1 expands the wrapper-argument map and runs every shared corpus case through Invoke-CodexTopologyCli in P7-T3; ordinary/epic assertions remain unchanged. Converter/publisher suites named in P8-T9 preserve all existing destinations and exclusion behavior. |
| M: registered hooks and bundles | tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1: P9-T4 preserves U1/U1-ST exception blocks and U2 complete validator inventory while adapting the discovery seam. tests/scripts/{claude-hooks/hook-dependency-failure.Claude,codex-hooks/hook-dependency-failure.Codex}.Tests.ps1: P9-T2/P9-T4 retain existing prefixes; P9-T6 extends ReasonPrefix exactly with registrations and retains B1-B3 fail-closed envelopes. tests/scripts/claude-runtime/claude-settings.Tests.ps1 keeps the fifteen-agent group and gains dedicated four-role registration assertions in P9-T6. tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 keeps inactive admitted-tool success, malformed-input blocks and state-isolation assertions while adding active discovery cases. tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 and DTTEST/test_codex_core_manifest_closure.py retain bundle execution/dependency closure and run when their outputs first change. |

Before changing an existing public behavior, search the test tree for its symbol, filename, and asserted output again; include any additional asserting caller in that task's change/proof record. Do not alter a shared fixture without running its full consumer set. This search supplements the explicit dispositions above rather than deferring design discovery.

## Pre-Mortem

- Review checklists: P11-T9 walks every policy-audit, code-review, and feature-audit checklist item against the branch diff from the merge base of origin/main and HEAD; missing implementation or proof remains FAIL, and independent feature review follows the executor.
- Coverage: P0-T2 through P0-T4 capture numeric baselines; P11-T2 through P11-T5 measure final totals, changed lines, per-new-module targets, Python/TypeScript branches, T2 properties/mutation trend, and no exclusion or threshold weakening.
- Mirror parity: P8-T9 and P10-T1–P10-T3 publish and validate native/resource manifests and exact profiles; P10-T4 updates execution-environment through canonical authoring and all six byte-identical copies if a stated tool-route, hook-context, CI, or packaging fact changes. No CI context change is planned.
- File size: each task counts physical lines of changed production, test, and reusable script files; the 500-line maximum includes generated wrappers and new tests. Near-limit modules are extracted into the named focused components before adding behavior.
- Test isolation: P11-T6 runs seeded shuffled Jest, reversed-order new/changed Python modules, and shuffled touched Pester file order with at least three recorded seeds; CI-shaped single-process/shard checks also run.
- CI-only behavior: P11-T7 proves independent installed resources and native-host behavior; P11-T8 verifies Linux/Windows fixture handling, no ignored artifacts dependency, no shallow-clone base assumption, correct case, deterministic LF content, and full package/contract gates.
- Evidence: every gate writes its own canonical write-time evidence; protected host authority stays distinct from editable reports. P11-T10 reconciles all 66 ACs and 22 deliverables, and P11-T11 leaves review/CI-dependent completion unchecked until actual authority passes.

Before a task runs a contract that inventories tracked files, the orchestrator stages that task's complete owned file set without committing. This prevents new package/configuration paths from being omitted by tracked-file checks. Implementation ownership is Python for Phases 1–6, customization plus routed Python/PowerShell/TypeScript resolver specialists for Phase 7, TypeScript for P8-T1–P8-T8, publishing specialists for the P8-T9 prerequisite, PowerShell for Phase 9 with the narrow P9-T2 Python classification update, publishing/documentation specialists for Phase 10, and executor verification for Phases 0 and 11. Mixed-language tasks retain the stated single behavior and use sequential owned-file handoffs.

Task evidence distinguishes changed existing code, relocated implementations with compatibility adapters, genuinely new authored code, and generated mirrors/resources; generated copies are counted separately. Reuse existing orchestration and publishing services rather than introduce a second scheduler or semantic engine.

### Phase 0 — Policy and numeric baselines

- [x] [P0-T1] Record the policy and requirement baseline.
  - Files and behavior: Read AGENTS.md, .agents/skills/{general-code-change,general-unit-test,python,python-suppressions,typescript,typescript-suppressions,powershell,quality-tiers,architecture-boundaries,self-explanatory-code-commenting}/SKILL.md in the required precedence, then FEATURE/{issue,spec,user-story,requirements-traceability}.md and both research artifacts. Write FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md.
  - Tests and proof: Inventory all 66 ACs, seven DoD items, twelve seeded conditions, existing runtime/adapters, and initial physical file lengths; confirm no C# production addition is planned.
  - Acceptance: The evidence lists the actual files read, policy order, selected full-feature mode, and unresolved baseline blockers; no implementation has preceded it.

- [x] [P0-T2] Capture the full Python baseline with coverage.
  - Files and behavior: Measure the current pyproject.toml Python scope, schemas, discovery tests, conversion/publishing/routing suites, and quality-tiers.yml classification. Write separate FEATURE/evidence/baseline/python-{format,lint,types,tests,contracts}.<timestamp>.md and numeric coverage JSON under that canonical baseline directory.
  - Tests and proof: Apply the ordered Python gate from execution-environment, including full Pytest line/branch coverage, existing discovery-specific values, and schema/resource/generator/quality-tier contracts. Preserve failing baseline diagnostics.
  - Acceptance: Every baseline step has its own exit/output artifact and numeric repository/discovery line and branch values; missing measurements remain blocking.

- [x] [P0-T3] Capture both TypeScript project baselines with coverage.
  - Files and behavior: Measure package.json and extensions/drm-copilot/{package.json,jest.config.cjs} scopes plus packages/mcp-server build contracts. Write separate FEATURE/evidence/baseline/typescript-{root,extension}-{format,lint,types,tests,architecture}.<timestamp>.md.
  - Tests and proof: Run the applicable ordered gates and coverage-enabled Jest suites for root and extension; retain per-file discovery wrapper metrics and package/build status.
  - Acceptance: Baseline records distinguish both projects, all command-step exits, numeric line/branch totals and existing changed-file thresholds; no summary-only success is accepted.

- [x] [P0-T4] Capture the PowerShell baseline with actual results.
  - Files and behavior: Measure config/{poshqc-scan,poshqc-coverage}.json scopes, discovery hooks/libraries, routing helpers, and the full registered Pester population. Write FEATURE/evidence/baseline/powershell-{format,analyze,tests}.<timestamp>.md and retain coverage/test result copies in that directory.
  - Tests and proof: Use the documented PoshQC path plus branch-current result files/direct analyzer evidence; capture full suite counts and numeric line coverage, with no invented branch metric.
  - Acceptance: Actual test/analyzer results and coverage, rather than MCP invocation summaries, establish the baseline and expose any existing failures.

### Phase 1 — Installable runtime and trusted artifact boundaries

- [x] [P1-T1] Establish the single canonical Python package and preserve value-object imports.
  - Files and behavior: Create packages/discovery-runtime/{pyproject.toml,README.md} and R/{__init__,domain_profile,domain_profile_models,init_models,io,rendering}.py by moving the existing reusable implementations once; retain thin adapters at DT/discovery/{__init__,domain_profile,domain_profile_models,init_models,io,rendering}.py. Update root pyproject.toml, poetry.lock, quality-tiers.yml, DT/quality_tiers_contract.py (DiscoveryRules, DISCOVERY_RULES, _discover_from_path), and DTTEST/test_quality_tiers_contract{,_classification}.py. Discover tracked pyproject.toml project roots before classifying the dedicated runtime T2; retain existing root/adapter classifications and exclusions.
  - Tests and proof: Add PT/test_package_contract.py; update Set A import/patch seams. Add nested/root Python-project discovery cases and extend test_discover_projects_ignores_excluded_roots; retain package.json/.csproj/module tests. Update test_committed_quality_tiers_yml_assigns_spec_tiers for only the approved new T2 package and preserve all old assignments; run test_committed_quality_tiers_yml_matches_live_tree and complete classification checks. Verify version 2.0.0, Python >=3.10, approved runtime dependencies, type/coverage inclusion, no duplicate model implementation, and unchanged v1 values.
  - Acceptance: Root tooling imports the dedicated package, legacy model exports resolve to it, and focused package/value suites pass. The tracked package exists before classification is verified; no QT007 or QT008 failure occurs at this task boundary.

- [x] [P1-T2] Build a deterministic schema/template resource staging boundary.
  - Files and behavior: Create DT/build_discovery_runtime.py, packages/discovery-runtime/resource-manifest.json, R/resources.py and its generated resource directory; initially enumerate the existing canonical schemas/discovery/v1 resources. Every following schema/template authoring task extends this same explicit allowlist when its files land. Add DTTEST/test_build_discovery_runtime.py and PT/test_resources.py.
  - Tests and proof: Exercise byte hashes, sorted manifest paths, missing/extra input rejection, importlib.resources lookup independent of cwd, dependency/resource closure reporting, and repeatable staged bytes using injected I/O. Build artifacts are operational outputs under SCRATCH or dist/discovery, not unit-test temporary files.
  - Acceptance: The builder produces a deterministic complete manifest for currently authored resources and a buildable wheel project; no lookup requires a framework checkout. P1-T3 through P1-T7 and P3-T2 extend the allowlist, and P10-T3 verifies final v1/v2/template closure.

- [x] [P1-T3] Define shared v2 reference, profile, and scope schemas.
  - Files and behavior: Create S2/{common,domain-profile,scope}.schema.json, E2/{domain-profile,scope}.example.yaml, F2/{domain-profile,scope}.invalid.yaml, and tests/schemas/discovery/test_v2_profile_schemas.py. Common definitions govern IDs, immutable repository references, independent status axes, dimensions, closed objects, and namespaced extensions.
  - Tests and proof: Validate Draft 2020-12 schemas plus valid/invalid synthetic profiles, exact versions, role/client/mode unions, strict gate booleans, extension boundaries, draft versus configured fields, and null draft pins.
  - Acceptance: All requested profile configuration fields have validated representations; optional offline/mobile requirements remain optional unless declared; core keys cannot be replaced by extensions.

- [x] [P1-T4] Define observation and evidence artifact schemas.
  - Files and behavior: Create S2/{feature-contract,evidence-reference,runtime-characterization-scenario}.schema.json, corresponding E2 examples and F2 invalid documents, and tests/schemas/discovery/test_v2_observation_schemas.py.
  - Tests and proof: Cover every specified behavior dimension, transition, trigger, permission/environment field, source/runtime evidence distinction, confidence, pre/post capture plan/result, known/unknown expectation, repeatability, and unresolved links with positive and negative cases.
  - Acceptance: Each observation artifact validates only its exact v2 kind/version and expresses all specified fields without conflating confidence, observation state, lifecycle, or runtime result.

- [x] [P1-T5] Define coverage and immutable inventory transport schemas.
  - Files and behavior: Create S2/{coverage-ledger,inventory-snapshot,source-snapshot-manifest,extension-result-manifest}.schema.json, corresponding E2/F2 fixtures, and tests/schemas/discovery/test_v2_inventory_schemas.py.
  - Tests and proof: Assert component path/symbol/span/hash, inspection/disposition, exclusions/rationale, test/runtime requirements, responsible actor, diagnostics, source pins, manifest digest, and detected/inferred adapter result structures.
  - Acceptance: Synthetic complete and partial inventories retain provenance and exact transport hashes; malformed component, manifest, and extension records fail with schema pointers.

- [x] [P1-T6] Define target parity, decisions, and acceptance schemas.
  - Files and behavior: Create S2/{parity-matrix,implementation-record,unspecified-behavior,product-decision,unspecified-behavior-collection,product-decision-collection,acceptance-specification}.schema.json, corresponding E2/F2 fixtures, and tests/schemas/discovery/test_v2_target_schemas.py.
  - Tests and proof: Cover all requested parity/decision fields, independent approval/applicability/verification states, client scopes, decision-key/supersession links, approval metadata, criterion IDs, ready/pending records, and no fabricated pending Then.
  - Acceptance: Every required target artifact and collection has a strict supported v2 schema and both passing and failing fixtures; v1 schema/fixture bytes remain unchanged.

- [x] [P1-T7] Define versioned service and authority envelope schemas.
  - Files and behavior: Create S2/{activation,service-request,service-result,discovery-invocation,required-output-manifest,validation-receipt,migration-report,capability-attestation,tool-authorization}.schema.json and tests/schemas/discovery/test_v2_control_schemas.py; extend the explicit resource manifest.
  - Tests and proof: Validate operation/mode/exit enums, findings/pointers/next actions, exact role/session/workspace/input bindings, opaque authority references, request correlation, and rejection of extra caller-selected executable or receipt-location fields.
  - Acceptance: Python, TypeScript, and native adapters have one versioned interoperability contract; a structurally valid workspace envelope alone carries no permission or success authority.

- [x] [P1-T8] Reject ambiguous or resource-exhausting structured input.
  - Files and behavior: Create R/{parsing,findings,models}.py and PT/test_{parsing,parsing_limits,findings}.py; implement parse_document and immutable finding/value types without weakening generic repository YAML/JSON helpers.
  - Tests and proof: Test duplicate JSON/YAML keys, merges, cycles, non-string keys, nonfinite/non-JSON values, wrong encoding/root types, 16 MiB/depth-64/record limits, aggregate bounded errors, stable pointer/code ordering, and round-trip/order properties.
  - Acceptance: Malformed or over-limit documents produce deterministic actionable findings before graph construction; valid JSON-compatible YAML and JSON normalize identically.

- [x] [P1-T9] Resolve expected-kind schemas through a complete offline catalog.
  - Files and behavior: Create R/{catalog,schema_validation}.py and PT/test_{catalog,schema_validation}.py; replace DT/validate_discovery_schema_artifacts.py with safe compatibility adapters. Update Set B schema tests and package resource manifest.
  - Tests and proof: Reject wrong kind, unsupported exact version, artifact-selected weaker/remote schema, unavailable jsonschema/referencing, invalid format, and extension-schema hash/network escape; accept only registered v1 aliases and v2 URNs. Preserve existing valid v1 fixture tests unchanged.
  - Acceptance: No discovery schema retrieval uses the network or reduced fallback; expected kind is caller/root controlled, and valid v1 reads are clearly compatibility-only.

- [x] [P1-T10] Load the v2 profile and immutable gate policy through one parser.
  - Files and behavior: Create R/{profile_v2,profile_models,activation_models}.py and PT/test_{profile_v2,profile_dimensions}.py; update R/domain_profile.py only for explicit version dispatch and DT/validate_discovery_profile.py for authoritative validation. Update Set B obsolete profile assertions.
  - Tests and proof: Test every profile field, custom artifact roots, combined/separate roles, multiple clients, runtime capability, inherited requirements, mandatory non-disableable claim rules, unknown gate keys, draft state, and preserved valid v1 parser behavior.
  - Acceptance: Every discovery operation receives the same typed profile/gate configuration; missing or malformed configuration fails and explicit optional dimensions do not become unconditional requirements.

- [x] [P1-T11] Enforce one cross-platform read/write path policy.
  - Files and behavior: Create R/{path_policy,path_models}.py and PT/test_{path_policy,path_resolution,path_collisions}.py, using injected path metadata rather than platform-specific unit-test disk operations.
  - Tests and proof: Cover traversal, rooted/drive-relative/UNC/device paths, reserved names, alternate streams, separator/case aliases, symlink/reparse/cyclic ancestors, sibling prefix traps, protected/output overlap, and parent replacement before commit.
  - Acceptance: Only validated workspace-relative paths inside authorized input or exact artifact grants resolve; all documented Windows/POSIX escape and collision cases fail closed.

### Phase 2 — Artifact graph and completion rules

- [x] [P2-T1] Load immutable snapshots and complete input manifests.
  - Files and behavior: Create R/{snapshot,snapshot_io,repository_reader}.py and PT/test_{snapshot,snapshot_io,repository_reader}.py; expose read adapters for local Git identities/objects and configured file snapshots.
  - Tests and proof: Account for every structured artifact, raw profile/locator, local evidence payload, imported manifest, extension schema/result, and selected source byte sequence; reject unrecognized/malformed files instead of skipping them. Test injected read failures, enumeration limits, stable ordering, and read/hash consistency.
  - Acceptance: A snapshot carries the exact complete input set and bytes used for validation, with deterministic digest and no implicit remote or neighboring-repository read.

- [x] [P2-T2] Index artifact identities and resolve typed references.
  - Files and behavior: Create R/references.py and PT/test_{references,reference_uniqueness}.py with a typed reference index over snapshots.
  - Tests and proof: Cover duplicate IDs by namespace, path-kind mismatch, missing and wrong-kind links, ambiguous foreign IDs, collection record IDs, linked scenarios/features/components/evidence, and deterministic duplicate diagnostics.
  - Acceptance: Every present reference resolves unambiguously to its expected artifact/repository identity or produces a stable blocking finding.

- [x] [P2-T3] Validate evidence integrity and declared repository revisions.
  - Files and behavior: Create R/{evidence_rules,revision_rules}.py and PT/test_{evidence_rules,revision_rules}.py.
  - Tests and proof: Check one-based inclusive spans, required capture metadata, local payload checksums, source/test/full revision pins, source-versus-target identity, inspected bytes at a local pin, imported immutable hashes, and unknown remote freshness. Prove documentation-only HEAD changes do not invalidate matching historical source bytes.
  - Acceptance: A claim cannot use replaced bytes, a mismatched expected pin, or descriptive URI-only evidence as completion proof; valid intentionally historical snapshots remain usable for their declared pin.

- [x] [P2-T4] Enforce honest observed behavior and runtime result claims.
  - Files and behavior: Create R/claim_rules.py and PT/test_{observation_claims,runtime_claims}.py.
  - Tests and proof: Test verified evidence, unknown/contradictory dimension-to-unresolved coverage, intentionally-unspecified approved rationale, confidence/state separation, first-run observed semantics, passed known expectations, required pre/post captures, environment and runtime evidence.
  - Acceptance: Prospective and stored claims reject false verified/passed states while legitimate draft/not-run/blocked observations remain structurally valid.

- [x] [P2-T5] Reconcile product approval and deterministic decision conflicts.
  - Files and behavior: Create R/decision_rules.py and PT/test_{decision_rules,decision_supersession}.py.
  - Tests and proof: Exercise valid owners/approval evidence, proposed versus approved target behavior, same decision-key overlapping feature/client/platform/mode/dimension scopes, disjoint scopes, supersession cycles, retired features, and unresolved resolutions preserving historical facts.
  - Acceptance: Only an approved scoped decision establishes target requirements; overlapping unsuperseded approvals and invalid resolution links are blocking findings.

- [x] [P2-T6] Validate complete inventory-to-ledger accounting.
  - Files and behavior: Create R/coverage_rules.py and PT/test_{coverage_rules,coverage_scope}.py.
  - Tests and proof: Check confirmed scope, every inventory component exactly once, missing/foreign ledger entries, inspection/disposition independence, unassigned/blocked statuses, linked features/tests/evidence, supporting/excluded rationale, declared runtime need, and incomplete scan diagnostics.
  - Acceptance: Structural drafts pass without false completeness; discovery completion cannot pass while an in-scope component is absent, undispositioned, blocked, or unjustifiably excluded.

- [x] [P2-T7] Evaluate required client, dimension, and scenario obligations.
  - Files and behavior: Create R/{dimension_rules,acceptance_rules}.py and PT/test_{dimension_rules,acceptance_rules}.py.
  - Tests and proof: Test the global/client/feature requirement union, explicit configured online/offline/mobile/custom classifications, approved not-applicable dispositions, required feature/criterion/client/mode scenario linkage, pending versus ready specifications, optional dimensions, and zero-feature confirmed-scope rules.
  - Acceptance: Required obligations cannot be weakened by a child record or satisfied by pending scenarios; unconfigured optional dimensions do not create failures or synthetic passes.

- [x] [P2-T8] Verify parity against immutable source contracts and target evidence.
  - Files and behavior: Create R/parity_rules.py and PT/test_{parity_rules,parity_clients}.py.
  - Tests and proof: Cover missing source contracts, wrong source revision/hash, multiple target clients, implementation/test/evidence references, full/partial/missing/conflicting states, approved changes/retirements, source test evidence misused as target proof, and per-dimension verification.
  - Acceptance: Each required parity entry resolves its pinned source and independently justified target state; no report or status string can substitute for implementation/decision evidence.

- [x] [P2-T9] Compose structural, completion, planning, and role-output validation.
  - Files and behavior: Create R/{validation,completion_rules,agent_output}.py and PT/test_{validation_modes,completion_rules,agent_output}.py; implement validate_snapshot with bounded sorted findings and exact required-output manifests.
  - Tests and proof: Exercise empty initialized structural success versus discovery failure; discovery/parity/planning modes; each configurable prerequisite; missing profile; malformed unreferenced files; all four role output sets; valid incremental output; and a reviewer output-valid/result-fail report.
  - Acceptance: The selected mode is explicit and determines success; a v1 check, structural pass, another role's receipt, or valid failing review cannot authorize completion/planning.

### Phase 3 — Safe consumer workspace operations

- [x] [P3-T1] Commit validated prospective artifact mutations with compare-and-swap.
  - Files and behavior: Create R/{mutation_plan,mutation_io}.py and PT/test_{mutation_plan,mutation_commit}.py. Plan exact artifact-kind/path/ID grants, validate the prospective graph, recheck parent metadata and input hashes, and perform exclusive creation or digest-matched replacement.
  - Tests and proof: Test unchanged bytes, invalid proposed content over valid old content, wrong roles/kinds/IDs, stale original digest, concurrent collision, parent-link replacement, bounded partial I/O failure, and repeatable dry-run; use in-memory writers.
  - Acceptance: Unauthorized or invalid prospective writes change nothing; a race or partial failure is reported explicitly and invalidates completion authority; successful mutation preserves unrelated artifacts.

- [x] [P3-T2] Initialize a structurally valid draft without overwriting existing content.
  - Files and behavior: Move/rework DT/discovery/init_flow.py into R/init_flow.py with a thin old adapter; create docs/discovery/templates/v2/{domain-profile.yaml,scope.yaml,coverage-ledger.json,unspecified-behaviors.yaml,product-decisions.yaml,parity-matrix.json}; extend resource-manifest.json. Add PT/test_{initialization,initialization_conflicts}.py and update Set C flow/model/neutrality tests.
  - Tests and proof: Cover caller-provided identity/role/roots, honest null draft pins, all configured directories, source/target/combined structures, first/repeat/partial-recovery runs, invalid existing file, conflict-before-write, no-overwrite force compatibility, and dry-run without directories/activation/receipts.
  - Acceptance: Identical inputs produce identical projected content; repeat initialization skips valid files unchanged; the created or projected draft passes structural validation and fails completion.

- [x] [P3-T3] Manage explicit activation and configuration changes.
  - Files and behavior: Create R/{configuration,activation_store}.py and PT/test_{configuration,activation_store}.py for config/discovery.json and the trusted external per-workspace activation registry.
  - Tests and proof: Test default/custom profile selection, multiple candidates, argument/locator disagreement, missing/deleted/malformed active configuration, inactive nonparticipants, root-only activate/deactivate, no authority path from inputs, platform registry locations, invalidated grants, and dry-run no writes.
  - Acceptance: Configuration deletion cannot disable an active gate; deliberate deactivation is a recorded root operation, while repositories without activation or a default profile remain unaffected.

- [x] [P3-T4] Create feature contracts and runtime scenarios with explicit unknowns.
  - Files and behavior: Create R/{draft_contracts,draft_scenarios}.py and PT/test_{draft_contracts,draft_scenarios}.py; use the shared mutation planner to create selected artifacts plus required unresolved records.
  - Tests and proof: Test unique stable IDs, custom roots, missing feature links, unknown required dimensions, multi-feature scenario linkage, nullable unknown expectations, zero synthetic approval/evidence, collisions, and dry-run.
  - Acceptance: New artifacts are structurally truthful drafts; unknown behavior has linked unresolved records and cannot become verified or passed merely through creation.

- [x] [P3-T5] Register and link verifiable evidence to an authorized artifact.
  - Files and behavior: Create R/evidence_linking.py and PT/test_{evidence_linking,evidence_payloads}.py; register evidence records and supplied local payloads, then link the specified artifact through the shared validated mutation contract.
  - Tests and proof: Cover source/test/runtime/manual/decision evidence, immutable pins/checksums, allowed payload roots, duplicate IDs, checksum mismatch, path escape, stale destination digest, missing artifact, unrelated link preservation, and partial failure reporting.
  - Acceptance: A successful evidence link identifies exact local evidence and preserves the original observation/approval state; malformed or unverified evidence cannot upgrade a claim.

- [x] [P3-T6] Export and import immutable source snapshots.
  - Files and behavior: Create R/source_snapshots.py and PT/test_{snapshot_export,snapshot_import}.py, using the versioned manifest and configured source-snapshot root.
  - Tests and proof: Exercise source revision/contract/evidence hashes, local transport manifests, foreign identities, unsupported versions, changed bytes, duplicate or conflicting imports, no-overwrite/dry-run, combined-repository identities, and multiple target clients.
  - Acceptance: Target references resolve only to locally imported bytes matching the declared immutable source identity; no sibling checkout, remote fetch, or silent snapshot replacement occurs.

- [x] [P3-T7] Migrate valid v1 artifacts into an explicit new v2 draft root.
  - Files and behavior: Create R/{migration_v1,migration_models}.py and PT/test_{migration_v1,migration_unknowns}.py; preserve v1 source files and emit the versioned mapping report.
  - Tests and proof: Test each v1 artifact kind, deterministic old/new ID/hash mapping, unresolved missing dimensions/pins/approval/expectations, namespaced unmapped metadata, collisions, invalid v1 input, unsupported migration versions, and dry-run.
  - Acceptance: Migration never overwrites originals, activates automatically, or invents confidence/approvals/parity; the projected v2 result is structurally valid and incomplete obligations remain visible.

- [x] [P3-T8] Provide bounded source inspection without executable access.
  - Files and behavior: Create R/source_reads.py and PT/test_{source_reads,source_read_limits}.py for list/read/literal-search operations over configured selected production/test/project/documentation/evidence/snapshot roots.
  - Tests and proof: Cover byte/line/match bounds, source hashes/revisions/spans, exact grants, disabled regex or bounded supported search, encoding/read failures, symlink/path escapes, and deterministic pagination/order.
  - Acceptance: The service returns source evidence metadata and bounded text/matches with no shell/process/network execution or mutation capability.

### Phase 4 — Deterministic generic inventory analyzers

- [x] [P4-T1] Move and harden repository inventory and the analyzer pipeline.
  - Files and behavior: Move DT/discovery/analyzer/{models,pipeline,inventory,emitter}.py into R/analyzer/ and leave compatibility adapters; create R/analyzer/{registry,findings}.py. Add PT/analyzer/test_{repository,pipeline,registry}.py and update Set F model/pipeline/emitter/inventory/E2E suites.
  - Tests and proof: Recognize real solution/project and generic manifest suffixes; traverse selected roots with early output/dependency/exclusion pruning; retain every included/excluded/read-failed input; hash parsed bytes once; distinguish detected/inferred findings; seed only uninspected/unassigned ledger proposals.
  - Acceptance: Default and dry-run inventory perform no writes; explicit writes are validated mutations; ordering, clock variation, separator variation, and enumeration order do not change semantic IDs/digests.

- [x] [P4-T2] Inventory declared .NET solutions and projects safely.
  - Files and behavior: Create R/analyzer/{xml_input,dotnet_projects}.py, PT/analyzer/test_{xml_input,dotnet_projects}.py, and synthetic text fixtures under tests/fixtures/discovery_analyzers/dotnet/.
  - Tests and proof: Cover .sln/.slnx, project/props/targets XML, project/package/COM references, target frameworks, conditions, implicit SDK/unresolved expressions, malformed XML, DTD/entity/network rejection, and source spans/hashes.
  - Acceptance: Explicit declarations are machine-readable detected facts with provenance; unresolved/evaluated build semantics are not presented as a resolved dependency or runtime graph.

- [x] [P4-T3] Preserve C# lexical inventory and classify event candidates honestly.
  - Files and behavior: Move/split DT/discovery/analyzer/{source_text,dotnet_inventory}.py into R/analyzer/{source_text,csharp_declarations,event_subscriptions,dotnet_inventory}.py with thin old adapters. Add PT/analyzer/test_{csharp_declarations,event_subscriptions}.py and update Set F source-text/.NET assertions.
  - Tests and proof: Preserve namespace/type/record/delegate/event/member candidates and comment/string/raw-string masking; cover arithmetic +=/-= false positives, handler candidates, multiline declarations, Unicode, line endings, and unsupported preprocessing/binding diagnostics.
  - Acceptance: Detected syntax and inferred event relationships remain separate, source references identify inspected bytes, and no module exceeds 500 physical lines.

- [x] [P4-T4] Extract configuration keys without exposing values.
  - Files and behavior: Create R/analyzer/configuration.py, PT/analyzer/test_configuration.py, and tests/fixtures/discovery_analyzers/configuration/ synthetic inputs.
  - Tests and proof: Parse JSON, secure XML, INI/settings declarations and key paths; cover conditions, duplicates/malformed input, secret-looking key values, deterministic ordering, and unsupported-format diagnostics. TOML value evaluation is not claimed without an approved compatible parser.
  - Acceptance: Findings expose key/declaration locations and provenance but no credential/secret values, executable configuration evaluation, or product-specific settings catalog.

- [x] [P4-T5] Detect generic filesystem, registry, and COM constructs.
  - Files and behavior: Create R/analyzer/{filesystem_access,registry_access,com_interop}.py and PT/analyzer/test_{filesystem_access,registry_access,com_interop}.py; extract reusable COM logic from the existing optional platform adapter without importing it from core.
  - Tests and proof: Test recognized file/directory/stream APIs, generic registry APIs/platform applicability, COM attributes/references/activation/marshal declarations, masked false positives, and unresolved runtime paths.
  - Acceptance: Static candidates are labeled inferred where appropriate and source-referenced; generic interop analysis is usable without loading any optional platform module.

- [x] [P4-T6] Map declared UI callbacks and inferred test references.
  - Files and behavior: Create R/analyzer/{ui_callbacks,test_references}.py and PT/analyzer/test_{ui_callbacks,test_references}.py with synthetic XAML/XML/code/test-project inputs.
  - Tests and proof: Cover declared callback attributes, code-behind links, unresolved symbols, test-project references, lexical production type references, ambiguous names, and negative cases that must not become coverage or test-pass claims.
  - Acceptance: Explicit declaration links and inferred test relevance are distinguishable; no finding claims runtime execution or behavioral test coverage.

- [x] [P4-T7] Inventory local declared dependencies.
  - Files and behavior: Create R/analyzer/dependencies.py and PT/analyzer/test_dependencies.py with synthetic Node package/lock, Python requirements/setup configuration, and .NET package/lock/project inputs.
  - Tests and proof: Cover pinned/unpinned versions, conditions/markers, direct versus declared lock relationships, malformed/unsupported manifests, duplicate ordering, and secret/token redaction; no package install/restore/network lookup.
  - Acceptance: Each supported ecosystem yields deterministic source-linked declarations and clear limitations; unsupported formats are diagnostics rather than fabricated evaluated dependencies.

- [x] [P4-T8] Retain the optional platform analyzer behind explicit consent.
  - Files and behavior: Move DT/discovery/analyzer/{vsto_office,vsto_patterns}.py into R/analyzer/optional/ with thin compatibility imports; update registry lazy loading, add PT/analyzer/test_optional_adapter.py, and update Set F vsto_office/stack_neutrality/domain_neutrality suites.
  - Tests and proof: Retain generic Ribbon XML/callback, interop/lifecycle/COM/API marker fixtures with secure XML and shared generic COM detector; verify disabled imports, explicit profile consent, and absence of product IDs/semantics.
  - Acceptance: Core package imports, templates, schemas, roles, and ordinary inventories contain no optional-domain behavior; the existing optional adapter works only when explicitly selected and permitted.

- [x] [P4-T9] Import local analyzer extension results as validated data.
  - Files and behavior: Create R/extension_results.py and PT/test_{extension_results,extension_inventory_merge}.py; expose the Analyzer protocol and fixed built-in registry from R/analyzer/__init__.py.
  - Tests and proof: Test manifest/schema/provenance/path validation, incomplete coverage diagnostics, collisions, declared adapter identity, deterministic merges, and rejection of executable/module/shell fields from profiles.
  - Acceptance: Consumers can contribute separately produced inventory results without modifying core code or causing configuration-driven code execution; imported findings cannot weaken accounting or confidence rules.

### Phase 5 — Generated reports and acceptance specifications

- [x] [P5-T1] Compute discovery coverage from the validated graph.
  - Files and behavior: Move/rework DT/discovery/coverage_report.py into R/coverage_report.py with a thin adapter; create R/report_models.py and PT/test_coverage_report.py; update Set D coverage/rendering assertions.
  - Tests and proof: Assert all requested component/inspection/disposition/feature/runtime/evidence/unresolved counts, explicit numerators/denominators, null zero-denominator percentages, exclusions, stable ordering, findings and input digest.
  - Acceptance: Coverage JSON and its Markdown view agree exactly and do not treat an empty, invalid, or uninventoried graph as complete.

- [x] [P5-T2] Compute parity totals per feature and client.
  - Files and behavior: Move/rework DT/discovery/parity_report.py into R/parity_report.py with a thin adapter; add PT/test_parity_report.py and update Set D parity tests.
  - Tests and proof: Cover unique features versus feature-client totals, all parity states, required/applicable per-client online/offline/mobile verification, blockers, unresolved decisions, and invalid source references.
  - Acceptance: Parity reports use the canonical entry model, retain every blocking finding, and classify undeclared optional dimensions as not-required rather than passed.

- [x] [P5-T3] Render explicit completion results and next actions.
  - Files and behavior: Move/rework DT/discovery/completion_report.py into R/completion_report.py with a thin adapter; create R/report_rendering.py, PT/test_{completion_report,report_rendering}.py, and update Set D completion/I/O tests.
  - Tests and proof: Test structural/discovery/parity/planning mode labels, blocking findings/warnings, stale/conflicting refs, incomplete artifacts, pending scenarios, deduplicated actions, both renderings, safe report replacement, and no unconditional readiness.
  - Acceptance: Completion is derived from the selected validated mode and current digest; generated views cannot overwrite authored evidence/contracts or authorize a host gate.

- [x] [P5-T4] Generate stable ready or pending acceptance records.
  - Files and behavior: Create R/{acceptance_models,acceptance_generation}.py and PT/test_{acceptance_generation,acceptance_decisions,acceptance_properties}.py; move reusable stable-ID/digest logic from DT/generate_acceptance_scenarios.py into this authority.
  - Tests and proof: Cover kind/feature/criterion/client/mode-derived identities, immutable source refs, approved scoped decisions, supersession, known legacy characterization, target requirements, unresolved/proposed/rejected expectations, and permutation/content-change properties.
  - Acceptance: Confirmed requirements yield linked ready specifications; unknown or contradictory expectations remain pending with no invented expected result, and generation never modifies implementation AC files.

- [x] [P5-T5] Render traceable Markdown and executable-ready Gherkin only.
  - Files and behavior: Create R/gherkin.py, PT/test_{gherkin,acceptance_tags}.py, and E2/acceptance/ synthetic examples; update Set E projection/generation assertions while retaining safe public adapters.
  - Tests and proof: Assert feature/scenario/client/platform/mode tags, configured offline/mobile tags, escaping/collision detection, sorted output, source/evidence/decision traceability, companion pending Markdown, and no pending executable scenarios.
  - Acceptance: Repeated generation is byte-stable; .feature output includes only ready scenarios and no implementation-specific test code or step definitions.

### Phase 6 — Authoritative service and complete CLI adapters

- [x] [P6-T1] Expose the versioned Python service and fixed gateway.
  - Files and behavior: Create R/{service,operations,gateway,doctor}.py and PT/test_{service,gateway,service_failures,doctor}.py. Implement service.execute with injected I/O/repository/clock/analyzer collaborators and operation-specific request validation; gateway reads one JSON request and emits one versioned result. doctor initially reports installed runtime/resource/profile status and explicit unavailable native capability; P8-T8 adds the protected host-probe result projection.
  - Tests and proof: Exercise every implemented operation through real validators and in-memory snapshots, stable findings/artifact statuses, unsupported requests, dependency/I/O failures, interrupted writes, result/exit consistency, and separation of local-user versus host-granted invocation context. Verify doctor remains read-only and cannot self-assert host capability.
  - Acceptance: The installed module is the sole semantic authority; malformed inputs return exit 2, blocking findings 1, runtime failures 3, and success 0 without arbitrary executable/module dispatch.

- [x] [P6-T2] Register every required noninteractive console command.
  - Files and behavior: Create R/{cli,cli_arguments,cli_commands}.py and PT/test_{cli_commands,cli_errors,cli_dry_run}.py; update packages/discovery-runtime/pyproject.toml and root pyproject.toml console registrations.
  - Tests and proof: Exercise every command in spec.md's Command inventory, including create/update/link, all individual validators, decisions/workspace modes, report pairs, snapshots/extensions/migration/configure/doctor, and both acceptance aliases. Verify workspace/profile-relative resolution, help, mutually exclusive flags, and dry-run semantics.
  - Acceptance: All documented commands invoke service.execute and return its typed outcome; validate-all emits canonical JSON and Markdown reports by default, and dry-run emits projected reports without writes.

- [x] [P6-T3] Finish safe legacy entry-point compatibility and remove checkout coupling.
  - Files and behavior: Convert DT/discovery/{profile_cli,init_cli,coverage_report,parity_report,completion_report}.py, DT/discovery/analyzer/{__init__,__main__,cli,stack_cli}.py, DT/{validate_discovery_artifacts,validate_discovery_profile,validate_discovery_schema_artifacts,generate_acceptance_scenarios}.py into thin authoritative-package adapters; add PT/test_legacy_adapters.py and update Sets A–F CLI/import consumers.
  - Tests and proof: Preserve safe named exports and all existing console names; explicitly update obsolete profile/type-probing/overwrite/report-ready/generator-field expectations and targeted argv/error assertions. Verify no runtime import reaches scripts.dev_tools or checkout-relative schemas/templates; unsupported legacy ambiguity gives an actionable migration error.
  - Acceptance: Existing safe callers reach one implementation, v1 readers remain available, and no legacy path can bypass v2 claim safety or issue completion authority.

### Phase 7 — Canonical specialist workflows and existing routing integration

- [x] [P7-T1] Author the four constrained specialist contracts canonically.
  - Files and behavior: Create .github/agents/{legacy-parity-analyst,runtime-characterization-analyst,requirements-reconciler,migration-coverage-reviewer}.agent.md and DTTEST/test_discovery_agent_contracts.py. Existing Set K native assertions are updated with the first generated outputs in P7-T3.
  - Tests and proof: Assert all specified responsibilities, project memory limits, selected source reads, closed controlled-output grants, no production/configuration/authority writes, no shell/evaluation/arbitrary MCP, no analyst approval, per-role required-output/finalize contract, and explicit failing-review semantics.
  - Acceptance: Each role has one canonical domain-neutral body with precise inputs, outputs, routing and stop obligations; native derivatives are generated later rather than independently authored.

- [x] [P7-T2] Author nine invoked workflows and reduce seven legacy skills to aliases.
  - Files and behavior: Create .github/skills/{inventory-legacy-system,extract-feature-contract,characterize-runtime-behavior,reconcile-parity-matrix,review-discovery-coverage,adjudicate-unspecified-behavior,generate-acceptance-scenarios,initialize-discovery-workspace,validate-discovery-artifacts}/SKILL.md and canonical .github/skills/discovery-{workflow,repo-inventory,coverage-ledger,runtime-characterization,parity-matrix,behavior-reconciliation,validate-artifacts}/SKILL.md aliases. Add DTTEST/test_discovery_workflow_contracts.py; Set K native expectations change with P7-T3 generation.
  - Tests and proof: Check each explicit input set, exact profile output keys, missing-configuration block, root bootstrap/approval split, prepare→exact role→finalize sequencing, incremental versus completion mode, deterministic artifacts, no standing catalog injection, and legacy alias routing correction.
  - Acceptance: All nine requested skills route to the specified roles with valid scoped output contracts; aliases contain no duplicate semantic workflow or stale future-dependency assumptions.

- [x] [P7-T3] Extend deterministic routing for zero-production-write discovery invocations.
  - Files and behavior: Update config/orchestration-routing.json, DT/{resolve_codex_topology,resolve_codex_deployment,generate_codex_agent_variants}.py, .claude/lib/codex-routing/{CodexTopology,CodexDeployment}.psm1, ES/lib/validate/{codex-topology-resolver,orchestrator-state-codex-model-routing}.ts; add focused discovery-routing helpers only beside these existing resolvers. Update Set L and ET/lib/validate/{codex-topology-resolver,codex-deployment}.test.ts, tests/fixtures/codex_routing/{topology,deployment}.json, and existing config-policy parity tests. Convert the four canonical role bases and skill bodies through the existing converter before variant generation; regenerate the corresponding .claude/agents, .claude/skills, .codex/agents, .agents/skills, bundled counterparts, and core pack entries in the same task, updating Set K. This first generation carries the new role/routing contracts; P10-T1 regenerates them again after native enforcement mapping is complete. Extend .codex/scripts/Resolve-CodexTopology.ps1::Invoke-CodexTopologyCli and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/Resolve-CodexTopology.ps1 through the existing native publication mechanism. Add the discovery selector/skill argument parsing and forwarding required by the shared topology contract; update tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1.
  - Tests and proof: Assert fixed skill→role/kind/gate mappings, production-write count zero, C1–C4/context/ceiling rules, all four generated families, unavailable-model failure, and equal Python/TypeScript/PowerShell receipts. Existing ordinary/epic topology and portable handoff behavior stays unchanged. Run that existing PowerShell CLI corpus consumer across every shared topology/deployment fixture, including positive discovery selections, rejected flags/combinations, and unchanged ordinary/epic cases.
  - Acceptance: A direct discovery invocation selects the exact existing-policy deployment without issue promotion, nested scheduler, ordinary checkpoint replacement, or silent model fallback. The published PowerShell topology CLI and the direct resolver return matching receipts for the entire shared corpus.

### Phase 8 — Shared TypeScript gateway, workspace surfaces, and native publication prerequisites

- [x] [P8-T1] Transport only validated fixed-runtime requests and results.
  - Files and behavior: Create ES/{discovery-result,discovery-runtime,discovery-service-types}.ts; refactor ES/repo-automation-execute-discovery.ts into thin operation adapters; add ET/{discovery-result,discovery-runtime}.test.ts and update Set G execute assertions. Add exact per-file entries to extensions/drm-copilot/jest.config.cjs. Because jest.config.cjs is already 493 physical lines, extract the discovery per-file thresholds to extensions/drm-copilot/jest.discovery-coverage.json and merge that map from the existing configuration; add ET/discovery-coverage-contracts.test.ts. Preserve existing stricter entries and gate new executable modules at 90% lines and 75% branches.
  - Tests and proof: Test fixed isolated installed-module invocation, trusted interpreter selection, JSON stdin, version/build compatibility, malformed/truncated output, inconsistent process/result exits, missing dependencies, stderr context, actionable install diagnostics, and no shell interpolation/human sentence parsing.
  - Acceptance: Both hosts receive authoritative structured findings/artifacts or a blocking transport error; malformed stdout can never be reported as successful validation.

- [x] [P8-T2] Own protected activation and authority storage outside workspaces.
  - Files and behavior: Create ES/{discovery-authority,discovery-authority-paths}.ts and ET/{discovery-authority,discovery-authority-paths}.test.ts; add per-file coverage entries. Share versioned registry/envelope formats with R/activation_store.py through schema fixtures.
  - Tests and proof: Test Windows/macOS/Linux trusted user-state resolution, canonical workspace hashes, session/invocation partitioning, external containment, profile/locator hash binding, exclusive writes, malformed store records, and rejection of analyst-supplied destination/identity/success claims.
  - Acceptance: Editable workspace reports and invocation mirrors cannot create or modify native authority; activation survives locator/profile deletion and all store I/O is isolated behind testable adapters.

- [x] [P8-T3] Consume exact one-use tool authorizations.
  - Files and behavior: Create ES/discovery-authorization.ts and ET/discovery-authorization.test.ts; add its coverage threshold and versioned native tool/input digest fixtures under tests/fixtures/discovery_host/.
  - Tests and proof: Test exact normalized request ID/tool/input digest plus trusted agent/session/role binding, expiry, duplicate/ambiguous matches, replay, concurrent consumption, wrong workspace, unknown operation, and root-only versus analyst operations.
  - Acceptance: Only a matching unconsumed native authorization admits a controlled tool request; caller role strings or request IDs cannot expand grants or impersonate a root approval.

- [x] [P8-T4] Prepare constrained discovery invocations through existing routing authority.
  - Files and behavior: Create ES/{discovery-invocation,discovery-routing}.ts and ET/{discovery-invocation,discovery-routing}.test.ts; bind existing resolver outputs, capability attestation, expected artifact outputs and selected inputs. Add coverage entries.
  - Tests and proof: Cover all nine workflows/four roles, exact model/effort/profile hash, parent/session context, zero-code-write topology, protected record and diagnostic mirror separation, absent feature checkpoint, unsupported capability, output-contract substitution, and nested self-launch denial.
  - Acceptance: prepare_discovery_agent returns a launchable exact deployment only after persisted protected bindings, without modifying artifacts/orchestration/orchestrator-state.json or requiring a new feature issue.

- [x] [P8-T5] Finalize role output and mint fresh gate-specific receipts.
  - Files and behavior: Create ES/{discovery-finalization,discovery-input-manifest}.ts and ET/{discovery-finalization,discovery-input-manifest}.test.ts; add coverage entries. Recompute the complete input set/hashes independently after the Python result before protected receipt creation.
  - Tests and proof: Test missing/new/deleted/renamed/edited inputs, evidence replacement, profile/root changes, schema/runtime/build/policy drift, wrong gate/role/session, absent outputs, forged success JSON, and valid output-valid/result-fail reviewer results.
  - Acceptance: Only a current authoritative result bound to the exact invocation/output/gate produces a protected receipt; source mutation or mismatched result invalidates it before stop/planning can succeed.

- [x] [P8-T6] Expose the full shared MCP operation contract.
  - Files and behavior: Update ES/{mcp-discovery-tool-definitions,mcp-tool-inputs-discovery,mcp-handlers/discovery-handlers,mcp-tools,repo-automation-tool-names,repo-automation-service-contract,repo-automation-service}.ts; extract ES/{mcp-discovery-authority-tool-definitions,mcp-tool-inputs-discovery-authority,repo-automation-service-discovery}.ts to keep files bounded. Update Sets G/H and add ET/mcp-discovery-authority-tools.test.ts; add every new executable module's coverage entry.
  - Tests and proof: Retain seven existing tools and add configure/create/update/link/transfer/import/migrate/read/prepare/finalize plus diagnostic operation as specified; test closed input enums, whole-workspace modes, noninteractive dry-run, service stub consumers, role-denied tools, and text/structuredContent/isError agreement.
  - Acceptance: Extension and standalone MCP share one service implementation; no wrapper computes schema, coverage, parity, or approval semantics, and all shared nondiscovery contract tests remain green.

- [x] [P8-T7] Register justified VS Code commands without business logic.
  - Files and behavior: Update ES/discovery-command-registration.ts and extensions/drm-copilot/package.json; extract ES/discovery-artifact-command-registration.ts and ES/discovery-workspace-command-registration.ts. Update ET/extension.discovery-commands.test.ts, add ET/discovery-artifact-commands.test.ts, and add coverage thresholds.
  - Tests and proof: Test existing command ID compatibility, initialize/configure/inventory/create/link/validate/reports/generate/snapshot/migrate/diagnostic commands, direct structured arguments, only-missing-input prompts, cancellation, custom workspace/profile, and no terminal creation.
  - Acceptance: Every documented user-facing operation is available noninteractively and calls the shared MCP/service contract; prepare/finalize and bounded reads remain agent/service operations.

- [ ] [P8-T8] Define current host capability diagnostics and probe orchestration.
  - Files and behavior: Create ES/discovery-capabilities.ts and ET/discovery-capabilities.test.ts; extend R/doctor.py and PT/test_doctor.py from P6-T1 to project protected host diagnostics through the existing gateway/service. Add the TypeScript module coverage entry.
  - Tests and proof: Require trusted observed hook start/tool/stop attribution, exact host/config/hook hashes and harmless denial sentinel result; reject caller-only capabilities, disabled hooks, missing trust, unsupported harness, stale probes, wrong workspace and runtime versions.
  - Acceptance: doctor explains installation/configuration deficiencies, while controlled agent preparation returns DISCOVERY_ENFORCEMENT_UNAVAILABLE until an actual supported-host probe is current; CLI read-only diagnostics remain usable.

- [ ] [P8-T9] Enable approved native publication classifications and mappings before hook creation.
  - Files and behavior: Update DT/codex_native_converter/{inventory,classifier,mapping,pipeline,rewrites,validation}.py, ES/lib/codex-native-converter/{inventory,classifier,classifier-claude,mapping,pipeline,rewrites,validation}.ts, DT/{agentic_sync,push_down_copilot_customizations,push_down_codex_and_agents_customizations}.py, and ES/lib/push-down/{copilot-customizations,copilot-customizations-engine,codex-agents-customizations}.ts. Extend _classify_github_copilot/_classify_claude and classifyGithubCopilot/classifyClaude for the approved GitHub hooks and native helper/config/docs/template resources, with explicit per-host mappings and complete helper closure.
  - Tests and proof: Update DTTEST/codex_native_converter/test_{inventory,classifier,mapping,rewrites,validation,end_to_end}.py and ET/lib/codex-native-converter/{inventory,classifier,mapping,pipeline,rewrites,validation}.test.ts. Update DTTEST/test_{agentic_sync,push_down_copilot_customizations,push_down_copilot_customizations_helpers,push_down_copilot_customizations_rewrites,push_down_codex_and_agents_virtual_paths}.py and corresponding ET/lib/push-down suites. Add positive approved-surface classifications and preserve unrelated/foreign unsupported-path rejection, existing destination/exclusion assertions, mapping validation and in-memory publication fixtures.
  - Acceptance: The existing publishing/conversion pipeline can classify and deliver the approved native surfaces before P9-T1 creates helper files. No unrelated path becomes supported, and no instruction-only restriction is represented as a native control. Actual helper/hook mirrors are verified at each P9 creation/change task and final publication.

### Phase 9 — Native tool, output, and planning enforcement

- [ ] [P9-T1] Share narrow native authority, payload, and freshness primitives.
  - Files and behavior: Create CL/{DiscoveryAuthority.psd1,DiscoveryAuthority.psm1,DiscoveryManifest.psm1,DiscoveryPayload.psm1} and LPTEST/{DiscoveryAuthority,DiscoveryManifest,DiscoveryPayload}.Tests.ps1. Update LPTEST/DiscoveryValidation.Manifest.Tests.ps1 ExpectedPaths and complete on-disk-module assertions now. Using the P8-T9 mapping prerequisite, publish the helper files to extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/ and the corresponding mapped Codex bundle helper directory; update the affected core pack manifests. Retain the existing .claude/lib/discovery-validation tier; GitHub hook population/classification is introduced with its first tracked hook in P9-T2.
  - Tests and proof: Use captured synthetic Claude/Codex/Copilot event envelopes and injected file/clock/store seams; verify trusted principal attribution, external authority location, canonical path hashes, complete input enumeration, current raw hashes, malformed/dependency failures and inactive detection. No Python or duplicate schema/graph logic. Run DiscoveryValidation.Manifest.Tests.ps1 at this boundary for every new module, manifest membership/uniqueness and byte identity; run DTTEST/test_push_down_claude_{resource_contracts,pack_manifest_completeness}.py and DTTEST/test_codex_core_manifest_closure.py. Preserve existing exports and module inventory assertions; do not defer helper mirror proof until Phase 10.
  - Acceptance: All hosts share the same narrow permission/receipt semantics; altered, added, missing, deleted, renamed, or untrusted authority inputs fail closed. All new helpers have current published mirrors/manifests, and classification produces no QT007/QT008 at this boundary.

- [ ] [P9-T2] Enforce tool and exact artifact grants before every analyst action.
  - Files and behavior: Replace CH/enforce-discovery-artifact-gate.ps1 with the native authorization adapter; add XH/enforce-discovery-artifact-gate.ps1 and .github/hooks/discovery-pre-tool.ps1, using shared CL helpers. Update Set I PreToolUse suites and add XPTEST/discovery-pre-tool.Tests.ps1 plus tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1. With the first tracked .github/hooks/discovery-pre-tool.ps1, update DT/quality_tiers_contract.py (DISCOVERY_RULES.hook_roots and _discover_from_path), quality-tiers.yml, config/{poshqc-scan,poshqc-coverage}.json, and DTTEST/test_quality_tiers_contract{,_classification}.py to discover/classify/measure .github/hooks. Publish this task's canonical hook/helper outputs and affected manifests through P8-T9 mappings.
  - Tests and proof: Deny shell/terminal/exec/evaluation, generic Write/Edit/apply_patch, arbitrary MCP dispatch, outside grants, production/test/config/profile/locator/schema/policy/authority mutations and approval escalation; authorize only current allowed requests with one-use exact digest records. Test new/changed proposed bytes through the service boundary rather than old disk content. Extend test_discover_projects_discovers_hook_roots_only_with_tracked_file for .github/hooks, including absent/excluded-root negatives; extend approved committed tier assignments without altering existing ones. Preserve the existing DISCOVERY_ARTIFACT_GATE_BLOCKED: reason envelope for the replaced Claude hook and run its dependency-failure assertions. Run current helper/pack mirror and quality-tier classification checks.
  - Acceptance: Each supported native adapter blocks unauthorized attempts before execution; valid bounded reads and controlled draft mutations remain possible without a prior passing completion gate. The first GitHub hook is tracked before its classification/coverage checks; no QT007/QT008, premature classification, or unpublished helper dependency remains.

- [ ] [P9-T3] Attest discovery starts without altering feature checkpoints.
  - Files and behavior: Extend XH/{record-subagent-routing-attestation,codex-agent-profile-attestation,enforce-codex-model-routing}.ps1 with focused XH/discovery-start-attestation.ps1; add CH/record-discovery-agent-start.ps1 and .github/hooks/discovery-agent-start.ps1. Update XPTEST/{subagent-attestation-command,subagent-attestation-persistence,model-profile-attestation,enforce-codex-model-routing.Coverage}.Tests.ps1 and add CPTEST/discovery-start.Tests.ps1, XPTEST/discovery-start.Tests.ps1, and tests/scripts/copilot-hooks/discovery-start.Tests.ps1.
  - Tests and proof: Check protected discovery-invocation receipt kind, trusted parent/session, actual exact role/model/effort/profile hash, allowed schema/runtime/build and capability, missing/wrong receipts, mirror tampering, nested launch, absent ordinary checkpoint, and unchanged ordinary/epic start cases.
  - Acceptance: No tool grant activates before matching native start attestation; direct discovery actions work without feature promotion or fabricated model receipts.

- [ ] [P9-T4] Validate each specialist's actual required outputs at stop.
  - Files and behavior: Replace CH/validate-discovery-artifact-gate.ps1 with per-role protected output validation; add XH/validate-discovery-agent-output.ps1 and .github/hooks/discovery-agent-stop.ps1; extend XH/validate-codex-subagent-routing.ps1. Update Set I Stop suites, XPTEST/validate-codex-subagent-routing.Coverage.Tests.ps1, and add CPTEST/discovery-output.Tests.ps1, XPTEST/discovery-output.Tests.ps1, and tests/scripts/copilot-hooks/discovery-output.Tests.ps1. Update tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 when the legacy stop implementation changes; preserve envelope-helper exception interception and the existing DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix. Publish the changed native hook mirrors/manifests in this task.
  - Tests and proof: Parametrize all four roles and generated variants; test missing/blank final text, absent required path/ID/kind, stale input/profile/evidence, wrong session/role/gate, forged workspace success, missing helper, output-valid failing reviewer report, and valid incremental results. Retain U1/U1-ST exit-2 guarantees and U2 complete validator inventory, adapting only the discovery validator's authorized seam/rows. Run the existing helper manifest/byte-identity checks and native bundle probe; unrelated and inactive stop behavior remains unchanged.
  - Acceptance: Every role has an enforced stop result derived from its protected invocation; filenames or success prose in an assistant message cannot bypass validation.

- [ ] [P9-T5] Gate implementation planning on current configured discovery authority.
  - Files and behavior: Create CH/enforce-discovery-planning-gate.ps1, XH/enforce-discovery-planning-gate.ps1, .github/hooks/discovery-planning.ps1, CPTEST/discovery-planning-gate.Tests.ps1, XPTEST/discovery-planning-gate.Tests.ps1, and tests/scripts/copilot-hooks/discovery-planning.Tests.ps1.
  - Tests and proof: Test atomic-planner/orchestrator planning entry with discovery-complete/parity-complete/none settings, inactive repositories, active missing/deleted/malformed profile/locator, stale/current/wrong-mode receipts, and structural/v1/output-only receipts that must not authorize planning.
  - Acceptance: Configured incomplete discovery blocks planning before delegation; inactive consumers follow existing behavior, and hooks only verify authority without invoking Python.

- [ ] [P9-T6] Register native events and execute a harmless capability probe.
  - Files and behavior: Update .claude/settings.json and .codex/config.toml through the native publishing mechanism; create .github/hooks/discovery.json, CH/discovery-capability-probe.ps1, XH/discovery-capability-probe.ps1, .github/hooks/discovery-capability-probe.ps1, and scripts/dev-tools/Test-DiscoveryHostCapability.ps1. Add CPTEST/discovery-capability.Tests.ps1, XPTEST/discovery-capability.Tests.ps1, tests/scripts/copilot-hooks/discovery-capability.Tests.ps1, and tests/scripts/dev-tools/Test-DiscoveryHostCapability.Tests.ps1 for registration and probes. Update tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 and tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 ReasonPrefix tables at registration; update tests/scripts/claude-runtime/claude-settings.Tests.ps1 and tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 for the new registered handlers. Publish settings/hooks/helpers and affected native core manifests through the available P8-T9 mechanism in this task.
  - Tests and proof: Verify actual host-shaped event registration, agent variants, trusted start/tool/stop attribution, Workspace Trust/enabled-hook requirements, allowed/forbidden MCP tool sets, harmless denied sentinel, current handler/config hashes, and missing/disabled/unsupported host failure. Use mocks for unit-test process boundaries. Keep each ReasonPrefix table equal to its discovered registered-hook set; retain B1-B3 missing dependency/bootstrap block envelopes. Preserve the existing fifteen-agent Claude stop group and add dedicated coverage for the four discovery roles. Retain Codex every-admitted-tool inactive success, malformed-input fail-closed and no-leaked-state assertions while adding activated denial tests. Run tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1, DTTEST/test_codex_core_manifest_closure.py and both existing Claude/Codex pack-manifest completeness suites now.
  - Acceptance: Only observed protected probe evidence enables native discovery launches; a caller capability Boolean or embedded YAML instruction cannot substitute for actual controls. Registration tests, dependency failures and all touched native/bundle copies agree at this task boundary; final Phase 10 generation cannot conceal an earlier broken hook contract.

- [ ] [P9-T7] Retire independent PowerShell artifact semantics and preserve hook contracts.
  - Files and behavior: Refactor CL/DiscoveryValidation.psm1 to bounded compatibility exports that direct semantic validation to the authoritative normal service; update Set J semantic/version tests, preserve and rerun the already-current P9-T1 manifest assertions, publish the changed compatibility module mirror, and update tests/scripts/claude-runtime/{enforcement-hooks-no-python-invocation,hook-dependency-guard-completeness}.Tests.ps1.
  - Tests and proof: Retain actionable fail-closed missing-authority/unsupported-host behavior; remove artifact-selected schema/profile parsing and false success. Verify no direct or indirect Python invocation, guarded helper loading, new-module export correctness, and old entry names cannot mint a passing gate.
  - Acceptance: One Python engine owns artifact meaning, native hooks verify protected current authority, all compatibility Pester assertions match the deliberate contract, and no changed script/module/test exceeds 500 lines.

### Phase 10 — Publication, installed resources, and consumer documentation

- [ ] [P10-T1] Regenerate the three complete native customization bundles.
  - Files and behavior: Regenerate the four role families, all nine workflows/seven aliases, native settings/hooks/helpers, .agents/.codex/.claude outputs, extensions/drm-copilot/resources/{copilot-customizations,claude-customizations,codex-and-agents-customizations}, and affected core pack manifests from canonical sources and explicit native adapter mappings.
  - Tests and proof: Run Set K/L plus DTTEST/test_push_down_{claude_resource_contracts,claude_pack_manifest_completeness,codex_and_agents_resource_contracts,codex_and_agents_pack_manifest_completeness,issue_824_follow_ups}.py, test_skill_bundle_contract_repo.py, test_claude_rules_frontmatter.py, native architecture/dependency contracts, and generator check mode. Add DTTEST/test_discovery_publication_contracts.py for complete role/skill/hook/tool/resource representation.
  - Acceptance: All source/bundle bytes and manifest inventories agree, every logical role has exact native variants and stop/tool controls, and no unresolved source-ecosystem reference or consumer-specific standing content remains.

- [ ] [P10-T2] Verify VSIX and standalone MCP package contents.
  - Files and behavior: Update packages/mcp-server/prepack.cjs and extension packaging allowlists only as needed for newly mapped non-Python resources; update ET/packaging/mcp-server-prepack.test.ts and add ET/packaging/discovery-resources.test.ts. Preserve the explicit Python-source exclusion and shared-server build.
  - Tests and proof: Assert all published hooks/helper/config/setup/template references survive packaging, standalone imports no VS Code host, wheel runtime requirement is explicit, and shared MCP input/result/tool sets match extension registration. Build both distributables and record FEATURE/evidence/other/discovery-host-packages.<timestamp>.md.
  - Acceptance: The built VSIX/npm artifacts contain complete native customization support and thin shared wrappers without copied Python business logic or unresolved resource references.

- [ ] [P10-T3] Build the versioned Python wheel with complete isolated resources.
  - Files and behavior: Finalize packages/discovery-runtime/{pyproject.toml,resource-manifest.json,README.md}, DT/build_discovery_runtime.py and their tests; produce dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl and FEATURE/evidence/other/discovery-wheel-build.<timestamp>.md.
  - Tests and proof: Inspect wheel metadata/import closure, all console entries, frozen v1 and exact v2 schema/template hashes, required approved dependencies, no unrelated root ML/dev dependencies, and deterministic staged manifests. Keep operational build work under SCRATCH and record the actual artifact digest/version.
  - Acceptance: The wheel is buildable from the dedicated package and includes every runtime resource; final independent installation proof is scheduled in P11-T7.

- [ ] [P10-T4] Document the complete reusable architecture and operational contracts.
  - Files and behavior: Update DOC/{README,domain-profile,artifacts-and-schemas,workflow,running-the-workflow,consumer-onboarding}.md; add DOC/{architecture,analyzers,enforcement,migration,cli-reference,maintainer-guide}.md and a Mermaid architecture diagram. Update docs/engineering/claude-code-architecture.md and canonical .github/skills/{orchestrator-workflow,atomic-planner}/SKILL.md only through authoring/conversion for the discovery planning prerequisite and criteria linkage.
  - Tests and proof: Add DTTEST/test_discovery_documentation_contracts.py and update tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1. Cover field/status/version semantics, ownership, local setup, no-runtime/manual/combined/separate/multiclient flows, safe extensions, evidence/pins, analyzer limits, supported native controls, inactive compatibility, migration, all commands, and criteria-versus-test-pass separation. If any execution-environment fact changes, update its canonical .github skill and all six byte-identical copies in this same task; otherwise record the unchanged-fact check.
  - Acceptance: A consumer can install and operate the full capability without a framework checkout or implied completion; all links and generated workflow mirrors are current and no standing policy is edited ad hoc.

- [ ] [P10-T5] Prepare exact publication and separated consumer handoff instructions.
  - Files and behavior: Create DOC/examples/taskmaster-tmw.md and FEATURE/handoff.md with the example source/target trees and exact built package versions/digests/install commands, interpreter setting, three installed MCP push-down argument shapes, host probe, initialization and validation sequence.
  - Tests and proof: Reconcile the actual wheel/VSIX/npm evidence and list every consumer-owned local profile, scope, inventory, contract, characterization, evidence, unresolved/decision, source snapshot, implementation, parity, acceptance and report artifact; distinguish target architecture and implementation tests from reusable framework output.
  - Acceptance: The handoff states exact publication prerequisites and local source/target work without inspecting, populating, or modifying either consumer; domain names appear only in this separated example and feature delivery records.

### Phase 11 — Full verification, self-review, and execution handoff

- [ ] [P11-T1] Prove the complete source and target public workflows in memory.
  - Files and behavior: Create PT/test_{public_source_workflow,public_target_workflow,public_combined_workflow}.py, ET/discovery-public-workflow.test.ts, and shared synthetic fixtures under tests/fixtures/discovery_workflow/; write FEATURE/evidence/regression-testing/discovery-public-workflows.<timestamp>.md.
  - Tests and proof: Drive init→inventory→scope/coverage/contracts/unknowns→runtime/manual evidence→decision→source export/import→target implementation/parity→ready/pending acceptance→all reports/gates through real service rules. Cover no-runtime, optional dimensions, multiple clients, repeat runs, dry-run, malformed/unreferenced artifacts, stale bytes, and negative exit mapping.
  - Acceptance: The public path demonstrates structural draft success, honest incomplete discovery failure, evidence-backed completion and parity, and no false pass in any negative scenario; host transport uses the same authority.

- [ ] [P11-T2] Complete the Python formatting, lint, type, and full coverage loop.
  - Files and behavior: Verify all changed Python code/tests, dedicated runtime package, root adapters, schemas, generator/converter/publisher/build modules using pyproject.toml and package configuration. Write separate FEATURE/evidence/qa-gates/python-{format,lint,types,tests}.<timestamp>.md plus canonical numeric coverage output.
  - Tests and proof: Run the complete documented order and restart at formatting after every fix/failure; run full Pytest with line and branch coverage, exact-version schema fixtures, new package import closure, and existing safe v1/compatibility suites.
  - Acceptance: One clean pass has zero formatter/lint/type/test failures, Python line coverage meets the existing 85% CI floor, branch coverage is at least 75%, and required numeric new/changed coverage is available for P11-T5.

- [ ] [P11-T3] Complete both TypeScript project quality loops and builds.
  - Files and behavior: Verify root and extensions/drm-copilot TypeScript, shared MCP wrappers, new authority/operation modules, conversion/publishing adapters, and packages/mcp-server build inputs. Write separate FEATURE/evidence/qa-gates/typescript-{root,extension}-{format,lint,types,tests,architecture,build}.<timestamp>.md.
  - Tests and proof: Apply the documented ordered loops, complete coverage-enabled Jest populations, source/test type checks, architecture-boundary checks, and both extension/standalone builds; restart from formatting after any fix/failure.
  - Acceptance: All applicable root/extension tests and builds pass in one clean cycle, no architecture violation remains, and new per-file thresholds are measured rather than bypassed by blanket mocks.

- [ ] [P11-T4] Complete PowerShell gates and CI-shaped execution.
  - Files and behavior: Verify changed canonical and generated PowerShell hooks/libraries/scripts, config/poshqc coverage population, and every touched Pester suite. Write separate FEATURE/evidence/qa-gates/powershell-{format,analyze,tests,single-process,shards}.<timestamp>.md with retained actual result/coverage files.
  - Tests and proof: Run formatting→analysis→tests in the documented order, restart after fixes, inspect actual analyzer/JUnit/coverage evidence, execute the full registered population in CI-shaped single-process and shard/completeness form, and include new Copilot hook suites.
  - Acceptance: No formatting/analyzer/test failure, missing shard, leaked module state, or incomplete coverage population remains; PowerShell line metrics are numeric and no branch metric is fabricated.

- [ ] [P11-T5] Verify coverage deltas and T2 rigor without lowering existing gates.
  - Files and behavior: Write FEATURE/evidence/qa-gates/{coverage-comparison,tier-properties-mutation}.<timestamp>.md from the latest baseline/final artifacts and the changed-file/function inventory; update missing focused tests only in their owning PT/ET/Pester files, then repeat affected full loops.
  - Tests and proof: Record a baseline/final/delta coverage table for every changed production file, including relocated-source baselines: Python and TypeScript lines >=85% and branches >=75%; PowerShell lines >=85%. Identify genuinely new files as absent from the baseline with zero prior executable lines, then measure their complete final coverage. Require repository lines >=80% and every stricter configured floor, new module/class/method lines >=90%, and no regression on changed lines. Map at least one deterministic property test to every new T2 pure function, execute core-path E2E, record retry rate and a bounded deterministic AST mutation trend over staged path/claim/completion/acceptance modules under SCRATCH with killed/survived/equivalent counts.
  - Acceptance: Every changed production file has its required baseline provenance, final numeric measurements and delta disposition; Python/TypeScript per-file 85% line/75% branch and PowerShell per-file 85% line floors, stricter existing floors, new-code 90%, repository 80% and changed-line no-regression gates pass. Missing measurements fail the gate. T2 property/contract-major/E2E/determinism obligations and mutation trend have evidence.

- [ ] [P11-T6] Prove isolation and cross-platform input behavior.
  - Files and behavior: Write FEATURE/evidence/regression-testing/discovery-isolation.<timestamp>.md and per-run evidence under the same directory; keep transient ordering helpers under SCRATCH.
  - Tests and proof: Run seeded shuffled Jest with recorded seed, reversed-order all new/changed Python modules, and shuffled touched Pester file order with at least three recorded seeds. Exercise Windows/POSIX/case/reparse/UNC/line-ending fixtures, no mutable global state, and no unit-test temporary files/processes/network.
  - Acceptance: Every isolation order passes with reproducible seeds and no suite-specific ambient PATH/cwd/profile assumptions; failures are fixed and the affected full language loop is repeated.

- [ ] [P11-T7] Verify independent installed runtime and actual native host controls.
  - Files and behavior: Build/install the exact wheel and host packages into issue-scoped operational locations under SCRATCH; write FEATURE/evidence/qa-gates/discovery-installed-runtime.<timestamp>.md and discovery-native-capabilities.<timestamp>.md with actual versions/digests and probe results.
  - Tests and proof: Exclude the source checkout from import search paths and exercise every exposed console operation/resources, shared standalone MCP tools, and justified extension commands. For Claude Code, Codex, and the supported Copilot Local harness, run the automated capability smoke with real start/tool/stop events, harmless prohibited-operation denial, valid controlled output, stale receipt block, and disabled/unsupported fail-closed cases.
  - Acceptance: Installed behavior has no checkout dependency and all advertised supported-host controls have observed positive and negative proof. An unavailable or failed required installed-host check is an explicit blocker; no manual/user QA substitution or unsupported-host prevention claim is allowed.

- [ ] [P11-T8] Run complete repository and publication contracts on the final implementation.
  - Files and behavior: Write FEATURE/evidence/qa-gates/discovery-repository-contracts.<timestamp>.md and separate command-step records for schema/docs/architecture/tier/generator/mirror/packaging/neutrality/size checks; use the full task-owned branch file set.
  - Tests and proof: Run all execution-environment contract suites and Set L, canonical-source conversion review, unresolved-reference checks, all three bundle/pack completeness checks, generator check mode, staged resource hashes, VSIX/npm closure, documentation links, package metadata, source-neutrality scan with only the isolated optional adapter/case study exceptions, and physical line counts. Stage task-owned new files through the orchestrator before tracked-file inventory checks.
  - Acceptance: All applicable repository checks and all source/bundle/package contracts pass with no generated drift, unsupported reference, unclassified project, production/test/script over 500 lines, forbidden test I/O, or consumer-specific core content.

- [ ] [P11-T9] Perform the required complete checklist self-review.
  - Files and behavior: Read docs/features/templates/policy_audit/{policy-audit.yyyy-MM-ddTHH-mm,code-review.yyyy-MM-ddTHH-mm,feature-audit.yyyy-MM-ddTHH-mm}.md against the entire branch diff from the merge base of origin/main and HEAD; write FEATURE/evidence/qa-gates/self-review.<timestamp>.md.
  - Tests and proof: Include one PASS, FAIL, or justified N/A row for every template checklist item, requirements/AC traceability, source-authority separation, installed proof, native grants, all existing asserting tests, evidence completeness, and architecture/file-size/isolation/coverage checks.
  - Acceptance: No FAIL or unverified blocking row remains; every correction is tested through the affected full loop before the self-review is rewritten.

- [ ] [P11-T10] Reconcile acceptance evidence and the publication handoff.
  - Files and behavior: Update FEATURE/{requirements-traceability,spec,user-story,issue,handoff,completion-report}.md and DOC/examples/taskmaster-tmw.md using verified task/QA evidence only; write FEATURE/evidence/qa-gates/acceptance-criteria-status.<timestamp>.md.
  - Tests and proof: Map each of AC-01–AC-66 and D01–D22 to exact implementing task/artifact/test evidence, account separately for seven DoD and twelve seeded conditions, record conditional C# applicability, actual package versions/digests, known analyzer/host limits, backward compatibility, and exact remaining local consumer work.
  - Acceptance: Every verified criterion is individually checked without text changes; review/CI-dependent criteria remain explicitly pending until their own gates pass, and the report does not claim feature completion prematurely.

- [ ] [P11-T11] Return a complete executor handoff for independent review and repository delivery.
  - Files and behavior: Finalize this plan's verified task state and FEATURE/completion-report.md; provide the orchestrator all baseline/final/coverage/self-review/package/handoff references and remaining review/CI-dependent acceptance items.
  - Tests and proof: Validate the plan and applicable execution artifacts, confirm each checked task has canonical proof, and supply full-branch review inputs. The orchestrator continues the mandatory lifecycle described below rather than treating this executor handoff as feature DONE.
  - Acceptance: The implementation/QA handoff is internally consistent and review-ready, with no unreported blocker or false completion claim; independent audit and exact-head CI remain mandatory delivery gates.
## Acceptance and deliverable coverage

The exact criterion text remains in the requirements sources; these ranges identify implementing tasks rather than replace those requirements.

| Acceptance IDs | Implementing and proving tasks |
| --- | --- |
| AC-01–AC-04 | P1-T1, P1-T10–P1-T11, P2-T1–P2-T9, P3-T3, P6-T1–P6-T3, P9-T5, P11-T1 |
| AC-05–AC-09 | P7-T1–P7-T3, P8-T3–P8-T8, P9-T1–P9-T7, P8-T9, P10-T1, P11-T7 |
| AC-10–AC-14 | P1-T2–P1-T10, P2-T1–P2-T5, P3-T7, P11-T2 |
| AC-15–AC-19 | P3-T1–P3-T4, P6-T2, P8-T6–P8-T7, P11-T1 |
| AC-20–AC-30 | P2-T1–P2-T9, P3-T1, P5-T1–P5-T3, P6-T1–P6-T3, P8-T5, P9-T2–P9-T5 |
| AC-31–AC-36 | P4-T1–P4-T9, P3-T8, P11-T1, P11-T6 |
| AC-37–AC-42 | P1-T1–P1-T2, P1-T11, P3-T1–P3-T8, P6-T1–P6-T3, P8-T1–P8-T8, P11-T7 |
| AC-43–AC-47 | P7-T1–P7-T3, P9-T1–P9-T7, P8-T9, P10-T1–P10-T3, P11-T7–P11-T8 |
| AC-48–AC-52 | P2-T5, P2-T7–P2-T8, P3-T6, P5-T4–P5-T5, P11-T1 |
| AC-53–AC-58 | P10-T4–P10-T5, P11-T10 |
| AC-59–AC-66 | P0-T1–P0-T4, P11-T1–P11-T11, independent feature review and exact-head CI continuation |

Deliverables D01–D04 already have promoted documentation, research, specification, and this plan; final evidence must still verify their consistency. D05–D16 are implemented by Phases 1–10, D17–D19 by P10-T4/P10-T5, D20 by the independent feature review, D21 by P11-T10 plus delivery reconciliation, and D22 by P10-T5/P11-T10. All 15 functional areas and 16 resolved research questions remain covered by requirements-traceability.md.

## Orchestrator continuation after executor handoff

The execution handoff is not feature completion. The owning orchestrator persists each transition and performs the existing large-feature lifecycle without adding another scheduler:

1. Collect staged commit context, delegate the conventional commit message, and commit the complete reviewed implementation/evidence through repository conventions.
2. Resolve the actual PR base by merge-base ancestry, refresh canonical PR context, and delegate full feature review of the entire branch. Preserve all policy/code/feature audit artifacts in the active feature folder and use the prescribed single-pass remediation/preflight limits for any blocking finding.
3. Delegate PR authoring, create/update the PR through the existing authorized lifecycle, and verify every CI check at the exact final PR head, including all required contexts and non-required executed checks. A docs-only green context is not substitute evidence for the implementation's full run.
4. Reconcile review/CI-dependent ACs through their designated owner, commit/push any final evidence/checkoff changes, and re-verify the new exact head. Refresh context and run the orchestration completion validator with complete topology/model routing evidence.
5. Finalize FEATURE/completion-report.md and FEATURE/handoff.md with audit/CI/evidence results, supported ecosystems and host limitations, actual commands/artifacts, compatibility impact, exact publication/push-down instructions, exact source/target local artifact lists, and unresolved follow-on work. Do not modify consumer repositories or publish external packages during this feature.

No blocking AC, required gate, missing evidence, incomplete installed proof, or unresolved feature-review defect may be reported as complete.

# P6-T1 finite core composition preparation

Timestamp: 2026-10-20T14-30

Status: PREPARATION_READY_PENDING_IMPLEMENTATION_RELEASE

Thirty wire operations are mapped in the paired JSON. This is read-only preparation; no implementation, runtime test, collection, native publication or second baseline was performed.

The shared baseline (14:17) and declaration freeze (14:25) are referenced by exact digest. Shared helper, selector and installed-build ownership remains unchanged.

The coordinator approved file-only initialization artifact rows with separate directory/uncertain effects, honest graph-wide findings after individual expected-kind checks, and explicitly truncated first-page source reads. Trusted attribution retains the approved ID-string carrier with principal-based kind/id conversion.

| Operation | Required operation inputs | Existing runtime composition |
| --- | --- | --- |
| init | system_id, system_name, system_role, repository_id | InitializationRequest; plan_initialization; commit_initialization |
| configure | configuration_action | ActivationStore.configure(ConfigurationRequest) |
| profile | None; see conditional/default selection | ActivationStore.select; bounded exact-version profile parser |
| inventory | None; see conditional/default selection | pin_inventory_sources; capture_snapshot; run_inventory; plan_inventory; commit_mutation |
| new-contract | feature_id, name | ContractDraft; contract_changes / plan_contract |
| new-scenario | scenario_id, feature_ids, input_path | ScenarioDraft; scenario_changes / plan_scenario |
| update-artifact | artifact_kind, artifact_path, input_path, expected_sha256, update_action | validate_document; MutationChange; plan_mutation; commit_mutation |
| link-evidence | artifact_kind, artifact_id, evidence_path, expected_sha256 | EvidenceLink; evidence_changes / plan_evidence_link |
| validate-profile | None; see conditional/default selection | validate_document exact kind/version; parse_domain_profile_text / ProfileV2 |
| validate-feature-contract | artifact_path | validate_document(expected_kind=feature-contract); validate_snapshot(mode=structural) |
| validate-coverage-ledger | artifact_path | validate_document(expected_kind=coverage-ledger); validate_snapshot(mode=structural) |
| validate-runtime-scenario | artifact_path | validate_document(expected_kind=runtime-characterization-scenario); validate_snapshot(mode=structural) |
| validate-parity-matrix | artifact_path | validate_document(expected_kind=parity-matrix); validate_snapshot(mode=structural) |
| validate-unspecified-behavior | artifact_path | validate_document(expected_kind=unspecified-behavior); validate_snapshot(mode=structural) |
| validate-product-decision | artifact_path | validate_document(expected_kind=product-decision); validate_snapshot(mode=structural) |
| validate-evidence-reference | artifact_path | validate_document(expected_kind=evidence-reference); validate_snapshot(mode=structural) |
| validate-decisions | None; see conditional/default selection | validate_snapshot; accepted decision/unresolved collection assessments |
| validate-all | None; see conditional/default selection | validate_snapshot; report_projection(kind=validation-report); DiscoveryReport; plan_mutation |
| coverage-report | None; see conditional/default selection | build_coverage_report |
| parity-report | None; see conditional/default selection | build_parity_report |
| completion-report | None; see conditional/default selection | build_completion_report / plan_completion_report |
| generate-acceptance | acceptance_kind | resolve_feature_ids; generate_acceptance; select_acceptance_platforms; render_acceptance; plan_mutation |
| snapshot-export | selected_ids | ReferenceIndex; SnapshotExport; prepare_snapshot_export / plan_snapshot_export |
| snapshot-import | manifest_path | bind_transport; SnapshotImport; prepare_snapshot_import / plan_snapshot_import |
| import-inventory | manifest_path | validate_extension_results; merge_extension_inventory; MutationChange; plan_mutation |
| migrate | from_version, to_version, destination, system_id, system_name, system_role, repository_id | MigrationRequest(InitializationRequest, MigrationSource, bindings=()); plan_migration; commit_migration |
| doctor | None; see conditional/default selection | verified installed RuntimeIdentity; resource/catalog verification; ActivationStore.select |
| read-source | read_operation, paths | SourceReader(... authenticated ReadSelection ...).inspect(SourceReadRequest) |
| prepare-agent | skill_id, selected_ids, paths, expected_outputs, execution_context, complexity | No native host adapter until P8 |
| finalize-agent | None; see conditional/default selection | No native host adapter until P8 |

The paired JSON supplies closed optional fields, mode/flag proposals, conditional requirements, output semantics and exact publication rules. These parser choices are explicit for coordinator/shared-owner recording; they are not a claim of existing service behavior.

Requested cohesive paths before creation: R/service_reports.py, R/service_mutations.py and PT/test_service_publication.py. The first separates report/acceptance projection, the second controlled mutation composition. The existing service/operations/gateway/doctor ownership remains with this worker unless the coordinator transfers it. Size figures in JSON are planning forecasts; Black must confirm the 500-line cap.

Future tests use all 30 fixed routes plus the listed authority, exit, bounded-work, publication and result controls with accepted memory fixtures. No collected node count is invented. Native composition reuses accepted Windows/Git capture and guarded publication after final source/package identity freeze and ordered statics; it makes no host-hook claim.

Implementation awaits coordinator release and any approved split. Dependent behavioral tests additionally require actual shared source hash windows and final installed build identity. The preparation does not accept P6-T1.

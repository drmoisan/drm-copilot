# P12-T6 — Host-principal gateway composition: Python loop

Timestamp: 2026-10-26T09-42
Command: sh SCRATCH/issue-980-p12t6-loop.sh (poetry run black --check, poetry run ruff check, poetry run pyright over the P12-T6 file set; poetry run pytest -p no:randomly --cov=drm_copilot_discovery.gateway --cov=drm_copilot_discovery.gateway_host --cov=drm_copilot_discovery.gateway_host_baseline --cov=drm_copilot_discovery.gateway_host_store --cov=drm_copilot_discovery.gateway_local --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p12t6-coverage.json over test_gateway_host.py, test_gateway_host_main.py, test_gateway_host_baseline.py, test_gateway_host_refusals.py, test_gateway.py, test_gateway_local.py, test_gateway_factory.py, test_gateway_binding.py)
EXIT_CODE: 0
Output Summary: Resumed from the two WIP checkpoints. Corrections before the clean pass: `installed_location` and `installed_activation` were imported by gateway_host.py but absent from gateway_local.py (two unused helpers `canonical_state_location` and `installed_platform` stood in their place), so they were implemented and the unused helpers removed; test_gateway_host_refusals.py imported its helpers from the pre-split module and now imports gateway_host_test_support.py; an inactive workspace let `ConfigurationError` escape `_binding`, now converted to the exit-3 SERVICE_AUTHORITY refusal (the one failure of the first run, 155 passed / 1 failed); that fix took gateway_host.py over 500 lines, so `HostStoreIO` and `InstalledHostStore` moved to the new gateway_host_store.py; one TC001 import and four Pyright unknown-type errors in the test modules were fixed. Final pass: black "14 files would be left unchanged"; Ruff "All checks passed!"; Pyright "0 errors, 0 warnings, 0 informations"; Pytest 159 passed. Coverage (JSON report): gateway.py line 95.6% branch 94.4%; gateway_host.py line 97.8% branch 92.9%; gateway_host_baseline.py line 96.3% branch 90.0%; gateway_host_store.py line 96.0% branch 83.3%; gateway_local.py line 92.5% branch 90.0%. Package contracts (test_package_contract.py, test_build_discovery_runtime.py): 187 passed.

## Changed files (physical lines)

- new `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host.py` (465): `HostPrincipal`, `partition_name`, `session_directory`, `invocation_directory`, `HostServiceIO` (`authorize`, `writer`, `capability_observation` returning None) and `installed_host_io`.
- new `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_baseline.py` (207): `required_rows` and `reconstruct_baseline` (stored output content replayed or removed, every other input checked against the stored manifest, drift is `SERVICE_BASELINE` exit 3).
- new `packages/discovery-runtime/src/drm_copilot_discovery/gateway_host_store.py` (65): read-only `HostStoreIO` seam and the bounded `InstalledHostStore`; no write method exists.
- `packages/discovery-runtime/src/drm_copilot_discovery/gateway.py` (401): `_parse_options` admits `--session-id`, `--host-name` and `--agent-role` only with `--principal host`, which then requires all three plus `--author-id`; the argument ceiling moves from 8 to 14; `_compose_io` selects `installed_host_io` for host and `installed_local_io` otherwise.
- `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py` (487): `recapture_workspace`, `installed_location` and `installed_activation` extracted for reuse; `installed_local_io` keeps refusing `host`.
- `packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py`: `CONTROLLED_OPERATIONS`, equal to tests/fixtures/discovery_host/controlled-operations.json (`test_controlled_operations_equal_the_pinned_fixture`).
- new tests: `tests/discovery_runtime/gateway_host_test_support.py` (310), `test_gateway_host.py` (235), `test_gateway_host_main.py` (265), `test_gateway_host_baseline.py` (183), `test_gateway_host_refusals.py` (376).

## Set N dispositions

- `test_gateway.py::test_fixed_outer_options_reject_arbitrary_dispatch`: three rows added (host without identity, host with partial identity, local-user with a session id); every existing row retained.
- `test_gateway_local.py::test_host_principal_is_never_converted_to_local_user`, `test_request_markers_cannot_expand_local_authority`, `test_gateway_factory.py::test_factory_rejects_invalid_outer_authority`, `test_composed_ports_reject_host_references`: unchanged and passing.

## Acceptance

- A host request with complete trusted identity and verified records receives a host authority bound to its invocation (`test_host_authority_binds_invocation_grants_and_pinned_baseline`, `test_finalize_authority_carries_every_required_output_grant`, `test_read_source_authority_is_bounded_by_the_selected_paths`, `test_main_composes_the_host_ports_from_the_complete_identity`).
- Every incomplete, mismatched, stale, replayed or unverifiable case exits 3 before dispatch (`test_every_protected_record_binding_refuses_before_dispatch` with 11 rows, drift, read-scope, missing-record, inactive-workspace, malformed-record and foreign-workspace tests; `test_main_refuses_incomplete_or_misplaced_host_identity`).
- No code path constructs a local-user authority for the host principal (`HostServiceIO.authorize` returns principal `host` only; `installed_local_io` refuses `host`; `test_host_io_never_writes_the_protected_store` records zero store writes).

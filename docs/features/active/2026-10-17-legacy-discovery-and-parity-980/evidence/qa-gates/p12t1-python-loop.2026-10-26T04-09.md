# P12-T1 — Root prepare-agent baseline route: Python loop

Timestamp: 2026-10-26T04-09
Command: poetry run black packages/discovery-runtime/src/drm_copilot_discovery/service_preparation.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py packages/discovery-runtime/src/drm_copilot_discovery/service.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py tests/discovery_runtime/test_service_preparation.py tests/discovery_runtime/test_service_boundaries.py tests/discovery_runtime/test_gateway_local.py
EXIT_CODE: 0
Output Summary: First pass reformatted the two new files (service_preparation.py, test_service_preparation.py); the loop restarted and `black --check` on both reports "2 files would be left unchanged". Ruff: "All checks passed!" (exit 0). Pyright: "0 errors, 0 warnings, 0 informations" (exit 0). Pytest over test_service_preparation.py, test_service_boundaries.py, test_gateway_local.py, test_service.py, test_cli_errors.py, test_service_request_rules.py: 242 passed (exit 0). Coverage of `--cov=drm_copilot_discovery.service_preparation --cov-branch`: 60 statements, 3 missed, 20 branches, 1 partial, 95% (missing: the generic ValueError arm of the grant check and the defensive missing-baseline raise, both unreachable through `execute` because the request schema rejects malformed kinds and `_context` captures before the route).

## Changed files (physical lines)

- new `packages/discovery-runtime/src/drm_copilot_discovery/service_preparation.py` (171): `prepare_agent`, `_planned_row`, `_row_problem`; refusal classes `PREPARE_OUTPUT_LOCATION`, `PREPARE_OUTPUT_DIGEST`, `PREPARE_OUTPUT_TEXT`, `SERVICE_MODE`.
- changed `service_inspection.py` (293): `inspect_request` routes `prepare-agent` to `prepare_agent`.
- changed `service.py` (336): `_local` admits `prepare-agent` under local-user and keeps refusing `finalize-agent`.
- changed `gateway_local.py` (443): `LocalServiceIO.authorize` admits `prepare-agent` and keeps refusing `finalize-agent`, agent-output mode and every host marker.
- new `tests/discovery_runtime/test_service_preparation.py` (218): 11 tests (valid rows with present and absent outputs, three digest-mismatch rows, duplicate path, binary content, path outside the kind's location, every defect in one round trip, non-structural mode, finalize-agent refusal, host marker on prepare).
- changed `tests/discovery_runtime/test_service_boundaries.py` (488): Set N disposition applied, `test_native_operations_remain_unavailable_without_a_verified_provider` keeps the finalize-agent row and drops the prepare-agent row.
- changed `tests/discovery_runtime/test_gateway_local.py` (467): the `prepare` marker row of `test_request_markers_cannot_expand_local_authority` is removed because `LocalServiceIO.authorize` must admit the root `prepare-agent` request for the installed `installed_local_io` composition that the TypeScript prepare route (P12-T2) calls. Set N lists this test as unchanged; the P12-T1 task text's instruction to search PT for every remaining `prepare-agent` refusal assertion under local-user owns this row. The host-principal, invocation, authorization, mode, workspace and finalize rows are unchanged.

## Acceptance

- Valid request: exit 0, complete input manifest, exact prior content and digest of the existing expected output, no row for the absent output, counts `expected_outputs`/`existing_outputs`, `receipt_ref` and `invocation_ref` null, zero writer calls, memory store unchanged.
- Mismatched or malformed row: exit 1 with a blocking `PREPARE_*` finding carrying the row path and no artifact row.
- No grant, receipt or write is produced on any path.

# Discovery wheel rebuild on the remediated tree (P16-T6)

Timestamp: 2026-10-30T01-47
Task: [P16-T6] Rebuild the distributables and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-wheel.sh (the P10-T3 sequence: poetry run python -m scripts.dev_tools.build_discovery_runtime --check; --stage-only; --check; build; --stage-only determinism rerun); sh SCRATCH/issue-980-p12t11-pytests.sh (poetry run pytest tests/discovery_runtime/test_package_contract.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/discovery_runtime/test_resources.py -q --no-cov -p no:randomly); sh SCRATCH/issue-980-p16t6-inspect.sh (SCRATCH/issue-980-p10t3-inspect-wheel.py)
EXIT_CODE: 1 (first --check, expected stale), 0 (stage-only), 0 (check), 0 (build), 0 (determinism rerun), 0 (236 passed), 0 (wheel inspection, DEFECTS=0)
Output Summary: The first check reported "Installed build manifest is missing or stale" because Phase 15 changed runtime modules (`catalog.py`, `protected_records.py`, `gateway.py`, `gateway_host.py`, `gateway_host_store.py`, `service_request_rules.py`, the new `gateway_host_reads.py`) and the staged resources (the `tool-authorization` schema enums and the two new schemas). The stage regenerated `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` (`build_manifest_changed: true`, `changed_paths: []`; the only tracked file that changed, committed with this task). The repeated check, build and rerun all reported `build_manifest_changed: false` with the same identity, so the staged bytes are deterministic. The three package-contract suites pass (236 passed in 0.41s); `test_resources.py` verifies the staged resource manifest, which now carries the `root-grant` and `host-observation` schemas.

## Artifact

- `dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl`, 625,987 bytes, 189 archived files (189 recorded, 0 foreign, 0 unrecorded; 140 source modules equal 140 wheel modules), SHA-256 `8993309f9ee392536a6619cf8b5c694e498a712aa72b7873044746ada16deb85` (also reported as `wheel_sha256` by the builder). `dist/` is gitignored; the artifact is not committed.
- Runtime identity: `build_sha256` `3396ea3ba30a68d644ca8d2e020a21f3d3daaf09eddd162d875445291be716fc` (equal to the SHA-256 of the regenerated `_build_manifest.json`, 184 files, 0 mismatched), `policy_version` 2, `policy_sha256` `cfdab7095fe66234358a8da535553b9ac9c73ea7b1639837150722b529fc38a3`, `resource_manifest_sha256` `887c4b620f77093747eeaac24d6e987dc2814bba1bb3ab7f62c3d9fe480d24ab` over 42 entries (7 version 1 schemas, 29 version 2 schemas, 6 templates; P14-T12 recorded 40 entries, before `root-grant.schema.json` and `host-observation.schema.json`).
- Supersedes the P14-T12 wheel (`566679a0…`, build `dc7bff83…`, policy `d73c68cd…`, resource manifest `64574adb…`).

Result: PASS

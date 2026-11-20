# Discovery wheel rebuild (P12-T11)

Timestamp: 2026-10-28T13-21
Command: sh SCRATCH/issue-980-p12t11-wheel.sh (poetry run python -m scripts.dev_tools.build_discovery_runtime --check; --stage-only; --check; build; --stage-only determinism rerun); poetry run python -I SCRATCH/issue-980-p12t11-inspect.py SCRATCH/stage; sh SCRATCH/issue-980-p12t11-install.sh (python -I -m venv --clear SCRATCH/install/venv; pip install --no-cache-dir the wheel); sh SCRATCH/issue-980-p12t11-doctor.sh (dev.discovery.doctor --workspace-root SCRATCH/install/workspace); poetry run pytest tests/discovery_runtime/test_package_contract.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/discovery_runtime/test_resources.py -q --no-cov -p no:randomly
EXIT_CODE: 0 (every build step of the repeated sequence), 0 (inspection, DEFECTS=0), 0 (venv, pip, import), 0 (doctor), 0 (236 passed)
Output Summary: The first sequence after the Phase 12 Python changes regenerated `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` (the only staged file that changed; it is committed with this task) and built the wheel; the sequence was repeated and every step reported `changed_paths: []` and `build_manifest_changed: false`, so the staged bytes are deterministic. The isolated install succeeded with only the four declared dependencies, the installed module resolves from the venv site-packages, and the installed doctor verifies the rebuilt identity. The three package-contract suites pass (236 passed in 0.40s).

## Artifact

- `dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl`, 618,577 bytes, SHA-256 `59652fe9ab2c3dc475be9c8c7e35b099fe2d3a0d2db0fae308a007f777c7136f` (also reported as `wheel_sha256` by the builder). `dist/` is gitignored; the artifact is not committed.
- METADATA Version `2.0.0`; 186 archived files (was 177 at P10-T3: the Phase 12 modules `service_preparation`, `protected_records`, `gateway_host`, `gateway_host_baseline`, `gateway_host_store`, `operation_grants`, `service_finalization` and the new schema resource).
- Resources: `_resources/manifest.json` SHA-256 `64574adbd4e672f659f73fae790d20fd95ed473606331e7e119464cd12ec5dc6` with 40 entries (was 39); the new entry is `schemas/discovery/v2/start-attestation.schema.json` (P12-T5).
- `_build_manifest.json` SHA-256 `a4a41346b85867ec445687575c1e94ba7d5478631e81965d272d51051b222b95`.
- Installed runtime identity (installed doctor): `package_version` 2.0.0, `schema_version` 2.0.0, `build_sha256` `a4a41346b85867ec445687575c1e94ba7d5478631e81965d272d51051b222b95`, `policy_version` 2, `policy_sha256` `7428cac9564b87547857631946c45493e9d6b70ddeadbdd7b1dcdf537304f276`. The policy version advanced from 1 because the Phase 12 request rules (the controlled operation set, the root `prepare-agent` route and the host `finalize-agent` route) are part of the policy identity.

## Notes

- The installed-host smoke with this wheel is P12-T12; this record covers buildability, content closure, determinism and the installed identity.
- The SCRATCH venv at `SCRATCH/install/venv` is the operational installation reused by P12-T12.

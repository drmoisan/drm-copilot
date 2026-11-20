# Discovery wheel rebuild with the corrected catalog (P14-T12)

Timestamp: 2026-10-29T12-26
Task: [P14-T12] Rebuild the distributables with the corrected runtime and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-wheel.sh (the P10-T3 sequence: poetry run python -m scripts.dev_tools.build_discovery_runtime --check; --stage-only; --check; build; --stage-only determinism rerun); sh SCRATCH/issue-980-p12t11-pytests.sh (poetry run pytest tests/discovery_runtime/test_package_contract.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/discovery_runtime/test_resources.py -q --no-cov -p no:randomly)
EXIT_CODE: 1 (first --check, expected stale), 0 (stage-only), 0 (check), 0 (build), 0 (determinism rerun), 0 (236 passed)
Output Summary: The first check reported "Installed build manifest is missing or stale" because `catalog.py` changed in P14-T4. The stage regenerated `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` (`build_manifest_changed: true`, `changed_paths: []`; the only tracked file that changed, committed with this task). The repeated check, build and rerun all reported `build_manifest_changed: false` with the same identity, so the staged bytes are deterministic. The three package-contract suites pass (236 passed in 0.41s).

## Artifact

- `dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl`, 619,238 bytes, 186 archived files, SHA-256 `566679a0a929837d0c9145e0d6a2ca86da1e4b68fdcc3c3412427c274406131a` (also reported as `wheel_sha256` by the builder). `dist/` is gitignored; the artifact is not committed.
- Runtime identity: `build_sha256` `dc7bff83fb56a7867826bae2adcd54e295beacd5b87cbfe31eaac051c764522d` (equal to the SHA-256 of the regenerated `_build_manifest.json`), `policy_version` 2, `policy_sha256` `d73c68cd04e18dee0d4d26a29d0cea8a34b8ed21bbd054baecf37952987d72b9`, `resource_manifest_sha256` `64574adbd4e672f659f73fae790d20fd95ed473606331e7e119464cd12ec5dc6` (unchanged from P12-T12: no resource changed).
- The build identity and policy digest change because the runtime module set they hash includes `drm_copilot_discovery.catalog`; the policy version stays 2 and the archived file count stays 186.
- Supersedes the P12-T12 wheel (`dca943be…`, build `2b7d5215…`, policy `aa2349b3…`).

Result: PASS

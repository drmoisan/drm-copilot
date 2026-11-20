# P14-T12 Installed runtime verification of the corrected wheel

Timestamp: 2026-10-29T12-26
Task: [P14-T12] Rebuild the distributables with the corrected runtime and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-install.sh (python -I -m venv --clear SCRATCH/install/venv; pip install --no-cache-dir the wheel; import and `dev.discovery.doctor --help`); sh SCRATCH/issue-980-p12t11-doctor.sh (`dev.discovery.doctor --workspace-root SCRATCH/install/workspace`); sh SCRATCH/issue-980-p14t12-sweep.sh (the installed interpreter with -I from SCRATCH/install/work runs SCRATCH/issue-980-p14t12-sweep.py)
EXIT_CODE: 0 (venv), 0 (pip), 0 (import), 0 (doctor --help), 0 (doctor), 0 (sweep)
Output Summary: The rebuilt wheel `566679a0…` installs into the issue-scoped `SCRATCH/install/venv` with only its declared dependencies. The module resolves from the venv site-packages, and the installed doctor reports `Installed runtime verified` with runtime build `dc7bff83…`, policy `d73c68cd…`, policy version 2 and schema version 2.0.0. All 31 console entries answer `--help` with exit 0. The package ships 41 resource files (the 40-entry manifest plus `manifest.json`), 34 of them schemas. The installed catalog loads all 34 schema documents and returns one shared registry across calls (`REGISTRY_SHARED=True`), served from the installed `catalog.py`. The installed runtime has no checkout dependency.

## Isolation of the installed interpreter

- `sys.path` of the isolated interpreter contains only the base Python installation (`python313.zip`, `DLLs`, `Lib`, the installation root) and the SCRATCH venv (`venv`, `venv/Lib/site-packages`). The sweep's `CHECKOUT_ON_PATH=True` line is a false positive of its substring heuristic: the SCRATCH folder name contains the worktree-family name. The printed path list holds no checkout entry, as P11-T7 also recorded.
- Every process ran with `-I` from `SCRATCH/install/work` or through the venv's console executables, never from the checkout.

## Installed doctor (workspace `SCRATCH/install/workspace`)

`ok: true`, `exit_code` 0, summary "Installed runtime verified; configuration activation-required; native capability unavailable." with the warning `DISCOVERY_ENFORCEMENT_UNAVAILABLE` for the local-user principal, as the contract states. Runtime: `build_sha256` `dc7bff83fb56a7867826bae2adcd54e295beacd5b87cbfe31eaac051c764522d`, `package_version` 2.0.0, `policy_sha256` `d73c68cd04e18dee0d4d26a29d0cea8a34b8ed21bbd054baecf37952987d72b9`, `policy_version` 2, `schema_version` 2.0.0.

## Contract suites

`tests/discovery_runtime/test_package_contract.py`, `tests/scripts/dev_tools/test_build_discovery_runtime.py`, `tests/discovery_runtime/test_resources.py`: 236 passed. `extensions/drm-copilot/test/packaging/discovery-resources.test.ts`, `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts`: 2 suites, 14 tests passed.

## Native host controls not repeated

The native host controls of P12-T12 (`discovery-native-capabilities.2026-10-28T15-06.md`: receipt chain, stale-receipt and replay controls, refusals on Claude Code, Codex and the Copilot Local harness) are not repeated. Phase 14 changes no TypeScript, PowerShell, hook or adapter file: its file changes are `catalog.py` and its generated `_build_manifest.json`, two Python test modules, the brief and its contract test, and the file-size baseline JSON. The host-side code those controls exercise is therefore byte-identical to the P12-T12 build. The catalog change alters only how often the Python runtime builds the schema registry, and the shared-registry behavior is verified above on the installed wheel and by the P14-T2 and P14-T3 tests.

Result: PASS

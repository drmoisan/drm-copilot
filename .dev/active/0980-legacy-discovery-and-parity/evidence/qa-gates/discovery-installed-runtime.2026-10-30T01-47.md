# P16-T6 Installed runtime verification of the remediated wheel

Timestamp: 2026-10-30T01-47
Task: [P16-T6] Rebuild the distributables and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-install.sh (python -I -m venv --clear SCRATCH/install/venv; pip install --no-cache-dir the wheel; import and `dev.discovery.doctor --help`); sh SCRATCH/issue-980-p12t11-doctor.sh (`dev.discovery.doctor --workspace-root SCRATCH/install/workspace`); sh SCRATCH/issue-980-p16t6-sweep.sh (the installed interpreter with -I from SCRATCH/install/work runs SCRATCH/issue-980-p16t6-sweep.py)
EXIT_CODE: 0 (venv), 0 (pip), 0 (import), 0 (doctor --help), 0 (doctor), 0 (sweep)
Output Summary: The rebuilt wheel `8993309f…` installs into the issue-scoped `SCRATCH/install/venv` with only its declared dependencies. The module resolves from the venv site-packages (`drm_copilot_discovery` 2.0.0), and the installed doctor reports `Installed runtime verified` with runtime build `3396ea3b…`, policy `cfdab709…`, policy version 2 and schema version 2.0.0. All 31 console entries answer `--help` with exit 0 (`ENTRIES=31 FAILURES=0`). The package ships 43 resource files (the 42-entry manifest plus `manifest.json`), 36 of them schemas (P14-T12: 41 and 34; the two additions are `root-grant` and `host-observation`). The installed catalog loads all 36 schema documents and returns one shared registry across calls (`REGISTRY_SHARED=True`), served from the installed `catalog.py`. The installed runtime has no checkout dependency.

## Isolation of the installed interpreter

- `sys.path` of the isolated interpreter contains only the base Python installation (`python313.zip`, `DLLs`, `Lib`, the installation root) and the SCRATCH venv (`venv`, `venv/Lib/site-packages`). The sweep's `CHECKOUT_ON_PATH=True` line is a false positive of its substring heuristic: the SCRATCH folder name contains the worktree-family name. The printed path list holds no checkout entry, as P11-T7 and P14-T12 also recorded.
- Every process ran with `-I` from `SCRATCH/install/work` or through the venv's console executables, never from the checkout.

## Installed doctor (workspace `SCRATCH/install/workspace`)

`ok: true`, `exit_code` 0, summary "Installed runtime verified; configuration activation-required; native capability unavailable." with the warning `DISCOVERY_ENFORCEMENT_UNAVAILABLE` for the local-user principal, as the contract states. Runtime: `build_sha256` `3396ea3ba30a68d644ca8d2e020a21f3d3daaf09eddd162d875445291be716fc`, `package_version` 2.0.0, `policy_sha256` `cfdab7095fe66234358a8da535553b9ac9c73ea7b1639837150722b529fc38a3`, `policy_version` 2, `schema_version` 2.0.0.

## Contract suites

`tests/discovery_runtime/test_package_contract.py`, `tests/scripts/dev_tools/test_build_discovery_runtime.py`, `tests/discovery_runtime/test_resources.py`: 236 passed. `extensions/drm-copilot/test/packaging/discovery-resources.test.ts`, `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts`: 2 suites, 14 tests passed.

## Host observations

The native host controls are not re-driven in this record. The per-host observation table of this cycle is P16-T7 (`discovery-host-observations.*.md`); the hook behavior itself is proven by the Pester suites named there against the rebuilt resources' sources, which are byte-identical to their mirrors (P15-T22).

Result: PASS

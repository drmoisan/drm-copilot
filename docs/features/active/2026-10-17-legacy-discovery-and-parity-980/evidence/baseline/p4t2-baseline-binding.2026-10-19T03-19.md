# P4-T2 baseline and scope

Timestamp: 2026-10-19T03-19
Command: Verify absent new paths and bind the accepted P4-T1 source bytes and final proofs
EXIT_CODE: 0
Output Summary: All four scoped code/test paths are new. The accepted predecessor source hashes remain exact; its clean toolchain, 243 analyzer tests, 310 contracts and 13 native checks are reused without execution. New-module baseline executable coverage is not applicable.

- `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/xml_input.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py`
- `tests/discovery_runtime/analyzer/test_xml_input.py`
- `tests/discovery_runtime/analyzer/test_dotnet_projects.py`

Synthetic text fixture root: `tests/fixtures/discovery_analyzers/dotnet/`. Adapter registration remains P4-T9. No prior source, registry or policy file is in the edit scope.

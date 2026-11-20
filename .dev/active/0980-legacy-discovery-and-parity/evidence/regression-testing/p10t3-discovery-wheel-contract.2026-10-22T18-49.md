# P10-T3 Discovery wheel contract

Timestamp: 2026-10-22T18-49
Task: [P10-T3] Build the versioned Python wheel with complete isolated resources.
Result: PASS

## Behavior verified

- The dedicated package `packages/discovery-runtime` builds `drm_copilot_discovery-2.0.0-py3-none-any.whl` through `scripts/dev_tools/build_discovery_runtime.py` with the approved poetry-core backend and no network; the builder refuses to build while a staged resource or the build manifest is stale (`--check` exit 1 before staging), refreshes only generated files (`--stage-only`), and reports the resource-manifest digest, declared and imported runtime dependencies, checked modules, build digest and wheel SHA-256.
- The wheel carries every runtime resource: 131 modules equal to the source tree, 39 staged schemas and templates byte-identical to the canonical repository files (frozen v1, exact v2), the verified resource manifest, the build manifest whose 172 entries match the archived bytes, `py.typed`, and 31 console entries; it requires only PyYAML, jsonschema, referencing and lxml with Python 3.10 or later. Details and digests: `evidence/other/discovery-wheel-build.2026-10-22T18-49.md`.
- Staging is deterministic: repeated runs report no changed paths and identical digests.

## Proof

- `tests/scripts/dev_tools/test_build_discovery_runtime.py`: existing in-memory staging, closure, allowlist, schema-reference, import-closure and check-mode tests plus the new `test_project_metadata_matches_runtime_contract` pinning `pyproject.toml` to the runtime (backend, name, version, scripts equal to the `cli.main_*` set, exact approved dependencies, Python floor, includes).
- `tests/scripts/dev_tools/test_discovery_build_identity.py`, `tests/discovery_runtime/test_build_identity.py`, `tests/discovery_runtime/test_resources.py`: build-manifest projection and verification, resource manifest integrity and installed lookup; 186 tests pass with the regenerated `_build_manifest.json`.
- SCRATCH inspector over the built wheel: METADATA, entry points, RECORD closure and digests, module and resource closure, build-manifest agreement; DEFECTS=0.

## Gates

- Black, Ruff and Pyright clean on the changed test; pytest 186 passed; builder `--check` passes after staging; wheel built and inspected with zero defects.

## Carried notes

- The wheel at `dist/discovery` is a build output (gitignored) and is recorded by digest only; P11-T7 performs the independent installation proof in an isolated interpreter.
- The README retains the sentence about the legacy initializer's checkout template resolver because `scripts/dev_tools/discovery/init_models.py` still carries that adapter.

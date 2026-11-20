# P13-T6 Packaging closure, staged resource hashes and package metadata

Timestamp: 2026-10-29T02-34
Task: [P13-T6] Repeat repository and publication contracts on the final tree.
Command: `poetry run python -m scripts.dev_tools.build_discovery_runtime --check`; `sh SCRATCH/issue-980-p12t11-packages.sh` (the P12-T11 rebuild of the VSIX and the npm package into SCRATCH/stage, following the P10-T2 sequence); `poetry run python -I SCRATCH/issue-980-p10t2-inspect.py`; `poetry run python -I SCRATCH/issue-980-p10t3-inspect-wheel.py`
EXIT_CODE: 0 (staged hashes: `"changed_paths": []`), 0 (rebuild: `VSCE_EXIT=0`, `PACK_EXIT=0`), 0 (packages: `DEFECTS=0`), 0 (wheel: `DEFECTS=0`)
Output Summary: The staged resource allowlist and the wheel identity reproduce from the canonical sources, with no changed path, so the P12-T12 wheel is current.

The VSIX and npm package were rebuilt from the final tree because P13-T3 changed one comment line in the bundled `DiscoveryAuthorization.psm1`:
- VSIX `drm-copilot.vsix`: 796 entries, 58 of 58 required native entries, no Python source, no root `scripts` tree, size 3095605, SHA-256 `550c65f28f2a7a11580c6a392afcd4a9eaece9de3753205cb8291aee55e9d0a5`.
- npm `@danmoisan/drm-copilot-mcp@1.1.22`: 790 entries, 58 of 58 required, no Python source, size 1872294, SHA-256 `768bcea14434eaacab164445ab881883eda781c41dbffe362f6810da5b0bb8aa`.

Wheel `drm_copilot_discovery-2.0.0-py3-none-any.whl`:
- SHA-256 `dca943beac79dab5486cd27adbd96ca3d207d755d73af8e8068aee728e10c096`, `Requires-Python >=3.10,<4.0`, and the four runtime dependencies.
- 31 well-formed console entry points; 186 archive files, all recorded, none foreign, none unrecorded, and no RECORD digest mismatch.
- 139 of 139 source modules present.
- 40 staged resources (7 v1 schemas, 27 v2 schemas including `start-attestation`, 6 templates), byte-identical to the canonical files.
- Build manifest: 181 files, no mismatch, build_sha256 `2b7d5215b1dd41cdea87424fedb7c7b0f1b25697989675d1ee87bcf832db3b4d`.

The packaging Jest suites pass in `p13-architecture-boundaries.2026-10-29T02-34.md`. The rebuilt host packages differ from the P12-T12 installed packages only by that comment line; P13-T9 records the new digests in the handoff.
Result: PASS

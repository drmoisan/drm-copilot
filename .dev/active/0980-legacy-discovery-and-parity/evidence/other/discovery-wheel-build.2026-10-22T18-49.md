# Discovery wheel build (P10-T3)

Timestamp: 2026-10-22T18-49
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --check (stale); poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only; poetry run python -m scripts.dev_tools.build_discovery_runtime --check; poetry run python -m scripts.dev_tools.build_discovery_runtime; poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only (determinism rerun); poetry run python -I SCRATCH/issue-980-p10t3-inspect-wheel.py
EXIT_CODE: 1 (first check: "Installed build manifest is missing or stale"), 0 (stage), 0 (check), 0 (build), 0 (rerun), 0 (inspection, DEFECTS=0)
Output Summary: The wheel is built from the dedicated package with the approved poetry-core backend (`pip wheel --no-index --no-deps --no-build-isolation`; pip 26.0.1, poetry-core 2.5.0, Python 3.13.12 in the Poetry environment).

## Artifact

- `dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl`, 594,045 bytes, SHA-256 `0389c099b612c905340cad1adfd33d67142b7396a21d829de69344725f07661e` (also reported as `wheel_sha256` by the builder). `dist/` is gitignored; the artifact is not committed.
- METADATA: Name `drm-copilot-discovery`, Version `2.0.0` (equals `drm_copilot_discovery.__version__` and the pyproject version), Metadata-Version 2.4, Requires-Python `>=3.10,<4.0`.
- Requires-Dist: `PyYAML (>=6.0)`, `jsonschema (>=4.25.1,<5.0.0)`, `lxml (>=5.3.0)`, `referencing (>=0.37,<0.38)`; no other dependency, so no root machine-learning or developer-tool package (no torch, numpy, pandas, scikit, pytest, ruff, black, pyright, hypothesis or typer hint) is required.

## Contents

- 177 archived files, all 177 recorded in RECORD with matching digests; no file outside `drm_copilot_discovery/` and the dist-info; `py.typed`, `_build_manifest.json` and `_resources/manifest.json` present.
- Import closure: 131 `.py` modules in the wheel equal the 131 modules under `packages/discovery-runtime/src/drm_copilot_discovery`; the builder's static closure check reports every runtime import as either local, standard library or one of the four declared dependencies.
- Console entries: 31 `dev.discovery.*` scripts, each `drm_copilot_discovery.cli:main_*`, equal to the set of `cli.main_*` functions (pinned by the new `test_project_metadata_matches_runtime_contract`).
- Resources: all 39 allowlisted files (7 frozen v1 schemas, 26 v2 schemas, 6 v2 templates) are staged under `_resources/` with SHA-256 equal to the canonical repository bytes; `_resources/manifest.json` SHA-256 `15d20eebf1eed42192ac437c5cc7ee06e0036247d84a47c43961b0fa965cfd13` (39 entries); `_build_manifest.json` SHA-256 `618a5fc325061b87f74b8f348872b9abfbee18bb00ab79d5ef00165c1f6b9cfb` with 172 file entries, every hash matching the archived bytes.
- Determinism: a second `--stage-only` run after the build reports `changed_paths: []`, `build_manifest_changed: false` and the same resource-manifest and build-manifest digests.

## Changes in this task

- `packages/discovery-runtime/src/drm_copilot_discovery/_build_manifest.json` regenerated (the only staged file that was stale after the P8/P9 runtime changes; no `_resources` file changed).
- `packages/discovery-runtime/README.md` finalized with package contents, build, and installation sections; `pyproject.toml` and `resource-manifest.json` needed no change.
- `tests/scripts/dev_tools/test_build_discovery_runtime.py` gains the project-metadata contract test.

## Notes

- Final independent installation proof (a fresh interpreter installing this wheel and running the gateway) is scheduled in P11-T7; this record covers buildability and content closure.
- Operational build work (backend probe, inspector) ran from SCRATCH; the wheel itself lives at the plan-named `dist/discovery` path.

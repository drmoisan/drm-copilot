# Task Check [P3-T7]

Timestamp: 2026-11-20T15-23
Command: sh SCRATCH/issue-1016-tc-p3t7.sh (Black check, Ruff, Pyright on the six changed Python files; launcher pytest -n auto over test_build_discovery_runtime.py, test_build_discovery_runtime_io.py, tests/scripts/dev_tools/discovery, tests/discovery_runtime, test_discovery_build_identity.py; python -m scripts.dev_tools.build_discovery_runtime --check; git diff --name-status BASE -- packages/discovery-runtime and git status --porcelain -- packages/discovery-runtime)
EXIT_CODE: 0
Output Summary: First run: Black would reformat 2 test files and Ruff reported 2 E501 on the same lines; Black was applied and the check re-run from the start. Second run: Black "6 files would be left unchanged.", Ruff "All checks passed!", Pyright "0 errors, 0 warnings, 0 informations"; pytest 6769 passed, 0 failed, 0 errors (every tests/discovery_runtime file, test_package_contract.py, test_domain_neutrality.py and both module suites included; no setup error); the build script's verification mode exits 0 with "changed_paths": [] and lists the six docs/discovery/templates keys read from .dev/discovery/templates; packages/discovery-runtime shows 0 name-status lines against BASE and 0 porcelain lines.

## Changed files

- `scripts/dev_tools/build_discovery_runtime.py`: `MOVED_RESOURCE_SOURCES`, `source_path_for_resource`, `resource_key_for_source`; `DiskBuildFileSystem._path` reads a key from its source directory, and `list_files` reports source files under their canonical key. `RESOURCE_ROOTS`, keys, staged members and `resource-manifest.json` are unchanged. The mapping sits in the disk boundary because the package's `validate_resource_path` rejects a leading `.dev` segment and the package is excluded (A5). 520 lines.
- `scripts/dev_tools/discovery/init_models.py`: `resolve_default_template_root` returns `.dev/discovery/templates`. 33 lines.
- `tests/scripts/dev_tools/test_build_discovery_runtime_io.py`: new case `test_canonical_template_inputs_read_from_moved_source_directory`.
- `tests/scripts/dev_tools/discovery/test_init_models.py`: `test_resolve_default_template_root_returns_expected_path` expects `.dev/discovery/templates`.
- `tests/discovery_runtime/initialization_test_support.py`: `initialization_templates` reads through the new helper `read_template_source`, which maps a `docs/discovery/templates/` key to `.dev/discovery/templates/` (keys unchanged).
- `tests/scripts/dev_tools/discovery/test_domain_neutrality.py`: `_TEMPLATE_ROOT` joined from `.dev`, `discovery`, `templates`.

## Selection and rule

Mirrored tests of the two production modules (`test_build_discovery_runtime*.py`, `tests/scripts/dev_tools/discovery`), every test that imports the changed support module (`tests/discovery_runtime`), the suite that imports `test_build_discovery_runtime` helpers (`test_discovery_build_identity.py`), and the task's named suites.

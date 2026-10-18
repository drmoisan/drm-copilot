# p1t2-wheel-build

Timestamp: 2026-10-18T04-51
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --output SCRATCH/issue-980-p1t2-dist
EXIT_CODE: 0
Output Summary:   "runtime_version": "2.0.0",;   "wheel": "drm_copilot_discovery-2.0.0-py3-none-any.whl",;   "wheel_sha256": "d24139d8de67ad5ae4aa81487e4fc79b66be3741e6f3171790c2f6e309de380e"; }

Working directory: .
Started: 2026-10-18T04:51:19.121816+00:00
Duration seconds: 1.986
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
{
  "changed_paths": [],
  "checked_runtime_modules": [
    "drm_copilot_discovery",
    "drm_copilot_discovery.domain_profile",
    "drm_copilot_discovery.domain_profile_models",
    "drm_copilot_discovery.init_models",
    "drm_copilot_discovery.io",
    "drm_copilot_discovery.rendering",
    "drm_copilot_discovery.resources"
  ],
  "declared_runtime_dependencies": [
    "PyYAML",
    "jsonschema",
    "lxml",
    "referencing"
  ],
  "imported_runtime_dependencies": [
    "PyYAML"
  ],
  "resource_manifest_sha256": "329dcc48c2bc145b4ecb61f62cefa348d81bbae39ca163eed7c0fef5a3316605",
  "resources": [
    "schemas/discovery/v1/coverage-ledger.schema.json",
    "schemas/discovery/v1/evidence-reference.schema.json",
    "schemas/discovery/v1/feature-contract.schema.json",
    "schemas/discovery/v1/parity-matrix.schema.json",
    "schemas/discovery/v1/product-decision-record.schema.json",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json"
  ],
  "runtime_version": "2.0.0",
  "wheel": "drm_copilot_discovery-2.0.0-py3-none-any.whl",
  "wheel_sha256": "d24139d8de67ad5ae4aa81487e4fc79b66be3741e6f3171790c2f6e309de380e"
}
```

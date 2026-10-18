# p1t2-stage

Timestamp: 2026-10-18T04-51
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only
EXIT_CODE: 0
Output Summary:     "schemas/discovery/v1/unspecified-behavior-record.schema.json";   ],;   "runtime_version": "2.0.0"; }

Working directory: .
Started: 2026-10-18T04:51:13.295221+00:00
Duration seconds: 0.906
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
{
  "changed_paths": [
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/coverage-ledger.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/evidence-reference.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/feature-contract.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/parity-matrix.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/product-decision-record.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/unspecified-behavior-record.schema.json"
  ],
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
  "runtime_version": "2.0.0"
}
```

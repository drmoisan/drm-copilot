# p1t3-stage-correction

Timestamp: 2026-10-18T05-05
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only
EXIT_CODE: 0
Output Summary:     "schemas/discovery/v2/scope.schema.json";   ],;   "runtime_version": "2.0.0"; }

Working directory: .
Started: 2026-10-18T05:05:45.263740+00:00
Duration seconds: 0.892
Phase: P1-T3 shared profile/scope schemas; focused task verification.

## Captured output

```text
{
  "changed_paths": [
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/common.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/domain-profile.schema.json"
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
  "resource_manifest_sha256": "85d41cc8162d3d9f567bca002341df72936889ceeea08a9ec0c1e258f478bbb4",
  "resources": [
    "schemas/discovery/v1/coverage-ledger.schema.json",
    "schemas/discovery/v1/evidence-reference.schema.json",
    "schemas/discovery/v1/feature-contract.schema.json",
    "schemas/discovery/v1/parity-matrix.schema.json",
    "schemas/discovery/v1/product-decision-record.schema.json",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json",
    "schemas/discovery/v2/common.schema.json",
    "schemas/discovery/v2/domain-profile.schema.json",
    "schemas/discovery/v2/scope.schema.json"
  ],
  "runtime_version": "2.0.0"
}
```

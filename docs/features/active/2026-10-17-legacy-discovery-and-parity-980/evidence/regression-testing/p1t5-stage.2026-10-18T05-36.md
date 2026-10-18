# p1t5-stage

Timestamp: 2026-10-18T05-36
Command: poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only
EXIT_CODE: 0
Output Summary:     "schemas/discovery/v2/source-snapshot-manifest.schema.json";   ],;   "runtime_version": "2.0.0"; }

Working directory: .
Started: 2026-10-18T05:36:38.432321+00:00
Duration seconds: 0.935
Phase: P1-T5 coverage/inventory/transport schemas; focused task verification.

## Captured output

```text
{
  "changed_paths": [
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/coverage-ledger.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/extension-result-manifest.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/inventory-snapshot.schema.json",
    "packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v2/source-snapshot-manifest.schema.json"
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
  "resource_manifest_sha256": "0ae4aa0f0a5b293f217f1cab881bcae84a232481f21eb420a2a2123f5941e602",
  "resources": [
    "schemas/discovery/v1/coverage-ledger.schema.json",
    "schemas/discovery/v1/evidence-reference.schema.json",
    "schemas/discovery/v1/feature-contract.schema.json",
    "schemas/discovery/v1/parity-matrix.schema.json",
    "schemas/discovery/v1/product-decision-record.schema.json",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json",
    "schemas/discovery/v2/common.schema.json",
    "schemas/discovery/v2/coverage-ledger.schema.json",
    "schemas/discovery/v2/domain-profile.schema.json",
    "schemas/discovery/v2/evidence-reference.schema.json",
    "schemas/discovery/v2/extension-result-manifest.schema.json",
    "schemas/discovery/v2/feature-contract.schema.json",
    "schemas/discovery/v2/inventory-snapshot.schema.json",
    "schemas/discovery/v2/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v2/scope.schema.json",
    "schemas/discovery/v2/source-snapshot-manifest.schema.json"
  ],
  "runtime_version": "2.0.0"
}
```

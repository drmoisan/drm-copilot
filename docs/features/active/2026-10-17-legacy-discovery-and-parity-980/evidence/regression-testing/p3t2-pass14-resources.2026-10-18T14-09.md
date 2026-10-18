# p3t2-pass14-resources

Timestamp: 2026-10-18T14-09
Command: poetry run python scripts/dev_tools/build_discovery_runtime.py --check
EXIT_CODE: 0
Output Summary:     "schemas/discovery/v2/validation-receipt.schema.json";   ],;   "runtime_version": "2.0.0"; }

Working directory: .
Started: 2026-10-18T14:09:18.238187+00:00
Duration seconds: 1.042
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
{
  "changed_paths": [],
  "checked_runtime_modules": [
    "drm_copilot_discovery",
    "drm_copilot_discovery.acceptance_rules",
    "drm_copilot_discovery.activation_models",
    "drm_copilot_discovery.agent_output",
    "drm_copilot_discovery.catalog",
    "drm_copilot_discovery.claim_rules",
    "drm_copilot_discovery.completion_rules",
    "drm_copilot_discovery.coverage_rules",
    "drm_copilot_discovery.coverage_scope_rules",
    "drm_copilot_discovery.decision_rules",
    "drm_copilot_discovery.dimension_rules",
    "drm_copilot_discovery.domain_profile",
    "drm_copilot_discovery.domain_profile_models",
    "drm_copilot_discovery.evidence_rules",
    "drm_copilot_discovery.findings",
    "drm_copilot_discovery.init_flow",
    "drm_copilot_discovery.init_io",
    "drm_copilot_discovery.init_models",
    "drm_copilot_discovery.init_projection",
    "drm_copilot_discovery.io",
    "drm_copilot_discovery.models",
    "drm_copilot_discovery.mutation_filesystem",
    "drm_copilot_discovery.mutation_io",
    "drm_copilot_discovery.mutation_plan",
    "drm_copilot_discovery.parity_rules",
    "drm_copilot_discovery.parity_target_rules",
    "drm_copilot_discovery.parsing",
    "drm_copilot_discovery.path_models",
    "drm_copilot_discovery.path_policy",
    "drm_copilot_discovery.profile_models",
    "drm_copilot_discovery.profile_v2",
    "drm_copilot_discovery.reference_links",
    "drm_copilot_discovery.references",
    "drm_copilot_discovery.rendering",
    "drm_copilot_discovery.repository_reader",
    "drm_copilot_discovery.resources",
    "drm_copilot_discovery.revision_rules",
    "drm_copilot_discovery.runtime_claim_rules",
    "drm_copilot_discovery.schema_validation",
    "drm_copilot_discovery.snapshot",
    "drm_copilot_discovery.snapshot_io",
    "drm_copilot_discovery.snapshot_loading",
    "drm_copilot_discovery.validation",
    "drm_copilot_discovery.validation_inputs"
  ],
  "declared_runtime_dependencies": [
    "PyYAML",
    "jsonschema",
    "lxml",
    "referencing"
  ],
  "imported_runtime_dependencies": [
    "PyYAML",
    "jsonschema",
    "referencing"
  ],
  "resource_manifest_sha256": "3c3edf7c867f5bc06399e4f488542d4444653eb8b61ad1051b40760e29f63c4c",
  "resources": [
    "docs/discovery/templates/v2/coverage-ledger.json",
    "docs/discovery/templates/v2/domain-profile.yaml",
    "docs/discovery/templates/v2/parity-matrix.json",
    "docs/discovery/templates/v2/product-decisions.yaml",
    "docs/discovery/templates/v2/scope.yaml",
    "docs/discovery/templates/v2/unspecified-behaviors.yaml",
    "schemas/discovery/v1/coverage-ledger.schema.json",
    "schemas/discovery/v1/evidence-reference.schema.json",
    "schemas/discovery/v1/feature-contract.schema.json",
    "schemas/discovery/v1/parity-matrix.schema.json",
    "schemas/discovery/v1/product-decision-record.schema.json",
    "schemas/discovery/v1/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v1/unspecified-behavior-record.schema.json",
    "schemas/discovery/v2/acceptance-specification.schema.json",
    "schemas/discovery/v2/activation.schema.json",
    "schemas/discovery/v2/capability-attestation.schema.json",
    "schemas/discovery/v2/common.schema.json",
    "schemas/discovery/v2/coverage-ledger.schema.json",
    "schemas/discovery/v2/discovery-invocation.schema.json",
    "schemas/discovery/v2/domain-profile.schema.json",
    "schemas/discovery/v2/evidence-reference.schema.json",
    "schemas/discovery/v2/extension-result-manifest.schema.json",
    "schemas/discovery/v2/feature-contract.schema.json",
    "schemas/discovery/v2/implementation-record.schema.json",
    "schemas/discovery/v2/inventory-snapshot.schema.json",
    "schemas/discovery/v2/migration-report.schema.json",
    "schemas/discovery/v2/parity-matrix.schema.json",
    "schemas/discovery/v2/product-decision-collection.schema.json",
    "schemas/discovery/v2/product-decision.schema.json",
    "schemas/discovery/v2/required-output-manifest.schema.json",
    "schemas/discovery/v2/runtime-characterization-scenario.schema.json",
    "schemas/discovery/v2/scope.schema.json",
    "schemas/discovery/v2/service-request.schema.json",
    "schemas/discovery/v2/service-result.schema.json",
    "schemas/discovery/v2/source-snapshot-manifest.schema.json",
    "schemas/discovery/v2/tool-authorization.schema.json",
    "schemas/discovery/v2/unspecified-behavior-collection.schema.json",
    "schemas/discovery/v2/unspecified-behavior.schema.json",
    "schemas/discovery/v2/validation-receipt.schema.json"
  ],
  "runtime_version": "2.0.0"
}
```

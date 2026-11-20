# Phase 0 pyproject.toml `dev.discovery.*` Divergent-Line Enumeration — Remediation Cycle 2 (#362)

- Timestamp: 2026-07-18T17-25

## Commands and Verbatim Output

### `git merge-base HEAD origin/epic/legacy-discovery-and-parity-integration`

```
f18c1c16f3eb111f0acef5eb3c46be1fb563aac0
```

### `git show <merge-base>:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

```
59:"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
```

### `git show HEAD:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

```
59:"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
60:"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
```

### `git show origin/epic/legacy-discovery-and-parity-integration:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

```
59:"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
60:"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
61:"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
62:"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
63:"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
64:"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
65:"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
66:"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
67:"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
68:"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
69:"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
```

## Derived Lists

### (a) Lines present on HEAD but absent at the merge base

1. `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"`

Total: 1 line.

### (b) Lines present on the integration branch but absent at the merge base

1. `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"`
2. `"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"`
3. `"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"`
4. `"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"`
5. `"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"`
6. `"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"`
7. `"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"`
8. `"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"`
9. `"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"`
10. `"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"`

Total: 10 lines.

### (c) Lines present in both HEAD's and the integration branch's added sets with an identical key

None found. HEAD's sole addition (`dev.discovery.init`) does not overlap with any of the integration branch's 10 additions.

## Statement on Completeness

No further lines beyond the two anticipated in the remediation-inputs document were found in derived list (a) beyond `"dev.discovery.init"` (exactly 1 line). Derived list (b) contains 10 lines total: `"dev.discovery.generate-acceptance-scenarios"` plus 9 `"dev.discovery.validate-*"` lines, consistent with the directive's stated count of 10 lines beyond the merge base contributed by sibling features on the integration branch. `"dev.discovery.profile"` is present at the merge base itself and is therefore not divergent; it requires no special handling beyond remaining unedited in its existing position.

# Phase 0 — pyproject.toml Divergent-Line Enumeration (Remediation Cycle 4, Issue #362)

- Timestamp: 2026-07-18T18-47

## Commands and Verbatim Output

### 1. `git merge-base HEAD origin/epic/legacy-discovery-and-parity-integration`

```
85e7bea2bd2695114c9feffb2a4963da9f37c9ad
```

### 2. `git show 85e7bea2bd2695114c9feffb2a4963da9f37c9ad:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

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

### 3. `git show HEAD:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

```
59:"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
60:"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
61:"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
62:"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
63:"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
64:"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
65:"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
66:"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
67:"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
68:"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
69:"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
70:"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
```

Note: HEAD's `dev.discovery.*` run is already in strict alphabetical order (a prior remediation cycle sorted it), in addition to adding `dev.discovery.init`.

### 4. `git show origin/epic/legacy-discovery-and-parity-integration:pyproject.toml | Select-String -Pattern '"dev\.discovery\.'`

```
59:"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
60:"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
61:"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
62:"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
63:"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
64:"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
65:"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
66:"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
67:"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
68:"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
69:"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
70:"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
```

Note: the integration branch's `dev.discovery.*` run retains the merge-base's original (unsorted) order, plus the single added `dev.discovery.inventory` line.

### 5. `git diff 85e7bea2bd2695114c9feffb2a4963da9f37c9ad origin/epic/legacy-discovery-and-parity-integration -- pyproject.toml`

```
diff --git a/pyproject.toml b/pyproject.toml
index 5912f4c9..060a9828 100644
--- a/pyproject.toml
+++ b/pyproject.toml
@@ -57,6 +57,7 @@ shell-qc-test = "scripts.dev_tools.shell_qc:main_test"
 "dev.clean-devcontainer" = "scripts.dev_tools.clean_devcontainer:main"
 "dev.collect-commit-context" = "scripts.dev_tools.collect_commit_context:main"
 "dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
+"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
 "dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
 "dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
 "dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
@@ -130,6 +131,7 @@ exclude_lines = [
     "if TYPE_CHECKING:",
     "@abstractmethod",
     "@abc.abstractmethod",
+    "^\\s*\\.\\.\\.\\s*$",
 ]
 
 [tool.pyright]
```

The integration side's full diff against the merge base touches exactly two locations in `pyproject.toml`: the single `"dev.discovery.inventory"` addition in `[tool.poetry.scripts]`, and the single `"^\\s*\\.\\.\\.\\s*$"` addition in `[tool.coverage.report] exclude_lines` (already known to merge cleanly, per the plan's Ground-Truth Contracts).

## Derived Lists

- **(a) Lines present on HEAD but absent at the merge base:**
  - `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"`
  - (HEAD's `dev.discovery.*` run was also reordered into alphabetical order in a prior cycle; that reordering is not a new "line" — it is a positional change to lines already present at the merge base.)

- **(b) Lines present on the integration branch but absent at the merge base:**
  - `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"`

- **(c) Lines present in both derived sets with an identical key:** None. `dev.discovery.init` and `dev.discovery.inventory` are distinct keys.

## Conclusion

No further `dev.discovery.*` lines, and no other lines anywhere else in `pyproject.toml`, were found to diverge between the merge base and the integration branch beyond the two hunks shown in command 5 above (the `dev.discovery.inventory` script alias and the `exclude_lines` addition, both already known and accounted for by the plan's Ground-Truth Contracts). The confirmed full divergent-line set for the `[tool.poetry.scripts]` conflict region is exactly `"dev.discovery.init"` (HEAD-only) and `"dev.discovery.inventory"` (integration-only).

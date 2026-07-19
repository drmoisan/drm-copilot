# Phase 0 — pyproject.toml [tool.poetry.scripts] Divergence Enumeration (Issue #369, Remediation Cycle 1)

Timestamp: 2026-07-18T22-27

## Command 1: git merge-base HEAD origin/epic/legacy-discovery-and-parity-integration

Output:
```
3a4985fa904da7b5925091b393f9551c874ab006
```
Merge base = `3a4985fa904da7b5925091b393f9551c874ab006`.

## Command 2: git show <merge-base>:pyproject.toml | Select-String '"dev\.discovery\.'

Output (base, dev.discovery.* run):
```
"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
```

## Command 3: git show HEAD:pyproject.toml | Select-String '"dev\.discovery\.'

Output (HEAD / feature #369, dev.discovery.* run):
```
"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"
"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"
"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
```

## Command 4: git show origin/epic/legacy-discovery-and-parity-integration:pyproject.toml | Select-String '"dev\.discovery\.'

Output (integration tip 01fb34a8, dev.discovery.* run):
```
"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"
"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"
"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"
"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
"dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
"dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
"dev.discovery.validate-evidence-reference" = "scripts.dev_tools.validate_discovery_artifacts:main_evidence_reference"
"dev.discovery.validate-feature-contract" = "scripts.dev_tools.validate_discovery_artifacts:main_feature_contract"
"dev.discovery.validate-parity-matrix" = "scripts.dev_tools.validate_discovery_artifacts:main_parity_matrix"
"dev.discovery.validate-product-decision" = "scripts.dev_tools.validate_discovery_artifacts:main_product_decision"
"dev.discovery.validate-profile" = "scripts.dev_tools.validate_discovery_artifacts:main_profile"
"dev.discovery.validate-runtime-scenario" = "scripts.dev_tools.validate_discovery_artifacts:main_runtime_scenario"
"dev.discovery.validate-unspecified-behavior" = "scripts.dev_tools.validate_discovery_artifacts:main_unspecified_behavior"
```

## Command 5: git diff <merge-base> origin/epic/legacy-discovery-and-parity-integration -- pyproject.toml

Output:
```
diff --git a/pyproject.toml b/pyproject.toml
index a600d83f..b11adba4 100644
--- a/pyproject.toml
+++ b/pyproject.toml
@@ -56,9 +56,12 @@ shell-qc-test = "scripts.dev_tools.shell_qc:main_test"
 "dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"
 "dev.clean-devcontainer" = "scripts.dev_tools.clean_devcontainer:main"
 "dev.collect-commit-context" = "scripts.dev_tools.collect_commit_context:main"
+"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"
+"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"
 "dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"
 "dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
 "dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"
+"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"
 "dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"
 "dev.discovery.validate-all" = "scripts.dev_tools.validate_discovery_artifacts:main"
 "dev.discovery.validate-coverage-ledger" = "scripts.dev_tools.validate_discovery_artifacts:main_coverage_ledger"
```

## Derived Lists

(a) Lines present on HEAD but absent at the merge base:
- `"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"`
- `"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"`

(b) Lines present on the integration branch but absent at the merge base:
- `"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"`
- `"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"`
- `"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"`

(c) Keys present in both derived sets: none. The HEAD-added and integration-added key sets are disjoint.

## Conflict-Shape Confirmation

- The plan P0-T3 acceptance requires: list (a) includes `dotnet` and `vsto` — CONFIRMED. List (b) includes `parity-report` — CONFIRMED.
- Additional `[tool.poetry.scripts]` lines beyond the plan-anticipated three: YES. The integration branch has advanced since plan capture (tip 01fb34a8 vs plan ground-truth 2215ebf9) and now additionally adds `dev.discovery.completion-report` and `dev.discovery.coverage-report`. Both are additive entries placed at the top of the `dev.discovery.*` run (before `generate-acceptance-scenarios`) via a clean, non-conflicting hunk. They do not overlap the HEAD-added region and do not collide with any HEAD key.
- Any diverging `pyproject.toml` hunk OUTSIDE the `[tool.poetry.scripts]` table: NONE. Command 5 shows exactly one hunk, entirely within the `[tool.poetry.scripts]` table. No dependency table, coverage-config table, or other section diverges on the integration side.
- Escalation assessment: The plan's P0-T3 escalation trigger is divergence *outside* the `[tool.poetry.scripts]` table. That trigger is NOT met — all integration divergence is confined to the scripts table. The two extra additive entries (`completion-report`, `coverage-report`) are within the single authorized conflicted file (`pyproject.toml`) and the single authorized table (`[tool.poetry.scripts]`), do not conflict with the HEAD additions, and will be auto-merged from the integration side. The true conflict region remains solely the block between `inventory` and `profile` (HEAD: `dotnet`, `vsto`; integration: `parity-report`). Execution continues per plan; the conflicted-file-list check (P1-T1) provides the second confirmation that only `pyproject.toml` conflicts.

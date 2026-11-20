# P11-T5 Coverage comparison: baseline, final and delta for every changed production file

Timestamp: 2026-10-23T08-18
Command: poetry run python SCRATCH/issue-980-coverage-comparison.py SCRATCH/logs/p11t5-comparison-final.md SCRATCH/issue-980-p11t5-coverage.json SCRATCH/p11t4/single-powershell-coverage.xml final (baselines from evidence/baseline/python-coverage.2026-10-18T03-51.json, typescript-{root,extension}-coverage-summary.*.json and powershell-coverage.2026-10-18T04-22.xml; finals from the P11-T5 Python full run, the P11-T3 Jest coverage runs and the P11-T5 single-process Pester run; changed files and changed lines from git diff against the merge base of origin/main and HEAD with rename detection, which reports no renamed production file, so no relocated-source baseline applies)
EXIT_CODE: 0
Output Summary: 254 changed production files (Python 174: 136 added, 38 modified; TypeScript 45: 25 added, 20 modified; PowerShell 35: 25 added, 10 modified), every one present in its final report with numeric figures. Gates: Python per-file lines >= 85% and branches >= 75% pass for all 174 (0 below), every added Python file >= 90% lines (lowest 93.02%), repository 96.67% lines / 93.61% branches (>= 80% and the stricter CI 85/75); TypeScript per-file 85/75 pass for all 42 executable files and the three interface-only modules (0 executable statements) are exempt by the type-only clarification, every added executable file >= 90% lines, extension 97.15% / 93.53% and root 98.2% / 93.23%; PowerShell per-file lines >= 85% pass for all 35 (lowest 92.82%), every added file >= 90%, population 93.13% lines, no branch metric (Pester measures none). Changed-line no-regression: every measurable changed line of every modified Python and PowerShell file and every changed statement of every modified TypeScript file is covered (0 uncovered). Two modified files carry a whole-file percentage below their baseline with every changed line covered and both floors met (rewrites.py 91.30 to 90.24 lines, repo-automation-service.ts 98.39 to 98.22 lines); recorded as information. Baseline provenance: added files are absent from the baseline reports with zero prior executable lines; modified files carry their baseline figures.

## Gate summary

| Gate | Python | TypeScript | PowerShell |
| --- | --- | --- | --- |
| Changed production files measured | 174 / 174 | 45 / 45 (42 executable, 3 type-only) | 35 / 35 |
| Per-file lines >= 85% | 174 pass | 42 pass | 35 pass |
| Per-file branches >= 75% | 174 pass | 42 pass | not measured by Pester (no gate) |
| New files lines >= 90% | 136 pass | 22 executable pass | 25 pass |
| Changed-line no regression (modified files) | 38 pass, 0 uncovered changed lines | 20 pass, 0 uncovered changed statements | 10 pass, 0 uncovered changed lines |
| Repository >= 80% and configured floors | 96.67% lines, 93.61% branches (CI 85/75 gate exit 0) | extension 97.15% / 93.53%, root 98.2% / 93.23%, per-file threshold map exit 0 | 93.13% lines over 240 files |

## Python changed production files

| File | Status | Baseline provenance | Baseline lines / branches | Final lines / branches | Line delta | Changed lines / covered | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `packages/discovery-runtime/src/drm_copilot_discovery/__init__.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 4 / 4 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.92% / 95.65% | n/a | 144 / 141 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.40% / 95.16% | n/a | 187 / 184 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 180 / 180 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_render_text.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 95.74% / 92.00% | n/a | 94 / 90 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.68% / 96.05% | n/a | 151 / 149 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 102 / 102 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 28 / 28 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 162 / 162 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.29% / 98.53% | n/a | 140 / 139 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 3 / 3 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 91 / 91 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 115 / 115 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_interop.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 121 / 121 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_syntax.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 85 / 85 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 89 / 89 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.53% / 93.33% | n/a | 204 / 201 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 174 / 174 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_tokens.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.98% / 97.92% | n/a | 98 / 97 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependencies.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 149 / 149 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 141 / 141 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 174 / 174 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_node.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 103 / 103 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_python.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 156 / 156 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_values.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 101 / 101 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 137 / 137 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 126 / 126 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 100 / 100 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 47 / 47 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 11 / 11 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 22 / 22 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 112 / 112 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 80 / 80 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 109 / 109 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/__init__.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | n/a / n/a | n/a | 0 / 0 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_office.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 127 / 127 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_patterns.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 16 / 16 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_syntax.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 162 / 162 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 70 / 70 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 80 / 80 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 9 / 9 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 63 / 63 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/source_text.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 145 / 145 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.39% / 97.37% | n/a | 62 / 61 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.12% / 94.83% | n/a | 160 / 157 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/ui_callbacks.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 164 / 164 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/xml_input.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 101 / 101 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/build_identity.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 225 / 225 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/catalog.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 167 / 167 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/claim_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.22% / 97.22% | n/a | 128 / 127 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 147 / 147 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli_arguments.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 182 / 182 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/cli_commands.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 41 / 41 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/completion_report.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 95 / 95 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 72 / 72 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/configuration.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 123 / 123 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.26% / 92.00% | n/a | 115 / 113 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 111 / 111 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 106 / 106 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/coverage_scope_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 142 / 142 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/decision_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 183 / 183 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 98 / 98 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/doctor.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 142 / 142 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.51% / 98.78% | n/a | 203 / 202 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 55 / 55 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.17% / 97.37% | n/a | 120 / 119 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 50 / 50 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 108 / 108 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/evidence_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 110 / 110 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_inputs.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 187 / 187 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_results.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 122 / 122 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/extension_validation.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 214 / 214 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/findings.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 97.22% | n/a | 78 / 78 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 117 / 117 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.30% / 97.50% | n/a | 142 / 141 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/gherkin.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.32% / 98.28% | n/a | 148 / 147 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.53% / 94.44% | n/a | 136 / 134 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_io.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.86% / 94.00% | n/a | 140 / 137 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 30 / 30 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 178 / 178 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/io.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 16 / 16 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_capture.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 96.67% / 90.91% | n/a | 120 / 116 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_conversion.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 76 / 76 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 96 / 96 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/migration_v1.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 131 / 131 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 84 / 84 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.04% / 94.44% | n/a | 209 / 207 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.26% / 97.22% | n/a | 136 / 135 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.60% / 96.88% | n/a | 214 / 211 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/operations.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 158 / 158 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.56% / 94.64% | n/a | 139 / 137 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 91.07% | n/a | 151 / 151 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / n/a | n/a | 35 / 35 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 45 / 45 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 104 / 104 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 98.00% | n/a | 99 / 99 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/parsing.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.09% / 97.67% | n/a | 206 / 200 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/path_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 98 / 98 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 161 / 161 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 173 / 173 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 150 / 150 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/reference_links.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 97.06% | n/a | 93 / 93 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/references.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.83% / 97.62% | n/a | 171 / 169 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/rendering.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 15 / 15 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/report_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 138 / 138 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/report_rendering.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 17 / 17 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/repository_reader.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 83 / 83 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/resources.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 103 / 103 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/revision_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.47% / 98.15% | n/a | 187 / 186 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/runtime_claim_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.83% / 91.67% | n/a | 92 / 90 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/schema_validation.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 146 / 146 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.08% / 96.15% | n/a | 109 / 108 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 95.50% / 82.14% | n/a | 111 / 106 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_contracts.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 132 / 132 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.13% / 96.67% | n/a | 115 / 114 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 96 / 96 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 84 / 84 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_request_rules.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.30% / 96.55% | n/a | 74 / 72 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_selection.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.14% / 98.00% | n/a | 116 / 115 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/service_serialization.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 154 / 154 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 116 / 116 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_inventory_inputs.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 22 / 22 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 186 / 186 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 98.31% | n/a | 204 / 204 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_read_models.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 200 / 200 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_reads.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 209 / 209 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.68% / 96.15% | n/a | 152 / 150 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 97.39% / 93.75% | n/a | 115 / 112 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 89 / 89 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 51 / 51 | PASS |
| `packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 98 / 98 | PASS |
| `scripts/dev_tools/_codex_discovery_routing.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 70 / 70 | PASS |
| `scripts/dev_tools/agentic_sync.py` | M | baseline file | 87.22% / 62.50% | 96.67% / 95.00% | +9.45 | 0 / 0 | PASS |
| `scripts/dev_tools/build_discovery_runtime.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 225 / 225 | PASS |
| `scripts/dev_tools/codex_native_converter/classifier.py` | M | baseline file | 92.94% / 88.64% | 96.88% / 94.12% | +3.94 | 13 / 13 | PASS |
| `scripts/dev_tools/codex_native_converter/classifier_claude.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 93.02% / 90.00% | n/a | 43 / 40 | PASS |
| `scripts/dev_tools/codex_native_converter/inventory.py` | M | baseline file | 95.56% / 90.00% | 97.78% / 95.00% | +2.22 | 0 / 0 | PASS |
| `scripts/dev_tools/codex_native_converter/mapping.py` | M | baseline file | 93.75% / 87.50% | 96.36% / 92.31% | +2.61 | 7 / 7 | PASS |
| `scripts/dev_tools/codex_native_converter/pipeline.py` | M | baseline file | 94.57% / 83.33% | 95.74% / 88.64% | +1.17 | 2 / 2 | PASS |
| `scripts/dev_tools/codex_native_converter/rewrites.py` | M | baseline file | 91.30% / 85.71% | 90.24% / 80.00% | -1.06 | 2 / 2 | info: whole-file line delta -1.06, changed lines covered; info: whole-file branch delta -5.71 |
| `scripts/dev_tools/codex_native_converter/rewrites_detection.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 9 / 9 | PASS |
| `scripts/dev_tools/discovery/__init__.py` | M | baseline file | 100.00% / n/a | 100.00% / n/a | +0.00 | 1 / 1 | PASS |
| `scripts/dev_tools/discovery/analyzer/__init__.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 3 / 3 | PASS |
| `scripts/dev_tools/discovery/analyzer/cli.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 15 / 15 | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | M | baseline file | 96.83% / 90.91% | 100.00% / n/a | +3.17 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/analyzer/emitter.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/analyzer/inventory.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 6 / 6 | PASS |
| `scripts/dev_tools/discovery/analyzer/models.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 8 / 8 | PASS |
| `scripts/dev_tools/discovery/analyzer/pipeline.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 4 / 4 | PASS |
| `scripts/dev_tools/discovery/analyzer/source_text.py` | M | baseline file | 100.00% / 96.15% | 100.00% / n/a | +0.00 | 8 / 8 | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | M | baseline file | 94.23% / 100.00% | 100.00% / n/a | +5.77 | 3 / 3 | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | M | baseline file | 97.76% / 93.33% | 100.00% / 100.00% | +2.24 | 46 / 46 | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | M | baseline file | 100.00% / n/a | 100.00% / 100.00% | +0.00 | 7 / 7 | PASS |
| `scripts/dev_tools/discovery/completion_report.py` | M | baseline file | 92.16% / 100.00% | 100.00% / 100.00% | +7.84 | 31 / 31 | PASS |
| `scripts/dev_tools/discovery/coverage_report.py` | M | baseline file | 95.00% / 100.00% | 100.00% / 100.00% | +5.00 | 24 / 24 | PASS |
| `scripts/dev_tools/discovery/domain_profile.py` | M | baseline file | 99.47% / 98.72% | 100.00% / n/a | +0.53 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/domain_profile_models.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/init_cli.py` | M | baseline file | 100.00% / n/a | 100.00% / n/a | +0.00 | 3 / 3 | PASS |
| `scripts/dev_tools/discovery/init_flow.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/init_models.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/io.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery/parity_report.py` | M | baseline file | 95.00% / 100.00% | 100.00% / 100.00% | +5.00 | 24 / 24 | PASS |
| `scripts/dev_tools/discovery/profile_cli.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 3 / 3 | PASS |
| `scripts/dev_tools/discovery/rendering.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/discovery_build_identity.py` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | 101 / 101 | PASS |
| `scripts/dev_tools/generate_acceptance_scenarios.py` | M | baseline file | 100.00% / 100.00% | 100.00% / n/a | +0.00 | 24 / 24 | PASS |
| `scripts/dev_tools/generate_codex_agent_variants.py` | M | baseline file | 94.53% / 89.13% | 94.57% / 89.13% | +0.04 | 1 / 1 | PASS |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | M | baseline file | 98.04% / 85.71% | 98.17% / 88.89% | +0.13 | 7 / 7 | PASS |
| `scripts/dev_tools/quality_tiers_contract.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 2 / 2 | PASS |
| `scripts/dev_tools/resolve_codex_deployment.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 0 / 0 | PASS |
| `scripts/dev_tools/resolve_codex_topology.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 6 / 6 | PASS |
| `scripts/dev_tools/validate_discovery_artifacts.py` | M | baseline file | 98.36% / 100.00% | 100.00% / 100.00% | +1.64 | 64 / 64 | PASS |
| `scripts/dev_tools/validate_discovery_profile.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 16 / 16 | PASS |
| `scripts/dev_tools/validate_discovery_schema_artifacts.py` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 19 / 19 | PASS |

Python counts: {"files": 174, "new": 136, "below": 0, "new_below_90": 0, "regressed": 1, "changed_uncovered": 0}

## TypeScript changed production files

| File | Status | Baseline provenance | Baseline lines / branches | Final lines / branches | Line delta | Disposition |
| --- | --- | --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/discovery-artifact-command-registration.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authority-paths.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.11% / 97.37% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authority-provider.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authority-record.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.23% / 98.51% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authority.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.22% / 96.15% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authorization-record.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.12% / 97.44% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-authorization.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 96.46% / 96.43% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-capabilities.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 97.98% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-capability-record.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.37% / 98.21% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-command-registration.ts` | M | baseline file | 90.66% / 78.18% | 100.00% / 100.00% | +9.34 | 78 changed statements, 78 covered | PASS |
| `extensions/drm-copilot/src/discovery-finalization.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.29% / 97.10% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-input-manifest.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.48% / 98.80% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-invocation-record.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-invocation.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.27% / 95.56% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-result.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 97.06% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-routing.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 98.45% / 97.44% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-runtime.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 96.67% / 95.92% | n/a | added file | PASS |
| `extensions/drm-copilot/src/discovery-service-types.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 0.00% / 0.00% | n/a | added file | type-only module (no executable statement); exempt from measurement |
| `extensions/drm-copilot/src/discovery-workspace-command-registration.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier-claude.ts` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 55 changed statements, 55 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier.ts` | M | baseline file | 98.64% / 94.44% | 98.88% / 95.35% | +0.24 | 62 changed statements, 62 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts` | M | baseline file | 98.09% / 87.72% | 98.10% / 87.72% | +0.01 | 2 changed statements, 2 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/mapping.ts` | M | baseline file | 99.10% / 94.87% | 99.19% / 95.12% | +0.09 | 25 changed statements, 25 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts` | M | baseline file | 93.72% / 79.55% | 93.80% / 77.78% | +0.08 | 5 changed statements, 5 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 25 changed statements, 25 covered | PASS |
| `extensions/drm-copilot/src/lib/codex-native-converter/rewrites.ts` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 2 changed statements, 2 covered | PASS |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | M | baseline file | 98.87% / 95.31% | 98.98% / 95.65% | +0.11 | 38 changed statements, 38 covered | PASS |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | M | baseline file | 97.99% / 86.67% | 98.00% / 86.67% | +0.01 | 1 changed statements, 1 covered | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-discovery-routing.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 99.21% / 96.67% | n/a | added file | PASS |
| `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` | M | baseline file | 97.41% / 94.74% | 97.88% / 95.16% | +0.47 | 63 changed statements, 63 covered | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` | M | baseline file | 95.69% / 94.17% | 95.71% / 94.35% | +0.02 | 2 changed statements, 2 covered | PASS |
| `extensions/drm-copilot/src/mcp-discovery-authority-tool-definitions.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` | M | baseline file | 100.00% / n/a | 100.00% / 100.00% | +0.00 | 250 changed statements, 250 covered | PASS |
| `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` | M | baseline file | 100.00% / 100.00% | 100.00% / 100.00% | +0.00 | 107 changed statements, 107 covered | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery-authority.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery-shared.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 100.00% | n/a | added file | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs-discovery.ts` | M | baseline file | 100.00% / 96.88% | 100.00% / 100.00% | +0.00 | 323 changed statements, 323 covered | PASS |
| `extensions/drm-copilot/src/mcp-tools.ts` | M | baseline file | 94.74% / 88.41% | 95.93% / 91.40% | +1.19 | 106 changed statements, 106 covered | PASS |
| `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | M | baseline file | 97.14% / 83.87% | 100.00% / 100.00% | +2.86 | 328 changed statements, 328 covered | PASS |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | M | baseline file | 0.00% / 0.00% | 0.00% / 0.00% | +0.00 | added file | type-only module (no executable statement); exempt from measurement |
| `extensions/drm-copilot/src/repo-automation-service-discovery-agent.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 91.67% | n/a | added file | PASS |
| `extensions/drm-copilot/src/repo-automation-service-discovery-types.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 0.00% / 0.00% | n/a | added file | type-only module (no executable statement); exempt from measurement |
| `extensions/drm-copilot/src/repo-automation-service-discovery.ts` | A | absent from baseline (0 prior executable lines) | n/a / n/a | 100.00% / 92.59% | n/a | added file | PASS |
| `extensions/drm-copilot/src/repo-automation-service.ts` | M | baseline file | 98.39% / 94.12% | 98.22% / 93.18% | -0.17 | 10 changed statements, 10 covered | info: whole-file line delta -0.17, changed statements covered |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | M | baseline file | 100.00% / n/a | 100.00% / n/a | +0.00 | 11 changed statements, 11 covered | PASS |

TypeScript counts: {"files": 45, "new": 25, "below": 0, "new_below_90": 0, "type_only": 3}

## PowerShell changed production files

| File | Status | Baseline provenance | Baseline lines | Final lines | Line delta | Changed lines measured / covered | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/discovery-capability-probe.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 97.14% | n/a | 35 / 35 | PASS |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | M | baseline file | 95.65% | 100.00% | +4.35 | 19 / 19 | PASS |
| `.claude/hooks/enforce-discovery-planning-gate.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 26 / 26 | PASS |
| `.claude/hooks/record-discovery-agent-start.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 39 / 39 | PASS |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | M | baseline file | 100.00% | 100.00% | +0.00 | 21 / 21 | PASS |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | M | baseline file | 100.00% | 100.00% | +0.00 | 0 / 0 | PASS |
| `.claude/lib/codex-routing/CodexDiscoveryRouting.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 68 / 68 | PASS |
| `.claude/lib/codex-routing/CodexTopology.psm1` | M | baseline file | 100.00% | 100.00% | +0.00 | 3 / 3 | PASS |
| `.claude/lib/discovery-validation/DiscoveryAuthority.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 94.56% | n/a | 147 / 147 | PASS |
| `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 95.50% | n/a | 200 / 200 | PASS |
| `.claude/lib/discovery-validation/DiscoveryCapability.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 99.21% | n/a | 127 / 127 | PASS |
| `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 93.48% | n/a | 46 / 46 | PASS |
| `.claude/lib/discovery-validation/DiscoveryManifest.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 93.94% | n/a | 132 / 132 | PASS |
| `.claude/lib/discovery-validation/DiscoveryPayload.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 97 / 97 | PASS |
| `.claude/lib/discovery-validation/DiscoveryPlanning.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 97.67% | n/a | 129 / 129 | PASS |
| `.claude/lib/discovery-validation/DiscoveryStart.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 99.26% | n/a | 136 / 136 | PASS |
| `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 95.33% | n/a | 107 / 107 | PASS |
| `.claude/lib/discovery-validation/DiscoveryStop.psm1` | A | absent from baseline (0 prior executable lines) | n/a | 97.14% | n/a | 140 / 140 | PASS |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | M | baseline file | 94.50% | 100.00% | +5.50 | 56 / 56 | PASS |
| `.codex/hooks/codex-agent-profile-attestation.ps1` | M | baseline file | 93.75% | 94.19% | +0.44 | 6 / 6 | PASS |
| `.codex/hooks/discovery-capability-probe.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 96.43% | n/a | 28 / 28 | PASS |
| `.codex/hooks/discovery-start-attestation.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 77 / 77 | PASS |
| `.codex/hooks/enforce-codex-model-routing.ps1` | M | baseline file | 100.00% | 100.00% | +0.00 | 1 / 1 | PASS |
| `.codex/hooks/enforce-discovery-artifact-gate.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 46 / 46 | PASS |
| `.codex/hooks/enforce-discovery-planning-gate.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 46 / 46 | PASS |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | M | baseline file | 92.65% | 92.82% | +0.17 | 5 / 5 | PASS |
| `.codex/hooks/validate-codex-subagent-routing.ps1` | M | baseline file | 100.00% | 100.00% | +0.00 | 6 / 6 | PASS |
| `.codex/hooks/validate-discovery-agent-output.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 57 / 57 | PASS |
| `.codex/scripts/Resolve-CodexTopology.ps1` | M | baseline file | 100.00% | 100.00% | +0.00 | 7 / 7 | PASS |
| `.github/hooks/discovery-agent-start.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 35 / 35 | PASS |
| `.github/hooks/discovery-agent-stop.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 40 / 40 | PASS |
| `.github/hooks/discovery-capability-probe.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 96.77% | n/a | 31 / 31 | PASS |
| `.github/hooks/discovery-planning.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 25 / 25 | PASS |
| `.github/hooks/discovery-pre-tool.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 100.00% | n/a | 31 / 31 | PASS |
| `scripts/dev-tools/Test-DiscoveryHostCapability.ps1` | A | absent from baseline (0 prior executable lines) | n/a | 95.24% | n/a | 21 / 21 | PASS |

PowerShell counts: {"files": 35, "new": 25, "below": 0, "new_below_90": 0, "changed_uncovered": 0}

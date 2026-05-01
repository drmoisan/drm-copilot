# 2026-04-26-codex-native-converter - Plan

- **Issue:** #164
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-26T18-01
- **Status:** Approved-for-execution (pending preflight)
- **Version:** 1.0
- **Work Mode:** full-feature
- **Feature folder:** `docs/features/active/2026-04-26-codex-native-converter-164/`
- **Languages in scope:** Python, TypeScript

## Required References

- Repository tone and policy: `.github/copilot-instructions.md`
- General code change policy: `.github/instructions/general-code-change.instructions.md`
- General unit test policy: `.github/instructions/general-unit-test.instructions.md`
- Python policy: `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`
- TypeScript policy: `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`
- Atomic plan contract: `.github/skills/atomic-plan-contract/SKILL.md`
- Evidence and timestamp conventions: `.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- Acceptance-criteria tracking: `.github/skills/acceptance-criteria-tracking/SKILL.md`

All work must comply with these policies. All evidence artifacts in this plan resolve to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/<kind>/`.

## Source Documents (Authoritative Inputs)

- `docs/features/active/2026-04-26-codex-native-converter-164/issue.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md`
- `artifacts/research/20260426-codex-native-converter-research.md`
- `docs/features/active/2026-04-26-codex-native-converter-164/plan.2026-04-26T18-01.md`

## Implementation Strategy Notes

- **Authoritative runtime shape.** The Python converter is the primary implementation surface. TypeScript is limited to a thin bundled command and MCP wrapper in `extensions/drm-copilot/`; no separate TypeScript conversion engine is allowed.
- **Planned Python package.** Keep converter logic under `scripts/dev_tools/codex_native_converter/` so classification, mapping, validation, report writing, and CLI orchestration remain split across cohesive modules under the 500-line policy limit.
- **Planned TypeScript surface.** Follow the existing `repo-automation-service` + `mcp-handlers` + `mcp-tool-definitions` + `mcp-tool-inputs` + `mcp-tools` wiring pattern already used for bundled Python workflows.
- **Acceptance-criteria source files.** Because this feature is `full-feature`, check off delivered acceptance criteria in `spec.md` and `user-story.md` only after final QC passes.
- **Coverage evidence contract.** Record numeric baseline and final coverage for Python and TypeScript. Record separate Python and TypeScript coverage-delta artifacts plus a final summary artifact that cites the recorded repo-wide baseline, repo-wide post-change, and new-or-changed-code coverage values for both languages.

---

### Phase 0 — Preflight, Policy Reads, and Baseline Capture

- [x] [P0-T1] Read the required policy and skill files in the repository order and record the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Policy Order:`, and the explicit file list for `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.github/skills/evidence-and-timestamp-conventions/SKILL.md`, and `.github/skills/acceptance-criteria-tracking/SKILL.md`.

- [x] [P0-T2] Verify feature-folder integrity and record the result in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-feature-state.md`.
  - Acceptance: the artifact exists and records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming the presence of `issue.md`, `spec.md`, `user-story.md`, and `plan.2026-04-26T18-01.md` under `docs/features/active/2026-04-26-codex-native-converter-164/`.

- [x] [P0-T3] Capture Python formatting baseline by running `poetry run black --check scripts tests` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-python-format.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with a pass-fail signal.

- [x] [P0-T4] Capture Python lint baseline by running `poetry run ruff check scripts tests` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-python-lint.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with either `All checks passed` or a numeric violation count.

- [x] [P0-T5] Capture Python type-check baseline by running `poetry run pyright` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-python-typecheck.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric error and warning counts.

- [x] [P0-T6] Capture Python test-and-coverage baseline by running `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-python-test-coverage.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric passed-failed counts and a numeric coverage headline for the measured Python coverage roots `src` and `scripts/dev_tools`.

- [x] [P0-T7] Capture TypeScript formatting baseline by running `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-typescript-format.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with a pass-fail signal.

- [x] [P0-T8] Capture TypeScript lint baseline by running `npm --prefix extensions/drm-copilot run lint` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-typescript-lint.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with either `All checks passed` or a numeric violation count.

- [x] [P0-T9] Capture TypeScript type-check baseline by running `npm --prefix extensions/drm-copilot run typecheck` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-typescript-typecheck.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric error and warning counts.

- [x] [P0-T10] Capture TypeScript test-and-coverage baseline by running `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-typescript-test-coverage.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric passed-failed counts and a numeric repo-wide coverage headline.

- [x] [P0-T11] Inventory the current repository surface for pre-existing `codex-native-converter` implementation files by running `git grep -n -E "codex_native_converter|codex-native-converter" -- scripts extensions tests README.md docs/features/active/2026-04-26-codex-native-converter-164` and writing the result to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-converter-surface-inventory.md`.
  - Acceptance: the artifact exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` that distinguishes requirement-document hits from implementation-file hits.

- [x] [P0-T12] Run the plan validator gate for the exact plan path by executing `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-04-26-codex-native-converter-164/plan.2026-04-26T18-01.md`. Capture the validator output at `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/phase0-plan-validator.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the exact CLI command exits 0 for `docs/features/active/2026-04-26-codex-native-converter-164/plan.2026-04-26T18-01.md`, the artifact exists, and `Output Summary:` records `validate_orchestration_artifacts: ok`; the plan is not treated as approved until this auditable validator gate passes.

---

### Phase 1 — Requirements Lock and Scope Alignment

- [x] [P1-T1] Update `docs/features/active/2026-04-26-codex-native-converter-164/spec.md` so the `Overview`, `API / CLI Surface`, and `Implementation Strategy` sections explicitly state that v1 includes the Python CLI plus a thin `extensions/drm-copilot/` command and MCP wrapper over the bundled Python runner.
  - Acceptance: `spec.md` contains the exact phrase `The Python CLI is the authoritative converter surface; the TypeScript layer is a thin bundled command and MCP wrapper over the same Python engine.`

- [x] [P1-T2] Update `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md` so the acceptance-criteria and scenario text explicitly mention both review-apply CLI execution and extension-MCP wrapper execution without introducing a second converter implementation.
  - Acceptance: `user-story.md` contains the exact phrase `The extension and MCP entry points invoke the same bundled Python converter contract.`

- [x] [P1-T3] Create `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/p1-requirements-traceability.md` mapping each acceptance criterion in `spec.md` and `user-story.md` to the planned implementation file or test file that will verify it.
  - Acceptance: the artifact exists and includes one row for every acceptance-criteria checkbox item currently present in `spec.md` and `user-story.md`, including both checked and unchecked items, with no unmapped criterion text.

---

### Phase 2 — Python Converter Models, Inventory, and Classification

- [x] [P2-T1] Create `scripts/dev_tools/codex_native_converter/__init__.py` as the package export surface for the converter.
  - Acceptance: the file exists and exports `main` from the CLI entry point.

- [x] [P2-T2] Create `scripts/dev_tools/codex_native_converter/models.py` with typed enums and dataclasses for source ecosystem, source kind, conversion class, target role, mapping records, validation findings, and run options.
  - Acceptance: the file exists and defines `SourceEcosystem`, `SourceKind`, `ConversionClass`, `TargetRole`, `MappingRecord`, `ValidationFinding`, and `RunOptions`.

- [x] [P2-T3] Create `scripts/dev_tools/codex_native_converter/inventory.py` to enumerate supported source artifacts in deterministic normalized-relative-path order and to reject selected paths that escape the declared source root.
  - Acceptance: the file exists and defines `discover_source_artifacts` and `normalize_selected_paths`.

- [x] [P2-T4] Create `scripts/dev_tools/codex_native_converter/classifier.py` to classify GitHub Copilot and Claude source artifacts into `direct`, `decomposed`, `repo-convention`, or `unsupported` plus the target role taxonomy required by `issue.md` and `spec.md`.
  - Acceptance: the file exists and defines `classify_source_artifact`.

- [x] [P2-T5] Create `scripts/dev_tools/codex_native_converter/mapping.py` to resolve approved Codex-native destination paths, including `AGENTS.md`, `.agents/skills/**`, `.codex/agents/**`, `.codex/config.toml`, `.codex/hooks/**`, `.codex/rules/**`, and optional `.codex/prompts/**` when repo prompts are enabled.
  - Acceptance: the file exists and defines `plan_target_paths`.

- [x] [P2-T6] Create `scripts/dev_tools/codex_native_converter/rewrites.py` to centralize semantic MCP rewrites toward `drmCopilotExtension` and to flag unsupported host-specific automation references that cannot be rewritten safely.
  - Acceptance: the file exists and defines `rewrite_supported_automation_reference` and `detect_unresolved_runtime_reference`.

---

### Phase 3 — Python Validation, Reporting, and CLI Orchestration

- [x] [P3-T1] Create `scripts/dev_tools/codex_native_converter/validation.py` to enforce blocking failure categories for unsupported ecosystems, malformed artifacts, unresolved hard-gate mappings, unresolved handoff mappings, unresolved MCP rewrites, duplicate target paths, lingering source-runtime references, and missing required inputs.
  - Acceptance: the file exists and defines `validate_conversion_plan`.

- [x] [P3-T2] Create `scripts/dev_tools/codex_native_converter/reporting.py` to write `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and `proposed-tree/` into the selected artifact root using deterministic ordering.
  - Acceptance: the file exists and defines `write_conversion_report_set`.

- [x] [P3-T3] Create `scripts/dev_tools/codex_native_converter/engine.py` to orchestrate inventory, classification, mapping, rewrite application, validation, report generation, review-mode non-mutation, and apply-mode destination writes.
  - Acceptance: the file exists and defines `run_review_mode` and `run_apply_mode`.

- [x] [P3-T4] Create `scripts/dev_tools/codex_native_converter/cli.py` with Typer commands `review` and `apply`, explicit required-option validation, and stdout lines that report the artifact root and validation outcome.
  - Acceptance: the file exists and defines a Typer app that exposes `review` and `apply` commands.

- [x] [P3-T5] Create `scripts/dev_tools/codex_native_converter/__main__.py` so `python -m scripts.dev_tools.codex_native_converter` delegates to the Typer CLI.
  - Acceptance: the file exists and imports `main` from `cli.py`.

- [x] [P3-T6] Update `pyproject.toml` to expose a console-script entry for the converter.
  - Acceptance: `pyproject.toml` contains a script entry whose command target is `scripts.dev_tools.codex_native_converter.cli:main`.

---

### Phase 4 — Python Fixtures and Scenario-Specific Tests

- [x] [P4-T1] Create `tests/fixtures/codex_native_converter/github_copilot/` as a representative GitHub Copilot source tree fixture that includes standing instructions, path-scoped instructions, skills, agents, and launcher prompts.
  - Acceptance: the fixture directory exists and contains at least one example under `.github/copilot-instructions.md`, `.github/instructions/`, `.github/skills/`, `.github/agents/`, and `.github/prompts/`.

- [x] [P4-T2] Create `tests/fixtures/codex_native_converter/claude/` as a representative Claude source tree fixture that includes `CLAUDE.md`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`, `.claude/settings.json`, and `.claude/rules/`.
  - Acceptance: the fixture directory exists and contains at least one example under each listed surface.

- [x] [P4-T3] Add `tests/scripts/dev_tools/codex_native_converter/test_inventory.py` scenario `test_discover_source_artifacts_returns_deterministic_relative_path_order`.
  - Acceptance: the test file exists and contains the exact test function name `test_discover_source_artifacts_returns_deterministic_relative_path_order`.

- [x] [P4-T4] Add `tests/scripts/dev_tools/codex_native_converter/test_inventory.py` scenario `test_normalize_selected_paths_rejects_paths_outside_source_root`.
  - Acceptance: the test file contains the exact test function name `test_normalize_selected_paths_rejects_paths_outside_source_root`.

- [x] [P4-T5] Add `tests/scripts/dev_tools/codex_native_converter/test_classifier.py` scenario `test_classify_github_copilot_surfaces_maps_supported_items_to_expected_conversion_classes`.
  - Acceptance: the test file exists and contains the exact test function name `test_classify_github_copilot_surfaces_maps_supported_items_to_expected_conversion_classes`.

- [x] [P4-T6] Add `tests/scripts/dev_tools/codex_native_converter/test_classifier.py` scenario `test_classify_claude_surfaces_marks_rules_and_unverified_handoffs_as_expected`.
  - Acceptance: the test file contains the exact test function name `test_classify_claude_surfaces_marks_rules_and_unverified_handoffs_as_expected`.

- [x] [P4-T7] Add `tests/scripts/dev_tools/codex_native_converter/test_mapping.py` scenario `test_plan_target_paths_leaves_launcher_prompts_unsupported_when_repo_prompts_disabled`.
  - Acceptance: the test file exists and contains the exact test function name `test_plan_target_paths_leaves_launcher_prompts_unsupported_when_repo_prompts_disabled`.

- [x] [P4-T8] Add `tests/scripts/dev_tools/codex_native_converter/test_mapping.py` scenario `test_plan_target_paths_emits_codex_prompts_when_repo_prompts_enabled`.
  - Acceptance: the test file contains the exact test function name `test_plan_target_paths_emits_codex_prompts_when_repo_prompts_enabled`.

- [x] [P4-T9] Add `tests/scripts/dev_tools/codex_native_converter/test_validation.py` scenario `test_validate_conversion_plan_blocks_unresolved_hard_gate_handoff_and_mcp_failures`.
  - Acceptance: the test file exists and contains the exact test function name `test_validate_conversion_plan_blocks_unresolved_hard_gate_handoff_and_mcp_failures`.

- [x] [P4-T10] Add `tests/scripts/dev_tools/codex_native_converter/test_validation.py` scenario `test_validate_conversion_plan_blocks_duplicate_targets_and_lingering_source_runtime_references`.
  - Acceptance: the test file contains the exact test function name `test_validate_conversion_plan_blocks_duplicate_targets_and_lingering_source_runtime_references`.

- [x] [P4-T11] Add `tests/scripts/dev_tools/codex_native_converter/test_cli_review.py` scenario `test_review_mode_writes_required_artifacts_without_destination_mutation`.
  - Acceptance: the test file exists and contains the exact test function name `test_review_mode_writes_required_artifacts_without_destination_mutation`.

- [x] [P4-T12] Add `tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py` scenario `test_apply_mode_requires_destination_root_and_writes_outputs_plus_report_artifacts`.
  - Acceptance: the test file exists and contains the exact test function name `test_apply_mode_requires_destination_root_and_writes_outputs_plus_report_artifacts`.

- [x] [P4-T13] Add `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py` scenario `test_github_copilot_fixture_review_run_produces_required_report_set`.
  - Acceptance: the test file exists and contains the exact test function name `test_github_copilot_fixture_review_run_produces_required_report_set`.

- [x] [P4-T14] Add `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py` scenario `test_claude_fixture_review_run_surfaces_unsupported_constructs_without_dropping_them`.
  - Acceptance: the test file contains the exact test function name `test_claude_fixture_review_run_surfaces_unsupported_constructs_without_dropping_them`.

---

### Phase 5 — TypeScript Bundled Runner, Service Layer, and MCP Wiring

- [x] [P5-T1] Create `extensions/drm-copilot/resources/templates/codex_native_converter.py` as the bundled Python runner that imports and executes the converter from the packaged extension resources.
  - Acceptance: the file exists and imports the Python converter entry point from the bundled `dev_tools` path.

- [x] [P5-T2] Update `extensions/drm-copilot/src/repo-automation-tool-names.ts` to add the semantic tool name `run_codex_native_converter`.
  - Acceptance: the file contains the exact string literal `run_codex_native_converter`.

- [x] [P5-T3] Update `extensions/drm-copilot/src/repo-automation-service.ts` to add `runCodexNativeConverter` as a thin wrapper over the bundled Python runner, including review-apply arguments and artifact-path parsing.
  - Acceptance: the file defines `runCodexNativeConverter`.

- [x] [P5-T4] Update `extensions/drm-copilot/src/mcp-tool-definitions.ts` to add the input schema for `run_codex_native_converter`, including mode, source ecosystem, source root, selected paths, destination root, artifact root, and repo-prompts enablement.
  - Acceptance: the file contains a tool definition whose `name` field is `run_codex_native_converter`.

- [x] [P5-T5] Update `extensions/drm-copilot/src/mcp-tool-inputs.ts` to add typed normalization and validation for the converter tool input.
  - Acceptance: the file defines `resolveRunCodexNativeConverterToolInput`.

- [x] [P5-T6] Create `extensions/drm-copilot/src/mcp-handlers/codex-native-converter-handlers.ts` to forward normalized tool input to the shared repo-automation service.
  - Acceptance: the file exists and defines `handleRunCodexNativeConverter`.

- [x] [P5-T7] Update `extensions/drm-copilot/src/mcp-tools.ts` to dispatch `run_codex_native_converter` through the new handler.
  - Acceptance: the file contains a dispatch case for `run_codex_native_converter`.

- [x] [P5-T8] Update `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/package.json` to register the VS Code command `drmCopilotExtension.runCodexNativeConverter`.
  - Acceptance: `package.json` contains the exact command identifier `drmCopilotExtension.runCodexNativeConverter`, and `extension.ts` registers a command handler for it.

---

### Phase 6 — TypeScript Tests and User-Facing Documentation

- [x] [P6-T1] Add `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` scenario `it("builds bundled codex-native-converter argv and summary")`.
  - Acceptance: the test file exists and contains the exact test name `builds bundled codex-native-converter argv and summary`.

- [x] [P6-T2] Add `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` scenario `it("returns the artifact path parsed from codex-native-converter stdout")`.
  - Acceptance: the test file contains the exact test name `returns the artifact path parsed from codex-native-converter stdout`.

- [x] [P6-T3] Add `extensions/drm-copilot/test/mcp-tool-inputs.codex-native-converter.test.ts` scenario `it("normalizes review-mode converter input without requiring destination_root")`.
  - Acceptance: the test file exists and contains the exact test name `normalizes review-mode converter input without requiring destination_root`.

- [x] [P6-T4] Add `extensions/drm-copilot/test/mcp-tool-inputs.codex-native-converter.test.ts` scenario `it("rejects apply-mode converter input when destination_root or source_ecosystem is invalid")`.
  - Acceptance: the test file contains the exact test name `rejects apply-mode converter input when destination_root or source_ecosystem is invalid`.

- [x] [P6-T5] Add `extensions/drm-copilot/test/codex-native-converter-handlers.test.ts` scenario `it("forwards normalized converter input to the repo automation service")`.
  - Acceptance: the test file exists and contains the exact test name `forwards normalized converter input to the repo automation service`.

- [x] [P6-T6] Add `extensions/drm-copilot/test/mcp-tools.codex-native-converter.test.ts` scenario `it("dispatches run_codex_native_converter through the dedicated handler")`.
  - Acceptance: the test file exists and contains the exact test name `dispatches run_codex_native_converter through the dedicated handler`.

- [x] [P6-T7] Add a discoverability assertion to the extension test suite that verifies `run_codex_native_converter` appears in the MCP tool list and `drmCopilotExtension.runCodexNativeConverter` appears in the command contributions.
  - Acceptance: the existing extension test suite contains one assertion for the MCP tool name and one assertion for the command identifier.

- [x] [P6-T8] Update `README.md` with a `codex-native-converter` section that documents Python review-apply commands, artifact outputs, and the fail-closed validation model.
  - Acceptance: `README.md` contains the exact heading `## Codex-native converter`.

- [x] [P6-T9] Update `extensions/drm-copilot/README.md` with the new command and semantic MCP tool contract for the converter wrapper.
  - Acceptance: `extensions/drm-copilot/README.md` contains the exact strings `drmCopilotExtension.runCodexNativeConverter` and `run_codex_native_converter`.

---

### Phase 7 — Final QC, Coverage Delta, Acceptance-Criteria Checkoff, and Review Prep

- [x] [P7-T1] Run the Python formatter on the final touched Python files with `poetry run black scripts tests` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-format.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if the formatter changes files, rerun P7-T1 through P7-T5 from the start.

- [x] [P7-T2] Run Python lint on the final touched Python files with `poetry run ruff check scripts tests` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-lint.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step fails, rerun P7-T1 through P7-T5 from the start after the fix.

- [x] [P7-T3] Run Python type checking with `poetry run pyright` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-typecheck.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step fails, rerun P7-T1 through P7-T5 from the start after the fix.

- [x] [P7-T4] Run Python repo-wide tests with coverage using `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-test-coverage.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric passed-failed counts and a numeric coverage headline for the measured Python coverage roots `src` and `scripts/dev_tools`; if this step fails, rerun P7-T1 through P7-T5 from the start after the fix.

- [x] [P7-T5] Run targeted Python coverage for the new converter package using `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-targeted-coverage.md`.
  - Acceptance: the artifact exists and `Output Summary:` reports numeric coverage for `scripts.dev_tools.codex_native_converter`.

- [x] [P7-T6] Run the TypeScript formatter on the extension workspace with `npm --prefix extensions/drm-copilot run format` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-format.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if the formatter changes files, rerun P7-T6 through P7-T9 from the start.

- [x] [P7-T7] Run TypeScript lint on the extension workspace with `npm --prefix extensions/drm-copilot run lint` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-lint.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step fails, rerun P7-T6 through P7-T9 from the start after the fix.

- [x] [P7-T8] Run TypeScript type checking on the extension workspace with `npm --prefix extensions/drm-copilot run typecheck` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-typecheck.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; if this step fails, rerun P7-T6 through P7-T9 from the start after the fix.

- [x] [P7-T9] Run TypeScript unit tests with coverage using `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and write evidence to `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-test-coverage.md`.
  - Acceptance: the artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric passed-failed counts, a numeric extension-wide coverage headline, and numeric line-coverage values for each changed TypeScript source file touched in Phase 5 (`src/repo-automation-tool-names.ts`, `src/repo-automation-service.ts`, `src/mcp-tool-definitions.ts`, `src/mcp-tool-inputs.ts`, `src/mcp-handlers/codex-native-converter-handlers.ts`, `src/mcp-tools.ts`, and `src/extension.ts`); if this step fails, rerun P7-T6 through P7-T9 from the start after the fix.

- [x] [P7-T10] Compute Python coverage delta and threshold verification. Compare Python baseline coverage from `phase0-python-test-coverage.md`, post-change coverage from `final-python-test-coverage.md`, and new-or-changed Python coverage from `final-python-targeted-coverage.md`. Write `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-coverage-delta.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric baseline coverage, numeric post-change coverage, numeric new-or-changed-code coverage, and a PASS/FAIL threshold verdict.
  - Acceptance: the artifact exists, includes all four required schema fields, and `Output Summary:` records non-placeholder numeric values for Python baseline coverage, Python post-change coverage, and Python new-or-changed-code coverage.

- [x] [P7-T11] Compute TypeScript coverage delta and threshold verification. Compare TypeScript baseline coverage from `phase0-typescript-test-coverage.md`, post-change coverage from `final-typescript-test-coverage.md`, and new-or-changed TypeScript coverage from the changed-file figures recorded in `final-typescript-test-coverage.md`. Write `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-typescript-coverage-delta.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric baseline coverage, numeric post-change coverage, numeric new-or-changed-code coverage, and a PASS/FAIL threshold verdict.
  - Acceptance: the artifact exists, includes all four required schema fields, and `Output Summary:` records non-placeholder numeric values for TypeScript baseline coverage, TypeScript post-change coverage, and TypeScript new-or-changed-code coverage.

- [x] [P7-T12] Write `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-coverage-delta.md` summarizing the recorded results from `final-python-coverage-delta.md` and `final-typescript-coverage-delta.md`.
  - Acceptance: the artifact exists and `Output Summary:` cites both per-language delta artifacts and summarizes their recorded numeric baseline, post-change, and new-or-changed-code coverage values plus their final verdicts.

- [x] [P7-T13] Check off delivered acceptance criteria in `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`.
  - Acceptance: only `- [ ]` to `- [x]` transitions are made for criteria verified by Phase 7 evidence, and no criterion text is modified.

- [x] [P7-T14] Check off delivered acceptance criteria in `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md`.
  - Acceptance: only `- [ ]` to `- [x]` transitions are made for criteria verified by Phase 7 evidence, and no criterion text is modified.

- [x] [P7-T15] Create `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/post-implementation-review-prep.md` summarizing changed files, report-artifact paths, final QA artifact paths, remaining unsupported mappings, and reviewer focus areas.
  - Acceptance: the artifact exists and contains the exact section headings `## Changed Files`, `## Evidence Index`, `## Remaining Unsupported Mappings`, and `## Reviewer Focus Areas`.

## Test Scope Summary

- **Python unit coverage:** inventory ordering, selected-path validation, source classification, target mapping, runtime-reference rewrites, validation failure categories, report generation, review mode, apply mode.
- **Python end-to-end coverage:** one GitHub Copilot fixture and one Claude fixture through the real review pipeline.
- **TypeScript unit coverage:** repo-automation service argument construction, MCP input normalization, handler forwarding, dispatcher registration, command and MCP discoverability.
- **Coverage evidence artifacts:**
  - Baseline: `evidence/baseline/phase0-python-test-coverage.md`, `evidence/baseline/phase0-typescript-test-coverage.md`
  - Final: `evidence/qa-gates/final-python-test-coverage.md`, `evidence/qa-gates/final-python-targeted-coverage.md`, `evidence/qa-gates/final-python-coverage-delta.md`, `evidence/qa-gates/final-typescript-test-coverage.md`, `evidence/qa-gates/final-typescript-coverage-delta.md`, `evidence/qa-gates/final-coverage-delta.md`

## Execution Assumptions

- Preflight must preserve the scope lock that v1 includes both the Python converter engine and the thin TypeScript extension-MCP wrapper. Do not drop the TypeScript phases unless `spec.md` and `user-story.md` are updated first and the plan is revalidated.
- The converter must fail closed for unresolved hard-gate mappings, unresolved handoff mappings, unresolved MCP rewrites, duplicate target paths, and lingering `.github`, `.claude`, or `CLAUDE.md` runtime references.
- `.codex/prompts/**` remains a repository-convention output only; it is never emitted unless the explicit repo-prompts option is enabled.

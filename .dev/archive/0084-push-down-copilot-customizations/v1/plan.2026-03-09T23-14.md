# 2026-03-09-push-down-copilot-customizations - Plan

- **Issue:** #84
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-09T23-14
- **Status:** Planned
- **Version:** 0.2
- **Work Mode:** full
- **Target Plan Path:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84/plan.2026-03-09T23-14.md`
- **Preflight Route:** `python-atomic-planning -> atomic_planner -> atomic_executor`

## Overview

Implement a new one-way Python push-down tool that copies the scoped `.github` customization trees into a destination workspace, rewrites verified script references to extension command references, and records deterministic summary artifacts. Keep `scripts/dev_tools/agentic_sync.py` on its existing two-way contract while extending the VS Code extension with placeholder commands for uncovered referenced scripts that fail with stable not-implemented errors.

## Requirements Sources

- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/user-story.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/spec.md`
- `artifacts/research/20260309-push-down-copilot-customizations-implementation-research.md`

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Evidence

- [x] [P0-T1] Record the selected work mode from `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md` in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-mode-source.2026-03-09T23-14.md`.
  - Acceptance: The evidence file exists and contains exact lines `Work Mode Source: issue.md` and `Resolved Work Mode: full`.

- [x] [P0-T2] Record policy-read evidence in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-instructions-read.2026-03-09T23-14.md` for these files in exact order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, and `AGENTS.md`.
  - Acceptance: The evidence file exists and contains `Timestamp:`, `Policy Order:`, and every listed path in the exact order above.

- [x] [P0-T3] Record a requirements map in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/phase0-requirements-map.2026-03-09T23-14.md` using `issue.md`, `user-story.md`, `spec.md`, and `artifacts/research/20260309-push-down-copilot-customizations-implementation-research.md`.
  - Acceptance: The mapping file exists and includes the exact requirement strings `overwrite same-path files`, `rewrite supported script references`, `placeholder command references`, `deterministic not-implemented error`, `preserve current scripts/dev_tools/agentic_sync.py two-way sync behavior`, and `unmatched references left unchanged and reported`.

- [x] [P0-T4] Capture the TypeScript baseline formatting state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-format.2026-03-09T23-14.md` by running `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture the TypeScript baseline lint state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-lint.2026-03-09T23-14.md` by running `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture the TypeScript baseline type-check state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-typecheck.2026-03-09T23-14.md` by running `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Capture the TypeScript baseline unit-test state for the extension package in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/ts-test-unit.2026-03-09T23-14.md` by running `npm --prefix extensions/drm-copilot run test:unit`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Capture the Python baseline formatting state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-format.2026-03-09T23-14.md` by running `poetry run black --check .`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Capture the Python baseline lint state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-lint.2026-03-09T23-14.md` by running `poetry run ruff check`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T10] Capture the Python baseline type-check state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-typecheck.2026-03-09T23-14.md` by running `poetry run pyright`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T11] Capture the Python baseline test-and-coverage state in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/baseline/py-test-cov.2026-03-09T23-14.md` by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — TDD Red Scenarios & Contract Guards

- [x] [P1-T1] [expect-fail] Add `test_main_rejects_invalid_destination_before_copy` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_main_rejects_invalid_destination_before_copy"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t1-invalid-destination.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the invalid-destination scenario.

- [x] [P1-T2] [expect-fail] Add `test_push_down_copies_scoped_github_trees_to_empty_destination` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_copies_scoped_github_trees_to_empty_destination"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t2-empty-destination-copy.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the empty-destination copy scenario.

- [x] [P1-T3] [expect-fail] Add `test_push_down_overwrites_existing_destination_file` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_overwrites_existing_destination_file"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t3-overwrite-existing-file.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the overwrite scenario.

- [x] [P1-T4] [expect-fail] Add `test_rewrite_known_pr_context_reference_to_collect_pr_context_command` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_known_pr_context_reference_to_collect_pr_context_command"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t4-pr-context-rewrite.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the implemented-command rewrite scenario.

- [x] [P1-T5] [expect-fail] Add `test_rewrite_new_active_feature_folder_reference_to_placeholder_command` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_new_active_feature_folder_reference_to_placeholder_command"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t5-placeholder-rewrite.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the placeholder rewrite scenario.

- [x] [P1-T6] [expect-fail] Add `test_rewrite_normalizes_dev_tools_slash_variants` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_normalizes_dev_tools_slash_variants"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t6-slash-normalization.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the slash-normalization scenario.

- [x] [P1-T7] [expect-fail] Add `test_push_down_reports_unmatched_script_references_without_rewrite` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_reports_unmatched_script_references_without_rewrite"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t7-unmatched-reference-reporting.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the unmatched-reference scenario.

- [x] [P1-T8] Add `test_sync_repos_ignores_files_missing_on_one_side` to `tests/scripts/dev_tools/test_agentic_sync.py` to lock down the existing two-way sync contract.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k "test_sync_repos_ignores_files_missing_on_one_side"` exits `0`.

- [x] [P1-T9] [expect-fail] Add `registers push-down placeholder commands` to `extensions/drm-copilot/test/extension.placeholder-commands.test.ts`.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.placeholder-commands.test.ts -t "registers push-down placeholder commands"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t9-placeholder-registration.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing-command-registration scenario.

- [x] [P1-T10] [expect-fail] Add `placeholder command throws deterministic not implemented error` to `extensions/drm-copilot/test/extension.placeholder-commands.test.ts`.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.placeholder-commands.test.ts -t "placeholder command throws deterministic not implemented error"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t10-placeholder-error.2026-03-09T23-14.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the placeholder-error scenario.
  - Reconciliation Note: Historical fail-before evidence was not captured during the original implementation; see `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t10-placeholder-error-replacement-note.2026-03-09T23-14.md` for the audited replacement note recorded during remediation.

### Phase 2 — Python Push-Down Tool Implementation

- [x] [P2-T1] Create `scripts/dev_tools/push_down_copilot_customizations.py` with typed dataclasses, typed helper functions, and CLI argument parsing that imports `ROOT_FOLDERS` from `scripts.dev_tools.agentic_sync` rather than editing `agentic_sync.py`.
  - Acceptance: The file exists and contains the exact symbol names `ROOT_FOLDERS`, `PushDownSummary`, and `parse_args`.

- [x] [P2-T2] Implement destination validation in `scripts/dev_tools/push_down_copilot_customizations.py` so missing paths, the source repository root, and non-directory destinations fail before any copy action begins.
  - Acceptance: The file contains a dedicated validation helper that raises `ValueError` before invoking the copy engine when the destination is unusable.

- [x] [P2-T3] Implement the rewrite catalog and canonical textual reference renderer in `scripts/dev_tools/push_down_copilot_customizations.py` for `drmCopilotExtension.collectPrContext`, `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, `drmCopilotExtension.potentialToIssuePlaceholder`, `drmCopilotExtension.newPotentialBugEntryPyPlaceholder`, and `drmCopilotExtension.newPotentialEntryPsPlaceholder`.
  - Acceptance: The file contains all five exact command IDs plus the exact text fragments `VS Code command:` and `command ID:`.

- [x] [P2-T4] Implement anchored text-reference normalization and rewrite helpers in `scripts/dev_tools/push_down_copilot_customizations.py` so `scripts.dev_tools.*`, `scripts/dev_tools/*`, and `scripts/dev-tools/*` patterns normalize before catalog lookup.
  - Acceptance: The file contains one helper responsible for normalization before lookup and one helper responsible for applying replacements only to matched references.

- [x] [P2-T5] Implement deterministic source-file enumeration in `scripts/dev_tools/push_down_copilot_customizations.py` so files are processed in root order defined by `ROOT_FOLDERS` and then by relative path.
  - Acceptance: The file contains one helper that returns files ordered first by scoped root and then by sorted relative path.

- [x] [P2-T6] Implement overwrite-copy behavior in `scripts/dev_tools/push_down_copilot_customizations.py` so missing destination directories are created and same-path files are classified as created or overwritten.
  - Acceptance: The file contains explicit created-versus-overwritten result tracking and path creation before writes.

- [x] [P2-T7] Implement unmatched-reference tracking and JSON summary artifact writing in `scripts/dev_tools/push_down_copilot_customizations.py` under `artifacts/copilot-customizations/`.
  - Acceptance: The file contains the exact artifact directory literal `artifacts/copilot-customizations` and records unmatched references separately from applied rewrites.

- [x] [P2-T8] Wire `main()` in `scripts/dev_tools/push_down_copilot_customizations.py` to run validation, rewrite, copy, and summary-artifact emission with deterministic exit handling.
  - Acceptance: The file contains the exact CLI invocation path fragment `scripts.dev_tools.push_down_copilot_customizations` and prints the summary artifact path on success.

### Phase 3 — Extension Placeholder Command Exposure

- [x] [P3-T1] Add placeholder command contributions to `extensions/drm-copilot/package.json` for `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, `drmCopilotExtension.potentialToIssuePlaceholder`, `drmCopilotExtension.newPotentialBugEntryPyPlaceholder`, and `drmCopilotExtension.newPotentialEntryPsPlaceholder`.
  - Acceptance: `extensions/drm-copilot/package.json` contains all four exact command IDs under `contributes.commands`.

- [x] [P3-T2] Add a placeholder command catalog in `extensions/drm-copilot/src/extension.ts` that maps each placeholder command ID to its original script reference and display title.
  - Acceptance: `extensions/drm-copilot/src/extension.ts` contains the exact script references `scripts.dev_tools.new_active_feature_folder`, `scripts.dev_tools.potential_to_issue`, `scripts/dev_tools/new_potential_bug_entry.py`, and `scripts/dev-tools/new-potential-entry.ps1`.

- [x] [P3-T3] Add a placeholder command registration helper to `extensions/drm-copilot/src/extension.ts` and register all placeholder commands inside `activate()` without changing the existing `drmCopilotExtension.collectPrContext` command ID.
  - Acceptance: `extensions/drm-copilot/src/extension.ts` still contains `drmCopilotExtension.collectPrContext` and also contains all four placeholder command IDs in `activate()` registration flow.

- [x] [P3-T4] Implement the deterministic placeholder failure message in `extensions/drm-copilot/src/extension.ts` as `Not implemented: <commandId> is a placeholder for <script reference>.`.
  - Acceptance: `extensions/drm-copilot/src/extension.ts` contains the exact text fragment `Not implemented:` and the exact text fragment `is a placeholder for` in the placeholder handler.

### Phase 4 — Green Scenario Verification & Usage Documentation

- [x] [P4-T1] Make `test_main_rejects_invalid_destination_before_copy` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_main_rejects_invalid_destination_before_copy"` exits `0`.

- [x] [P4-T2] Make `test_push_down_copies_scoped_github_trees_to_empty_destination` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_copies_scoped_github_trees_to_empty_destination"` exits `0`.

- [x] [P4-T3] Make `test_push_down_overwrites_existing_destination_file` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_overwrites_existing_destination_file"` exits `0`.

- [x] [P4-T4] Make `test_rewrite_known_pr_context_reference_to_collect_pr_context_command` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_known_pr_context_reference_to_collect_pr_context_command"` exits `0`.

- [x] [P4-T5] Make `test_rewrite_new_active_feature_folder_reference_to_placeholder_command` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_new_active_feature_folder_reference_to_placeholder_command"` exits `0`.

- [x] [P4-T6] Make `test_rewrite_normalizes_dev_tools_slash_variants` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_normalizes_dev_tools_slash_variants"` exits `0`.

- [x] [P4-T7] Make `test_push_down_reports_unmatched_script_references_without_rewrite` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_push_down_reports_unmatched_script_references_without_rewrite"` exits `0`.

- [x] [P4-T8] Make `test_sync_repos_ignores_files_missing_on_one_side` pass.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_agentic_sync.py -k "test_sync_repos_ignores_files_missing_on_one_side"` exits `0`.

- [x] [P4-T9] Make `registers push-down placeholder commands` pass.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.placeholder-commands.test.ts -t "registers push-down placeholder commands"` exits `0`.

- [x] [P4-T10] Make `placeholder command throws deterministic not implemented error` pass.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.placeholder-commands.test.ts -t "placeholder command throws deterministic not implemented error"` exits `0`.

- [x] [P4-T11] Update `README.md` with the new push-down CLI invocation and the placeholder command contract.
  - Acceptance: `README.md` contains the exact command `poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination` and the exact command ID `drmCopilotExtension.newActiveFeatureFolderPlaceholder`.

### Phase 5 — Final QA Loop & Coverage Gates

- [x] [P5-T1] Run the final TypeScript formatting step for the extension package and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-format.2026-03-09T23-14.md` using `npm --prefix extensions/drm-copilot run format`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P5-T2] Run the final TypeScript lint step for the extension package and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-lint.2026-03-09T23-14.md` using `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T3] Run the final TypeScript type-check step for the extension package and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-typecheck.2026-03-09T23-14.md` using `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T4] Run the final TypeScript unit-test step for the extension package and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-test-unit.2026-03-09T23-14.md` using `npm --prefix extensions/drm-copilot run test:unit`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T5] Run the final Python formatting step and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-format.2026-03-09T23-14.md` using `poetry run black .`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P5-T6] Run the final Python lint step and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-lint.2026-03-09T23-14.md` using `poetry run ruff check`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T7] Run the final Python type-check step and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-typecheck.2026-03-09T23-14.md` using `poetry run pyright`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T8] Run the final Python coverage-test step and save command-step evidence to `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-test-cov.2026-03-09T23-14.md` using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Acceptance: The evidence file contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P5-T9] Repeat the TypeScript and Python QA loops until one clean end-to-end pass completes without formatter-induced file changes and record the final pass manifest in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/qa-loop-summary.2026-03-09T23-14.md`.
  - Acceptance: The summary file exists and lists the exact evidence files used for the final clean pass for [P5-T1] through [P5-T8], plus rerun counts for the TypeScript loop and the Python loop.

- [x] [P5-T10] Record the Python coverage delta and TypeScript coverage note in `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/coverage-delta.2026-03-09T23-14.md`.
  - Acceptance: The delta file contains numeric `Python Baseline Coverage:`, numeric `Python Final Coverage:`, an explicit no-regression statement for Python coverage, and the exact note `TypeScript unit-test command emits no repo-standard numeric coverage artifact.`.

## Acceptance Criteria Traceability

- AC1 (copy scoped `.github` trees into destination workspace): P1-T2, P2-T5, P2-T6, P4-T2
- AC2 (overwrite same-path destination files): P1-T3, P2-T6, P4-T3
- AC3 (rewrite implemented script references to packaged extension commands): P1-T4, P2-T3, P2-T4, P4-T4
- AC4 (rewrite uncovered references to placeholder commands with deterministic failure): P1-T5, P1-T9, P1-T10, P3-T1, P3-T2, P3-T3, P3-T4, P4-T5, P4-T9, P4-T10
- AC5 (preserve current `agentic_sync.py` two-way behavior): P1-T8, P2-T1, P4-T8
- AC6 (normalize `scripts/dev_tools` and `scripts/dev-tools` references to the same catalog target): P1-T6, P2-T4, P4-T6
- AC7 (leave unknown references unchanged and report them): P1-T7, P2-T7, P4-T7
- AC8 (invalid destination fails before partial copy begins): P1-T1, P2-T2, P2-T8, P4-T1
- AC9 (automated Python + extension coverage for changed behavior): P0-T4 through P0-T11, P1-T1 through P1-T10, P4-T1 through P4-T10, P5-T1 through P5-T10

## Executor Preflight Requirement (Validate-Only)

Use this exact handoff directive for preflight validation before execution:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required terminal signal before implementation handoff:

`PREFLIGHT: ALL CLEAR`

## Preflight Checklist

- [x] Phase headings follow the canonical `### Phase N — <Title>` format.
- [x] Task IDs are sequential and phase-aligned.
- [x] No placeholder text remains.
- [x] Phase 0 includes policy reads, requirement capture, and baseline evidence.
- [x] TDD red tasks are scenario-specific and every `[expect-fail]` task includes a regression-testing evidence artifact.
- [x] Final QA covers both TypeScript and Python surfaces in toolchain order.
- [x] Python baseline and final test tasks capture numeric coverage evidence.
- [x] The plan preserves the requested path and does not require sibling timestamped plans.

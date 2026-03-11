---
title: Atomic Plan — Feature #84 Push Down Copilot Customizations (v2 Remaining Scope)
feature: 2026-03-09-push-down-copilot-customizations
issue: 84
parent: none
owner: drmoisan
last_updated: 2026-03-10T20-38
status: Complete
status_color: green
version: v2
work_mode: full
mode_source: issue.md marker: full
plan_path: docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/plan.2026-03-10T20-38.md
preflight_route: atomic_planner -> atomic_executor
---

# Atomic Plan — Feature #84 Push Down Copilot Customizations (v2 Remaining Scope)

## Overview

This plan delivers only the remaining unchecked requirements from `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md` and `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/user-story.md`. The remaining scope is the real extension-side push-down command, the real-command rewrite for `scripts.dev_tools.push_down_copilot_customizations`, the packaged source/artifact split needed for bundled execution, the missing automated coverage, and the related documentation updates.

**Status Badge:** ![Status: Complete](https://img.shields.io/badge/status-Complete-green)

## Mode Resolution

- Selected work mode: `full`
- Resolution rule: `issue.md` marker first, fail closed to `full` when the marker is missing or malformed.
- Applied outcome for this plan: feature-root `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md` contains `- Work Mode: full`, so this plan uses `full` mode.

## Requirements in Scope

| ID | Requirement | Source |
| --- | --- | --- |
| REQ-001 | Contribute and register a real extension command `drmCopilotExtension.pushDownCopilotCustomizations` that executes a bundled push-down publisher through the same extension-side runtime/script-launch path used for PR-context collection. | `v2/user-story.md` AC2, `v2/spec.md` Behavior + API / CLI Surface |
| REQ-002 | Rewrite copied references to `scripts.dev_tools.push_down_copilot_customizations` to a real textual extension-command reference while retaining the existing real-command rewrite for `scripts.dev_tools.pr_context.collector`. | `v2/user-story.md` AC4, `v2/spec.md` Behavior + API / CLI Surface |
| REQ-003 | Make bundled push-down execution functional by reading customization source files from packaged extension resources while writing output artifacts and copied files into the destination workspace. | `v2/spec.md` Behavior + Inputs / Outputs + Data & State |
| REQ-004 | Extend automated coverage with Python tests for the remaining publisher behavior and TypeScript tests for push-down command contribution, bundled wrapper execution, destination argument propagation, continued PR-context bundled execution, and placeholder deterministic failure behavior. | `v2/user-story.md` AC10, `v2/spec.md` Definition of Done + Seeded Test Conditions |
| REQ-005 | Update extension-facing documentation and active feature documentation to show the real push-down command usage and the rewritten textual command-reference contract. | `v2/spec.md` Definition of Done + CLI/API examples |
| REQ-006 | Capture baseline evidence, targeted regression evidence, and a full final QA loop for Python and TypeScript with required artifact fields and Python coverage values. | `atomic-plan-contract`, `evidence-and-timestamp-conventions`, repo toolchain policies |

## Constraints

| ID | Constraint |
| --- | --- |
| CON-001 | Keep already-checked acceptance criteria out of implementation scope unless they are needed as regression verification for the remaining work. |
| CON-002 | Preserve the existing CLI contract `poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <workspace-root>` for source-repo execution. |
| CON-003 | Keep unit tests deterministic and in-memory; do not create temporary files. |
| SEC-001 | Keep extension subprocess launches on explicit executable + argv arrays with `shell: false`; do not introduce shell-concatenated command strings. |
| SEC-002 | Keep placeholder command failures deterministic and preserve the existing not-implemented error format for placeholder-only commands. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline
- [x] [P0-T1] Record policy-read evidence at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/phase0-instructions-read.2026-03-10T20-38.md` after reading these files in exact order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, and `AGENTS.md`.
  - Acceptance: The evidence file exists and contains `Timestamp:`, `Policy Order:`, and each listed file path in the exact order above.

- [x] [P0-T2] Record mode-resolution evidence at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/phase0-mode-source.2026-03-10T20-38.md` using the feature-root `issue.md` marker.
  - Acceptance: The evidence file exists and contains exact lines `Mode Source: issue.md marker`, `Marker Value: full`, and `Resolved Work Mode: full`.

- [x] [P0-T3] Record the remaining unchecked requirement map from `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md` and `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/user-story.md` at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/phase0-remaining-requirements.2026-03-10T20-38.md`.
  - Acceptance: The evidence file exists and includes the exact strings `drmCopilotExtension.pushDownCopilotCustomizations`, `scripts.dev_tools.push_down_copilot_customizations`, `bundled copy of scripts.dev_tools.push_down_copilot_customizations`, `continued packaged-path execution of PR-context collection`, and `placeholder-command failure paths`.

- [x] [P0-T4] Capture TypeScript baseline formatting evidence by running `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/ts-format.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture TypeScript baseline lint evidence by running `npm --prefix extensions/drm-copilot run lint` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/ts-lint.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture TypeScript baseline type-check evidence by running `npm --prefix extensions/drm-copilot run typecheck` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/ts-typecheck.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Capture TypeScript baseline test-and-coverage evidence by running `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/ts-test-unit.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text`, `EXIT_CODE:`, and `Output Summary:` with numeric TypeScript coverage headline values.

- [x] [P0-T8] Capture Python baseline formatting evidence by running `poetry run black --check .` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/py-format.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Capture Python baseline lint evidence by running `poetry run ruff check` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/py-lint.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T10] Capture Python baseline type-check evidence by running `poetry run pyright` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/py-typecheck.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T11] Capture Python baseline test-and-coverage evidence by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/baseline/py-test-cov.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — TDD Red for Remaining Scenarios
- [x] [P1-T1] [expect-fail] Add `test_rewrite_known_push_down_reference_to_real_command` to `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` for the scenario where `rewrite_text_references()` receives `scripts.dev_tools.push_down_copilot_customizations` and must emit `drmCopilotExtension.pushDownCopilotCustomizations`.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_known_push_down_reference_to_real_command"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t1-push-down-rewrite-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing real-command rewrite.

- [x] [P1-T2] [expect-fail] Add `test_push_down_customizations_reads_from_explicit_source_root` to `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` for the scenario where `push_down_customizations()` must enumerate `.github` content from a packaged source root that differs from the destination workspace root.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "test_push_down_customizations_reads_from_explicit_source_root"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t2-explicit-source-root-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing explicit source-root behavior.

- [x] [P1-T3] [expect-fail] Add `test_push_down_customizations_writes_summary_artifact_under_explicit_artifact_root` to `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` for the scenario where bundled execution must write `artifacts/copilot-customizations` under the destination workspace instead of the packaged source root.
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "test_push_down_customizations_writes_summary_artifact_under_explicit_artifact_root"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t3-explicit-artifact-root-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing explicit artifact-root behavior.

- [x] [P1-T4] [expect-fail] Add `it("registers pushDownCopilotCustomizations")` to `extensions/drm-copilot/test/extension.test.ts` for the scenario where `activate()` must register `drmCopilotExtension.pushDownCopilotCustomizations`.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.test.ts -t "registers pushDownCopilotCustomizations"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t4-extension-registration-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing command registration.

- [x] [P1-T5] [expect-fail] Add `it("pushDownCopilotCustomizations executes bundled wrapper script in workspace")` to `extensions/drm-copilot/test/extension.integration.test.ts` for the scenario where the real push-down command must execute `resources/templates/push_down_copilot_customizations.py` from the extension install path.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.integration.test.ts -t "pushDownCopilotCustomizations executes bundled wrapper script in workspace"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t5-bundled-wrapper-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing bundled wrapper execution.

- [x] [P1-T6] [expect-fail] Add `it("pushDownCopilotCustomizations passes workspace root as --destination")` to `extensions/drm-copilot/test/extension.integration.test.ts` for the scenario where the handler must forward the open workspace path as the exact `--destination` argument.
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.integration.test.ts -t "pushDownCopilotCustomizations passes workspace root as --destination"` exits non-zero and evidence is saved at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p1-t6-destination-arg-red.2026-03-10T20-38.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failure excerpt attributable to the missing `--destination` argument propagation.

### Phase 2 — Python Publisher Refactor and Bundled Payload
- [x] [P2-T1] Add a `source_root: Path` parameter to `enumerate_source_files()` and `push_down_customizations()` in `scripts/dev_tools/push_down_copilot_customizations.py`, and make the module bundled-import compatible so extension-packaged execution can enumerate packaged `.github` content without treating the destination workspace as the source tree.
  - Depends on: [P1-T2].
  - Acceptance: The function signatures contain the exact parameter name `source_root`, the copy loop computes `relative_path` from `source_root` instead of the current `repo_root` variable, and the bundled publisher no longer requires repo-only import paths beginning with `scripts.dev_tools` at runtime.

- [x] [P2-T2] Add an `artifact_root: Path` parameter to `build_artifact_path()`, `write_summary_artifact()`, and `push_down_customizations()` in `scripts/dev_tools/push_down_copilot_customizations.py` so bundled execution writes `artifacts/copilot-customizations` under the destination workspace.
  - Depends on: [P1-T3].
  - Acceptance: `build_artifact_path()` accepts the exact parameter name `artifact_root`, and the returned path is rooted at that parameter instead of the source-content root.

- [x] [P2-T3] Preserve the source-repo CLI contract in `scripts/dev_tools/push_down_copilot_customizations.py` by keeping `parse_args()` limited to the required `--destination` flag and making `main()` call `push_down_customizations()` with identical values for `source_root` and `artifact_root` during repo-local execution.
  - Depends on: [P2-T1], [P2-T2].
  - Acceptance: `parse_args()` still requires only `--destination`, and `main()` passes the same resolved repo path into both `source_root` and `artifact_root`.

- [x] [P2-T4] Add a non-placeholder rewrite target for `scripts.dev_tools.push_down_copilot_customizations` to `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` using command ID `drmCopilotExtension.pushDownCopilotCustomizations` and title `drm-copilot: Push Down Copilot Customizations`.
  - Depends on: [P1-T1].
  - Acceptance: `build_rewrite_catalog()` contains the exact normalized key `scripts.dev_tools.push_down_copilot_customizations`, the exact command ID `drmCopilotExtension.pushDownCopilotCustomizations`, the exact title `drm-copilot: Push Down Copilot Customizations`, and `is_placeholder=False`.

- [x] [P2-T5] Copy `scripts/dev_tools/push_down_copilot_customizations.py`, `scripts/dev_tools/push_down_copilot_customizations_filesystem.py`, `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`, and every remaining runtime Python dependency required by the bundled publisher into `extensions/drm-copilot/resources/scripts/dev_tools/`, or remove the dependency from the bundled publisher before packaging.
  - Depends on: [P2-T1], [P2-T2], [P2-T4].
  - Acceptance: The files `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations.py`, `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py`, and `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` all exist, and every module imported at runtime by the bundled publisher exists under `extensions/drm-copilot/resources/scripts/dev_tools/` or has been removed from the bundled publisher.

- [x] [P2-T6] Create `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py` as a bundled wrapper that prepends `extensions/drm-copilot/resources/scripts` to `sys.path`, imports `dev_tools.push_down_copilot_customizations`, resolves `source_root` to `extensions/drm-copilot/resources/customizations`, resolves `artifact_root` to `Path.cwd()`, and executes the bundled publisher in-process with `destination_root=Path(args.destination)`.
  - Depends on: [P2-T5].
  - Acceptance: The wrapper file exists and contains the exact strings `resources/scripts`, `dev_tools.push_down_copilot_customizations`, `resources/customizations`, `artifact_root`, and `--destination`.

- [x] [P2-T7] Bundle the source customization payload under `extensions/drm-copilot/resources/customizations/.github/` by copying the repo trees `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into the same relative structure.
  - Depends on: [P2-T6].
  - Acceptance: The directories `extensions/drm-copilot/resources/customizations/.github/agents`, `extensions/drm-copilot/resources/customizations/.github/instructions`, `extensions/drm-copilot/resources/customizations/.github/prompts`, and `extensions/drm-copilot/resources/customizations/.github/skills` all exist.

### Phase 3 — Extension Command Contribution and Registration
- [x] [P3-T1] Add the command contribution `drmCopilotExtension.pushDownCopilotCustomizations` with title `drm-copilot: Push Down Copilot Customizations` to `extensions/drm-copilot/package.json`.
  - Depends on: [P1-T4].
  - Acceptance: `extensions/drm-copilot/package.json` contains an entry under `contributes.commands` with exact values `"command": "drmCopilotExtension.pushDownCopilotCustomizations"` and `"title": "drm-copilot: Push Down Copilot Customizations"`.

- [x] [P3-T2] Add a dedicated `pushDownCopilotCustomizationsDisposable` handler to `extensions/drm-copilot/src/extension.ts` that calls `executeBundledScript(context, output, spec)` with `runtimeKind: "python"`, `commandId: "drmCopilotExtension.pushDownCopilotCustomizations"`, and `bundledRelativePath: "resources/templates/push_down_copilot_customizations.py"`.
  - Depends on: [P1-T5], [P2-T6].
  - Acceptance: `extensions/drm-copilot/src/extension.ts` contains the exact identifier `pushDownCopilotCustomizationsDisposable`, the exact command ID `drmCopilotExtension.pushDownCopilotCustomizations`, and the exact bundled path `resources/templates/push_down_copilot_customizations.py`.

- [x] [P3-T3] Pass the open workspace root as the exact `--destination` argument in the new push-down command handler inside `extensions/drm-copilot/src/extension.ts`.
  - Depends on: [P1-T6], [P3-T2].
  - Acceptance: The new command spec contains the exact argument pair `"--destination"` followed by `workspaceRoot`.

- [x] [P3-T4] Register `pushDownCopilotCustomizationsDisposable` inside `activate()` in `extensions/drm-copilot/src/extension.ts` without changing the existing `collectPrContext` registration or `registerPlaceholderCommands(output)` call.
  - Depends on: [P3-T2], [P3-T3].
  - Acceptance: `activate()` pushes `pushDownCopilotCustomizationsDisposable` into `context.subscriptions`, still pushes `collectPrContextDisposable`, and still spreads `...placeholderDisposables`.

### Phase 4 — Green Verification and Documentation
- [x] [P4-T1] Make `test_rewrite_known_push_down_reference_to_real_command` pass in `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.
  - Depends on: [P2-T4].
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_known_push_down_reference_to_real_command"` exits `0`.

- [x] [P4-T2] Make `test_push_down_customizations_reads_from_explicit_source_root` pass in `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`.
  - Depends on: [P2-T1], [P2-T7].
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "test_push_down_customizations_reads_from_explicit_source_root"` exits `0`.

- [x] [P4-T3] Make `test_push_down_customizations_writes_summary_artifact_under_explicit_artifact_root` pass in `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`.
  - Depends on: [P2-T2], [P2-T6].
  - Acceptance: Command `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py -k "test_push_down_customizations_writes_summary_artifact_under_explicit_artifact_root"` exits `0`.

- [x] [P4-T4] Make `registers pushDownCopilotCustomizations` pass in `extensions/drm-copilot/test/extension.test.ts`.
  - Depends on: [P3-T1], [P3-T4].
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.test.ts -t "registers pushDownCopilotCustomizations"` exits `0`.

- [x] [P4-T5] Make `pushDownCopilotCustomizations executes bundled wrapper script in workspace` pass in `extensions/drm-copilot/test/extension.integration.test.ts`.
  - Depends on: [P3-T2], [P3-T4].
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.integration.test.ts -t "pushDownCopilotCustomizations executes bundled wrapper script in workspace"` exits `0`.

- [x] [P4-T6] Make `pushDownCopilotCustomizations passes workspace root as --destination` pass in `extensions/drm-copilot/test/extension.integration.test.ts`.
  - Depends on: [P3-T3].
  - Acceptance: Command `npm --prefix extensions/drm-copilot exec -- jest test/extension.integration.test.ts -t "pushDownCopilotCustomizations passes workspace root as --destination"` exits `0`.

- [x] [P4-T7] Verify the existing packaged PR-context execution path remains green by running `npm --prefix extensions/drm-copilot exec -- jest test/extension.collect-pr-context.test.ts -t "collectPrContext executes bundled wrapper script"` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p4-t7-pr-context-green.2026-03-10T20-38.md`.
  - Acceptance: The command exits `0`, and the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the passing PR-context bundled-wrapper scenario.

- [x] [P4-T8] Verify the existing placeholder deterministic failure path remains green by running `npm --prefix extensions/drm-copilot exec -- jest test/extension.placeholder-commands.test.ts -t "placeholder command throws deterministic not implemented error"` and writing `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p4-t8-placeholder-green.2026-03-10T20-38.md`.
  - Acceptance: The command exits `0`, and the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the passing placeholder deterministic-error scenario.

- [x] [P4-T9] Run the targeted Python push-down regression suite with `poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p4-t9-python-push-down-green.2026-03-10T20-38.md`.
  - Acceptance: The command exits `0`, and the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the push-down rewrite, explicit source-root, and explicit artifact-root scenarios.

- [x] [P4-T10] Run the targeted extension command regression suite with `npm --prefix extensions/drm-copilot exec -- jest test/extension.test.ts test/extension.integration.test.ts test/extension.collect-pr-context.test.ts test/extension.placeholder-commands.test.ts` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/regression-testing/p4-t10-extension-command-green.2026-03-10T20-38.md`.
  - Acceptance: The command exits `0`, and the artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming push-down registration, push-down bundled execution, PR-context bundled execution, and placeholder deterministic-failure coverage.

- [x] [P4-T11] Update `extensions/drm-copilot/README.md` with the real command ID `drmCopilotExtension.pushDownCopilotCustomizations`, the destination-workspace execution model, and the rewritten textual command-reference format for real versus placeholder commands.
  - Acceptance: `extensions/drm-copilot/README.md` contains the exact strings `drmCopilotExtension.pushDownCopilotCustomizations`, `drm-copilot: Push Down Copilot Customizations`, and `VS Code command:`.

- [x] [P4-T12] Update `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md` so the `API / CLI Surface` section includes the real push-down extension command example and the bundled-source-to-destination-workspace behavior.
  - Acceptance: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md` contains the exact strings `drmCopilotExtension.pushDownCopilotCustomizations`, `resources/templates/push_down_copilot_customizations.py`, and `--destination`.

### Phase 5 — Final QA Loop
- [x] [P5-T1] Run final TypeScript formatting with `npm --prefix extensions/drm-copilot run format` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/ts-format.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T2] Run final TypeScript lint with `npm --prefix extensions/drm-copilot run lint` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/ts-lint.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T3] Run final TypeScript type-check with `npm --prefix extensions/drm-copilot run typecheck` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/ts-typecheck.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T4] Run final TypeScript tests with coverage using `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/ts-test-unit.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change TypeScript coverage headline values.

- [x] [P5-T5] Run final Python formatting with `poetry run black .` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/py-format.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T6] Run final Python lint with `poetry run ruff check` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/py-lint.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T7] Run final Python type-check with `poetry run pyright` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/py-typecheck.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T8] Run final Python tests with coverage using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and write `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/py-test-cov.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P5-T9] Record QA-loop restart compliance at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/qa-loop-summary.2026-03-10T20-38.md` after rerunning the TypeScript and Python loops from the formatting step whenever any command changes files or fails.
  - Acceptance: The summary artifact exists and contains the exact strings `TypeScript Loop Final Pass: clean`, `Python Loop Final Pass: clean`, and `Restart Rule Applied:`.

- [x] [P5-T10] Record coverage and regression deltas at `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/evidence/qa-gates/coverage-delta.2026-03-10T20-38.md`.
  - Acceptance: The artifact contains numeric `Python Baseline Coverage:`, numeric `Python Final Coverage:`, numeric `Python New/Changed-Code Coverage:`, explicit `Python Coverage Regression: none`, numeric `TypeScript Baseline Coverage:`, numeric `TypeScript Final Coverage:`, numeric `TypeScript New/Changed-Code Coverage:`, and explicit `TypeScript Coverage Regression: none`.

## Requirements Traceability

| Requirement ID | Covered By |
| --- | --- |
| REQ-001 | P1-T4, P1-T5, P1-T6, P3-T1, P3-T2, P3-T3, P3-T4, P4-T4, P4-T5, P4-T6 |
| REQ-002 | P1-T1, P2-T4, P4-T1, P4-T10 |
| REQ-003 | P1-T2, P1-T3, P2-T1, P2-T2, P2-T3, P2-T5, P2-T6, P2-T7, P4-T2, P4-T3, P4-T9 |
| REQ-004 | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P1-T6, P4-T7, P4-T8, P4-T9, P4-T10, P5-T4, P5-T8 |
| REQ-005 | P4-T11, P4-T12 |
| REQ-006 | P0-T1, P0-T2, P0-T3, P0-T4, P0-T5, P0-T6, P0-T7, P0-T8, P0-T9, P0-T10, P0-T11, P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P5-T7, P5-T8, P5-T9, P5-T10 |

## Preflight Validation Handoff

Use this exact directive for executor validation:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required completion signal before returning control:

`PREFLIGHT: ALL CLEAR`

## Preflight Checklist

- [x] Phase headings use the canonical `### Phase N — <Title>` format.
- [x] Every atomic task starts with `- [ ] [P#-T#]`.
- [x] The plan contains zero placeholder tokens.
- [x] Phase 0 includes policy-read evidence, mode-resolution evidence, requirements capture, and baseline toolchain evidence.
- [x] All `[expect-fail]` tasks include exact commands and regression-testing evidence artifacts with `Timestamp:`, `Command:`, and `EXIT_CODE:` fields.
- [x] Final QA includes the full TypeScript and Python toolchain loops plus Python coverage evidence.
- [x] Requirement identifiers are closed exactly once in the `Requirements Traceability` table.
- [x] The authoritative target plan path is preserved in place with no sibling plan file creation.

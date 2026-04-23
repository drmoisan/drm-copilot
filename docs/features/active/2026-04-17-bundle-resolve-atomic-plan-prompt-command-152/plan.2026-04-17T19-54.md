# Atomic Plan — Feature #152 Resolve Atomic Plan Prompt Command

## Overview
This plan adds one additive VS Code command, `drmCopilotExtension.resolveAtomicPlanPrompt`, that resolves the bundled atomic-plan prompt against the active feature plan markdown file and copies the resolved prompt to the clipboard. Scope is limited to the new command surface, the eligible-plan selection helper, the repo-automation service seam, the bundled Python wrapper and resolver resources needed for destination-workspace execution, and directly related TypeScript and Python tests; existing command behavior and the repository-local `Dev: Resolve Atomic Plan Prompt` task remain unchanged.

Planned command surface:
- VS Code command: `drmCopilotExtension.resolveAtomicPlanPrompt`
- Bundled wrapper: `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py`
- Bundled resolver module: `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py`
- Bundled prompt template: `extensions/drm-copilot/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md`

### Phase 0 — Compliance and Baseline Capture
- [x] [P0-T1] Read policy and requirement files in the required order and persist evidence at `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/phase0-instructions-read.2026-04-17T19-54.md`.
  - Acceptance: Evidence file exists and contains `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, `Resolved Work Mode: full-feature`, and an explicit ordered list of files read: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/issue.md`, `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/spec.md`, `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/user-story.md`, `artifacts/research/20260417-bundle-resolve-atomic-plan-prompt-command-research.md`, and `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md`.

- [x] [P0-T2] Record the current task-to-command inventory at `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/other/command-inventory.2026-04-17T19-54.md` by running `rg -n "Resolve Atomic Plan Prompt|resolveExecuteHardLockPrompt|promptForActiveFeaturePlan|resolve_file_prompt\\.py|generate-atomic-plan\\.prompt\\.md" .vscode/tasks.json extensions/drm-copilot/src extensions/drm-copilot/resources extensions/drm-copilot/test tests`.
  - Acceptance: Artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; categorizes matches as `repo-task baseline`, `active-plan helper`, `existing bundled command pattern`, `bundled resolver asset`, or `test baseline`; and states that scope is limited to the new additive command equivalent plus directly related tests.

- [x] [P0-T3] Capture the TypeScript baseline formatting result by running `npm run format` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/ts-format.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture the TypeScript baseline lint result by running `npm run lint` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/ts-lint.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture the TypeScript baseline type-check result by running `npm run typecheck` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/ts-typecheck.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture the TypeScript baseline unit-test and coverage result by running `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/ts-test-unit.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values.

- [x] [P0-T7] Capture the Python baseline formatting result by running `poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` from the workspace root and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/py-black.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Capture the Python baseline lint result by running `poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` from the workspace root and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/py-ruff.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Capture the Python baseline type-check result by running `poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` from the workspace root and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/py-pyright.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T10] Capture the Python baseline regression-and-coverage result by running `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q` from the workspace root and write `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/baseline/py-pytest.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values.

### Phase 1 — Constrain Eligible Plan Selection
- [x] [P1-T1] Update `extensions/drm-copilot/src/extension-command-helpers.ts` so `getActiveFeaturePlanPath` accepts only markdown files under `docs/features/active/**` whose basename starts with `plan`.
  - Acceptance: Active `plan.md` and timestamped `plan.*.md` files remain eligible, while active `issue.md`, `spec.md`, `user-story.md`, and other non-plan markdown files return `undefined`.

- [x] [P1-T2] Update `extensions/drm-copilot/src/extension-command-helpers.ts` so `promptForActiveFeaturePlan` validates picker selections against the same `plan*.md` rule and throws a clear error that names `docs/features/active/**/plan*.md` when the selected file is ineligible.
  - Acceptance: A picker-selected non-plan markdown file never reaches the repo-automation service, and the thrown error message states that the command requires an active or selected plan markdown file under `docs/features/active/`.

- [x] [P1-T3] Add a helper regression test to `extensions/drm-copilot/test/extension-command-helpers.test.ts` that proves an active `plan.2026-04-17T19-54.md` file under `docs/features/active/**` is accepted.
  - Acceptance: The new test fails when `getActiveFeaturePlanPath` rejects timestamped plan files and passes when `plan*.md` is accepted.

- [x] [P1-T4] Add a helper regression test to `extensions/drm-copilot/test/extension-command-helpers.test.ts` that proves an active `issue.md` file under `docs/features/active/**` is rejected.
  - Acceptance: The new test fails when `issue.md` is treated as a valid plan and passes when it returns `undefined`.

- [x] [P1-T5] Add a helper regression test to `extensions/drm-copilot/test/extension-command-helpers.test.ts` that proves an active `spec.md` file under `docs/features/active/**` is rejected.
  - Acceptance: The new test fails when `spec.md` is treated as a valid plan and passes when it returns `undefined`.

- [x] [P1-T6] Add a helper regression test to `extensions/drm-copilot/test/extension-command-helpers.test.ts` that proves an active `user-story.md` file under `docs/features/active/**` is rejected.
  - Acceptance: The new test fails when `user-story.md` is treated as a valid plan and passes when it returns `undefined`.

- [x] [P1-T7] Add a helper regression test to `extensions/drm-copilot/test/extension-command-helpers.test.ts` that proves a picker-selected non-plan markdown file raises the actionable validation error from `P1-T2`.
  - Acceptance: The new test fails when a picker-selected `spec.md` is allowed through and passes when the helper throws the exact validation message.

### Phase 2 — Bundle the Atomic-Plan Resolver Assets
- [x] [P2-T1] Add `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py` as a bundled wrapper that injects `extensions/drm-copilot/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md` when `--template` is absent and delegates to the bundled resolver module from `resources/scripts`.
  - Acceptance: The wrapper preserves a caller-supplied `--template`, prepends the bundled scripts path before import, and returns the delegated exit code unchanged.

- [x] [P2-T2] Add `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py` as the bundled resolver implementation for the new command without changing `scripts/dev_tools/resolve_file_prompt.py`.
  - Acceptance: The bundled resolver supports the same placeholder substitutions and clipboard behavior required by `.github/prompts/generate-atomic-plan.prompt.md`, including `${file}`, `${folderpath}`, `${name}`, `${spec}`, `${user-story}`, `${research}`, `${work-mode}`, and `${fallback-reason}`.

- [x] [P2-T3] Add `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py` coverage for the wrapper scenario where `--template` is absent and the bundled atomic-plan prompt path is injected.
  - Acceptance: The new test fails when the wrapper omits the bundled prompt path and passes when `sys.argv` contains exactly one injected `--template` argument pointing at the bundled prompt asset.

- [x] [P2-T4] Add `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py` coverage for the wrapper scenario where a caller-supplied `--template` is preserved.
  - Acceptance: The new test fails when the wrapper appends a second template argument and passes when the explicit path remains unchanged.

- [x] [P2-T5] Add `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py` coverage for the wrapper scenario where the delegated bundled resolver returns a non-zero exit code.
  - Acceptance: The new test fails when the wrapper masks the delegated exit status and passes when the wrapper returns the same non-zero code.

- [x] [P2-T6] Add `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py` coverage proving the bundled resolver copy preserves the minor-audit `${work-mode}` substitution behavior.
  - Acceptance: The new test fails when the bundled resolver produces a different `${work-mode}` result than the canonical resolver contract and passes when minor-audit resolves to `minor-audit` with `fallback-reason` preserved.

- [x] [P2-T7] Add `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py` coverage proving the bundled resolver copy removes a `${research}` line when the optional research document is absent.
  - Acceptance: The new test fails when the bundled resolver leaves the `${research}` placeholder line in the output and passes when the entire line is removed.

### Phase 3 — Expose the Bundled Command in the Extension
- [x] [P3-T1] Add the `drmCopilotExtension.resolveAtomicPlanPrompt` command contribution to `extensions/drm-copilot/package.json`.
  - Acceptance: The manifest contributes one new command entry with a stable title and does not modify any existing command ids.

- [x] [P3-T2] Add `resolveAtomicPlanPrompt` to `extensions/drm-copilot/src/repo-automation-service.ts` so the shared service executes `resources/templates/resolve_atomic_plan_prompt.py` with `--target <plan-path>` and `--workspace <workspace-root>`.
  - Acceptance: The service interface and tool union are updated additively, the service summary names the target plan file, and no existing service method behavior changes.

- [x] [P3-T3] Register `drmCopilotExtension.resolveAtomicPlanPrompt` in `extensions/drm-copilot/src/document-workflow-commands.ts` so the command resolves a validated plan path via `promptForActiveFeaturePlan` and delegates to `options.service.resolveAtomicPlanPrompt(...)`.
  - Acceptance: The new command reuses the existing workspace-root lookup and returns early on picker cancellation without invoking the service.

- [x] [P3-T4] Update `extensions/drm-copilot/src/extension.ts` so the document-workflow registration tuple includes the new disposable and existing command registrations remain unchanged.
  - Acceptance: Extension activation subscribes the new disposable exactly once and preserves the existing `resolvePolicyAuditTemplateAsset` and `resolveExecuteHardLockPrompt` registrations.

### Phase 4 — Add Regression Coverage and Targeted Evidence
- [x] [P4-T1] Add a repo-automation service regression test to `extensions/drm-copilot/test/repo-automation-service.test.ts` that proves `resolveAtomicPlanPrompt` executes `resources/templates/resolve_atomic_plan_prompt.py` with the expected `--target` and `--workspace` argument pairs.
  - Acceptance: The new test fails when the wrapper path or argv order is wrong and passes when the service forwards the exact execution contract.

- [x] [P4-T2] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving the command registers `drmCopilotExtension.resolveAtomicPlanPrompt`.
  - Acceptance: The new test fails when activation omits the command and passes when the command handler is present.

- [x] [P4-T3] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving the command reuses an active eligible `plan*.md` file before opening the picker.
  - Acceptance: The new test fails when the picker opens for an active eligible plan and passes when the spawned process receives that active plan path.

- [x] [P4-T4] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving an active `issue.md` file triggers the `docs/features/active` picker instead of service execution.
  - Acceptance: The new test fails when an active `issue.md` is treated as a valid plan and passes when the picker opens with the active-features default path.

- [x] [P4-T5] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving picker cancellation returns without spawning the bundled wrapper.
  - Acceptance: The new test fails when cancellation still spawns a process and passes when no spawn call occurs.

- [x] [P4-T6] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving a missing Python runtime error surfaces to the caller.
  - Acceptance: The new test fails when the command swallows the runtime error and passes when the thrown message names the missing Python runtime.

- [x] [P4-T7] Add `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts` coverage proving a picker-selected `spec.md` file fails with the actionable validation error and does not spawn the bundled wrapper.
  - Acceptance: The new test fails when a selected non-plan markdown file is accepted and passes when the exact validation error from `P1-T2` is thrown before spawn.

- [x] [P4-T8] Run the targeted TypeScript regression suites from `extensions/drm-copilot/` using `node run-jest.cjs --runTestsByPath test/extension-command-helpers.test.ts test/repo-automation-service.test.ts test/extension.resolve-atomic-plan-prompt.test.ts test/extension.test.ts` and persist `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/regression-testing/ts-resolve-atomic-plan-prompt.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the focused TypeScript regression suites that passed.

- [x] [P4-T9] Run the targeted Python regression suites from the workspace root using `poetry run pytest tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt.py tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt_part2.py -q` and persist `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/regression-testing/py-resolve-atomic-plan-prompt.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the focused Python regression suites that passed.

### Phase 5 — Final QA Loop
- [x] [P5-T1] Run the final Python formatting check from the workspace root using `poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-black.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run black --check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE: 0`, and `Output Summary:`; if formatting changes are required, apply them and restart the Python QA loop from `P5-T1`.

- [x] [P5-T2] Run the final Python lint check from the workspace root using `poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-ruff.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run ruff check scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE: 0`, and `Output Summary:`; if linting fails, fix the findings and restart the Python QA loop from `P5-T1`.

- [x] [P5-T3] Run the final Python type-check from the workspace root using `poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-pyright.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pyright scripts tests extensions/drm-copilot/resources/templates extensions/drm-copilot/resources/scripts/dev_tools`, `EXIT_CODE: 0`, and `Output Summary:`; if type-checking fails, fix the findings and restart the Python QA loop from `P5-T1`.

- [x] [P5-T4] Run the final Python coverage-enabled pytest pass from the workspace root using `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-pytest.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values; if tests fail, fix the findings and restart the Python QA loop from `P5-T1`.

- [x] [P5-T5] Record the final Python coverage disposition at `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/py-coverage-summary.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: derived-from-P0-T10-and-P5-T4`, `EXIT_CODE: 0`, and `Output Summary:`; cites the baseline coverage value from `P0-T10`; cites the post-change coverage value from `P5-T4`; states whether coverage regressed; and states `remediation required` rather than `PASS` if changed/new-code coverage cannot be determined deterministically.

- [x] [P5-T6] Run the final TypeScript formatting pass from `extensions/drm-copilot/` using `npm run format` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-format.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`; if formatting changes occur, restart the TypeScript QA loop from `P5-T6`.

- [x] [P5-T7] Run the final TypeScript lint pass from `extensions/drm-copilot/` using `npm run lint` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-lint.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`; if linting fails, fix the findings and restart the TypeScript QA loop from `P5-T6`.

- [x] [P5-T8] Run the final TypeScript type-check pass from `extensions/drm-copilot/` using `npm run typecheck` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-typecheck.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`; if type-checking fails, fix the findings and restart the TypeScript QA loop from `P5-T6`.

- [x] [P5-T9] Run the final TypeScript coverage-enabled unit-test pass from `extensions/drm-copilot/` using `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and capture `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-test-unit.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values; if tests fail, fix the findings and restart the TypeScript QA loop from `P5-T6`.

- [x] [P5-T10] Record the final TypeScript coverage disposition at `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-coverage-summary.2026-04-17T19-54.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: derived-from-P0-T6-and-P5-T9`, `EXIT_CODE: 0`, and `Output Summary:`; cites the baseline coverage value from `P0-T6`; cites the post-change coverage value from `P5-T9`; states whether coverage regressed; and states `remediation required` rather than `PASS` if changed/new-code coverage cannot be determined deterministically.

- [x] [P5-T11] Record the final combined QA loop summary at `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/qa-loop-summary.2026-04-17T19-54.md`.
  - Acceptance: Summary artifact contains `Timestamp:`, `Command: derived-from-P5-T1-through-P5-T10`, `EXIT_CODE: 0`, and `Output Summary:`; records the final clean-pass order `python: black -> ruff -> pyright -> pytest` and `typescript: format -> lint -> typecheck -> test`; cites `P5-T5` and `P5-T10`; records any rerun count; and states that existing public command behavior remained unchanged outside the additive `drmCopilotExtension.resolveAtomicPlanPrompt` surface.

## Acceptance Criteria Traceability
- AC1 (new bundled extension command exists without repo-local task or install dependencies): P0-T2, P2-T1, P2-T2, P3-T1, P3-T2, P3-T3, P3-T4, P4-T1, P4-T2
- AC2 (eligible active plan resolves the bundled prompt and copies it to the clipboard): P1-T1, P1-T2, P2-T1, P2-T2, P2-T6, P2-T7, P3-T2, P3-T3, P4-T3
- AC3 (bundled resources preserve current `resolve_file_prompt.py` semantics in destination workspaces): P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7, P4-T1, P4-T9
- AC4 (missing, cancelled, or invalid plan context fails clearly): P1-T2, P1-T4, P1-T5, P1-T6, P1-T7, P4-T4, P4-T5, P4-T6, P4-T7
- AC5 (extension tests cover registration, target resolution, invalid-target rejection, service invocation, and bundled-resource wiring): P1-T3, P1-T4, P1-T5, P1-T6, P1-T7, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7, P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6, P4-T7, P4-T8, P4-T9

## Preflight Checklist
- [x] Phase headings follow the required `### Phase N — Title` format.
- [x] Task ids are sequential and phase-aligned.
- [x] The plan updates the provided plan path in place and creates no sibling plan files.
- [x] Phase 0 includes explicit policy-read evidence plus baseline command artifacts for every language in scope.
- [x] TypeScript baseline and final QA tasks use coverage-enabled test commands and require numeric coverage evidence.
- [x] The plan keeps scope limited to the new command equivalent, the eligible-plan helper, bundled resolver resources, and directly related tests.
- [x] The plan preserves existing public command behavior by making the new surface additive only.
- [x] Final QA includes full Python and TypeScript toolchain loops with per-command artifacts, coverage summaries, and a clean-pass summary artifact.
- [x] No placeholder tokens or bucket tasks remain.

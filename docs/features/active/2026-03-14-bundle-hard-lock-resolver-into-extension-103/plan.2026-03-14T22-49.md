# 2026-03-14-bundle-hard-lock-resolver-into-extension - Plan

- **Issue:** #103
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T22-49
- **Status:** In Progress
- **Version:** 0.2

## Implementation Plan (Atomic Tasks)

- Requirements sources: `issue.md`, `spec.md`, and `user-story.md` (resolved from `issue.md` work mode `full-feature`)
- Feature folder: `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103`
- Required target plan path: `c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-bundle-hard-lock-resolver-into-extension-103\plan.2026-03-14T22-49.md`
- Preflight status: `ALL CLEAR`
- Execution authorized by user on 2026-03-14
- Revision rule: update this exact plan file in place for every preflight revision; do not create sibling `plan.*.md` files.

### Phase 0 — Context & Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/copilot-instructions.md` in `Files Read:`.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/general-code-change.instructions.md` in `Files Read:`.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/general-unit-test.instructions.md` in `Files Read:`.
- [x] [P0-T4] Read `.github/instructions/python-code-change.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-code-change.instructions.md` in `Files Read:`.
- [x] [P0-T5] Read `.github/instructions/python-unit-test.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-unit-test.instructions.md` in `Files Read:`.
- [x] [P0-T6] Read `.github/instructions/python-suppressions.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/python-suppressions.instructions.md` in `Files Read:`.
- [x] [P0-T7] Read `.github/instructions/self-explanatory-code-commenting.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/self-explanatory-code-commenting.instructions.md` in `Files Read:`.
- [x] [P0-T8] Read `.github/instructions/typescript-code-change.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/typescript-code-change.instructions.md` in `Files Read:`.
- [x] [P0-T9] Read `.github/instructions/typescript-suppressions.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/typescript-suppressions.instructions.md` in `Files Read:`.
- [x] [P0-T10] Read `.github/instructions/typescript-unit-test.instructions.md` and record completion in the Phase 0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and records `.github/instructions/typescript-unit-test.instructions.md` in `Files Read:`.
- [x] [P0-T11] Record the policy-read order, authoritative inputs, resolved work mode, and exact target plan path in `evidence/baseline/phase0-instructions-read.md`
  - Preconditions: `issue.md`, `spec.md`, `user-story.md`, `.github/skills/policy-compliance-order/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, and `.github/skills/evidence-and-timestamp-conventions/SKILL.md` exist.
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, `Files Read:`, `Work Mode: full-feature`, `Requirements Sources: issue.md, spec.md, user-story.md`, and `Target Plan Path: c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-03-14-bundle-hard-lock-resolver-into-extension-103\plan.2026-03-14T22-49.md`.
- [x] [P0-T12] Run `poetry run black .` and store the baseline result in `evidence/baseline/python-black.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/python-black.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T13] Run `poetry run ruff check` and store the baseline result in `evidence/baseline/python-ruff.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/python-ruff.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T14] Run `poetry run pyright` and store the baseline result in `evidence/baseline/python-pyright.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/python-pyright.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T15] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store the baseline result in `evidence/baseline/python-pytest.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/python-pytest.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric total coverage and numeric `scripts/dev_tools/resolve_hard_lock_prompt.py` coverage values.
- [x] [P0-T16] Run `npm --prefix extensions/drm-copilot run format` and store the baseline result in `evidence/baseline/extension-format.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/extension-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T17] Run `npm --prefix extensions/drm-copilot run lint` and store the baseline result in `evidence/baseline/extension-lint.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/extension-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T18] Run `npm --prefix extensions/drm-copilot run typecheck` and store the baseline result in `evidence/baseline/extension-typecheck.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/extension-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T19] Run `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and store the baseline result in `evidence/baseline/extension-jest.<timestamp>.md`
  - Acceptance: a file matching `evidence/baseline/extension-jest.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:` with numeric total coverage and numeric `src/extension.ts` coverage values.

### Phase 1 — Python Regression Coverage

- [x] [P1-T1] [expect-fail] Add pytest case `test_main_prefers_template_root_before_workspace_codex` to `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
  - Acceptance: `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` contains a test named `test_main_prefers_template_root_before_workspace_codex`, and `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_prefers_template_root_before_workspace_codex` fails while writing `evidence/regression-testing/python-template-root-preferred.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_prefers_template_root_before_workspace_codex`, and non-zero `EXIT_CODE:`.
- [x] [P1-T2] [expect-fail] Add pytest case `test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing` to `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
  - Acceptance: `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` contains a test named `test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing`, and `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing` fails while writing `evidence/regression-testing/python-template-root-fallback.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing`, and non-zero `EXIT_CODE:`.
- [x] [P1-T3] [expect-fail] Add pytest case `test_main_reports_checked_template_paths_when_template_lookup_fails` to `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
  - Acceptance: `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` contains a test named `test_main_reports_checked_template_paths_when_template_lookup_fails`, and `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_reports_checked_template_paths_when_template_lookup_fails` fails while writing `evidence/regression-testing/python-template-root-missing.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_reports_checked_template_paths_when_template_lookup_fails`, and non-zero `EXIT_CODE:`.
- [x] [P1-T4] [expect-fail] Create `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` with pytest case `test_main_injects_bundled_template_root_when_flag_is_absent`
  - Acceptance: `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` exists, contains a test named `test_main_injects_bundled_template_root_when_flag_is_absent`, and `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py -k test_main_injects_bundled_template_root_when_flag_is_absent` fails while writing `evidence/regression-testing/python-wrapper-template-root-injection.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py -k test_main_injects_bundled_template_root_when_flag_is_absent`, and non-zero `EXIT_CODE:`.
- [x] [P1-T5] [expect-fail] Add pytest case `test_main_preserves_explicit_template_root_when_wrapper_flag_is_present` to `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py`
  - Acceptance: `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` contains a test named `test_main_preserves_explicit_template_root_when_wrapper_flag_is_present`, and `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py -k test_main_preserves_explicit_template_root_when_wrapper_flag_is_present` fails while writing `evidence/regression-testing/python-wrapper-template-root-preserve.<timestamp>.md` with `Timestamp:`, `Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py -k test_main_preserves_explicit_template_root_when_wrapper_flag_is_present`, and non-zero `EXIT_CODE:`.

### Phase 2 — Resolver Seam & Bundled Resources

- [x] [P2-T1] Add `_resolve_template_path()` to `scripts/dev_tools/resolve_hard_lock_prompt.py` to evaluate bundled-template and workspace-template candidates in deterministic order
  - Acceptance: `scripts/dev_tools/resolve_hard_lock_prompt.py` defines `_resolve_template_path()` and the helper checks `<template-root>/<template-name>` before `<workspace>/.github/codex/<template-name>`.
- [x] [P2-T2] Add the optional `--template-root` CLI argument to `scripts/dev_tools/resolve_hard_lock_prompt.py`
  - Acceptance: `scripts/dev_tools/resolve_hard_lock_prompt.py` adds `parser.add_argument("--template-root", ...)`, and `main()` passes the parsed value into template resolution without changing the existing `--target`, `--workspace`, or `--template-kind` flags.
- [x] [P2-T3] Update the missing-template failure path in `scripts/dev_tools/resolve_hard_lock_prompt.py` to report each checked location
  - Acceptance: the error branch in `scripts/dev_tools/resolve_hard_lock_prompt.py` emits a message that includes the requested template name and every checked template path when no candidate exists.
- [x] [P2-T4] Create `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` as the bundled import-rewritten mirror of the root resolver
  - Acceptance: `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` exists, preserves the root resolver behavior, and imports `prompt_mode_contract` from `dev_tools` rather than `scripts.dev_tools`.
- [x] [P2-T5] Create `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` as the thin wrapper entrypoint
  - Acceptance: `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` exists, defines `_ensure_bundled_scripts_import_path()`, appends `--template-root` only when the flag is absent, and delegates to `dev_tools.resolve_hard_lock_prompt.main()`.
- [x] [P2-T6] Add bundled `execute-hard-lock.prompt.md` to `extensions/drm-copilot/resources/customizations/.github/codex/`
  - Acceptance: `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md` exists and matches `.github/codex/execute-hard-lock.prompt.md` exactly.
- [x] [P2-T7] Add bundled `resume-hard-lock.prompt.md` to `extensions/drm-copilot/resources/customizations/.github/codex/`
  - Acceptance: `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md` exists and matches `.github/codex/resume-hard-lock.prompt.md` exactly.

### Phase 3 — Extension Command Regression Coverage & Wiring

- [x] [P3-T1] [expect-fail] Create `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` with Jest case `registers resolveExecuteHardLockPrompt`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` exists, contains a test whose title includes `registers resolveExecuteHardLockPrompt`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "registers resolveExecuteHardLockPrompt"` fails while writing `evidence/regression-testing/extension-command-register-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "registers resolveExecuteHardLockPrompt"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T2] [expect-fail] Add Jest case `reuses the active feature plan editor before opening the picker` to `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` contains a test whose title includes `reuses the active feature plan editor before opening the picker`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "reuses the active feature plan editor before opening the picker"` fails while writing `evidence/regression-testing/extension-active-plan-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "reuses the active feature plan editor before opening the picker"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T3] [expect-fail] Add Jest case `opens a docs/features/active picker when the active editor is not eligible` to `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` contains a test whose title includes `opens a docs/features/active picker when the active editor is not eligible`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "opens a docs/features/active picker when the active editor is not eligible"` fails while writing `evidence/regression-testing/extension-plan-picker-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "opens a docs/features/active picker when the active editor is not eligible"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T4] [expect-fail] Add Jest case `passes the wrapper path plus --target and --workspace argument pairs` to `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` contains a test whose title includes `passes the wrapper path plus --target and --workspace argument pairs`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "passes the wrapper path plus --target and --workspace argument pairs"` fails while writing `evidence/regression-testing/extension-argv-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "passes the wrapper path plus --target and --workspace argument pairs"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T5] [expect-fail] Add Jest case `returns early when the feature plan picker is cancelled` to `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` contains a test whose title includes `returns early when the feature plan picker is cancelled`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "returns early when the feature plan picker is cancelled"` fails while writing `evidence/regression-testing/extension-picker-cancel-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "returns early when the feature plan picker is cancelled"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T6] [expect-fail] Add Jest case `surfaces a missing python runtime error for resolveExecuteHardLockPrompt` to `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
  - Acceptance: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` contains a test whose title includes `surfaces a missing python runtime error for resolveExecuteHardLockPrompt`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "surfaces a missing python runtime error for resolveExecuteHardLockPrompt"` fails while writing `evidence/regression-testing/extension-python-runtime-red.<timestamp>.md` with `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "surfaces a missing python runtime error for resolveExecuteHardLockPrompt"`, and non-zero `EXIT_CODE:`.
- [x] [P3-T7] Add the `drmCopilotExtension.resolveExecuteHardLockPrompt` command contribution to `extensions/drm-copilot/package.json`
  - Acceptance: `extensions/drm-copilot/package.json` contains a `contributes.commands` entry whose `command` is `drmCopilotExtension.resolveExecuteHardLockPrompt` and whose `title` is `drm-copilot: Resolve Execute Hard-Lock Prompt`.
- [x] [P3-T8] Add an active feature-plan detection helper to `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` defines a helper that returns a path only when the active editor is a Markdown file below `docs/features/active/`.
- [x] [P3-T9] Add a feature-plan picker helper to `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` defines a helper that calls `showOpenDialog(...)` with `defaultUri` rooted under `docs/features/active`, filters to Markdown, and returns `undefined` when the user cancels.
- [x] [P3-T10] Register `drmCopilotExtension.resolveExecuteHardLockPrompt` in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extensions/drm-copilot/src/extension.ts` calls `vscode.commands.registerCommand("drmCopilotExtension.resolveExecuteHardLockPrompt", ...)` and pushes the disposable into `context.subscriptions`.
- [x] [P3-T11] Wire `executeBundledScript(...)` for the new hard-lock command in `extensions/drm-copilot/src/extension.ts`
  - Acceptance: the new handler in `extensions/drm-copilot/src/extension.ts` launches `resources/templates/resolve_hard_lock_prompt.py` with `runtimeKind: "python"`, `--target <selected-plan-path>`, and `--workspace <workspace-root>` only.

### Phase 4 — Green Coverage, Docs & Bundle Parity

- [x] [P4-T1] Add pytest case `test_resolve_prompt_uses_forward_slash_path_for_versioned_windows_style_target` to `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
  - Acceptance: `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` contains a test named `test_resolve_prompt_uses_forward_slash_path_for_versioned_windows_style_target` that asserts a `v2` target path resolves to forward-slash `${plan-path}` output.
- [x] [P4-T2] Update `extensions/drm-copilot/README.md` with the new hard-lock command surface and runtime expectations
  - Acceptance: `extensions/drm-copilot/README.md` mentions `Resolve Execute Hard-Lock Prompt`, describes that the command uses bundled Python resources, and states that a Python runtime must be available on `PATH`.
- [x] [P4-T3] Run `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov-report=term-missing` and store the passing targeted coverage result in `evidence/other/resolve-hard-lock-python-green.<timestamp>.md`
  - Acceptance: a file matching `evidence/other/resolve-hard-lock-python-green.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` naming the resolver and wrapper test files plus numeric `scripts/dev_tools/resolve_hard_lock_prompt.py` coverage, numeric `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` coverage, and numeric `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` coverage values.
- [x] [P4-T4] Run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts` and store the passing targeted result in `evidence/other/resolve-hard-lock-extension-green.<timestamp>.md`
  - Acceptance: a file matching `evidence/other/resolve-hard-lock-extension-green.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts`, `EXIT_CODE: 0`, and `Output Summary:` naming `extension.resolve-hard-lock-prompt.test.ts`.
- [x] [P4-T5] Record bundle parity details in `evidence/qa-gates/resolve-hard-lock-bundle-summary.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/resolve-hard-lock-bundle-summary.*.md` exists and contains the headings `Root Source Files:`, `Bundled Resource Files:`, `Command ID:`, and `Wrapper Path:`.

### Phase 5 — Final QA & Coverage Closure

If any command in this phase changes files or exits non-zero, restart Phase 5 from [P5-T1].

- [x] [P5-T1] Run `poetry run black .` and store the final QA result in `evidence/qa-gates/python-black.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/python-black.*.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T2] Run `poetry run ruff check` and store the final QA result in `evidence/qa-gates/python-ruff.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/python-ruff.*.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T3] Run `poetry run pyright` and store the final QA result in `evidence/qa-gates/python-pyright.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/python-pyright.*.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T4] Run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store the final QA result in `evidence/qa-gates/python-pytest.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/python-pytest.*.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric total coverage and numeric `scripts/dev_tools/resolve_hard_lock_prompt.py` coverage values.
- [x] [P5-T5] Record the baseline-versus-final Python coverage delta and threshold verification in `evidence/qa-gates/python-coverage-delta.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/python-coverage-delta.*.md` exists and uses the revised `[P0-T15]` artifact generated by `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` for `Baseline Total Coverage:` and `Baseline scripts/dev_tools/resolve_hard_lock_prompt.py Coverage:`, uses the revised `[P5-T4]` artifact generated by `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` for `Final Total Coverage:` and `Final scripts/dev_tools/resolve_hard_lock_prompt.py Coverage:`, evaluates `Repository Coverage Threshold (>=80%):` against those `Baseline Total Coverage:` and `Final Total Coverage:` values, uses the `[P4-T3]` targeted coverage artifact for `Final extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py Coverage:`, `Final extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py Coverage:`, and `New/Changed Python Code Coverage:`, and contains `New/Changed Code Threshold (>=90%):`, `No Regression vs Baseline:`, `Threshold Check: PASS or FAIL`, and `No planned command task skipped: true`.
- [x] [P5-T6] Run `npm --prefix extensions/drm-copilot run format` and store the final QA result in `evidence/qa-gates/extension-format.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/extension-format.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T7] Run `npm --prefix extensions/drm-copilot run lint` and store the final QA result in `evidence/qa-gates/extension-lint.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/extension-lint.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T8] Run `npm --prefix extensions/drm-copilot run typecheck` and store the final QA result in `evidence/qa-gates/extension-typecheck.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/extension-typecheck.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T9] Run `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and store the final QA result in `evidence/qa-gates/extension-jest.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/extension-jest.*.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric total coverage and numeric `src/extension.ts` coverage values.
- [x] [P5-T10] Record the baseline-versus-final extension coverage delta and threshold verification in `evidence/qa-gates/extension-coverage-delta.<timestamp>.md`
  - Acceptance: a file matching `evidence/qa-gates/extension-coverage-delta.*.md` exists and uses the `[P0-T19]` baseline artifact for `Baseline Total Coverage:` and `Baseline src/extension.ts Coverage:`, uses the `[P5-T9]` final QA artifact for `Final Total Coverage:`, `Final src/extension.ts Coverage:`, and `New/Changed TypeScript Code Coverage:` (because `src/extension.ts` is the only planned changed production TypeScript file), and contains `Repository Coverage Threshold (>=80%):`, `New/Changed Code Threshold (>=90%):`, `No Regression vs Baseline:`, `Threshold Check: PASS or FAIL`, and `No planned command task skipped: true`.

# Atomic Plan — Bug #82 PR Context Not Bundled Extension-Side

## Overview
This plan fixes Issue #82 by bundling the `pr_context` Python package inside the extension, switching PR context collection to bundled-script execution, and preserving existing branch discovery/QuickPick behavior. The plan is implementation-ready for `python-atomic-executor`, includes baseline and final QA evidence capture, and maps directly to the acceptance criteria in `spec.md`.

### Phase 0 — Baseline Capture
- [x] [P0-T1] Read policy files in required order and persist evidence at `docs/features/active/2026-03-09-pr-context-not-bundled-extension-side-82/evidence/baseline/phase0-instructions-read.2026-03-09T12-00.md`.
  - Preconditions: None.
  - Acceptance: Evidence file exists and contains `Timestamp:`, `Policy Order:`, and explicit list of policy files read in this order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `AGENTS.md`, `docs/features/templates/policy_audit/AGENTS.md`, `drm-copilot/AGENTS.md`, `drm-copilot/docs/features/templates/policy_audit/AGENTS.md`.

- [x] [P0-T2] Capture TypeScript baseline formatting result by running `npm run format` from `extensions/drm-copilot/` and write artifact `evidence/baseline/ts-format.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Capture TypeScript baseline lint result by running `npm run lint` from `extensions/drm-copilot/` and write artifact `evidence/baseline/ts-lint.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture TypeScript baseline type-check result by running `npm run typecheck` from `extensions/drm-copilot/` and write artifact `evidence/baseline/ts-typecheck.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture TypeScript baseline unit-test result by running `npm run test:unit` from `extensions/drm-copilot/` and write artifact `evidence/baseline/ts-test-unit.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture Python baseline formatting result by running `poetry run black --check .` from workspace root and write artifact `evidence/baseline/py-format.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Capture Python baseline lint result by running `poetry run ruff check` from workspace root and write artifact `evidence/baseline/py-lint.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Capture Python baseline type-check result by running `poetry run pyright` from workspace root and write artifact `evidence/baseline/py-typecheck.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Capture Python baseline test-and-coverage result by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` from workspace root and write artifact `evidence/baseline/py-test-cov.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — Bundle PR Context Package
- [x] [P1-T1] Create package marker `extensions/drm-copilot/resources/scripts/dev_tools/__init__.py`.
  - Acceptance: File exists and is empty or minimal package-marker content only.

- [x] [P1-T2] Create package marker `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/__init__.py`.
  - Acceptance: File exists and is empty or minimal package-marker content only.

- [x] [P1-T3] Copy `scripts/dev_tools/pr_context/collector.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/collector.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T4] Copy `scripts/dev_tools/pr_context/feature_docs.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/feature_docs.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T5] Copy `scripts/dev_tools/pr_context/git.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/git.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T6] Copy `scripts/dev_tools/pr_context/github.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/github.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T7] Copy `scripts/dev_tools/pr_context/models.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/models.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T8] Copy `scripts/dev_tools/pr_context/render.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T9] Copy `scripts/dev_tools/pr_context/render_feature_excerpts.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_feature_excerpts.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T10] Copy `scripts/dev_tools/pr_context/render_pr_helpers.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/render_pr_helpers.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T11] Copy `scripts/dev_tools/pr_context/summary_helpers.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/summary_helpers.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T12] Copy `scripts/dev_tools/pr_context/verification_evidence.py` to `extensions/drm-copilot/resources/scripts/dev_tools/pr_context/verification_evidence.py`.
  - Acceptance: Destination file exists and is byte-identical to source at copy time.

- [x] [P1-T13] Verify canonical source package remains unchanged.
  - Acceptance: `scripts/dev_tools/pr_context/` has zero modified files in git status after bundling work.

### Phase 2 — Rewrite Wrapper Script
- [x] [P2-T1] Replace subprocess delegation logic in `extensions/drm-copilot/resources/templates/collect_pr_context.py` with direct in-process execution flow.
  - Acceptance: File no longer imports or calls `subprocess.run` for collector execution.

- [x] [P2-T2] Add deterministic `sys.path` setup in wrapper so bundled `resources/scripts/` is importable at runtime.
  - Acceptance: Wrapper computes extension-relative scripts path from `__file__` and prepends it to `sys.path` when missing.

- [x] [P2-T3] Import `dev_tools.pr_context.collector.main` from bundled package and invoke it as wrapper entrypoint.
  - Acceptance: Wrapper contains direct import-call path and retains executable `if __name__ == "__main__":` behavior.

- [x] [P2-T4] Preserve CLI compatibility for `--base`, `--repo-root`, `--out`, and `--appendix-out` by forwarding unmodified process arguments.
  - Acceptance: Wrapper does not drop or rename these arguments and relies on collector CLI contract unchanged.

### Phase 3 — Update Extension TypeScript
- [x] [P3-T1] Update `collectPrContext` command in `extensions/drm-copilot/src/extension.ts` to call `executeBundledScript` instead of `executePythonModule`.
  - Acceptance: Command registration uses `executeBundledScript(context, output, spec)` for PR-context execution.

- [x] [P3-T2] Set bundled script path to `resources/templates/collect_pr_context.py` in command spec.
  - Acceptance: `bundledRelativePath` exact value is `resources/templates/collect_pr_context.py`.

- [x] [P3-T3] Pass `--repo-root` and workspace root path explicitly in PR-context script args.
  - Acceptance: Spawned argument list includes `--repo-root` followed by workspace path.

- [x] [P3-T4] Preserve `--base`, `--out`, and `--appendix-out` argument semantics and artifact-relative paths.
  - Acceptance: Args still include selected base and artifact outputs `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`.

- [x] [P3-T5] Remove dead code `executePythonModule` function from `extensions/drm-copilot/src/extension.ts`.
  - Acceptance: File contains no `executePythonModule` symbol.

- [x] [P3-T6] Remove dead type `PythonModuleCommandSpec` from `extensions/drm-copilot/src/extension.ts`.
  - Acceptance: File contains no `PythonModuleCommandSpec` type declaration or references.

- [x] [P3-T7] Confirm branch discovery and QuickPick UX paths remain unchanged.
  - Acceptance: Existing branch discovery tests still reference same behavior and pass without behavior-specific rewrites outside execution-path assertions.

### Phase 4 — Update TypeScript Tests
- [x] [P4-T1] Update `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` case `collectPrContext passes base and artifact args` to assert bundled-script execution (not `-m` module execution).
  - Acceptance: Assertions no longer check `-m` or `scripts.dev_tools.pr_context.collector`; they assert bundled script path invocation.

- [x] [P4-T2] Update `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` case `collectPrContext executes canonical package module` to validate bundled wrapper execution pattern.
  - Acceptance: Test asserts first runtime argument is resolved bundled wrapper path and module-mode assertion is removed.

- [x] [P4-T3] Add regression assertion in `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` that `--repo-root` is always present and points to workspace root.
  - Acceptance: Test fails when `--repo-root` is absent or mismatched and passes with explicit workspace-root argument.

- [x] [P4-T4] Update `extensions/drm-copilot/test/extension.integration.test.ts` PR-context execution assertions from module mode to bundled script path.
  - Acceptance: Integration assertions no longer depend on `-m` and verify bundled script path execution.

- [x] [P4-T5] Add or update integration assertion in `extensions/drm-copilot/test/extension.integration.test.ts` to verify `--repo-root` argument propagation.
  - Acceptance: Integration test asserts `--repo-root` followed by expected workspace path value.

- [x] [P4-T6] Add targeted regression test run for PR-context test suites and persist evidence at `evidence/regression-testing/ts-pr-context-regression.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, exact targeted Jest command, `EXIT_CODE: 0`, and `Output Summary:` naming passed PR-context regression cases.

### Phase 5 — Final QA Loop
- [x] [P5-T1] Run final TypeScript formatting from `extensions/drm-copilot/` using `npm run format` and capture artifact `evidence/qa-gates/ts-format.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T2] Run final TypeScript lint from `extensions/drm-copilot/` using `npm run lint` and capture artifact `evidence/qa-gates/ts-lint.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T3] Run final TypeScript type-check from `extensions/drm-copilot/` using `npm run typecheck` and capture artifact `evidence/qa-gates/ts-typecheck.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T4] Run final TypeScript unit tests from `extensions/drm-copilot/` using `npm run test:unit` and capture artifact `evidence/qa-gates/ts-test-unit.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T5] Run final Python formatting from workspace root using `poetry run black --check .` and capture artifact `evidence/qa-gates/py-format.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T6] Run final Python lint from workspace root using `poetry run ruff check` and capture artifact `evidence/qa-gates/py-lint.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T7] Run final Python type-check from workspace root using `poetry run pyright` and capture artifact `evidence/qa-gates/py-typecheck.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T8] Run final Python tests with coverage from workspace root using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and capture artifact `evidence/qa-gates/py-test-cov.2026-03-09T12-00.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage headline values.

- [x] [P5-T9] Enforce QA loop restart policy when any final QA command fails or changes files.
  - Acceptance: `evidence/qa-gates/qa-loop-summary.2026-03-09T12-00.md` exists and records command pass order, rerun count, and final clean-pass confirmation.

- [x] [P5-T10] Record coverage deltas between baseline and final QA artifacts.
  - Acceptance: `evidence/qa-gates/coverage-delta.2026-03-09T12-00.md` exists and includes baseline and final numeric coverage values for Python plus an explicit TypeScript coverage note tied to available command output.

## Acceptance Criteria Traceability
- AC1 (bundled script spawn pattern): P3-T1, P3-T2, P4-T1, P4-T2, P4-T4
- AC2 (bundled import via sys.path): P2-T2, P2-T3
- AC3 (`--repo-root` explicit): P3-T3, P4-T3, P4-T5
- AC4 (workspace-relative artifacts): P3-T4, P4-T1, P4-T4
- AC5 (branch discovery + QuickPick unchanged): P3-T7
- AC6 (TS tests pass with updated assertions): P4-T1 through P4-T6, P5-T4
- AC7 (remove dead module execution code): P3-T5, P3-T6
- AC8 (repro now succeeds): P4-T6, P5-T4, P5-T8
- AC9 (regression tests added and passing): P4-T3, P4-T6

## Preflight Checklist
- [x] Phase headings follow `### Phase N — Title` format.
- [x] Task IDs are sequential and phase-aligned.
- [x] No placeholder tokens remain.
- [x] Code/test changes include Phase 0 baseline capture tasks.
- [x] Final QA phase includes full TS and Python toolchain loops.
- [x] Command-bearing tasks require machine-verifiable artifacts with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.
- [x] Work mode resolved from `issue.md` as `full`.
- [x] Plan path continuity respected at requested target path.

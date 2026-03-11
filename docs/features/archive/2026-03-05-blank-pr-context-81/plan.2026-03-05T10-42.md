# 2026-03-05-blank-pr-context-81 (Atomic Implementation Plan)

- **Issue:** #81
- **Owner:** drmoisan
- **Last Updated:** 2026-03-05T10-42
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full (from `issue.md`)
- **Plan Scope Sources:**
	- `docs/features/active/2026-03-05-blank-pr-context-81/issue.md`
	- `docs/features/active/2026-03-05-blank-pr-context-81/spec.md`
	- `docs/features/active/2026-03-05-blank-pr-context-81/user-story.md`
- **Mandatory Handoff Route:** `python-atomic-planning -> atomic_planner -> atomic_executor`

### Phase 0 — Context, Policy, and Baseline Evidence

- [x] [P0-T1] Create `phase0-instructions-read.md` in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/` with `Timestamp:`, `Policy Order:`, and explicit list of policy files read in required order.
	- Acceptance: File exists at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/phase0-instructions-read.md` and contains all three required headers.

- [x] [P0-T2] Record a requirements snapshot note in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/requirements-snapshot.2026-03-05T10-42.md` that states the active Work Mode and the exact scope boundaries taken from `issue.md`, `spec.md`, and `user-story.md`.
	- Acceptance: Snapshot file exists and includes the exact line `Work Mode Source: issue.md -> full`.

- [x] [P0-T3] Run baseline TypeScript formatter check in extension scope using `cd extensions/scaffold-extension && npm run format` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/ts-format.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: cd extensions/scaffold-extension && npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Run baseline TypeScript lint in extension scope using `cd extensions/scaffold-extension && npm run lint` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/ts-lint.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: cd extensions/scaffold-extension && npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Run baseline TypeScript type-check in extension scope using `cd extensions/scaffold-extension && npm run typecheck` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/ts-typecheck.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: cd extensions/scaffold-extension && npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Run baseline TypeScript unit tests in extension scope using `cd extensions/scaffold-extension && npm run test` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/ts-test.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: cd extensions/scaffold-extension && npm run test`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Run baseline Python formatter using `poetry run black .` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/py-format.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Run baseline Python lint using `poetry run ruff check` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/py-lint.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T9] Run baseline Python type-check using `poetry run pyright` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/py-typecheck.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T10] Run baseline Python coverage tests using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and save one command-step artifact to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/py-test-cov.2026-03-05T10-42.md`.
	- Acceptance: Artifact contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values.

### Phase 1 — Regression Lock (Red) for Blank PR Context

- [x] [P1-T1] [expect-fail] Add a Jest regression scenario in `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts` that asserts summary output is not placeholder-only when the command reports success.
	- Preconditions: `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts` exists.
	- Acceptance: New test name contains `fails_when_summary_is_placeholder_only`.

- [x] [P1-T2] [expect-fail] Run `cd extensions/scaffold-extension && npm run test -- extension.collect-pr-context.test.ts` before the fix and store failing evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/regression-testing/ts-regression-red.2026-03-05T10-42.md`.
	- Acceptance: Evidence includes `Timestamp:`, `Command: cd extensions/scaffold-extension && npm run test -- extension.collect-pr-context.test.ts`, and either a non-zero `EXIT_CODE:` or a `Failure:` excerpt tied to placeholder output.

- [x] [P1-T3] Add an integration assertion in `extensions/scaffold-extension/test/extension.integration.test.ts` requiring non-empty multi-line PR summary and appendix artifacts in destination workspace flow.
	- Acceptance: Integration test file contains an assertion checking line count greater than `1` for both summary and appendix outputs.

### Phase 2 — Minimal Targeted Fix

- [x] [P2-T1] Replace placeholder write logic in `extensions/scaffold-extension/resources/templates/collect_pr_context.py` with canonical PR-context collection/render flow equivalent to the contract in `scripts/dev_tools/pr_context/collector.py`.
	- Acceptance: `collect_pr_context.py` no longer hardcodes placeholder-only summary content.

- [x] [P2-T2] Preserve bundled CLI interface in `extensions/scaffold-extension/resources/templates/collect_pr_context.py` for `--base`, `--out`, and `--appendix-out` without renaming flags.
	- Acceptance: Command-line parser in the bundled script still defines exactly `--base`, `--out`, and `--appendix-out`.

- [x] [P2-T3] Add deterministic error-path handling in `extensions/scaffold-extension/resources/templates/collect_pr_context.py` so unrecoverable git/data failures return non-zero exit and stderr context instead of placeholder success output.
	- Acceptance: Script contains a non-zero exit path for collector failures and writes an error message to stderr.

- [x] [P2-T4] Update extension command test expectations in `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts` so successful flow requires substantive summary and appendix content.
	- Acceptance: Test assertions reject heading-only output for both artifact files.

### Phase 3 — Post-Fix Verification and QA Loop

- [x] [P3-T1] Re-run targeted regression test with `cd extensions/scaffold-extension && npm run test -- extension.collect-pr-context.test.ts` and store pass evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/regression-testing/ts-regression-green.2026-03-05T10-42.md`.
	- Acceptance: Evidence artifact includes `EXIT_CODE: 0` and `Output Summary:` naming the passing regression test.

- [x] [P3-T2] Run final TypeScript formatter using `cd extensions/scaffold-extension && npm run format` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/ts-format.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T3] Run final TypeScript lint using `cd extensions/scaffold-extension && npm run lint` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/ts-lint.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T4] Run final TypeScript type-check using `cd extensions/scaffold-extension && npm run typecheck` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/ts-typecheck.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T5] Run final TypeScript tests using `cd extensions/scaffold-extension && npm run test` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/ts-test.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T6] Run final Python formatter using `poetry run black .` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/py-format.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T7] Run final Python lint using `poetry run ruff check` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/py-lint.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T8] Run final Python type-check using `poetry run pyright` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/py-typecheck.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields and `EXIT_CODE: 0`.

- [x] [P3-T9] Run final Python coverage tests using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store QA evidence at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/py-test-cov.2026-03-05T10-42.md`.
	- Acceptance: QA artifact includes required schema fields, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage values.

- [x] [P3-T10] Create coverage delta report at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/coverage-delta.2026-03-05T10-42.md` comparing baseline and post-change Python coverage percentages.
	- Acceptance: Delta report includes `Baseline Coverage:`, `Post-Change Coverage:`, and `Delta:` numeric lines.

### Phase 4 — Documentation Sync and Preflight Handoff

- [x] [P4-T1] Update `docs/features/active/2026-03-05-blank-pr-context-81/issue.md` with implementation outcome summary and links to regression/QA evidence artifacts.
	- Acceptance: `issue.md` contains a new dated section with at least one `evidence/` path link.

- [x] [P4-T2] Update `docs/features/active/2026-03-05-blank-pr-context-81/spec.md` test-strategy status to list exact passing regression test names and final toolchain command results.
	- Acceptance: `spec.md` contains a concrete list of executed commands and pass outcomes.

- [x] [P4-T3] Produce handoff packet for `atomic_planner` in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/preflight-handoff.2026-03-05T10-42.md` with directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and the exact plan file path.
	- Acceptance: Handoff file contains both `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and `Plan Path: docs/features/active/2026-03-05-blank-pr-context-81/plan.2026-03-05T10-42.md`.

- [ ] [P4-T4] Run preflight validation through `atomic_executor` for this exact plan path and record result at `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/preflight-result.2026-03-05T10-42.md`. (Blocked: atomic_executor preflight returned `RuntimeError: Auto-QC detection found mixed toolchains in phase 3`; see evidence artifact.)
	- Acceptance: Preflight result file contains one exact status line: `PREFLIGHT: ALL CLEAR`.

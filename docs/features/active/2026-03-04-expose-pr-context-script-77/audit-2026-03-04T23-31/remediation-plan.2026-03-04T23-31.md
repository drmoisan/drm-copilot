# remediation-expose-pr-context-script-77 - Plan

- **Issue:** #77
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-03-04T23-31
- **Status:** Planned
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript unit test policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python policy (bundled script scope): [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context, Policy Reads, and Baseline Capture

- [x] [P0-T1] Confirm execution mode from `issue.md` metadata and record it in `evidence/baseline/mode-confirmation.2026-03-04T23-31.md`
	- Acceptance: Artifact file exists and contains `Work Mode: full` plus `Source: issue.md`.

- [x] [P0-T2] Record required policy-read order evidence in `evidence/baseline/phase0-instructions-read.2026-03-04T23-31.md`
	- Acceptance: Artifact file exists and contains `Timestamp:`, `Policy Order:`, and explicit file list including:
		- `.github/copilot-instructions.md`
		- `.github/instructions/general-code-change.instructions.md`
		- `.github/instructions/general-unit-test.instructions.md`
		- `.github/instructions/typescript-code-change.instructions.md`
		- `.github/instructions/typescript-unit-test.instructions.md`
		- `.github/instructions/python-code-change.instructions.md`
		- `.github/instructions/python-unit-test.instructions.md`

- [x] [P0-T3] Create canonical evidence folders under this feature scope
	- Acceptance: Directories exist:
		- `evidence/baseline/`
		- `evidence/regression-testing/`
		- `evidence/qa-gates/`
		- `evidence/other/`

- [x] [P0-T4] Capture root TypeScript formatting baseline using `npm run format:check`
	- Acceptance: `evidence/baseline/root-ts-format-check.2026-03-04T23-31.md` exists and includes `Timestamp:`, `Command: npm run format:check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture extension TypeScript formatting baseline using `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
	- Acceptance: `evidence/baseline/ext-ts-format-check.2026-03-04T23-31.md` exists and includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture extension TypeScript lint baseline using `npm --prefix extensions/scaffold-extension run lint`
	- Acceptance: `evidence/baseline/ext-ts-lint.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P0-T7] Capture extension TypeScript typecheck baseline using `npm --prefix extensions/scaffold-extension run typecheck`
	- Acceptance: `evidence/baseline/ext-ts-typecheck.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P0-T8] Capture extension TypeScript coverage baseline using `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
	- Acceptance: `evidence/baseline/ext-ts-coverage.2026-03-04T23-31.md` exists with required schema fields and `Output Summary:` includes numeric values for statements, branches, functions, and lines.

- [x] [P0-T9] Capture Python formatting baseline for bundled script using `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- Acceptance: `evidence/baseline/python-black-check.collect-pr-context.2026-03-04T23-31.md` exists with required schema fields.

- [x] [P0-T10] Capture Python lint baseline for bundled script using `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- Acceptance: `evidence/baseline/python-ruff.collect-pr-context.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P0-T11] Capture Python typecheck baseline using `poetry run pyright`
	- Acceptance: `evidence/baseline/python-pyright.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P0-T12] Capture Python test+coverage baseline using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
	- Acceptance: `evidence/baseline/python-pytest-coverage.2026-03-04T23-31.md` exists with required schema fields and `Output Summary:` includes numeric total coverage percentage.

### Phase 1 — Blocker Remediation in Source and Tests

- [x] [P1-T1] Reformat `tests/unit/hello-typescript.test.ts` to satisfy root formatting check
	- Acceptance: Running `npm run format:check` no longer reports `tests/unit/hello-typescript.test.ts`.

- [x] [P1-T2] Reformat `extensions/scaffold-extension/package.json` to satisfy extension Prettier check
	- Acceptance: Running `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` no longer reports `package.json`.

- [x] [P1-T3] Reformat `extensions/scaffold-extension/resources/templates/collect_pr_context.py` with Black-compliant layout
	- Acceptance: `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py` exits with code `0`.

- [x] [P1-T4] Split `extensions/scaffold-extension/test/extension.test.ts` into focused modules so each resulting TypeScript test file is `<= 500` lines
	- Acceptance: Line-count evidence file `evidence/other/ts-test-file-line-counts.2026-03-04T23-31.md` exists and lists each extension test file with entries like `Lines: 312`, and every listed value is `<= 500`.

- [x] [P1-T5] Add Jest scenario for `collectPrContext` git branch discovery failure in the split extension test suite
	- Acceptance: Targeted run command `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs -t "collectPrContext git branch discovery failure"` exits with code `0`.

- [x] [P1-T6] Add Jest scenario for `collectPrContext` non-zero collector exit diagnostics in the split extension test suite
	- Acceptance: Targeted run command `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs -t "collectPrContext non-zero collector exit diagnostics"` exits with code `0`.

- [x] [P1-T7] Add integration scenario asserting PR-context artifact output contract in destination workspace context
	- Acceptance: Targeted run command `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs -t "collectPrContext writes summary and appendix artifacts"` exits with code `0`.

### Phase 2 — Coverage Regression and Evidence Remediation

- [x] [P2-T1] Generate post-change extension TypeScript coverage evidence using `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
	- Acceptance: `evidence/qa-gates/ext-ts-coverage.post-remediation.2026-03-04T23-31.md` exists and includes required schema fields plus numeric statements/branches/functions/lines.

- [x] [P2-T2] Produce explicit coverage delta evidence comparing baseline vs post-remediation values
	- Acceptance: `evidence/qa-gates/ts-coverage-delta.2026-03-04T23-31.md` exists and contains all of:
		- `Baseline Statements:` numeric value
		- `Post Statements:` numeric value
		- `Baseline Lines:` numeric value
		- `Post Lines:` numeric value
		- `NewOrChangedCodeCoverage:` numeric value or `NotAvailableWithCurrentTooling` with one-sentence reason
		- `NoRegressionVerdict:` `PASS` or `FAIL`

- [x] [P2-T3] If `NoRegressionVerdict: FAIL`, record remediation-required gate evidence in `evidence/qa-gates/ts-coverage-regression-blocker.2026-03-04T23-31.md`
	- Acceptance: Artifact exists only when verdict is `FAIL` and includes required schema fields plus `BlockingReason:` line.

- [x] [P2-T4] If `NoRegressionVerdict: PASS`, record satisfied gate evidence in `evidence/qa-gates/ts-coverage-regression-clear.2026-03-04T23-31.md`
	- Acceptance: Artifact exists only when verdict is `PASS` and includes required schema fields plus `ClearReason:` line.

### Phase 3 — Plan Checklist and Gate-State Reconciliation

- [x] [P3-T1] Reconcile checkbox states in `docs/features/active/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md` with latest evidence outcomes
	- Acceptance: Every checked item in `plan.2026-03-04T23-07.md` references evidence files that exist and report matching pass/fail state.

- [x] [P3-T2] Record checklist reconciliation audit in `evidence/qa-gates/plan-checklist-reconciliation.2026-03-04T23-31.md`
	- Acceptance: Artifact includes `Timestamp:`, `Command: checklist-state-reconciliation`, `EXIT_CODE: 0`, and `Output Summary:` listing each reconciled checklist section and resulting state.

### Phase 4 — Final QA Loops (Policy Order, No Shortcuts)

- [x] [P4-T1] Run root TypeScript formatting gate: `npm run format:check`
	- Acceptance: `evidence/qa-gates/final.root-ts-format-check.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T2] Run root TypeScript lint gate: `npm run lint`
	- Acceptance: `evidence/qa-gates/final.root-ts-lint.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T3] Run root TypeScript typecheck gate: `npm run typecheck`
	- Acceptance: `evidence/qa-gates/final.root-ts-typecheck.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T4] Run extension TypeScript formatting gate: `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
	- Acceptance: `evidence/qa-gates/final.ext-ts-format-check.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T5] Run extension TypeScript lint gate: `npm --prefix extensions/scaffold-extension run lint`
	- Acceptance: `evidence/qa-gates/final.ext-ts-lint.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T6] Run extension TypeScript typecheck gate: `npm --prefix extensions/scaffold-extension run typecheck`
	- Acceptance: `evidence/qa-gates/final.ext-ts-typecheck.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T7] Run extension TypeScript tests with coverage gate: `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
	- Acceptance: `evidence/qa-gates/final.ext-ts-tests-coverage.2026-03-04T23-31.md` exists with required schema fields, `EXIT_CODE: 0`, and numeric statements/branches/functions/lines in `Output Summary:`.

- [x] [P4-T8] Run Python formatting gate for bundled script: `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- Acceptance: `evidence/qa-gates/final.python-black-check.collect-pr-context.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T9] Run Python lint gate for bundled script: `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- Acceptance: `evidence/qa-gates/final.python-ruff.collect-pr-context.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T10] Run Python typecheck gate: `poetry run pyright`
	- Acceptance: `evidence/qa-gates/final.python-pyright.2026-03-04T23-31.md` exists with required schema fields and `EXIT_CODE: 0`.

- [x] [P4-T11] Run Python tests with coverage gate: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
	- Acceptance: `evidence/qa-gates/final.python-pytest-coverage.2026-03-04T23-31.md` exists with required schema fields, `EXIT_CODE: 0`, and numeric total coverage in `Output Summary:`.

- [x] [P4-T12] Enforce QA-loop restart rule until one uninterrupted green pass is recorded for all Phase 4 commands
	- Acceptance: `evidence/qa-gates/final.qa-loop-pass.2026-03-04T23-31.md` exists and includes `LoopPassCount: 1` with all Phase 4 artifact filenames listed under `SuccessfulPassArtifacts:`.

### Phase 5 — atomic_executor Preflight Validation Loop

- [x] [P5-T1] Run plan preflight with directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY` against `docs/features/active/2026-03-04-expose-pr-context-script-77/remediation-plan.2026-03-04T23-31.md`
	- Acceptance: `evidence/other/preflight-pass-1.2026-03-04T23-31.md` exists and includes one exact signal line: `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`.

- [x] [P5-T2] Apply required plan deltas in place when preflight returns `PREFLIGHT: REVISIONS REQUIRED`
	- Acceptance: Artifact `evidence/other/preflight-revision-cycles.2026-03-04T23-31.md` exists and contains one section per cycle with `Cycle: 1` (and incrementing values for additional cycles), `RevisionApplied: yes`, and a bullet list of applied deltas.

- [x] [P5-T3] Repeat preflight validation cycles until terminal signal is `PREFLIGHT: ALL CLEAR`
	- Acceptance: `evidence/other/preflight-final.2026-03-04T23-31.md` exists and contains exact line `PREFLIGHT: ALL CLEAR`.

## Test Plan

- Unit:
	- `collectPrContext git branch discovery failure`
	- `collectPrContext non-zero collector exit diagnostics`
	- Existing deterministic branch default and cancel-path scenarios must stay green after file split.
- Integration:
	- `collectPrContext writes summary and appendix artifacts`
	- Existing integration scenarios for bundled-resource execution boundary and workspace paths with spaces/unicode must stay green.
- CLI/Toolchain:
	- Root TypeScript loop: `npm run format:check` -> `npm run lint` -> `npm run typecheck`
	- Extension TypeScript loop: Prettier check -> lint -> typecheck -> Jest coverage
	- Python loop: Black check -> Ruff check -> Pyright -> Pytest coverage
	- Final loop is complete only when all commands pass in one uninterrupted pass.

## Open Questions / Notes

- Coverage evidence remains a hard gate: do not mark remediation complete unless `evidence/qa-gates/ts-coverage-delta.2026-03-04T23-31.md` is present with numeric baseline/post values and an explicit verdict.
- Plan-path continuity is mandatory: all preflight revisions must update this file in place and must not create sibling remediation plan files.

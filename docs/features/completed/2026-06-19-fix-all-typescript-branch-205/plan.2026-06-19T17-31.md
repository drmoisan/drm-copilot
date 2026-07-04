# fix-all-typescript-branch - Plan

- **Issue:** #205
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-19T17-31
- **Status:** Draft
- **Work Mode:** minor-audit
- **Version:** 0.2

## Required References

- General Code Change Policy: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

- Work Mode: minor-audit (small-path change).
- Language in scope: Python only.
- Files in scope: 1 production file + 1 test file.
  - Production: `scripts/dev_tools/fix_all_runtime.py`
  - Test: `tests/scripts/dev_tools/test_fix_all.py`
- Requirements source: `docs/features/active/2026-06-19-fix-all-typescript-branch-205/issue.md`, `## Acceptance Criteria` section only.
- The implementation is already present on branch `feature/fix-all-typescript-branch-205`. This plan documents the delivered work for minor-audit verification.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the applicable policy files in required order: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-unit-test.instructions.md`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/phase0-instructions-read.md` exists and includes `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Capture Black baseline by running `poetry run black --check .`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/black-baseline.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T3] Capture Ruff baseline by running `poetry run ruff check .`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/ruff-baseline.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T4] Capture Pyright baseline by running `poetry run pyright`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/pyright-baseline.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Capture Pytest coverage baseline by running `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/pytest-baseline.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording numeric line coverage and branch coverage headline values for `scripts/dev_tools/fix_all_runtime.py`.

### Phase 1 — Constrained Small-Path Implementation

> The implementation is already delivered on the current branch. Tasks below are marked complete only where verifiable by reading the source. The executor must verify each acceptance criterion against the working tree.

- [x] [P1-T1] Implement `run_typescript_branch()` in `scripts/dev_tools/fix_all_runtime.py` that runs the TypeScript steps in order Prettier (format) -> ESLint (lint) -> TSC (type-check) -> Jest (test) using npm scripts, mirroring the linear no-retry structure of the PowerShell branch.
  - Acceptance: `scripts/dev_tools/fix_all_runtime.py` defines `run_typescript_branch` invoking `npm run format`, `npm run lint`, `npm run typecheck`, and the Jest step in that order; verified at lines 453-571.
- [x] [P1-T2] Switch the Jest step name and command on coverage in `run_typescript_branch()`: use step name `Jest: test with coverage` with command `npm run test:unit:coverage` when `include_coverage` is true, and `Jest: test` with command `npm run test:unit` otherwise.
  - Acceptance: `scripts/dev_tools/fix_all_runtime.py` selects `jest_command` and `jest_step_name` based on `include_coverage`; verified at lines 535-543.
- [x] [P1-T3] Register the `typescript` branch in the parallel `branch_functions` list in `scripts/dev_tools/fix_all_runtime.py` so it runs alongside json, shell, python, and powershell.
  - Acceptance: `branch_functions` includes `("typescript", run_typescript_branch)`; verified at line 578.
- [x] [P1-T4] Add a `typescript` row to the status board in `scripts/dev_tools/fix_all_runtime.py`: include `"typescript": "pending"` in `status_by_branch` and `"typescript"` in the interactive board line ordering.
  - Acceptance: `status_by_branch` contains a `typescript` entry (line 40) and the board line tuple in `emit_status_transition` includes `"typescript"` (lines 51-59).
- [x] [P1-T5] Add `test_pipeline_stops_on_prettier_failure` to `tests/scripts/dev_tools/test_fix_all.py` covering the Prettier failure path.
  - Acceptance: Test asserts exit code 1, that the typescript branch calls only `Prettier: format`, and that `Prettier formatting failed` appears in the log; verified at lines 366-382.
- [x] [P1-T6] Add `test_pipeline_stops_on_eslint_failure` to `tests/scripts/dev_tools/test_fix_all.py` covering the ESLint failure path.
  - Acceptance: Test asserts exit code 1, that the last typescript call is `ESLint: lint`, that `TSC: type-check` is not reached, and that `ESLint linting failed` appears in the log; verified at lines 385-402.
- [x] [P1-T7] Add `test_pipeline_stops_on_tsc_failure` to `tests/scripts/dev_tools/test_fix_all.py` covering the TSC failure path.
  - Acceptance: Test asserts exit code 1, that the last typescript call is `TSC: type-check`, that the Jest step is not reached, and that `TSC type checking failed` appears in the log; verified at lines 405-422.
- [x] [P1-T8] Add `test_pipeline_stops_on_jest_failure` to `tests/scripts/dev_tools/test_fix_all.py` covering the Jest failure path.
  - Acceptance: Test asserts exit code 1, that the last typescript call is `Jest: test with coverage`, and that `Jest failed` appears in the log; verified at lines 425-443.
- [x] [P1-T9] Add `test_typescript_jest_step_name_switches_with_coverage` to `tests/scripts/dev_tools/test_fix_all.py` covering the coverage step-name switch.
  - Acceptance: Test runs with `include_coverage=False`, asserts the Jest step name is `Jest: test` (not `Jest: test with coverage`), and asserts the Jest command is `["npm", "run", "test:unit"]`; verified at lines 446-462.

### Phase 2 — Final QC Loop

> Run the Python toolchain in order: format -> lint -> type-check -> test. If any step changes files or fails, restart from formatting until a single clean pass completes. Each command task below is unconditional and must be executed and recorded.

- [x] [P2-T1] Run Black formatting check: `poetry run black --check .`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/black-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (must be 0), and `Output Summary:`.
- [x] [P2-T2] Run Ruff linting: `poetry run ruff check .`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/ruff-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (must be 0), and `Output Summary:`.
- [x] [P2-T3] Run Pyright type checking: `poetry run pyright`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/pyright-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (must be 0), and `Output Summary:` reporting zero type errors.
- [x] [P2-T4] Run Pytest with coverage: `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py`.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/pytest-final.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (must be 0), and `Output Summary:` recording numeric post-change line coverage and branch coverage values; all five new tests pass.
- [ ] [P2-T5] Verify coverage thresholds and no regression on changed lines.
  - Acceptance: Evidence artifact `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/coverage-delta.md` exists reporting baseline coverage (from P0-T5), post-change coverage (from P2-T4), and changed-code coverage for `scripts/dev_tools/fix_all_runtime.py`; line coverage >= 85%, branch coverage >= 75%, and no regression on changed lines.
  - Status: PARTIAL. Evidence artifact written. Branch coverage 79.41% (>= 75%) PASS. No regression on changed lines PASS — changed TypeScript-branch code is 100% covered; module line coverage rose from 82.20% (base) to 84.55% and branch coverage rose from 75.00% to 79.41%. The absolute module line-coverage threshold (>= 85%) is NOT MET at 84.55%; this is a pre-existing gap in unchanged json/shell/python/powershell FAIL/cancel/aggregation paths (base branch was 82.20%, already below 85%). Closing it would require new tests for unchanged code in `tests/scripts/dev_tools/test_fix_all.py`, which is already 733 lines (over the 500-line file limit) and outside the approved minor-audit scope. Left unchecked pending scope decision.

## Test Plan

- Unit: `tests/scripts/dev_tools/test_fix_all.py` — five tests covering the Prettier, ESLint, TSC, and Jest failure paths plus the Jest coverage step-name switch.
  - `test_pipeline_stops_on_prettier_failure`
  - `test_pipeline_stops_on_eslint_failure`
  - `test_pipeline_stops_on_tsc_failure`
  - `test_pipeline_stops_on_jest_failure`
  - `test_typescript_jest_step_name_switches_with_coverage`
- Integration: Full parallel fix-all run including the typescript branch is exercised through the existing parallel-branch test harness in `tests/scripts/dev_tools/test_fix_all.py`.
- Manual/CLI: `poetry run python -m scripts.dev_tools.fix_all`.
- Coverage evidence:
  - Baseline artifact: `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/baseline/pytest-baseline.md`
  - Post-change artifact: `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/pytest-final.md`
  - Comparison artifact: `docs/features/active/2026-06-19-fix-all-typescript-branch-205/evidence/qa-gates/coverage-delta.md`

## Open Questions / Notes

- No change to `.vscode/tasks.json` is required because "QC: 0 Fix All" delegates to the `scripts.dev_tools.fix_all` module.
- Phase 1 tasks are pre-marked complete based on source verification of the current branch. The executor must confirm each acceptance criterion against the working tree before treating Phase 1 as closed.

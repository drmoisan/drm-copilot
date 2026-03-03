# scaffold-extension remediation — Plan

- **Issue:** #16
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-01T20-57
- **Status:** Planned
- **Version:** 1.0
- **Work Mode Resolution:** `full` (fail-closed; `issue.md` has no exact `- Work Mode:` marker)

## Remediation Objective

Close all FAIL/PARTIAL findings in `feature-audit.2026-03-01T20-57.md` by restoring PR-visible implementation scope, adding missing runtime/error-path coverage, strengthening Windows+POSIX integration confidence, completing README acceptance content, and finishing with a clean final TypeScript extension quality-gate pass.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Inputs

**Phase Completion Criteria:** Required policy/order references and remediation scope are locked; baseline evidence exists under canonical `evidence/baseline/` with machine-checkable schema (`Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`).

- [x] [P0-T1] Record policy-read order evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/remediation-policy-read.2026-03-01T20-57.md` for these files in exact order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/github-actions.instructions.md`.
	- Acceptance: evidence file exists and includes exact lines `Timestamp: 2026-03-01T20-57`, `Command: policy-read verification`, `EXIT_CODE: 0`, plus non-empty `Output Summary:`.
- [x] [P0-T2] Record remediation scope lock evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/remediation-scope.2026-03-01T20-57.md` using `poetry run python scripts/dev_tools/plan_progress_report.py --feature docs/features/active/2026-01-28-scaffold-extension-16`.
	- Acceptance: evidence file exists and includes exact lines `Timestamp:`, `Command: poetry run python scripts/dev_tools/plan_progress_report.py --feature docs/features/active/2026-01-28-scaffold-extension-16`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P0-T3] Capture baseline extension TypeScript toolchain evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/remediation-typescript-toolchain.2026-03-01T20-57.md` by running `npm --prefix extensions/scaffold-extension run format`, `npm --prefix extensions/scaffold-extension run lint`, `npm --prefix extensions/scaffold-extension run typecheck`, and `npm --prefix extensions/scaffold-extension run test`.
	- Acceptance: evidence file exists with four command blocks, each containing `Timestamp:`, exact `Command:`, integer `EXIT_CODE:`, and non-empty `Output Summary:`.
- [x] [P0-T4] Capture baseline PR diff-scope evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/baseline/remediation-pr-diff.2026-03-01T20-57.md` by running `git diff --name-status (git merge-base origin/main HEAD)..HEAD` and `git status --short`.
	- Acceptance: evidence file exists with two command blocks containing exact `Command:` values, integer `EXIT_CODE:`, and non-empty `Output Summary:`.

### Phase 1 — PR Diff Scope Repair (FAIL Closure)

**Phase Completion Criteria:** merge-base diff (`(git merge-base origin/main HEAD)..HEAD`) contains extension implementation files; remediation is no longer docs-only.

- [x] [P1-T1] Commit tracked extension implementation changes under `extensions/scaffold-extension/**` so they are included in `HEAD`.
	- Acceptance: `git diff --name-status (git merge-base origin/main HEAD)..HEAD | findstr /I "extensions/scaffold-extension/src/extension.ts extensions/scaffold-extension/package.json extensions/scaffold-extension/test"` exits with `EXIT_CODE: 0`.
- [x] [P1-T2] Record post-commit diff evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/remediation-pr-diff-after-commit.2026-03-01T20-57.md` using `git diff --name-status (git merge-base origin/main HEAD)..HEAD`.
	- Acceptance: evidence file includes exact `Command: git diff --name-status (git merge-base origin/main HEAD)..HEAD`, `EXIT_CODE: 0`, and `Output Summary:` containing at least one path starting with `extensions/scaffold-extension/`.

### Phase 2 — Runtime Error Coverage Gaps (PARTIAL Closure)

**Phase Completion Criteria:** Missing-PowerShell runtime error behavior is explicitly tested and passes.

- [x] [P2-T1] Add Jest unit test in `extensions/scaffold-extension/test/extension.test.ts` for scenario `detectRuntime returns actionable PowerShell error when both pwsh and powershell are unavailable`.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "missing PowerShell"` exits with `EXIT_CODE: 0`.
- [x] [P2-T2] Verify runtime probe order behavior in `extensions/scaffold-extension/test/extension.test.ts` for scenario `probe pwsh first, then powershell, then emit named failure when both missing`.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "pwsh then powershell"` exits with `EXIT_CODE: 0`.

### Phase 3 — Cross-Platform Integration Confidence (PARTIAL Closure)

**Phase Completion Criteria:** Integration verification provides auditable Windows + POSIX confidence for both hello commands and no-copy invariant.

- [x] [P3-T1] Add/update integration scenario in `extensions/scaffold-extension/test/extension.integration.test.ts` for `helloPython` execution path with platform-specific runtime assumptions.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPython"` exits with `EXIT_CODE: 0`.
- [x] [P3-T2] Add/update integration scenario in `extensions/scaffold-extension/test/extension.integration.test.ts` for `helloPowerShell` execution path with platform-specific runtime assumptions.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "helloPowerShell"` exits with `EXIT_CODE: 0`.
- [x] [P3-T3] Add/update integration scenario in `extensions/scaffold-extension/test/extension.integration.test.ts` for `no workspace-root hello script copy` invariant under command execution.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testPathPattern "extension.integration.test.ts" --testNamePattern "no copy"` exits with `EXIT_CODE: 0`.
- [x] [P3-T4] Update `.github/workflows/ci.yml` to run extension tests on `windows-latest` and one POSIX runner (`ubuntu-latest` or `macos-latest`) and save run evidence in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/remediation-platform-matrix.2026-03-01T20-57.md`.
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('.github/workflows/ci.yml').read_text(encoding='utf-8'); assert 'windows-latest' in t; assert ('ubuntu-latest' in t) or ('macos-latest' in t)"` exits with `EXIT_CODE: 0`, and evidence file contains `Timestamp:`, exact `Command:`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

### Phase 4 — Documentation Acceptance Closure (PARTIAL Closure)

**Phase Completion Criteria:** README explicitly satisfies platform notes, first-run workflow, and production-foundation positioning.

- [x] [P4-T1] Add explicit per-platform runtime section (Windows/macOS/Linux) to `extensions/scaffold-extension/README.md`.
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'Windows' in t and 'macOS' in t and 'Linux' in t"` exits with `EXIT_CODE: 0`.
- [x] [P4-T2] Add explicit first-run workflow steps to `extensions/scaffold-extension/README.md` for both `scaffoldExtension.helloPython` and `scaffoldExtension.helloPowerShell`.
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'First-run workflow' in t; assert 'scaffoldExtension.helloPython' in t; assert 'scaffoldExtension.helloPowerShell' in t"` exits with `EXIT_CODE: 0`.
- [x] [P4-T3] Add dedicated production-foundation section to `extensions/scaffold-extension/README.md` describing extension-to-workspace execution value.
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/scaffold-extension/README.md').read_text(encoding='utf-8'); assert 'Production foundation' in t"` exits with `EXIT_CODE: 0`.

### Phase 5 — Security, Performance, and Maintainability Checks

**Phase Completion Criteria:** Remediation includes explicit security invariant verification, performance impact note, and maintainability reconciliation.

- [x] [P5-T1] Add/update unit test in `extensions/scaffold-extension/test/extension.test.ts` for security scenario `spawn arguments are arrays and shell concatenation is not used`.
	- Acceptance: `npm --prefix extensions/scaffold-extension run test -- --testNamePattern "argv arrays"` exits with `EXIT_CODE: 0`.
- [x] [P5-T2] Record performance-impact assessment in `docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/remediation-performance-assessment.2026-03-01T20-57.md` with exact statement `No algorithmic complexity change; remediation is test/doc/CI scope.`
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/remediation-performance-assessment.2026-03-01T20-57.md').read_text(encoding='utf-8'); assert 'No algorithmic complexity change; remediation is test/doc/CI scope.' in t"` exits with `EXIT_CODE: 0`.
- [x] [P5-T3] Update `docs/features/active/2026-01-28-scaffold-extension-16/feature-audit.2026-03-01T20-57.md` statuses for all previously FAIL/PARTIAL rows and record verification commands used for each row.
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-01-28-scaffold-extension-16/feature-audit.2026-03-01T20-57.md').read_text(encoding='utf-8'); assert '| FAIL |' not in t and '| PARTIAL |' not in t"` exits with `EXIT_CODE: 0`.

### Phase 6 — Final QA Toolchain Loop

**Phase Completion Criteria:** One clean final extension TypeScript toolchain pass is recorded under canonical `evidence/qa-gates/`.

- [x] [P6-T1] Run extension formatting gate `npm --prefix extensions/scaffold-extension run format` and append result to `docs/features/active/2026-01-28-scaffold-extension-16/evidence/qa-gates/remediation-typescript-toolchain.2026-03-01T20-57.md`.
	- Acceptance: evidence file contains exact `Command: npm --prefix extensions/scaffold-extension run format`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.
- [x] [P6-T2] Run extension lint gate `npm --prefix extensions/scaffold-extension run lint`; if it fails or changes files, restart Phase 6 from [P6-T1].
	- Acceptance: evidence file contains exact `Command: npm --prefix extensions/scaffold-extension run lint` and `EXIT_CODE: 0`.
- [x] [P6-T3] Run extension typecheck gate `npm --prefix extensions/scaffold-extension run typecheck`; if it fails, restart Phase 6 from [P6-T1].
	- Acceptance: evidence file contains exact `Command: npm --prefix extensions/scaffold-extension run typecheck` and `EXIT_CODE: 0`.
- [x] [P6-T4] Run extension test gate `npm --prefix extensions/scaffold-extension run test`; if it fails, restart Phase 6 from [P6-T1].
	- Acceptance: evidence file contains exact `Command: npm --prefix extensions/scaffold-extension run test` and `EXIT_CODE: 0`.

### Phase 7 — Preflight Validation Loop (Validation-Only)

**Phase Completion Criteria:** Validation loop returns exact signal `PREFLIGHT: ALL CLEAR`.

- [x] [P7-T1] Run validation-only preflight through route `python-atomic-planning -> atomic_planner -> atomic_executor` using exact directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY`.
	- Acceptance: preflight log file `docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/preflight-loop.2026-03-01T20-57.md` contains exact lines `Directive: DIRECTIVE: PREFLIGHT VALIDATION ONLY` and one signal line equal to either `PREFLIGHT: REVISIONS REQUIRED` or `PREFLIGHT: ALL CLEAR`.
- [x] [P7-T2] Apply only plan-text deltas requested by preflight when signal is `PREFLIGHT: REVISIONS REQUIRED`, then rerun [P7-T1]. _(Not applicable in this run: no `PREFLIGHT: REVISIONS REQUIRED` iteration occurred.)_
	- Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-01-28-scaffold-extension-16/evidence/other/preflight-loop.2026-03-01T20-57.md').read_text(encoding='utf-8'); assert 'PREFLIGHT: REVISIONS REQUIRED' in t; assert 'Plan Delta:' in t"` exits with `EXIT_CODE: 0` whenever a revisions-required iteration occurs.
- [x] [P7-T3] Stop loop only when the final signal is exactly `PREFLIGHT: ALL CLEAR`.
	- Acceptance: final non-empty preflight signal line equals `PREFLIGHT: ALL CLEAR`.

## Preflight Handoff Contract

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required preflight result signals:
- `PREFLIGHT: ALL CLEAR`
- `PREFLIGHT: REVISIONS REQUIRED`

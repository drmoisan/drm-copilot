# Implementation Plan — blank-pr-context (Issue #81)

DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED

## Overview

Fix the PR-context collection bug where `scripts/dev_tools/pr_context` produces empty artifacts when run from extension-side execution in destination workspaces. This minimal-audit plan captures baseline state, delegates constrained implementation to a small-path engineer, and validates the fix through a full QC loop with reduced audit.

## Requirements Source

- `docs/features/active/2026-03-05-blank-pr-context-81/issue.md` (sole requirements source)

## Languages In Scope

- Python (`scripts/dev_tools/pr_context/`, `tests/`)
- TypeScript (`extensions/drm-copilot/`)

## Evidence Locations

- Baseline: `evidence/baseline/`
- QA gates: `evidence/qa-gates/`

---

### Phase 0 — Context & Baseline Capture

- [ ] [P0-T1] Read repository policy files in compliance order and record evidence artifact
  - Read in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and explicit list of files read

- [ ] [P0-T2] Capture Python baseline format state via `poetry run black --check .`
  - Acceptance: `evidence/baseline/python-format.md` exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T3] Capture Python baseline lint state via `poetry run ruff check`
  - Acceptance: `evidence/baseline/python-lint.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T4] Capture Python baseline type-check state via `poetry run pyright`
  - Acceptance: `evidence/baseline/python-typecheck.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T5] Capture Python baseline test state with coverage via `poetry run pytest --cov --cov-report=term-missing`
  - Acceptance: `evidence/baseline/python-test.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term-missing`, `EXIT_CODE:`, `Output Summary:` with numeric coverage headline values (total percent and per-module percent for `scripts/dev_tools`)

- [ ] [P0-T6] Capture TypeScript baseline format state via `npm --prefix extensions/drm-copilot run format`
  - Acceptance: `evidence/baseline/typescript-format.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T7] Capture TypeScript baseline lint state via `npm --prefix extensions/drm-copilot run lint`
  - Acceptance: `evidence/baseline/typescript-lint.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T8] Capture TypeScript baseline type-check state via `npm --prefix extensions/drm-copilot run typecheck`
  - Acceptance: `evidence/baseline/typescript-typecheck.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, `Output Summary:`

- [ ] [P0-T9] Capture TypeScript baseline test state with coverage via `npm --prefix extensions/drm-copilot run test:unit:coverage`
  - Acceptance: `evidence/baseline/typescript-test.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit:coverage`, `EXIT_CODE:`, `Output Summary:` with numeric coverage headline values

### Phase 1 — Constrained Small-Path Implementation

- [ ] [P1-T1] Delegate fix to small-path implementation engineer: resolve PR-context empty-artifact bug under extension-side execution
  - Requirements source: `docs/features/active/2026-03-05-blank-pr-context-81/issue.md`
  - Candidate files: `scripts/dev_tools/pr_context/collector.py`, `scripts/dev_tools/pr_context/render.py`, `scripts/dev_tools/pr_context/render_pr_helpers.py`, and any bundled copies under `extensions/drm-copilot/`
  - Prior attempt context: See "2026-03-05 Implementation Outcome" section in `issue.md`
  - Acceptance: implementation changes committed; PR-context collection produces non-empty summary and appendix artifacts containing git-backed context when invoked under extension-side execution path; all pre-existing tests continue to pass

### Phase 2 — Final QC Loop & Reduced Audit

- [ ] [P2-T1] Run Python format via `poetry run black .` and record evidence artifact
  - Acceptance: `evidence/qa-gates/python-format.md` exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, `Output Summary:`; if files changed, restart from P2-T1

- [ ] [P2-T2] Run Python lint via `poetry run ruff check` and record evidence artifact
  - Acceptance: `evidence/qa-gates/python-lint.md` exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, `Output Summary:`; if failures found, fix and restart from P2-T1

- [ ] [P2-T3] Run Python type-check via `poetry run pyright` and record evidence artifact
  - Acceptance: `evidence/qa-gates/python-typecheck.md` exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, `Output Summary:`; if failures found, fix and restart from P2-T1

- [ ] [P2-T4] Run Python test with coverage via `poetry run pytest --cov --cov-report=term-missing` and record evidence artifact
  - Acceptance: `evidence/qa-gates/python-test.md` exists and contains `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term-missing`, `EXIT_CODE: 0`, `Output Summary:` with numeric post-change coverage values; if failures found, fix and restart from P2-T1

- [ ] [P2-T5] Run TypeScript format via `npm --prefix extensions/drm-copilot run format` and record evidence artifact
  - Acceptance: `evidence/qa-gates/typescript-format.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, `Output Summary:`; if files changed, restart from P2-T5

- [ ] [P2-T6] Run TypeScript lint via `npm --prefix extensions/drm-copilot run lint` and record evidence artifact
  - Acceptance: `evidence/qa-gates/typescript-lint.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, `Output Summary:`; if failures found, fix and restart from P2-T5

- [ ] [P2-T7] Run TypeScript type-check via `npm --prefix extensions/drm-copilot run typecheck` and record evidence artifact
  - Acceptance: `evidence/qa-gates/typescript-typecheck.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, `Output Summary:`; if failures found, fix and restart from P2-T5

- [ ] [P2-T8] Run TypeScript unit tests with coverage via `npm --prefix extensions/drm-copilot run test:unit:coverage` and record evidence artifact
  - Acceptance: `evidence/qa-gates/typescript-test.md` exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit:coverage`, `EXIT_CODE: 0`, `Output Summary:` with numeric post-change coverage values; if failures found, fix and restart from P2-T5

- [ ] [P2-T9] Verify Python coverage delta: compare baseline coverage from `evidence/baseline/python-test.md` against post-change coverage from `evidence/qa-gates/python-test.md`
  - Acceptance: `evidence/qa-gates/python-coverage-delta.md` exists and contains baseline total coverage percent, post-change total coverage percent, and delta; post-change total coverage is not lower than baseline total coverage

- [ ] [P2-T10] Verify TypeScript coverage delta: compare baseline coverage from `evidence/baseline/typescript-test.md` against post-change coverage from `evidence/qa-gates/typescript-test.md`
  - Acceptance: `evidence/qa-gates/typescript-coverage-delta.md` exists and contains baseline total coverage percent, post-change total coverage percent, and delta; post-change total coverage is not lower than baseline total coverage

- [ ] [P2-T11] Perform reduced small-audit review of implementation changes against `issue.md` requirements
  - Acceptance: `evidence/qa-gates/small-audit-review.md` exists and contains `Timestamp:`, confirmed list of changed files, verification that each change maps to a requirement in `issue.md`, and confirmation that no out-of-scope changes were introduced

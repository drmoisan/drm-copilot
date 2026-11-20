# Issue #615 Atomic Implementation Plan

- **Issue:** #615
- **Work mode:** full-bug
- **Feature folder:** `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615`
- **Scope:** zero production files; one Python test-support file
- **Target file:** `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- **Plan status:** Draft pending executor preflight

## Objective

Update only the stale SHA-256 tuple value for `.claude/skills/epic-orchestrate/SKILL.md` to `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`, preserving the digest assertion, the second frozen-file pin, all fragment expectations, and the runtime skill and mirror. Restore the failed CI contract and verify the exact resulting commit head.

## Required invariants

- Do not modify `.claude/skills/epic-orchestrate/SKILL.md` or its mirror.
- Do not modify production code, runtime configuration, APIs, dependencies, or unrelated test-support expectations.
- Do not add a regression test; the existing frozen-surface contract is the regression test.
- All evidence belongs under `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/<kind>/`.
- Any failed or file-changing toolchain step restarts the Python loop at formatting.

### Phase 0 — Policy and baseline capture

- [ ] [P0-T1] Read `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`, and `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` in the required order; record `Timestamp:`, `Policy Order:`, and the complete file list in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/phase0-instructions-read.md`.
- [ ] [P0-T2] Record branch, baseline commit, and workspace status in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/repository-state.md`, including `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P0-T3] Run `poetry run black --check .` and record the exact result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/python-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P0-T4] Run `poetry run ruff check .`, record the exit code and whether Ruff rewrote any tracked files, and record the exact result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/python-lint.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P0-T5] Run `poetry run pyright` and record the exact result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/python-typecheck.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P0-T6] Run `poetry run pytest --cov=. --cov-report=term-missing` and record numeric total and targeted coverage in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/python-tests-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P0-T7] Independently compute the SHA-256 of `.claude/skills/epic-orchestrate/SKILL.md` and compare it with the proposed digest; record both values and the unchanged second pin in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/baseline/digest-cross-check.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Preparation and implementation handoff

- [ ] [P1-T1] Confirm `issue.md`, `spec.md`, and the research artifact identify issue #615, full-bug mode, the one-file test-support scope, and runtime/mirror preservation; record discrepancies in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/requirements-reconciliation.md`.
- [ ] [P1-T2] Delegate implementation to the typed Python engineer with the exact target file, digest, invariants, and approved scope; require no runtime or unrelated expectation changes.
- [ ] [P1-T3] Verify the implementation diff changes only the matching digest tuple in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; record the diff and changed-file count in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/scope-diff.md`.

### Phase 2 — Focused regression verification

- [ ] [P2-T1] Run `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` and record the result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/regression-testing/frozen-surface-contract.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [ ] [P2-T2] Verify the second frozen-file pin, all section/fragment expectations, runtime skill bytes, and mirror parity remain unchanged; record the comparison in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/regression-testing/frozen-surface-preservation.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 3 — Mandatory Python QA loop

- [ ] [P3-T1] Run `poetry run black .`, record the exit code and whether Black rewrote any tracked files in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/python-format.md`, and restart at P3-T1 if it fails or changes files.
- [ ] [P3-T2] After clean formatting, run `poetry run ruff check .`, record the exit code and whether Ruff rewrote any tracked files in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/python-lint.md`, and restart at P3-T1 if it fails or changes files.
- [ ] [P3-T3] After clean formatting and linting, run `poetry run pyright`, record the result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/python-typecheck.md`, and restart at P3-T1 if it fails or changes files.
- [ ] [P3-T4] After clean formatting, linting, and type checking, run `poetry run pytest --cov=. --cov-report=term-missing`, record numeric total and targeted coverage in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/python-tests-coverage.md`, and restart at P3-T1 if it fails or changes files.
- [ ] [P3-T5] Compare baseline and post-change coverage, confirm repository coverage remains at least 80% and changed-line coverage has no regression, and record all numeric values in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/python-coverage-comparison.md`.

### Phase 4 — Acceptance criteria and review

- [ ] [P4-T1] Check off only the satisfied acceptance criteria in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/spec.md` after linking each to evidence; mirror any posted issue update in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/issue-updates/issue-615.<timestamp>.md`.
- [ ] [P4-T2] Collect commit context from the staged diff, have the commit steward create the repository-compliant commit, and record the resulting SHA and changed-file list in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/commit-context.md`.
- [ ] [P4-T3] Run the full-bug feature review against the resolved base branch and record audit artifacts under `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/`; remediate findings through a new bounded QA loop before continuing.

### Phase 5 — Pull request and exact-head CI gate

- [ ] [P5-T1] Collect PR context for issue #615 and the committed branch head, then generate the PR body from the canonical context bundle with scope, evidence, risks, and validation results.
- [ ] [P5-T2] Push the issue #615 branch and create or update its pull request without merging; record PR number, URL, and head SHA in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/pr-context.md`.
- [ ] [P5-T3] Monitor required GitHub Actions checks for the exact PR head SHA, including the Python 3.11 quality job and frozen-surface contract, and record conclusions and URLs in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/qa-gates/ci-exact-head.md`.
- [ ] [P5-T4] If exact-head CI fails, identify the failing job and verified cause, apply only an in-scope correction, and repeat Phases 3 through 5; do not merge or bypass controls.

### Phase 6 — Completion validation and handoff

- [ ] [P6-T1] Run `validate_orchestration_artifacts` for the feature folder, plan, and required evidence, and record the result in `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/evidence/other/completion-validation.md`.
- [ ] [P6-T2] Confirm issue #615 acceptance criteria, exact-head CI, review status, PR state, and checkpoint state are consistent; preserve merge authorization as an independent repository-controlled gate.
- [ ] [P6-T3] Report the exact terminal signal, plan path, implementation commit, PR/head SHA, CI conclusions, evidence locations, and unresolved validator limitations to the parent orchestrator.

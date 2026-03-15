# 2026-03-05-blank-pr-context-81 — Minimal-Audit Plan

- **Issue:** `#81`
- **Requirements Source:** `docs/features/active/2026-03-05-blank-pr-context-81/issue.md`
- **Work Mode:** `minor-audit`
- **Plan Path:** `docs/features/active/2026-03-05-blank-pr-context-81/plan.md`
- **Directive:** `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`

Overview: Repair the destination-workspace PR-context regression described in `issue.md` without widening scope beyond the suspected Python PR-context modules and any directly required extension wrapper surfaces. This plan uses `issue.md` as the only requirements source, captures a deterministic baseline for Python and extension-local TypeScript, leaves Phase 1 as a constrained small-path implementation placeholder, and ends with an unconditional final QC loop on the same two language surfaces.

### Phase 0 — Baseline capture

- [ ] [P0-T1] Record required policy reads in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/phase0-instructions-read.md`
  - Preconditions: `docs/features/active/2026-03-05-blank-pr-context-81/issue.md` remains the sole requirements source for this `minor-audit` plan.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Policy Order:`, and these exact paths in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`.

- [ ] [P0-T2] Record the minor-audit requirements-file gate in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/minor-audit-requirements-gate.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-05-blank-pr-context-81/issue.md`, `SearchScope: docs/features/active/2026-03-05-blank-pr-context-81`, `SearchPatterns: spec.md, user-story.md`, `SearchResult: none`, and `Result: PASS`.

- [ ] [P0-T3] Run the baseline Python format command `poetry run black .` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t3-python-format.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T4] Run the baseline Python lint command `poetry run ruff check` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t4-python-lint.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T5] Run the baseline Python type-check command `poetry run pyright` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t5-python-typecheck.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T6] Run the baseline Python coverage test command `poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t6-python-test.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, `Output Summary:`, and numeric `Coverage Total:`.

- [ ] [P0-T7] Run the baseline extension format command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t7-extension-format.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T8] Run the baseline extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t8-extension-lint.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T9] Run the baseline extension type-check command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t9-extension-typecheck.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T10] Run the baseline extension coverage unit-test command `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t10-extension-test.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, `Output Summary:`, and numeric `Coverage Lines:`.

### Phase 1 — Placeholder for constrained small-path implementation work

- [ ] [P1-T1] Record constrained small-path targets in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/p1-t1-constrained-targets.yyyy-MM-ddTHH-mm.md`
  - Preconditions: `[P0-T2]` recorded `Result: PASS` for the minor-audit requirements gate.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-05-blank-pr-context-81/issue.md`, `Constrained Target: scripts/dev_tools/pr_context/collector.py`, `Constrained Target: scripts/dev_tools/pr_context/render.py`, `Constrained Target: scripts/dev_tools/pr_context/render_pr_helpers.py`, `Constrained Target: extensions/drm-copilot`, and `Reason:` lines quoting the `Suspected Cause / Notes` section from `issue.md`.

- [ ] [P1-T2] Record the constrained small-path implementation handoff in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/p1-t2-small-path-handoff.yyyy-MM-ddTHH-mm.md`
  - Preconditions: `[P1-T1]` identified the constrained target list.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-05-blank-pr-context-81/issue.md`, `Expected Outcome: PR-context artifacts are non-empty under extension-side execution`, `Control Outcome: collect_commit_context.py remains populated`, `OutOfScope: Any requirement not stated in issue.md`, and `OutOfScope: Any new production surface outside the constrained targets requires a new justification artifact before editing.`

- [ ] [P1-T3] Record the targeted verification placeholder in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/other/p1-t3-targeted-verification-handoff.yyyy-MM-ddTHH-mm.md`
  - Preconditions: `[P1-T2]` recorded the constrained implementation handoff.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Validation Target: PR-context summary artifact is non-empty`, `Validation Target: PR-context appendix artifact is non-empty`, `Validation Target: collect_commit_context.py control artifact remains populated`, `Validation Target: changed files stay within constrained targets unless separately justified`, and `Ready For Phase 2: true`.

### Phase 2 — Final QC loop

- [ ] [P2-T1] Run the final Python format command `poetry run black .` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t1-python-format.yyyy-MM-ddTHH-mm.md`; if this command changes files or exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T2] Run the final Python lint command `poetry run ruff check` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t2-python-lint.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T3] Run the final Python type-check command `poetry run pyright` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t3-python-typecheck.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T4] Run the final Python coverage test command `poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t4-python-test.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE: 0`, `Output Summary:`, and numeric `Coverage Total:`.

- [ ] [P2-T5] Run the final extension format command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t5-extension-format.yyyy-MM-ddTHH-mm.md`; if this command changes files or exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T6] Run the final extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t6-extension-lint.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T7] Run the final extension type-check command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t7-extension-typecheck.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T8] Run the final extension coverage unit-test command `npm --prefix extensions/drm-copilot run test:unit -- --coverage` and save the result to `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t8-extension-test.yyyy-MM-ddTHH-mm.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, `Output Summary:`, and numeric `Coverage Lines:`.

- [ ] [P2-T9] Record the coverage delta and threshold verification in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t9-coverage-verification.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `Baseline Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t6-python-test.yyyy-MM-ddTHH-mm.md`, `Baseline Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/baseline/p0-t10-extension-test.yyyy-MM-ddTHH-mm.md`, `Final Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t4-python-test.yyyy-MM-ddTHH-mm.md`, `Final Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t8-extension-test.yyyy-MM-ddTHH-mm.md`, numeric `Python Baseline Coverage:`, numeric `Python Post-Change Coverage:`, numeric `Python Changed-Code Coverage:`, numeric `Extension Baseline Coverage:`, numeric `Extension Post-Change Coverage:`, numeric `Extension Changed-Code Coverage:`, `Thresholds: repository >= 80%; new or changed code >= 90%`, and `Result: PASS`.

- [ ] [P2-T10] Record the clean-pass QC summary in `docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t10-clean-pass-summary.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The artifact exists and contains `Timestamp:`, `FinalPass: clean`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t1-python-format.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t2-python-lint.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t3-python-typecheck.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t4-python-test.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t5-extension-format.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t6-extension-lint.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t7-extension-typecheck.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t8-extension-test.yyyy-MM-ddTHH-mm.md`, `Artifact: docs/features/active/2026-03-05-blank-pr-context-81/evidence/qa-gates/p2-t9-coverage-verification.yyyy-MM-ddTHH-mm.md`, and the exact sentence `No Phase 2 command task was skipped.`.

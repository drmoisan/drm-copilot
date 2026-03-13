# 2026-03-12-extension-template-resolution (Plan)

- **Issue:** #93
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-13T00-20
- **Status:** Approved
- **Version:** 3.0
- **Work Mode:** minor-audit
- **Requirements source:** `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`

DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED

## Overview

The bug in `issue.md` is that extension commands resolve template markdown files from the destination workspace instead of the extension's bundled resources. This minimal-audit plan uses `issue.md` as the only requirements source, captures baseline evidence for the Python and TypeScript toolchains touched by the fix, delegates constrained small-path implementation against the `issue.md` acceptance items, and ends with an unconditional final QC loop that records on-disk evidence for each command step.

## QC Toolchain

| Language | Format | Lint | Type-check | Test |
|---|---|---|---|---|
| Python | `poetry run black .` | `poetry run ruff check` | `poetry run pyright` | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` |
| TypeScript | `npm --prefix extensions/drm-copilot run format` | `npm --prefix extensions/drm-copilot run lint` | `npm --prefix extensions/drm-copilot run typecheck` | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` |

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Record policy reads in repository compliance order in `evidence/baseline/phase0-instructions-read.md`
  - Preconditions: feature folder exists and `issue.md` contains `- Work Mode: minor-audit`
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the exact ordered list `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`

- [ ] [P0-T2] Record branch and commit baseline in `evidence/baseline/branch-commit-baseline.md`
  - Acceptance: `evidence/baseline/branch-commit-baseline.md` exists and contains `Timestamp:`, `Command: git branch --show-current && git rev-parse HEAD`, `EXIT_CODE: 0`, `Output Summary:`, `Branch: bug/extension-template-resolution-93`, and a non-empty `Commit:` line

- [ ] [P0-T3] Record minor-audit requirements-file gate in `evidence/baseline/minor-audit-requirements-gate.md`
  - Acceptance: `evidence/baseline/minor-audit-requirements-gate.md` exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `SearchScope:`, `SearchPatterns: spec.md, user-story.md`, `SearchResult:`, and `Result: PASS` when neither file exists or `Result: FAIL-CLOSED` when either file exists

- [ ] [P0-T4] Capture Python formatting baseline in `evidence/baseline/python-format-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T5] Capture Python lint baseline in `evidence/baseline/python-lint-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T6] Capture Python type-check baseline in `evidence/baseline/python-typecheck-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T7] Capture Python coverage baseline in `evidence/baseline/python-test-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values

- [ ] [P0-T8] Capture TypeScript formatting baseline in `evidence/baseline/ts-format-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T9] Capture TypeScript lint baseline in `evidence/baseline/ts-lint-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T10] Capture TypeScript type-check baseline in `evidence/baseline/ts-typecheck-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`

- [ ] [P0-T11] Capture TypeScript coverage baseline in `evidence/baseline/ts-test-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values

### Phase 1 — Constrained Small-Path Implementation Placeholder

- [ ] [P1-T1] Delegate constrained implementation against `issue.md` acceptance items to the small-path engineer
  - Preconditions: all Phase 0 artifacts exist and `evidence/baseline/minor-audit-requirements-gate.md` records `Result: PASS`
  - Acceptance: delegate summary identifies only the in-scope changes from `issue.md` (`resources/feature-templates/` bundling, bundled-resource template resolution with fallback, and unit-test coverage of bundled vs workspace paths) and references only these production/test files: `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`, `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`, `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`, `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_flow.py`, `scripts/dev_tools/new_potential_bug_entry.py`, `scripts/dev_tools/new_active_feature_folder_flow.py`, `extensions/drm-copilot/test/extension.test.ts`, `tests/scripts/dev_tools/test_new_potential_bug_entry.py`, and `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py`

- [ ] [P1-T2] Persist targeted `issue.md` delivery validation in `evidence/other/issue-validation.md` before final QC handoff
  - Depends on: [P1-T1]
  - Acceptance: `evidence/other/issue-validation.md` exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `Delivered Acceptance Items:`, `SearchScope:`, `SearchPatterns: spec.md, user-story.md`, `SearchResult:`, `Checklist Evidence Status:`, and `Result: PASS` only when the three checked acceptance items in `issue.md` are evidenced and no unexpected `spec.md` or `user-story.md` exists; otherwise `Result: remediation-required`

- [ ] [P1-T3] Persist reduced small-path audit handoff in `evidence/other/reduced-audit-handoff.md`
  - Depends on: [P1-T2]
  - Acceptance: `evidence/other/reduced-audit-handoff.md` exists and contains `Timestamp:`, `Target Folder: docs/features/active/2026-03-12-extension-template-resolution-93`, `Scope: policy + feature acceptance review`, `Baseline Evidence Status:`, `Validation Evidence: evidence/other/issue-validation.md`, and `Result: READY` only when required baseline artifacts exist and are consistent with checklist state; otherwise `Result: BLOCKED`

### Phase 2 — Final QC Loop

- [ ] [P2-T1] Run Python formatter and persist `evidence/qa-gates/python-format-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T2] Run Python linter and persist `evidence/qa-gates/python-lint-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T3] Run Python type checker and persist `evidence/qa-gates/python-typecheck-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T4] Run Python coverage tests and persist `evidence/qa-gates/python-test-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values

- [ ] [P2-T5] Run TypeScript formatter and persist `evidence/qa-gates/ts-format-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T6] Run TypeScript linter and persist `evidence/qa-gates/ts-lint-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T7] Run TypeScript type checker and persist `evidence/qa-gates/ts-typecheck-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`

- [ ] [P2-T8] Run TypeScript unit tests and persist `evidence/qa-gates/ts-test-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values

- [ ] [P2-T9] Restart the QC loop from [P2-T1] when any Phase 2 command changes files or fails
  - Acceptance: the final successful pass records `EXIT_CODE: 0` in every artifact from `python-format-final.md` through `ts-test-final.md` without any `SKIPPED` outcome

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

## Status Notes

- Remediation follow-up: `remediation-plan.2026-03-13T19-35.md`
- Remediation verification complete: remediation-plan.2026-03-13T19-35.md
- Fresh remediation evidence: `evidence/regression-testing/new-potential-entry-template-less-workspace.2026-03-13T19-35.md`
- Legacy checklist state retained; remediation verification is tracked by the remediation plan and its evidence artifacts.

## Overview

The bug in `issue.md` is that extension commands resolve template markdown files from the destination workspace instead of the extension's bundled resources. This minimal-audit plan uses `issue.md` as the only requirements source, captures baseline evidence for the Python and TypeScript toolchains touched by the fix, delegates constrained small-path implementation against the `issue.md` acceptance items, and ends with an unconditional final QC loop that records on-disk evidence for each command step.

## QC Toolchain

| Language | Format | Lint | Type-check | Test |
|---|---|---|---|---|
| Python | `poetry run black .` | `poetry run ruff check` | `poetry run pyright` | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` |
| PowerShell | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` | `N/A` | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` |
| TypeScript | `npm --prefix extensions/drm-copilot run format` | `npm --prefix extensions/drm-copilot run lint` | `npm --prefix extensions/drm-copilot run typecheck` | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` |

### Phase 0 — Baseline Capture

- [x] [P0-T1] Record policy reads in repository compliance order in `evidence/baseline/phase0-instructions-read.md`
  - Preconditions: feature folder exists and `issue.md` contains `- Work Mode: minor-audit`
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the exact ordered list `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/phase0-instructions-read.md` — Timestamp ✓, Policy Order listed ✓, all 12 required policy files in correct order ✓, Result: PASS ✓

- [x] [P0-T2] Record branch and commit baseline in `evidence/baseline/branch-commit-baseline.md`
  - Acceptance: `evidence/baseline/branch-commit-baseline.md` exists and contains `Timestamp:`, `Command: git branch --show-current && git rev-parse HEAD`, `EXIT_CODE: 0`, `Output Summary:`, `Branch: bug/extension-template-resolution-93`, and a non-empty `Commit:` line
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/branch-commit-baseline.md` — Timestamp: 2026-03-13T00-31 ✓, EXIT_CODE: 0 ✓, Branch: bug/extension-template-resolution-93 ✓, Commit: acab750... ✓

- [x] [P0-T3] Record minor-audit requirements-file gate in `evidence/baseline/minor-audit-requirements-gate.md`
  - Acceptance: `evidence/baseline/minor-audit-requirements-gate.md` exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `SearchScope:`, `SearchPatterns: spec.md, user-story.md`, `SearchResult:`, and `Result: PASS` when neither file exists or `Result: FAIL-CLOSED` when either file exists
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/minor-audit-requirements-gate.md` — Timestamp ✓, Requirements Source ✓, SearchPatterns ✓, SearchResult: neither spec.md nor user-story.md found ✓, Result: PASS ✓

- [x] [P0-T4] Capture Python formatting baseline in `evidence/baseline/python-format-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/python-format-baseline.md` — Timestamp: 2026-03-13T00-32 ✓, Command ✓, EXIT_CODE: 0 ✓, Output: 159 files unchanged ✓

- [x] [P0-T5] Capture Python lint baseline in `evidence/baseline/python-lint-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/python-lint-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: all checks passed ✓

- [x] [P0-T6] Capture Python type-check baseline in `evidence/baseline/python-typecheck-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/python-typecheck-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: 0 errors ✓

- [x] [P0-T7] Capture Python coverage baseline in `evidence/baseline/python-test-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/python-test-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Coverage: 836 passed / 82% overall ✓

- [x] [P0-T8] Capture TypeScript formatting baseline in `evidence/baseline/ts-format-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ts-format-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: all files unchanged ✓

- [x] [P0-T9] Capture TypeScript lint baseline in `evidence/baseline/ts-lint-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ts-lint-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: no errors or warnings ✓

- [x] [P0-T10] Capture TypeScript type-check baseline in `evidence/baseline/ts-typecheck-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ts-typecheck-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: no errors ✓

- [x] [P0-T11] Capture TypeScript coverage baseline in `evidence/baseline/ts-test-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ts-test-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Coverage: 67 tests / 89.31% stmts ✓

- [x] [P0-T12] Capture PowerShell formatting baseline in `evidence/baseline/ps-format-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ps-format-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: 36 files already formatted ✓

- [x] [P0-T13] Capture PowerShell analyzer baseline in `evidence/baseline/ps-analyze-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE:`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ps-analyze-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 0 ✓, Output: PSScriptAnalyzer passed, no findings ✓

- [x] [P0-T14] Capture PowerShell test baseline in `evidence/baseline/ps-test-baseline.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values
  - Evidence (status_updater, 2026-03-13T19-22): `evidence/baseline/ps-test-baseline.md` — Timestamp ✓, Command ✓, EXIT_CODE: 2 (2 pre-existing failures) ✓, Coverage: 220 passed / 43.5% ✓

### Phase 1 — Constrained Small-Path Implementation Placeholder

- [x] [P1-T1] Persist constrained implementation handoff in `evidence/other/delegated-implementation-handoff.md`
  - Preconditions: all Phase 0 artifacts exist and `evidence/baseline/minor-audit-requirements-gate.md` records `Result: PASS`
  - Acceptance: `evidence/other/delegated-implementation-handoff.md` exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `In-Scope Changes: resources/feature-templates bundling; bundled-resource template resolution with fallback; unit-test coverage of bundled vs workspace paths`, `Allowed Files: extensions/drm-copilot/src/extension.ts; extensions/drm-copilot/resources/templates/new-potential-entry.ps1; extensions/drm-copilot/resources/templates/new_potential_bug_entry.py; extensions/drm-copilot/resources/templates/new_active_feature_folder.py; extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_flow.py; scripts/dev_tools/new_potential_bug_entry.py; scripts/dev_tools/new_active_feature_folder_flow.py; extensions/drm-copilot/test/extension.test.ts; tests/scripts/dev_tools/test_new_potential_bug_entry.py; tests/scripts/dev_tools/test_new_active_feature_folder_part2.py; extensions/drm-copilot/resources/feature-templates/**`, and `Result: DELEGATED`

- [x] [P1-T2] Persist targeted `issue.md` delivery validation in `evidence/other/issue-validation.md` before final QC handoff
  - Depends on: [P1-T1]
  - Acceptance: `evidence/other/issue-validation.md` exists and contains `Timestamp:`, `Requirements Source: docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`, `Delivered Acceptance Items:`, `SearchScope:`, `SearchPatterns: spec.md, user-story.md`, `SearchResult:`, `Checklist Evidence Status:`, and `Result: PASS` only when the three checked items under `## Proposed Fix / Validation Ideas` in `issue.md` lines 63-65 are evidenced and no unexpected `spec.md` or `user-story.md` exists; otherwise `Result: remediation-required`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/other/issue-validation.md` — Timestamp ✓, Requirements Source ✓, delivered items 1-3 evidenced from bundled templates / template-root code paths / unit tests ✓, SearchResult: no `spec.md` or `user-story.md` in feature root ✓, Result: PASS ✓

- [x] [P1-T3] Persist reduced small-path audit handoff in `evidence/other/reduced-audit-handoff.md`
  - Depends on: [P1-T2]
  - Acceptance: `evidence/other/reduced-audit-handoff.md` exists and contains `Timestamp:`, `Target Folder: docs/features/active/2026-03-12-extension-template-resolution-93`, `Scope: policy + feature acceptance review`, `Baseline Evidence Status:`, `Validation Evidence: evidence/other/issue-validation.md`, and `Result: READY` only when required baseline artifacts exist and are consistent with checklist state; otherwise `Result: BLOCKED`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/other/reduced-audit-handoff.md` — Timestamp ✓, Target Folder ✓, Scope ✓, Validation Evidence points to `evidence/other/issue-validation.md` ✓, Result: READY ✓

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run Python formatter and persist `evidence/qa-gates/python-format-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/python-format-final.md` — Timestamp ✓, Command: `poetry run black .` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T2] Run Python linter and persist `evidence/qa-gates/python-lint-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/python-lint-final.md` — Timestamp ✓, Command: `poetry run ruff check` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T3] Run Python type checker and persist `evidence/qa-gates/python-typecheck-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/python-typecheck-final.md` — Timestamp ✓, Command: `poetry run pyright` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T4] Run Python coverage tests and persist `evidence/qa-gates/python-test-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values
  - Evidence missing (status_updater, 2026-03-13T18-10): `evidence/qa-gates/python-test-final.md` exists, but `Command:` is `poetry run pytest` instead of the required coverage command and the artifact does not record numeric post-change coverage headline values

- [x] [P2-T5] Run TypeScript formatter and persist `evidence/qa-gates/ts-format-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/ts-format-final.md` — Timestamp ✓, Command: `npm --prefix extensions/drm-copilot run format` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T6] Run TypeScript linter and persist `evidence/qa-gates/ts-lint-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/ts-lint-final.md` — Timestamp ✓, Command: `npm --prefix extensions/drm-copilot run lint` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T7] Run TypeScript type checker and persist `evidence/qa-gates/ts-typecheck-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`
  - Evidence (status_updater, 2026-03-13T18-10): `evidence/qa-gates/ts-typecheck-final.md` — Timestamp ✓, Command: `npm --prefix extensions/drm-copilot run typecheck` ✓, EXIT_CODE: 0 ✓, Output Summary present ✓

- [x] [P2-T8] Run TypeScript unit tests and persist `evidence/qa-gates/ts-test-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values

- [x] [P2-T9] Run PowerShell formatter and persist `evidence/qa-gates/ps-format-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`

- [x] [P2-T10] Run PowerShell analyzer and persist `evidence/qa-gates/ps-analyze-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`

- [x] [P2-T11] Run PowerShell tests and persist `evidence/qa-gates/ps-test-final.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values

- [x] [P2-T12] Verify coverage deltas and QC loop closure in `evidence/qa-gates/coverage-delta-verification.md`
  - Acceptance: `evidence/qa-gates/coverage-delta-verification.md` exists and contains `Timestamp:`, `Python Baseline Coverage:`, `Python Post-Change Coverage:`, `Python New/Changed-Code Coverage:`, `TypeScript Baseline Coverage:`, `TypeScript Post-Change Coverage:`, `TypeScript New/Changed-Code Coverage:`, `PowerShell Baseline Coverage:`, `PowerShell Post-Change Coverage:`, `PowerShell New/Changed-Code Coverage:`, `Restart Required: NO`, and `Result: PASS`; if any Phase 2 command changes files or fails before the final clean pass, the QC loop restarts from [P2-T1], and the final successful pass records `EXIT_CODE: 0` in every artifact from `python-format-final.md` through `ps-test-final.md` without any `SKIPPED` outcome

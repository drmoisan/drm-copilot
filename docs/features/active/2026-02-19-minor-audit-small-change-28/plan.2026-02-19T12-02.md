---
issue: 28
parent: none
owner: drmoisan
last_updated: 2026-02-19T12-02
status: Planned
status_color: blue
version: 1.0
---

# 2026-02-19-minor-audit-small-change - Plan

## Introduction

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

This plan delivers the Minor Change Audit Path defined in `spec.md`, `user-story.md`, and `research.md` for issue #28.
All tasks are deterministic, atomic, and executor-compatible.

## Required References

- Copilot Instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python Suppressions Policy: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- Feature spec: [`docs/features/active/2026-02-19-minor-audit-small-change-28/spec.md`](./spec.md)
- User story: [`docs/features/active/2026-02-19-minor-audit-small-change-28/user-story.md`](./user-story.md)
- Research: [`docs/features/active/2026-02-19-minor-audit-small-change-28/research.md`](./research.md)

## Requirements Traceability

| ID | Type | Requirement |
| --- | --- | --- |
| REQ-001 | Functional | Support work-mode routing (`minor-audit` vs `full`) in promotion and active-folder flows. |
| REQ-002 | Functional | Enforce minor-audit eligibility: bootstrapped/pre-cooked OR <=3 production files and low integration risk. |
| REQ-003 | Functional | Ensure minor-audit `issue.md` contains required sections: problem/why, implementation intent, acceptance criteria, dependencies/risks, verification steps, evidence checklist. |
| REQ-004 | Functional | Preserve full workflow behavior for non-qualifying work and explicit `full` mode. |
| REQ-005 | Functional | Add deterministic script outputs that state selected mode and fallback reason when rejected. |
| REQ-006 | Functional | Update process docs and template guidance to include minor-audit selection rules and evidence contract. |
| SEC-001 | Security | Prevent secret/token leakage in generated evidence and script output text. |
| SEC-002 | Security | Maintain existing gh authentication checks; no bypass path added. |
| CON-001 | Constraint | No new runtime dependencies. |
| CON-002 | Constraint | Keep existing CLI defaults backward-compatible. |
| CON-003 | Constraint | Keep evidence artifacts in canonical folders with required schema fields. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context, Policy, and Baseline Capture

- [x] [P0-T1] Record policy-read evidence in `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/policy-read.2026-02-19T12-02.md` after reading the required policy files in listed order
  - Acceptance: File exists and contains exact lines `Timestamp: 2026-02-19T12-02`, `Command: policy-read`, `EXIT_CODE: 0`, `Output Summary: policy files reviewed in required order`, and the exact ordered list of files read: `1) .github/copilot-instructions.md`, `2) .github/instructions/general-code-change.instructions.md`, `3) .github/instructions/general-unit-test.instructions.md`, `4) .github/instructions/python-code-change.instructions.md`, `5) .github/instructions/python-unit-test.instructions.md`, `6) .github/instructions/python-suppressions.instructions.md`.
- [x] [P0-T2] Capture Python formatter baseline by running `poetry run black . --check` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-format-baseline.2026-02-19T12-02.md`
  - Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run black . --check`, integer `EXIT_CODE`, and `Output Summary`.
- [x] [P0-T3] Capture Python lint baseline by running `poetry run ruff check` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-lint-baseline.2026-02-19T12-02.md`
  - Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run ruff check`, integer `EXIT_CODE`, and `Output Summary`.
- [x] [P0-T4] Capture Python type baseline by running `poetry run pyright` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-type-baseline.2026-02-19T12-02.md`
  - Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run pyright`, integer `EXIT_CODE`, and `Output Summary`.
- [x] [P0-T5] Capture Python test baseline by running `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and writing output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/baseline/python-test-baseline.2026-02-19T12-02.md`
  - Acceptance: Evidence file contains `Timestamp`, exact `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, integer `EXIT_CODE`, and `Output Summary`.

Phase completion criteria:
- All baseline evidence artifacts listed in P0-T1..P0-T5 exist and are schema-valid.

### Phase 1 — Add TDD Red Tests for `scripts/dev_tools/potential_to_issue.py`

- [x] [P1-T1] [expect-fail] Add regression test `test_promote_potential_minor_audit_adds_required_issue_sections` in `tests/scripts/dev_tools/test_potential_to_issue.py` for function `promote_potential` when `--work-mode minor-audit` is selected
  - Preconditions: `tests/scripts/dev_tools/test_potential_to_issue.py` exists.
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k minor_audit_adds_required_issue_sections` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p1-t1.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `minor audit`.
- [x] [P1-T2] [expect-fail] Add regression test `test_promote_potential_minor_audit_rejects_missing_eligibility_inputs` in `tests/scripts/dev_tools/test_potential_to_issue.py` for function `promote_potential` rejection path
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k minor_audit_rejects_missing_eligibility_inputs` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p1-t2.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `eligibility`.
- [x] [P1-T3] [expect-fail] Add regression test `test_promote_potential_full_mode_preserves_existing_body_contract` in `tests/scripts/dev_tools/test_potential_to_issue.py` for backward compatibility in `full` mode
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k full_mode_preserves_existing_body_contract` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p1-t3.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `full mode`.

Phase completion criteria:
- All three red tests exist with exact test names and auditable expect-fail evidence artifacts.

### Phase 2 — Implement `potential_to_issue.py` Minor-Audit Routing and Make Phase 1 Green

- [x] [P2-T1] Add CLI argument `--work-mode` with choices `minor-audit|full` in `scripts/dev_tools/potential_to_issue.py` function `parse_args`
  - Dependencies: [P1-T1], [P1-T2], [P1-T3]
  - Acceptance: `parse_args` includes `--work-mode`, default `full`, and `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k parse_args` exits 0.
- [x] [P2-T2] Add typed helper function `evaluate_minor_audit_eligibility` in `scripts/dev_tools/potential_to_issue.py` implementing REQ-002 deterministic gate
  - Acceptance: Helper signature is fully typed and `poetry run pyright scripts/dev_tools/potential_to_issue.py` exits 0.
- [x] [P2-T3] Add typed helper function `build_minor_audit_body` in `scripts/dev_tools/potential_to_issue.py` that emits required issue sections per REQ-003
  - Acceptance: Function output contains exact headings `## Problem / Why`, `## Implementation Intent`, `## Acceptance Criteria`, `## Dependencies / Risks`, `## Verification Steps`, `## Evidence Checklist`, `## Source`.
- [x] [P2-T4] Update function `promote_potential` in `scripts/dev_tools/potential_to_issue.py` to branch on `work_mode` and call `build_minor_audit_body` only when eligibility passes
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "minor_audit_adds_required_issue_sections or minor_audit_rejects_missing_eligibility_inputs"` exits 0.
- [x] [P2-T5] Add/adjust tests in `tests/scripts/dev_tools/test_potential_to_issue.py` so Phase 1 scenarios pass with green expectations
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "minor_audit or full_mode_preserves_existing_body_contract"` exits 0.
- [x] [P2-T6] Add security regression assertion in `tests/scripts/dev_tools/test_potential_to_issue.py` verifying body generation does not include token-like substrings (`ghp_`, `xoxb-`, `AIza`)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k token_like` exits 0.

Phase completion criteria:
- REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, SEC-001, SEC-002 are satisfied for `potential_to_issue.py` with passing tests.

### Phase 3 — Add TDD Red Tests for `scripts/dev_tools/new_active_feature_folder.py`

- [x] [P3-T1] [expect-fail] Add regression test `test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` for function `create_active_folder`
  - Preconditions: `tests/scripts/dev_tools/test_new_active_feature_folder.py` exists.
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k minor_audit_materializes_issue_md_and_skips_full_docs` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p3-t1.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `minor audit`.
- [x] [P3-T2] [expect-fail] Add regression test `test_create_active_folder_minor_audit_falls_back_to_full_when_not_eligible` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` for fallback behavior
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k minor_audit_falls_back_to_full_when_not_eligible` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p3-t2.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `fallback`.
- [x] [P3-T3] [expect-fail] Add regression test `test_create_active_folder_full_mode_remains_backward_compatible` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` for existing full behavior preservation
  - Acceptance: Running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k full_mode_remains_backward_compatible` fails and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/regression-testing/p3-t3.expect-fail.2026-02-19T12-02.md` with `Timestamp`, exact `Command`, non-zero `EXIT_CODE`, and failure excerpt containing `full mode`.

Phase completion criteria:
- All three new red tests exist and produce auditable expect-fail evidence.

### Phase 4 — Implement `new_active_feature_folder.py` Mode Routing and Make Phase 3 Green

- [x] [P4-T1] Add CLI argument `--work-mode` with choices `minor-audit|full` in `scripts/dev_tools/new_active_feature_folder.py` function `parse_args`
  - Dependencies: [P3-T1], [P3-T2], [P3-T3]
  - Acceptance: `parse_args` includes `--work-mode`, default `full`.
- [x] [P4-T2] Add typed helper function `should_use_minor_audit_mode` in `scripts/dev_tools/new_active_feature_folder.py` to centralize mode + eligibility routing
  - Acceptance: Helper signature is fully typed and `poetry run pyright scripts/dev_tools/new_active_feature_folder.py` exits 0.
- [x] [P4-T3] Update function `create_active_folder` in `scripts/dev_tools/new_active_feature_folder.py` to materialize `issue.md`-centric output for eligible minor-audit mode
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k minor_audit_materializes_issue_md_and_skips_full_docs` exits 0.
- [x] [P4-T4] Update function `create_active_folder` in `scripts/dev_tools/new_active_feature_folder.py` to preserve existing full-feature behavior for `full` mode and rejected minor-audit requests
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "minor_audit_falls_back_to_full_when_not_eligible or full_mode_remains_backward_compatible"` exits 0.
- [x] [P4-T5] Add/adjust tests in `tests/scripts/dev_tools/test_new_active_feature_folder.py` so Phase 3 scenarios pass with green expectations
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "minor_audit or full_mode_remains_backward_compatible"` exits 0.
- [x] [P4-T6] Add deterministic output assertions in `tests/scripts/dev_tools/test_new_active_feature_folder.py` that selected mode and fallback reason are printed
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k fallback_reason` exits 0.

Phase completion criteria:
- REQ-001, REQ-002, REQ-004, REQ-005, CON-002 are satisfied for active-folder workflow with passing tests.

### Phase 5 — Wire Tasks and Update Process Documentation

- [x] [P5-T1] Update `.vscode/tasks.json` task `Dev: 2 Promote Potential to GitHub Issue` to pass `--work-mode` from a new input `PotentialWorkMode`
  - Acceptance: `.vscode/tasks.json` includes input id `PotentialWorkMode` with options `minor-audit` and `full`, and task args include `--work-mode` then `${input:PotentialWorkMode}`.
- [x] [P5-T2] Update `.vscode/tasks.json` task `Dev: 3 Create Active Folder` to pass `--work-mode` from a new input `ActiveWorkMode`
  - Acceptance: `.vscode/tasks.json` includes input id `ActiveWorkMode` with options `minor-audit` and `full`, and task args include `--work-mode` then `${input:ActiveWorkMode}`.
- [x] [P5-T3] Update `docs/engineering/Feature Playbook.md` with deterministic minor-audit eligibility gate and fallback rules
  - Acceptance: Document contains exact phrase `Minor Change Audit Path` and explicit fallback condition `if eligibility fails, use full feature path`.
- [x] [P5-T4] Update `docs/features/templates/README.md` with decision tree rules for `minor-audit`, `feature`, and `refactor`
  - Acceptance: Document contains a dedicated bullet list naming all three paths and when each applies.
- [x] [P5-T5] Add evidence contract section to `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md` with canonical folders and schema fields
  - Acceptance: `issue.md` contains exact fields `Timestamp`, `Command`, `EXIT_CODE` and folder names `evidence/baseline/`, `evidence/regression-testing/`, `evidence/other/`, `evidence/qa-gates/`.

Phase completion criteria:
- REQ-006 and CON-003 are documented in repo guidance and issue contract.

### Phase 6 — Final QA Loop and Evidence Closure

- [x] [P6-T1] Run formatter loop start command `poetry run black .` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-format.2026-02-19T12-02.md`
  - Acceptance: Evidence file exists with schema fields and `EXIT_CODE: 0`.
- [x] [P6-T2] Run linter command `poetry run ruff check` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-lint.2026-02-19T12-02.md`
  - Dependencies: [P6-T1]
  - Acceptance: Evidence file exists with schema fields and `EXIT_CODE: 0`.
- [x] [P6-T3] Run type checker command `poetry run pyright` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-type.2026-02-19T12-02.md`
  - Dependencies: [P6-T2]
  - Acceptance: Evidence file exists with schema fields and `EXIT_CODE: 0`.
- [x] [P6-T4] Run test command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and save output to `docs/features/active/2026-02-19-minor-audit-small-change-28/evidence/qa-gates/qa-test.2026-02-19T12-02.md`
  - Dependencies: [P6-T3]
  - Acceptance: Evidence file exists with schema fields and `EXIT_CODE: 0`.
- [x] [P6-T5] Re-run the full QA loop from P6-T1 if any prior QA gate changed files or had non-zero exit codes
  - Acceptance: Latest evidence set shows all four commands passing in one clean pass with no subsequent file modifications.

Phase completion criteria:
- Final QA evidence proves a clean format -> lint -> type -> test pass in a single loop.

## Test Plan

- Unit:
  - `tests/scripts/dev_tools/test_potential_to_issue.py`
    - `promote_potential` scenario: minor-audit required sections generated.
    - `promote_potential` scenario: minor-audit eligibility rejection fallback to full mode.
    - `promote_potential` scenario: explicit full mode preserves legacy body contract.
    - `promote_potential` scenario: generated body does not include token-like secret strings.
  - `tests/scripts/dev_tools/test_new_active_feature_folder.py`
    - `create_active_folder` scenario: eligible minor-audit materializes issue-centric flow.
    - `create_active_folder` scenario: ineligible minor-audit request falls back to full path with reason.
    - `create_active_folder` scenario: full mode remains backward compatible.
- Integration:
  - Script-level invocation checks through parser and mode routing in both scripts using fake filesystem/fake clients.
- Manual/CLI:
  - `poetry run python -m scripts.dev_tools.potential_to_issue --potential-path docs/features/potential/2026-02-19-example.md --promotion-type feature --work-mode minor-audit`
  - `poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name minor-audit-smoke --type feature --issue-number auto --work-mode minor-audit`

## Open Questions / Notes

- No open questions remain for implementation sequencing.
- If additional eligibility dimensions are added later (for example changed-line budget), add a new requirement ID and separate atomic tasks in a follow-up plan.

---
title: "Remediation Plan: potential-to-issue-missing-label (2026-04-05T14-19)"
issue: 123
owner: "drmoisan"
work_mode: "minor-audit"
status: "Executed"
status_color: "red"
last_updated: "2026-04-05T15-00"
source_of_truth: "docs/features/active/2026-04-05-potential-to-issue-missing-label-123/remediation-inputs.2026-04-05T14-19.md"
plan_path: "docs/features/active/2026-04-05-potential-to-issue-missing-label-123/remediation-plan.2026-04-05T14-19.md"
---

# potential-to-issue-missing-label - Remediation Plan

## Scope

This remediation plan addresses the remaining post-remediation audit failure for the `minor-audit` feature folder `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`. `issue.md` remains the sole requirements source. Feature acceptance criteria are already satisfied; the remaining blocker is policy compliance for bundled-runtime test coverage.

## Inputs Reviewed

- `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/remediation-inputs.2026-04-05T14-19.md`
- `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T14-19.md`
- `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/code-review.2026-04-05T14-19.md`
- `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/feature-audit.2026-04-05T14-19.md`

## Atomic Work Outline

### Phase 0 — Policy Reading and Baseline Capture

- [x] [P0-T1] Read repository policy files in required order.
  - Read: `.github/copilot-instructions.md`, `general-code-change.instructions.md`, `general-unit-test.instructions.md`, `python-code-change.instructions.md`, `python-unit-test.instructions.md`, `python-suppressions.instructions.md`.
  - Store evidence artifact: `evidence/remediation-baseline/phase0-instructions-read.2026-04-05T15-00.md` with fields: `Timestamp:`, `Policy Order:`, list of files read.
  - **AC**: Artifact exists and lists all six policy files in order.

- [x] [P0-T2] Confirm `issue.md` work mode is `minor-audit`, and that `spec.md` and `user-story.md` are absent from the feature folder.
  - **AC**: `issue.md` contains `- Work Mode: minor-audit`; `spec.md` and `user-story.md` do not exist in the feature folder.

- [x] [P0-T3] Baseline: run Black on bundled-runtime scope.
  - Command: `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/remediation-baseline/baseline-black.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Artifact exists with all four required fields populated.

- [x] [P0-T4] Baseline: run Ruff on bundled-runtime scope.
  - Command: `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/remediation-baseline/baseline-ruff.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Artifact exists with all four required fields populated.

- [x] [P0-T5] Baseline: run Pyright on bundled-runtime scope.
  - Command: `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/remediation-baseline/baseline-pyright.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Artifact exists with all four required fields populated.

- [x] [P0-T6] Baseline: run pytest with coverage on bundled-runtime scope.
  - Command: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=extensions.drm_copilot.resources.scripts.dev_tools.potential_to_issue --cov-report=term-missing`
  - Store artifact: `evidence/remediation-baseline/baseline-pytest-coverage.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (must include numeric baseline coverage percentage).
  - **AC**: Artifact exists with all four required fields populated and `Output Summary:` includes numeric coverage value.

### Phase 1 — Close the Bundled-Runtime Coverage Gap

- [x] [P1-T1] Add or adjust focused pytest tests in `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` targeting uncovered branches in `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`.
  - **AC**: New or modified test functions exist; tests pass when run individually with `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q`.

- [x] [P1-T2] If baseline coverage from P0-T6 is already `>= 90%`, skip this task. Otherwise, simplify or extract dead/redundant branches in `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` without changing accepted behavior, only if P1-T1 alone does not reach `>= 90%`.
  - **AC**: Either (a) no production code changes needed and coverage already `>= 90%` after P1-T1, or (b) production code changes made and all existing tests still pass.

- [x] [P1-T3] Re-run pytest with focused coverage and confirm `>= 90%` on the bundled-runtime module.
  - Command: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=extensions.drm_copilot.resources.scripts.dev_tools.potential_to_issue --cov-report=term-missing`
  - **AC**: Coverage percentage for `potential_to_issue.py` is `>= 90%` and all tests pass.

### Phase 2 — Final QA Loop

- [x] [P2-T1] Final QA: run Black on bundled-runtime scope.
  - Command: `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/qa-gates/final-black.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Exit code 0; artifact exists with all four fields.

- [x] [P2-T2] Final QA: run Ruff on bundled-runtime scope.
  - Command: `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/qa-gates/final-ruff.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Exit code 0; artifact exists with all four fields.

- [x] [P2-T3] Final QA: run Pyright on bundled-runtime scope.
  - Command: `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
  - Store artifact: `evidence/qa-gates/final-pyright.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - **AC**: Exit code 0; artifact exists with all four fields.

- [x] [P2-T4] Final QA: run pytest with coverage on bundled-runtime scope.
  - Command: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=extensions.drm_copilot.resources.scripts.dev_tools.potential_to_issue --cov-report=term-missing`
  - Store artifact: `evidence/qa-gates/final-pytest-coverage.2026-04-05T15-00.md` with fields: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (must include numeric post-change coverage percentage).
  - **AC**: Exit code 0; coverage `>= 90%`; artifact exists with all four fields and numeric coverage value.

- [x] [P2-T5] Coverage delta verification: compare baseline coverage (from P0-T6 artifact) to final coverage (from P2-T4 artifact) and confirm no regression and `>= 90%` threshold met.
  - **AC**: Post-change coverage `>=` baseline coverage; post-change coverage `>= 90%`. Report baseline, post-change, and delta values.

## Constraints

- No scope creep beyond the bundled-runtime coverage gap.
- Do not weaken the repository coverage standard.
- Do not add `spec.md` or `user-story.md`.
- Preserve the already-satisfied `issue.md` acceptance criteria.

## Delegation Note

Automatic `atomic_planner` delegation could not be executed in this tool environment because no delegation surface was available here. This remediation plan file was created directly as a deterministic fallback so the remaining work is still captured in the expected feature folder.

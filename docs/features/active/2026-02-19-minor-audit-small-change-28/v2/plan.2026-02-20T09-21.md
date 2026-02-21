# 2026-02-19-minor-audit-small-change-28-v2 - Plan

- **Issue:** #28
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-20T09-21
- **Status:** Superceded
- **Version:** 2.0

![Status: Superceded](https://img.shields.io/badge/Status-Superceded-orange)

## Introduction

This plan implements deterministic minor-audit mode branching by persisting `- Work Mode: minor-audit|full` in `issue.md`, then updating producer tooling, reviewer/status agents, tests, and process docs so minor-audit work is audited correctly without false failures.

## Required References

- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`
- `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/python-suppressions.instructions.md`
- `.github/instructions/self-explanatory-code-commenting.instructions.md`
- `.github/skills/policy-compliance-order/SKILL.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/spec.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/user-story.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/research.md`

## Requirements Traceability

| Requirement ID | Requirement | Primary Files | Validation |
|---|---|---|---|
| REQ-001 | Persist deterministic work-mode marker in issue artifacts using exact format `- Work Mode: minor-audit|full`. | `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py` | Pytest scenarios in producer test modules pass. |
| REQ-002 | Marker reflects selected mode after eligibility fallback, not requested mode. | `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py` | Fallback scenario tests pass; output includes fallback reason. |
| REQ-003 | Reviewer agents branch AC source by marker (`issue.md` for minor-audit, `spec.md` + `user-story.md` for full). | `.github/agents/feature-review.agent.md`, `.github/agents/epic-review.agent.md` | Contract tests for agent docs pass. |
| REQ-004 | Status updater branches Delivered and evidence target by marker. | `.github/agents/status_updater.agent.md` | Contract tests for status updater doc pass. |
| REQ-005 | Feature promotion lifecycle skill includes work-mode in canonical commands and outputs. | `.github/skills/feature-promotion-lifecycle/SKILL.md` | Contract tests for skill doc pass. |
| REQ-006 | Process docs define deterministic minor-audit branch and constraints. | `docs/engineering/Feature Playbook.md`, `docs/features/templates/README.md` | Contract tests for process docs pass. |
| REQ-007 | Changes follow TDD red-then-green and produce auditable evidence artifacts. | `tests/scripts/dev_tools/*.py`, `tests/unit/test_minor_audit_mode_contract_docs.py`, `v2/evidence/*` | Expect-fail evidence and final QA evidence artifacts are schema-valid. |

## Constraints Registry

| Constraint ID | Constraint | Enforcement |
|---|---|---|
| CON-001 | Preserve backward-compatible full-mode behavior. | Existing full-mode tests remain passing; no behavior regressions in full branch scenarios. |
| CON-002 | No new runtime dependencies. | Dependency manifests unchanged. |
| CON-003 | Evidence schema fields required for baseline/regression/QA artifacts: `Timestamp`, `Command`, `EXIT_CODE`. | Evidence files are created with exact field labels. |
| CON-004 | Minor-audit must fail closed when marker is missing or malformed. | Agent contract text explicitly states default-to-full behavior. |

## Security Registry

| Security ID | Control | Enforcement |
|---|---|---|
| SEC-001 | Do not emit secrets into issue body, issue.md, or evidence artifacts. | Existing token-string negative test remains passing; no secret-like literals added. |
| SEC-002 | Preserve trusted evidence handling with canonical locations only. | Evidence paths are under `v2/evidence/` canonical subfolders. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Inputs, and Baseline Capture

- [x] [P0-T1] Record policy-read completion in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/baseline/policy-read.$TS.md` after reading all files listed in `## Required References` in the declared order.
  - Preconditions: Repository checkout on branch `feature/minor-audit-#28`.
  - Acceptance: Evidence file exists and contains exact labels `Timestamp:`, `Command: policy-read`, and `EXIT_CODE: 0`.

- [x] [P0-T2] Create canonical evidence directories under `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/`: `baseline/`, `regression-testing/`, `qa-gates/`, `other/`, `issue-updates/`.
  - Acceptance: Each directory exists and is writable.

- [x] [P0-T3] Capture baseline formatting status using `poetry run black --check .` and store output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/baseline/black-check.$TS.md`.
  - Acceptance: Evidence file includes `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture baseline lint status using `poetry run ruff check` and store output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/baseline/ruff-check.$TS.md`.
  - Acceptance: Evidence file includes `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture baseline type-check status using `poetry run pyright` and store output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/baseline/pyright-check.$TS.md`.
  - Acceptance: Evidence file includes `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture baseline test status using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` and store output in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/baseline/pytest-baseline.$TS.md`.
  - Acceptance: Evidence file includes `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — TDD Red for Producer Work-Mode Marker Behavior

- [x] [P1-T1] [expect-fail] Add pytest scenario in `tests/scripts/dev_tools/test_potential_to_issue.py` asserting `promote_potential` in minor-audit mode emits exact line `- Work Mode: minor-audit` above the first markdown section heading.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "work_mode_marker_minor_audit"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/potential-to-issue-minor-marker-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P1-T2] [expect-fail] Add pytest scenario in `tests/scripts/dev_tools/test_potential_to_issue.py` asserting ineligible `minor-audit` requests persist `- Work Mode: full` after fallback.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "work_mode_marker_fallback_full"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/potential-to-issue-fallback-marker-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P1-T3] [expect-fail] Add pytest scenario in `tests/scripts/dev_tools/test_new_active_feature_folder.py` asserting eligible `minor-audit` active folder creation writes `issue.md` with exact line `- Work Mode: minor-audit` above first `##` heading.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "work_mode_marker_minor_issue_md"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/new-active-folder-minor-marker-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P1-T4] [expect-fail] Add pytest scenario in `tests/scripts/dev_tools/test_new_active_feature_folder.py` asserting ineligible `minor-audit` fallback writes `issue.md` with exact line `- Work Mode: full`.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "work_mode_marker_fallback_issue_md_full"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/new-active-folder-fallback-marker-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

### Phase 2 — Implement Producer Marker Persistence and Green Producer Tests

- [x] [P2-T1] Implement `potential_to_issue.py` update in functions `build_minor_audit_body` and `build_body` to inject exactly one work-mode marker line immediately before the first `##` heading.
  - Depends on: [P1-T1], [P1-T2]
  - Acceptance: Marker placement is deterministic for both full and minor-audit outputs and no duplicate marker line appears.

- [x] [P2-T2] Implement `potential_to_issue.py` fallback-mode persistence so the marker value uses selected mode after eligibility evaluation (`full` on fallback).
  - Depends on: [P2-T1]
  - Acceptance: Fallback path body contains `- Work Mode: full` while selected minor path contains `- Work Mode: minor-audit`.

- [x] [P2-T3] Implement `new_active_feature_folder.py` update in minor-audit issue body generation path to insert exactly one work-mode marker line before first `##` heading in generated `issue.md`.
  - Depends on: [P1-T3], [P1-T4]
  - Acceptance: Generated `issue.md` contains exactly one marker line and required minor-audit sections remain unchanged.

- [x] [P2-T4] Implement `new_active_feature_folder.py` fallback-mode persistence so ineligible `minor-audit` requests write `- Work Mode: full` in resulting `issue.md`.
  - Depends on: [P2-T3]
  - Acceptance: Fallback output marker equals selected mode and existing fallback messaging remains present.

- [x] [P2-T5] Run targeted producer tests: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "work_mode_marker_minor_audit or work_mode_marker_fallback_full"`.
  - Depends on: [P2-T2]
  - Acceptance: Command exits with code `0`.

- [x] [P2-T6] Run targeted producer tests: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "work_mode_marker_minor_issue_md or work_mode_marker_fallback_issue_md_full"`.
  - Depends on: [P2-T4]
  - Acceptance: Command exits with code `0`.

### Phase 3 — TDD Red and Green for Agent/Skill/Process Contract Updates

- [x] [P3-T1] [expect-fail] Add new contract test module `tests/unit/test_minor_audit_mode_contract_docs.py` with scenario asserting `.github/agents/feature-review.agent.md` explicitly branches AC source by persisted marker (`minor-audit` uses `issue.md`; `full` uses `spec.md` + `user-story.md`).
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_branching_contract"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/feature-review-contract-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P3-T2] [expect-fail] Add scenario in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/agents/epic-review.agent.md` doc-completeness logic allows missing `spec.md` and `user-story.md` when `Work Mode: minor-audit` and states fallback-to-full on missing marker.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "epic_review_minor_audit_doc_completeness_contract"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/epic-review-contract-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P3-T3] [expect-fail] Add scenario in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/agents/status_updater.agent.md` branches Delivered and evidence targets by persisted marker.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "status_updater_branching_contract"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/status-updater-contract-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P3-T4] [expect-fail] Add scenario in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/skills/feature-promotion-lifecycle/SKILL.md` canonical commands include `--work-mode` and output expectations include minor-audit branch semantics.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_promotion_lifecycle_work_mode_contract"` fails and failure evidence is saved to `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/regression-testing/feature-promotion-skill-contract-red.$TS.md` with `Timestamp:`, `Command:`, and non-zero `EXIT_CODE:`.

- [x] [P3-T5] Update `.github/agents/feature-review.agent.md` to parse persisted marker from `issue.md`, extract AC from `issue.md` for minor-audit, preserve existing full-mode AC extraction, and declare missing-marker fallback to full.
  - Depends on: [P3-T1]
  - Acceptance: Doc contains explicit deterministic branching rules matching REQ-003.

- [x] [P3-T6] Update `.github/agents/epic-review.agent.md` to branch doc completeness and AC extraction by marker, including explicit `minor-audit: spec/user-story may be absent by design` behavior.
  - Depends on: [P3-T2]
  - Acceptance: Doc contains deterministic doc-completeness branch and marker fallback behavior.

- [x] [P3-T7] Update `.github/agents/status_updater.agent.md` to branch Delivered computation and evidence append target by marker (`issue.md` for minor-audit, spec/user-story for full).
  - Depends on: [P3-T3]
  - Acceptance: Doc includes explicit minor-audit and full-mode Delivered definitions.

- [x] [P3-T8] Update `.github/skills/feature-promotion-lifecycle/SKILL.md` canonical commands and required outputs to include `--work-mode` and minor-audit semantics.
  - Depends on: [P3-T4]
  - Acceptance: Skill file includes deterministic mode-aware command and output contracts.

- [x] [P3-T9] Update `docs/engineering/Feature Playbook.md` to codify persisted marker contract, fail-closed rule, and eligibility fallback behavior.
  - Acceptance: Playbook explicitly states marker format, location, and fallback-to-full behavior.

- [x] [P3-T10] Update `docs/features/templates/README.md` to codify decision-tree branch using persisted marker and minor-audit artifact expectations.
  - Acceptance: README includes explicit marker-driven branch criteria.

- [x] [P3-T11] Run contract test module: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py`.
  - Depends on: [P3-T5], [P3-T6], [P3-T7], [P3-T8], [P3-T9], [P3-T10]
  - Acceptance: Command exits with code `0`.

### Phase 4 — Final QA Loop and Evidence Pack

- [x] [P4-T1] Run formatter pass: `poetry run black .`.
  - Acceptance: Command exits with code `0`.

- [x] [P4-T2] Run lint pass: `poetry run ruff check`.
  - Depends on: [P4-T1]
  - Acceptance: Command exits with code `0`; if any file changes or failures occur, restart Phase 4 from [P4-T1].

- [x] [P4-T3] Run type-check pass: `poetry run pyright`.
  - Depends on: [P4-T2]
  - Acceptance: Command exits with code `0`; if failures occur, restart Phase 4 from [P4-T1].

- [x] [P4-T4] Run test pass: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Depends on: [P4-T3]
  - Acceptance: Command exits with code `0`; if failures occur, restart Phase 4 from [P4-T1].

- [x] [P4-T5] Record final QA summary in `docs/features/active/2026-02-19-minor-audit-small-change-28/v2/evidence/qa-gates/final-qa.$TS.md`.
  - Depends on: [P4-T4]
  - Acceptance: Evidence file includes exact labels `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` covering formatter, lint, type-check, and tests.

- [x] [P4-T6] Verify REQ/SEC/CON closure by updating this plan checklist items and confirming every requirement in `## Requirements Traceability` is satisfied by completed evidence.
  - Depends on: [P4-T5]
  - Acceptance: No unchecked task remains for delivered scope and each REQ row maps to passing validation evidence.

## Test Plan

- Unit tests (producer behavior):
  - `tests/scripts/dev_tools/test_potential_to_issue.py`
    - Scenario A: minor-audit selected mode persists `- Work Mode: minor-audit` above first `##` heading.
    - Scenario B: fallback selected mode persists `- Work Mode: full`.
  - `tests/scripts/dev_tools/test_new_active_feature_folder.py`
    - Scenario C: eligible minor-audit generated `issue.md` persists `- Work Mode: minor-audit` above first `##` heading.
    - Scenario D: ineligible minor-audit fallback generated `issue.md` persists `- Work Mode: full`.

- Unit tests (agent/skill/doc contract behavior):
  - `tests/unit/test_minor_audit_mode_contract_docs.py`
    - Scenario E: feature review marker-driven AC source branch exists.
    - Scenario F: epic review marker-driven doc-completeness and AC source branch exists.
    - Scenario G: status updater marker-driven Delivered branch exists.
    - Scenario H: feature promotion lifecycle canonical commands include `--work-mode` and minor-audit output semantics.
    - Scenario I: process docs include marker format and fail-closed guidance.

- Security regression guard:
  - Preserve existing token-string negative assertion in `tests/scripts/dev_tools/test_potential_to_issue.py` so marker changes do not introduce secret-like content.

## Open Questions / Notes

- None.

# 2026-02-19-minor-audit-small-change-28-v3 - Plan

- **Issue:** #28
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-21T11-38
- **Status:** Completed
- **Version:** 3.0
- Remediation Plan: remediation-plan.2026-02-21T12-40.md
- Remediation Status: Complete

![Status: Complete](https://img.shields.io/badge/Status-Completed-brightgreen)

## Introduction

This plan delivers `v3/spec.md` and `v3/user-story.md` by enforcing deterministic, machine-readable mode routing (`minor-audit|full`) across producer scripts, planning/execution agents, and shared planning contracts, with fail-closed behavior and auditable evidence.

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
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/spec.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/user-story.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/research.md`

## Requirements Traceability

| Requirement ID | Requirement | Primary Files | Validation |
|---|---|---|---|
| REQ-001 | Persist exactly one marker line in issue metadata using `- Work Mode: minor-audit|full` above first `##` heading. | `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py` | Producer unit tests pass for marker placement and single-marker invariant. |
| REQ-002 | Marker value reflects selected mode after eligibility fallback, not requested mode. | `scripts/dev_tools/potential_to_issue.py`, `scripts/dev_tools/new_active_feature_folder.py` | Producer fallback tests pass and assert `- Work Mode: full` on fallback. |
| REQ-003 | Planning/execution agents resolve mode from `issue.md` marker and fail closed to `full` when marker is missing/malformed. | `.github/agents/atomic_planning.agent.md`, `.github/agents/atomic_executor.agent.md`, `.github/agents/python-typed-engineer.agent.md`, `.github/agents/powershell-atomic-planning.agent.md`, `.github/agents/powershell-atomic-executor.agent.md` | Contract tests pass for all five agent files and three marker states. |
| REQ-004 | Shared planning contract enforces mode-aware preflight gates and canonical preflight signals. | `.github/skills/atomic-plan-contract/SKILL.md` | Contract tests pass for required directive and both exact preflight signals. |
| REQ-005 | Feature promotion lifecycle skill and plan template enforce mode-aware plan generation with zero placeholders. | `.github/skills/feature-promotion-lifecycle/SKILL.md`, `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` | Contract tests pass for `--work-mode` requirements and no-placeholder template checks. |
| REQ-006 | Reviewer/status flow for minor-audit consumes `issue.md` AC/evidence without false failure on missing `spec.md`/`user-story.md`. | `.github/agents/feature-review.agent.md`, `.github/agents/epic-review.agent.md`, `.github/agents/status_updater.agent.md` | Existing plus updated contract tests pass for marker-driven routing expectations. |
| REQ-007 | Deterministic routing is covered by contract and smoke tests for marker states `minor-audit`, `full`, and missing/malformed. | `tests/unit/test_minor_audit_mode_contract_docs.py`, `tests/unit/test_minor_audit_mode_smoke.py`, `tests/fixtures/minor_audit_mode/*.md` | Test commands exit `0`; smoke tests assert fallback to `full` on missing/malformed marker. |
| REQ-008 | Evidence artifacts follow canonical locations and machine-checkable schema fields. | `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/**` | Evidence files contain exact labels `Timestamp`, `Command`, `EXIT_CODE`; baseline files include `Output Summary`. |

## Constraints Registry

| Constraint ID | Constraint | Enforcement |
|---|---|---|
| CON-001 | Preserve backward-compatible full-mode behavior. | Existing full-path tests remain passing in targeted and full pytest runs. |
| CON-002 | Add no runtime dependencies. | `pyproject.toml` and `package.json` unchanged. |
| CON-003 | Use canonical evidence folder layout for baseline, regression-testing, other, qa-gates, and issue-updates. | Evidence files are written only under `v3/evidence/<canonical-folder>/`. |
| CON-004 | Plan format must be executor-ingestible without replanning. | Preflight validation loop returns `PREFLIGHT: ALL CLEAR`. |

## Security Registry

| Security ID | Control | Enforcement |
|---|---|---|
| SEC-001 | Do not introduce secret-like literals into issue artifacts, evidence artifacts, or tests. | Existing secret/token negative tests remain passing. |
| SEC-002 | Maintain fail-closed behavior to prevent under-auditing. | Smoke tests verify missing/malformed marker routes to `full`. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Inputs, and Baseline Capture

- [x] [P0-T1] Record policy-read evidence in `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/baseline/policy-read.2026-02-21T12-30.md` after reading every entry in `## Required References` in listed order.
  - Acceptance: File exists and contains exact lines `Timestamp: 2026-02-21T12-30`, `Command: policy-read`, and `EXIT_CODE: 0`.

- [x] [P0-T2] Create canonical evidence directories under `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/`: `baseline/`, `regression-testing/`, `other/`, `qa-gates/`, `issue-updates/`.
  - Acceptance: Each directory exists; directory existence is verifiable by listing all five paths.

- [x] [P0-T3] Capture baseline formatter status using `poetry run black --check .` into `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/baseline/black-check.2026-02-21T12-30.md`.
  - Acceptance: Evidence file contains exact labels `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture baseline lint status using `poetry run ruff check` into `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/baseline/ruff-check.2026-02-21T12-30.md`.
  - Acceptance: Evidence file contains exact labels `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture baseline type-check status using `poetry run pyright` into `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/baseline/pyright-check.2026-02-21T12-30.md`.
  - Acceptance: Evidence file contains exact labels `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture baseline tests status using `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` into `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/baseline/pytest-baseline.2026-02-21T12-30.md`.
  - Acceptance: Evidence file contains exact labels `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:`.

Phase completion criteria: Baseline evidence files from [P0-T1], [P0-T3], [P0-T4], [P0-T5], and [P0-T6] exist and satisfy required schema fields; canonical evidence directories from [P0-T2] also exist.

### Phase 1 — TDD Red: Contract and Smoke Test Expansion

- [x] [P1-T1] [expect-fail] Add test `test_atomic_planning_agent_requires_mode_resolution_contract` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/agents/atomic_planning.agent.md` includes marker-first mode resolution and fail-closed-to-full text.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "atomic_planning_agent_requires_mode_resolution_contract"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/atomic-planning-contract-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T2] [expect-fail] Add test `test_atomic_executor_agent_requires_preflight_mode_gate_contract` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/agents/atomic_executor.agent.md` contains mode-aware preflight rejection criteria.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "atomic_executor_agent_requires_preflight_mode_gate_contract"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/atomic-executor-contract-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T3] [expect-fail] Add test `test_python_typed_engineer_requires_mode_aware_planning_handoff_contract` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/agents/python-typed-engineer.agent.md` requires mode-aware planning and evidence obligations.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "python_typed_engineer_requires_mode_aware_planning_handoff_contract"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/python-typed-engineer-contract-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T4] [expect-fail] Add test `test_powershell_atomic_agents_require_mode_aware_preflight_contract` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting both `.github/agents/powershell-atomic-planning.agent.md` and `.github/agents/powershell-atomic-executor.agent.md` declare mode-first routing and fail-closed behavior.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "powershell_atomic_agents_require_mode_aware_preflight_contract"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/powershell-atomic-contract-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T5] [expect-fail] Add test `test_atomic_plan_contract_skill_requires_preflight_directive_and_signals` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `.github/skills/atomic-plan-contract/SKILL.md` contains exact directive text and both exact result signals.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "atomic_plan_contract_skill_requires_preflight_directive_and_signals"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/atomic-plan-contract-skill-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T6] [expect-fail] Add test `test_feature_plan_template_forbids_placeholder_tokens` in `tests/unit/test_minor_audit_mode_contract_docs.py` asserting `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` contains zero occurrences of `<Phase Name>`, `<Atomic task`, `TBD`, and `Add language-specific policies as needed`.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_plan_template_forbids_placeholder_tokens"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/plan-template-placeholder-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T7] [expect-fail] Add smoke test file `tests/unit/test_minor_audit_mode_smoke.py` containing scenario `test_mode_resolution_selects_minor_audit_for_valid_marker` using fixture `tests/fixtures/minor_audit_mode/issue.valid-minor.md` and expected resolved mode `minor-audit`.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py -k "selects_minor_audit_for_valid_marker"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/smoke-valid-minor-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T8] [expect-fail] Add smoke test scenario `test_mode_resolution_selects_full_for_valid_full_marker` in `tests/unit/test_minor_audit_mode_smoke.py` using fixture `tests/fixtures/minor_audit_mode/issue.valid-full.md` and expected resolved mode `full`.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py -k "selects_full_for_valid_full_marker"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/smoke-valid-full-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

- [x] [P1-T9] [expect-fail] Add smoke test scenario `test_mode_resolution_fails_closed_to_full_for_missing_or_malformed_marker` in `tests/unit/test_minor_audit_mode_smoke.py` using fixtures `tests/fixtures/minor_audit_mode/issue.missing-marker.md` and `tests/fixtures/minor_audit_mode/issue.malformed-marker.md` and expected resolved mode `full`.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py -k "fails_closed_to_full_for_missing_or_malformed_marker"` exits non-zero and evidence is written to `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/regression-testing/smoke-fail-closed-red.2026-02-21T12-30.md` with `Timestamp`, `Command`, `EXIT_CODE`.

Phase completion criteria: Nine expect-fail tasks are completed with schema-valid regression evidence artifacts.

### Phase 2 — Implement Mode-Aware Agent and Skill Contracts

- [x] [P2-T1] Update `.github/agents/atomic_planning.agent.md` to require parsing `- Work Mode: minor-audit|full` from feature `issue.md`, specify mode source precedence, and require fail-closed default to `full` for missing/malformed marker.
  - Depends on: [P1-T1]
  - Acceptance: File contains explicit directives for marker-first resolution, fallback to `full`, and mode-specific preflight plan gates.

- [x] [P2-T2] Update `.github/agents/atomic_executor.agent.md` to require preflight rejection when selected mode obligations are absent and to preserve exact validation signals `PREFLIGHT: ALL CLEAR` and `PREFLIGHT: REVISIONS REQUIRED`.
  - Depends on: [P1-T2]
  - Acceptance: File contains explicit mode-aware validation-only branch criteria and no contradictory signal text.

- [x] [P2-T3] Update `.github/agents/python-typed-engineer.agent.md` to require mode-aware planning handoff obligations: `minor-audit` requires baseline+targeted+end-state evidence; `full` requires full-doc and full QA obligations.
  - Depends on: [P1-T3]
  - Acceptance: File contains explicit mode branching obligations and fail-closed behavior for missing/malformed marker.

- [x] [P2-T4] Update `.github/agents/powershell-atomic-planning.agent.md` to require mode-aware preflight criteria equivalent to generic atomic planner with fail-closed routing.
  - Depends on: [P1-T4]
  - Acceptance: File contains marker-driven mode resolution and branch-specific required task sets.

- [x] [P2-T5] Update `.github/agents/powershell-atomic-executor.agent.md` to require mode-aware preflight validation and to reject minor-audit plans missing baseline/targeted/end-state evidence tasks.
  - Depends on: [P1-T4]
  - Acceptance: File contains explicit reject conditions for missing mode-specific evidence gates.

- [x] [P2-T6] Update `.github/skills/atomic-plan-contract/SKILL.md` to encode exact preflight directive line, exact result signals, mode source precedence, and mode-specific mandatory plan gates.
  - Depends on: [P1-T5]
  - Acceptance: Skill contains exact strings `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, `PREFLIGHT: ALL CLEAR`, and `PREFLIGHT: REVISIONS REQUIRED`, plus mode-branch gate details.

- [x] [P2-T7] Update `.github/skills/feature-promotion-lifecycle/SKILL.md` to require canonical commands with `--work-mode`, selected-mode persistence, and fallback marker behavior.
  - Acceptance: Skill explicitly states selected-mode persistence and fail-closed consistency with `issue.md` marker.

- [x] [P2-T8] Run contract test command `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py`.
  - Depends on: [P2-T1], [P2-T2], [P2-T3], [P2-T4], [P2-T5], [P2-T6], [P2-T7]
  - Acceptance: Command exits with code `0`.

Phase completion criteria: All targeted agent/skill contract tests pass.

### Phase 3 — Implement Template and Smoke Routing Artifacts

- [x] [P3-T1] Update `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` to remove all placeholder tokens and replace them with deterministic, executor-compatible phase/task skeleton using canonical headings `### Phase N — <Title>` and task IDs `- [ ] [P#-T#]`.
  - Depends on: [P1-T6]
  - Acceptance: Template file contains zero occurrences of `<Phase Name>`, `<Atomic task`, `TBD`, and `Add language-specific policies as needed`.

- [x] [P3-T2] Add fixture file `tests/fixtures/minor_audit_mode/issue.valid-minor.md` with metadata block containing exact line `- Work Mode: minor-audit` above first `##` heading.
  - Depends on: [P1-T7]
  - Acceptance: Fixture file exists and includes exactly one `Work Mode` marker with value `minor-audit`.

- [x] [P3-T3] Add fixture file `tests/fixtures/minor_audit_mode/issue.valid-full.md` with metadata block containing exact line `- Work Mode: full` above first `##` heading.
  - Depends on: [P1-T8]
  - Acceptance: Fixture file exists and includes exactly one `Work Mode` marker with value `full`.

- [x] [P3-T4] Add fixture file `tests/fixtures/minor_audit_mode/issue.missing-marker.md` with no `Work Mode` marker and one `##` section heading.
  - Depends on: [P1-T9]
  - Acceptance: Fixture file exists and contains zero lines matching regex `^-\s*Work Mode:`.

- [x] [P3-T5] Add fixture file `tests/fixtures/minor_audit_mode/issue.malformed-marker.md` with malformed marker line `- Work Mode: minor audit` and one `##` section heading.
  - Depends on: [P1-T9]
  - Acceptance: Fixture file exists and marker line does not match allowed values `minor-audit|full`.

- [x] [P3-T6] Implement helper function `resolve_work_mode_from_issue_text(issue_text: str) -> str` in `tests/unit/test_minor_audit_mode_smoke.py` to parse marker with regex and return `full` on missing/malformed marker.
  - Depends on: [P1-T7], [P1-T8], [P1-T9]
  - Acceptance: Function is used by all three smoke tests and each smoke test command exits `0`.

- [x] [P3-T7] Run smoke test command `poetry run pytest tests/unit/test_minor_audit_mode_smoke.py`.
  - Depends on: [P3-T2], [P3-T3], [P3-T4], [P3-T5], [P3-T6]
  - Acceptance: Command exits with code `0`.

Phase completion criteria: Template placeholders are eliminated and all three routing smoke states pass.

### Phase 4 — Producer, Reviewer, and Status Consistency Verification

- [x] [P4-T1] Add or update producer test scenario `test_promote_potential_persists_selected_work_mode_after_fallback` in `tests/scripts/dev_tools/test_potential_to_issue.py` for requested `minor-audit` that falls back to selected `full` marker.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k "persists_selected_work_mode_after_fallback"` exits with code `0`.

- [x] [P4-T2] Add or update producer test scenario `test_new_active_feature_folder_writes_single_work_mode_marker_before_first_heading` in `tests/scripts/dev_tools/test_new_active_feature_folder.py` to assert single-marker placement.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -k "writes_single_work_mode_marker_before_first_heading"` exits with code `0`.

- [x] [P4-T3] Add or update contract scenario `test_feature_review_epic_review_status_updater_branch_by_marker` in `tests/unit/test_minor_audit_mode_contract_docs.py` verifying `minor-audit` consumes `issue.md` and `full` consumes `spec.md` + `user-story.md`.
  - Acceptance: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_review_epic_review_status_updater_branch_by_marker"` exits with code `0`.

- [x] [P4-T4] Run combined targeted verification command `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_new_active_feature_folder.py tests/unit/test_minor_audit_mode_contract_docs.py tests/unit/test_minor_audit_mode_smoke.py`.
  - Depends on: [P4-T1], [P4-T2], [P4-T3]
  - Acceptance: Command exits with code `0`.

Phase completion criteria: Producer and consumer routing consistency is proven by targeted test suite pass.

### Phase 5 — Final QA Loop and Evidence Closure

- [x] [P5-T1] Run formatter command `poetry run black .`.
  - Acceptance: Command exits with code `0`.

- [x] [P5-T2] Run linter command `poetry run ruff check`.
  - Depends on: [P5-T1]
  - Acceptance: Command exits with code `0`; if command fails or modifies files, restart Phase 5 from [P5-T1].

- [x] [P5-T3] Run type-check command `poetry run pyright`.
  - Depends on: [P5-T2]
  - Acceptance: Command exits with code `0`; if command fails, restart Phase 5 from [P5-T1].

- [x] [P5-T4] Run full test command `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`.
  - Depends on: [P5-T3]
  - Acceptance: Command exits with code `0`; if command fails, restart Phase 5 from [P5-T1].

- [x] [P5-T5] Write final QA evidence file `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/evidence/qa-gates/final-qa.2026-02-21T12-30.md` containing the four Phase 5 commands and outcomes.
  - Depends on: [P5-T4]
  - Acceptance: Evidence file contains exact labels `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P5-T6] Verify plan closure by confirming every REQ/CON/SEC row maps to passing evidence and by checking all checkboxes for delivered scope.
  - Depends on: [P5-T5]
  - Acceptance: No unresolved requirement row remains and no placeholder token appears in this plan.

Phase completion criteria: Full toolchain passes in one clean loop and closure evidence is complete.

## Test Plan

- Unit tests (producer behavior):
  - `tests/scripts/dev_tools/test_potential_to_issue.py`
    - Scenario A: marker placement for selected `minor-audit`.
    - Scenario B: marker fallback to selected `full` after ineligible minor request.
  - `tests/scripts/dev_tools/test_new_active_feature_folder.py`
    - Scenario C: single marker line exists above first `##` heading.
    - Scenario D: fallback marker is `full` when ineligible.

- Unit tests (contracts and routing):
  - `tests/unit/test_minor_audit_mode_contract_docs.py`
    - Scenario E: atomic planner contract includes marker-first resolution.
    - Scenario F: atomic executor contract includes mode-aware preflight reject rules.
    - Scenario G: python/powershell planning-execution agents include mode-aware routing.
    - Scenario H: shared skills include exact preflight directive/signals and mode gates.
    - Scenario I: template placeholder ban and mode-aware generation requirements.
  - `tests/unit/test_minor_audit_mode_smoke.py`
    - Scenario J: valid `minor-audit` marker resolves to `minor-audit`.
    - Scenario K: valid `full` marker resolves to `full`.
    - Scenario L: missing/malformed marker resolves to `full`.

- Security and fail-closed checks:
  - Preserve existing secret/token negative assertions.
  - Verify fallback routing to `full` on missing/malformed marker.

## Open Questions / Notes

- None.

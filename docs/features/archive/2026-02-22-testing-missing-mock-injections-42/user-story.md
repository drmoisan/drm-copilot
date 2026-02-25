# `testing-missing-mock-injections` — User Story

- Issue: #42
- Owner: Dan Moisan
- Status: In Progress
- Last Updated: 2026-02-22

## Story Statement

- As a maintainer, I want dev-tools unit tests to avoid real VS Code subprocess launches, so that tests remain deterministic and side-effect free.
- As a contributor, I want guardrails that fail fast on unmocked launcher usage, so that regressions are caught early.

## Problem / Why

Some unit tests call `create_active_folder(...)` without a fake launcher and accidentally invoke the real editor launcher. This can create host-side effects and break test isolation.

## Personas & Scenarios

- Persona: repository maintainer
  - cares about deterministic CI
  - needs hermetic tests
  - wants quick diagnosis when isolation breaks
  - wants clear evidence artifacts per plan
- Scenario: contributor runs targeted dev-tools tests
  - trigger: local test execution
  - action: runs pytest for dev-tools test module
  - outcome: tests pass without launching real editor subprocesses

## Acceptance Criteria

- [x] All missing `create_active_folder(...)` callsites inject `code_launcher=FakeCodeLauncher()`.
- [x] Scoped guard fixture fails on unmocked `code` launcher subprocess attempts.
- [x] Targeted tests and full Python QA loop pass with evidence artifacts recorded.

## Validation Outcome

- Guard and launcher compatibility verification: `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/guard-and-launcher-verification.2026-02-22T15-25.md`
- Final QA loop summary: `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/qa-loop-summary.2026-02-22T15-25.md`

## Non-Goals

- Changing production launcher behavior in `scripts/dev_tools/new_active_feature_folder_*.py`.

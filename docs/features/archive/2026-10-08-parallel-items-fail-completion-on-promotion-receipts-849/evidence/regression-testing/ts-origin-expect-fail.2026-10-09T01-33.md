# TypeScript Origin Fail-Before Evidence (P2-T4, Issue #849)

Timestamp: 2026-10-10T10-21
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts
ExpectedExitCode: 1
EXIT_CODE: 1
State: before the validator change (Phase 3 not started).

## Jest summary (verbatim)

```text
Test Suites: 1 failed, 1 total
Tests:       3 failed, 4 passed, 7 total
```

## Failed titles (verbatim)

```text
  ● issue-adoption potential_record requirement by origin (issue #849) › waives the bug entry tool without a record when origin is filed_before_orchestration
  ● issue-adoption potential_record requirement by origin (issue #849) › waives the feature entry tool without a record when origin is transferred
  ● issue-adoption potential_record requirement by origin (issue #849) › waives the bug entry tool without a record on the preparation route
```

These are the first three titles of the TypeScript list in "New Test Specifications". The remaining four cases (rule 9 still reported for `epic_decomposition` without a record, a null record, an invalid record path, and an invalid origin) pass.

## First failure detail (verbatim, ANSI codes omitted)

```text
    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 3

    - Array []
    + Array [
    +   "Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving new_potential_bug_entry.",
    + ]
```

Output Summary: EXIT_CODE 1 equals ExpectedExitCode 1 (non-zero). Tests: 3 failed, 4 passed, 7 total. The failures are the first three titles; each receives the rule-9 potential_record error instead of an empty error list before the fix.

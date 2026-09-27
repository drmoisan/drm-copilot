# remaining-cannot-fail-count-assertions (Issue #711)

- Date captured: 2026-09-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/ (Issue #711)

> Source: populated from the GitHub issue #711 body. The promoted lifecycle record is not present on this branch, so `new_active_feature_folder` found no potential source to copy.

- Issue: #711
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/711
- Last Updated: 2026-09-26
- Work Mode: full-bug

## Summary

Issue #513 (PR #702) fixed three Pester non-emptiness assertions that could never fail. Five more occurrences of the same defect class were identified and deliberately left out of scope under its decision D3.

## Environment

- OS/version: any
- Python version: n/a (Pester)
- Command/flags used: the Pester suites listed below
- Data source or fixture: n/a

## Steps to Reproduce

1. Empty the collection each assertion guards.
2. Observe that the assertion still passes, because the count is computed over a wrapped value that is never empty.

## Expected Behavior

Each non-emptiness assertion fails when its input is empty.

## Actual Behavior

These locations still use the vacuous form (line numbers as recorded in the issue):

- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1:251`: `mandate_reads`, two-statement form.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:457`
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:155`
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1:333`
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:133`

## Logs / Screenshots

- Snippet: #513 `spec.md`, the Scope section and "Rollout & Follow-up".

## Impact / Severity

- [x] Low

## Acceptance Criteria

- [ ] AC-1: The `mandate_reads` non-emptiness assertion in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` fails when the guarded collection is empty or null.
- [ ] AC-2: The non-emptiness assertion in `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (issue-cited line 457) fails when the guarded collection is empty or null.
- [ ] AC-3: The non-emptiness assertion in `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (issue-cited line 155) fails when the guarded collection is empty or null.
- [ ] AC-4: The non-emptiness assertion in `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (issue-cited line 333) fails when the guarded collection is empty or null.
- [ ] AC-5: The non-emptiness assertion in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (issue-cited line 133) fails when the guarded collection is empty or null.
- [ ] AC-6: All four affected Pester suites pass after the change, with no reduction in test count.

## Source

From: docs/features/potential/2026-09-26-remaining-cannot-fail-count-assertions.md (lifecycle record not present on this branch)

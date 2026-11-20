# issue-adoption-pester-folder-scoped-command-not-found (Potential Bug)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: observation during issue #484 execution (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/evidence/baseline/pester-receipts-coverage-baseline.md`, plan task P0-T30; deviation D10)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

When Pester runs the whole `tests/scripts/claude-lib/orchestrator-state` folder with code coverage enabled, 38 cases in `OrchestratorStateIssueAdoption.Tests.ps1` (added by #509) fail with `The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized`. The same cases pass in the full PoshQC gate. The failure is present on the integration branch before any #484 change.

## Environment

- OS/version: Windows 11, pwsh 7.6.6, Pester 5.6.1
- Python version: not applicable
- Command/flags used: `New-PesterConfiguration` with `Run.Path = tests/scripts/claude-lib/orchestrator-state`, `CodeCoverage.Enabled = $true`, `CodeCoverage.Path = .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`
- Data source or fixture: integration branch `epic/orchestrator-state-contract-correctness-integration` at `40faab41`

## Steps to Reproduce

1. Check out the integration branch at or after `40faab41`.
2. Run the configuration above through `Invoke-Pester -Configuration`.
3. Inspect the failures in `OrchestratorStateIssueAdoption.Tests.ps1`.

## Expected Behavior

All cases pass when run as part of the folder, as they do in the full gate.

## Actual Behavior

38 failures, all `CommandNotFoundException` for `Get-OrchestratorStateIssueAdoptionResult` raised at test line 92, in four groups (AC-6: 10, AC-7: 20, AC-8: 6, AC-9/AC-11: 2).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Probably a test-isolation problem with import order. A sibling test file re-imports a module with `-Force` and removes the command from the session scope that this file's tests rely on. #484 hit the same mechanism in its own accounting test (deviation D5) and fixed it by reordering the imports in `BeforeAll`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: make the test file import the module it calls last in `BeforeAll`, or use `InModuleScope`
- [ ] Integration scenario to retest: the folder-scoped coverage run above reports 0 failures
- [ ] Manual verification notes: the full PoshQC gate stays green

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

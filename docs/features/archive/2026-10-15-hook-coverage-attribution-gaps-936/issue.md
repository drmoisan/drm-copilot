# hook-coverage-attribution-gaps (Issue #936)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-coverage-attribution-gaps/ (Issue #936)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #936
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/936
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

Two hook lines that are executed by tests are not attributed in CI PowerShell coverage. Recorded by #903 (Operator Follow-up 7 and policy-audit PA-2).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. CI run 38410234897: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (catch body) shows ci 0.
2. CI run 38423196404: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207` show ci 0 although test ES-D1 asserts the exact deny reason that only line 207 produces.

## Expected Behavior

Executed lines are attributed, or the cause of the non-attribution is documented with a test that covers the line.

## Actual Behavior

The lines report 0 hits.

## Acceptance Criteria

- [x] AC-1: The `.DESCRIPTION` comment-help header of `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` contains a note that names `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` line 41, names the H2 codex deny rows and their line-unique assertion, describes the Pester 5.x breakpoint-mode cause (each line breakpoint binds to the first compiled instance of a script, so a later recompilation leaves later executions unattributed), and references issue #936; verified by reading the header of the file.
- [x] AC-2: The `.DESCRIPTION` comment-help header of `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` contains a note that names `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 183, 190, 191, 206, 207, and 209, names ES-D1 and ES-D2 and the exact-reason assertion, describes the same Pester 5.x breakpoint-mode cause, and references issue #936; verified by reading the header of the file.
- [x] AC-3: The branch diff of the two test files against origin/main changes only `.DESCRIPTION` comment-help text (no test logic, no `It`, `Describe`, `Mock`, or assertion line is added, removed, or altered), and each file remains under 500 lines; verified by `git diff origin/main` on the two files and a line count of each.
- [x] AC-4: An evidence artifact under `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/` records the `<line>` elements from `artifacts/pester/powershell-coverage.xml` produced by a PoshQC MCP test run scoped to `tests/scripts/codex-hooks`, taken from the `.codex/hooks` package (not the same-basename `.claude/hooks` entries), showing `ci` of at least 1 for `enforce-orchestration-preimplementation-gate-modes.ps1` line 41 and `enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 206 and 207.
- [x] AC-5: The PR head's `poshqc / PowerShell QC` job (windows-latest; coverage enabled) passes, and an evidence artifact under `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/` records the `.codex/hooks` package `<line>` elements for `enforce-orchestration-preimplementation-gate-modes.ps1` line 41 and `enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 206 and 207 from the `poshqc-test-results` artifact of that job, documenting that they may remain `ci="0"` in the full run as the known exception; this criterion is CI-dependent and is checked off only after CI has run.
- [x] AC-6: The H2 codex deny rows in `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` and the ES-D1 and ES-D2 tests in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` pass; verified by a recorded PoshQC test result or `pester-junit.xml` entries with `status="Passed"`.
- [x] AC-7: PoshQC format and PoshQC analyze report no findings for `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`; verified by recorded PoshQC tool results.
- [x] AC-8: The branch diff against origin/main changes no file other than the two test files named in AC-1 and AC-2 and files under `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/`; in particular no production hook, coverage configuration (`config/poshqc-coverage.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), or CI workflow file is changed; verified by `git diff --name-only origin/main...HEAD`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 policy-audit.2026-10-13T16-01.md PA-2; issue.md Operator Follow-up 7.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Item 7 was routed to the owner of hook-import-failure-exemptions.FailClosed.Tests.ps1 (epic #852 C4 / #786).

## Proposed Fix / Validation Ideas

- [ ] Add a test that covers modes.ps1:41.
- [ ] Investigate why ES-D1 does not attribute epic-scope 206-207 (stub construction or a separate runspace) and fix or document it.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
# Codex selector fail-before run (remediation cycle 1, CR-4 and R1) [expect-fail]

Timestamp: 2026-10-16T15-47
Task: [P2-T10]
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]; then Grep WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `codex-hooks` on those lines, `returns 5 for gh pr merge --merge=true 5`, and `status="Failed"`
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 1."}; JUNIT_FAILED=1 (the F2 testcase only)
JUnitFreshness: FRESH
Baseline (P0-T8 t-codex-hooks): GREEN-AFTER-PIN

## Freshness

- F1: 68 lines match `<testsuite name=`; 68 lines match `<testsuite name="[^"]*codex-hooks`.
- F2: testcase `...Get-EpicMergeGateSelectorPrNumber.returns 5 for gh pr merge --merge=true 5` present (junit line 973), classname ends with `enforce-epic-merge-gate-command.Tests.ps1`; this testcase exists only after P2-T1.

## Failing set

- `Codex enforce-epic-merge-gate-command selector reader (issue #952).Get-EpicMergeGateSelectorPrNumber.returns 5 for gh pr merge --merge=true 5`, classname `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1`, failure message: `Expected 5, because the selector of gh pr merge --merge=true 5 resolves to 5, but got $null.`
- testsuites with non-zero errors: none. testsuites with non-zero failures: `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` (tests="15" errors="0" failures="1").

Reason: `.codex/hooks/enforce-epic-merge-gate-command.ps1:165-167` returns `ConvertFrom-EpicMergeGateSelector -Selector 'true'`, which is `$null` at `:68`.

## RowAttribution:

RowAttributionSource: JUNIT

| Testcase | Classname | Status |
|---|---|---|
| baseline mock interception probe | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| ConvertFrom-EpicMergeGateSelector.converts 5 to 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| ConvertFrom-EpicMergeGateSelector.converts https://github.com/o/r/pull/5 to 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| ConvertFrom-EpicMergeGateSelector.converts https://github.com/o/r/pull/5/?tab=checks to 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| ConvertFrom-EpicMergeGateSelector.converts feature-branch to no number | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| ConvertFrom-EpicMergeGateSelector.converts 99999999999 to no number | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns 5 for gh pr merge -- 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns no number for gh pr merge --merge -- | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns 5 for gh pr merge --merge=5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns 5 for gh pr merge --merge=true 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Failed (expected) |
| Get-EpicMergeGateSelectorPrNumber.returns no number for gh pr merge --merge | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns no number for gh pr merge feature-branch --merge | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns 5 for gh api -X PUT repos/o/r/pulls/5/merge | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns no number for gh api repos/o/r/pulls/5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| Get-EpicMergeGateSelectorPrNumber.returns no number for git status | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed |
| resolves the selector helper functions from the Codex helper file | tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | Passed |
| keeps the bare-merge deny text unchanged (codex, issue #927) (P2-T8 pin) | tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | Passed |

The failing set is exactly the F2 testcase. The other 14 testcases of the new suite, the provenance case, and the updated #927 pin pass.

CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.

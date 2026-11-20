# Remediation cycle 2 - Codex hook tests before the M1 URL rule [expect-fail] (P2-T7)

Timestamp: 2026-10-16T20-18
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]; then Grep of WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `status="Failed"`, `URL selector with PR_UNRESOLVED and no process call`, `decides a pull-request URL selector`, `resolves the selector helper functions from the Codex helper file`, `returns 5 for gh pr merge --merge=true 5`
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: the call raised with `Command exited with code 2.` (error text verbatim: `{"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 2."}`). JUNIT_FAILED=2 (N3 and N4), as required.
JUnitFreshness: FRESH
RowAttributionSource: JUNIT

P0-T8 baseline of `t-codex-hooks`: GREEN.

## Freshness

- F1: 68 lines match `<testsuite name=`; all 68 contain `codex-hooks` (the preceding test call, P2-T6, was on `claude-hooks`).
- F2: the N3 testcase is present, classname ending `enforce-epic-merge-gate-docs-only.Tests.ps1`.
- No `testsuite` line has a non-zero `errors` attribute.

## RowAttribution

| Row | Suite (repository-relative) | Pre-change status | Reason |
|---|---|---|---|
| N3 `denies a pull-request URL selector with PR_UNRESOLVED and no process call (codex, issue #952)` | tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | Failed | the Codex gate allows (returns `$null`, D7). JUnit failure message: "Expected 'deny', but got $null." at `$decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'`, line 147 |
| N4 `decides a pull-request URL selector (codex copy, issue #927)` | tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | Failed | `Exempt` is `$true` (D7). JUnit failure message: "Expected $false, but got $true." at `$result.Exempt | Should -BeFalse`, line 195 |
| row (g) `resolves the selector helper functions from the Codex helper file` | tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | Passed | provenance unchanged |
| row (h) `returns 5 for gh pr merge --merge=true 5` | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | Passed | helper unchanged |

## Failing set (every `status="Failed"` testcase; repository-relative classnames)

1. `Codex enforce-epic-merge-gate docs-only branch (issue #927).denies a pull-request URL selector with PR_UNRESOLVED and no process call (codex, issue #952)` - tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
2. `Codex hook-docs-only-diff copy (issue #927).decides a pull-request URL selector (codex copy, issue #927)` - tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1

The failing set is exactly {N3, N4}.

CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.

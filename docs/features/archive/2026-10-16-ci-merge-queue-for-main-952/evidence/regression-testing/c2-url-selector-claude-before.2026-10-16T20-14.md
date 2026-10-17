# Remediation cycle 2 - Claude hook tests before the M1 URL rule [expect-fail] (P2-T6)

Timestamp: 2026-10-16T20-14
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-hooks]; then Grep of WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `status="Failed"`, `URL selector before any process`, `URL selector with the PR_UNRESOLVED docs-only reason`, `is byte-identical across all four copies`, `denies a -R override with the PR_UNRESOLVED docs-only reason`
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: the call raised with `Command exited with code 2.` (error text verbatim: `{"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 2."}`). JUNIT_FAILED=2 (N1 and N2), as required.
JUnitFreshness: FRESH
RowAttributionSource: JUNIT

P0-T8 baseline of `t-claude-hooks`: GREEN.

## Freshness

- F1: 164 lines match `<testsuite name=`; all 164 contain `claude-hooks` (the preceding test call, P1-T5, was on `codex-hooks`).
- F2: the N1 testcase is present, classname ending `hook-docs-only-diff.MergeExemption.Tests.ps1`.
- No `testsuite` line has a non-zero `errors` attribute.

## RowAttribution

| Row | Suite (repository-relative) | Pre-change status | Reason |
|---|---|---|---|
| N1 `denies a pull-request URL selector before any process (issue #952)` | tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | Failed | `Exempt` is `$true` (D7). JUnit failure message: "Expected $false, but got $true." at `$result.Exempt | Should -BeFalse`, line 69 |
| N2 `denies a pull-request URL selector with the PR_UNRESOLVED docs-only reason and no process call (issue #952)` | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | Failed | the gate allows (D7). JUnit failure message: "Expected: 'deny' But was: 'allow'" at `$decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'`, line 139 |
| `is byte-identical across all four copies (issue #927)` | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Passed | four copies unchanged |
| `denies a -R override with the PR_UNRESOLVED docs-only reason and no process call (issue #927)` | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | Passed | existing M1 `-R` rule |

## Failing set (every `status="Failed"` testcase; repository-relative classnames)

1. `enforce-epic-merge-gate docs-only branch (issue #927).no checkpoint records the pull request.denies a pull-request URL selector with the PR_UNRESOLVED docs-only reason and no process call (issue #952)` - tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1
2. `Get-DocsOnlyMergeExemption (issue #927).M1 command shape.denies a pull-request URL selector before any process (issue #952)` - tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1

The failing set is exactly {N1, N2}. A further testcase name matched the byte-identity search, `hook-dependency-guard.ps1 helper (Claude).H11: is byte-identical across all four copies` (tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1), status Passed; it is not a named row of this task.

CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.

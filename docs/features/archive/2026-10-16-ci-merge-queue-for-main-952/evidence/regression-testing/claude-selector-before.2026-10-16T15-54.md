# Claude selector fail-before run (remediation cycle 1, CR-2 and CR-4) [expect-fail]

Timestamp: 2026-10-16T15-54
Task: [P2-T11]
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-hooks]; then Grep WORKTREE_ROOT/artifacts/pester/pester-junit.xml for `<testsuite name=`, `claude-hooks` on those lines, `returns 5 for gh pr merge --merge=true 5`, and `status="Failed"`
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 1."}; JUNIT_FAILED=1 (the F2 testcase only)
JUnitFreshness: FRESH
Baseline (P0-T8 t-claude-hooks): GREEN-AFTER-PIN

## Freshness

- F1: 164 lines match `<testsuite name=`; 164 lines match `<testsuite name="[^"]*claude-hooks` (the P2-T10 file listed only codex-hooks suites).
- F2: testcase `...the PR selector reader resolves every spelling (AC-8).returns 5 for gh pr merge --merge=true 5` present (junit line 692), classname ends with `enforce-epic-merge-gate.MergeQueue.Tests.ps1`.

## Failing set

- `enforce-epic-merge-gate.ps1 merge-queue scope (issue #952).the PR selector reader resolves every spelling (AC-8).returns 5 for gh pr merge --merge=true 5`, classname `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`
- testsuites with non-zero errors: none. testsuites with non-zero failures: `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (tests="40" errors="0" failures="1").

Reason: `.claude/hooks/enforce-epic-merge-gate-command.ps1:165-167` returns `ConvertFrom-EpicMergeGateSelector -Selector 'true'`, which is `$null` at `:68`.

## RowAttribution:

RowAttributionSource: JUNIT

| Testcase | Classname | Status |
|---|---|---|
| returns 5 for gh pr merge -- 5 | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | Passed |
| returns no number for gh pr merge --merge -- | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | Passed |
| returns no number for gh pr merge feature-branch --merge | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | Passed |
| returns 5 for gh pr merge --merge=true 5 | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | Failed (expected) |
| every testcase (suite tests="360" errors="0" failures="0") | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | Passed |
| makes no docs-only call for a bare merge and keeps its exact deny text (issue #927) (P2-T7 pin) | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | Passed |

The failing set is exactly the F2 testcase.

CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.

# Import-ScriptFunction Search (Issue #847, AC-08)

Timestamp: 2026-10-10T01-18
Task: [P7-T8]
Route note: run from the Bash tool per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (no PowerShell-tool commands in the agent worktree). The `git grep` text is unchanged. The `Select-String -SimpleMatch` count is replaced by `git grep --untracked -c -F` (fixed-string, per-file line count), which gives the same count when the literal appears at most once per line.
Command: (1) `git grep --untracked -n -F -e 'Import-ScriptFunction' -- <the eleven TEST11 paths>; echo "EXIT_CODE=$?"`; (2) `git grep --untracked -c -F -e 'scaffold extension package identity' -- tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- (1) No match lines printed; `EXIT_CODE=1`.
- (2) `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1:1`, so the literal `scaffold extension package identity` appears exactly once.
- Result: PASS (AC-08).

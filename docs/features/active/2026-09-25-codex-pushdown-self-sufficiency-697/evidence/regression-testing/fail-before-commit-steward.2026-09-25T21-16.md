# Fail-Before: commit-steward PowerShell Port (Issue #697, AC-4.11 red)

Timestamp: 2026-09-25T21-16
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: `Tests Passed: 26, Failed: 2, Skipped: 0, Inconclusive: 0, NotRun: 0`. Failed:
- `accepts every generated agent family` -- `ArgumentException: Unsupported Codex logical agent: 'commit-steward'.`
- `resolves commit-steward to the Python resolver receipt` -- `ArgumentException: Unsupported Codex logical agent: 'commit-steward'.`

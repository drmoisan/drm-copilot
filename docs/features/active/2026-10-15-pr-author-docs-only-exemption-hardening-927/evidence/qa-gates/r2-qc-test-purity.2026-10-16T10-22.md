# R2 QC Test Purity, Loop Pass 1 (Issue #927)

Timestamp: 2026-10-16T10-22
Command: grep -c -E -e 'Mock (git|gh)( |$)|Mock .(git|gh). |function (git|gh) |Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTempFileName|GetTempPath|env:TEMP|ProcessStartInfo' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Zero forbidden test constructs (rule R2-9) in either edited suite; grep exit 1 is the expected no-match outcome.

## Output

- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:0`
- `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:0`

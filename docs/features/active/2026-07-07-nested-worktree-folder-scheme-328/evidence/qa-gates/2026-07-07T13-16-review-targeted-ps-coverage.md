# Feature-Review Targeted PowerShell Coverage Measurement (Issue #328)

Timestamp: 2026-07-07T13-16
Command: pwsh -NoProfile -Command "Invoke-Pester -Configuration <cfg>" with Run.Path = tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1; CodeCoverage.Enabled = true; CodeCoverage.Path = scripts/dev-tools/new-claude-worktree-session.ps1; CodeCoverage.OutputFormat = JaCoCo
EXIT_CODE: 1 (coverage-percent gate below Pester default target; test run itself green)

Output Summary:
- Tests Passed: 31, Failed: 0, Skipped: 2 (platform-conditional `-Skip:$IsWindows` / `-Skip:(-not $IsWindows)` variants), NotRun: 0.
- Reported coverage: "Covered 4.88% / 75%. 82 analyzed Commands in 1 File."
- The 4.88% figure is a measurement-attribution artifact, not a test-coverage result. The repo test helper `Import-ScriptFunction` (tests/scripts/powershell/Support/TestHelpers.ps1) extracts each function's AST extent and re-parses it via `Parser::ParseInput($functionText, $resolved, ...)`. The re-parsed scriptblock's line numbers restart at 1, so Pester's breakpoint-based coverage cannot attribute executed commands back to the original file lines in `scripts/dev-tools/new-claude-worktree-session.ps1`.
- Behavioral evidence: all nine functions in the changed script (including the new `Get-WorktreeGroupDirectory` and `New-WorktreeParentDirectory`) are directly exercised by the 31 passing tests.

Consequence for the review:
- No structurally valid per-file numeric line-coverage measurement exists for the changed PowerShell production file. The committed repo coverage artifact (`artifacts/pester/powershell-coverage.xml`) also excludes this file because `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` allow-lists hook/release files only (pre-existing configuration, unchanged by this branch).
- Fail-closed disposition recorded in `policy-audit.2026-07-07T13-16.md` Section 8 and `remediation-inputs.2026-07-07T13-16.md`.

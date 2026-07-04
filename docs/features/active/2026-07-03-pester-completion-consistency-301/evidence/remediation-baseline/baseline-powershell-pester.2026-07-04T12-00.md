# Baseline PowerShell Pester Run (Pre-Fix, Coverage-Enabled)

Timestamp: 2026-07-04T12-00
Command: `mcp__drm-copilot__run_poshqc_test` (coverage-enabled) against `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, using the current (unmodified) `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
EXIT_CODE: 0

Output Summary: 51 tests executed across both target files (`enforce-completion-consistency-codex.Tests.ps1`: 2 tests; `enforce-completion-consistency.Tests.ps1`: 49 tests), 0 failures, 0 errors. JUnit summary line: `tests="51" errors="0" failures="0" disabled="0" time="2.303"`. Coverage report regenerated at `artifacts/pester/powershell-coverage.xml` using the pre-fix `CodeCoverage.Path` array (16 entries, not yet including the four in-scope hook files).

## Coverage-Measurement Gap Verification (P0-T9)

Command: `grep -n "sourcefile" artifacts/pester/powershell-coverage.xml`

Result: No `<sourcefile>` entry exists for any of the four in-scope files:
- `.claude/hooks/enforce-completion-consistency.ps1` — not found
- `.claude/hooks/enforce-completion-helpers.ps1` — not found
- `.codex/hooks/enforce-completion-consistency.ps1` — not found
- `.codex/hooks/enforce-completion-helpers.ps1` — not found

This confirms the pre-fix `CodeCoverage.Path` array does not measure the four in-scope hook files, and no coverage evidence exists for them prior to the Phase 1 fix.

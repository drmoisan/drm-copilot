# Remediation: Add Pester Tests for validate-bash.ps1 - Plan

- **Issue:** #136
- **Parent (optional):** N/A
- **Owner:** atomic_planner
- **Last Updated:** 2026-04-12T02-01
- **Status:** approved
- **Version:** 1.0

## Overview

Add Pester (v5.x) unit tests for `.claude/hooks/validate-bash.ps1` to satisfy remediation inputs from the feature audit. The plan creates one new test file (`tests/.claude/hooks/validate-bash.Tests.ps1`) covering all 6 blocked patterns, safe-command pass-through, empty input, and malformed JSON edge cases. Production code is not modified.

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Constraints

- Do NOT modify `.claude/hooks/validate-bash.ps1`.
- Do NOT modify any existing test files.
- Do NOT create temporary files in tests.
- New test file must be under 500 lines.
- Follow repo Pester conventions: `Describe`/`Context`/`It`, `*.Tests.ps1` naming.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context and Baseline

- [x] [P0-T1] Read the following policy files in order and confirm compliance requirements: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
  - Acceptance: Evidence artifact `evidence/baseline/phase0-instructions-read.md` exists with `Timestamp:`, `Policy Order:`, and an explicit list of files read.

- [x] [P0-T2] Read `.claude/hooks/validate-bash.ps1` (66 lines) and confirm all 6 blocked patterns: `rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`
  - Acceptance: The list of 6 blocked patterns is verified against the production code and matches exactly.

- [x] [P0-T3] Read `remediation-inputs.2026-04-12T02-01.md` and confirm the full set of required test scenarios
  - Acceptance: Scenario list matches the remediation inputs specification without omissions.

- [x] [P0-T4] Capture baseline PoshQC test results by running `mcp_drmcopilotext_run_poshqc_test`
  - Acceptance: Evidence artifact `evidence/baseline/poshqc-test-baseline.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:` containing pass/fail counts.

- [x] [P0-T5] Capture baseline PoshQC analyze results by running `mcp__drmCopilotExtension__run_poshqc_analyze`
  - Acceptance: Evidence artifact `evidence/baseline/poshqc-analyze-baseline.md` exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Pester Test File Creation

- [x] [P1-T1] Create directory `tests/.claude/hooks/` if it does not already exist
  - Acceptance: Directory `tests/.claude/hooks/` exists on disk.

- [x] [P1-T2] Create `tests/.claude/hooks/validate-bash.Tests.ps1` with Pester v5.x structure: top-level `Describe "validate-bash.ps1"` block, `BeforeAll` resolving the script path to `.claude/hooks/validate-bash.ps1`
  - Acceptance: File exists, contains `Set-StrictMode -Version Latest`, a `Describe` block named `"validate-bash.ps1"`, and a `BeforeAll` that resolves the production script path.

- [x] [P1-T3] Add `Context "Blocked patterns"` with test: `It "blocks 'rm -rf' commands with exit code 1"` — invokes the script with a command containing `rm -rf /some/path` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script with `rm -rf /some/path`, and asserts exit code 1.

- [x] [P1-T4] Add test: `It "blocks 'git push --force' commands with exit code 1"` — invokes the script with a command containing `git push --force` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script targeting `git push --force`, and asserts exit code 1.

- [x] [P1-T5] Add test: `It "blocks 'git push origin --force' commands with exit code 1"` — invokes the script with a command containing `git push origin --force` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script targeting `git push origin --force`, and asserts exit code 1.

- [x] [P1-T6] Add test: `It "blocks 'Remove-Item -Recurse -Force' commands with exit code 1"` — invokes the script with a command containing `Remove-Item -Recurse -Force` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script targeting `Remove-Item -Recurse -Force`, and asserts exit code 1.

- [x] [P1-T7] Add test: `It "blocks 'git reset --hard' commands with exit code 1"` — invokes the script with a command containing `git reset --hard` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script targeting `git reset --hard`, and asserts exit code 1.

- [x] [P1-T8] Add test: `It "blocks 'git push -f' commands with exit code 1"` — invokes the script with a command containing `git push -f` and asserts `$LASTEXITCODE -eq 1`
  - Acceptance: `It` block exists, invokes the script targeting `git push -f`, and asserts exit code 1.

- [x] [P1-T9] Add `Context "Safe commands"` with test: `It "allows 'ls -la' with exit code 0"` — invokes the script with `ls -la` and asserts `$LASTEXITCODE -eq 0`
  - Acceptance: `It` block exists, invokes the script with `ls -la`, and asserts exit code 0.

- [x] [P1-T10] Add test: `It "allows 'git status' with exit code 0"` — invokes the script with `git status` and asserts `$LASTEXITCODE -eq 0`
  - Acceptance: `It` block exists, invokes the script with `git status`, and asserts exit code 0.

- [x] [P1-T11] Add test: `It "allows 'echo hello' with exit code 0"` — invokes the script with `echo hello` and asserts `$LASTEXITCODE -eq 0`
  - Acceptance: `It` block exists, invokes the script with `echo hello`, and asserts exit code 0.

- [x] [P1-T12] Add `Context "Empty input"` with test: `It "exits with code 0 when no command is provided"` — invokes the script with no arguments and no `CLAUDE_TOOL_INPUT` environment variable, asserts `$LASTEXITCODE -eq 0`
  - Acceptance: `It` block exists, invokes the script with empty input, and asserts exit code 0.

- [x] [P1-T13] Add `Context "Malformed JSON in CLAUDE_TOOL_INPUT"` with test: `It "falls back to raw environment variable value when JSON is malformed"` — sets `$env:CLAUDE_TOOL_INPUT` to a non-JSON string containing a blocked pattern, invokes the script, asserts `$LASTEXITCODE -eq 1`, and cleans up the environment variable in an `AfterEach` or within the test body
  - Acceptance: `It` block exists, sets malformed JSON containing a blocked pattern, asserts exit code 1, and restores the environment variable.

- [x] [P1-T14] Add test: `It "falls back to raw environment variable value when JSON is malformed and value is safe"` — sets `$env:CLAUDE_TOOL_INPUT` to a non-JSON safe string (e.g., `not-json-but-safe`), invokes the script, asserts `$LASTEXITCODE -eq 0`, and cleans up the environment variable
  - Acceptance: `It` block exists, sets malformed JSON containing a safe value, asserts exit code 0, and restores the environment variable.

- [x] [P1-T15] Add `Context "CLAUDE_TOOL_INPUT with valid JSON"` with test: `It "reads command from JSON 'command' field"` — sets `$env:CLAUDE_TOOL_INPUT` to `'{"command":"rm -rf /tmp"}'`, invokes the script with no positional argument, asserts `$LASTEXITCODE -eq 1`, and cleans up the environment variable
  - Acceptance: `It` block exists, sets valid JSON with a blocked command, asserts exit code 1, and restores the environment variable.

- [x] [P1-T16] Add test: `It "reads safe command from JSON 'command' field and exits 0"` — sets `$env:CLAUDE_TOOL_INPUT` to `'{"command":"git status"}'`, invokes the script with no positional argument, asserts `$LASTEXITCODE -eq 0`, and cleans up the environment variable
  - Acceptance: `It` block exists, sets valid JSON with a safe command, asserts exit code 0, and restores the environment variable.

- [x] [P1-T17] Verify the completed test file is under 500 lines by counting lines
  - Acceptance: `(Get-Content tests/.claude/hooks/validate-bash.Tests.ps1).Count` is less than 500.

### Phase 2 — QC Loop (Format, Analyze, Test)

- [x] [P2-T1] Run PoshQC format on the new test file via `mcp__drmCopilotExtension__run_poshqc_format`
  - Acceptance: Command exits successfully. Evidence artifact `evidence/qa-gates/poshqc-format-final.md` exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T2] Run PoshQC analyze via `mcp__drmCopilotExtension__run_poshqc_analyze`
  - Acceptance: Command exits with no errors or warnings for the new test file. Evidence artifact `evidence/qa-gates/poshqc-analyze-final.md` exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T3] Run PoshQC test via `mcp_drmcopilotext_run_poshqc_test`
  - Acceptance: All existing tests plus all new `validate-bash.Tests.ps1` tests pass. Evidence artifact `evidence/qa-gates/poshqc-test-final.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE: 0`, and `Output Summary:` containing pass counts showing new tests included.

- [x] [P2-T4] If any of [P2-T1], [P2-T2], or [P2-T3] failed or changed files, fix the issues and restart the QC loop from [P2-T1]. Repeat until all three pass in a single clean run.
  - Acceptance: A single pass of format, analyze, and test all complete with exit code 0 without restarting.

- [x] [P2-T5] Confirm no existing tests regressed by comparing test pass counts from [P2-T3] against the baseline captured in [P0-T4]
  - Acceptance: All tests that passed in the baseline still pass. Total test count has increased by the number of new tests added.

## Test Plan

- Unit: Pester tests for `.claude/hooks/validate-bash.ps1` in `tests/.claude/hooks/validate-bash.Tests.ps1`
- Integration: N/A
- Manual/CLI: N/A

## Open Questions / Notes

- Production code (`validate-bash.ps1`) must not be modified.
- Tests were relocated from `tests/.claude/hooks/validate-bash.Tests.ps1` to `tests/scripts/claude-hooks/validate-bash.Tests.ps1` because the MCP-bundled Pester settings only scan `scripts/`, `tests/powershell/`, and `tests/scripts/`, and the installed extension's bundled settings are not updated by editing the repo source.
- Both repo-root and bundled Pester settings received `.claude/hooks/*.ps1` in the `CodeCoverage.Path` array to include the production hook in coverage reporting.
- Tests that expect exit code 1 (blocked patterns) require `$ErrorActionPreference = 'Continue'` and stderr redirection (`2>$null`) because the PoshQC runner sets `$ErrorActionPreference = 'Stop'`, which causes `Write-Error` in the production script to become a terminating error.
- Environment variable cleanup within CLAUDE_TOOL_INPUT tests is required to maintain test independence.
- The QC loop (Phase 2) must restart from formatting if any step fails or changes files, per general code change policy.

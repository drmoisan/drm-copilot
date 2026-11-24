# Task Check - [P1-T2] [expect-fail]

Plan: remediation-plan.2026-11-24T08-32.md
Timestamp: 2026-11-24T09-47
Command: sh SCRATCH/issue-1221-static.sh <changed files>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1 tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1 (`BeforeAll` helper `New-TestCaseInsensitiveSeam`; new `Describe 'Read-DocsFamilyEvidence root-file name case'` with four cases), tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 (new `It 'lists only the top-level repository-root files for the empty relative root'`).
- Selection and rule: the two changed test files (the plan's fail-before selection).
- Format (check-only): exit 0, 0 files need formatting. Analyzer: exit 0, 0 findings (the helper carries a PSUseShouldProcessForStateChangingFunctions suppression with a justification, as `New-DocsLedgerTestContext` does). Logical lines: DocsFamilyCheck.Tests.ps1 528, Invoke-DocsCommand.Tests.ps1 512.
- Pester: exit 1 with exactly the four expected failures; see evidence/regression-testing/fail-before.2026-11-24T09-47.md.
- Not a gate; no coverage is claimed from this run.

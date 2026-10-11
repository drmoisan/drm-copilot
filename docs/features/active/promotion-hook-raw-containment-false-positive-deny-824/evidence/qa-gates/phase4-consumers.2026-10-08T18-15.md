# Phase 4 Gate: Consumer Suites Against the New Matcher (set A-NOPARITY)

Timestamp: 2026-10-08T18-15
Command: sh <SCRATCHPAD>/s-pester.sh A-NOPARITY
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
PESTER_SET: A-NOPARITY FILES=43
PESTER_TOTAL: 963
PESTER_PASSED: 962
PESTER_FAILED: 1
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0
FAILED_TEST: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Failing set = B_SCOPED exactly (pre-existing). The exit code 1 is caused only by that B_SCOPED member.

Run history (same command):
1. First run: PESTER_FAILED: 2 = the B_SCOPED member plus "enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree". The guard listed ten DynamicInvocation sites in .claude/hooks/hook-command-invocation.ps1, each an ampersand-invoked local scriptblock variable ($stop in Skip-CommandLineOption, $indeterminate in Get-CommandLineInvocation). This was a matcher-module regression and was fixed in Phase 4 as the task requires: both scriptblocks were replaced by direct record construction and the named helper ConvertTo-CommandLineIndeterminateMatch, the codex-invocation group was re-mirrored (mirror-codex-invocation-phase4), and P4 was re-run (phase4-pester).
2. This run: only the B_SCOPED member fails.

Diagnostic note (recorded for the audit): to read the guard's detail lines, one diagnostic run of `sh <SCRATCHPAD>/s-pester.sh PARITY` was made between the two runs above. Rule 9 excludes the parity suites from plan tasks in this interval; that run was a diagnostic read only, is not used as evidence for any task, and its expected parity failure (bundled copies still at base text) is not counted.

The gate path helpers deleted in Phase 5 (Get-EpicWorktreeRemovalCommandPath, Get-ParallelWorktreeRemovalCommandPath, Get-CodexWorktreeRemovalPath) still exist at this point, and their existing rows passed.

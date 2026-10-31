# Fail-Before (Issue #1011, Remediation Cycle 1)

Timestamp: 2026-10-31T02-42
Command: sh SCRATCH/issue-1011-r1-tr.sh (Invoke-Pester, one process, file tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1, against the unmodified .claude/hooks/enforce-pr-author-skill-helpers.ps1; then JUnit read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- JUnit: tests=19, failures=3, errors=0, skipped=0.
- Failed (expected, [expect-fail] rows P1-T2 to P1-T4):
  - TR-10 maps a CommandOperand root that encloses the session path to SessionRoot: Status was OtherWorktree, expected SessionRoot (F1, no enclosing-worktree ascent).
  - TR-11 lets the identity resolver decide when the command also carries a canonical issue line: Status was OtherWorktree, expected Ambiguous (CR-2, shared resolver bypassed the agreement check).
  - TR-12 yields no selection for a resolved root whose directory is gone: the mapped result was an OtherWorktree object, expected null (CR-3, no marker check).
- Passed: every other row of the suite (16): the baseline mock interception probe, the five rows of the two #687 contexts, TR-01 to TR-09 (TR-06 has two cases). This confirms the P1-T1 context mocks leave TR-01 to TR-09 passing against the unmodified helpers.

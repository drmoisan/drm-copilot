# Allowlist Suites After Phase 2 (Issue #1011, AC-02 to AC-05)

Timestamp: 2026-10-31T01-40
Command: sh SCRATCH/issue-1011-pester-targeted.sh "tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1,tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1,tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1" (one process); then sh SCRATCH/issue-1011-read-results.sh -NoCoverage -PassedPattern AL-
EXIT_CODE: 0
Output Summary:
- JUnit (artifacts/pester/pester-junit.xml): tests 116, failures 0, errors 0.
- AL-01 to AL-67: all 67 rows PASSED (including AL-50, AL-51, AL-52, AL-67 that failed before, the new deny rows AL-53 to AL-66, the relative form AL-07, AL-34, and AL-49).
- hook-command-invocation.Issue824Regression.Tests.ps1 and hook-command-consumers.Issue824.Tests.ps1: all rows passed.
- `wc -l .claude/hooks/enforce-pr-author-command-allowlist.ps1`: 326 (at most 500).

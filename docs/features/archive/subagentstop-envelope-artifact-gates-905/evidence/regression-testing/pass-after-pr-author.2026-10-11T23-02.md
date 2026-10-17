# Pass-after: validate-pr-author-output (plan [P4-T2], issue #905)

Timestamp: 2026-10-11T23-02
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-scoped.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
EXIT_CODE: 0
Output Summary: SUMMARY: passed=21 failed=0 skipped=0 notrun=0; CONTAINER-ERRORS: 0. A `PASSED-TEST:` line is present for each of P1 to P8 (Coverage suite) and P9 (Tests suite).

```text
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a GitHub PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a PR # reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr create confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | allows when output contains a gh pr edit confirmation with a PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with PR_AUTHOR_OUTPUT_EMPTY when the assistant message is blank
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when output has no PR URL or number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with a payload anomaly when the input text is empty
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks with a payload anomaly when the input text is malformed JSON
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | blocks when the output mentions gh pr create but has no PR number
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for null/empty/whitespace output
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns true for a PR URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | returns false for prose with no PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | exits 2 in a separate process when the stdin envelope lacks a PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_NO_PR on stderr when last_assistant_message lacks a PR reference
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 0 when last_assistant_message reports a pull request URL
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with PR_AUTHOR_OUTPUT_EMPTY when last_assistant_message is an empty string
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for empty stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason for malformed stdin
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | exits 2 with a payload anomaly reason when last_assistant_message is absent
PASSED-TEST: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | keeps validating when stop_hook_active is true
BLOCK-ERRORS: 0
CONTAINER-ERRORS: 0
SUMMARY: passed=21 failed=0 skipped=0 notrun=0
```

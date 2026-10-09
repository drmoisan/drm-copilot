# Fail-Before: Named Regression Rows (T-REG) Against the Unchanged Production Tree

Timestamp: 2026-10-08T17-50
Command: sh <SCRATCHPAD>/s-pester.sh REG
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
PESTER_SET: REG FILES=1 (tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1)
PESTER_TOTAL: 23
PESTER_PASSED: 0
PESTER_FAILED: 23
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 1 (the allowlist Describe BeforeAll)

Production state: every in-scope production path equals BASE_SHA 991aae0a180a09d504b59bc9460ec4b00b85d11b (production-equals-base artifact); only the new test file was added.

## Per-row result and failure cause

| Row | Named regression | Result | First assertion or error message (cause) |
|---|---|---|---|
| REG-01 (claude) | R-824-MAIN | RESULT Failed | Expected $null or empty, but got 'PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` ...' (raw substring containment of gh/issue/new in a wrapper-led segment) |
| REG-01 (codex) | R-824-MAIN | RESULT Failed | Expected $null or empty, but got 'PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` ...' (same cause, Codex copy) |
| REG-02 | R-824-ADD1 | RESULT Failed | Expected strings to be the same ('allow'), but they were different (Claude epic gate denied: substring containment classified the pwsh segment as git worktree remove) |
| REG-03 | R-742-1 | RESULT Failed | Expected strings to be the same ('allow'), but they were different (Claude epic gate denied: --version read as an unmodeled option) |
| REG-04 | R-824-ADD1 | RESULT Failed | Expected strings to be the same ('allow'), but they were different (Claude parallel gate denied: substring containment) |
| REG-05 | R-742-1 | RESULT Failed | Expected strings to be the same ('allow'), but they were different (Claude parallel gate denied: unmodeled-option rule) |
| REG-06 | R-824-ADD1 | RESULT Failed | Expected $null or empty, but got System.Collections.Specialized.OrderedDictionary (Codex epic gate deny decision: substring containment) |
| REG-07 | R-742-1 | RESULT Failed | Expected $null or empty, but got System.Collections.Specialized.OrderedDictionary (Codex epic gate deny decision: unmodeled-option rule) |
| REG-08 (claude) | R-742-1 | RESULT Failed | Expected $false, but got $true (Test-ImplementationCommand classified git --version as git add/commit) |
| REG-08 (codex) | R-742-1 | RESULT Failed | Expected $false, but got $true (same cause, Codex copy) |
| REG-09 | R-733-714 | RESULT Failed | Expected $null or empty, but got 'PR_AUTHOR_SKILL_BLOCKED: New PRs require `--body-file`. ...' (live-substitution segment classified as gh pr create by substring containment) |
| REG-10 | R-733-GREP G1 | RESULT Failed | Expected $null or empty, but got 'PR_AUTHOR_SKILL_BLOCKED: New PRs require `--body-file`. ...' (wrapper-led pwsh segment, substring containment) |
| REG-11 | R-733-GREP G2 | RESULT Failed | Expected $null or empty, but got 'PR_AUTHOR_SKILL_BLOCKED: New PRs require `--body-file`. ...' (live substitution, substring containment) |
| REG-12 | R-733-GREP G3 | RESULT Failed | Expected $null or empty, but got 'PR_AUTHOR_SKILL_BLOCKED: New PRs require `--body-file`. ...' (live substitution, substring containment) |
| REG-13 | R-733-715 S1 | RESULT Failed | Could not find Command Get-PrAuthorBodyFileRoot (the not-yet-defined mock target in the Context BeforeEach) |
| REG-14 | R-733-715 S2 | RESULT Failed | Could not find Command Get-PrAuthorBodyFileRoot (same cause) |
| REG-15 | R-733-715 S3 | RESULT Failed | Could not find Command Get-PrAuthorBodyFileRoot (same cause) |
| REG-16 | R-733-715 S4 | RESULT Failed | Could not find Command Get-PrAuthorBodyFileRoot (same cause) |
| REG-17 | R-733-715 S5 | RESULT Failed | Could not find Command Get-PrAuthorBodyFileRoot (same cause) |
| REG-18 | R-733-712 chain | RESULT Failed | Describe BeforeAll failed: CommandNotFoundException, the term '<WORKSPACE_ROOT>/.claude/hooks/enforce-pr-author-command-allowlist.ps1' is not recognized (file does not exist yet) |
| REG-19 | R-733-712 single | RESULT Failed | Describe BeforeAll failed: enforce-pr-author-command-allowlist.ps1 does not exist yet |
| REG-20 | R-733-712 single | RESULT Failed | Describe BeforeAll failed: enforce-pr-author-command-allowlist.ps1 does not exist yet |
| REG-21 | R-733-712 single | RESULT Failed | Describe BeforeAll failed: enforce-pr-author-command-allowlist.ps1 does not exist yet |

REG-09..REG-12 fail on a PR_AUTHOR_SKILL_BLOCKED: reason, not on a mock or setup error, as the plan requires. REG-13..REG-17 fail on the not-yet-defined Get-PrAuthorBodyFileRoot mock target. REG-18..REG-21 fail because the allowlist hook file does not exist.

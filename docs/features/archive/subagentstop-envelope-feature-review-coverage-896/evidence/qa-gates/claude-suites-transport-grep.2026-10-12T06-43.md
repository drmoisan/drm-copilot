# Claude suites transport search (P5-T14, AC-6)

Timestamp: 2026-10-12T06-43
Command: git grep -n -e CLAUDE_HOOK_INPUT -e "-RawPayload" -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no output; git grep exits 1 because neither "CLAUDE_HOOK_INPUT" nor "-RawPayload" occurs in the four tracked Claude hook suites (working tree after P5-T6 through P5-T11).

## Output

```
(no output)
```

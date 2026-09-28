# Fail-Before: Chain Escape Regression Suite (Issue #710)

Timestamp: 2026-09-27T02-11
Command: sh <SCRATCHPAD>/r-scoped-chain.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-scoped-chain.ps1: R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1, before any production change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure observed against the unmodified helper copies (SHA256 5BB872E2...881D7F). PassedCount 22, FailedCount 16, FailedBlocksCount 0, FailedContainersCount 0. The FAILED lines are exactly the eight plan section 4 fail-before names, each once for (.claude/hooks) and once for (.codex/hooks).

## Runner Output

```text
PassedCount: 22
FailedCount: 16
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).treats a mid-line escaped semicolon as literal
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped ampersand as literal
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped pipe as literal
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).treats backslash-newline as a line continuation
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).does not split after an odd run of backslashes
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).consumes an escaped double quote inside double quotes
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).does not open a quote on an unquoted escaped double quote
FAILED: preimplementation gate helpers chain escapes (.claude/hooks).exempts a commit whose message contains an escaped semicolon
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).treats a mid-line escaped semicolon as literal
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped ampersand as literal
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped pipe as literal
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).treats backslash-newline as a line continuation
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).does not split after an odd run of backslashes
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).consumes an escaped double quote inside double quotes
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).does not open a quote on an unquoted escaped double quote
FAILED: preimplementation gate helpers chain escapes (.codex/hooks).exempts a commit whose message contains an escaped semicolon
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a chained command after an escaped backslash
```

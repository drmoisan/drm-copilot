# Pass-After: Chain Escape Regression Suite (Issue #710)

Timestamp: 2026-09-27T02-13
Command: sh <SCRATCHPAD>/r-scoped-chain.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/r-scoped-chain.ps1: R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1, after [P2-T1] and [P2-T3])
EXIT_CODE: 0
Output Summary: PassedCount 38, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. Each of the 19 expanded names of plan section 4 ends exactly one PASSED line for (.claude/hooks) and one for (.codex/hooks). Both canonical copies carry SHA256 EBE15355...9C6F7A.

## Runner Output

```text
PassedCount: 38
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).exempts a commit whose message contains an escaped semicolon
PASSED: preimplementation gate helpers chain escapes (.claude/hooks).does not exempt a chained command after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a mid-line escaped semicolon as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped ampersand as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats an escaped pipe as literal
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats backslash-newline as a line continuation
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ;
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &&
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped ||
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped |
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits on unescaped &
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).still splits after an escaped backslash
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not split after an odd run of backslashes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).splits on the unescaped ampersand after an escaped one
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).keeps backslash literal inside single quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).consumes an escaped double quote inside double quotes
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not open a quote on an unquoted escaped double quote
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).treats a trailing lone backslash as balanced
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).returns no segments for an empty command
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).exempts a commit whose message contains an escaped semicolon
PASSED: preimplementation gate helpers chain escapes (.codex/hooks).does not exempt a chained command after an escaped backslash
```

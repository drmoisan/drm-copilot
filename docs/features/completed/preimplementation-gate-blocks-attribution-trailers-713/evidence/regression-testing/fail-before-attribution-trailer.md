# P1-T5 Fail-Before Run (expect-fail)

Timestamp: 2026-09-27T03-33
Command: sh <SCRATCHPAD>/x713-newsuite.sh (R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1, before any production change)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: As predicted by plan section 4: 48 passed, 20 failed, 0 failed blocks, 0 failed containers. The failed tests are exactly the ten fail-before names, each once for claude and once for codex. Every other name passes before the fix.

SIBLING_710_PRESENT: True

PRE_EXISTING_BYPASS: the unmodified helpers admit "denies the hash-quote comment desynchronization line" on both runtimes; the S4 comment bypass exists on the base and is not introduced by #713.

## Runner output (structured result lines)

```text
PassedCount: 48
FailedCount: 20
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: preimplementation gate attribution trailers (claude).admits a separate-value trailer option
FAILED: preimplementation gate attribution trailers (claude).admits an equals-form trailer option
FAILED: preimplementation gate attribution trailers (claude).admits two trailer options
FAILED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a backtick
FAILED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a dollar sign and a command substitution
FAILED: preimplementation gate attribution trailers (claude).admits a chained add and trailer-bearing commit
FAILED: preimplementation gate attribution trailers (claude).admits a POSIX-rooted selector with a trailer option
FAILED: preimplementation gate attribution trailers (claude).admits an empty single-quoted trailer value
FAILED: preimplementation gate attribution trailers (claude).denies the hash-quote comment desynchronization line
FAILED: preimplementation gate attribution trailers (claude).denies a mid-word hash in an exempt operand
FAILED: preimplementation gate attribution trailers (codex).admits a separate-value trailer option
FAILED: preimplementation gate attribution trailers (codex).admits an equals-form trailer option
FAILED: preimplementation gate attribution trailers (codex).admits two trailer options
FAILED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a backtick
FAILED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a dollar sign and a command substitution
FAILED: preimplementation gate attribution trailers (codex).admits a chained add and trailer-bearing commit
FAILED: preimplementation gate attribution trailers (codex).admits a POSIX-rooted selector with a trailer option
FAILED: preimplementation gate attribution trailers (codex).admits an empty single-quoted trailer value
FAILED: preimplementation gate attribution trailers (codex).denies the hash-quote comment desynchronization line
FAILED: preimplementation gate attribution trailers (codex).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (claude).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (claude).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (claude).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (claude).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (claude).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (claude).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (claude).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (claude).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (claude).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (claude).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (claude).denies a message-file option
PASSED: preimplementation gate attribution trailers (claude).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (claude).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (claude).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (codex).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted redirection after a single-quoted dollar message
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a variable expansion in an operand
PASSED: preimplementation gate attribution trailers (codex).denies a dollar sign inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a command substitution inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies a backtick inside double quotes
PASSED: preimplementation gate attribution trailers (codex).denies the heredoc command-substitution commit recipe
PASSED: preimplementation gate attribution trailers (codex).denies ANSI-C dollar-single-quote quoting
PASSED: preimplementation gate attribution trailers (codex).denies an and-chain to a non-exempt add
PASSED: preimplementation gate attribution trailers (codex).denies a semicolon chain to a non-git command
PASSED: preimplementation gate attribution trailers (codex).denies a non-exempt pathspec with a trailer option
PASSED: preimplementation gate attribution trailers (codex).denies a pathless commit carrying a message and a trailer
PASSED: preimplementation gate attribution trailers (codex).denies a trailer option on the add subcommand
PASSED: preimplementation gate attribution trailers (codex).denies a dangling trailer option with no value
PASSED: preimplementation gate attribution trailers (codex).denies a message-file option
PASSED: preimplementation gate attribution trailers (codex).denies an equals-form file option
PASSED: preimplementation gate attribution trailers (codex).denies a stdin message file fed by a heredoc
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (codex).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies an escaped single quote near a dollar sign
```

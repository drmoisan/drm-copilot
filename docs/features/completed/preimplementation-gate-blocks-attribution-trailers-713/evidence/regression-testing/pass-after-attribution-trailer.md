# P2-T4 Pass-After Run

Timestamp: 2026-09-27T03-37
Command: sh <SCRATCHPAD>/x713-newsuite.sh (R-SCOPED over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1, after [P2-T1] and [P2-T3])
EXIT_CODE: 0
Output Summary: 68 passed, 0 failed, 0 failed blocks, 0 failed containers. Each of the 34 expanded names (12 admits, 22 denies) ends exactly two PASSED lines, one for claude and one for codex (34 distinct names, each counted twice; 34 claude lines and 34 codex lines).

## Runner output (structured result lines)

```text
PassedCount: 68
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
PASSED: preimplementation gate attribution trailers (claude).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (claude).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (claude).admits two trailer options
PASSED: preimplementation gate attribution trailers (claude).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (claude).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (claude).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (claude).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (claude).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (claude).admits an empty single-quoted trailer value
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
PASSED: preimplementation gate attribution trailers (claude).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (claude).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (claude).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (claude).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (claude).denies an escaped single quote near a dollar sign
PASSED: preimplementation gate attribution trailers (codex).admits a separate-value trailer option
PASSED: preimplementation gate attribution trailers (codex).admits an equals-form trailer option
PASSED: preimplementation gate attribution trailers (codex).admits two trailer options
PASSED: preimplementation gate attribution trailers (codex).admits a multi-message form with both trailers in one single-quoted paragraph
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a backtick
PASSED: preimplementation gate attribution trailers (codex).admits a single-quoted subject containing a dollar sign and a command substitution
PASSED: preimplementation gate attribution trailers (codex).admits a chained add and trailer-bearing commit
PASSED: preimplementation gate attribution trailers (codex).admits a POSIX-rooted selector with a trailer option
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a single-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits a hash inside a double-quoted message
PASSED: preimplementation gate attribution trailers (codex).admits an inline angle-bracket attribution in a double-quoted subject
PASSED: preimplementation gate attribution trailers (codex).admits an empty single-quoted trailer value
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
PASSED: preimplementation gate attribution trailers (codex).denies the hash-quote comment desynchronization line
PASSED: preimplementation gate attribution trailers (codex).denies an unquoted trailing comment
PASSED: preimplementation gate attribution trailers (codex).denies a mid-word hash in an exempt operand
PASSED: preimplementation gate attribution trailers (codex).denies an unbalanced single quote around a dollar sign
PASSED: preimplementation gate attribution trailers (codex).denies an escaped single quote near a dollar sign
```

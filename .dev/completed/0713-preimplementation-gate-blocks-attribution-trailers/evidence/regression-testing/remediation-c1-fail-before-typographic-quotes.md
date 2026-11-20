# Remediation Cycle 1 - Fail-Before Run ([P1-T4], expect-fail)

Timestamp: 2026-09-27T05-03

Command: sh <SCRATCHPAD>/x713-newsuite.sh (R-SCOPED, Run.Path `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`; launcher `exec pwsh -NoProfile -File "$(dirname "$0")/x713-newsuite.ps1"`)

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: Run before any production change (helpers at head a30f52f6 plus the three section-4 test rows). PassedCount: 68; FailedCount: 6; FailedBlocksCount: 0; FailedContainersCount: 0. The six FAILED lines are exactly the three section-4 names, each once for `claude` and once for `codex`. Expected-fail outcome confirmed.

EXPOSURE: the helpers at head admit a typographic-quoted $(...) and a typographic-quote-exposed pathspec on both runtimes (CR-1).

## Runner output

```text
PassedCount: 68
FailedCount: 6
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: preimplementation gate attribution trailers (claude).denies a typographic single-quoted command substitution
FAILED: preimplementation gate attribution trailers (claude).denies a typographic double-quoted command substitution
FAILED: preimplementation gate attribution trailers (claude).denies a typographic single quote around a non-exempt pathspec
FAILED: preimplementation gate attribution trailers (codex).denies a typographic single-quoted command substitution
FAILED: preimplementation gate attribution trailers (codex).denies a typographic double-quoted command substitution
FAILED: preimplementation gate attribution trailers (codex).denies a typographic single quote around a non-exempt pathspec
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

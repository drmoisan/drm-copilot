# P1-T1 OperandNormalization suite structure run (issue #732)

Timestamp: 2026-10-09T03-46
Task: [P1-T1]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 1 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1
PassedCount: 28
FailedCount: 48
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 brace-expansion shape
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies the issue 732 escaped dot-segment shape
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped semicolon in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped ampersand in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an escaped pipe in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a mixed dot-backslash segment in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a backslash-spelled operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a comma brace in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a range brace in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a brace in an unquoted message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted comma in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted at-sign name in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted opening parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an unquoted closing parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a star glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a question-mark glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a bracket glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a tilde in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a percent sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a caret in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an exclamation mark in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies an equals sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a plus sign in an operand
FAILED: preimplementation gate helpers operand normalization (.claude/hooks).denies a non-ASCII division-slash look-alike in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 brace-expansion shape
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies the issue 732 escaped dot-segment shape
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped semicolon in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped ampersand in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an escaped pipe in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a mixed dot-backslash segment in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a backslash-spelled operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a comma brace in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a range brace in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a brace in an unquoted message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted comma in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted at-sign name in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted opening parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an unquoted closing parenthesis in a message
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a star glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a question-mark glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a bracket glob under an exempt tree
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a tilde in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a percent sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a caret in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an exclamation mark in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies an equals sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a plus sign in an operand
FAILED: preimplementation gate helpers operand normalization (.codex/hooks).denies a non-ASCII division-slash look-alike in an operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.claude/hooks).admits a single-quoted message containing an at sign
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a leading double slash
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a parent-directory segment
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).denies a drive-letter operand
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the epics tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the parallel tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the active tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the potential tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an ordinary operand under the orchestration artifacts tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits an operand with a dot segment inside an exempt tree
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening brace
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing a comma
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an opening parenthesis
PASSED: preimplementation gate helpers operand normalization (.codex/hooks).admits a single-quoted message containing an at sign
```

Output Summary: EXIT_CODE 1 as expected (fail-before). PassedCount 28, FailedCount 48, FailedBlocksCount 0, FailedContainersCount 0; 76 tests (38 rows on each of two surfaces); the 48 FAILED: lines are the 24 rows marked fails per surface.

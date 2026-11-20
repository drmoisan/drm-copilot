# Gold Standard: test-execution-policy

## Objective

Test-execution policy and launcher. Use before running any local test suite so it runs through the launcher under the machine test-suite lock with the integration and golden lanes excluded, and so exit codes 75 and 2 are read correctly. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Commands: The suite name is the first argument, and extra arguments follow it and reach the suite unchanged; there is no `-Suite` or `-ExtraArgument` parameter.
- **OB-2** Exit Codes and Messages: Classification by consumers: a result is a queue timeout when its exit code is 75, or when it is non-zero and the first non-blank line of its captured output starts with `TEST_EXECUTION_QUEUE_TIMEOUT:`.
- **OB-3** Configuration: `config/test-execution-policy.json` is optional and repository-owned (it is not pushed down).
- **OB-4** Machine Test-Suite Lock: `XDG_RUNTIME_DIR` is not used.
- **OB-5** Hook: The hook denies a direct test runner with `TEST_EXECUTION_POLICY_BLOCKED:` and the launcher command, and allows a runner word followed only by `--version`, `--help`, or `-h`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Commands, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Exit Codes and Messages, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Configuration, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Machine Test-Suite Lock, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Hook, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

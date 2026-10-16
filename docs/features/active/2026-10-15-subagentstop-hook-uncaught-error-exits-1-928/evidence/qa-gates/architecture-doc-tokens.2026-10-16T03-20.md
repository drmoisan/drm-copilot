# Architecture Doc Tokens (issue #928, P7-T10)

Timestamp: 2026-10-16T03-20
Command: grep -c -F "exits with code 1 and blocks" docs/engineering/claude-code-architecture.md
EXIT_CODE: 1
ExpectedExitCode: 1

Further commands:
- `grep -c -F "exits with code 2, which blocks" docs/engineering/claude-code-architecture.md` (EXIT_CODE 0)
- `grep -c -F "raises an unhandled error" docs/engineering/claude-code-architecture.md` (EXIT_CODE 0)

Output Summary: counts 0, 1, 1. The document no longer states that a SubagentStop exit 1 blocks; it states exit-2 blocking, including on an unhandled error.

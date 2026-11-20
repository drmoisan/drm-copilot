# Architecture-Doc Tokens (remediation cycle 1, P3-T6)

Timestamp: 2026-10-16T05-26
Command: grep -c -F "PreToolUse fails open on exit code 1" docs/engineering/claude-code-architecture.md
EXIT_CODE: 0
CYCLE_BASE: b08496681062990d39ccc4e1a07767b9854701d3
Output Summary:

P3-T1 token checks (docs/engineering/claude-code-architecture.md):
- grep -c -F "exits with code 1 and the Bash command is rejected" -> 0
- grep -c -F "PreToolUse fails open on exit code 1" -> 1
- grep -c -F "hookSpecificOutput.permissionDecision" -> 1
- grep -c -F "exits with code 2, which blocks" -> 1 (line 239 unchanged)
- git diff --numstat CYCLE_BASE -- docs/engineering/claude-code-architecture.md -> 1 added, 1 deleted

AC10 checks:
- grep -c -F "exits with code 1 and blocks" -> 0
- grep -c -F "exits with code 2, which blocks" -> 1
- grep -c -F "raises an unhandled error" -> 1

Mirror check:
- git ls-files '*claude-code-architecture.md' -> docs/engineering/claude-code-architecture.md (only; no mirror)

# Width and Architecture-Doc Tokens (remediation cycle 1 baseline)

Timestamp: 2026-10-16T04-23
Command: awk 'length > 120 { print FILENAME ":" FNR ":" length }' .claude/hooks/subagentstop-envelope.ps1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Gated lines present: `.claude/hooks/subagentstop-envelope.ps1:12:182` and `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9:178`.
- Other lines over 120 characters (pre-existing, not gated): helper lines 50 (127) and 122 (125); test lines 20, 22, 23, 24, 29, 30, 31, 38, 44, 54, 56, 58, 64, 66, 71, 76, 78-99, 105, 106, 111, 139, 140, 142, 145, 147, 148, 150, 246, 250, 269, 274, 275 (all code or data lines outside the comment-based help block).

Additional commands:

- Command: grep -c -F "exits with code 1 and the Bash command is rejected" docs/engineering/claude-code-architecture.md
  EXIT_CODE: 0
  Output: 1
- Command: grep -c -F "PreToolUse fails open on exit code 1" docs/engineering/claude-code-architecture.md
  EXIT_CODE: 1 (grep exits 1 when the count is 0)
  Output: 0
- Command: git ls-files '*claude-code-architecture.md'
  EXIT_CODE: 0
  Output: docs/engineering/claude-code-architecture.md (no mirror)

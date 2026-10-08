# Final QC line limits and production-file boundary (P5-T8)

Timestamp: 2026-10-07T11-21
Command: wc -l <four files>; git diff --name-only origin/main...HEAD -- scripts src extensions; git status --porcelain -- scripts src extensions
EXIT_CODE: 0
Output Summary: all four counts at or under 500 (49, 199, 467, 499); both git commands printed nothing.

Deviation note: the Bash tool does not expose the process exit code; EXIT_CODE 0 is inferred from the successful output of each command (empty output for the git commands is the asserted result).

Line counts (`wc -l`):
```
   49 tests/scripts/dev_tools/claude_payload_scope_test_support.py
  199 tests/scripts/dev_tools/test_claude_payload_scope_support.py
  467 tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
  499 tests/scripts/dev_tools/test_claude_rules_frontmatter.py
 1214 total
```
`git diff --name-only origin/main...HEAD -- scripts src extensions`: no output.
`git status --porcelain -- scripts src extensions`: no output.

# Documentation Literals (P5-T8, AC-12)

Timestamp: 2026-10-09T04-10
Command: git grep -n -F "### File-shape recognition (issue #797)" -- .claude/rules/parallel-orchestration.md; git grep -c -F "[a-z][a-z0-9]*" -- .claude/rules/parallel-orchestration.md; git grep -c -F "src/TaskMaster.Domain" -- .claude/rules/parallel-orchestration.md; git grep -c -F "separator-free bare file name" -- .claude/rules/parallel-orchestration.md; grep -n "### Placeholder-shape rejection (issue #502)\|### Module-map granularity criterion" .claude/rules/parallel-orchestration.md
EXIT_CODE: 0
Output Summary: the heading prints exactly one line, at line 385, which lies between `### Placeholder-shape rejection (issue #502)` (line 327) and `### Module-map granularity criterion` (line 423). Each of the three count commands prints a count of 1. The Known false negatives list gained item 7; the lead-in sentence and items 1 to 6 are unchanged (the anchored diff of the rules document against the P0-T3 SHA contains additions only: 39 insertions, 0 deletions).

## Output

```text
.claude/rules/parallel-orchestration.md:385:### File-shape recognition (issue #797)
.claude/rules/parallel-orchestration.md:1
.claude/rules/parallel-orchestration.md:1
.claude/rules/parallel-orchestration.md:1
327:### Placeholder-shape rejection (issue #502)
423:### Module-map granularity criterion
```

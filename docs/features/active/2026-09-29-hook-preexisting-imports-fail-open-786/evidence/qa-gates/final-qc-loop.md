# Final QC Loop Closure ([P11-T10])

Timestamp: 2026-10-10T06-28
Pass: 4
Command: Reads the [P11-T1] to [P11-T9] artifacts of QC pass 4.
EXIT_CODE: 1
Output Summary: Eight of nine rows are GREEN. [P11-T3] is NOT GREEN because of the full-run coverage gap. All rows carry Pass: 4. No step changed files in pass 4: Formatted 0, SHA_UNEQUAL 0, and the MCP format tool also left every SHA pair equal.

- P11-T1: GREEN (Pass: 4)
- P11-T2: GREEN (Pass: 4)
- P11-T3: NOT GREEN (Pass: 4). Tests 9495 passed and 0 failed, and JUnit failures 0 and errors 0. Four Codex files are below 85.00 coverage; see final-pester-coverage.md.
- P11-T4: GREEN (Pass: 4)
- P11-T5: GREEN (Pass: 4)
- P11-T6: GREEN (Pass: 4)
- P11-T7: GREEN (Pass: 4)
- P11-T8: GREEN (Pass: 4)
- P11-T9: GREEN (Pass: 4)

ACCEPTANCE-GAP: not every row reads GREEN. Restarting at [P11-T1] would reproduce the same result. The [P11-T3] gap is deterministic across [P10-T3] pass 2 and [P11-T3] pass 4, and no file in the plan's scope can change the profiler attribution without an operator decision; see deviations.md, [P10-T3] and [P10-T4]. [P11-T10] is left unchecked and escalated.

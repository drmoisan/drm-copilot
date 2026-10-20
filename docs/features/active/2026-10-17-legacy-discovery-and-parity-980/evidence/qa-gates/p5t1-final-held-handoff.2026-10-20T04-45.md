# P5-T1 retained final-gate result

Timestamp: 2026-10-20T04-45
Command: `poetry run python SCRATCH/issue-980-p5t1-final-held.py`
EXIT_CODE: 0
Output Summary: Passing stages 1–6 and failed native-stage evidence are preserved; task acceptance remains pending.

The 49 graph tests, 138 caller tests and four contracts passed. All 27 measured callable/class ranges passed. Validator coverage is 150/150 statements and 52/52 branches; report coverage is 111/111 and 26/26; population coverage is 113/115 and 46/50, retaining its two known statements and four branch gaps without loss. The accepted 114-case helper proof was reused.

The native composition passed eight assertions, then failed the previous-view equality assertion. Its semantic digest remains stable; generated Markdown incorrectly enters coverage scan-input accounting. Assertions 10–14 were not executed. The complete bounded finding is assigned to coordinator/reviewer routing, with no source/test/fixture edits here.

Exact original output/progress/coverage bytes are decode-verified in the lossless archive. Native failed streams are preserved separately. Candidate, review and helper proofs are referenced without repeating historical inventories. The caller duration of 927.939 seconds and native failed duration of 21.048 seconds are not host timeout limits.

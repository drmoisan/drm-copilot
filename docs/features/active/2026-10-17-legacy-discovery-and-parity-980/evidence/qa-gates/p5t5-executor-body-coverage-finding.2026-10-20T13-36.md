# P5-T5 exact body-coverage finding

Timestamp: 2026-10-20T13-36
Command: poetry run python SCRATCH/issue-980-p5t5-trace-coverage.py
EXIT_CODE: 0

RC2: `_trace` is 8/9 body statements (88.89%) and 3/4 branches in both the retained 77-case and final 118-case reports. Its only missing statement is line 179 (`raise ReportLimitError()`); the missing arc is 178 to 179. The previous 9/10 AST-range result counted executed declaration line 157. There is no lambda/nested-function attribution ambiguity.

Within the same fixed 17 renderer ranges, the other 16 named bodies meet 90%; no named lines or arcs lost coverage. Add one deterministic test-only exhausted-byte trace control using the actual local budget, asserting refusal before serialization. No production change or checker exemption is indicated.

All 118 tests passed. The failed subprocess was the coverage proof reader, which detected this real unit-coverage gap. Four contracts remain unexecuted. No tests were replayed and all original evidence remains unchanged.

Exact populations, raw bytes, diagnostics and harnesses: [p5t5-executor-body-coverage-finding.2026-10-20T13-36.json](p5t5-executor-body-coverage-finding.2026-10-20T13-36.json).

Current phase: P5. P5-T5 acceptance remains pending. Next five: P5-T5, P6-T1, P6-T2, P6-T3, P7-T1.

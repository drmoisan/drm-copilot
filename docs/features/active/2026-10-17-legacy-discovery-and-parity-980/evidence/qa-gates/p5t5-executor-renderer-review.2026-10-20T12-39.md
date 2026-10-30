# P5-T5 renderer candidate review

Status: **COMPLETE_FINDINGS_REPAIR_REQUIRED**. No open probe remains.

The exact three-file candidate is bound by `7dafe0d5590cebfb4fac47892c2068f054fbe716e39d3e9bf4cd1135cef7ac40`. The retained first batch executed all 62 nodes: **60 passed and two fixture failures**. Current coverage is 205/215 statements and 88/98 branches; `_Output.measure` and `_Output` remain below their required statement threshold.

- **RR1:** Public carriers undercount Unicode path bytes and apply an unrelated JSON-LF deduction. The bounded four-call probe demonstrates excess acceptance and rejection at the exact ASCII limit.
- **RR2:** `_feature` concatenates a tag prefix before reserving its bytes; JSON work also omits the escaped-output traversal/copy cost. Reserve the prefix/tag and measured escaped-output work before their protected allocations.
- **RT1:** Correct the model-rejected byte fixture and select the intended target criterion explicitly, retaining existing assertions.
- **RC1:** Add minimum meaningful serializer resource controls to close the measured class/method gaps, preserving the original 62 cases.
- **PC1:** Complete only the enumerated typed parameter, return/effect contracts and adjacent filtering comment in the JSON receipt.

Ready membership, traceability, literal escaping, exact generated tags, deterministic identity/path handling and no-I/O separation are otherwise clear in this bounded review. Accepted generator/model semantics and the separate Set E slice were not re-reviewed. Task acceptance remains pending.

Evidence: [p5t5-executor-renderer-review.2026-10-20T12-39.json](p5t5-executor-renderer-review.2026-10-20T12-39.json), [p5t5-executor-renderer-probe.2026-10-20T12-39.json](p5t5-executor-renderer-probe.2026-10-20T12-39.json), and [p5t5-renderer-candidate.2026-10-20T12-30.json](p5t5-renderer-candidate.2026-10-20T12-30.json).

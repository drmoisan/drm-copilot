# P5-T3 semantic candidate review

Status: SEMANTIC_REVIEW_REPAIR_REQUIRED. One production dispatch regression and one test fixture defect; no open probes.

- SD1: completion-only preflight and malformed diagnostics currently also capture validation-report. Restore its prior malformed ValueError and preserve its valid envelope.
- ST1: positional slicing of sorted capture tuples duplicates scope.yaml. Select added members by path and preserve the three malformed-output refusal assertions.

The retained run passed 17 cases and failed 3 at fixture construction after the malformed diagnostics assertions passed. The requested coverage false branch is reachable for validation-report; it cannot receive an unreachable-path qualification. Add the existing coverage-report control and valid/invalid validation-report controls to the narrow corrected proof.

Selected-mode assessment, trusted-warning aggregation, cache ownership, malformed completion behavior and unchanged coverage/parity branches are clear within this delta. The producer and mechanical reviews are retained by reference. No source, test, plan, AC, checkpoint or Git changes were made.

Exact bindings and reproduction: `p5t3-executor-semantic-review.2026-10-20T09-21.json`; `p5t3-executor-semantic-probe.2026-10-20T09-21.json`. Task acceptance remains pending.

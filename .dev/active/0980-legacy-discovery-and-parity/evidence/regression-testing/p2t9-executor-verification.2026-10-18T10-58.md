# P2-T9 independent executor verification

Timestamp: 2026-10-18 10:58:28 UTC

Command: `poetry run python SCRATCH/issue-980-verify-p2t9.py 2026-10-18T10-57`

EXIT_CODE: 0

## Output Summary

Accepted P2-T9. Eight exact staged paths match their final hashes; 203 previously accepted paths and 24 frozen v1/export paths are unchanged. All 63 independent checks pass against final production bytes. Raw coverage is 395/396 executable lines and 177/178 branch arcs. All 33 measured callable/class ranges meet the new-unit requirement, with minimum line coverage 96.774194%. Maximum physical file length is 461.

The checker recomputed staged Git identities, working-file SHA-256 values, raw coverage totals, AST unit ranges, required docstrings and physical lengths. It verified Python 3.10 syntax and bound the final [38-case mode/output run](p2t9-executor-probes-final.2026-10-18T10-51.json), [23-case additional run](p2t9-executor-additional-final.2026-10-18T10-50.json), and [older-report regression](p2t9-executor-report-final.2026-10-18T10-50.json) to the specialist's final bytes. [Numerical proof](p2t9-executor-checks.2026-10-18T10-58.json) records the full comparison; no broad suite was repeated.

## Task acceptance

- `validate_snapshot` requires an explicit mode and applies the captured profile, trusted schema kinds, exact versions and accepted graph/evidence/claim rules to all present artifacts. Missing profile bytes, malformed unreferenced structured files and v1 artifacts fail the v2 aggregate contract.
- Honest draft collections pass structural validation while configured discovery, parity and planning requirements fail. Discovery and parity are distinct: truthful partial target parity can coexist with complete source discovery but cannot satisfy parity completion. Configured planning follows exactly its declared prerequisite; `none` cannot waive core claim or evidence integrity.
- Completion composes coverage, evidence, unresolved behavior, ready acceptance specifications and configured dimensions. Per-source identity and current inventory remain explicit. Approved target behavior can coexist with a separate open legacy-observation question; required remaining uncertainty blocks completion when configured, without changing observed facts.
- All four role-output sets are tested with separately supplied invocation context and exact manifest kind, ID, path, role, invocation and original-content preconditions. Changes outside grants or selected collection identities fail; approved decision facts remain immutable.
- A reviewer can produce a valid failing report: `output_valid=true` and `validation_result=fail` remain separate, and actual recomputed review findings are retained. Fabricated pass status, missing findings and incorrect counts fail. Role context cannot authorize a root planning mode.
- Report projections use an explicit report/control-excluding input digest, while the complete validation result retains the full snapshot digest. Current requested reports are recomputed. Unchanged, unrequested earlier reports may remain during incremental agent output and grant no current completion authority.
- Findings remain bounded, sorted and fail closed. The immutable snapshot and all source observations remain unchanged by validation.

The consolidated older-report defect is corrected. Its [original stable-byte failure](p2t9-executor-report-review.2026-10-18T10-33.md), [first correction proof](p2t9-executor-report-regression.2026-10-18T10-36.md), and final frozen-byte regression are retained. Initial probe fixture mistakes and provisional source-stability failures are explicitly recorded and are not presented as production defects.

## Quality and remaining boundaries

The [specialist handoff](../other/p2t9-validation-composition.2026-10-18T10-57.md) and separate pass-7 receipts show Black/Ruff clean, full repository Pyright with zero diagnostics, [107 focused tests](p2t9-pass7-tests.2026-10-18T10-54.md) in 397.99 seconds, and [107 reversed tests](p2t9-pass7-isolation.2026-10-18T10-57.md) in 155.61 seconds. The static audit covers 73 documented units with no findings; tracked quality tiers remain 26/26 and resource closure remains 33. The final [metrics](p2t9-coverage-metrics.2026-10-18T10-57.json) and [raw coverage](p2t9-coverage.2026-10-18T10-57.json) agree.

Production coverage is 139/140 lines and 67/68 arcs for agent_output; completion_rules, validation and validation_inputs are respectively 72/72 and 46/46, 133/133 and 42/42, and 51/51 and 22/22. The uncovered output guard is defensive after manifest schema validation; its containing method is 30/31 covered. Earlier format/type failures, the pass-5 104-pass/one-fixture-failure result, its 393/396 lines and 175/178 arcs, and the evaluate 11/13 callable gap remain preserved. The final direct tests cover cached prerequisite reuse and unsupported report modes.

[AC-24](../other/p2t9-ac24-verification.2026-10-18T10-58.md) is independently satisfied at the pure completion-policy layer and synchronized in spec.md, user-story.md and issue.md. CLI result/exit mapping, rendered reports, native authority, mutation commit and host hooks remain assigned to their later tasks. A pure passing result is not a native receipt or write grant.

Phase 2 is complete: 24/84 plan tasks. Feature criteria are 6/66 per source (AC-10 through AC-14 and AC-24). Python task gates pass. This task changes no TypeScript, PowerShell or C#; final repository QA remains Phase 11.

Current phase completed: Phase 2. Next tasks: P3-T1, P3-T2, P3-T3, P3-T4, P3-T5.

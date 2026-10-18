# P2-T7 independent executor verification

Timestamp: 2026-10-18 10:00:38 UTC
Command: `poetry run python SCRATCH/issue-980-verify-p2t7.py 2026-10-18T09-59 49`
EXIT_CODE: 0
Output summary: PASS — 49 independent cases bound to final staged source; five owned paths; 193 accepted prior paths and 24 frozen compatibility paths unchanged; 246/249 executable lines and 104/108 branch arcs; all 23 measured callable/class ranges meet 90% line coverage; maximum 489 physical lines; staged whitespace check passes.

## Acceptance and scope

P2-T7 is verified. Required dimensions and acceptance obligations preserve the global/client/feature/scope union. Explicit criterion selectors determine where a ready expectation applies; missing inherited tuples remain incomplete. Current approved decisions add requirements only inside their scope, and decision-origin provenance prevents a source-only scenario from satisfying a changed target expectation with the same criterion ID. An approved target replacement preserves historical source facts without requiring a contradictory target expectation.

Unknown, contradictory or inferred client-required behavior cannot hide under a verified summary, including structural validation and disabled optional completion gates. Required not-applicable dispositions require rationale and a current scoped approval. Unconfigured optional modes create neither obligations nor successful verification. Pending and superseded specifications do not satisfy completion. Confirmed justified no-scope and fully accounted supporting-only inventory are supported; draft, empty or undispositioned inventories do not establish completion.

The [49-case proof](p2t7-executor-probes.2026-10-18T09-57.json) and its [command receipt](p2t7-executor-probes.2026-10-18T09-57.md) match both final production hashes. All semantic cases are authoritative-schema-valid, have zero upstream reference/evidence/decision/observation/revision findings, and preserve immutable snapshot hashes. This verifier reused those passing results after confirming final bytes; it did not repeat broad test suites. The complete staged/hash/coverage result is [machine-readable](p2t7-executor-checks.2026-10-18T10-00.json).

## Quality evidence

The [specialist handoff](../other/p2t7-dimension-acceptance.2026-10-18T09-59.md), [raw coverage](p2t7-coverage.2026-10-18T09-59.json), [metrics](p2t7-coverage-metrics.2026-10-18T09-59.json) and [final audit](p2t7-audit-pass11.2026-10-18T09-59.md) were independently checked.

- Clean ordered pass 11: [Black](p2t7-black-pass11.2026-10-18T09-57.md) leaves five files unchanged; [Ruff](p2t7-ruff-pass11.2026-10-18T09-57.md) reports zero findings; [full Pyright](p2t7-types-pass11.2026-10-18T09-57.md) reports zero errors/warnings/information diagnostics; [focused Pytest](p2t7-tests-pass11.2026-10-18T09-58.md) passes 95 tests in 41.49 seconds.
- [Reversed test modules](p2t7-isolation-pass11.2026-10-18T09-58.md) pass all 95 tests in 17.43 seconds.
- dimension_rules: 97/98 lines (98.979592%), 31/32 arcs (96.875%); acceptance_rules: 149/151 lines (98.675497%), 73/76 arcs (96.052632%). All 23 measured new callable/class ranges meet the required 90%, with no changes to accepted prior code or its coverage.
- [Quality-tier classification](p2t7-quality-tiers-pass11.2026-10-18T09-58.md) passes 26/26 projects. [Resource checking](p2t7-resources-pass11.2026-10-18T09-58.md) reports no drift across all 33 schemas and preserves the accepted resource manifest hash.
- Five exact staged files match current bytes and metrics. The permitted same-component test split retains both prescribed modules and adds test_acceptance_scope.py. Physical lengths are 309/489 production lines and 425/458/214 test lines; no file exceeds 500. Tests use immutable shared fixtures and fresh memory graphs, with no temporary files, network or process execution.

Python is the only implementation language changed in this task. TypeScript, PowerShell and C# gates are not newly applicable. Full repository QA, wrapper/native-host checks and feature review remain assigned to later plan tasks; no full-feature completion is claimed.

## Retained failures and follow-on contract

The initial [three-finding review](p2t7-executor-review.2026-10-18T09-42.md) and all failed specialist loops remain preserved. The same-ID source-versus-decision origin variant is retained in [its failing regression receipt](p2t7-origin-regression-pass10.2026-10-18T09-56.md) and passes the final positive/negative cases. Earlier verifier fixture errors involved an unrelated missing example evidence link, canonical terminal-LF encoding and an omitted required nullable supporting_rationale key; each correction is documented in its command receipt and did not alter production.

P5 generation must reuse acceptance_source_digest and preserve the exact ready criterion expectation, explicit tuple applicability and approved-decision provenance. Ready specifications remain distinct from target test results. P2-T9 must compose these rule findings with prior structural/reference/evidence/claim/decision/coverage results. The existing open-legacy-question versus approved-target-policy distinction remains intact for completion and documentation.

Only P2-T7 is checked off. Progress is 22/84 tasks; acceptance criteria remain 5/66 in each requirement source. No broader criterion is fully delivered by this isolated rule task. Next: P2-T8, P2-T9, P3-T1, P3-T2, P3-T3.

# P1-T8 independent executor verification

Timestamp: 2026-10-18T06-25
Command: poetry run python SCRATCH/issue-980-verify-p1t8.py
EXIT_CODE: 0
Output Summary: 68 independent parser/model/finding cases passed; six exact staged paths and 138 unchanged prior-task paths verified; new production coverage is 362/368 lines and 155/158 branch arcs.

## Scope and acceptance

Verified the final [specialist handoff](../other/p1t8-structured-parsing.2026-10-18T06-24.md), three production modules, three test modules and the final ordered gate receipts. The [machine receipt](p1t8-executor-checks.2026-10-18T06-25.json) records exact staged Git blobs, SHA-256 hashes, physical line counts, independent cases and recomputed per-unit coverage. Maximum task-file length is 418 lines. All 138 previously verified paths retain their hashes; no dependency, existing helper, compatibility adapter, schema or resource changed.

Independent cases verify identical JSON/YAML normalized values, duplicates and escaped-key collisions, YAML merges/cycles/non-string keys/unsupported tags, nonfinite numbers, invalid UTF-8 and Unicode, wrong roots, explicit syntax selection, byte/depth/record/node limits, bounded alias expansion, detached immutable values, canonical round trips, raw input digests and deterministic diagnostic order. The specialist suite additionally tests the actual 16 MiB boundary and nesting limits through the configured hard ceiling. Failed parsing exposes no partial value. A successful parse grants no schema, evidence, completion or native authorization claim.

The structural record budget counts each expanded mapping, including its envelope. A separate finite node budget covers scalar-only alias expansion; source-token and nesting checks run before decoder object construction. This follows the accepted P1-T8 budget interpretation without changing profile fields or source-enumeration limits.

All three independent review findings are corrected and verified:

- Consumer diagnostic paths retain schema-valid capitals, spaces, Unicode and dot directories; unsafe context paths fail for both valid and invalid documents.
- Reaggregating a truncated result retains one marker and actionable findings with unique, deterministic, idempotent output.
- The reserved FINDINGS_LIMIT marker cannot use warning or info severity. Both invalid constructors fail, and either input order preserves a blocking marker at limit one.

The first 64 independent cases are retained and pass against final bytes. Four additional severity/order cases prove the final correction. The pre-correction probe demonstrated blocking_count=0 when a warning marker displaced REAL_ERROR; it was treated as a defect, not successful acceptance. The final constructor invariant removes that path. The specialist's 06-23 audit/handoff is explicitly superseded by its 06-24 evidence.

## Quality evidence

| Check | Verified result | Evidence |
| --- | --- | --- |
| Black, final ordered pass 6 | Exit 0; six unchanged files | [Formatting](p1t8-format-pass6.2026-10-18T06-23.md) |
| Ruff, pass 6 | Exit 0; zero findings | [Lint](p1t8-lint-pass6.2026-10-18T06-23.md) |
| Full Pyright, pass 6 | Exit 0; zero code diagnostics | [Types](p1t8-types-pass6.2026-10-18T06-24.md) |
| Focused runtime Pytest, pass 6 | Exit 0; 387 passed | [Tests](p1t8-tests-pass6.2026-10-18T06-24.md) |
| Reversed new modules | Exit 0; 189 passed | [Isolation](p1t8-tests-reversed-final.2026-10-18T06-24.md) |
| Tracked tier classification | Exit 0; 26 entries and 26 projects | [Classification](p1t8-tracked-tiers.2026-10-18T06-21.md) |
| Package module/resource check | Exit 0; 33 unchanged resources | [Resources](p1t8-resource-closure.2026-10-18T06-21.md) |
| Independent executor checks | Exit 0; 68 cases, exact staged bytes and prior hashes | [Machine receipt](p1t8-executor-checks.2026-10-18T06-25.json) |

Raw coverage independently confirms findings.py at 78/78 lines and 35/36 arcs, models.py at 84/84 lines and 36/36 arcs, and parsing.py at 200/206 lines and 84/86 arcs. Aggregate coverage is 98.369565% lines and 98.101266% branches. All 45 new function/method/class ranges meet 90% line coverage; the minimum is 91.666667%. These modules have no prior executable baseline because they are newly added. The package retains its previous 198 focused tests and adds 189. Final repository-wide coverage and QA remain pending.

The tracked-tier and resource checks remain applicable because the final correction changed only the existing finding constructor and four tests; package membership, imports and resources did not change. Tests use in-memory data without temporary files, external processes or services. No suppression or test skip was added. TypeScript and PowerShell gates are not applicable to this Python-only task.

## Acceptance-criteria assessment

P1-T8 passes its bounded acceptance criteria. Check only P1-T8, advancing the plan to 12/84. Feature AC status remains 1/66 per source: AC-10 stays verified. AC-12 has parser findings now, but still requires authoritative schema/type/enum/version failure handling in P1-T9. Installed-catalog, extension, graph, profile, filesystem authorization and final QA criteria remain incomplete. P1-T9 is the next task.

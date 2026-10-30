# P1-T9 independent executor verification

Timestamp: 2026-10-18T06-46
Command: poetry run python SCRATCH/issue-980-verify-p1t9.py
EXIT_CODE: 0
Output Summary: 82 authoritative catalog/validation probes and two additional required-field probes passed; nine exact staged paths, 144 unchanged prior paths and 23 frozen v1 paths verified; coverage is 346/346 lines and 144/144 arcs.

## Scope and acceptance

Verified the [specialist handoff](../other/p1t9-offline-catalog.2026-10-18T06-43.md), the complete catalog, authoritative validator, safe compatibility adapter and six changed test modules. The [machine receipt](p1t9-executor-checks.2026-10-18T06-44.json) binds every owned path to its staged Git blob and SHA-256, retained independent probe results, physical line counts and recomputed per-unit coverage. The maximum file length is 382 lines. All 144 prior-task paths and 23 frozen v1 schema/example/fixture/test paths are unchanged.

The independent public-runtime probe validates all 16 v2 positive/negative example pairs and all seven frozen v1 positive/negative pairs. It checks the three exact aliases for each v1 kind, caller-selected kind/version, rejected weaker/remote/file schemas, explicit formats, malformed documents, missing format support and configured extensions. Probe source hashes match the final staged production bytes; no broad suite was repeated by the executor.

The actual installed distribution is drm-copilot-discovery 2.0.0 in editable mode. The public catalog reads 33 hash-verified package resources through importlib.resources, rather than the schema-test registry. This satisfies the public validation-entry requirement; independent wheel installation and host publication remain P11-T7 and their separate feature criteria.

All three consolidated defects are corrected: unsupported declared formats fail catalog construction, non-consuming recursive evaluation becomes a blocking SCHEMA_UNAVAILABLE finding, and configured extension rules apply at every reference to the shared core extensions schema. Nested decision/environment failures preserve full pointers. Finite recursive domain values remain valid, and a domain payload key named extensions remains ordinary data. Two [additional AC-14 cases](p1t9-ac14-required-fields.2026-10-18T06-45.json) prove that a permissive extension cannot supply a missing feature_id or permit an extra core property.

The existing seven text validator names and unused cache_dir keyword remain supported. Their default is explicitly frozen v1; trusted callers may request exact v2. Artifact metadata cannot select a weaker schema or initiate network/cache retrieval. Successful v1 results are compatibility-only. Structural success in either version grants no completion or approval authority.

## Quality evidence

| Check | Verified result | Evidence |
| --- | --- | --- |
| Black, ordered pass 5 | Exit 0; nine unchanged files | [Formatting](p1t9-black-pass5.2026-10-18T06-37.md) |
| Ruff, pass 5 | Exit 0; zero findings | [Lint](p1t9-ruff-pass5.2026-10-18T06-37.md) |
| Full Pyright, pass 5 | Exit 0; zero code diagnostics | [Types](p1t9-pyright-pass5.2026-10-18T06-37.md) |
| Focused Pytest, pass 5 | Exit 0; 1,882 passed | [Tests](p1t9-tests-pass5.2026-10-18T06-41.md) |
| Reversed changed modules | Exit 0; 223 passed | [Isolation](p1t9-tests-reversed.2026-10-18T06-43.md) |
| Resource closure | Exit 0; 33 resources, no changes required | [Resources](p1t9-resource-closure.2026-10-18T06-41.md) |
| Tracked tier classification | Exit 0; 26 entries and 26 projects | [Classification](p1t9-tracked-tiers.2026-10-18T06-42.md) |
| Exact scope and numeric audit | Exit 0; nine paths, 40 unit ranges | [Audit](p1t9-task-audit.2026-10-18T06-43.md) |

Raw coverage independently confirms catalog.py at 167/167 lines and 82/82 arcs, schema_validation.py at 146/146 lines and 60/60 arcs, and the compatibility adapter at 33/33 lines and 2/2 arcs. All 40 touched function/method/class ranges have 100% line coverage. The adapter's Phase 0 baseline was 44/44 lines and 4/4 arcs, so its percentage does not regress. All 313 new runtime executable lines are covered. The entire touched production surface is covered, including changed adapter lines.

The specialist retained initial formatting/lint/type failures and restarted through the clean pass. No dependency, suppression or skip was added. Tests use in-memory values and committed read-only fixtures; no test creates temporary files or invokes an external process/service. TypeScript and PowerShell gates are not applicable to this task. Full repository QA remains pending.

## Acceptance-criteria assessment and limits

- AC-11 passes: every committed positive example validates through the installed authoritative public runtime; the nine control-envelope fixtures also pass in the specialist suite.
- AC-12 passes: invalid examples, versions, kinds, enums, types, syntax and unavailable dependencies produce actionable code/path/pointer/next_action findings.
- AC-14 passes: namespaced pinned extension schemas strengthen every core extension position without replacing required fields, statuses or schema identity; unsupported formats and external references fail closed.
- AC-13 remains unchecked: cross-artifact identity, reference and claim validation belongs to Phase 2.

Only P1-T9 and AC-11, AC-12 and AC-14 are checked at this transition. AC-10 remains checked. Plan progress becomes 13/84; feature criteria become 4/66 in each source. P1-T10 is next.

Supported declared formats are currently date-time and the HTTP(S) evidence URI contract; other formats fail explicitly. Leap-second data includes known insertions through 2016-12-31 and requires maintenance for future announcements. Profile-controlled filesystem authorization, graph semantics, full installed-wheel proof, publishing and final QA remain their later tasks.

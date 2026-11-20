# P1-T8 structured parsing handoff

Timestamp: 2026-10-18T06-24
Command: poetry run python SCRATCH/issue-980-p1t8-task-audit.py
EXIT_CODE: 0
Output Summary: Six exact staged paths; 387 focused and 189 reversed tests passed; 362/368 new production lines and 155/158 branch arcs covered; all new callable/class ranges meet 90% line coverage.

## Scope, baseline and delivered behavior

Approved plan P1-T8 adds only:

- packages/discovery-runtime/src/drm_copilot_discovery/findings.py
- packages/discovery-runtime/src/drm_copilot_discovery/models.py
- packages/discovery-runtime/src/drm_copilot_discovery/parsing.py
- tests/discovery_runtime/test_findings.py
- tests/discovery_runtime/test_parsing.py
- tests/discovery_runtime/test_parsing_limits.py

These are new production modules and tests, so no pre-existing per-file coverage denominator applies. Phase 0 Python baseline remains 7,336 passed, six existing skips, zero failures, 94.111715% repository line coverage and 88.783742% branch coverage. The current focused runtime suite retains its 198 previous tests and adds 189 tests. Final repository-wide QA remains assigned to the final plan phase.

parse_document accepts explicit JSON or YAML and returns an immutable object or actionable findings without partial data. It rejects duplicate keys (including escaped equivalents), YAML merges/cycles, non-string keys, non-JSON tags/types, nonfinite numbers, invalid Unicode/encoding, malformed syntax, multiple documents and non-object roots. It uses a discovery-local SafeLoader and a fixed scalar-tag whitelist without global constructor registration. There is no decoder fallback, file access, network or application object construction.

Byte and source nesting checks precede decoder construction. Defaults are 16 MiB, nesting depth 64 and 100,000 structural mapping records; the existing profile hard ceilings remain 64 MiB, depth 128 and 1,000,000 records. Root-supplied ParseLimits is immutable; document fields cannot override it. The envelope counts as a mapping record. Each expanded alias occurrence consumes its own record and node budget; cycles are independently rejected. EXPANDED_NODE_MULTIPLIER=64 bounds all expanded value visits, including scalar-only alias trees. Source tokens have an additional precomposition budget of twice that node limit because keys also consume tokens. No analyst input can disable these checks.

Finding values preserve the closed service-result diagnostic fields and provide sorted, unique, bounded aggregation with an explicit truncation error. Reaggregation preserves one existing truncation marker and actionable findings. Consumer path spelling accepts schema-valid capitals/spaces/Unicode/dot directories while rejecting lexical escapes; it performs no filesystem resolution or authorization. Parser diagnostic paths are validated for both valid and invalid documents. Immutable objects preserve arrays, sort member keys, reject mutable descendants and provide detached plain projections/canonical UTF-8 JSON. Raw input digests remain distinct from normalized content.

## Verification

| Step | Final result | Evidence under regression-testing |
| --- | --- | --- |
| Black pass 6 | Exit 0; six unchanged files | p1t8-format-pass6.2026-10-18T06-23.md |
| Ruff pass 6 | Exit 0; zero findings | p1t8-lint-pass6.2026-10-18T06-23.md |
| Full Pyright pass 6 | Exit 0; zero diagnostics | p1t8-types-pass6.2026-10-18T06-24.md |
| Focused runtime tests pass 6 | Exit 0; 387 passed | p1t8-tests-pass6.2026-10-18T06-24.md |
| Reversed new test modules | Exit 0; 189 passed | p1t8-tests-reversed-final.2026-10-18T06-24.md |
| Tracked project tier classification | Exit 0; 26/26 projects | p1t8-tracked-tiers.2026-10-18T06-21.md |
| Installed package import/resource closure | Exit 0; all 33 resources unchanged | p1t8-resource-closure.2026-10-18T06-21.md |

New findings.py is 78/78 lines and 35/36 arcs; models.py is 84/84 lines and 36/36 arcs; parsing.py is 200/206 lines and 84/86 arcs. Aggregate line coverage is 98.369565%; branch coverage is 98.101266%. The numerical audit separately intersects raw coverage with every new function/method/class source range: all applicable units meet the 90% line requirement. Uncovered defensive branches reject unsupported decoder values/keys and runtime numeric/recursion errors; no new test skip or suppression was added.

All six task paths are staged at current bytes with a clean whitespace check; maximum file length is 418. All 138 previously verified paths retain exact hashes, including schemas, resource manifests, package dependencies and compatibility adapters. No previous asserting test was changed. Tests use fresh in-memory values only, with no temporary files, subprocesses, network or mutable global state.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t8-coverage.2026-10-18T06-24.json
Exact scope, prior hashes and per-unit coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t8-coverage-metrics.2026-10-18T06-24.json

## Corrections and retained evidence

Independent review found an initial package-resource path validator was too restrictive for consumer diagnostics and a composed-collector case could duplicate its truncation marker. Both were corrected within the six owned files and have direct regressions, including parser caller-path consistency. A final independent probe found that a caller-created FINDINGS_LIMIT warning/info marker could hide a real error under limit one. Finding now rejects those nonblocking reserved severities, with four direct severity/order regressions. Ordered pass 6 and the final reversed run verify the correction. The 06-23 audit/handoff is retained as superseded interim evidence.

Initial Ruff found 25 import/cast/attribute-style and long-line diagnostics. Fourteen were auto-fixed; eleven comment/docstring/literal lines were shortened without assertion weakening. An intermediate Black check required one reformat; its subsequent diagnostics were exploratory, not a clean ordered pass. Pyright then reported 14, and later four, untyped PyYAML/defensive type-narrowing diagnostics. Small typed protocols now isolate the existing library APIs without Any or suppressions. The ordered sequence restarted and passed. Required loop-intent comments were added after pass 4, then pass 5 repeated successfully. The final reserved-marker correction then required pass 6. The tracked-tier/resource checks remain applicable because neither package membership nor resources/imports changed. All failed command evidence is retained; no test failure occurred.

## Boundary and carry-forward

TASK_READY_FOR_VERIFICATION applies only to P1-T8. Executor owns task acceptance/checkoff; coordinator owns staging and checkpoint changes. P1-T9 has not been released.

The installed schema catalog/format validation and v1 reader security integration remain P1-T9. Profile dispatch and filesystem path resolution remain P1-T10/P1-T11. Parsing success establishes only syntactic JSON-compatible data and finite limits; it does not imply schema validity, evidence correctness, gate completion or native authority. Source-file enumeration retains its separate 1,000,000-file profile default in the later inventory boundary.

No generic repository helper, policy, plan/AC checkbox, checkpoint, consumer repository, dependency, schema or resource byte was modified.

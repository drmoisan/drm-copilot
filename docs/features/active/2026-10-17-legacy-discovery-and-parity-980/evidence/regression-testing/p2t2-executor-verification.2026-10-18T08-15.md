# P2-T2 independent executor verification

Timestamp: 2026-10-18T08-15
Command: poetry run python SCRATCH/issue-980-verify-p2t2.py 2026-10-18T08-15
EXIT_CODE: 0
Output Summary: 50 final-byte probes passed; four exact staged paths, 174 accepted prior paths and 24 frozen v1/export paths verified; 245/247 executable lines and 139/144 branch arcs covered; all 20 measured callable/class ranges have at least 95% line coverage.

## Verified behavior

The [specialist handoff](../other/p2t2-references.2026-10-18T08-15.md) and [independent machine receipt](p2t2-executor-checks.2026-10-18T08-15.json) verify an immutable typed index over accepted snapshots. Artifact IDs and domain IDs retain separate repository/kind namespaces. Collection members inherit trusted repository ownership and physical paths, while links resolve to the member's own artifact kind. Missing, duplicate, ambiguous, wrong-kind and path-mismatched links produce stable blocking findings.

The 50 independent probes were rerun against both final production hashes. They cover qualified and bare foreign IDs, original versus imported storage paths, whole-file versus collection-member references, nested behavior/evidence links, inventory component and diagnostic identifiers, scope/ledger inventory selection, parity feature identity, acceptance criterion linkage, malformed header retention, opaque extension/action payloads and deterministic duplicate diagnostics. Probe fixtures deliberately include narrow malformed index inputs; they do not replace the authoritative schema-validation proof. Existing loader findings remain blocking. A source-contract reference retains its pin and digest for subsequent integrity validation.

The final checker independently recomputed four staged Git object identities, current SHA-256 values, all raw coverage counts, all measured callable/class ranges and physical line counts. It verified all 174 previously accepted paths and 24 frozen v1/export paths unchanged. Maximum file length is 473; staged whitespace checks pass. The approved same-component split places schema traversal and scalar linkage in reference_links.py and leaves immutable values, indexing, collection expansion and duplicate checks in references.py. No prior runtime, dependency, schema, resource or test helper changed.

## Quality evidence

The [aggregate command record](p2t2-gates.2026-10-18T08-12.md) retains the clean ordered pass and its earlier failure:

| Check | Verified result |
| --- | --- |
| Black, pass 3 | Exit 0; four files unchanged |
| Ruff, pass 3 | Exit 0; zero findings |
| Full Pyright, pass 3 | Exit 0; zero code diagnostics |
| Focused Pytest | Exit 0; 64 passed in 3.08 seconds |
| Reversed module order | Exit 0; 64 passed in 1.29 seconds |
| Tracked quality tiers | Exit 0; 26 entries/26 discovered projects |
| Packaged resource check | Exit 0; existing 33-resource closure unchanged |
| Final task audit | Exit 0; no findings in the staged-path/coverage metrics |

Raw coverage independently confirms reference_links.py at 93/93 lines and 65/68 arcs, and references.py at 152/154 lines and 74/76 arcs. Aggregate coverage is 99.190283% lines and 96.527778% branches; all 20 measured new callable/class ranges meet the 90% line requirement, with a minimum of 95%. Previously accepted production bytes are unchanged, so their changed-line coverage does not regress. Tests use fresh in-memory documents and manifests with immutable schema/profile fixtures; they create no temporary files, subprocesses or network operations. TypeScript, PowerShell and C# gates are not applicable to these Python-only additions. Full repository QA remains Phase 11.

Earlier preparation failures remain identified in the handoff and aggregate record. The initial combined file exceeded 500 lines after formatting and was split under the plan's existing provision. Import, line-length and closure-binding findings were corrected. Ordered pass 2 stopped at eight typing diagnostics; explicit shared module interfaces, tuple narrowing, immutable lookup visibility and the test mapping annotation resolved them without suppressions. Pass 3 is the complete clean ordered pass. The executor's first SCRATCH probe launch stopped before execution because of one unmatched parenthesis in the probe helper; only that helper was corrected, after which all 50 probes passed and later passed again against final source hashes.

## Checkoff and continuation

P2-T2 is verified and checked. Plan progress is 17/84, with P2-T3 next. AC-10, AC-11, AC-12 and AC-14 remain checked, 4/66 per requirement source. AC-13 remains pending the explicitly required cyclic-supersession proof assigned to P2-T5; no broader criterion is inferred from the reference index alone.

Resolution is an identity result, not evidence of runtime truth, product approval or completion. Evidence hashes/revisions, decision scope/readiness, configured feature/criterion/client/mode obligations, supersession cycles and composed validation modes remain assigned to P2-T3 through P2-T9. No later task was implemented or released by this verification.


## Command-receipt format correction — 2026-10-18T09-02

The retained aggregate command log was normalized into individual write-time-stamped receipts without rerunning commands or changing their recorded results. Original capture/start timestamps, commands, exit codes and output are preserved. See the [verified extraction index](p2-command-receipt-normalization-verification.2026-10-18T09-02.md) for the one-to-one mapping and unchanged aggregate hashes. This note corrects evidence format only; the task acceptance and production-byte verification above are unchanged.

# AC-13 cross-artifact reference verification

Timestamp: 2026-10-18T09-11
Criterion: Cross-artifact references are validated.
Result: PASS

The accepted [P2-T2 verification](../regression-testing/p2t2-executor-verification.2026-10-18T08-15.md) supplies 50 independent final-byte cases plus 64 focused and 64 reversed tests for duplicate/missing IDs, wrong-kind links, path identity, ambiguous and explicit cross-repository ownership, collection members and nested/scalar references. Those production hashes are unchanged in the P2-T5 audit. Accepted [P2-T3 evidence/revision verification](../regression-testing/p2t3-executor-verification.2026-10-18T08-36.md) independently checks pinned artifact references and captured-byte identity.

[P2-T5 verification](../regression-testing/p2t5-executor-verification.2026-10-18T09-11.md) closes the remaining cyclic-supersession obligation with approved/proposed self, two-node and three-node cycle tests, acyclic replacement and invalid resolution references. Its 38 independent cases include a 1,200-record valid chain, while the final ordered and reversed suites each pass 88 tests. All 19 new callable/class ranges have 100% line coverage. The corrected historical-conflict regression passes against the final staged hash.

This directly satisfies the AC-13 traceability row. Check only this criterion in the full-feature authoritative spec.md and user-story.md and the synchronized issue.md mirror, preserving its text. Feature criteria are five of 66 verified per source (AC-10, AC-11, AC-12, AC-13 and AC-14). Complete validation modes, CLI exposure, completion authorization and full repository QA are separate pending criteria; none is inferred from this reference-graph proof.

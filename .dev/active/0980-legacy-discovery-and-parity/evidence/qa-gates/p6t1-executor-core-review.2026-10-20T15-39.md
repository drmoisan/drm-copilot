# P6-T1 core source review

**SCOPED_FINDINGS_COMPLETE — changes required.** Frozen six-file candidate: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-core-source-freeze.2026-10-20T15-20.json` (`2daa4d244d233ef48280461dd1bbf8821ce252e3fa61c524cd58a3d65bd78985`).

- **CR1:** Early provider/I-O and catalog failures can raise `ValueError` instead of returning the typed failure envelope. Bootstrap failure packaging can repeat the failed freshness check and rethrow `OSError`. Preserve truthful observed context and use the approved failure schema without weakening authority.
- **CR2:** Projection hashes 4,096 bytes after its 2,048-unit work budget is exhausted. The coordinator alone performs 4,560 equality comparisons for 96 findings after reserving 768 units. Reserve actual cumulative work before projection and ordering.
- **CT1:** Fix the retained test fixture's missing `Finding.next_action` and narrow its count values before comparison. Preserve assertions; no suppression is required.

Both bounded probe processes exited 0 and preserved all six core and three shared dependency hashes. Source-only Black/Ruff/Pyright receipts remain retained; the subsequent test preparation has the two typing corrections above and no behavioral batch.

Exact original six-source streams and executed probe/output bytes: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-core-probe.2026-10-20T15-39.json`. Locations, observations and finite repair bounds: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-core-review.2026-10-20T15-39.json`.

No open probe remains. No source/test or acceptance checkbox was changed. Current phase P6; next five tasks: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.

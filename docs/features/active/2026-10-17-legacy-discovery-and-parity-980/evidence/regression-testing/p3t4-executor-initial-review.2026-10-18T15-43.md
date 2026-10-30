# P3-T4 preliminary independent draft review

Timestamp: 2026-10-18T15-43
Command: poetry run python SCRATCH/issue-980-p3t4-review-probes.py
EXIT_CODE: 1
Output Summary: 24 of 25 behavioral assertions passed; nested verified transition creation was unexpectedly accepted. Source hashes changed while this unfrozen implementation was being formatted, so this run is preliminary diagnostic evidence, not final-byte proof.

The prior fixture-only stop is retained in p3t4-executor-fixture-diagnostic.2026-10-18T15-41.md. This corrected run covered deterministic IDs/bytes, null unknowns, linked questions, no generated evidence or approval, optional mode requirements, inherited client/global/feature requirements, custom roots, complete planner positives, missing grants/feature links, preserved prior questions, collisions and prohibited summary/run/capture promotions.

Exact assertions and before/after source hashes: [preliminary probe result](p3t4-executor-initial-probes.2026-10-18T15-43.json).

A separate three-case probe on unchanged current source confirms the nested-phase finding; the preliminary run is not used to claim current source identity.

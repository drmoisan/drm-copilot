# P2-T6 source-runtime identity review

Timestamp: 2026-10-18T09-26

Command: `poetry run python SCRATCH/issue-980-p2t6-runtime-identity.py`

EXIT_CODE: 0

Output Summary: Two authoritative schema-valid runtime cases executed. The same-source observed-runtime control passes. The negative case also incorrectly passes: a source ledger's required characterization is satisfied solely by target-owned runtime observations at another repository and revision. All reference, evidence, claim and revision checks return zero findings in both cases.

Machine result: [Runtime identity review](p2t6-executor-runtime-review.2026-10-18T09-26.json).

The fully pinned cross-repository feature link is legitimate traceability, but it does not make target execution evidence legacy source characterization. P2-T6's runtime qualification must match the source ledger repository and revision. This correction is confined to the current coverage helper and direct regression tests; accepted earlier rules remain unchanged. The coordinator and specialist received this concrete finding.

This diagnostic collector exit code does not mean task acceptance. The final assertion-based probe must reject the target-runtime case and retain the valid source-runtime control. Current recorded source hashes are in the machine result.

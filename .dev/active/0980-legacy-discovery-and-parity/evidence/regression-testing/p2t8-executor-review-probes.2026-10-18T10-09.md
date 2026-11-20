# P2-T8 independent review probes

Timestamp: 2026-10-18T10:09:51Z

Command: `poetry run python SCRATCH/issue-980-probe-p2t8.py`

EXIT_CODE: 1

Output Summary: 45 of 49 cases passed with stable production hashes. Every failing semantic case is schema-valid and has zero prerequisite reference, evidence, revision, decision, dimension and observation findings. Exact results are in `p2t8-executor-review-probes.2026-10-18T10-09.json`.

The four failing cases establish three bounded parity defects: an approved retirement skips present-claim proof and duplicate mode consistency; an optional partial feature incorrectly blocks required parity completion; and configured mobile applicability incorrectly requires an evidence platform literally named `mobile`, rejecting a configured `portable` client/platform. The specialist independently identified the first two conditions while its boundaries were still drafts. These findings do not alter accepted lower-level validators or the plan.

The fixture issues from the preceding 45-case run are corrected: wrong-scope decisions now select a configured alternate client, and approved retirement decisions retain schema-required resulting criteria. The executor has not modified production source and has not accepted P2-T8.

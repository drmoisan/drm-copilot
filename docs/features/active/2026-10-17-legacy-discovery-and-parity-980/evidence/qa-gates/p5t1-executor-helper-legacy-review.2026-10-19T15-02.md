# P5-T1 frozen helper and legacy subset review

Timestamp: 2026-10-19T15-02
Command: .venv/Scripts/python.exe SCRATCH/issue-980-p5t1-publish-subset-review.py
EXIT_CODE: 0
Output Summary: CHANGES_REQUIRED. One complete blocking finding; no open behavioral probe.

Scope is report_models.py at 9cab8065 and the three legacy paths in the immutable 14:54 freeze. The existing 37-case clean loop, 38/38 statements, 4/4 branches and 12 original cases are reused. No moving runtime report, validation or helper-test file was reviewed.

P5-T1-SR1: report_models.py lines 137 and 182 use JsonObject.items(), inducing a linear key lookup for every member. A 64-member object performs 2,080 actual key comparisons during ReportBudget.check while only 129 nodes and no work units are charged; bounded_object performs 4,160 comparisons across its two passes. These are deterministic counted results, not timing thresholds. Use existing JsonObject.members directly for immutable values and retain exact-dict traversal; add a small no-keyed-lookup regression. No accepted primitive change is needed.

The legacy forwarding, v2 rejection, preserved injected validator/I/O/argparse seams, and isolation checks have no independent finding. All 22 JSON-byte controls, Markdown-fence control, null zero-denominator and detached-output controls pass. Helper behavior/coverage evidence remains pending, so the dependent legacy subset is not independently ready to commit.

Exact findings, scope hashes and proof: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p5t1-executor-helper-legacy-review.2026-10-19T15-02.json
Counted reproduction: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p5t1-executor-model-probes.2026-10-19T14-59.json

This completes only the assigned incremental review. P5-T1 is unchecked; no AC or implementation files changed.

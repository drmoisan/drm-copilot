# P5-T1 frozen producer source review

Timestamp: 2026-10-20T03-47
Command: Read frozen P5-T1 producer sources; .venv/Scripts/python.exe SCRATCH/issue-980-p5t1-producer-probes.py
EXIT_CODE: 1
Output Summary: CHANGES_REQUIRED. Complete source-only findings PR1–PR4; no open behavioral probes.

The reviewed scope is `coverage_report.py` (359 lines, `f1da578149f69f9353e2f286d108a4ba6f5cefc255210c31f2fe7cb1d773fadc`) and `coverage_population.py` (272 lines, `1b716c64b0dea1a41bb49fa079932af138b37b136ec22ea19a2adcb004841f74`). The helper's accepted 114-case proof is retained; no suite was rerun.

- **PR1:** Removing only the ledger changes two known selected inventory components into zero reported total/inventoried/missing components while the population remains available. Retain known scope/inventory accounting, or mark unavailable populations explicitly; preserve the existing blocker.
- **PR2:** With 64 components and 1,024 roots, the accepted path predicate performs 66,560 comparisons against capacity 32,768; the producer reserves only 897 work units and returns. Bound selector-dependent work before traversal and test deterministic counts.
- **PR3:** The required runtime missing and verified measures are absent. Add explicit observed/verified/missing distinctions with named units; authored scenario results cannot manufacture verification.
- **PR4:** The two projection constructors and `coverage_summary` need explicit parameter types and meanings in their docstrings, as required by the commenting policy.

All probe artifacts are schema-valid and held entirely in memory. The exact source/probe/output payload is preserved separately from this readable summary. Accepted identity, evidence and scope semantics are reused. No production, tests, plan checkboxes or checkpoint were changed.

The moving validation composer and graph tests remain outside this review. Digest/nonrecursion and complete graph/caller gates remain pending for final composed acceptance. This source review is complete and can be reused for unchanged bytes.

Exact findings and bindings: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p5t1-executor-producer-source-review.2026-10-20T03-47.json

# P4-T9 shared/core candidate review

Timestamp: 2026-10-19T13-31
Command: poetry run python SCRATCH/issue-980-p4t9-shared-core-review.py
EXIT_CODE: 0
Output Summary: SHARED_CORE_REVIEW_REVISIONS_REQUIRED; three finite findings; no open behavioral probe.

P4T9-R1: Expand only the shared _Budget class contract required by the class-docstring policy. Its existing method contracts remain adequate.

P4T9-R2: The core numeric reservation allocates str(integer) before checking its byte cost. A counted, non-timing probe observed 1,001 rendered characters with a 10-byte ceiling before rejection. Check integer render capacity prospectively and preserve exact accepted boundaries.

P4T9-R3: Complete the exact core helper/test docstrings enumerated in the JSON receipt with required typed parameter, return, exception and effect contracts. Retain all behavior and assertions and the 500-line limit.

All nine current source/test streams are bound. Production is unchanged from review release; two separately authorized fixture repairs are explicitly qualified. The failed shared/core focused runs remain evidence, and their unfinished successors are not claimed as passing. Registry review is retained. No suite was replayed or source/test/checklist/checkpoint/Git state modified.

The emitter remains a minimal metadata seam; core merge preflight owns complete external-row text reservation. Validation and merge return data eligibility only, with publication still deferred. Counts remain 40/84 tasks and 13/66 AC.

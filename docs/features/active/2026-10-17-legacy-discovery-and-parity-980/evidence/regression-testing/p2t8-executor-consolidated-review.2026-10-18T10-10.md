# P2-T8 consolidated independent parity review

Timestamp: 2026-10-18T10:10:53Z

Command: `poetry run python SCRATCH/issue-980-probe-p2t8.py`

EXIT_CODE: 1

Output Summary: 48 of 51 cases passed with stable production hashes. All semantic cases use authoritative schema validation and unchanged immutable snapshots. The three remaining failures have zero prerequisite findings. Exact outcomes are retained in `p2t8-executor-consolidated-review.2026-10-18T10-10.json`.

The bounded review identifies four defects, with the first two already corrected in this captured run:

1. Approved retirement must still validate supplied classifications, their evidence and duplicate mode consistency. Both retirement regressions now pass.
2. Optional incomplete rows must not block required-only completion. The optional partial regression now passes; explicit full claims remain subject to truth checks.
3. A configured mobile dimension must use the declared target platform context. The configured portable platform is still incorrectly rejected by a literal `mobile` platform requirement.
4. A full row must not let a passing linked implementation conceal another linked failed or unverified implementation. Both mixed-state variants currently return no parity findings. Distinct passing implementation records may still divide the required verification coordinates.

The specialist received this consolidated result and owns corrections and production regressions. Accepted lower-level validators, schemas and the plan remain unchanged. No task checkoff is justified by this failing review.

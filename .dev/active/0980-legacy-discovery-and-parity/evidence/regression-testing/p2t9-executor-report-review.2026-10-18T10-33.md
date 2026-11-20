# P2-T9 derived-report incremental-output review

Timestamp: 2026-10-18 10:33:40 UTC

Command: `poetry run python SCRATCH/issue-980-p2t9-report-probe.py`

EXIT_CODE: 1

## Output Summary

One bounded production defect was reproduced against stable hashes. The baseline complete graph plus its generated completion report passes structural validation. Changing only the granted ledger member's responsible workflow, preserving every other input including the older report, makes the legacy analyst's exact output fail solely with `REPORT_RESULT` on that unchanged report.

The role is permitted to update the selected ledger member and cannot update reports. Requiring every previous derived view to match the newly changed inputs prevents valid incremental output. The mode composer should distinguish unchanged historical derived views from reports selected as current invocation outputs; selected reports must retain exact recomputation, and full snapshot/receipt hashes must remain sensitive to the changed bytes. This finding requests no prior-module change and does not grant an old report authority.

The result retains the four production hashes, zero baseline findings, unchanged-report proof and the sole failure. No source or schema was modified by the verifier. See [structured result](p2t9-executor-report-review.2026-10-18T10-33.json).

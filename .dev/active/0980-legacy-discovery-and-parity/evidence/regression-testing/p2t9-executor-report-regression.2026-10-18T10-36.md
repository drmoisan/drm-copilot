# P2-T9 historical-report regression

Timestamp: 2026-10-18 10:36:37 UTC

Command: `poetry run python SCRATCH/issue-980-p2t9-report-probe.py`

EXIT_CODE: 0

## Output Summary

The retained incremental-output case now passes against stable hashes for all four task modules. The complete baseline with its captured report has zero findings; the exact selected ledger-member update produces `output_valid=true`, `validation_result=pass`, zero findings, and leaves the prior report bytes unchanged. The correction applies only to an unchanged, unrequested report during agent-output validation. Explicit requested-report recomputation and full snapshot digest binding remain in the implementation and will be included in final task verification.

This closes the reproduced older-report defect on the recorded bytes. The full task's final ordered gates, hash binding and remaining bounded cases are still pending. See [structured result](p2t9-executor-report-regression.2026-10-18T10-36.json).

# P2-T9 final historical-report regression

Timestamp: 2026-10-18 10:50:27 UTC

Command: `poetry run python SCRATCH/issue-980-p2t9-report-probe.py`

EXIT_CODE: 0

## Output Summary

The retained incremental-output regression passes against the four frozen production hashes. The complete baseline containing its earlier report validates with zero findings. Updating the exact selected coverage-ledger member produces `output_valid=true`, `validation_result=pass`, and zero findings while preserving the earlier report bytes. Initial and final source hashes agree.

The complete structured command result, including its original capture timestamp and source hashes, is in [final result](p2t9-executor-report-final.2026-10-18T10-50.json). This is a bounded regression result; final task acceptance still requires the remaining probes and specialist quality evidence.

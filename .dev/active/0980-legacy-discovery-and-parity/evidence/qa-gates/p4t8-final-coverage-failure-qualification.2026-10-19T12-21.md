# P4-T8 stopped coverage assertion qualification

Timestamp: 2026-10-19T12-21
Command: `poetry run python SCRATCH/issue-980-p4t8-final-coverage-failure.py`
EXIT_CODE: 0
Output Summary: The final runner exited 1 after all 266 tests passed; this read-only reconciliation passed. Contracts and native checks did not run.

The original blanket callable assertion failed on two pre-existing CLI helpers. Their executable AST, three uncovered statements and baseline execution sets are unchanged. Every changed executable statement is covered. The original runner, raw coverage and six completed receipts are preserved. No frozen source/test/fixture/predecessor bytes changed.

The authorized correction is limited to exact unchanged helper ranges, preserving their no-loss baseline comparison and every new/changed-unit threshold. The full ordered sequence will restart after the harness correction is frozen. The outer tool-returned AssertionError was not separately captured as a raw process stream; the JSON labels its assertion reconstruction explicitly.

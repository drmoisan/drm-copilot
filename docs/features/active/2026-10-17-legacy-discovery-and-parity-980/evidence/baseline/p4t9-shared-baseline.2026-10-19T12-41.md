# P4-T9 shared baseline

Timestamp: 2026-10-19T12-41
Command: `poetry run python SCRATCH/issue-980-p4t9-shared-baseline.py`
EXIT_CODE: 0
Output Summary: BASELINE_READY at c64b35435d1c1597830d8dd03e661d7944192065; five existing paths and seven absent paths bound before mutation.

Current emitter and caller bytes exactly match accepted P4-T1 proof (50/50 statements, 14/14 branches). Current registry and affected tests exactly match accepted P4-T8 proof (23/23 statements, 8/8 branches). The existing package initializer has no executable statements. All affected callable coverage is retained through the bound reports. No test suite was rerun.

Original bytes are preserved in external SCRATCH with exact hashes. The baseline verifies 93 unrelated predecessor streams through the retained immutable candidate manifest. Fresh C4 native authority/profile matches; source, test, Git, checkpoint, plan and acceptance state were not changed. All new evidence is LF with one final newline; no raw diff or lossy normalization is introduced.

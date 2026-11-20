# P4-T9 core repair confirmation

Timestamp: 2026-10-19T13-52

Command: `poetry run python SCRATCH/issue-980-p4t9-core-repair-check.py`; `poetry run python SCRATCH/issue-980-p4t9-core-probe-capture.py`

EXIT_CODE: 0

Output Summary: CORE_R2_R3_CONFIRMED_READY_FOR_CHECKED_COMMIT_AND_FINAL_GATES. No remaining finding or open probe.

- R2: all three original counted cases pass with zero integer rendering; the valid 1,001-digit value reserves exactly 1,002 bytes. The retained 19 new owner cases cover signs, zero, powers, prior usage and a 5,001-digit allowed value without timing assertions.
- R3: all 50 listed contracts are complete; seven moved definitions preserve the original 125 cases and assertions, with only the approved profile-fixture correction. Five files remain below 500 lines.
- Reused focused proof: 144 cases after 20 prechecks; 336/336 statements, 148/148 branches, 30 measured ranges. No suite replay.
- Exact freeze: `5c39693cb1f753fbe36b3c7dd427b78497f5f6fac5119b991dab2c3ec04b7a5b`. Receipt: `p4t9-executor-core-repair-confirmation.2026-10-19T13-52.json`. Owner staging closure: `p4t9-core-stage-closure.2026-10-19T13-45.json`.
- The initial checker path-key failure and exact executed scripts/raw probe streams remain in `p4t9-executor-core-confirmation-executed-payloads.2026-10-19T13-52.json`. Its correction maps only Windows coverage separators; no implementation or test changed.
- P4-T9 final gates and acceptance remain pending. Counts stay 40/84 tasks and 13/66 AC. Publication and installed-host proof are not claimed.

# Final QC — Python Coverage Comparison

Timestamp: 2026-10-10T08-39
Task: [P8-T5] (Phase 8 loop pass 1)
Command: comparison of `evidence/baseline/python-pytest-coverage.2026-10-10T08-05.md` ([P0-T6]) and `evidence/qa-gates/python-pytest-coverage.2026-10-10T08-39.md` ([P8-T4]); no new command run
EXIT_CODE: 0

Output Summary:
- Baseline ([P0-T6]): line 96.45% (136/141), branch 95.00% (57/60).
- Post-change ([P8-T4]): line 96.45% (136/141), branch 95.00% (57/60).
- Line % post-change >= baseline: yes (equal). Branch % post-change >= baseline: yes (equal).
- Missing lines are identical before and after (`109, 216, 245-246, 254`); neither changed line is in the Missing column.

Changed lines in `scripts/dev_tools/skill_bundle_contract.py`:
- Line 52 (bash/sh/source invocation pattern, `[ \t]+` separator) and line 64 (`_PYTHON_PATH_PATTERN`, `python3?[ \t]+`) are module-level statements executed on import, so they are covered by every run above.
- Behaviour coverage of both changed lines: `evidence/regression-testing/pass-after-guard-fix.2026-10-10T08-21.md` ([P2-T3]), result `9 passed` (six shell-fence cases and the split-line case exercise line 52; the python-fence case exercises line 64; the parallel-plan case exercises line 52 against the real skill file).

Verdict: PASS (no coverage regression; [P2-T3] citation present).

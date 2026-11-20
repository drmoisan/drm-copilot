# Phase 0 — Policy Compliance Read Evidence

Timestamp: 2026-08-08T20-59

Task: [P0-T1]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8

Policy Order: `CLAUDE.md` -> `.claude/rules/general-code-change.md` -> `.claude/rules/general-unit-test.md` -> `.claude/rules/python.md` -> `.claude/rules/python-suppressions.md` -> `.claude/rules/powershell.md`

## Files Read (in the stated order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`

All six files listed in [P0-T1] were read in the stated order before any Phase 0
baseline command was executed. No policy file was modified.

## Additional Standing Rules Loaded

The following path-scoped rule files were also present in the loaded standing-instruction
context and inform this feature's work surface. They are recorded for completeness and are
not a substitute for the six required reads above.

- `.claude/rules/parallel-orchestration.md` (F3-owned parallel artifact invariants and the
  wave-4 enum-consumption constraint that governs this feature)
- `.claude/rules/orchestrator-state.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/tonality.md`
- `.claude/rules/ci-workflows.md`
- `.claude/rules/benchmark-baselines.md`

## Policy Constraints Recorded for This Feature

- Python toolchain order: `black` -> `ruff` -> `pyright` -> `pytest --cov --cov-branch`;
  restart from step 1 on any failure or file change.
- PowerShell toolchain order: PoshQC format -> PoshQC analyze -> PoshQC test (Pester v5);
  type checking not applicable.
- Coverage thresholds are uniform across tiers T1-T4: line >= 85%, branch >= 75%.
- No production file may be excluded from coverage measurement.
- File size limit: 500 lines for production, test, and reusable script files.
- Tests must not create or use temporary files.
- Suppressions require a pre-authorized pattern or explicit user approval.

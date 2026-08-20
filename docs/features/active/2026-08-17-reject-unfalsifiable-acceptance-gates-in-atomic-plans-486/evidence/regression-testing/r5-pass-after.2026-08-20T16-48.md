# R5 Pass-After — Guarded Tracked-Tree Seam Degrades Silently ([P2-T2])

Timestamp: 2026-08-20T16-48

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

Output Summary:

- `1 passed in 0.08s`; zero failed.
- The same command and the same test that failed with `RuntimeError` before the fix
  (`evidence/regression-testing/r5-fail-before.2026-08-20T16-44.md`, EXIT_CODE 1) now passes. The
  test asserts `report.blocking == []` and `report.warnings == []` for a raising tracked-tree seam
  with a path-separator `--cov` value, so both channels are empty and no exception escapes
  `evaluate_plan_gates`.
- Change under test: `scripts/dev_tools/plan_gate_discrimination.py` now extracts the G2/G3
  tracked-tree block into `_evaluate_tracked_cov_value` and invokes it from `_evaluate_cov_value`
  inside a `try` / `except Exception: return` guard carrying the same contract comment as
  `_evaluate_literal_rules`. No finding string, severity constant, or cascade order changed.
- The fail-before/pass-after pair for finding R5 is therefore complete: exit 1 before, exit 0 after,
  same command, same test node id.

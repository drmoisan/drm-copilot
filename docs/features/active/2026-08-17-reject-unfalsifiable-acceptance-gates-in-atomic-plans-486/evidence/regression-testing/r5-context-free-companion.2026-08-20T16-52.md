# R5 Companion Test — Context-Free Rules Still Report Under Degradation ([P2-T3])

Timestamp: 2026-08-20T16-52

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_raising_adapter_reports_only_context_free_findings -q`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

Output Summary:

- `1 passed in 0.07s`; zero failed.
- Fixture: the same raising stub adapter used by the fail-before test, plus a two-task plan. Task
  `P3-T4` carries a coverage value that is a filesystem path ending in the Python suffix (a
  context-free G1 Blocking finding). Task `P3-T5` carries a coverage value of
  `scripts/dev_tools/missing` supplied space-separated (a context-free G4 Warning finding, plus a
  tracked-tree lookup that raises and therefore degrades).
- Assertions confirmed: exactly one Blocking finding, prefixed `[P3-T4] ` and containing
  `names a filesystem path`; exactly one Warning finding, prefixed `[P3-T5] ` and containing
  `space-separated`. No G3 Warning is emitted for the raising lookup, and no exception escapes.
- Together with `test_failing_git_adapter_skips_g2_g3_without_raising` (coverage path) and the
  pre-existing `test_failing_git_adapter_produces_no_findings` (literal path), the degradation suite
  now covers both rule groups explicitly.

# R5 Fail-Before — Raising Tracked-Tree Seam Escapes `evaluate_plan_gates` ([P1-T2], `[expect-fail]`)

Timestamp: 2026-08-20T16-44

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 1

Expected outcome: FAILURE. This run precedes the [P2-T1] guard. The failure is the proof that the
new test discriminates: it exercises the unguarded G2/G3 coverage path, which no existing test
reaches. A passing run here would have invalidated the test and required rework of [P1-T1].

Output Summary:

- `1 failed in 0.10s`; zero passed.
- The failure is not an assertion failure. `RuntimeError` raised by the stub seam propagated out of
  `evaluate_plan_gates`, exactly as finding R5 describes. Verbatim propagation chain from the run:

```
    def test_failing_git_adapter_skips_g2_g3_without_raising() -> None:
...
>       report = evaluate_plan_gates(text, context=_context(git))

tests\scripts\dev_tools\test_plan_gate_discrimination_context.py:283:
scripts\dev_tools\plan_gate_discrimination.py:479: in evaluate_plan_gates
    _evaluate_cov_value(
scripts\dev_tools\plan_gate_discrimination.py:284: in _evaluate_cov_value
    if context.git.is_tracked_file(truncated + PYTHON_SUFFIX):

path = 'scripts/dev_tools/missing.py'

>       raise RuntimeError("git is unavailable")
E       RuntimeError: git is unavailable

tests\scripts\dev_tools\test_plan_gate_discrimination_context.py:267: RuntimeError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising
1 failed in 0.10s
```

- The escape point is `scripts/dev_tools/plan_gate_discrimination.py:284`, the unguarded
  `context.git.is_tracked_file` call inside `_evaluate_cov_value`, reached because the plan text
  carries the path-separator coverage value `scripts/dev_tools/missing` in the `=` form.
- This violates `.claude/rules/plan-acceptance-gates.md` § Graceful degradation and spec AC10, and
  diverges from the TypeScript runtime, which already wraps the equivalent lookups in try/catch.
- Pass-after evidence for the same command is recorded at
  `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/regression-testing/r5-pass-after.<ts>.md` ([P2-T2]).

# Parity-Guard Discrimination Demonstration — Mutation Reverted (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P2-T3]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

The single temporary line appended by [P2-T2] was deleted from
`scripts/dev_tools/plan_gate_coverage.py` immediately after that task's evidence was recorded. Two
commands verify the revert.

## Command 1 — the assertion passes again

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py::test_no_repr_formatting_in_gate_messages -q`

EXIT_CODE: 0

Raw output:

```
.                                                                        [100%]
1 passed in 0.07s
```

## Command 2 — the token is gone (zero-match grep, expected non-zero exit)

Command: `grep -c -F "repr(" scripts/dev_tools/plan_gate_coverage.py`

EXIT_CODE: 1

Raw output:

```
0
```

`grep -c` exits 1 when it reports 0 matches; the non-zero exit is the expected and stated outcome
for this command, not a failure.

## Supplementary confirmation

`grep -c -F "TEMPORARY" scripts/dev_tools/plan_gate_coverage.py` also reports `0` with exit code 1,
and `wc -l scripts/dev_tools/plan_gate_coverage.py` reports 243 lines, matching the file's state
before the mutation was appended.

Output Summary: The [P2-T2] mutation is fully reverted — no `repr(` token and no residual marker
remains in `scripts/dev_tools/plan_gate_coverage.py` — and the generalized
`test_no_repr_formatting_in_gate_messages` assertion passes again. Taken with the recorded
[P2-T2] failure, the pair demonstrates that the assertion discriminates: it fails when the
prohibited token is present in the newly extracted module and passes when it is not.

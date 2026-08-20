# Validator Behavior Unchanged Across the Split — Original Approved Plan (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P3-T5]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

Command: `PYTHONPATH=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md --workspace-root .`

EXIT_CODE: 0

Raw output (two stderr warning lines, then the stdout success summary):

```
PLAN GATE WARNING: [P2-T2] --cov argument value `tests/foo` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.
PLAN GATE WARNING: [P2-T2] --cov argument `tests/foo` contains a path separator but resolves to neither a tracked file nor a tracked directory; coverage may collect no data. Use the importable dotted form or a tracked directory.
plan validation passed: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md
```

## Byte-identity check against the pre-split recording

The same two warning strings were recorded before this cycle's split at
`docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/self-gate-run.2026-08-20T13-42.md`
lines 15 and 16. Both lines match the output above character for character, including the backtick
delimiters around `tests/foo`, the `--cov=<module>` remedy text, and the punctuation. The G4 warning
is produced by `evaluate_cov_value` and the G3 warning by `_evaluate_tracked_cov_value`, both of
which now live in `scripts/dev_tools/plan_gate_coverage.py` — so this comparison exercises exactly
the finding strings the extraction moved.

Output Summary: EXIT_CODE 0 with zero blocking findings and exactly the same two self-referential
`PLAN GATE WARNING: ` lines the pre-split validator emitted, byte-identical in message text, plus
the unchanged stdout success summary. The module split is behavior-preserving at the CLI boundary,
including warning ordering (G4 before G3, both attributed to `[P2-T2]`) and channel routing (both on
the Warning channel, neither affecting the exit code).

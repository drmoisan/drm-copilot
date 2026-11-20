# Cross-Runtime Parity for the R5 Input Class ([P3-T1])

Timestamp: 2026-08-20T16-57

Input class under test: a raising repository seam combined with a path-separator `--cov` value
supplied in the `=` form (`scripts/dev_tools/missing`). Both runtimes must produce zero Blocking and
zero Warning findings and must not propagate the exception out of the evaluation entry point.

## Command 1 — TypeScript runtime (pre-existing test)

Command: `node run-jest.cjs test/lib/validate/plan-gate-discrimination-literals.test.ts -t "skips the tracked-tree cov rules when the adapter throws"`

Working directory: `extensions/drm-copilot`

EXIT_CODE: 0

```
Test Suites: 1 passed, 1 total
Tests:       12 skipped, 1 passed, 13 total
```

The 12 skips are the other tests in the same file, excluded by the `-t` name filter; the targeted
test passed. The test asserts `expect(report.blocking).toEqual([])` and
`expect(report.warnings).toEqual([])` for a `ThrowingTrackedRepository` whose `isTrackedFile`
throws.

## Command 2 — Python runtime (test added this cycle)

Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_discrimination_context.py::test_failing_git_adapter_skips_g2_g3_without_raising -q`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

```
.                                                                        [100%]
1 passed in 0.06s
```

The test asserts `report.blocking == []` and `report.warnings == []` for a `_RaisingGitRepository`
whose `is_tracked_file` and `is_tracked_directory` raise `RuntimeError`.

## Command 3 — TypeScript production diff is empty

Command: `git diff --name-only extensions/drm-copilot/src`

Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

Output: empty (no file names printed).

## Output Summary

- Both tests pass. Both assert empty Blocking and empty Warning channels for the same raising-seam
  path-separator coverage input, so the two runtimes agree on graceful degradation for this input
  class. The divergence recorded as finding R5 is closed.
- The TypeScript production diff is empty: no file under `extensions/drm-copilot/src` was modified
  this cycle, consistent with the plan's constraint that the TypeScript runtime already implements
  the required guard and must not be touched.
- Fixture equivalence note: the TypeScript stub throws from `isTrackedFile` only, while the Python
  stub raises from both `is_tracked_file` and `is_tracked_directory`. The Python fixture is the
  stricter of the two, because it would also expose an unguarded directory lookup; both fixtures
  drive the same evaluated path for this input, since the first lookup raises in each runtime.

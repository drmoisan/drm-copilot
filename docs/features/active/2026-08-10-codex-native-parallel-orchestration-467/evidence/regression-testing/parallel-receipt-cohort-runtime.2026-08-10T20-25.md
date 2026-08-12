# P3-T7 Receipt-Bound Cohort Runtime Evidence

## Scope

- Task: `[P3-T7]`
- Python composition owner: `validate_parallel_orchestrator_state.py`
- TypeScript/MCP composition owner: `parallel-orchestrator-state-core.ts`
- Shared corpus: `tests/fixtures/parallel-orchestration/drift-parity.json`
- The existing 496-line TypeScript drift module and 500-line structures test were not modified.

## Acceptance Results

- A started conflicting later cohort is rejected until its predecessor records
  `worktree_removed` and binds both merge and worktree-removal receipt paths.
- A started later item must bind both launch-receipt and launch-status paths.
- Unresolved drift produces the normalized admission/completion quiescence error.
- Persisted recoloring rejects running-item movement, a missing later-started halt requeue,
  stale unstarted-only assignments, and non-ascending requeue order.
- Validation is deterministic and does not mutate the supplied checkpoint.
- The shared corpus contains six required behaviors, six unique reason codes, and zero
  `currently_divergent` cases. Python and TypeScript/MCP produce the same accept/reject
  decision for all six cases. All four rejected cases begin with the identical normalized
  error `Parallel checkpoint unresolved drift for items [444] blocks admission and completion.`

## Python Toolchain

- `poetry run black --check` over the focused helper, public validator, and focused/parity
  tests: PASS.
- `poetry run ruff check` over the same scope: PASS.
- `poetry run pyright` over the same scope: PASS, 0 errors and 0 warnings.
- Focused receipt-bound helper suite: PASS, 9/9.
- Shared Python drift-parity suite: PASS, 14/14.
- Combined focused receipt/parity run: PASS, 23/23.
- Public validator, cohort, drift, mutation, completion, and parity regression selection:
  PASS, 350/350.

## TypeScript Toolchain

- `npx prettier --check` over the focused helper, core, focused/parity tests, and shared
  fixture: PASS.
- `npx eslint` over the changed TypeScript scope: PASS.
- `npx tsc -p ./ --noEmit`: PASS.
- Focused receipt-bound helper suite: PASS, 9/9.
- Shared TypeScript drift-parity suite: PASS, 12/12.
- Combined focused receipt/parity run: PASS, 21/21.
- Core, completion, structures, cohort, drift parity, dispatch, and receipt regression
  selection: PASS, 8 suites and 266/266 tests.

## File-Size and Repository Gates

- Python helper: 318 lines.
- Python public validator: 360 lines.
- Python focused test: 286 lines.
- Python parity test: 372 lines.
- TypeScript helper: 279 lines.
- TypeScript core: 342 lines.
- TypeScript focused test: 224 lines.
- TypeScript parity test: 366 lines.
- Existing TypeScript drift module: 496 lines; unchanged.
- Existing TypeScript structures test: 500 lines; unchanged.
- `.claude/` changed-file count: 0.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

No issue, specification, or user-story checkbox is changed by this task alone. The related
criteria also require the later hook, portable-runtime, and end-to-end enforcement tasks;
checking them at P3-T7 would overstate delivered scope.

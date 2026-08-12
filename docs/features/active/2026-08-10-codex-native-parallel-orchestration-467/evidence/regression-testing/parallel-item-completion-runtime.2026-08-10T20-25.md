# P3-T9 Per-Item Completion Runtime Evidence

## Scope

- Task: `[P3-T9]`.
- PowerShell runtime: `.codex/scripts/parallel-child-post-session.ps1`.
- Python receipt authority: `_parallel_orchestrator_state_completion_receipts.py`,
  composed into `validate_parallel_orchestrator_state.py` only for explicit completion.
- TypeScript receipt authority:
  `parallel-orchestrator-state-completion-receipts.ts`, composed into
  `parallel-orchestrator-state-core.ts` only for explicit completion.
- Receipt validation is additive and presence-gated, preserving legacy completed checkpoints
  without per-item receipt fields.

## Acceptance Results

- The post-session runtime requires exactly one PR whose base is `main), whose head branch is
  the item branch, and whose head SHA is the checked live worktree HEAD.
- Required checks are queried for that PR and must all report the passing bucket before merge.
- The final PR view must report `MERGED`, retain the same head SHA and main base, and expose a
  merge commit before the matching item worktree can be removed.
- Worktree removal uses the exact bound item path and a second live worktree-list query rejects
  residual worktrees before any completion receipt or checkpoint is persisted.
- The versioned receipt and item checkpoint fields persist PR, exact-head check, merge, and
  worktree-removal identity without integration-branch or fan-in fields.
- Zero or multiple PRs, stale PR/check heads, non-green checks, an unmerged final PR,
  non-main/integration/fan-in state, a mismatched worktree, and a residual worktree all reject.
- Python and TypeScript terminal validators reject duplicate PR ownership, incomplete or
  mismatched PR/check/merge/removal records, non-relative receipt paths, and residual worktree
  status in deterministic order without mutating input.

## PowerShell Toolchain

- Bundled PoshQC format over `.codex/scripts` and `tests/scripts/codex-hooks`: PASS.
- Bundled PoshQC analyze over the same scope: PASS, zero findings.
- Focused `parallel-child-post-session.Tests.ps1`: PASS, 7/7 tests.
- The first authoritative wrapper run identified only the expected purity assertion because the
  completed Python and PowerShell batch-budget receipts remained under `.codex/state`.
- After deleting only those verified ephemeral receipts and the resulting empty directory, the
  identical authoritative `run_poshqc_test` command passed: 511/511 tests, zero failures,
  errors, or skips.

## Python Toolchain

- `poetry run black --check` over the helper, public validator, and focused test: PASS.
- `poetry run ruff check` over the same scope: PASS.
- `poetry run pyright` over the same scope: PASS, 0 errors and 0 warnings.
- Focused receipt plus existing completion/core regressions: PASS, 157/157 tests.
- Full parallel validator selection:
  `poetry run pytest tests/scripts/dev_tools -k "parallel" -q`: PASS,
  1,428 passed, 5 documented fixture skips, and 2,381 deselected.

## TypeScript Toolchain

- `npx prettier --check` over the helper, public core, and focused test: PASS.
- `npx eslint` over the same scope: PASS.
- `npx tsc --noEmit`: PASS.
- Focused receipt, core, completion, and artifact-dispatch selection: PASS,
  4/4 suites and 141/141 tests.
- Full `npx jest --runInBand`: PASS, 190/190 suites and 2,635/2,635 tests.

## Cross-Runtime Parity

- A read-only runtime comparator supplied identical in-memory states to the Python helper and the
  transpiled TypeScript helper.
- All 19 normalized scenarios produced byte-identical ordered error arrays.
- The matrix covered legacy and valid states, duplicate PR ownership, all PR/head/check/state
  mismatches, missing merge/removal fields, residual worktree state, invalid path forms, and the
  ordered multi-error case.
- Both runtime inputs remained unchanged.

## File-Size and Repository Gates

- PowerShell runtime: 375 lines.
- PowerShell focused test: 279 lines.
- Python receipt helper: 220 lines.
- Python public validator: 364 lines.
- Python focused test: 240 lines.
- TypeScript receipt helper: 258 lines.
- TypeScript public core: 344 lines.
- TypeScript focused test: 219 lines.
- Every touched production, test, and reusable file is at or below 500 lines.
- `.claude/` changed-file count: 0.
- `.codex/state` is absent after the verified ephemeral-receipt cleanup.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

- Checked the matching per-item main PR, exact-head checks, merge, and worktree-removal criterion
  in `issue.md`.
- Checked the matching criterion in `user-story.md`.
- The broader specification integration-test criterion and final live GitHub current-head
  criterion remain unchecked until their later plan tasks complete.

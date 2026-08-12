# P3-T8 Receipt-Bound Mutation Runtime Evidence

## Scope

- Task: `[P3-T8]`
- Python decision authority: `parallel_mutation_protocol.py`, unchanged at 499 lines.
- Python composition: `_parallel_orchestrator_state_mutation_receipts.py` through
  `_parallel_orchestrator_state_mutations.py`.
- TypeScript composition: `parallel-orchestrator-state-mutation-receipts.ts` through
  `parallel-orchestrator-state-mutations.ts`.
- `parallel-state-records.ts` remains the unchanged owner of the exact seven-field
  `mutations[]` record. The optional `mutation_receipts[]` collection is additive and
  presence-gated, so no duplicate record schema was added.

## Acceptance Results

- In-flight detach and abandon preserve the current recolor generation.
- Removal from prior state `merged` is rejected.
- Receipt-mode detach and abandon require one exact binding over mutation index,
  operation, item key, worktree identity, repository-relative receipt path, and
  confirmation token.
- Missing or mismatched operation, item key, worktree identity, or token rejects.
- Mutation records retain the exact complete seven-field shape and non-decreasing
  generation order.
- Explicit completion rejects open mode without a close record.
- Close with any in-flight item rejects atomically without changing the input.
- Legacy checkpoints without `mutation_receipts[]` remain compatible.

## Python Toolchain

- `poetry run black` / restarted formatting check over the focused helper,
  composition owner, and focused/public tests: PASS; all files unchanged in the clean pass.
- `poetry run ruff check` over the same scope: PASS.
- `poetry run pyright` over the same scope: PASS, 0 errors and 0 warnings.
- Focused receipt-bound runtime suite: PASS, 14/14.
- Focused receipt, public mutation/mode, and shared parity selection: PASS, 75/75.
- Shared mutation fixture parity: PASS, 18/18 over 16 committed cases and two corpus guards.
- Full parallel mutation selection: PASS, 434/434; 3,363 deselected.

## TypeScript Toolchain

- `npx prettier --check` over the focused helper, composition owner, and focused test:
  PASS.
- `npx eslint` over the same scope: PASS.
- `npx tsc --noEmit`: PASS.
- Focused receipt-bound helper and public-composition suite: PASS, 15/15.
- Shared mutation fixture parity: PASS, 24/24 over the same 16 committed cases.
- Focused helper, shared parity, core public validator, and artifact-dispatch selection:
  PASS, 4 suites and 151/151 tests.

## File-Size and Repository Gates

- Python mutation authority: 499 lines, unchanged.
- Python receipt helper: 295 lines.
- Python mutation composition owner: 317 lines.
- Python focused receipt test: 262 lines.
- Python public mutation tests: 401 and 183 lines.
- TypeScript receipt helper: 207 lines.
- TypeScript mutation composition owner: 372 lines.
- TypeScript record owner: 354 lines, unchanged.
- TypeScript focused receipt test: 203 lines.
- Every touched production, test, and reusable file is at or below 500 lines.
- `.claude/` changed-file count: 0.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

- Checked the matching mutation acceptance criterion in `issue.md`.
- Checked the matching mutation acceptance criterion in `user-story.md`.
- The broader specification criterion that also includes later integration and portable-runtime
  proof remains unchecked until those later plan tasks complete.

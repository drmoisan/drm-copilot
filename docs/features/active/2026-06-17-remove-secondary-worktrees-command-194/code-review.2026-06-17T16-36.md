# Code Review: remove-secondary-worktrees-command (Issue #194)

**Review Date:** 2026-06-17
**Review Type:** Re-review after remediation (prior review: `code-review.2026-06-17T16-23.md`)
**Baseline:** `main` @ `ce0f3613526f64756363961661902814d88c28a7` (merge-base)
**Head:** `feature/remove-worktrees` @ `63546a9c539cbbd0fd928c972f37df376e0891ae`
**Scope:** Full branch diff vs merge-base. TypeScript-only production change (plus package.json contribution, README, feature docs/evidence).

---

## Executive Summary

This change adds the `drmCopilotExtension.removeSecondaryWorktrees` command to the drm-copilot VS Code extension. The design follows the extension's established three-layer separation:

- `remove-worktrees.ts` — pure, host-neutral logic (porcelain parsing, secondary selection, skip classification, summary message). No `vscode` or `node:*` imports.
- `remove-worktrees-runner.ts` — the git I/O seam (`createGitRunner` over `node:child_process.spawn`) and the `removeAllSecondaryWorktrees` orchestration. The `GitRunner.run` contract resolves (does not reject) on non-zero exit so a non-removable worktree is recorded as skipped rather than aborting the batch.
- `extension.ts` — VS Code wiring: modal confirmation, output-channel logging, and result notifications.

The safety-critical requirements are met in code: the primary worktree is excluded by position (first porcelain block), removal uses NON-force `git worktree remove <path>` with `--force` never passed, and a failed removal is recorded as skipped while the batch continues. Locked and prunable worktrees are skipped with reasons before any removal is attempted.

This is a re-review following remediation of the only prior finding: the test file `remove-worktrees.test.ts` was 612 lines, exceeding the 500-line file-size limit. It has been split into `remove-worktrees.test.ts` (336 lines, pure-function tests) and `remove-worktrees-runner.test.ts` (278 lines, orchestration and I/O-seam tests). The split preserves all 388 tests, which pass. The file-size finding is resolved.

The full toolchain (Prettier, ESLint, TSC, Jest with coverage) passes in a single pass. No blocking or major findings were identified in this pass. The change is ready for merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Resolved | extensions/drm-copilot/test/remove-worktrees.test.ts | whole file | Prior review's only finding (test file 612 lines, exceeding the 500-line limit) is remediated. File is now 336 lines; orchestration/I/O-seam tests moved to a new `remove-worktrees-runner.test.ts` (278 lines). | No action; confirm the split kept all tests (it did — 388 pass). | `general-code-change.md` 500-line limit now satisfied for all changed files. | `wc -l`: remove-worktrees.test.ts 336, remove-worktrees-runner.test.ts 278; Jest: 34 suites / 388 tests pass. |
| Info | extensions/drm-copilot/test | package toolchain | The package uses Jest, while `typescript.md` names Vitest as the repository TypeScript framework. | None required for this feature; framework migration is a separate, package-wide concern. | Jest is the pre-existing, internally consistent framework for this package; not a regression introduced here. | `run-jest.cjs`, `@jest/globals` imports; predates this branch. |
| Info | extensions/drm-copilot | package architecture tooling | `dependency-cruiser` is not configured for this package, so the pure/host-bound boundary is not machine-enforced. | Consider wiring `.dependency-cruiser.cjs` for the extension package in a follow-up to enforce the No-COM/layer boundary automatically. | `architecture-boundaries.md` names dependency-cruiser as the TS enforcement tool; absence means the boundary is verified only by inspection here. | No `.dependency-cruiser.cjs` in `extensions/drm-copilot/`; boundary verified by reading `remove-worktrees.ts` (no host imports). |
| Info | extensions/drm-copilot/src/remove-worktrees.ts | lines 103-105 | The malformed-block guard (`worktreePath === undefined → continue`) is not covered by a test. | Optional: add a porcelain block lacking a `worktree` line to cover the guard. | Coverage is already 98.42% line / 90.32% branch on this module, well above thresholds; the guard is defensive. | `coverage/lcov.info`; uncovered lines 103-105 per Jest summary. |

---

## Detailed Observations

### Correctness and safety

- **Primary never removed.** `parseWorktreePorcelain` marks only the first block `isPrimary: true`; `selectSecondaryWorktrees` filters on `isPrimary === false`. The primary is excluded by position, which matches git's porcelain contract that the main worktree is reported first. A dedicated test asserts the primary path is never passed to a remove call.
- **NON-force semantics.** `removeAllSecondaryWorktrees` issues `["worktree", "remove", entry.path]` with no `--force`. A non-zero remove exit is captured and recorded as skipped with the stderr reason; the loop continues. This satisfies the "left intact, not partially deleted" requirement, given git's NON-force `worktree remove` does not partially delete.
- **Resolve-on-nonzero seam.** `createGitRunner` resolves on any close code and rejects only on the child `error` event (spawn failure). The JSDoc documents why `runCommandWithOutput` from `command-runtime` is intentionally not reused (it rejects on non-zero, which would abort the batch). This is a deliberate, well-justified design choice.
- **List failure is fatal by design.** A non-zero `git worktree list --porcelain` throws with the trimmed stderr. This is correct: if enumeration fails, the operation has no reliable input and should not proceed.
- **Skip precedence.** `classifyWorktreeForRemoval` evaluates locked before prunable, with a test asserting locked-before-prunable precedence. Reasons are user-readable and include the git-provided detail when present.

### Typing and style

- No `any`, no `as` assertions in production modules; `error: unknown` is narrowed via `instanceof Error`. Interfaces are `readonly` where appropriate. `WorktreeRemovalClassification` is a clean discriminated union on `skip`.
- ES module syntax throughout; `node:child_process` is the only added import and is already used by the package.
- No suppressions (`eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`) in changed files.

### Tests

- The split is clean: pure-function units in `remove-worktrees.test.ts`; orchestration and the `createGitRunner` I/O seam in `remove-worktrees-runner.test.ts`. Tests use an in-memory `FakeGitRunner` and a mocked `node:child_process`; no temporary files, no network, no wall-clock. Lifecycle hooks reset mocks between tests.
- Scenario coverage spans positive, negative, edge (CRLF separators, trailing blank block, locked/prunable with and without reason, no-secondary case), and error-handling (list failure, spawn error) paths.

### Documentation

- `README.md` adds a "Remove Secondary Worktrees" section that accurately documents the modal confirmation, NON-force behavior, skip-on-failure continuation, locked/prunable skipping, and the absence of automatic `git worktree prune`. The documentation matches the implemented behavior.

---

## Verdict

**Approve for merge.** No blocking or major findings. The prior file-size finding is remediated and verified. Remaining items are Info-level and do not block this feature.

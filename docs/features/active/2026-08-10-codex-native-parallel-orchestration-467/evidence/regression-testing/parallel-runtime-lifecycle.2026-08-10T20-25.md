# P3-T11 Parallel Runtime Lifecycle Test Evidence

## Scope

- Task: `[P3-T11]`.
- PowerShell owners: `parallel-runtime-lifecycle.Tests.ps1`,
  `parallel-child-worktree-launcher.Tests.ps1`,
  `parallel-child-resume-live-truth.Tests.ps1`, and
  `parallel-child-post-session.Tests.ps1`.
- Python owners: `test_parallel_mutation_parity.py` and
  `test_parallel_drift_parity.py`.
- TypeScript owners: `parallel-mutation-parity.test.ts` and
  `parallel-drift-parity.test.ts`.
- Shared corpora: `mutation-parity.json` and `drift-parity.json`.

## Acceptance-to-Test Mapping

- Max concurrency 1 and greater than 1, ascending launch order, and no
  thread-capacity reordering: PowerShell lifecycle test `fills one and multiple
  launch slots without reordering persisted items` and launcher tests `orders a
  bounded cohort batch by item key without thread-capacity reordering` and
  `invokes the shared bounded scheduler in persisted item order`.
- Wrong profile, model, branch, and worktree: PowerShell launcher test `rejects
  wrong profile, model, branch, or worktree identity`.
- Wrong repository and corrupt status: PowerShell resume test `rejects every
  mismatched authority with a stable reason code`; cached status non-authority
  is separately verified by `does not treat cached child status as authority
  over live process truth`.
- Interrupted resume: PowerShell lifecycle test `retains the tested per-item
  post-session and interrupted-resume public seams` plus the actual resume
  context test `binds live truth through the actual resume context before
  scheduling`.
- Later-cohort rejection and no integration or fan-in state: PowerShell
  lifecycle test `rejects later-cohort, wrong identity, and integration or
  fan-in launch state`, launcher test `rejects integration and fan-in state on
  every parallel launch`, and resume/post-session contamination tests.
- Merged-versus-green distinction: PowerShell lifecycle test `does not treat
  green CI as merged lifecycle completion`.
- Matching worktree removal: PowerShell post-session test `uses the exact
  main/head PR query, required checks, merge, and matching worktree removal`.
- Drift halt/requeue: the six-case shared drift corpus is executed by Python and
  TypeScript lifecycle mappings for quiescence, later-started halt, unstarted
  recolor, ascending requeue, and persisted resolution.
- All mutation modes: the sixteen-case shared mutation corpus is executed by
  Python and TypeScript lifecycle mappings for add, remove, close, detach, and
  abandon, including exact confirmation binding.

## PowerShell Toolchain

- PoshQC format: PASS.
- PoshQC analyze: PASS.
- Focused lifecycle, launcher, live-resume, and post-session Pester run: PASS,
  25/25 tests with zero failures and zero skips.
- P3-T11 changed no production PowerShell file.

## Python Toolchain

- Black: PASS.
- Ruff: PASS.
- Pyright: PASS, zero errors and zero warnings.
- Focused mutation and drift parity run: PASS, 34/34 tests.
- The committed mutation corpus contains 16 scenarios and five mapped lifecycle
  modes. The committed drift corpus contains six scenarios and five mapped
  lifecycle requirements.
- P3-T11 changed no production Python file.

## TypeScript Toolchain

- Prettier: PASS after the required clean restart.
- ESLint: PASS.
- `tsc --noEmit`: PASS.
- Focused mutation and drift parity run: PASS, 2/2 suites and 38/38 tests.
- P3-T11 changed no production TypeScript file.

## File-Size and Repository Gates

- PowerShell test lines: lifecycle 188, launcher 300, live resume 279, and
  post-session 279.
- Python test lines: mutation parity 335 and drift parity 395.
- TypeScript test lines: mutation parity 281 and drift parity 406.
- Every reusable P3-T11 test owner is at or below 500 lines; the JSON corpus
  files are raw fixtures and therefore exempt from the reusable-file limit.
- `.claude/` changed-file count: 0; `.claude/` diff line count: 0.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

- The exact P3-T11 lifecycle acceptance matrix is covered by executable test
  owners above.
- Broader registered-hook, portable-runtime, publisher, coverage, and final QA
  criteria remain assigned to later plan tasks.

# Preflight Fixes (round 2)

Timestamp: 2026-10-30T22-46
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T17-11.md

All fixes are task-text or preamble edits only. No task was added, removed, or reordered.

## Fix 1 — D-P5 (validator-blind: changed behavior versus existing test fakes)

- Defect: the resolver is newly invoked through injected `FileSystem` seams, but the plan did not state its probe order. The `InMemoryFileSystem` fakes in `extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts` and `new-potential-bug-entry-service-call.test.ts`, and the fake in `test/lib/validate/evidence-locations.test.ts`, throw `not used` from `exists` and `isDirectory`. The fake in `test/repo-automation-dispatch.test.ts` (`collectPrContext runs in-process using the injected runner and filesystem`) returns an empty string from `readTextFile` for any path, so a read-only probe would yield R-3 there. The tasks state these suites are unchanged.
- Change: D-P5 states the probe order (`exists` on the routing file first, false gives R-1 without a read; `isDirectory` only for `.dev`), which keeps the dispatch fake on R-1, and states that fakes throwing from `exists` or `isDirectory` answer from their own file map with case assertions unchanged. No acceptance condition changes.

## Fix 2 — [P4-T1] test disposition

- Change: the disposition names the two `InMemoryFileSystem` fakes that gain map-backed `exists` and `isDirectory` per D-P5. Both files are already in the task's test set; the existing case assertions are unchanged.

## Fix 3 — [P4-T2] acceptance wording

- Defect: the acceptance read "both pass" while the task names three existing suites and one new suite.
- Change: the acceptance reads "the three existing suites and the new suite pass". The asserted outcome is unchanged.

## Fix 4 — [P6-T13] corpus count literal

- Defect: the task stated the parity suites discover "49 files". The corpus holds 48 files on the branch today, and the parallel run that must merge before P0-T1 may add fixtures, so the literal can be wrong at execution time. The suites assert `MINIMUM_CORPUS_COUNT` (48) as a floor and on-disk equality, not 49.
- Change: the text reads "one file more than before this task, above the `MINIMUM_CORPUS_COUNT` of 48". The assertion is unchanged.

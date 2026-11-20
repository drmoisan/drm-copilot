# Feature Audit: Stage R, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `ce7c77f0207c8df4f9c7bc045f9a5f3c27106bfe`
- **Audit date:** 2026-11-07
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main` (supplied by the caller and confirmed by `artifacts/pr_context.summary.txt`, resolved `origin/main` @ `c24cbd295ecec1fc759f52a42806ad991aa49478`).
- Merge base: `81b6a1be385666e5025936a85e487e43e7ac6187`, the merge commit of PR #1110 (stages E and E2). `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `81b6a1be3..ce7c77f02`, 24 files, 31 commits.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage R per `spec.md` `## Delivery Stages`, so the five `[R]` criteria are owed here. Criteria tagged `[A]` to `[E2]` were delivered by earlier PRs and were re-checked only for regression. Criteria tagged `[F]` to `[J]` and `[I]` are owed by later stages and are not judged in this PR.
- Owner condition applied: each reduction is revertible months later from its entry alone, without `git revert`.

## Acceptance Criteria Inventory

Stage R criteria, identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion (abridged) |
|---|---|
| R1 | The README states the revert order (newest-first; alone only when no later entry names its paths; later entries found through `## Files Changed`); no entry lists its dependants. |
| R2 | Each stored patch stays in place and is read hunk by hunk as a revert block; the `## Stored Patch` check runs after every later entry touching its paths is reverted; mirrors, bundle copies, and generated Codex variants are left to re-copy and regeneration. |
| R3 | `ProcessReductionChain.Ledger.Tests.ps1` reverts every committed entry newest-first in memory with no exception, skip list, or allowed-error list; its end-state check finds each created path absent and each pre-image of the oldest entry present. |
| R4 | No new structure-checker rule; the chain test is the check and runs on every full CI run in the PowerShell shards. |
| R5 | The chain compares only revert-block and hunk regions: an edit outside every region keeps it green, an edit inside a region fails it until the same commit updates the entry's record, as the `0001` brief-hunk rebase shows. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| R1 | PARTIAL | README `## Revert Order` states newest-first, the alone condition, and the `## Files Changed` search (`PRC-README-REVERT-ORDER-STATED` passed). The clause "no entry lists its dependants" is false: entry `0001` `## Revert Steps` step 1 names `0006` as the entry to revert first. That list is also incomplete, because `0002` to `0005` share 6, 29, 6, and 31 paths with `0001`. Followed literally, step 1 leaves 26 hunks on 15 source paths unreverted (reviewer chain restricted to `0006` and `0001`). Finding F1. |
| R2 | PASS | README `## Revert Order` second and third paragraphs and the amended `## Entry Format` sentence. The `0001` and `0006` check sentences name the tree after later entries are reverted. `Get-ProcessReductionPatchHunk` assigns `Current` as context plus added lines and `Prior` as context plus removed lines. `PRC-CHAIN-SKIPS-DERIVED-PATHS` passed. Reviewer: plain `git apply -R --check` of each patch on the chain-derived tree before that entry exits 0 (`0006` and `0001`), with 50 generated variants excluded. |
| R3 | PASS | The test file holds four cases with no skip parameter and no filter variable, and `PRC-LEDGER-NO-EXCEPTIONS` checks this on its own syntax tree. In the gate run, `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-END-STATE-RECORDED` passed. Reviewer: `IsValid` true, 0 errors. Note RN2: the created-path half of the end-state check holds by construction, and the pre-image half is the part that can fail. |
| R4 | PASS | `scripts/dev-tools/ProcessReductionLedger.psm1` is not in the diff, so no checker rule was added. `config/poshqc-scan.json` scans `tests/scripts`. `config/ci-docs-only-paths.json` does not list `docs/engineering/`, so a ledger change gets a full run. No ledgered file path lies under a docs-only prefix. |
| R5 | PASS | Reviewer mutants: an in-region edit to the brief gives 6 errors; an out-of-region append to the brief and all byte-identical copies gives 0, and so does a header and tail added to the planner hook. With the merge-base `0001` patch, the chain gives exactly the brief error (1). The rebased patch gives 0 errors. The rebase sits in `03b4d808a` with `reduction: 0001`. |

Earlier criteria (`[A]` to `[E2]`): no regression found. The `PRL-*` suites passed unchanged (72, 15, and 4 tests), and the merge-commit back-fills satisfy `PRL-REAL-LEDGER-AGREES`.

## Summary

Four of the five stage R criteria pass, and R1 is PARTIAL. The newest-first rewind that RF1 asked for is stated, enforced on CI, and confirmed by two independent methods: the shipped module's chain and plain `git apply`. The remaining gap is a record inconsistency. Entry `0001` step 1 still gives a one-entry revert order that the new README rule contradicts, and a reader of that entry alone follows the step. Under the owner's condition, entry `0001` does not yet work from its own text without the README. The fix is one sentence in `0001` and the matching hunk of the `0006` patch, committed together (README R5 remedy). Verdict: remediation required (F1, `autonomous`).

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 34 per file
- Remaining (unchecked): 23 per file
- Items remaining: `[R]` R1 (PARTIAL, F1); the criteria tagged `[F]`, `[G]`, `[H]`, `[I]`, and `[J]`, which later stages owe.

## Acceptance Criteria Check-off

- R2, R3, R4, and R5 were already checked by the executor and are confirmed PASS; they stay checked in both files.
- R1 was checked by the executor at `dac55695b`. It is evaluated PARTIAL, so this review set it back to `- [ ]` in `spec.md` and in `user-story.md`, changing only the checkbox. The re-review checks it off once F1 is fixed.
- No new criterion was added and no criterion text was changed.

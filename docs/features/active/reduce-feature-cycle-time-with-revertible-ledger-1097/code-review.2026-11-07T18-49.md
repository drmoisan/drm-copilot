# Code Review: Stage R, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `ce7c77f0207c8df4f9c7bc045f9a5f3c27106bfe`
- **Base:** `main`, merge base `81b6a1be385666e5025936a85e487e43e7ac6187`; `origin/main` at `c24cbd295` (PR #1113), trial merge clean
- **Scope:** full branch diff, 24 files, 31 commits
- **Reviewer:** feature-review agent, 2026-11-07

## Executive Summary

Stage R adds `scripts/dev-tools/ProcessReductionChain.psm1`. The module reads each stored patch hunk by hunk as a revert block, reverts every ledger entry newest-first in memory, and reports each block or hunk that does not apply. Two test suites cover it, one with fixtures and one over the committed ledger. The README now states the revert order and the remedy for an edit inside a recorded region. Both `## Stored Patch` check sentences are corrected, and the `0001` brief hunk that a non-ledgered stage E commit broke is rebased in the patch (RF1).

Judged against the owner's condition, that each reduction is revertible months later from its entry alone without `git revert`:

- **A newest-first rewind holds, and CI now pins it.** The reviewer reproduced `IsValid` true at head. With the merge-base `0001` patch, the chain reports exactly the one brief-hunk error. An edit inside a region fails the chain, and an edit outside every region passes. Plain `git apply -R --check` of both stored patches exits 0 on chain-derived trees and exits 1 for the pre-rebase `0001` patch. The gate artifact's claim is therefore confirmed by a method that does not share the module's matcher.
- **Entry `0001` alone still gives an incomplete revert order (F1, blocking).** Its step 1 says to revert `0006` first and then apply the patch. Entries `0002` to `0005` also touch its paths, so that route leaves 15 source paths that do not revert. The README added by this stage says entries are reverted after every later entry that names their paths, and that no entry lists its dependants. The entry and the README now disagree, and the entry is the less complete of the two.
- **Selective revert is not addressed (RN1).** Under the README, reverting `0001` means reverting all six reductions. Nothing tells a reader how to restore the later ones afterward. The working precedent, a new entry written from the stored prior text as `0006` did, is not stated.

Code quality of the module is good: pure functions, one read seam, explicit errors, the `git apply` nearest-occurrence rule with tie refusal, and 99.50% line coverage. One check in it cannot fail (RN2).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`; `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`; `docs/engineering/process-reductions/README.md` | `0001` `## Revert Steps` step 1; README `## Revert Order` first paragraph | F1. Step 1 reads "revert entry `0006` ... first ... Then run `git apply -R` of the patch when its check passes". The README requires every later entry that names one of the entry's paths to be reverted first. `0002` to `0005` name 6, 29, 6, and 31 of the 241 paths of `0001`. The README also states that "an entry's `## Revert Steps` does not list the later entries that depend on it", which `0001` contradicts. Reverting only `0006` and then `0001` fails 26 hunks on 15 source paths: the brief, the three `atomic-plan-contract` sources, `atomic-planner` (Claude and Codex), `remediation-handoff-atomic-planner`, four Copilot executors, both `execute-hard-lock` prompts, the `.github` `feature-review-workflow` skill, and the feature plan template. The README route fails none. AC R1's clause "no entry lists its dependants" is false on the tree. | Replace step 1 with text that defers to README `## Revert Order` and names no entry, for example "Revert every later entry that names any path in `## Files Changed`, newest-first, as README `## Revert Order` states; then run `git apply -R` of the patch when its check passes. Otherwise ...". The sentence is a line added by the `0006` patch, so in the same commit regenerate that hunk of the `0006` patch so its post-image carries the new sentence (README R5 remedy), with both `reduction: 0001` and `reduction: 0006` in the subject. Confirm `PRC-LEDGER-CHAIN-HOLDS`, `PRL-REAL-LEDGER-AGREES`, and `PRL-PARTIAL-REVERT-LINKED` still pass. | The owner's condition is that the entry works from its own text. The entry's own step is the one a reader follows months later. A partial dependant list is worse than none, because it reads as complete. The plan kept the sentence because editing it forces a `0006` hunk rebase, but the stage's own README names that rebase as the remedy. Remediability `autonomous`: the fix uses only repository records. | Reviewer chain restricted to entries `0006` and `0001`: 26 errors, 15 distinct paths. Full chain: 0 errors. `## Files Changed` intersections: `0002` 6, `0003` 29, `0004` 6, `0005` 31, `0006` 209. `grep` of the `0006` patch shows step 1 as an added line in its `0001-parallel-only-test-gates.md` section. |
| Minor | `docs/engineering/process-reductions/README.md` | `## Revert Order` | RN1. The README makes reverting an older entry a full rewind whenever a later entry shares a path, which holds for every entry before `0006` today. It gives no route to restore the later reductions after that, and no route to revert one older reduction while keeping the later ones. Forward re-application is not mechanical: block entries whose `Prior` is empty have no anchor, and a later block authored over the reduced text may not match the reverted text. | Add one sentence to `## Revert Order`: to revert an older reduction while keeping later ones, write a new entry that restores the older entry's stored prior text over the current tree, as `0006` did for `0001`, so the selective revert is itself revertible. | Non-blocking. The stage's criteria define the rewind, and the selective route has a working precedent. Whether "revertible" must also mean "revertible alone" is an owner decision. Class if made blocking: `human_decision_required`. | Path intersections above; `0006` `## Summary` (partial revert of `0001` from its stored prior text). |
| Minor | `scripts/dev-tools/ProcessReductionChain.psm1`; `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | `Get-ProcessReductionEndStateError` (the created-path branch); `PRC-LEDGER-END-STATE-RECORDED` | RN2. The created-path half of the end-state check cannot fail. A create hunk sets the path to `$null` in `Invoke-ProcessReductionPatchStep`. An older entry that touched the same path either errors because the file is absent or replaces the touch record, which resets `Created`. The branch at line 368 is the module's only uncovered line, and the evidence says it is unreachable. The ledger test's assertion that each created path ends absent therefore holds by construction. The pre-image half can fail, as `PRC-CHAIN-END-STATE-PREIMAGES` shows. | Remove the unreachable branch, or make it meaningful. For example, record a create hunk's `Current` and check before the step that the file holds it, so that a later edit to a created file without a record is reported. Reword AC R3's evidence to rest on the pre-image half. | Non-blocking: the git-level gate's end-state comparison (119 equal, 18 attributed, 0 unattributed) is the stronger check and exists. A check that cannot fail should not read as evidence. | `artifacts/pester/powershell-coverage.xml` (missed line 368 only); `stage-r-powershell-test.2026-11-07T18-33.md`. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | `Get-ProcessReductionDerivedSource` | RN3. The function returns the first mapping hop. A bundle path under `customizations/.github/skills/` maps to the `.github` skill copy, which is itself derived from the `.claude` skill. The chain is unaffected because it only tests for a non-null result. A caller that reads the returned path as the text to restore, as the reviewer's first scratch probe did, gets an unreverted mirror. | State in the help text that the result may itself be derived, or resolve to the final source. | Documentation precision. | Reviewer probe: `git apply -R --check` failed on two bundle copies with one-hop resolution and passed with transitive resolution. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | `Invoke-ProcessReductionPatchStep` derived-path test | RN4. Derivation is decided from live text only. When a source is edited and its byte-identical copies are not re-synced, the copies become sources, and the chain reports hunk failures on them. Block entries record sources only. The message does not say that mirror parity broke. | None required. The mirror parity tests report the same state more directly. | Diagnostic clarity only. | Reviewer mutant: brief edited alone gives 3 errors on copies; brief and all copies edited together give 0. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N3 (carried). The header still reads `Last Updated: 2026-11-06T21-23` and `Version: 0.1` after the stage R edit. | Update it with the next spec edit. | Record only. | `spec.md` header. |
| Nit | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | Threaded reader arc 395->362 | N2 (carried). One timing-dependent branch moved, from 62 to 61 of 88. The file is not in the diff. | For the owner, as before. | Record only. | `stage-r-python-test.2026-11-07T18-38.md`. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev-tools/ProcessReductionChain.psm1` at 497 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### PowerShell: what changed well

- `Get-ProcessReductionPatchHunk` counts the remaining old and new lines from the hunk header, so a context line that holds a single space survives. It strips the tab git appends to a spaced name and refuses binary sections and quoted paths with a message naming the section.
- `Invoke-ProcessReductionHunkRevert` matches whole lines only and picks the occurrence nearest the recorded start. It throws on an equal-distance tie instead of guessing.
- `Invoke-ProcessReductionChain` reads each entry's blocks from the chain state of its own file, which handles the `0006` patch's edits to entries `0001` and `0005`. The previous review identified this as the trap a live-file read falls into.
- Patch entries check their own blocks before and after the patch step, so a block and a hunk of the same entry cannot drift apart unnoticed.

### API and safety

- Five exported functions; no process start, no `Invoke-Expression`, no file write. `Read-ProcessReductionChainInput` is the only reader.
- Entry ordering sorts `Name` as a string, which is correct for the four-digit, zero-padded numbering the README mandates.

### Test quality

- The fixture tests cover each rule of plan R3 by name, with exact error-string assertions.
- `PRC-LEDGER-NO-EXCEPTIONS` inspects its own file's syntax tree for skip parameters and allow or skip variables, so an exception list cannot be added quietly.
- The reviewer confirmed discrimination outside the test run. With the merge-base `0001` patch, the chain reports the brief error. With an in-region edit, it reports errors. With synced out-of-region edits, it reports none.
- No test checks entry `## Revert Steps` text against the README order rule. F1 passed every gate for that reason.

### Revert order (F1, RN1)

- The README rule is sound for a rewind and is enforced. The defect is the leftover sentence in `0001`. It is the first thing a reader of that entry follows, and it lists one dependant of five.
- Path-level overlap is coarser than region-level overlap, so some of the 15 paths might apply by hand without reverting the later entries. The README chooses the conservative path rule, and the entry should agree with it.

### Security and correctness

- No secret, no command construction, no network. Correctness of the chain was cross-checked with plain `git apply` on independent trees.

## Verification Performed

- `git -C <worktree> log` and `diff --stat` over `81b6a1be3..HEAD`; per-commit token check.
- In-memory chain and mutants (policy audit, Executive Summary table).
- Scratch-folder `git apply -R --check` of both patches and of the merge-base `0001` patch.
- Literal step 1 route: chain restricted to `0006` and `0001`.
- Coverage and JUnit parsing; logical line counts.
- `validate_evidence_locations.py` exit 0; `git merge-tree` against `origin/main` exit 0.

## PR Readiness

**Not ready to merge.** F1 requires one record correction, an entry sentence plus the matching `0006` hunk in one commit, and a re-review. RN1 and RN2 can be taken in the same cycle or deferred. CI run 42402548312 on this head is read by the orchestrator.

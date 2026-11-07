# Code Review: Stage R Re-audit, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `2195ec4e01c54aa4fd28181f0b536de7379de4a7`
- **Base:** `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 45 files, 51 commits (one merge)
- **Reviewer:** feature-review agent, 2026-11-07

## Executive Summary

This re-audit judges the two remediation cycles against the owner's condition: each reduction can be reverted months later from its entry alone, without `git revert`.

- **Cycle 2 resolved F1, RN1, and RN2 as specified.**
  - Entry `0001` step 1 defers to README `## Revert Order` and names no entry. No entry's `## Revert Steps` names a higher-numbered entry.
  - The `0006` hunk that adds step 1 was regenerated under both tokens.
  - The README states the keep-later-entries route.
  - The unreachable created-path branch is gone, and `ProcessReductionChain.psm1` is at 100% line coverage.
- **Cycle 3 is sound for the ledger as it stands.**
  - The `### Later Landing: #N` split and the "within an entry's turn, later landings first" order are implemented in `Get-ProcessReductionLanding` and `Invoke-ProcessReductionChain`.
  - The README states the order, and seven fixture cases and `PRC-LEDGER-SUBCHAIN-HOLDS` pin it.
  - The rule "a later landing may not edit a region a higher-numbered entry records" is enforced for non-commuting edits: `PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS`.
  - Context-only overlaps commute and are absorbed by the README's rebase rule, which is correct.
  - The reviewer reproduced the chain and both sub-chains (`IsValid` true, 298 paths).
- **Executor point 1, `--full-history --no-merges` in the git-level gate: accepted.** It corrects the gate's commit listing after a merge and does not weaken the attribution test. The reviewer confirmed the four-path explanation on two paths:
  - Only the new form lists PR #1108's `3b21425f6`.
  - The chain end state equals the file at that commit.
  - The `0001` merge's first parent equals the file just before that commit.

  The gate is item evidence, not a standing gate, so the change takes no ledger entry.
- **Executor point 2, created-file content: Blocking (F1).**
  - The create branch of `Invoke-ProcessReductionPatchStep` sets the path absent without comparing it with the hunk. Two probes on the real ledger stay green: one appends a line to `feature-review-coverage-narrowing-parity.Tests.ps1`, the other deletes it. A control edit inside a modify hunk fails as expected.
  - Either change would make `git apply -R` of the `0001` patch, the entry's primary record for about 190 paths, fail as a whole. The reader is then left with the hand-applied fallback.
  - PR #1113 made exactly such an edit within a day. Only the item's evidence-only git gate caught it, and CI would not have.
  - AC R5 and README `## Revert Order` both state that an in-region edit fails the chain until the record is updated. A create hunk is a region, so R5 is PARTIAL.
  - The fix is local and restores the README's claim without new rules.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `scripts/dev-tools/ProcessReductionChain.psm1`; `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | `Invoke-ProcessReductionPatchStep`, the `create` branch; `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` | F1. A create hunk sets `$State[$path]` to `$null` without reading it. The chain therefore accepts a created file that was edited after creation without a record, and one that is absent at the entry's turn. The test `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` pins the first case as valid. On the real ledger, appending a line to `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` gives `IsValid` true, and so does setting it to `$null`. A control edit inside a modify hunk gives 1 error. In either created-file case, `git apply -R --check` of the `0001` patch fails, and `git apply` is atomic, so the entry's primary route is lost for every path. PR #1113 (`test(hooks): add the item-resolution baseline mocks ...`) added four lines to that file. Cycle 3 found it only through the git-level trial (`stage-r-cycle3-merge.2026-11-07T20-12.md`), and the CI chain test would have passed. | In the `create` branch, before setting the path to `$null`: record `"${Name}: ${path}: the file the entry created is absent at this step."` when `$State[$path]` is `$null`. Record `"${Name}: ${path}: the file the entry created differs from its create hunk."` when the chain-state text, with one trailing LF removed, differs from the hunk's `Current` lines joined by LF. Then set it absent as now. Compare BOM-neutrally if a created file may start with U+FEFF; both current created files have none. Replace the edited-file half of `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` with an unedited created file, and keep its deleted-file half. Add a named case, for example `PRC-CHAIN-REPORTS-STALE-CREATED-FILE`, with three sub-cases: an edited created file gives the second message, an absent one gives the first, and an unchanged one gives no error. Keep `PRC-LEDGER-CHAIN-HOLDS` green: the reviewer confirmed both live created files equal their create hunks at the `0001` turn. | Owner Condition 1 and AC R5. The stored patch is what entry `0001` reverts through for most of its paths. It may decay only when CI says so, and a create hunk is a recorded region like any other. The README already promises this ("the chain test catches it on CI"), so the fix changes no rule, no spec criterion, and no README text. It overrides the cycle 2 note that comparing created content "contradicts the chosen design". A created file still ends absent whatever it held, and only an unrecorded change is reported, exactly as for a modify hunk. The fix uses only repository records, so the class is `autonomous`. | Reviewer probes (policy audit, Executive Summary table); `ProcessReductionChain.psm1` lines 326 to 328; `ProcessReductionChain.Tests.ps1` lines 227 to 244; `stage-r-cycle3-merge.2026-11-07T20-12.md` (narrowing-parity bullet); `self-review.2026-11-07T20-33.md` (observation row). |
| Minor | `docs/engineering/process-reductions/README.md` | `## Revert Order`, second paragraph | RN5. The rule "a later landing may not edit a region that a higher-numbered entry records" says nothing about the landing's own update to its entry text. The README requires that update in the same commit, and it can fall inside a higher entry's patch hunk on that entry file. That happened here. The #1096 landing extended `0001` step 1, which is an added line of the `0006` hunk on `0001-parallel-only-test-gates.md`. The merge resolved it by rewriting both images of that `0006` hunk under both tokens, which is the correct outcome: reverting `0006` keeps the #1096 instruction. | Add one sentence: an entry's own record text is not a landing region, and an edit to it inside a higher entry's hunk is recorded by regenerating that hunk, as the merge of PR #1112 did for `0006`. | Non-blocking. The chain holds, and the ledger is correct. The sentence lets the next reader repeat the resolution without reconstructing it. | `git diff 12825cb00 HEAD -- docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`; `stage-r-cycle3-merge.2026-11-07T20-12.md` "Rebased Records". |
| Minor | `docs/engineering/process-reductions/README.md` | `## Revert Order`, fourth paragraph | RN6. "Run `git apply -R` of the patch. A hunk that does not apply is applied by hand" reads as if `git apply` applied the rest. Without `--reject`, `git apply` applies nothing when any hunk fails. | State the command form, for example `git apply -R --reject`, which applies the hunks that fit and leaves `.rej` files for the rest. Or state that the check is all-or-nothing and the whole patch is then applied by hand. | Non-blocking; a months-later reader would discover the behavior, but the entry should say it. | `git apply` behavior; README text. |
| Nit | `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` | Hunk on `0001-parallel-only-test-gates.md` `## Revert Steps` | RN7. The stage R pointer "revert every later entry ... as README `## Revert Order` states" lives only in the `0006` post-image. Reverting `0006` alone therefore removes that pointer from `0001` step 1. This is consistent with the README rule for edits to `+` lines. The README still governs the order, so nothing is lost. | None required. | Record only. | `0006` patch hunk at +917. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | `Get-ProcessReductionDerivedSource` | RN3 (carried). The function returns the first mapping hop, not the final source. | State it in the help text, or resolve transitively. | Documentation precision. | Prior review. |
| Nit | `scripts/dev-tools/ProcessReductionChain.psm1` | Derived-path decision | RN4 (carried). Derivation is decided from live text only, so a broken mirror reports as hunk failures on copies. | None required. | Diagnostic clarity. | Prior review. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N3 (carried). `Last Updated` and `Version` are unchanged after the stage R edits. | Update with the next spec edit. | Record only. | `spec.md` header. |
| Nit | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | Threaded reader arc | N2 (carried). A timing-dependent branch; no difference in the cycle 3 run. | For the owner, as before. | Record only. | `stage-r-cycle3-python-test.2026-11-07T20-25.md`. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `scripts/dev-tools/ProcessReductionChain.psm1` at 572 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Later landings (cycle 3)

- `Get-ProcessReductionLanding` tracks fence length, so a `### Later Landing:` line inside a fenced block is ignored (`PRC-LANDING-SPLITS-PRIOR-TEXT`). It throws for a heading with no block, and the chain reports that error (`PRC-LANDING-EMPTY-THROWS`).
- Landings are parsed from the chain-state text of the entry file. This keeps the earlier lesson that a later patch may rewrite an earlier entry's record.
- Each landing gets its own touch map, merged after the landing, so the end-state pre-image check uses the oldest touching landing.
- The rule against editing a higher entry's region is enforced where the edit does not commute. An edit to a `+` line or a block `Current` makes the higher entry's `Current` unfindable. An edit to context lines commutes and is legitimately absorbed by a rebase. The README's sentence "the chain test fails on a violation" is accurate in that sense.

### Git-level gate change (executor point 1)

- Without `--full-history`, `git log -- <path>` simplifies history at merges and follows one parent whose content matches. After the cycle 3 merge it walked only the PR #1112 side. With `--full-history --no-merges` it lists every non-merge commit that touched the path on either side.
- The attribution test is unchanged: a difference from the `0001` merge's first parent needs a token-free non-merge commit that touched the path. A merge subject cannot attribute anything.
- Reviewer confirmation on `fix_all_branches_extra.py` and `qc_toolchain.py`: the end state equals `3b21425f6:<path>`, and the `0001` merge's first parent equals `3b21425f6~1:<path>`.

### Created files (executor point 2, F1)

- A create hunk's `Prior` is empty, so a stale create section loses no restore text. That is the cycle 2 reasoning, and it holds for the end state. It does not hold for the stored patch's applicability. The patch is the record that entry `0001`'s step 1 runs first, and `git apply` refuses the whole patch on one stale section.
- The two created files are test suites that other work edits. One was edited within a day by PR #1113.
- The item's git-level gate catches the problem, but it is not a repository test. After this PR merges, nothing on CI would.

### Security and correctness

- No secret, no command construction, no network. The module writes nothing.

## Verification Performed

- `git -C <worktree> fetch`, `diff --stat`, `log` over `12825cb00..HEAD`, and the first-parent token check of every ledger-file commit.
- In-memory chain, sub-chains, created-file probes, a modify-hunk control, and created-file equality at the `0001` turn.
- `## Revert Steps` search for higher entry numbers in all six entries.
- `git log` with and without `--full-history --no-merges`, and end-state equality against `3b21425f6`.
- `git apply -R --check` of the `0006` patch on the live tree (exit 0), and the conflict-marker scan (no match).
- Coverage XML parsing; logical line counts; `validate_evidence_locations` exit 0; `git merge-tree` exit 0.

## PR Readiness

**Not ready to merge.** F1 is one contained change in `Invoke-ProcessReductionPatchStep` with its tests, and it is suitable for the light path. RN5 and RN6 are one-sentence README additions that may be taken in the same cycle. CI run 42411868745 on this head is read by the orchestrator.

# Feature Audit: Stage G, Less Evidence and the CI Cross-check (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `3f46b17db132e54ff32e20620097250c3077eca0`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. The caller supplied it, and `artifacts/pr_context.summary.txt` confirms it: that file resolves `origin/main` @ `992d6849455d54c942e69748b768c67d8cfd2fef` for head `3f46b17db`.
- Merge base: `992d6849455d54c942e69748b768c67d8cfd2fef`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `992d6849455d..3f46b17db`, 74 files, 23 commits, including two merges of `origin/main` (`ed6dc022a` for PRs #1124 and #1125; `3f46b17db` for PR #1126).
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage G per `spec.md` `## Delivery Stages`, so the four `[G]` criteria are owed here. Criteria tagged `[A]` to `[F]` were delivered by earlier PRs and were re-checked for regression. Criteria tagged `[H]` to `[J]` are owed by later stages and are not judged in this audit. The stage H plan `plan.2026-11-07T22-28.md` is in the diff and passes the plan validator, and it owes nothing here.
- Decisions applied: D5, D13 (hard limit), K7, and K9 (added in its own commit `cfe8df45f`, which adds one line and changes no criterion).

## Acceptance Criteria Inventory

Stage G criteria, identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion (abridged) |
|---|---|
| G1 | The evidence requirements marked Reduce in research section 4 are removed from the skills and templates, and those marked Keep remain. |
| G2 | The reviewer writes `## CI Cross-check`, and a mismatch at the join becomes a synthetic Blocking finding that blocks merge, as in K7. |
| G3 | The less-evidence reduction lands as its own commit with its entry. |
| G4 | The less-evidence reduction does not reduce any baseline task, baseline evidence, or baseline comparison, including the Phase 0 test-suite baseline and the final-gate comparison restored at stage E2. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| G1 | PASS | The Reduce rows follow K9's re-derivation. (1) Static artifact: all 40 skill, agent, Codex-variant, and bundle copies state `one final-QC static artifact per language`, and `git grep` finds no `one final-QC artifact per QC command step` or `each final-QC step artifact` at head. (2) Python repo-wide total: the `.claude` and `.agents` workflow copies, the four feature-review copies, and the template name `Enforce Python coverage thresholds`, and the PowerShell and TypeScript repo-wide rows remain. (3) Scope listings: the template's `Code Under Test` is the merge base and head, and section 9 keeps its heading without `### Commits in This PR/Branch` or `### Files Modified`. The Keep rows remain: test-gate artifacts, per-file coverage, changed-line regression, fail-before, preflight-fixes, self-review, check-off, and the absent-artifact FAIL, which now also says "beneath the item worktree". `LEC-STATIC-ARTIFACT-*`, `LEC-PYTHON-TOTAL-*`, `LEC-SCOPE-LISTING-*`, and `LEC-KEPT-*` pin them, 77 `LEC-` tests with 0 failures. |
| G2 | PASS | Reviewer side: `feature-review-workflow` step 4 (all six copies), `feature-review` agent step 5 (four copies), the template section with the header `\| Check \| Claimed outcome \| Claimed figure \| Head \| Source \|`, and the `AGENTS.md` bullet. Join side: orchestrate item 11 (four copies) compares each row with `ci_gate` and `gh pr checks`, treats a missing check, a differing outcome (cancelled as fail), or a differing head as a mismatch, and appends a `REMEDIATION_REQUIRED` entry with an `autonomous` finding. Merge block: `RG-ci-cross-check-synthetic-after-pass` and `RGC-ci-cross-check-synthetic-after-pass` expect `REVIEW_GATE_NOT_PASSED` from the Claude guard and its Codex twin. `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-VALID` shows the entry is well formed, and `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-BLOCKS-COMPLETION` shows completion is refused under the key. All passed in the P3-T2 gate. This review writes the section itself. |
| G3 | PASS | `38517b6b3` (`docs(process-reductions): land less evidence whole with entry 0009 (reduction: 0009)`) holds the 53 reduction paths, entry `0009`, its README row, and its stored patch, and no other path. The reviewer checked four things. (1) The diff from the merge base to `13a1340ac` over those 56 paths is empty, so the withdrawal fully undid the split landing of `c58c16243` and `fe81a1118`. (2) The `38517b6b3` diff over those paths equals the branch diff over them byte for byte, so this one commit is what the branch delivers. (3) No later commit touches them. (4) The stored patch is byte-identical to a regeneration, and the in-memory chain over 9 entries is valid. Owner Condition 1 is met: the reduction is its own commit with its entry in that commit. The intermediate commits stay in history because no history was rewritten. The entry's history sentence understates the token commits (CR1), and the P3-T4 evidence predates the re-landing (CR2). Neither affects the criterion. |
| G4 | PASS | The executor's D13 check `stage-g-baseline-text-check.2026-11-08T13-09.md`, re-run at commit in `stage-g-ledger-replay.2026-11-08T13-34.md`, found that 52 of 52 paths keep every line matching `baseline\|regression\|pre-change\|Phase 0`. The reviewer counted at base and head: `Phase 0 baseline` 539/539, `regression on changed lines` 40/40, `Baseline Coverage Documented` 2/2, `No Coverage Regression` 2/2. The atomic-planner `Phase 0` bullet, the executor sentence "no per-file or repo-wide coverage drop", the contract's comparison with the `Phase 0 baseline` run, and the reviewer's modified-file `Phase 0 baseline` bullet are unchanged, and `LEC-BASELINE-HELD-*` pins them. This stage itself captured a Phase 0 baseline and compared its final gates with it. |

Earlier criteria, re-checked for regression:

- `[A]` to `[D]`: the ledger, stage timing, guard, and validator suites pass unchanged in the stage G gates (Pester 19666 tests and pytest 16537, both with 0 failures). The `[A]` parallel-gate criterion holds: one `Invoke-PoshQCParallelTest` and one `pytest -n auto` run per gate.
- `[E]` and `[E2]`: the planning standing rule and the restored Phase 0 baseline text are unchanged, as the G4 counts show. No serial, seeded, reversed, or comparison run was made.
- `[R]`: the chain over 9 entries is valid, in full and with each `-StopBefore` replay. A reviewer mutant probe inside a `0009` hunk fails the chain, and an edit outside every region keeps it green.
- `[F]`: no plan-gate file is in the diff. Both feature plans pass the Python CLI validator under the lowered guideline.

## Summary

Stage G delivers the less-evidence reduction and the CI cross-check across every skill, agent, Codex variant, bundle, and template copy. After the crash re-landing it is one reduction commit, `38517b6b3`, with entry `0009`. All four `[G]` criteria pass, and no earlier criterion regressed. No production file changed. PowerShell repo-wide line coverage is 95.56% against a Phase 0 figure of 94.18%, with growth from the main merge.

No blocking finding. Non-blocking items: CR1 (the entry's history sentence and the token commits), CR2 (P3-T4 records predate the re-landing), CR3 (`0008` merge-commit back-fill outstanding), and Nits CR4 to CR6. Verdict: PASS. `ci.yml` run 42486253596 on this head is pending-CI and is read by the orchestrator at S9. No stage G criterion depends on CI.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 42 per file
- Remaining (unchecked): 15 per file
- Items remaining: the criteria tagged `[H]` (2), `[I]` (7), and `[J]` (6), which later stages owe.

## Acceptance Criteria Check-off

- G1, G2, and G4 were checked off by the executor. This review evaluates each as PASS, so they stay checked in both files.
- G3 ("The less-evidence reduction lands as its own commit with its entry.") was newly checked off by this review in `spec.md` and in `user-story.md`. Only `- [ ]` was changed to `- [x]`. The change is uncommitted in the item worktree for the orchestrator to commit with the review artifacts.
- No criterion was added and no criterion text was changed.

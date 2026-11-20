# Code Review: Stage E with its Remediation and Stage E2 Baseline Restore (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, equal to `origin/main` after a fetch)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `377c187bcc4dd3acc190c7b78f4a26c204c660bd`
**Review Type:** Combined review of PR E: stage E, its remediation cycle, and stage E2 (280 files, 44 commits)

---

## Executive Summary

Since the stage E review (`code-review.2026-11-07T12-07.md`, head `b71c1d064`), the branch gained two bodies of work:

- **Stage E remediation.** Prior F1 is closed: the review prompt and its bundle no longer require `phase0-instructions-read.md`, entry `0005` gained a revert block for the prompt and two `## Files Changed` lines, and `PCW-SURFACE-REVIEW-PROMPT` forbids the token. Prior N1 is closed: `light_design_path_key_case_variant.json` pins the invariant 8 path read in all three runtimes, with the three count pins and entry `0003` updated in the same commit.
- **Stage E2.** The owner's 2026-11-07 decision restores the Phase 0 test-suite baseline and the final-gate comparison as a partial revert of entry `0001`. The contract states one `Phase 0 baseline` run per gate (one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, one Jest coverage run), records counts and repo-wide and per-file coverage, and compares the final gate with it. The QA gates restore `## Delta Requirements (Zero-Regression Hard Gate)` against the single gate run. The review surfaces restore the modified-file no-regression rule. The templates restore numeric baseline cells with `N/A - no pre-change run` as the stated alternative. No hook or validator changed, and a plan that captured static baselines only stays valid.

The reviewer verified by execution: the ledger is valid with 6 rows; the 25 blocks of `0006` restore each of their five paths to the text at `8c14d673f^`; the new `0005` prompt block restores the prompt at `2ab2710d5` to its parent; all 155 `Current` fences occur exactly once; every changed bundle equals its source; the generator `--check` exits 0; and the added lines of both `reduction: 0006` commits name no serial, single-process, seeded-shuffle, reversed-order, targeted, or comparison run.

One Blocking item, F1: the Codex executor family does not carry the sentence that E2 added to the Claude executor. Two Minor items and two Nits follow.

**What changed well:**
The partial revert is recorded as a new entry whose `Current` holds the restored text and whose `Prior` holds the `0001` text, so reverting `0006` re-applies the reduction, and `0001` step 1 orders that revert first because the `0001` patch no longer reverse-applies. The restored rule names the one parallel run wherever the pre-`0001` text named a run shape, and the 12 run-class sweep tokens stay forbidden. The transition sentence carrying `static baselines only` keeps older plans valid without a validator change, and the review skill states when `N/A - no pre-change run` still applies.

**Top 3 risks:**
1. F1: a Codex executor reads a `## Toolchain Commands` section that does not state the comparison with the `Phase 0 baseline`, while its Claude twin does.
2. N2: the restored "no repo-wide coverage drop" rule compares raw totals that include a timing-dependent branch; this stage's own Python gate met it only at two-decimal precision.
3. The `Merge commit: pending (PR #1097)` stand-ins of `0004`, `0005`, and `0006` are replaced after PR creation, outside the feature folder, so CI must be re-read at that head.

**PR readiness recommendation:** **Not ready until F1 is fixed.** F1 is a contained mirror fix suitable for the light remediation path. CI run 42386503847 on this head was `in_progress` when this review was written.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.codex/agents/atomic-executor.toml`, its generated variants `atomic-executor-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`, and their six bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/` | `## Toolchain Commands`, after "Run toolchain in order: format, lint, type-check, test." | F1. Stage E2 added to `.claude/agents/atomic-executor.md` (and its bundle): "The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop." The Codex base has the same section, identical apart from this sentence, and none of the 12 Codex files was changed. The E2 plan's B9 row names "Codex bases and generated variants" for the planner, executor, and engineer surfaces; the Codex planner and typed-engineer bases were updated, the executor base was not. `parallel-gate-wording.Tests.ps1` pins `EXEC-CLAUDE` and `EXEC-CODEX` with the same required list, but no row requires `Phase 0 baseline` on either, so the gap passes every gate. | Add the sentence, byte-identical, to `.codex/agents/atomic-executor.toml` after "Run toolchain in order: format, lint, type-check, test."; regenerate the variants and bundles with `generate_codex_agent_variants` and run `--check`; add `Phase 0 baseline` to the `Required` lists of `EXEC-CLAUDE`, `EXEC-CLAUDE-BUNDLE`, and `EXEC-CODEX`; add the 12 Codex paths to entry `0006` `## Files Changed` and regenerate the stored patch from the first parent of `8c14d673f`; one commit with `reduction: 0006` in its subject. | The owner's decision applies to every runtime. The P0-T5 inventory marked Codex files only by `0001` hunks, and `0001`'s hunk in `atomic-executor.toml` carried no baseline line, so the new executor sentence had no Codex target in the plan. The self-review's B9 row counted 20 sources and variants without this family. Remediability class: `autonomous`; scope: contained (a mirror of a file in the branch diff plus its test row). | `diff` of the `## Toolchain Commands` sections of `.claude/agents/atomic-executor.md` and `.codex/agents/atomic-executor.toml` at head: one line differs. `git diff --stat bad886e30 HEAD -- .codex/agents/atomic-executor*.toml` is empty. `parallel-gate-wording.Tests.ps1` rows `EXEC-CLAUDE` and `EXEC-CODEX`. |
| Minor | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` (and `user-story.md`) | `## Delivery Stages`, `## Acceptance Criteria` | N1. Spec gap. The owner decided on 2026-11-07 that stage E2 ships in PR E, but `spec.md` has no E2 row in `## Delivery Stages`, no criterion tagged for E2, and its stage E row does not mention the restore. The PR therefore delivers 205 paths of behavior no tagged criterion owes. The closest criterion, `[I] No baseline task, evidence, or comparison requirement is removed.`, is owed by stage I. Owner Condition 2 and `## Behavior` ("Baseline artifacts and comparison ... are kept") are consistent with E2. | Amend `spec.md` and `user-story.md` with an E2 row and criteria matching the plan's acceptance conditions (one parallel `Phase 0 baseline` run per gate recording counts and coverage; final gate compared with it; parallel-only rules kept; older plans valid; partial revert recorded as `0006`). Amendment is a planning-agent or owner action, not a reviewer action. | The AC protocol forbids reviewers adding criteria, and the owner decision is the authority for E2 in the meantime. The gap affects traceability, not behavior, so it does not block merge. Remediability class if made blocking: `human_decision_required`. | `spec.md` `## Delivery Stages` table rows A to I; `grep` of both files for `[E2]` returns nothing; `plan.2026-11-07T08-41.md` `## Scope`. |
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md` (six copies), QA gates, `.claude/agents/atomic-executor.md`, entry `0006` | `## Phase 0 Requirements` ("no per-file or repo-wide coverage drop"); QA gate "Overall coverage delta ... greater than or equal to the baseline" | N2. The restored comparison compares raw repo-wide totals. Stage E2's own Python gate recorded 11765 covered branches against a baseline of 11766, equal only at two decimals (93.6932% against 93.7012%). The one branch is arc 395 to 362 of the unchanged `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py`, the loop-back after the idle check in a reader loop polled with a 0.1 s queue timeout; the stage E remediation gate, the E2 baseline, and the E2 final gate recorded 11765, 11766, and 11765 for the same file text. Under the literal rule the next plan can see a false regression, and the owner's rule forbids a comparison run to settle it. | Either state the precision at which repo-wide totals are compared, or restrict the no-drop comparison to changed files and new behavior and keep repo-wide totals threshold-only, as the review skill already does. Separately, the timing-dependent arc in `cli_copilot_runtime.py` can be made deterministic by its tests (outside this branch). | The review skill judges repo-wide coverage by threshold only, so no FAIL applies here; the rule text in the contract and QA gates is stricter than the review's. Remediability class if made blocking: `autonomous`, but a wording choice the owner may prefer to make. | `evidence/qa-gates/stage-e2-python-test.2026-11-07T15-24.md`; `artifacts/python/lcov.info` record `BRDA:395,0,jump to line 362,0`; `evidence/qa-gates/stage-e-review-test-gates.2026-11-07T14-05.md`. |
| Nit | Commits `8c14d673f` and `3e6c72138` | Branch log | N3. The plan's [P1-T10] called for one whole partial-revert commit. The first omitted the five template sources because its path filter excluded all of `docs/features/`; the second adds them with the token and regenerates the patch. The self-review discloses it. Between the two commits the template sources and their bundles differed. | None for this branch. Filter the feature folder by its exact path, not by `docs/features/`. | Revertibility is unaffected: both commits carry `reduction: 0006`, the stored patch spans all 205 paths from the first parent of the first commit, and the replay matches. Remediability class: none; record only. | `git show --stat 3e6c72138`; `evidence/other/stage-e2-ledger-replay.2026-11-07T15-08.md`. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/other/stage-e2-baseline-inventory.2026-11-07T14-46.md` | `Added text at HEAD` column | N4. The inventory was taken before the restore, so its `present` column describes the `0001` text at Phase 0, not the restored text. Post-restore evidence of each B-row comes from the `PGW-` rows and the self-review, not from the inventory. | None. A post-restore pass of the same script would make the inventory self-contained. | Record only. The F1 gap shows that the token rows, not the inventory, carry the per-copy check. | Inventory header and classification rules. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies; the largest changed covered file is 566 logical lines (`tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`). `config/file-size-baseline.json` is not in the branch diff.

### Prior findings (stage E review `code-review.2026-11-07T12-07.md`)

| Finding | Status | Evidence |
|---|---|---|
| F1 review prompt bullet held | Closed | `2ab2710d5` (`reduction: 0005`); token absent from both copies; `PCW-SURFACE-REVIEW-PROMPT`; the new block replays to the parent text. |
| N1 invariant 8 path read unpinned | Closed | `6ffea1c64` (`reduction: 0003`); corpus row `light_design_path_key_case_variant` passes in Pester, pytest, and Jest. |
| N2 stray plan in the `0005` commit | Unchanged; record only | No change owed. |

---

## Detailed Notes

### Owner constraints on the restored baseline

- One run per gate: every restored surface names one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, or one Jest coverage run. `## Test Isolation Checks` of the brief has no changed line.
- No serial, single-process, seeded-shuffle, reversed-order, or comparison run returns. The added lines of both `reduction: 0006` commits contain `targeted` only in "targeted verification evidence tasks read from the gate run" and in the test's token lists, and contain no `Invoke-PoshQCTest`, `run_poshqc_test`, or bare `poetry run pytest`.
- "Compared with" in the restored text names a comparison of recorded results and figures, not a second run.

### Stage E2 against the plan's acceptance conditions

- [P1-T1] to [P1-T7], [P1-T9]: met; bundles equal sources; `PGW-` and named pytest functions passed in the final gates.
- [P1-T8]: met as written (the generator `--check` exits 0 and every marked Codex file carries the text); F1 is a Codex counterpart the marking did not reach.
- [P1-T10]: met with N3; the reviewer's replay reproduces the recorded one.
- [P2-T1] to [P2-T4]: met; counts and coverage are equal to the baseline, with the one-branch note under N2.
- [P2-T5]: the self-review's B9 row did not detect F1.

### Security and correctness

No production code changed after stage E. The stage E production changes (one removed condition in the planner hook and the ordinal key reads) were reviewed at `b71c1d064` and are unchanged; their files are at 100% and 99.52% line coverage in the final gate.

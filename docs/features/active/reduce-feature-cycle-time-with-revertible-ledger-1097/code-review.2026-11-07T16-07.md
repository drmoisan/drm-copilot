# Code Review: Stage E and Stage E2 Re-audit After the Light Remediation Cycle (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`, equal to `origin/main` after a fetch)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `9676eed601cffa59a0b48d57ddbd7130b82b88c3`
**Review Type:** Re-audit of PR E (stage E and stage E2) after the light remediation cycle of `remediation-inputs.2026-11-07T15-37.md` (298 files, 49 commits)

---

## Executive Summary

Since the combined review (`code-review.2026-11-07T15-37.md`, head `377c187bc`), the branch gained five commits:

- `4bba1f2ae` records that review.
- `6f56f5fc3` adds decisions D11 to D16, an E2 row and a J row in `## Delivery Stages`, and criteria tagged `[E2]` (5), `[G]` (1 more, now 4), and `[J]` (6) to `spec.md` and `user-story.md`. The two criteria lists are identical (52 lines each). This closes prior N1.
- `b4f472337` (`reduction: 0006`) is the light fix for prior F1: the comparison sentence in `.codex/agents/atomic-executor.toml`, the five generated variants and six bundle copies regenerated, `Phase 0 baseline` added to the `Required` lists of `EXEC-CLAUDE`, `EXEC-CLAUDE-BUNDLE`, and `EXEC-CODEX`, and entry `0006` with the twelve paths and a regenerated patch.
- `9bb5dce1c` and `9676eed60` record the cycle's gates against the Phase 0 baseline and check the three light fix tasks.

The reviewer verified by execution: the two `## Toolchain Commands` sections are identical; each Codex executor file carries the sentence once and each bundle equals its source; the generator `--check` exits 0; the Codex base at `377c187bc` holds the token zero times, so `EXEC-CODEX` discriminates the fixed defect; the stored `0006` patch is byte-identical to a fresh `git diff --binary --no-renames 8c14d673f^` over its 217 paths and reverse-applies; the ledger is valid; and the added lines of `b4f472337` name no serial, single-process, seeded-shuffle, reversed-order, targeted, or comparison run.

The reviewer also compared every Claude agent that stage E2 changed with its Codex profile, to look for a sibling of F1. The executor, planner, and Python engineer match verbatim; the C# and PowerShell engineers and the review agent differ only in surface-specific wording, and each Codex profile carries the same baseline and comparison change.

No Blocking item. One Minor item, carried from the prior review, and two Nits.

**What changed well:**
The fix is the smallest change that closes F1, it pins the token on both sides of the executor pair so the same gap cannot pass the gate again, and it keeps the partial revert revertible: the patch was regenerated over the full path set from the same parent, not appended, so a single `git apply -R` still undoes all of `0006`. The cycle's gate evidence states the comparison with the Phase 0 baseline line by line, which is the behavior stage E2 restores.

**Top 3 risks:**
1. N1: the repo-wide "no drop" comparison is stated over raw totals, and one Python branch arc is timing-dependent. It did not show in this cycle's run.
2. The `Merge commit: pending (PR #1097)` stand-ins of `0004`, `0005`, and `0006` are replaced after PR creation, outside the feature folder, so CI must be re-read at that head.
3. CI run 42389090745 on `9bb5dce1c` was `in_progress` when this review was written; S9 owns the result at the final head.

**PR readiness recommendation:** **Ready for the PR stage, subject to green CI.** No blocking finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md` (six copies), QA gates, `.claude/agents/atomic-executor.md` and `.codex/agents/atomic-executor.toml` | `## Phase 0 Requirements` ("no per-file or repo-wide coverage drop"); executor `## Toolchain Commands` | N1 (carried from prior N2). The restored comparison is stated over raw repo-wide totals. Arc 395 to 362 of the unchanged `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` is covered or not by thread timing, so a run can show one branch fewer with no code change. In this cycle's run the arc was covered and the raw count equals the baseline (11766 of 12558). | For the owner: state the precision at which repo-wide totals are compared, or keep repo-wide totals threshold-only and apply the no-drop comparison to changed files. Separately, make the arc deterministic in its tests (outside this branch). | The review skill judges repo-wide coverage by threshold, so no FAIL applies. The wording choice belongs to the owner. Remediability class if made blocking: `human_decision_required`. | `evidence/qa-gates/stage-e2-r3-python-test.2026-11-07T15-58.md`; `artifacts/python/lcov.info` BRF 12558, BRH 11766; prior review N2. |
| Nit | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` | Header block | N2. The header still reads `Last Updated: 2026-11-06T21-23` and `Version: 0.1`, although `6f56f5fc3` added D11 to D16, two stage rows, and twelve criteria on 2026-11-07. | Update the header when the spec is next edited by its owner or a planning agent. | Record only. The decisions name their date and source inline. | `spec.md` lines 6 and 8; `git show --stat 6f56f5fc3`. |
| Nit | `.claude/agents/feature-review.md` and `.codex/agents/feature-review.toml` | Modified-file coverage rule | N3. The restored rule reads "coverage on changed lines has regressed from the `Phase 0 baseline`" in the Claude profile and "line coverage has regressed from the `Phase 0 baseline`" in the Codex profile. Both state a comparison with the baseline; the Claude text names changed lines and the Codex text names the file's line figure. | None required. If the profiles are aligned later, the contract's "no per-file ... coverage drop" is the reference wording. | The two profiles are not mirrors and differed in structure before E2. Record only. | `git diff 8c14d673f^ HEAD -- .claude/agents/feature-review.md .codex/agents/feature-review.toml`. |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies; the largest changed covered file is 566 logical lines (`tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`). `config/file-size-baseline.json` is not in the branch diff.

### Prior findings (combined review `code-review.2026-11-07T15-37.md`)

| Finding | Status | Evidence |
|---|---|---|
| F1 Codex executor family lacks the comparison sentence | Closed | `b4f472337`; sections identical; six files carry the sentence once; six bundles equal their sources; generator `--check` exit 0; `EXEC-CODEX` requires `Phase 0 baseline`, which the pre-fix base lacks; five JUnit cases of the three rows passed. |
| N1 spec gap for stage E2 | Closed | `6f56f5fc3`: D12, the E2 stage row, and five `[E2]` criteria in both files. |
| N2 raw repo-wide comparison and a timing-dependent branch | Open, non-blocking | Carried as N1 above. |
| N3 two partial-revert commits | Unchanged; record only | The light fix is a third `reduction: 0006` commit, as the inputs file required. |
| N4 baseline-part inventory predates the restore | Unchanged; record only | No change owed. |

---

## Detailed Notes

### Light-cycle conformance

- The cycle executed exactly the three tasks of `## Light Fix Tasks`, all in one commit with `reduction: 0006`, and changed no spec criterion, interface, validator, hook, or production file.
- The gates named under F1 were met: sections identical; generator `--check` exit 0; bundles equal; ledger valid; `git apply -R --check` exit 0; one `Invoke-PoshQCParallelTest` run (15657 tests, 0 failed) and one `pytest -n auto` run (16185 passed, 0 failed), each compared with the stage E2 Phase 0 baseline; evidence under `evidence/qa-gates/` with the `stage-e2-` prefix.

### Owner constraints on the restored baseline

- One run per gate: unchanged since the prior review, and the cycle's sentence names "one run of these gates".
- No serial, single-process, seeded-shuffle, reversed-order, or comparison run returns: the added lines of `b4f472337` contain none of those terms.

### Security and correctness

No production code changed after stage E. The stage E production changes were reviewed at `b71c1d064` and are unchanged; their files are at 100% and 99.52% line coverage in the cycle's gate.

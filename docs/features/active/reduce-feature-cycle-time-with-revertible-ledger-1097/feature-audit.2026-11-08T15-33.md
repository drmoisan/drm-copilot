# Feature Audit: Stage H, the Design Check in Single-Pass Preflight (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `7b0c79346f6848380facf8ef5555a770241882d0`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. The caller supplied it, and `artifacts/pr_context.summary.txt` confirms it: that file resolves `origin/main` @ `cdcff3871765396183590128e142a929cf78327b` for head `7b0c79346`.
- Merge base: `cdcff3871765396183590128e142a929cf78327b`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `cdcff3871765..7b0c79346`, 44 files, 12 commits, no merge commit.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage H per `spec.md` `## Delivery Stages`, so the two `[H]` criteria are owed here. Criteria tagged `[A]` to `[G]` were delivered by earlier PRs and were re-checked for regression. Criteria tagged `[I]` and `[J]` are owed by later stages and are not judged in this audit. The stage I and stage J plans in the diff owe nothing here; both pass the plan validator.
- Decision applied: D6 (a named pass inside single-pass preflight with no new delegation), with research section 7.

## Acceptance Criteria Inventory

Stage H criteria, identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion |
|---|---|
| H1 | The named design-check pass is in single-pass preflight, adds no delegation, and is pinned by a contract test. |
| H2 | All 6 copies of the atomic-plan-contract skill describe the new rules, and contract tests pin them. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| H1 | PASS | Named pass: each contract copy carries the bullet `**Run the design check.**` inside `### Single-Pass Preflight`, and the Claude, Codex, and Copilot executors state it as part of their preflight list. In single-pass preflight: the bullet says "Within the same single pass", and its output is the existing `PREFLIGHT-DEFECT:` line in the existing substantive class. No delegation: the text says "with no new delegation and no new artifact"; the Claude executor tool list is unchanged and holds no `Agent` entry; no hook, orchestrator step, or preflight round is added. Pinned: `PCW-DESIGN-CHECK-<Copy>` (6), `PCW-DESIGN-CHECK-EXEC-<Id>` (8), and `PCW-DESIGN-CHECK-NO-DELEGATION-<Id>` (2), all 16 `Passed` in `artifacts/pester/pester-junit.xml`. The reviewer confirmed that none of the five pinned tokens exists on the root surfaces at the merge base, so the rows fail without the stage H text. |
| H2 | PASS | `git ls-files` lists six `atomic-plan-contract/SKILL.md` files (`.claude`, `.agents`, `.github`, and the three bundles), and each carries the bullet exactly once inside `### Single-Pass Preflight`. Each root copy has the same blob id as its bundle. `PCW-DESIGN-CHECK-<Copy>` runs over the six entries of `$script:ContractCopy` and reads only the `Single-Pass Preflight` section. `test_plan_gate_document_docs.py` and the push-down resource contract tests, which check the copy set and byte equality, pass in the pytest gate. |

Earlier criteria, re-checked for regression:

- `[A]` to `[D]`: the ledger, stage timing, guard, and validator suites pass unchanged in the stage H gates (Pester 19682 testcases and pytest 16537, both with 0 failures). One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate.
- `[E]` and `[E2]`: stage H captured its own Phase 0 baseline and compared both final gates with it; no baseline text is changed (0 deleted lines on all skill and agent files).
- `[R]`: the chain over 9 entries is valid in full and with each `-StopBefore` replay. The reviewer's probes show the new bullet lies outside every recorded region, and an edit to `0008` text fails the chain.
- `[F]`: no plan-gate file is in the diff. The three feature plans in the diff pass the Python CLI validator.
- `[G]`: the less-evidence text is unchanged by this stage; the policy audit carries `## CI Cross-check`. The `0009` merge commit is now back-filled.

## Summary

Stage H delivers the design check as one bullet in all six contract copies and one sentence on every executor surface that restates single-pass preflight, with bundles equal to their roots and Codex variants regenerated. Both `[H]` criteria pass and no earlier criterion regressed. No production file changed; PowerShell repo-wide line coverage is 95.56%, equal to the stage H Phase 0 figure.

No blocking finding. Non-blocking items: CR1 (Minor, the pass gives no rule for a spec rule that only a reviewer or evidence can verify) and Nits CR2 to CR5, recorded in the code review. Verdict: PASS. No stage H pull request or CI run exists yet; no stage H criterion depends on CI, so CI is pending-CI and is read by the orchestrator at S9.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 44 per file
- Remaining (unchecked): 13 per file
- Items remaining: the criteria tagged `[I]` (7) and `[J]` (6), which later stages owe.

## Acceptance Criteria Check-off

- H1 and H2 were checked off by the executor in commit `12359abb5`. This review evaluates each as PASS, so they stay checked in both `spec.md` and `user-story.md`.
- No criterion was newly checked or unchecked by this review, no criterion was added, and no criterion text was changed.

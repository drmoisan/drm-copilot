# Feature Audit: Stage J, review/verdict Commit Status and Whole-Item Closing Criteria (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `60e92a837ca2c8815a79c1c782924e3a8a66c459`
- **Audit date:** 2026-11-08
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. `artifacts/pr_context.summary.txt` resolves `origin/main` @ `70e66be7566f4c7259acce97449c769f7ff3854a` for head `60e92a837`.
- Merge base: `70e66be75`, equal to `origin/main` after fetch; `main` includes stages A to I (PR #1144) and the release PR #1147.
- Range audited: `70e66be75..60e92a837`, 32 files, 24 commits, one merge commit (`23a4ba42d`, main sync after #1147).
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: stage J owes the six `[J]` criteria and the five whole-item `[I]` closing criteria (I3 to I7). It is the last stage; its pull request closes #1097. `[A]` to `[I]` delivery criteria were delivered by earlier PRs and are not regressed by this diff.

## Acceptance Criteria Inventory

Identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion | Owed here |
|---|---|---|
| I3 | The ledger holds an entry for every reduction made, including #1094; every entry carries the prior text or a patch, revert steps, and revert signals; and the reviewer confirms from the branch log that each reduction is a separate commit. | Yes |
| I4 | The planning, execution, and review skills, and all mirrored copies, describe the new rules, and contract tests pin them. | Yes |
| I5 | No baseline task, evidence, or comparison requirement is removed. | Yes |
| I6 | Older checkpoints and plans still validate: existing fixtures pass unchanged, and no Epic #1019 feature folder or admitted plan is edited. | Yes |
| I7 | Merge is still impossible without a passing review and green CI, within the limit stated in D10. | Yes |
| J1 | The `review/verdict` status, state `success`, is posted through `gh api repos/{owner}/{repo}/statuses/{sha}` only after a review returns PASS for the current PR head, with a description naming the review artifact; a test shows that no status is posted for any other verdict or for a non-current head. | Yes |
| J2 | A new push leaves the new head without the `review/verdict` status, so review must pass again before the status is posted on that head. | Yes |
| J3 | Records are committed before the status is posted, or a narrow tested rule re-posts the status for a records-only head after checking that the diff between the reviewed head and the new head is records-only; tests cover a records-only diff and negative cases such as a diff that includes a non-record path. | Yes |
| J4 | The rules that post the status for a main sync into an integration branch, a records-only PR, and a promotion-record PR are each narrow, keyed on the diff and the branch pattern, and tested with positive and negative cases. | Yes |
| J5 | The skill text states the limit: anyone with write access, including any agent with `gh`, can post the status, and it records a passing review and does not prove one. | Yes |
| J6 | The status adds no CI run, no CI job, no workflow file, no committed verdict file, and no GitHub ruleset change. | Yes |
| DoD1 to DoD7 | The seven generic `## Definition of Done` items in `spec.md` (not under `## Acceptance Criteria`). | Evaluated at the caller's request |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| I3 | PASS | Ten entries, 0001 to 0010; 0001 records #1094. `Test-ProcessReductionLedger` (reviewer, in memory): IsValid true, 0 errors, 10 entries; it enforces revert steps, revert signals, and prior text or a stored patch. Chain: IsValid true, 0 errors. Branch log (reviewer): `git log --no-merges --no-renames --diff-filter=A` finds one reduction commit adding each entry file: `20e1cb1cc` (0001), `ee44aaa86` (0002, added as `0001-concurrent-review.md` and renumbered in a main-sync merge), `33b80bd19`, `06e117005`, `110f124f8`, `8c14d673f`, `3a56488c5`, `39824bd35`, `38517b6b3` (0009; the crash checkpoint `c58c16243` also added the file and is recorded in 0009 as withdrawn), `5988fc822` (0010). Each carries one `reduction:` token. Stage J adds no entry; its back-fill `e3c119578` touches only the 0010 `Merge commit:` line (now `0bfa4f2a0`, the PR #1144 merge) and the plan. **CR6 (stage I) and I3:** CR6 records that during stage I cycle 3, commits `8abf90f98` and `5c50de7d8` carried `reduction: 0010` but left the stored patch at its cycle 2 state until `785076762`, and merge `4dae0e385` edited recorded regions without the token. That deviates from the README `## Revert Order` same-commit rule for record updates at intermediate commits. It does not falsify any I3 clause: the 0010 reduction landed as its own commit `5988fc822` with its entry and patch, and the head record is complete and reverses. Owner ratification of CR6 is still outstanding. It is a history-only item that cannot be fixed without rewriting pushed history on `main`, so this review treats it as non-blocking and recommends naming it in the stage J PR description. |
| I4 | PASS | Evidence P3-T2 (`stage-j-powershell-test.2026-11-08T23-21.md`): planning-contract-wording 114, concurrent-review-skill-contract 58, light-remediation-skill-contract 74, less-evidence-contract 77, parallel-gate-wording 56, early-start-skill-contract 56, review-verdict-skill-contract 36 (`RVS-*`), 0 failing. Reviewer: blob ids of the four orchestrate copies equal in each pair. Non-blocking CR2: the orchestrator-state rule bullet still scopes `head_sha` to concurrent runs. |
| I5 | PASS | Reviewer `git grep -c -F` at head: `Phase 0 must include a baseline task.` 1 in each of the two `validate-planner-output.ps1` copies; `Phase 0 baseline` 9 in each of the six atomic-plan-contract copies; `### Baseline Evidence Output Summary (Required)` 1 in each of the six evidence-and-timestamp-conventions copies. The stage J diff deletes no line in any skill copy or the helper. |
| I6 | PASS | Reviewer: `git diff --name-only 70e66be75 HEAD -- tests/fixtures` is empty, and no `docs/features/` path outside this folder is in the diff. The plan validator passes `plan.2026-11-06T21-23.md` and `plan.2026-11-08T09-47.md`. Evidence P3-T3: checkpoint corpus tests pass, 0 failed. |
| I7 | PASS | No path under `.github`, `.claude/hooks`, or `.codex/hooks` in the diff. RG 380 and RGC 236 testcases pass, deny rows included. Ruleset read in the closing-criteria evidence: required context `CI Required Gate`. The new status is a record beside the merge guard; skill item 4 says the merge guard is unchanged. |
| J1 | PASS | `Get-ReviewVerdictReviewDecision` requires a last verdict of exactly `PASS` and posts only on the live head equal to, or a records-only descendant of, the reviewed `head_sha`. The POST argv is `api --method POST repos/{owner}/{repo}/statuses/<head> -f state=success -f context=review/verdict -f description=feature-review PASS: <policy-audit file name>`. Tests: `exits 3 with no gh call for the verdict <Verdict>` (each non-PASS verdict) and the non-current-head rows of `exits 3 without a POST for <Name>`. Reviewer probe with real git facts: reviewed `70e66be75` refused, reviewed `5c633cb07` eligible on `60e92a837`. Non-blocking CR1: the named artifact is not tied to the PASS outcome. |
| J2 | PASS | A commit status belongs to one SHA, so a new head carries none. The decision refuses a non-descendant head (`REVIEW_VERDICT_HEAD_NOT_CURRENT`) and a code change after the review (`REVIEW_VERDICT_NOT_RECORDS_ONLY`). Skill item 2 is pinned by `RVS-NEW-PUSH-NEEDS-NEW-REVIEW`. |
| J3 | PASS | Records first: `REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED` until the policy audit is in the live head (tested; reviewer probe). Re-post rule: `posts on a descendant head whose listing holds only feature-folder paths`. Negatives: `refuses a code change after the review`, `refuses a mixed listing of one folder path and one src path`, `refuses a sibling-prefix folder path`. Skill item 3 is pinned by `RVS-RECORDS-FIRST`. |
| J4 | PASS | MainSync, RecordsPr, and PromotionPr each check the branch pattern and `main` base (`refuses the branch pair <Name>`), then the diff. MainSync: one parent, unverified first parent, second parent not on `origin/main`, overlapping sets, extra path, resolved conflict. RecordsPr: listing negatives. PromotionPr: listing negatives and a folder that exists at the merge base. Entry point: `exits 3 without a POST on the mixed diff of <Mode>` for each mode. "Main sync into an integration branch" is implemented as the integration-branch pull request into `main` whose head is that merge, as the skill states. |
| J5 | PASS | Item 9 in all four copies: "Anyone with write access, including any agent with `gh`, can post the status. It records a passing review and does not prove one." Pinned by `RVS-STATES-LIMIT` (4 of 4). The entry-point help states it too. |
| J6 | PASS | No path under `.github/` in the diff. No new required check: the ruleset still requires only `CI Required Gate`. The entry point writes no file, and no committed file stores a verdict. The new CI failure (F1) comes from an existing step, not from a new job. Skill item 8 is pinned by `RVS-NOT-CI`. |
| DoD1 | PASS | Each AC maps to named tests (plan tasks and the table above). Checked off. |
| DoD2 | Pending-CI | Local Windows runs pass; the Linux CI legs for this head had not finished, and the stage J pull request does not exist yet. Left unchecked. |
| DoD3 | PASS | Six new test files and two allow rows. Checked off. |
| DoD4 | PASS | Failure, usage, fact-limit, truncated-listing, and boundary rows. Checked off. |
| DoD5 | PASS | Four orchestrate skill copies; `core.json`; entry-point help. Checked off. |
| DoD6 | PASS | Coded stdout and stderr lines with distinct exit codes; no telemetry surface applies. Checked off. |
| DoD7 | FAIL | Format, lint, and test pass, but the repository check `check_quality_tiers` fails (F1) and stopped the CI Python job. Left unchecked. |

## Blocking Finding

- **F1, tier classification.** `.claude/lib/review-verdict` is a discovered project with no `quality-tiers.yml` entry (`QT008`); CI step `tier-classification` failed on `60e92a837`. No criterion's text depends on it, so no `[I]` or `[J]` criterion is unchecked. It blocks the green CI that the PR needs.

## Summary

- Stage J delivers J1 to J6, and the whole-item closing criteria I3 to I7 hold at this head.
- One blocking finding, F1. Non-blocking: CR1 to CR3 (code review) and CR6 carried from stage I for owner ratification.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 57 per file
- Remaining (unchecked): 0 per file
- Items remaining: none under `## Acceptance Criteria`. In `spec.md` `## Definition of Done`, 2 of 7 remain unchecked: "Behavior matches acceptance criteria in all documented environments" (pending-CI) and "Toolchain pass completed (format → lint → type-check → test)" (F1).

## Acceptance Criteria Check-off

- I3 to I7 and J1 to J6 were checked off by the executor in this stage. This review evaluates each as PASS at this head, so they stay checked in both `spec.md` and `user-story.md`; none was unchecked.
- This review checked off DoD1, DoD3, DoD4, DoD5, and DoD6 in `spec.md` `## Definition of Done`. DoD2 and DoD7 stay unchecked.
- No criterion was added, and no criterion text was changed.

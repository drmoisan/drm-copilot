# Code Review: Stage G, Less Evidence and the CI Cross-check (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `3f46b17db132e54ff32e20620097250c3077eca0`
- **Base:** `main`, merge base `992d6849455d54c942e69748b768c67d8cfd2fef` (equal to `origin/main`); trial merge clean
- **Scope:** full branch diff, 74 files, 23 commits; reduction commit `38517b6b3` after the withdrawal `13a1340ac`
- **Reviewer:** feature-review agent, 2026-11-08

## Executive Summary

- **The reduction now lands whole in one commit with its entry.**
  - `38517b6b3` carries the 53 reduction paths, entry `0009`, its README row, and its stored patch, and nothing else.
  - `13a1340ac` returns all 56 paths to their `main` state; the reviewer's diff over those paths against the merge base is empty.
  - The branch diff over those paths equals the `38517b6b3` diff byte for byte (same MD5).
  - The tree after `38517b6b3` differs from the pre-withdrawal tree `c3ac98596` by one sentence of `0009-less-evidence.md`.
  - The only branch changes outside those paths and the feature folder are the P1-T2 control cases, which add tests and reduce nothing.
- **The reduced and kept text is as K9 states.**
  - Every copy of the planning contract, planner, executor, feature-review workflow, and feature-review agent states one final-QC static artifact per language. No surface still states the per-step artifact.
  - The template drops the `Code Under Test` list and the section 9 listings and keeps the section 9 heading.
  - The Python repo-wide total is read from `Enforce Python coverage thresholds`, while the PowerShell and TypeScript repo-wide rows stay.
  - Counts of the baseline strings are equal at base and head (`Phase 0 baseline` 539/539, `regression on changed lines` 40/40, `Baseline Coverage Documented` 2/2, `No Coverage Regression` 2/2).
- **The CI cross-check is coherent end to end.**
  - Reviewer side: the workflow step 4 bullet, the feature-review agent step 5, the template section, and the `AGENTS.md` bullet.
  - Orchestrator side: item 11 of `## Concurrent Review and CI (review_mode)` in both orchestrate skills.
  - Guard side: the existing `REVIEW_GATE_NOT_PASSED` deny on a non-PASS last entry, pinned for the K7 shape by `RG-`/`RGC-ci-cross-check-synthetic-after-pass` and both `OCR-CROSS-CHECK-` cases.
- **The revert chain holds with `0009`.** The stored patch is byte-identical to a regeneration, `git apply -R --check` exits 0, and the in-memory chain over 9 entries is valid, in full and with `-StopBefore` for each stored-patch entry. An edit inside a `0009` hunk fails the chain, and an appended line does not.

No blocking finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/engineering/process-reductions/0009-less-evidence.md` | `## Summary`, final two sentences | CR1. The sentence "the whole reduction then landed with this entry in the one commit whose subject carries `reduction: 0009`" reads as if one commit carried the token. The branch log has three: `fe81a1118` (entry, row, and patch only, the split landing), `3681735fc` (one-sentence wording fix), and `38517b6b3` (the whole reduction). The withdrawal sentence names `c58c16243` but not `fe81a1118`. | Identify the landing commit by its subject text (`land less evidence whole with entry 0009`), and state that `fe81a1118` and `3681735fc` were the split entry and its fix, withdrawn by `13a1340ac`. The edit is under `docs/engineering/`, so making it in this PR requires a new review; a later stage's records commit is an alternative. | A reader who later checks commit separation from the branch log needs to find the landing commit without inspecting each candidate. The stored patch and revert steps are unaffected, so revertibility holds as is. | `git log --format='%h %s' 992d6849455d..HEAD`; `git show --stat fe81a1118 38517b6b3` |
| Minor | `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/other/stage-g-ledger-replay.2026-11-08T13-34.md`; `evidence/qa-gates/self-review.2026-11-08T13-38.md` | P3-T4 summary; one-commit row | CR2. Both records predate the re-landing. They name `fe81a1118` as the reduction commit and state that no earlier commit carries the token. At head, the commit that holds the reduction is `38517b6b3`, and two earlier commits carry the token. Read literally, the P3-T4 acceptance clause "no earlier commit on the branch carries the token" is not met at head. No feature-folder record covers the withdrawal and re-landing checks. | Add a feature-folder evidence note for the re-landing that records the checks this review made: tree equality with `c3ac98596` apart from the entry sentence, withdrawal equal to `main` on the 56 paths, landing diff equal to the branch diff, and patch regeneration. A feature-folder path does not stale this review. | The evidence trail should describe the final commit structure. This review's Executive Summary covers the gap for now. | `head -12` of the replay artifact; `git diff --stat c3ac98596 38517b6b3` |
| Minor | `docs/engineering/process-reductions/0008-g13-guideline-cutoff.md` | `## Summary`, `Merge commit:` | CR3. The line still reads `pending (PR #1123)`. PR #1123 merged as `e33635c14b55277d38caca52d6167b1d352f392e` at 2026-11-08T00:38Z. K8 says a back-fill is committed before the stage's review starts; the README allows the next stage or a final records commit. | Back-fill `Merge commit: e33635c14b55277d38caca52d6167b1d352f392e` in stage H or the final records commit, before that stage's review starts. | Keeps every merged entry pointing at its merge commit, as `0001` to `0007` do. | `gh pr view 1123 --json mergeCommit,mergedAt`; `grep "Merge commit" docs/engineering/process-reductions/0008-*.md` |
| Nit | `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` | `LEC-STATIC-ARTIFACT-<Id>` | CR4. The rows assert that `one final-QC static artifact per language` is present but not that `one final-QC artifact per QC command step` is absent. P2-T1's acceptance names that absence. A later edit that restored the per-step bullet beside the new one would stay green. | Add an absence assertion for the superseded bullet to the contract rows, as `LEC-SCOPE-LISTING-*` does for the section 9 subsections. | Pins the reduction itself, not only its replacement text. The reviewer confirmed the absence at head with `git grep`. | `git grep -c "one final-QC artifact per QC command step" HEAD` returns nothing |
| Nit | `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1` | `Get-EpicMergeGateReviewCaseRow`, row `ci-cross-check-synthetic-after-pass` | CR5. The row differs from the existing `last-remediation-after-earlier-pass` only by a `findings` array. The guard reads the verdict and head, so both rows exercise the same deny path. | None required. The row names the K7 shape and fails if the guard were changed to accept an entry by its findings. | Record only. | Diff of the helper |
| Nit | `.claude/agents/feature-review.md` and copies | `### Verification Procedure`, step 3 | CR6. The first bullet still says "Parse the repo-wide coverage percentage and report it" for every language. The new bullet says that for Python the CI result is recorded "instead of computing the repo-wide total". The two read as being in tension for Python. | In a later wording pass, scope the first bullet to languages other than Python, or say that the Python figure is reported alongside the CI row. | Keeps the reviewer instruction unambiguous. The FAIL rule for a local Python total below threshold is unchanged, so no gate weakens. | Diff of `.claude/agents/feature-review.md` |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest changed covered file is `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1` at 361 logical lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Commit structure after the crash

The orchestrator chose two new commits instead of a history rewrite, which matches the plan's Execution Terms ("No tag, no history rewrite"). The withdrawal reverses the stored patch, so it depends on the patch being current. The reviewer's regeneration shows it is, and the empty diff from the merge base to `13a1340ac` over the 56 paths shows the withdrawal is exact.

Because the repository merges pull requests with merge commits, `c58c16243` (the edits without the entry) and `fe81a1118` (the entry without the edits) will remain in `main`'s history. The entry discloses the first. CR1 covers the second.

### Skill and template text

- The `.github` workflow copy receives the step 4 and step 5 edits but not the Python-total bullet, because that copy carries no repo-wide row; the plan states this, and `LEC-PYTHON-TOTAL-*` is scoped accordingly.
- The "beneath the item worktree" clause on the step 5 absent-artifact bullet and the step 8 trigger aligns the skill with the merged coverage hooks. It adds a location requirement and removes none.
- Template line `Coverage expectation` still states 90% and 80% figures. That text predates this branch and is unchanged here; stage G only appended the Python-total sentence.

### Installed-asset lag (D9)

The MCP template resolver still serves the old template until a release is installed. The entry states this. This review followed the branch skill: it added `## CI Cross-check` and wrote the reduced section 9.

### Security and correctness

No hook, validator, or production code changed. The cross-check is a policy-level control under D10, and the orchestrate item 11 text says that a sequential run records the table and S9 alone gates it.

## Verification Performed

- `git fetch`, merge base, `merge-tree` (exit 0); `log` and `diff` over `992d6849455d..HEAD`.
- Re-landing checks: `diff --stat c3ac98596 38517b6b3`; diff of the merge base against `13a1340ac` on the 56 paths (empty); MD5 of the landing diff against the branch diff (equal); paths of the final main merge against every ledger entry (none).
- Stored-patch regeneration and `cmp` (identical); `git apply -R --check` (exit 0).
- In-memory ledger check and chain at head, full and `-StopBefore` for `0001`, `0006`, `0008`, `0009`; one mutant probe inside a `0009` hunk and one control.
- `git grep` of baseline strings at base and head, and of the superseded per-step text at head.
- Python CLI validation of `plan.2026-11-07T12-43.md` and `plan.2026-11-07T22-28.md`: both pass.
- Coverage artifact parsing for PowerShell and Python; logical line counts; `validate_evidence_locations` exit 0; `gh run view 42486253596` (in progress on this head).

## PR Readiness

**Ready to merge once CI is green.** No blocking finding. CI run 42486253596 on this head is read by the orchestrator at S9. CR1 to CR3 are optional follow-ups. CR2 is a feature-folder record and can be added without staling this review.

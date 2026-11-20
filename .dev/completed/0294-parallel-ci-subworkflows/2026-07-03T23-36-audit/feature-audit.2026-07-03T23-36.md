# Feature Audit: parallel-ci-subworkflows (#294)

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-ci-subworkflows-294`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `9a36e9b3dd9da626a33a45b2318165f5e49c69ec`)
- **Head branch/commit:** `feature/parallel-ci-subworkflows-294` (commit `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`)
- **Merge base:** `9a36e9b3dd9da626a33a45b2318165f5e49c69ec`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (collected 2026-07-03 19:30 UTC against the same
    base/head SHAs stated above; verified fresh — no refresh performed)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/**`
  - Additional evidence: live `gh api` queries against `drmoisan/drm-copilot` (workflow runs,
    check-runs, branch protection) executed directly by this audit, independent of the feature's
    own evidence files
- **Feature folder used:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/` (only
  active folder whose suffix matches issue `#294`)
- **Requirements source:** `spec.md` (Definition of Done + Seeded Test Conditions) and
  `user-story.md` (Acceptance Criteria), per work mode `full-feature`
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: full-feature`.
- **Scope note:** Independently re-confirmed via `git diff --stat 9a36e9b3d...5cd712c9d1` that the
  entire branch diff is confined to `.github/workflows/**` and this feature's own documentation
  folder; no `.py`/`.ts`/`.ps1`/`.cs` file is touched. This is not a versioned feature (no `v1/`/`v2/`
  folder structure).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — Definition of Done (9 items) and Seeded Test Conditions (5 items)
- `user-story.md` — Acceptance Criteria (6 items)

### From `user-story.md`

1. Each current `ci.yml` job (`quality-checks7`, `security-scan`, `docs-validation`, `build-check`,
   `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`) is extracted into its own callable
   reusable workflow file named `_<name>.yml` declaring both `workflow_call` and `workflow_dispatch`
   triggers.
2. A thin orchestrator workflow (retaining the `ci.yml` name and its existing
   `push`/`pull_request`/`workflow_dispatch` triggers) invokes each reusable workflow via
   `uses: ./.github/workflows/_<name>.yml` with no inline `steps:` and no artificial `needs:`
   between independent gates.
3. Any cross-job file dependency uses explicit `actions/upload-artifact`/`actions/download-artifact`;
   no job relies on implicit shared-filesystem state from another job.
4. Required-status-check names referenced by branch protection continue to resolve after the split
   (renamed or preserved check names are documented).
5. `.github/workflows/README.md` documents the new per-stage dispatch and the required-check
   rename procedure.
6. A green workflow run against the branch head is captured before merge, per the
   `modified-workflow-needs-green-run` policy rule for workflow-file changes.

### From `spec.md` — Definition of Done

7. Acceptance criteria documented and mapped to tests or demos.
8. Each of the seven jobs is extracted into its own `_<name>.yml` file declaring `workflow_call`
   and `workflow_dispatch`, with steps lifted verbatim.
9. `ci.yml` is rewritten as a thin orchestrator: seven `uses:` job bodies, no `needs:` between
   independent gates, no inline `steps:`.
10. `.github/workflows/README.md` is created, documenting per-stage dispatch and the
    required-status-check rename procedure.
11. Each new `_<name>.yml` file is independently exercised via its own `workflow_dispatch` and
    completes successfully.
12. `actionlint` and YAML-parse validation pass for all seven new files and the rewritten `ci.yml`.
13. A green workflow run against the branch head is captured as evidence, satisfying
    `modified-workflow-needs-green-run`.
14. Required-status-check names are read from the branch-head run's actual check-runs and branch
    protection is updated (or confirmed unchanged) to match, per the rename procedure.
15. No `src/` or `extensions/drm-copilot/src` files are touched; `publish-extension.yml` and
    `publish-mcp-npm.yml` are unmodified.

### From `spec.md` — Seeded Test Conditions

16. Each new `_<name>.yml` reusable workflow can be invoked standalone via
    `gh workflow run _<name>.yml` (`workflow_dispatch`) and completes successfully.
17. The rewritten `ci.yml` orchestrator triggers all seven reusable workflows without any `needs:`
    chain forcing sequential execution among independent gates.
18. `actionlint` and a YAML-parse check pass for every new/modified file under
    `.github/workflows/**`.
19. A workflow run against the branch head confirms all seven gates execute and reach a green
    status; this run also serves as the evidence required by `modified-workflow-needs-green-run`.
20. `gh api .../commits/{head_sha}/check-runs` against the branch-head run confirms the actual
    composed check-run names, and branch protection's required-status-check list is verified
    (and updated if needed) against those confirmed names.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven jobs extracted into `_<name>.yml` files with `workflow_call`+`workflow_dispatch` | **PASS** | All 7 `.github/workflows/_*.yml` files read directly; each declares both triggers, no `inputs:` | `git diff --stat`; direct file reads | Byte-for-byte step-content match confirmed against merge-base `ci.yml` for all 7 jobs. |
| 2 | Thin orchestrator, `uses:` only, no `needs:`/`steps:` | **PASS** | `.github/workflows/ci.yml` read directly: 31 lines, 7 job bodies each exactly one `uses:` line | `grep -n "needs:" .github/workflows/ci.yml` → 0; `grep -n "steps:" .github/workflows/ci.yml` → 0 | `on:` block confirmed byte-for-byte unchanged from merge-base. |
| 3 | Explicit upload/download artifact for cross-job dependencies; no implicit sharing | **PASS** | `_poshqc.yml` and `_shell-coverage.yml` each retain their pre-existing `actions/upload-artifact@v7` step unchanged; no new cross-job dependency introduced | Direct file read | Matches `spec.md`'s stated non-goal (no new artifact pairing). |
| 4 | Required-status-check names continue to resolve | **PASS** | `main` has no branch protection configured at all (verified live), so there is nothing that could fail to resolve; matches feature's own baseline/reconciliation exactly | `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` → 404 "Branch not protected" (reproduced live) | Confirmed identical to the feature's own P0-T8 baseline and P4-T10 reconciliation. |
| 5 | `README.md` documents per-stage dispatch + rename procedure | **PASS** | `.github/workflows/README.md` read directly: contains "Per-Stage Dispatch" table (7 rows) and a numbered 4-step "Required-Status-Check Rename Procedure" with literal `gh api` GET/PATCH templates | Direct file read | Also contains a "Scope of This Refactor" section per `plan.md` P3-T3. |
| 6 | Green workflow run against branch head captured before merge | **FAIL** | `evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md` documents a run at head SHA `574aaa2a...`, one commit behind the current head `5cd712c9...` | `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs` → `{"total_count":0,"check_runs":[]}` (reproduced live) | Checkbox reverted to `[ ]` in `user-story.md`; **Blocking**, routed to remediation. |
| 7 | AC documented and mapped to tests/demos | **PASS** | `user-story.md` contains an explicit "Acceptance Criteria" section; `spec.md` cross-references it | Direct file read | — |
| 8 | Seven jobs extracted, steps verbatim | **PASS** | Same evidence as criterion 1 | Same as criterion 1 | — |
| 9 | `ci.yml` rewritten as thin orchestrator | **PASS** | Same evidence as criterion 2 | Same as criterion 2 | — |
| 10 | `README.md` created | **PASS** | Same evidence as criterion 5 | Same as criterion 5 | — |
| 11 | Each new file independently exercised via its own `workflow_dispatch` | **PARTIAL** | `evidence/other/workflow-dispatch-substitution-note.2026-07-03T18-07.md` documents an HTTP 404 (file not registered on default branch) and a substituted `ci.yml` dispatch that exercises all 7 callees | `gh workflow run _quality-checks.yml --ref feature/parallel-ci-subworkflows-294` → HTTP 404 (per feature's own evidence, real platform constraint) | Literal criterion unmet pre-merge; substitution is reasonable and well-evidenced. Checkbox reverted to `[ ]` in `spec.md` with a reviewer note; not Blocking (self-resolves post-merge). |
| 12 | `actionlint`/YAML-parse pass for all 8 files | **PASS** | Independently reproduced | `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1 <8 files>` → exit 0, 0 errors | — |
| 13 | Green workflow run captured as evidence | **FAIL** | Same evidence as criterion 6 | Same as criterion 6 | Checkbox reverted to `[ ]` in `spec.md`; **Blocking**. |
| 14 | Required-status-check names read + branch protection updated/confirmed unchanged | **PASS** | Branch-protection state independently reconfirmed live and unchanged from baseline | `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` → 404 (reproduced live) | Kept checked in `spec.md`; the substantive claim (branch protection unaffected) is live-reconfirmed even though the underlying check-run name read was against the stale head. |
| 15 | No `src/`/`extensions/drm-copilot/src` files touched; publish workflows unmodified | **PASS** | `git diff --stat` against merge-base shows 0 files under `src/` or `extensions/drm-copilot/src`; `publish-extension.yml`/`publish-mcp-npm.yml` absent from diff | `git diff --stat 9a36e9b3d...5cd712c9d1` | — |
| 16 | Standalone `gh workflow run _<name>.yml` per file completes successfully | **PARTIAL** | Same evidence as criterion 11 | Same as criterion 11 | Checkbox reverted to `[ ]` in `spec.md`; not Blocking. |
| 17 | No `needs:` chain among the seven reusable workflows | **PASS** | Independently reproduced | `grep -n "needs:" .github/workflows/ci.yml` → 0 matches | Checkbox newly checked `[x]` in `spec.md` by this review (was previously unchecked despite being met). |
| 18 | `actionlint`/YAML-parse pass for every new/modified file | **PASS** | Same evidence as criterion 12 | Same as criterion 12 | Checkbox newly checked `[x]` in `spec.md` by this review (was previously unchecked despite being met). |
| 19 | Workflow run at branch head confirms all seven gates green; serves as `modified-workflow-needs-green-run` evidence | **FAIL** | Same evidence as criterion 6 | Same as criterion 6 | Checkbox reverted to `[ ]` in `spec.md`; **Blocking**. |
| 20 | `gh api .../check-runs` against branch-head run confirms names; branch protection verified/updated | **PARTIAL** | Names were read against the stale head SHA `574aaa2a...`, not the current head; branch-protection unaffected state independently reconfirmed live | `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs` → 0 runs | Checkbox reverted to `[ ]` in `spec.md`; not independently Blocking beyond criterion 6/13/19 (same root cause), since the workflow-file content driving the composed names has not changed between the stale and current head. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria (1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 14, 15, 17, 18)
- **PARTIAL:** 3 criteria (11, 16, 20)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 3 criteria (6, 13, 19)

Note: criteria 1/8, 2/9, 5/10, 12/18, and 6/13/19 are duplicate statements of the same underlying
requirement across `user-story.md` and `spec.md`; each is evaluated independently above because it
is a distinct checkbox in a distinct authoritative source file, per the acceptance-criteria-tracking
protocol ("When multiple AC source files exist, track checkboxes in each applicable file
independently").

**Top gaps preventing PASS:**

1. **Blocking:** No workflow run exists at the current branch head SHA
   (`5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`); the `modified-workflow-needs-green-run` policy rule
   requires one for any `.github/workflows/**` diff. (Criteria 6, 13, 19.)
2. **Non-blocking, self-resolving post-merge:** Standalone per-file `workflow_dispatch` of each new
   `_<name>.yml` was not literally exercised pre-merge, due to a genuine GitHub platform constraint
   (files must be registered on the default branch first). A reasonable substitution
   (`ci.yml` dispatch) was performed and evidenced instead. (Criteria 11, 16.)
3. **Non-blocking:** Composed check-run names were confirmed against a stale (one-commit-behind)
   head SHA rather than the current head; the underlying branch-protection state is unaffected and
   was independently reconfirmed live. (Criterion 20.)

**Recommended follow-up verification steps:**

1. Re-dispatch `ci.yml` (or await the branch's own `push`/`pull_request`-triggered run) against the
   current branch head, confirm all 11 job runs conclude `success`, and refresh
   `evidence/qa-gates/green-run-branch-head.*.md` with the new run URL and head SHA. Re-run
   `gh api .../check-runs` against that same head SHA to refresh the composed check-run name
   evidence (criterion 20) in the same pass.
2. If the branch head moves again before merge (e.g., another rebase or evidence-only commit),
   repeat step 1 once more against the final head SHA before opening/merging the PR.
3. Post-merge, verify each `_<name>.yml` is independently dispatchable via
   `gh workflow run _<name>.yml` (no `--ref` needed once registered on `main`), closing criteria
   11/16 definitively.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, PASS criteria were checked off (or left checked) in the
authoritative source files; FAIL and PARTIAL criteria were reverted to unchecked with a dated
reviewer note explaining the gap, since their prior checked state was not supported by verified
evidence at the current branch head (checked prematurely, several explicitly self-labeled "pending
executor/reviewer sign-off").

### AC Status Summary

- Source: `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/user-story.md` and
  `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/spec.md`
- Total AC items: 20 (6 in `user-story.md`, 9 Definition-of-Done + 5 Seeded-Test-Condition items in
  `spec.md`)
- Checked off (delivered/PASS): 14
- Remaining (unchecked — PARTIAL or FAIL): 6
- Items remaining:
  1. `user-story.md`: "A green workflow run against the branch head is captured before merge..." (FAIL)
  2. `spec.md` DoD: "Each new `_<name>.yml` file is independently exercised via its own `workflow_dispatch`..." (PARTIAL)
  3. `spec.md` DoD: "A green workflow run against the branch head is captured as evidence..." (FAIL)
  4. `spec.md` Seeded: "Each new `_<name>.yml` reusable workflow can be invoked standalone via `gh workflow run _<name>.yml`..." (PARTIAL)
  5. `spec.md` Seeded: "A workflow run against the branch head confirms all seven gates execute..." (FAIL)
  6. `spec.md` Seeded: "`gh api .../commits/{head_sha}/check-runs` against the branch-head run confirms..." (PARTIAL)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `user-story.md` | 6 | 5 | 1 | Checkbox-backed; item 6 reverted this review with a dated correction note. |
| `spec.md` (Definition of Done) | 9 | 7 | 2 | Checkbox-backed; items 5 and 7 reverted this review with dated correction notes. |
| `spec.md` (Seeded Test Conditions) | 5 | 2 | 3 | Checkbox-backed; items 2 and 3 newly checked this review (independently verified PASS, previously left unchecked despite being met); items 1, 4, 5 reverted/left unchecked with dated correction notes. |

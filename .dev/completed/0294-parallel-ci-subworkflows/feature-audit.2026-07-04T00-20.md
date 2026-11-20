# Feature Audit: parallel-ci-subworkflows (#294)

**Audit Date:** 2026-07-04T00-20 (R4 — re-audit following remediation)
**Feature Folder:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-ci-subworkflows-294`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit following remediation cycle (prior: `feature-audit.2026-07-03T23-36.md`)

---

## Scope and Baseline

- **Base branch:** `main` (commit `9a36e9b3dd9da626a33a45b2318165f5e49c69ec`, per
  `artifacts/pr_context.summary.txt` resolved base)
- **Head branch/commit:** `feature/parallel-ci-subworkflows-294`
  (`da829efc32af6f09a1339bcbfe226d759ddf26cf`) — independently confirmed as the literal branch tip
  via `git rev-parse HEAD` and `git log -1`; working tree clean (`git status`).
- **Merge base:** `9a36e9b3dd9da626a33a45b2318165f5e49c69ec`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt` (collected
    against base `main` immediately before this delegation)
  - Feature evidence: `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/**`
  - Prior audit cycle: `feature-audit.2026-07-03T23-36.md`,
    `remediation-inputs.2026-07-03T23-36.md`, `remediation-plan.2026-07-03T23-36.md`
  - Additional evidence: live `gh api`/`gh run view` queries against `drmoisan/drm-copilot`
    executed directly by this audit, independent of any evidence file's claim
- **Feature folder used:** `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/` (only
  active folder whose suffix matches issue `#294`)
- **Requirements source:** `spec.md` (Definition of Done + Seeded Test Conditions) and
  `user-story.md` (Acceptance Criteria), per work mode `full-feature`
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: full-feature`.
- **Scope note:** Independently re-confirmed via
  `git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec..da829efc32af6f09a1339bcbfe226d759ddf26cf`
  that the entire branch diff (36 files) is confined to `.github/workflows/**` (8 files) and this
  feature's own documentation folder (28 files); no `.py`/`.ts`/`.ps1`/`.cs` file is touched. This
  is not a versioned feature (no `v1/`/`v2/` folder structure).

---

## What Changed Since the Prior Audit Cycle (`feature-audit.2026-07-03T23-36.md`)

No `.github/workflows/**` YAML content changed. Three additional documentation/evidence-only
commits landed:

1. **`cb43997`** — docs(review): record feature-review findings and remediation plan for 294
2. **`5a428db`** — docs(294): refresh green-run evidence after remediation cycle
3. **`da829ef`** — docs(294): record remediation Phase 4/5 scope-guard and actionlint (current head)

`git diff --stat cb43997..da829ef -- .github/workflows/` returns empty output (0 files),
independently confirming zero workflow-YAML drift across this remediation window.

---

## Independent Live Re-Verification (Performed Directly by This Audit)

1. `git rev-parse HEAD` → `da829efc32af6f09a1339bcbfe226d759ddf26cf`; `git log -1` confirms this
   is the tip with no newer commit; `git status` shows a clean working tree.
2. `gh api repos/drmoisan/drm-copilot/commits/da829efc32af6f09a1339bcbfe226d759ddf26cf/check-runs`
   → `"total_count": 11`, all 11 entries `"conclusion": "success"`, `"head_sha"` an exact match to
   the current head. Job names observed: `docs-validation / Documentation Validation`,
   `quality-checks7 / Code Quality & Tests (3.10/3.11/3.12/3.13)`, `security-scan / Security
   Scanning`, `build-check / Build Package`, `poshqc / PowerShell QC`, `shell-coverage / Shell
   Coverage (Bats + kcov)`, `drm-copilot-extension-tests / drm-copilot Extension Tests
   (ubuntu-latest/windows-latest)`.
3. `gh run view 28688875940 --json headSha,status,conclusion,jobs,workflowName` → cross-confirms
   the same run: `headSha: da829efc32af6f09a1339bcbfe226d759ddf26cf`, `status: completed`,
   `conclusion: success`, `workflowName: CI`, all 11 jobs `conclusion: success`.
4. `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` → `404
   "Branch not protected"`, unchanged from baseline.
5. `gh api repos/drmoisan/drm-copilot/actions/workflows` → confirms the 7 new `_<name>.yml` files
   are not yet registered as independently dispatchable workflows (only `ci.yml`,
   `_npm-audit-gate.yml`, `npm-audit-gate.yml`, and the two publish workflows are registered).
6. `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` → 0 errors, exit 0.
7. `grep -n "needs:" .github/workflows/ci.yml` and `grep -n "steps:" .github/workflows/ci.yml` →
   both 0 matches.
8. `python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0, no violations.

This satisfies the `modified-workflow-needs-green-run` policy rule ("a workflow run whose head SHA
matches the current branch head and whose conclusion is success") at the branch's literal, final
current head. This resolves the sole Blocking finding from `feature-audit.2026-07-03T23-36.md`
(criteria 6/13/19 below).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — Definition of Done (9 items) and Seeded Test Conditions (5 items)
- `user-story.md` — Acceptance Criteria (6 items)

(Same 20-item inventory as the prior audit cycle; reproduced here for completeness.)

### From `user-story.md`

1. Each current `ci.yml` job extracted into its own `_<name>.yml` file declaring both triggers.
2. Thin orchestrator workflow invokes each reusable workflow via `uses:` with no inline `steps:` /
   no artificial `needs:`.
3. Explicit `actions/upload-artifact`/`actions/download-artifact` for cross-job dependencies.
4. Required-status-check names continue to resolve after the split.
5. `.github/workflows/README.md` documents per-stage dispatch and rename procedure.
6. A green workflow run against the branch head is captured before merge.

### From `spec.md` — Definition of Done

7. Acceptance criteria documented and mapped to tests or demos.
8. Seven jobs extracted, steps lifted verbatim.
9. `ci.yml` rewritten as thin orchestrator.
10. `README.md` created.
11. Each new `_<name>.yml` independently exercised via standalone `workflow_dispatch`.
12. `actionlint`/YAML-parse pass for all seven new files and rewritten `ci.yml`.
13. Green workflow run captured as evidence, satisfying `modified-workflow-needs-green-run`.
14. Required-status-check names read + branch protection updated/confirmed unchanged.
15. No `src/`/`extensions/drm-copilot/src` files touched; publish workflows unmodified.

### From `spec.md` — Seeded Test Conditions

16. Standalone `gh workflow run _<name>.yml` per file completes successfully.
17. No `needs:` chain among the seven reusable workflows.
18. `actionlint`/YAML-parse pass for every new/modified file.
19. Workflow run at branch head confirms all seven gates green; serves as
    `modified-workflow-needs-green-run` evidence.
20. `gh api .../check-runs` against branch-head run confirms names; branch protection
    verified/updated.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Seven jobs extracted with both triggers | **PASS** | All 7 `.github/workflows/_*.yml` files unchanged since prior audit; re-confirmed via `git diff --stat cb43997..da829ef -- .github/workflows/` → empty | `git diff --stat` | Unchanged from prior cycle. |
| 2 | Thin orchestrator, `uses:` only, no `needs:`/`steps:` | **PASS** | `.github/workflows/ci.yml` re-read directly: 30 lines, 7 one-line job bodies | `grep -n "needs:"`/`grep -n "steps:"` → 0/0 (reproduced) | Unchanged. |
| 3 | Explicit upload/download for cross-job dependencies | **PASS** | `_poshqc.yml`/`_shell-coverage.yml` retain pre-existing `actions/upload-artifact@v7` steps unchanged | Direct file read | Unchanged. |
| 4 | Required-status-check names continue to resolve | **PASS** | `main` has no branch protection configured (reproduced live) | `gh api .../protection/required_status_checks` → 404 (reproduced) | Unchanged. |
| 5 | `README.md` documents dispatch + rename procedure | **PASS** | `.github/workflows/README.md` re-read directly, unchanged | Direct file read | Unchanged. |
| 6 | Green workflow run against branch head captured before merge | **PASS (was FAIL)** | Live `gh api .../commits/da829efc.../check-runs` returns 11/11 `success` at the exact current head; cross-confirmed via `gh run view 28688875940` | Reproduced live in this audit | **Checked off `[x]` in `user-story.md` by this audit** — prior Blocking finding resolved. |
| 7 | AC documented and mapped to tests/demos | **PASS** | Unchanged | Direct file read | — |
| 8 | Seven jobs extracted, steps verbatim | **PASS** | Same as criterion 1 | Same | — |
| 9 | `ci.yml` rewritten as thin orchestrator | **PASS** | Same as criterion 2 | Same | — |
| 10 | `README.md` created | **PASS** | Same as criterion 5 | Same | — |
| 11 | Each new file independently exercised via standalone `workflow_dispatch` | **PARTIAL (unchanged)** | `gh api repos/drmoisan/drm-copilot/actions/workflows` re-confirms none of the 7 `_<name>.yml` files are registered as dispatchable workflows yet | Reproduced live in this audit | Genuine, unchanged GitHub platform constraint (files must be on default branch). Left unchecked; self-resolves post-merge. |
| 12 | `actionlint`/YAML-parse pass for all 8 files | **PASS** | Reproduced directly | `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1` → exit 0 | Unchanged. |
| 13 | Green workflow run captured as evidence | **PASS (was FAIL)** | Same evidence as criterion 6 | Same | **Checked off `[x]` in `spec.md` by this audit.** |
| 14 | Required-status-check names read + branch protection confirmed | **PASS** | Branch-protection state re-confirmed live and unchanged | `gh api .../protection/required_status_checks` → 404 (reproduced) | Unchanged, still checked. |
| 15 | No `src/`/`extensions/drm-copilot/src` touched; publish workflows unmodified | **PASS** | `git diff --stat` against merge-base shows 0 files in those paths | `git diff --stat 9a36e9b3d...da829efc` | Unchanged. |
| 16 | Standalone `gh workflow run _<name>.yml` per file | **PARTIAL (unchanged)** | Same evidence as criterion 11 | Same | Left unchecked; non-blocking. |
| 17 | No `needs:` chain among reusable workflows | **PASS** | Reproduced | `grep -n "needs:" .github/workflows/ci.yml` → 0 | Unchanged, still checked. |
| 18 | `actionlint`/YAML-parse pass for every file | **PASS** | Same as criterion 12 | Same | Unchanged, still checked. |
| 19 | Workflow run at branch head confirms all seven gates green | **PASS (was FAIL)** | Same evidence as criterion 6 | Same | **Checked off `[x]` in `spec.md` by this audit.** |
| 20 | `gh api .../check-runs` confirms names + branch protection verified | **PASS (was PARTIAL)** | Live `gh api .../commits/da829efc.../check-runs` at the exact current head confirms 11 check-run name strings; branch protection re-confirmed unaffected | Same live queries as criterion 6/14 | **Checked off `[x]` in `spec.md` by this audit** — now verified against the literal current head, not a stale one. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 18 criteria (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 17, 18, 19, 20)
- **PARTIAL:** 2 criteria (11, 16)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Note: criteria 1/8, 2/9, 5/10, 12/18, and 6/13/19/20 are duplicate or closely related statements of
the same underlying requirement across `user-story.md` and `spec.md`; each is evaluated
independently above because it is a distinct checkbox in a distinct authoritative source file, per
the acceptance-criteria-tracking protocol.

**Remaining gap (non-blocking):**

1. **Non-blocking, self-resolving post-merge:** Standalone per-file `workflow_dispatch` of each new
   `_<name>.yml` cannot be exercised pre-merge, due to a genuine, independently re-confirmed GitHub
   platform constraint (files must be registered on the default branch first). (Criteria 11, 16.)

**Resolved since prior audit cycle:**

1. The `modified-workflow-needs-green-run` policy rule (criteria 6, 13, 19) — previously FAIL due
   to stale evidence — is now PASS, independently re-verified at the branch's literal current head.
2. Criterion 20 (check-run names + branch protection) — previously PARTIAL because the read was
   against a stale head — is now PASS, re-verified against the literal current head.

**Recommended follow-up verification steps:**

1. Post-merge, verify each `_<name>.yml` is independently dispatchable via
   `gh workflow run _<name>.yml` (no `--ref` needed once registered on `main`), closing criteria
   11/16 definitively. This is explicitly non-blocking for this PR.
2. Optionally refresh the feature's internal evidence files
   (`evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`,
   `evidence/qa-gates/scope-guard-remediation.2026-07-03T23-36.md`) in place to cite the run
   confirmed by this audit (id `28688875940`, head `da829efc...`) for internal consistency; not
   required for merge readiness since this audit's own live re-verification is authoritative.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, this audit independently re-verified the branch's
literal current head and found a qualifying green workflow run. Criteria 6, 13, 19, and 20 were
therefore checked off `[x]` in `user-story.md` and `spec.md` in this audit pass, each citing this
audit's own live `gh api`/`gh run view` evidence (not the feature's stale internal evidence files).
Criteria 11 and 16 remain unchecked, correctly, per the evidence-before-check-off rule — no
qualifying evidence exists (or can exist pre-merge) for standalone per-file dispatch.

### AC Status Summary

- Source: `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/user-story.md` and
  `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/spec.md`
- Total AC items: 20 (6 in `user-story.md`, 9 Definition-of-Done + 5 Seeded-Test-Condition items in
  `spec.md`)
- Checked off (delivered/PASS): 18
- Remaining (unchecked — PARTIAL): 2
- Items remaining:
  1. `spec.md` DoD: "Each new `_<name>.yml` file is independently exercised via its own
     `workflow_dispatch`..." (PARTIAL — non-blocking, platform constraint)
  2. `spec.md` Seeded: "Each new `_<name>.yml` reusable workflow can be invoked standalone via
     `gh workflow run _<name>.yml`..." (PARTIAL — non-blocking, platform constraint)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `user-story.md` | 6 | 6 | 0 | Item 6 (green run) newly checked `[x]` this audit, citing live re-verification at head `da829efc...`. |
| `spec.md` (Definition of Done) | 9 | 8 | 1 | Item "green run captured as evidence" newly checked `[x]` this audit; item "standalone workflow_dispatch" remains unchecked (non-blocking). |
| `spec.md` (Seeded Test Conditions) | 5 | 4 | 1 | Items "workflow run confirms all seven gates green" and "check-runs confirms names" newly checked `[x]` this audit; item "standalone `gh workflow run`" remains unchecked (non-blocking). |

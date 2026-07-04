# Feature Audit: Automate Full Release Flow (#291)

---

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-automate-full-release-flow-291`
**Base Branch:** `main`
**Head Branch:** `feature/automate-full-release-flow-291`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved base ref `origin/main @ 9a5de0c549327f2e47521cae51d2514e8b28b54b`)
- **Head branch/commit:** `feature/automate-full-release-flow-291 @ 6cb1f56cf7e7254d4b9b8985de1c252ec3312942`
- **Merge base:** `406a0c1f662d0eb6b669ea7d16b57925a0257859`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-03-automate-full-release-flow-291/evidence/**`
  - Additional evidence: local review commands listed in the evaluation table
- **Feature folder used:** `docs/features/active/2026-07-03-automate-full-release-flow-291`
- **Requirements source:** `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md`
- **Work mode resolution note:** `issue.md` explicitly contains `- Work Mode: minor-audit`, so only the explicit `## Acceptance Criteria` section in `issue.md` is authoritative.
- **Scope note:** The review audited the full branch diff against the resolved base branch. `spec.md` and `user-story.md` are absent and are not required for this minor-audit review.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md` - only authoritative source

### Acceptance criteria

1. A new guarded PowerShell script automates the full release flow by wrapping the existing full release PR and release tag-push scripts.
2. The script waits for GitHub pull request checks using `gh`, stops before merge/tag push when checks fail or remain blocked, and supports a safe confirmation model.
3. A VS Code task exposes the automated release flow, and Pester tests cover success, failed-check, dirty-worktree, and merge-blocked paths without invoking live `git`, `gh`, or `npm`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | A new guarded PowerShell script automates the full release flow by wrapping the existing full release PR and release tag-push scripts. | PASS | `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` defines `Invoke-FullReleaseFlowGuarded`, validates `ConfirmToken`, calls `Invoke-FullRelease.ps1`, waits through `gh`, merges through `gh`, checks out and pulls `main`, then calls `Invoke-ReleaseTagPush.ps1`. | `git diff --name-status 406a0c1f662d0eb6b669ea7d16b57925a0257859...HEAD`; code inspection of `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; `mcp__drm-copilot__run_poshqc_test workspace_root=C:\Users\DanMoisan\repos\drm-copilot` | Existing release scripts remain authoritative for version bumping and tag creation. |
| 2 | The script waits for GitHub pull request checks using `gh`, stops before merge/tag push when checks fail or remain blocked, and supports a safe confirmation model. | PASS | `Invoke-FullReleaseFlow.ps1` calls `gh pr checks <pr> --watch`, returns before merge and tag push on non-zero check result, and requires exact confirmation token `yes`. Tests cover failed checks and confirmation rejection. | `Select-String -Path scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -Pattern 'pr checks|ConfirmToken|pr merge|Invoke-ReleaseTagPush'`; focused Pester evidence in `evidence/regression-testing/invoke-full-release-flow-pester.2026-07-03T17-15.md` | Permanently pending checks are delegated to GitHub CLI `--watch`; the tested blocked path is a non-zero checks result. |
| 3 | A VS Code task exposes the automated release flow, and Pester tests cover success, failed-check, dirty-worktree, and merge-blocked paths without invoking live `git`, `gh`, or `npm`. | PASS | `.vscode/tasks.json` adds `AutomatedFullReleaseFlowConfirm` and `Release: Automate Full Release Flow`; Pester tests mock `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-ChildPowerShellScript`; focused evidence records 25 tests passed. | `poetry run python -m scripts.dev_tools.validate_json`; `Select-String -Path .vscode/tasks.json -Pattern 'AutomatedFullReleaseFlowConfirm|Release: Automate Full Release Flow|Invoke-FullReleaseFlow.ps1'`; focused Pester evidence | The final repository Pester run also reports 966 tests, 0 failures, and 0 errors. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 3 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. During PR authoring or CI review, verify live GitHub metadata if auto-close classification is required, because the PR context summary records GitHub CLI metadata as unavailable during collection.
2. During first manual release use, observe the live `gh pr checks --watch` behavior for any permanently pending check state and record follow-up hardening only if the CLI does not return a blocking exit code.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, all three authoritative checkbox criteria in `issue.md` are already checked and were evaluated as PASS in this audit. No source-file checkbox changes were needed during this review.

### AC Status Summary

- Source: `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md`
- Total AC items: 3
- Checked off (delivered): 3
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md` | 3 | 3 | 0 | Checkbox-backed and authoritative for `minor-audit`. |

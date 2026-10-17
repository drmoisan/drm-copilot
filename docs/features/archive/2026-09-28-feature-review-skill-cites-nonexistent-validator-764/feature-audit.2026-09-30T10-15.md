# Feature Audit: feature-review skill nonexistent validator citation (#764)

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764`
**Base Branch:** `main`
**Head Branch:** `bug/feature-review-skill-cites-nonexistent-validator-764`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `2b0121abf74f5862a3d12929d833504668941156`)
- **Head branch/commit:** `bug/feature-review-skill-cites-nonexistent-validator-764` (commit `3e262233727b2cd602cbe958608f7c1ba3290d83`)
- **Merge base:** `2b0121abf74f5862a3d12929d833504668941156`
- **Evidence sources:**
  - Primary: `git diff origin/main` (17 files; PR context artifacts were not regenerated because the caller specified the diff command)
  - Feature evidence: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/**`
  - Additional evidence: reviewer-run `git grep`, `git diff --numstat`, and `git diff --name-only`
- **Feature folder used:** `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: minor-audit`; `spec.md` and `user-story.md` are not present and not used.
- **Scope note:** Full branch diff against `origin/main`. No PR exists at review time, so CI status is unavailable and is not an acceptance criterion here.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md` - only source

### Acceptance criteria

1. AC-1: `.claude/skills/feature-review-workflow/SKILL.md` no longer cites the validator; the outcome bullet ends after "route it through the standard remediation handoff." and the rest of the rule text is unchanged.
2. AC-2: The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` receives the identical edit, and `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
3. AC-3: No file outside `docs/` cites `Test-ModifiedWorkflowNeedsGreenRun`, including the `.agents/`, `.github/`, and `codex-and-agents-customizations` copies.
4. AC-4: No new validator script is added, and `test_skill_bundle_contract_repo.py` and `test_push_down_claude_pack_manifest_completeness.py` pass.
5. AC-5: `scripts/dev_tools/push_down_claude_customizations.py` and `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` are absent from the branch diff against `origin/main`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 citation removed from repository skill, rest unchanged | PASS | Reviewer diff shows only line 75 changed; the outcome bullet now ends at "standard remediation handoff."; numstat `1 1`; `edit-diff.2026-09-30T05-20.md` | `git diff origin/main -- .claude/skills/feature-review-workflow/SKILL.md`; `git diff --numstat origin/main -- .claude extensions` (run by reviewer) | Hunk shows no change to lines 70 to 74, 76, 77 |
| 2 | AC-2 identical edit in bundled mirror and parity test passes | PASS | Mirror diff has the same blob transition `dad9f463..8f6d40c4` as the repository skill; `targeted-parity-test.2026-09-30T05-20.md` (1 passed) and `final-pytest.2026-09-30T05-20.md` (21 passed) | `git diff origin/main -- extensions/.../SKILL.md` (run by reviewer); `poetry run pytest ...::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (recorded, not rerun) | Pytest result relies on executor evidence |
| 3 | AC-3 no citation outside `docs/` | PASS | `git grep -n "Test-ModifiedWorkflowNeedsGreenRun" -- ':!docs'` printed no output when run by the reviewer; `final-citation-grep.2026-09-30T05-20.md` records exit 1 versus 2 matches at baseline | `git grep -n "Test-ModifiedWorkflowNeedsGreenRun" -- ':!docs'` (run by reviewer) | Covers all skill copies |
| 4 | AC-4 no new validator; two named tests pass | PASS | Non-docs diff contains only the two SKILL.md files, and no path under `scripts/`; `final-pytest.2026-09-30T05-20.md` records 21 passed, 0 failed, including both named files; `final-toolchain-applicability.2026-09-30T05-20.md` records no untracked file under `scripts` | `git diff --name-only origin/main` (run by reviewer); pytest recorded, not rerun | Pytest result relies on executor evidence |
| 5 | AC-5 ROOT_FOLDERS files absent from diff | PASS | `git diff --name-only origin/main` lists neither file; `baseline-rootfolders-diff` and `final-rootfolders-diff` artifacts empty | `git diff --name-only origin/main` (run by reviewer) | None |

---

## Summary

**Overall Feature Readiness:** PASS. All five criteria are supported by evidence; two rely on recorded executor pytest results that this review did not rerun.

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

1. None blocking. Residual notes: plan acceptance wording uses the invalid `git grep -nxF`, disclosed and worked around in `edit-diff.2026-09-30T05-20.md`; evidence filenames and internal `Timestamp:` fields differ in stamp; `issue.md` `Status:` header cites a stale folder path.

**Recommended follow-up verification steps:**

1. Open the PR and confirm required CI jobs succeed, including the bundle-parity tests in CI.
2. Optionally correct the `issue.md` `Status:` path and the plan `git grep -nxF` wording.

### Plan task P2-T5 (reduced audit)

- Phase 0 artifacts (6 of 6: `phase0-instructions-read.md`, `minor-audit-preconditions`, `baseline-pytest`, `baseline-citation-grep`, `baseline-rootfolders-diff`, `baseline-code-source-diff`) exist on disk.
- Phase 1 artifacts (2 of 2: `edit-diff`, `targeted-parity-test`) exist on disk.
- Phase 2 artifacts (4 of 4: `final-pytest`, `final-citation-grep`, `final-rootfolders-diff`, `final-toolchain-applicability`) exist on disk.
- All 12 artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, except `phase0-instructions-read.md`, which carries `Timestamp:`, `Policy Order:`, and the files-read list, exactly as P0-T1 requires. `final-citation-grep` also carries `ExpectedExitCode: 1`.
- Checklist state agrees with evidence: every checked task P0-T1 through P2-T4 and P2-T6 through P2-T10 has its artifact; no contradiction found. The only unchecked box in the plan is P2-T5 itself.
- Result: no missing artifact and no checklist/evidence contradiction. P2-T5 can be ticked.

---

## Acceptance Criteria Check-off

- AC-1 through AC-5 are already `[x]` in `issue.md`; the evidence inspected supports all five, so no change was needed.
- No source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 5 | 5 | 0 | Checkbox-backed |

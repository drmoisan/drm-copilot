# Feature Audit: potential-to-issue-auto-resolve-prompts (#98)

**Audit Date:** 2026-03-14  
**Base Branch:** `feature/expose-placeholder-commands-92`  
**Feature Folder:** `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98`

## Scope and baseline

- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/evidence/**`
- **Requirements source:** `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md`
- **Work mode:** `minor-audit` (resolved from `issue.md`)
- **Note:** The refreshed PR summary shows no commit-range diff because the reviewed implementation is currently local working-tree state; the appendix’s unstaged diff is the authoritative baseline for the code under review.

## Acceptance criteria inventory (authoritative for this run)

`issue.md` does not contain a dedicated `## Acceptance Criteria` checkbox section, so the authoritative criteria for this audit were derived from `## Expected Behavior` plus the validated behavior bullets in `## Proposed Fix / Validation Ideas`:

1. `drm-copilot: Potential To Issue` auto-resolves the active `docs/features/potential/*.md` editor path instead of always opening the picker.
2. After auto-resolution, the command still prompts for promotion type and forwards the selection as `--promotion-type`.
3. After auto-resolution, the command still prompts for work mode and forwards the selection as `--work-mode`.
4. When there is no valid active potential markdown file, the command still falls back cleanly to the file picker.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Auto-resolve the active potential markdown file. | PASS | `extensions/drm-copilot/src/extension.ts:293-306`; test `extension.potential-to-issue.test.ts:200`; fail-before artifact `p1-t5-potential-to-issue.expect-fail...md`; pass-after artifact `p1-t10-potential-to-issue.pass...md`. | `npm --prefix extensions/drm-copilot run test:unit`; in-session rerun: `Push-Location extensions/drm-copilot; npm run test:unit; Pop-Location` | The handler now reuses the active editor path before any picker fallback. |
| 2. Preserve the promotion-type quick pick after auto-resolution. | PASS | `extensions/drm-copilot/test/extension.potential-to-issue.test.ts:219`; pass-after artifact names the promotion-type quick-pick scenario. | same Jest commands as above | The test asserts the first quick-pick invocation and the forwarded `--promotion-type` argv. |
| 3. Preserve the work-mode quick pick after auto-resolution. | PASS | `extensions/drm-copilot/test/extension.potential-to-issue.test.ts:244`; pass-after artifact names the work-mode quick-pick scenario. | same Jest commands as above | The test asserts the second quick-pick invocation and the forwarded `--work-mode` argv. |
| 4. Keep clean picker fallback when no valid active file is resolved. | PASS | Existing fallback test remains at `extension.potential-to-issue.test.ts:274`; `p1-t10-potential-to-issue.pass...md` output summary explicitly names picker fallback as passed. | same Jest commands as above | Automated evidence covers the intended fallback behavior. |

## Summary

**Overall feature readiness:** PASS

The reviewed implementation satisfies the behavior defined in `issue.md` and is supported by baseline, fail-before, pass-after, and final QA evidence. The remaining merge-readiness gap is branch-state/process related rather than a missed requirement.

**Recommended follow-up verification steps:**
- Optional but nice: capture one short destination-workspace manual verification note if maintainers want parity with the issue’s validation ideas.
- Required for mergeable branch state: commit/push the current working-tree diff and refresh `pr_context` artifacts.

## Acceptance Criteria Status
- Source: `docs/features/active/2026-03-14-potential-to-issue-auto-resolve-prompts-98/issue.md`
- Total AC items: 4 (derived from prose requirements)
- Checked off (delivered): 0 source-file checkbox updates performed
- Remaining (unchecked): 0 authoritative criteria remain unmet
- Items remaining: None. `issue.md` uses prose requirements under `## Expected Behavior` rather than a dedicated acceptance-criteria checkbox list, so no source-file check-off was performed.

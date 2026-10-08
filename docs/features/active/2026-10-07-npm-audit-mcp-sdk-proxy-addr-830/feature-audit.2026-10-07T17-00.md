# Feature Audit: npm audit SDK and proxy-addr remediation (#830)

**Audit Date:** 2026-10-07
**Feature Folder:** `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-audit-mcp-sdk-proxy-addr`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
- **Head commit:** `f744baf09e08d0045e6d3803fe8408c6c378ab03`
- **Evidence sources:**
  - `git diff origin/main...HEAD` of the six manifests and lockfiles (run by reviewer)
  - Feature evidence: `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/**`, including `qa-gates/audit-handoff.2026-10-07T16-20.md`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: minor-audit`; `spec.md` and `user-story.md` are not present and not used.
- **Scope note:** Full branch diff against `origin/main`. No PR exists, so CI status is unavailable. The pre-existing root `format:check` failure on `tests/fixtures/**` JSON is excluded from AC-3 by the criterion's own text.

---

## Acceptance Criteria Inventory

**Authoritative AC source:** `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/issue.md`

1. AC-1: manifests and lockfiles updated (SDK `^1.31.0`, `proxy-addr` override `^2.0.8`, protected dependencies unchanged, lockfiles regenerated).
2. AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages; `npm ls` shows only patched versions.
3. AC-3: toolchains pass with coverage not below baseline (root format failure on fixtures excluded), mcp-server build passes, PR CI green including Publish to Marketplace.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 manifests, override, protected deps, lockfiles | PASS | Manifest diff shows `"@modelcontextprotocol/sdk": "^1.31.0"` and `"proxy-addr": "^2.0.8"` after `fast-uri` in all three `package.json` files; no `@types/vscode`, `@types/node`, or `typescript-eslint` line in the diff; all three lockfile diffs update the SDK entry (1.30.1 to 1.32.1), the `proxy-addr` entry (2.0.7 to 2.0.8), and the root range line only | `git diff origin/main...HEAD -- package.json extensions/drm-copilot/package.json packages/mcp-server/package.json`; `git diff origin/main...HEAD -- '*package-lock.json'` (run by reviewer); `evidence/qa-gates/protected-deps-manifest-diff.2026-10-07T15-30.md`, `scope-check.2026-10-07T15-30.md` | Existing `fast-uri` and `brace-expansion` overrides remain. Non-docs diff is exactly six files |
| 2 | AC-2 audit exits 0, patched versions only | PASS | `final-audit-root/extension/mcp-server.2026-10-07T16-10.md`: EXIT_CODE 0, "found 0 vulnerabilities". `final-ls-*.2026-10-07T16-10.md`: SDK 1.32.1 and proxy-addr 2.0.8 only, via express 5.2.1; matches lockfile diffs | `npx --yes npm@11 audit --audit-level=moderate` and `npx --yes npm@11 ls @modelcontextprotocol/sdk proxy-addr --all` (recorded, not rerun by reviewer) | Audit result relies on executor evidence; the advisory database was not re-queried by the reviewer |
| 3 | AC-3 toolchains, coverage, build, PR CI | PASS | CI update 2026-10-07T14:40Z: PR #831 head cf286317d2958cddeff345ecf0cf4fc2733be18e, all 26 checks pass (0 pending, 0 failing), including Publish to Marketplace (run 37636708119) and the three NPM Audit Gate jobs (run 37636709354); see `evidence/qa-gates/ac3-ci.2026-10-07T14-40.md`. Local portion: extension format, lint, typecheck, tests exit 0 (3808 passed); root lint, typecheck, tests exit 0 (3825 passed); coverage delta 0 (root 97.68% lines / 91.15% branches, extension 97.09% / 91.37%); mcp-server build exit 0. Root `format:check` exit 2 with body identical to baseline (`root-format-check-diff.2026-10-07T16-00.md`), excluded per AC text. PR CI, including Publish to Marketplace, is green | `evidence/qa-gates/*-2026-10-07T16-00.md`, `coverage-delta.2026-10-07T16-15.md`, `gh pr checks 831 --repo drmoisan/drm-copilot` | Local portion and CI clause both PASS; AC-3 checked off |

---

## Summary

**Overall Feature Readiness:** AC-1, AC-2 and AC-3 PASS. AC-3 CI clause verified 2026-10-07T14:40Z on PR #831 (evidence: `evidence/qa-gates/ac3-ci.2026-10-07T14-40.md`). No criterion is a FAIL, and no defect was found in the change.

**Criteria summary:**
- **PASS:** 3 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

None. PR CI is green (see `evidence/qa-gates/ac3-ci.2026-10-07T14-40.md`).

**Recommended follow-up verification steps:**

1. File a separate issue for the pre-existing root `format:check` fixture failure.

---

## Acceptance Criteria Check-off

- AC-1 and AC-2 are already `[x]` in `issue.md`; the evidence inspected supports both, so no change was needed.
- AC-3 was checked off (`[x]`) in `issue.md` after PR #831 CI passed (evidence: `evidence/qa-gates/ac3-ci.2026-10-07T14-40.md`).

### AC Status Summary

- Source: `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/issue.md`
- Total AC items: 3
- Checked off (delivered): 3
- Remaining (unchecked): 0
- Items remaining: none

AC status: 3/3.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 3 | 3 | 0 | Checkbox-backed |

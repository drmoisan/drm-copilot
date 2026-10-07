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
| 3 | AC-3 toolchains, coverage, build, PR CI | PARTIAL (pending CI) | Local portion: extension format, lint, typecheck, tests exit 0 (3808 passed); root lint, typecheck, tests exit 0 (3825 passed); coverage delta 0 (root 97.68% lines / 91.15% branches, extension 97.09% / 91.37%); mcp-server build exit 0. Root `format:check` exit 2 with body identical to baseline (`root-format-check-diff.2026-10-07T16-00.md`), excluded per AC text. PR CI, including Publish to Marketplace, does not exist yet | `evidence/qa-gates/*-2026-10-07T16-00.md`, `coverage-delta.2026-10-07T16-15.md` | Local portion PASS. The CI clause is unverified until a PR is opened, so AC-3 stays unchecked |

---

## Summary

**Overall Feature Readiness:** AC-1 and AC-2 PASS. AC-3 local portion PASS; AC-3 overall is pending PR CI. No criterion is a FAIL, and no defect was found in the change.

**Criteria summary:**
- **PASS:** 2 criteria
- **PARTIAL (pending CI):** 1 criterion
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

1. PR CI has not run: `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)`, `(packages/mcp-server)` and Publish to Marketplace are unobserved.

**Recommended follow-up verification steps:**

1. Open the PR and confirm the three NPM Audit Gate jobs and Publish to Marketplace succeed (the `vsce package` step is the check that failed on the Dependabot bumps of `@types/vscode`).
2. Check off AC-3 in `issue.md` only after CI is green.
3. File a separate issue for the pre-existing root `format:check` fixture failure.

---

## Acceptance Criteria Check-off

- AC-1 and AC-2 are already `[x]` in `issue.md`; the evidence inspected supports both, so no change was needed.
- AC-3 remains `[ ]` (PARTIAL, pending CI).
- No source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/issue.md`
- Total AC items: 3
- Checked off (delivered): 2
- Remaining (unchecked): 1
- Items remaining: AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, except the pre-existing root `format:check` failure on `tests/fixtures/**` JSON (excluded as in #802). The mcp-server build passes, and PR CI is green, including Publish to Marketplace.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 3 | 2 | 1 | Checkbox-backed |

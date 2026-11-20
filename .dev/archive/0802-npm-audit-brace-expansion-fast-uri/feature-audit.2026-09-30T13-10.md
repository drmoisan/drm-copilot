# Feature Audit: npm audit override remediation (#802)

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802`
**Base Branch:** `main`
**Head Branch:** `bug/npm-audit-brace-expansion-fast-uri`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `6e6ccd62792e0838bee7459a2b468de83ad5d408`)
- **Head branch/commit:** `bug/npm-audit-brace-expansion-fast-uri` (commit `c22849de1ee02402dd038fce6eca4fcfc0889792`)
- **Merge base:** `6e6ccd62792e0838bee7459a2b468de83ad5d408`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/evidence/**`
  - Additional evidence: direct lockfile inspection and `git diff` of the six manifests and lockfiles
- **Feature folder used:** `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker `- Work Mode: minor-audit`; `spec.md` and `user-story.md` are not present and not used.
- **Scope note:** Full branch diff against `main`. PR context was collected at head `c22849de`. No PR exists, so CI status is unavailable.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/issue.md` - only source

### Acceptance criteria

1. AC-1: In all three manifests (`package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json`), `overrides` contains `"fast-uri": "^3.1.8"` and `"brace-expansion": "^5.0.12"`, and each `package-lock.json` is regenerated to match.
2. AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls brace-expansion fast-uri` shows only patched versions (brace-expansion >= 5.0.12, fast-uri >= 3.1.8).
3. AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, the mcp-server build passes, and PR CI is green.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 overrides in all three manifests plus regenerated lockfiles | PASS | `git diff` shows `"fast-uri": "^3.1.8"` and `"brace-expansion": "^5.0.12"` in all three `package.json` files; lockfiles resolve brace-expansion 5.0.12 and fast-uri 3.1.8 | `git diff 6e6ccd62 HEAD -- package.json extensions/drm-copilot/package.json packages/mcp-server/package.json`; node script reading each `package-lock.json` | Scope limited to six files (`scope-check.2026-09-30T09-40.md`) |
| 2 | AC-2 audit exits 0 and only patched versions | PASS | `audit-*.2026-09-30T09-35.md` and `final-audit-*.2026-09-30T09-50.md` record exit 0 in all three packages; lockfile versions confirmed at or above the patched versions; mcp-server lockfile has no `brace-expansion` entry | `npx --yes npm@11 audit --audit-level=moderate` (recorded, not rerun by reviewer); lockfile inspection (run by reviewer) | Audit result relies on executor evidence because the advisory database state at review time was not re-queried |
| 3 | AC-3 toolchains pass, coverage not below baseline, build passes, CI green | PARTIAL | Extension format, lint, typecheck, tests, and root lint, typecheck, tests exit 0; coverage delta 0; mcp-server build exit 0. Root `format:check` exits 2, identical to baseline (pre-existing fixture JSON). No PR exists, so CI is unavailable | `npm run format:check` (root), evidence `root-format-check.2026-09-30T09-45.md`; `coverage-delta.2026-09-30T09-55.md` | Two gaps: root format check non-zero (pre-existing, unrelated to the six files), and CI green is unverifiable until a PR is opened |

---

## Summary

**Overall Feature Readiness:** PASS for AC-1 and AC-2; NEEDS REVISION is not warranted because the open AC-3 items are not defects of this change. Readiness is conditional on a green PR CI run.

**Criteria summary:**
- **PASS:** 2 criteria
- **PARTIAL:** 1 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

1. Root `format:check` exits 2 at both baseline and head because of `tests/fixtures/**` JSON (pre-existing). AC-3 lists "format check" as a passing toolchain stage.
2. PR CI green cannot be confirmed until a PR exists.

**Recommended follow-up verification steps:**

1. Open the PR and confirm `NPM Audit Gate / npm audit (.)`, `(extensions/drm-copilot)`, and `(packages/mcp-server)` succeed.
2. Decide whether the root `format:check` failure counts against AC-3 (AC-3 wording does not scope it); file a separate issue to exclude or fix the fixtures.

---

## Acceptance Criteria Check-off

- AC-1 and AC-2 are already `[x]` in `issue.md`; the evidence inspected supports both, so no change was needed.
- AC-3 remains `[ ]` (PARTIAL).
- No source-file edit was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/issue.md`
- Total AC items: 3
- Checked off (delivered): 2
- Remaining (unchecked): 1
- Items remaining: AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, the mcp-server build passes, and PR CI is green.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 3 | 2 | 1 | Checkbox-backed |

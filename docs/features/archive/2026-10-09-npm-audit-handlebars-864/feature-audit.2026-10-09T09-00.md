# Feature Audit: npm audit handlebars remediation (#864)

**Audit Date:** 2026-10-09
**Feature Folder:** `docs/features/active/2026-10-09-npm-audit-handlebars-864`
**Base Branch:** `origin/main`
**Head Branch:** `bug/npm-audit-handlebars`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `e7d3779b398604af919678c16c877c8539a86cc0`)
- **Head commit:** `86829312f912fc8ed2bd53cdf30c13f7deb7bfd1`
- **Evidence sources:**
  - `git diff origin/main...HEAD` of the four manifests and lockfiles
  - Feature evidence: `docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/**`, including `qa-gates/audit-handoff.2026-10-09T08-50.md`
- **Requirements source:** `issue.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` contains the explicit marker for `minor-audit`; `spec.md` and `user-story.md` are not present and not used.
- **Scope note:** Full branch diff against `origin/main`. No PR exists, so CI status is unavailable. The pre-existing root `format:check` failure on `tests/fixtures` JSON is excluded from AC-3 by the criterion's own text (#802, #848).

---

## Acceptance Criteria Inventory

**Authoritative AC source:** `docs/features/active/2026-10-09-npm-audit-handlebars-864/issue.md`

1. AC-1: manifests and lockfiles updated (`handlebars` override `^4.7.10` in root and extension, lockfiles regenerated, `packages/mcp-server` untouched, no other dependency version changed).
2. AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages; `npm ls` shows only the patched handlebars.
3. AC-3: toolchains pass with coverage not below baseline (root format failure on fixtures excluded), PR CI green on the full check list including Publish to Marketplace.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 manifests, override, lockfiles, scope | PASS | Manifest diff shows only `+ "handlebars": "^4.7.10"` in `package.json` and `extensions/drm-copilot/package.json`, no removals; both lockfiles regenerated (handlebars 4.7.9 -> 4.7.10); branch diff outside docs/ contains no `packages/mcp-server` path; no other dependency version changed | `git diff origin/main...HEAD -- package.json extensions/drm-copilot/package.json '*package-lock.json'`; `evidence/qa-gates/manifest-diff.2026-10-09T08-32.md`, `scope-check.2026-10-09T08-34.md` | Run by reviewer |
| 2 | AC-2 audit exits 0, patched version only | PASS | `final-audit-root`, `final-audit-extension`, `final-audit-mcp-server` (2026-10-09T08-46): `npm audit --audit-level=moderate` exit 0, 0 vulnerabilities. `final-ls-root`, `final-ls-extension`: only handlebars@4.7.10. packages/mcp-server has no handlebars dependency (baseline audit also clean) | `npm audit --audit-level=moderate`; `npm ls handlebars --all` (recorded, not rerun by reviewer) | Audit result relies on executor evidence; the advisory database was not re-queried |
| 3 | AC-3 toolchains, coverage, PR CI | PARTIAL | Local portion verified: root and extension lint, typecheck exit 0; extension format check exit 0; tests pass (root 3923, extension 3906); coverage equals baseline (root 97.76% / 91.42%, extension 97.16% / 91.66%; `coverage-delta.2026-10-09T08-48.md`). Root `format:check` fails only on pre-existing `tests/fixtures` JSON, excluded per #802/#848. The PR-CI-green portion (all checks including Publish to Marketplace) is UNVERIFIED because no PR exists yet | `evidence/qa-gates/*.2026-10-09T08-44.md`; `gh pr checks` after PR creation | Pending the orchestrator after PR creation; non-blocking at this stage |

---

## Summary

**Overall Feature Readiness:** AC-1 and AC-2 PASS. AC-3 is PARTIAL: the local toolchain portion passes and the PR CI portion is pending PR creation. No criterion is a FAIL, and no defect was found in the change.

**Criteria summary:**
- **PASS:** 2 criteria
- **PARTIAL:** 1 criterion (AC-3, PR CI pending; non-blocking)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing full PASS:**

1. AC-3: PR CI on the full check list (including Publish to Marketplace) cannot be observed until a PR exists.

**Recommended follow-up verification steps:**

1. After PR creation, confirm all checks are green and record the result before checking off AC-3.

blocking_count: 0 (FAIL: 0; blocking PARTIAL: 0). One non-blocking pending item (AC-3 PR CI).

---

## Acceptance Criteria Check-off

- AC-1 and AC-2 are already `[x]` in `issue.md`; the evidence inspected supports both, so no change was needed.
- AC-3 remains `[ ]` in `issue.md` as instructed; it is not checked off until PR CI is verified.
- The "Proposed Fix / Validation Ideas" checkboxes in `issue.md` are not AC items for `minor-audit` and are not evaluated.

### AC Status Summary

- Source: `docs/features/active/2026-10-09-npm-audit-handlebars-864/issue.md`
- Total AC items: 3
- Checked off (delivered): 2
- Remaining (unchecked): 1
- Items remaining: AC-3 (PR CI green on the full check list, pending after PR creation)

AC status: 2/3.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 3 | 2 | 1 | Checkbox-backed; AC-3 pending PR CI |

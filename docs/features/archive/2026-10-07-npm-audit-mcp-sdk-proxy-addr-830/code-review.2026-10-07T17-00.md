# Code Review: npm audit SDK and proxy-addr remediation (#830)

**Review Date:** 2026-10-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830`
**Base Branch:** `origin/main` (f6ef5b2f)
**Head Branch:** `bug/npm-audit-mcp-sdk-proxy-addr` (f744baf0)
**Review Type:** Initial review (minor-audit)

---

## Executive Summary

The branch raises `@modelcontextprotocol/sdk` to `^1.31.0` and adds the override `"proxy-addr": "^2.0.8"` in three packages, so that `npm audit --audit-level=moderate` no longer reports GHSA-6qxp-vccf-f47h (SDK) or GHSA-jqcg-44mw-7w3h (proxy-addr). The production diff is six JSON files (39 insertions, 24 deletions). Lockfiles resolve `@modelcontextprotocol/sdk` 1.32.1 (satisfies `^1.31.0`, above the 1.31.0 fix) and `proxy-addr` 2.0.8 in all three packages, verified from the lockfile diffs.

**What changed:**
- `package.json`, `extensions/drm-copilot/package.json`: SDK `^1.30.1` to `^1.31.0`; `proxy-addr` override added.
- `packages/mcp-server/package.json`: SDK `^1.29.0` to `^1.31.0`; `proxy-addr` override added.
- Three matching `package-lock.json` files (18 changed lines each: SDK entry, proxy-addr entry with a new `funding` block, dependency range line).

**Top 3 risks:**
1. PR CI (NPM Audit Gate, Publish to Marketplace) has not run; results rest on local evidence.
2. The SDK moved by two minor versions beyond the floor (1.30.1 to 1.32.1; mcp-server from 1.29-range lock at 1.30.1 to 1.32.1). Runtime behaviour of the MCP server is covered only by existing tests and the esbuild build, not by an end-to-end MCP session.
3. The root `format:check` stays red on pre-existing fixture JSON, which reduces the signal of that gate.

**PR readiness recommendation:** Go. The change is minimal, locally verified, and shows zero coverage delta. Confirm CI after the PR opens.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json` | `overrides` | `proxy-addr` is inserted after `fast-uri` rather than grouped in alphabetical order; the lists are already unordered | None required; matches the issue text ("next to the existing `fast-uri` ... overrides") | Consistent with AC-1 wording | `git diff origin/main...HEAD` on the three manifests |
| Minor | `package.json` (root) | `format:check` script | Exits 2 at baseline and post-change because of `tests/fixtures/**` JSON | Track in a separate issue (also noted in #802) | A permanently red local gate reduces signal for real format defects | `evidence/qa-gates/root-format-check-diff.2026-10-07T16-00.md` |
| Minor | `evidence/qa-gates/final-push.2026-10-07T16-30.md` | n/a | Untracked evidence file recording the final push | Commit it with the review artifacts | Keeps the evidence set complete in the branch | `git status --short` |
| Info | `docs/features/active/.../issue.md` | Status line, Proposed Fix, Next Step | Status line references a stale folder path; non-AC checkboxes are unchecked | None; not acceptance criteria | Documentation hygiene only | `issue.md` |
| Info | lockfiles (all three) | n/a | Lockfile deltas are limited to the SDK and `proxy-addr` entries and the root range line; `@types/vscode`, `@types/node`, `typescript-eslint` untouched | None | Confirms no incidental dependency churn | `git diff origin/main...HEAD -- '*package-lock.json'` |

No Blocker or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

No TypeScript source changed. No suppressions, `any`, or type changes were introduced.

#### What changed well

- The Dependabot-style bump of `@types/vscode` that breaks `vsce package` (#827, #828) was avoided; the manifest diff contains no `@types/vscode`, `@types/node`, or `typescript-eslint` line.
- The override uses a caret range consistent with neighbouring overrides and mirrors the #802 precedent.
- The SDK range is raised in the dependency declaration itself, so the lockfile cannot silently regress to a vulnerable release.

#### Type safety and maintainability

- Not applicable; JSON manifests only. Root and extension typecheck exit 0 after the bump, so no type-level incompatibility with SDK 1.32.1 was introduced.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

No test was added or modified, which is appropriate for a dependency-version change. Existing suites were re-run against the regenerated lockfiles: root 3825 passing (254 suites), extension 3808 passing (251 suites), unchanged from baseline. Coverage is unchanged (root 97.68% lines, 91.15% branches; extension 97.09% lines, 91.37% branches).

### Reviewed test and QA artifacts

- `evidence/qa-gates/root-test-coverage.2026-10-07T16-00.md`, `extension-test-coverage.2026-10-07T16-00.md`: full Jest runs, exit 0.
- `evidence/qa-gates/coverage-delta.2026-10-07T16-15.md`: zero delta versus baseline.
- `evidence/qa-gates/audit-*.2026-10-07T15-30.md`, `final-audit-*.2026-10-07T16-10.md`: audit exit 0, 0 vulnerabilities, in all three packages.
- `evidence/qa-gates/final-ls-*.2026-10-07T16-10.md`: `npm ls` shows SDK 1.32.1 and proxy-addr 2.0.8 only, via express 5.2.1.
- `evidence/qa-gates/mcp-server-build.2026-10-07T16-00.md`: build exit 0.
- Gap: mcp-server has no test suite in the evidence set; only the build was verified.

### Quality assessment prompts

- **Determinism:** Existing suites, unchanged.
- **Isolation:** Not affected.
- **Speed:** Not affected.
- **Diagnostics:** Not affected.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff limited to version ranges, resolved URLs, and registry integrity hashes |
| No unsafe subprocess or command construction | N/A | No code |
| Input validation at boundaries | N/A | No code |
| Vulnerable versions removed | PASS | Lockfiles resolve SDK 1.32.1 (fix 1.31.0) and proxy-addr 2.0.8 (fix 2.0.8); audit exit 0 recorded |
| Lockfile integrity | PASS | Lockfile diff shows only expected registry URLs (`registry.npmjs.org`) and integrity values for the two changed packages |
| Protected dependencies unchanged | PASS | Manifest diff and lockfile diffs contain no `@types/vscode`, `@types/node`, or `typescript-eslint` change |

---

## Research Log

No external research was required. Patched versions were taken from the advisory text in `issue.md`. This review did not re-query the npm registry and did not rerun `npm audit`; recorded evidence was relied on and lockfile versions were checked directly from `git diff`.

---

## Verdict

The change is correct, minimal, and consistent with AC-1 and AC-2. No Blocker or Major findings. It is ready for normal PR flow; the remaining verification is the CI run on the opened PR (AC-3).

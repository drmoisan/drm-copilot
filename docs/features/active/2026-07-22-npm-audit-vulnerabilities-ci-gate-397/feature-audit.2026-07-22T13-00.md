# Feature Audit — issue #397 (npm-audit-vulnerabilities-ci-gate)

- **Branch:** `bug/npm-audit-vulnerabilities-ci-gate-397` @ `33a33806`
- **Base:** `main` @ `b2351cbc3fb3916f516d77567a1c9e40457c8981`
- **Work mode:** `full-bug`
- **AC source:** `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md`, `## Acceptance Criteria` section (per `full-bug` mode rule: spec.md only; no `issue.md` exists in this feature folder, consistent with the task's explicit instruction that `spec.md` is the AC source)
- **Timestamp:** 2026-07-22T13-00

## Acceptance Criteria Evaluation

| # | Criterion | Current checkbox state | Verdict | Evidence |
|---|---|---|---|---|
| 1 | `npm ci && npm audit --audit-level=moderate` exits 0 in `.` (root). | `[x]` | **PASS** | Independently re-run by this reviewer at `33a33806`: `npm audit --audit-level=moderate` in root → "found 0 vulnerabilities", exit 0. Matches `evidence/qa-gates/npm-audit-postfix-root.2026-07-22T12-15.md`. |
| 2 | `npm ci && npm audit --audit-level=moderate` exits 0 in `extensions/drm-copilot/`. | `[x]` | **PASS** | Independently re-run: exit 0, 0 vulnerabilities. Matches `npm-audit-postfix-extensions.2026-07-22T12-15.md`. |
| 3 | `npm ci && npm audit --audit-level=moderate` exits 0 in `packages/mcp-server/`. | `[x]` | **PASS** | Independently re-run: exit 0, 0 vulnerabilities. Matches `npm-audit-postfix-mcp-server.2026-07-22T12-15.md`. |
| 4 | `@modelcontextprotocol/sdk` remains at `^1.29.0` in all three manifests (no SDK downgrade/upgrade); no source files are modified. | `[x]` | **PASS** | `git diff` on all 3 `package.json` files confirms `dependencies["@modelcontextprotocol/sdk"]` untouched; `package-lock.json` diffs confirm resolved version stays `1.29.0` in all three. Branch diff contains zero `.ts`/`.js`/`.py`/`.ps1`/`.cs` files (only 6 `.json` manifests + 37 `.md` docs). |
| 5 | Existing build/compile steps (`npm run compile` in root and `extensions/drm-copilot/`; `npm run build` in `packages/mcp-server/`) succeed unchanged. | `[x]` | **PASS** | Independently re-run: `npm run compile` (root) exit 0; `npx tsc -p ./ --noEmit` (extensions) exit 0; `npm run build` (mcp-server) exit 0, bundle produced. |
| 6 | Existing unit test suites (Jest, per each manifest's actual `npm run test:unit` script) pass unchanged. | `[x]` | **PASS** | Independently re-run: root 166/166 suites, 2007/2007 tests passed; extensions 165/165 suites, 2006/2006 tests passed — identical counts to both baseline and final evidence artifacts. |
| 7 | `NPM Audit Gate` required check is green on the PR head SHA. | `[ ]` | **UNVERIFIED / NOT YET ACTIONABLE** | Confirmed via `git ls-remote --heads origin bug/npm-audit-vulnerabilities-ci-gate-397` (no output — branch not pushed), `gh pr list --head ...` (no PR), and `gh run list --branch ...` (no runs) that no PR exists and no CI has run for this branch. This criterion is contingent on PR creation and a subsequent CI run, both explicitly deferred per `evidence/other/pr-prep-notes.2026-07-22T12-15.md` ("Do NOT commit or push — leave changes staged/unstaged for the orchestrator to review and commit"). This is a legitimate, honestly-tracked gap, not a code defect. |
| 8 | No unintended behavior changes outside the 6 in-scope manifest files. | `[x]` | **PASS** | `git diff --name-status <merge-base> <head>` confirms exactly 6 `M` entries (the 3 `package.json`/`package-lock.json` pairs) plus 37 `A` (new) documentation files under `docs/features/`; no other tracked file was modified. `.github/workflows/_npm-audit-gate.yml` confirmed byte-identical to base. |

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md`
- Total AC items: 8
- Checked off (delivered): 7
- Remaining (unchecked): 1
- Items remaining: "`NPM Audit Gate` required check is green on the PR head SHA." — blocked on PR creation/CI execution, not on any code or documentation defect found in this review. `spec.md`'s checkbox state (7 checked, 1 unchecked) already accurately reflects this; no check-off action was needed or taken by this review, and the one remaining item is correctly left unchecked per the AC Check-Off Protocol ("leave unmet items unchecked").

## Baseline-to-Fix Delta Summary

| Manifest | Pre-fix vulnerabilities | Post-fix vulnerabilities |
|---|---|---|
| `.` (root) | 7 (1 low, 3 moderate, 3 high) | 0 |
| `extensions/drm-copilot/` | 6 (3 moderate, 3 high) | 0 |
| `packages/mcp-server/` | 4 (3 moderate, 1 high) | 0 |

All three counts independently reconfirmed by this reviewer at commit `33a33806`.

## Scope Fidelity vs. `spec.md`

- **In scope, as declared:** `package.json` + `package-lock.json` in `.`, `extensions/drm-copilot/`, `packages/mcp-server/` (6 files). Confirmed exact match.
- **Out of scope, as declared:** no production/source code changes (confirmed — 0 `.ts`/`.js` files changed); no workflow file changes (confirmed — `_npm-audit-gate.yml` byte-identical); no `@modelcontextprotocol/sdk` version change (confirmed — `^1.29.0`/`1.29.0` unchanged everywhere).
- **Explicitly excluded (per spec, tracked as follow-up):** downstream-consumer protection for `@danmoisan/drm-copilot-mcp` (npm `overrides` don't propagate to consumers) — correctly not attempted in this fix, and correctly logged as a follow-up in `evidence/other/follow-up-notes.md`.

## Feature-Folder Completeness

- `spec.md` — present, `Status: Approved`, `Version: 0.2`.
- `plan.2026-07-22T07-54.md` — present, all Phase 0–7 and Phase 9 tasks checked `[x]`; Phase 8 (`P8-T1` PR prep, `P8-T2` CI confirmation) correctly left unchecked, consistent with AC item 7's state.
- `research/2026-07-22-npm-audit-fix-strategy.md` — present, referenced by spec's Root Cause Analysis and Repro & Evidence sections.
- `evidence/` — 32 artifacts across `baseline/`, `qa-gates/`, `other/`, `issue-updates/`, all internally consistent and independently reproducible where re-executable (see `code-review` for detail).
- No `issue.md` or `user-story.md` exists in this feature folder — consistent with `full-bug` work mode, which sources AC from `spec.md` only.

## Overall Feature-Audit Verdict

**PASS, pending one procedural (non-code) acceptance criterion.** All 7 code/config/behavior-verifiable acceptance criteria are independently confirmed true at commit `33a33806`. The 8th criterion (green required CI check on the PR head SHA) cannot be satisfied until a PR is opened and CI executes against its head SHA — this is expected sequencing for a review performed before PR creation, not a defect in the delivered fix. No remediation-inputs artifact is warranted: there is no FAIL-level or Blocking finding against the code/config change itself.

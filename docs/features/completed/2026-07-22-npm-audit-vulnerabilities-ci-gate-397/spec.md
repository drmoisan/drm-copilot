# 2026-07-22-npm-audit-vulnerabilities-ci-gate-397 (Spec)

- **Issue:** #397
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-22T13-30
- **Status:** Ready for Merge
- **Version:** 0.3

## Context
- The `NPM Audit Gate` required CI check (`.github/workflows/_npm-audit-gate.yml`, `npm audit --audit-level=moderate`) fails on `main` for all three npm manifests: root (`.`), `extensions/drm-copilot/`, and `packages/mcp-server/`. This blocks any PR that requires a green `NPM Audit Gate` check.
- Observed environment(s): GitHub Actions `ubuntu-24.04` hosted runner, Node.js 20.20.2, npm 10.8.2.
- Impact and severity: blocks CI/merge for the whole repository; no runtime user impact (see Root Cause Analysis — the vulnerable transitive package is unreachable at runtime).
- First observed: CI runs `29880641944`, `29885176562`, `29885750231` on `main` (2026-07-22), all with `NPM Audit Gate` conclusion `failure`.

## Repro & Evidence
- Steps to reproduce: check out `main` at `b2351cbc`; run `npm ci && npm audit --audit-level=moderate` in `.`, `extensions/drm-copilot/`, and `packages/mcp-server/`.
- Expected vs actual: expected exit 0; actual non-zero exit with a `# npm audit report` listing moderate/high advisories.
- Logs: `gh run view 29885750231 --log-failed` captured full advisory text per manifest; see the potential-bug doc at `docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md` and the research artifact at `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/research/2026-07-22-npm-audit-fix-strategy.md`.
- Frequency: deterministic — every CI run against the current lock files fails identically.

## Scope & Non-Goals
- In scope: `package.json` (`overrides` block) and `package-lock.json` in each of `.`, `extensions/drm-copilot/`, `packages/mcp-server/` (6 files total).
- Out of scope: no production/source code changes, no workflow file changes (`.github/workflows/_npm-audit-gate.yml` is correct as-is), no `@modelcontextprotocol/sdk` version change.
- Explicitly excluded: publishing/consumer-side protection for `@danmoisan/drm-copilot-mcp` (npm `overrides` only apply at this repo's install root, not to downstream consumers of the published package) — tracked as a follow-up, not in scope here.

## Root Cause Analysis
- Confirmed root cause: `@modelcontextprotocol/sdk@1.29.0` (the current `latest` and the version pinned as a direct dependency in all three manifests) declares a dependency on `@hono/node-server@^1.19.9`, which resolves to `1.19.14` — vulnerable to GHSA-frvp-7c67-39w9 (path traversal in `serve-static` on Windows, moderate). The SDK ships no forward version that changes this declaration. Four additional advisories (`fast-uri`, `hono`, `brace-expansion`, `body-parser`) are ordinary transitive-range issues fixable by a plain lock refresh.
- Evidence: registry metadata for `@modelcontextprotocol/sdk` 1.24.3 and 1.29.0; grep of the installed SDK's shipped code confirms zero references to `@hono/node-server` or `hono` anywhere in the package (declared-but-unused dependency); repo-wide grep confirms this codebase imports only `Server`, `StdioServerTransport`, and `types` from the SDK (production) plus `Client`/`InMemoryTransport` (tests) — no HTTP/hono-backed transport is used anywhere.
- Affected components: `package.json`/`package-lock.json` in `.`, `extensions/drm-copilot/`, `packages/mcp-server/`. No source modules are affected because the vulnerable code path is unreachable at runtime in this repo.

## Proposed Fix

### Design summary (what changes where):
Add an `overrides` entry pinning `@hono/node-server` to `^2.0.5` in all three `package.json` files (npm `overrides` force the resolution of a transitive dependency regardless of the parent's declared range), then regenerate each `package-lock.json` via `npm install` + `npm audit fix` (no `--force`). This resolves the `@hono/node-server` advisory without touching `@modelcontextprotocol/sdk`'s version. The four remaining advisories (`fast-uri`, `hono`, `brace-expansion`, `body-parser`) are already inside existing declared/override ranges and are resolved by the same lock regeneration.

### Boundaries and invariants to preserve:
`@modelcontextprotocol/sdk` stays pinned at `^1.29.0` / resolved `1.29.0` in all three manifests — no SDK major-version change, no source code changes.

### Dependencies or blocked work:
None. Fully self-contained dependency-manifest change.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `package.json` (root, `extensions/drm-copilot/`, `packages/mcp-server/`): add `"@hono/node-server": "^2.0.5"` to `overrides`; optionally raise existing override floors (`fast-uri` to `^3.1.4`, `hono` to `^4.12.27`, `c8`-scoped `brace-expansion` to `^5.0.7` in root/extensions) as a defense against future lock regression.
- `package-lock.json` (root, `extensions/drm-copilot/`, `packages/mcp-server/`): regenerate via `npm install` then `npm audit fix` in each directory.

#### Functions/classes/CLI commands impacted:
None — no source code is touched.

#### Data flow and validation changes:
None.

#### Error handling and logging updates:
None.

#### Rollback/feature-flag considerations (if applicable):
Trivial rollback: revert the `overrides` entries and lock files in the 3 manifests; no other coupling.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
N/A — dependency manifest only.

#### Required configuration keys and defaults:
N/A.

#### Backward-compatibility expectations:
`@hono/node-server` 2.0.0's only breaking changes (Node >= 20 required, removal of the `/vercel` export) do not affect this repo: CI already runs Node 20, and the package is never imported by this repo or by the SDK's shipped code.

#### Performance constraints (latency/throughput/memory):
N/A.

## Assumptions, Constraints, Dependencies
- Assumptions: the vulnerable `@hono/node-server` code path is genuinely unreachable at runtime, as confirmed by grep evidence in the research artifact; no hidden dynamic `require`/`import` of the package exists.
- Constraints: no new runtime dependencies; existing `overrides` mechanism only.
- External dependencies: npm registry availability during `npm install`/`npm audit fix`.

## Data / API / Config Impact
- No user-facing or API changes.
- No data or migration considerations.
- No logging/telemetry updates.
- No CLI flag or config schema changes.

## Test Strategy
- Regression tests to add or update: none — no production logic changed; the `NPM Audit Gate` CI check itself is the regression test for this fix.
- Toolchain commands to run per manifest: `npm ci && npm audit --audit-level=moderate` (must exit 0); `extensions/drm-copilot`: `npm run compile` and `npm run test:unit` (Jest — the repo's actual test runner, not vitest); root: `npm run compile` / `npm run test:unit`; `packages/mcp-server`: `npm run build` (esbuild bundle) plus a manual stdio startup smoke check of `packages/mcp-server/out/mcp-server.js`.
- Manual validation: confirm `NPM Audit Gate` required check is green on the PR head SHA before merge.

## Acceptance Criteria
- [x] `npm ci && npm audit --audit-level=moderate` exits 0 in `.` (root).
- [x] `npm ci && npm audit --audit-level=moderate` exits 0 in `extensions/drm-copilot/`.
- [x] `npm ci && npm audit --audit-level=moderate` exits 0 in `packages/mcp-server/`.
- [x] `@modelcontextprotocol/sdk` remains at `^1.29.0` in all three manifests (no SDK downgrade/upgrade); no source files are modified.
- [x] Existing build/compile steps (`npm run compile` in root and `extensions/drm-copilot/`; `npm run build` in `packages/mcp-server/`) succeed unchanged.
- [x] Existing unit test suites (Jest, per each manifest's actual `npm run test:unit` script) pass unchanged.
- [x] `NPM Audit Gate` required check is green on the PR head SHA.
- [x] No unintended behavior changes outside the 6 in-scope manifest files.

## Risks & Mitigations
- Risk: npm `overrides` do not propagate to downstream consumers of the published `@danmoisan/drm-copilot-mcp` package. Mitigation: the shipped `out/mcp-server.js` is a self-contained esbuild bundle that never loads `@hono/node-server`, so consumer risk is not applicable to the published artifact; track upstream SDK for a real fix as a follow-up (out of scope for this fix).
- Risk: `EBADENGINE` warning on Node < 18 installs for `@hono/node-server` 2.x (requires Node >= 20). Mitigation: cosmetic only (no `engine-strict`); CI already runs Node 20.

## Rollout & Follow-up
- Release/rollout: PR #398 is open with all required checks, including all three `NPM Audit Gate` legs, confirmed green on the PR head SHA (verified via `gh pr checks 398 --required`). Awaiting merge. No phased rollout needed once merged.
- Follow-up: track `modelcontextprotocol/typescript-sdk` upstream for a release that removes or bumps its unused `@hono/node-server`/`hono` dependencies, then drop the local `overrides` pins.
- Links: issue #397; PR #398; research artifact `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/research/2026-07-22-npm-audit-fix-strategy.md`.

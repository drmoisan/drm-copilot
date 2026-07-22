# Research: npm Audit Gate Remediation Strategy (Issue #397)

- Date: 2026-07-22
- Author: task-researcher agent
- Feature: docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/
- Scope: `NPM Audit Gate` failures on `main` for manifests `.`, `extensions/drm-copilot/`, `packages/mcp-server/`

## Method and Evidence Basis

Findings below are grounded in: direct reads of the three `package.json` and `package-lock.json` files, grep of the installed `@modelcontextprotocol/sdk` 1.29.0 package under `packages/mcp-server/node_modules/`, grep of repository sources for SDK imports, the workflow file `.github/workflows/_npm-audit-gate.yml`, and WebFetch of the npm registry (`@modelcontextprotocol/sdk` versions 1.24.3 and latest), the `honojs/node-server` GitHub releases (including the v2.0.0 release notes), and the GitHub advisories GHSA-w62v-xxxg-mg59, GHSA-4c8g-83qw-93j6, GHSA-v2hh-gcrm-f6hx, and GHSA-3jxr-9vmj-r5cp.

Limitation: this research session had no shell tool, so `npm audit fix --dry-run --json` was not executed. The equivalent conclusion for the non-breaking advisories is derived from lock-file resolution state plus registry-verified patched versions and declared parent dependency ranges (see section 5). The dry run is listed as an executor validation step.

Working-tree caveat: at the time of this research the session's git snapshot reported branch `chore/npm-upgrade` with uncommitted modifications to the root `package.json` and `package-lock.json`. All file contents cited below reflect the working tree as read, which may include those uncommitted changes. The planner should confirm the branch/commit baseline before scoping tasks.

## 1. Current State: SDK Pinning Across the Three Manifests

`@modelcontextprotocol/sdk` is a direct dependency in all three manifests, pinned identically:

| Manifest | package.json declaration | Lock-resolved version |
|---|---|---|
| `.` (root) | `"@modelcontextprotocol/sdk": "^1.29.0"` (`dependencies`) | 1.29.0 |
| `extensions/drm-copilot/` | `"@modelcontextprotocol/sdk": "^1.29.0"` (`dependencies`) | 1.29.0 |
| `packages/mcp-server/` | `"@modelcontextprotocol/sdk": "^1.29.0"` (`dependencies`) | 1.29.0 |

Registry-verified: 1.29.0 is the SDK's `latest` dist-tag at research time. There is no newer SDK version to upgrade to.

Lock-resolved advisory-relevant transitives (per lock file):

| Package | Root | extensions/drm-copilot | packages/mcp-server | Vulnerable? | Patched version |
|---|---|---|---|---|---|
| `@hono/node-server` | 1.19.14 | 1.19.14 | 1.19.14 | Yes (< 2.0.5, GHSA-frvp-7c67-39w9) | 2.0.5 (latest 2.0.11) |
| `fast-uri` | 3.1.2 | 3.1.2 | 3.1.2 | Yes (GHSA-4c8g-83qw-93j6 patched 3.1.3; GHSA-v2hh-gcrm-f6hx patched 3.1.4) | 3.1.4 |
| `hono` | 4.12.26 | 4.12.26 | 4.12.26 | Yes (< 4.12.27, GHSA-w62v-xxxg-mg59) | 4.12.27 |
| `brace-expansion` (top-level, dev) | 5.0.6 | 5.0.6 | not present | Yes (>= 3.0.0 < 5.0.7, GHSA-3jxr-9vmj-r5cp) | 5.0.7 |
| `brace-expansion` (nested under minimatch/glob, dev) | 2.1.1 | 2.1.1 | not present | Yes (>= 2.0.0 < 2.1.2, same GHSA) | 2.1.2 |
| `body-parser` | 2.2.2 | 2.3.0 (already fixed) | 2.3.0 (already fixed) | Root only (low, GHSA-v422-hmwv-36x6) | 2.3.0 |

Discrepancy versus the bug writeup: `hono` 4.12.26 is also resolved in `packages/mcp-server/package-lock.json` and is inside the GHSA-w62v-xxxg-mg59 vulnerable range (`< 4.12.27`). The writeup listed the `hono` advisory for root and extensions only. Regardless of whether the CI audit flagged it there, the remediation should refresh `hono` in all three locks.

All three manifests already carry `overrides` blocks (`fast-uri: ^3.1.2`, `hono: ^4.12.25`, plus others). These override *floors* currently admit vulnerable versions; the caret ranges also admit the patched versions, so a lock refresh fixes them without changing the override values (raising the floors is still recommended, see section 6).

## 2. Key Structural Finding: The Vulnerable Package Is Declared but Never Imported

Two verified facts drive the strategy choice:

1. **SDK 1.29.0 declares `@hono/node-server: ^1.19.9` and `hono: ^4.11.4` but ships no code that references either.** A case-insensitive grep for `hono` across the entire installed `@modelcontextprotocol/sdk` package (all dist trees, ESM and CJS) matches only the two `package.json` dependency declarations. Grep functionality against those dist files was positively controlled (it finds `require("../types.js")` in the same files). The hono packages are dead-weight dependencies in the shipped 1.29.0 artifact.
2. **This repository uses only the SDK's stdio and in-memory surfaces.** Repository-wide grep for `@modelcontextprotocol/sdk` imports finds exactly: `Server` (`server/index.js`), `StdioServerTransport` (`server/stdio.js`), types (`types.js`) in `extensions/drm-copilot/src/mcp-server.ts`; and `Client` (`client/index.js`), `InMemoryTransport` (`inMemory.js`) in three test files under `extensions/drm-copilot/test/`. No HTTP/SSE/streamable-HTTP transport is used. The root manifest declares the SDK as a dependency but no root source imports it (root `src/` contains only `hello-typescript.ts`). `packages/mcp-server` has no `src/`; its `out/mcp-server.js` is an esbuild bundle of `extensions/drm-copilot/src/mcp-server.ts` (entry point confirmed in `packages/mcp-server/esbuild-mcp-server.cjs`), and esbuild bundles only reachable imports.

Consequence: the vulnerable `@hono/node-server` 1.19.14 is unreachable at runtime everywhere in this repository. The audit gate failure is a supply-chain hygiene finding, not an exploitable path. This lowers the compatibility risk of any resolution-level fix to near zero.

## 3. Why Plain `npm audit fix` Cannot Fix the `@hono/node-server` Advisory

The fix version 2.0.5 is a major bump of `@hono/node-server` (1.x -> 2.x), outside the SDK's declared range `^1.19.9`. npm will not resolve outside a declared range without an override or a `--force` dependency rewrite.

## 4. Candidate Strategies for `@hono/node-server`

### Strategy A (rejected): `npm audit fix --force` (SDK to 1.24.3)

Registry verification shows the forced fix is a **downgrade**, not an upgrade:

- SDK 1.24.3 (published 2024-12) has **no** `@hono/node-server` or `hono` dependency at all; its HTTP stack is Express-only. npm's forced "fix" removes the vulnerable package by rolling the SDK back to the last version that never depended on it.
- The currently pinned 1.29.0 is the registry `latest`; no forward SDK version exists that depends on `@hono/node-server ^2`.
- npm flags the change `isSemVerMajor: true` because 1.24.3 is outside `^1.29.0`.

Rejection rationale: this discards five minor versions of SDK fixes/features, inverts the dependency direction the repo will eventually move in, and is unstable — any future `npm update` or SDK range restoration reintroduces the advisory. It also forces re-validation of the SDK API surface (`Server`, `StdioServerTransport`, `Client`, `InMemoryTransport`, `types.js` schemas) against an older release for zero security benefit relative to Strategy B.

### Strategy B (recommended): npm `overrides` pin of `@hono/node-server` to `^2.0.5`

Add `"@hono/node-server": "^2.0.5"` to the `overrides` block of all three `package.json` files and regenerate the three lock files. Verified compatibility facts:

- **npm accepts the override.** `overrides` unconditionally replaces the resolution of a transitive dependency regardless of the parent's declared range. The only npm hard-error case — an override conflicting with a *direct* dependency of the same package — does not apply; `@hono/node-server` is not a direct dependency in any manifest. All three manifests already use `overrides` (including out-of-range-style floors such as `ip-address: ^10.2.0`), and the workflow's `npm ci` honors lock files produced with overrides.
- **`@hono/node-server` 2.0.0 breaking changes are irrelevant here.** Release notes (verified via GitHub releases): (1) Node.js >= 20 required (v18 support dropped); (2) the `@hono/node-server/vercel` export removed. Public API otherwise unchanged. The CI gate runs Node 20; nothing in this repo (or in the SDK's shipped code, per section 2) imports the package, so neither change has a runtime effect.
- **SDK internal usage cannot break** because the SDK's shipped 1.29.0 code contains no reference to the package (section 2). The override swaps an unused directory in `node_modules`.
- Latest 2.x at research time is 2.0.11 (2026-07-21); `^2.0.5` will resolve to it.

Minor caveats:
- `@hono/node-server` 2.x declares `engines.node >= 20` (2.x releases) while `packages/mcp-server` declares `engines.node >= 18`. npm emits an `EBADENGINE` warning (not a failure, absent `engine-strict`) on Node 18 installs. Since the package is unreachable code, this is cosmetic; optionally raise the `packages/mcp-server` engines floor to `>= 20` in a follow-up (Node 18 is end-of-life).
- `@hono/node-server` has `peerDependencies: { hono: ^4 }` in both 1.x and 2.x lines; `hono` 4.12.27 will be present in all three trees after the refresh, satisfying it.

### Rejected alternatives (summary)

- `npm audit fix --force`: semver-major SDK *downgrade* to a pre-hono release; unstable and regressive (details above).
- Removing the root SDK dependency: root sources never import the SDK, so dropping it would clear most root advisories, but the dependency's intent is unverified and this widens scope; noted as a possible follow-up, not part of this fix.
- Waiting for an upstream SDK release that bumps or removes the hono dependencies: no such release exists (1.29.0 is latest); leaves the required check red indefinitely.

## 5. Non-Breaking Advisories: Confirmation Without a Dry Run

`npm audit fix --dry-run` was not executable in this session (no shell tool). Equivalent confirmation from lock and registry data — each patched version is admitted by every governing range, so a plain lock refresh (no `--force`, no manifest edit) resolves them, and none of these paths involves `@modelcontextprotocol/sdk`'s own version:

| Advisory | Governing range(s) | Patched version admitted? |
|---|---|---|
| `fast-uri` -> 3.1.4 | `ajv` declares `^3.0.1`-compatible range (`fast-uri: ^3.0.1` per lock); repo override `^3.1.2` | Yes |
| `hono` -> 4.12.27 | SDK declares `^4.11.4`; repo override `^4.12.25` | Yes |
| `brace-expansion` 5.0.6 -> 5.0.7 | repo override (scoped `c8: { brace-expansion: ^5.0.6 }`) | Yes |
| `brace-expansion` 2.1.1 -> 2.1.2 | `minimatch` 9.0.9 declares `^2.0.2` (verified in root lock); `glob` analog in extensions lock | Yes |
| `body-parser` 2.2.2 -> 2.3.0 (root only) | `express` 5.x declared range; extensions and mcp-server locks already resolve 2.3.0 | Yes |

`@modelcontextprotocol/sdk` remains at 1.29.0 throughout: every fix above is a transitive patch/minor bump inside declared ranges. The executor should still run `npm audit fix --dry-run --json` per manifest as a preflight check to confirm npm computes the same resolution set before applying changes.

## 6. Recommended Remediation (Single Strategy)

Apply Strategy B plus a plain lock refresh, per manifest:

1. Edit `package.json` `overrides` in all three manifests:
   - Add `"@hono/node-server": "^2.0.5"`.
   - Recommended (defense against future lock regression, not strictly required): raise existing floors that currently admit vulnerable versions — `fast-uri` to `^3.1.4`, `hono` to `^4.12.27`, and the `c8`-scoped `brace-expansion` to `^5.0.7` (root and extensions only).
2. Regenerate each lock file: `npm install` (picks up the override) followed by `npm audit fix` (or `npm update fast-uri hono brace-expansion body-parser`) in `.`, `extensions/drm-copilot/`, `packages/mcp-server/`.
3. Do not use `--force` anywhere. `@modelcontextprotocol/sdk` stays at 1.29.0; no source code changes are required (verified: no repo call site touches any hono-related SDK surface, and the SDK ships none).

### Validation required after the change

- `npm ci && npm audit --audit-level=moderate` in all three manifest directories must exit 0 (mirrors `.github/workflows/_npm-audit-gate.yml`, Node 20).
- `extensions/drm-copilot`: `npm run compile` (tsc + both esbuild bundles) and the unit test suite. Note: the bug writeup says "vitest suites", but the actual test scripts in both root and extensions `package.json` invoke Jest (`run-jest.cjs`); run what the scripts define (`npm run test:unit`).
- Root: `npm run compile` / `npm run test:unit` (Jest) to confirm the dev-tree bumps (`brace-expansion`) did not disturb tooling.
- `packages/mcp-server`: `npm run build` (esbuild bundle regeneration succeeds), then an MCP server startup smoke check. The existing extension tests using `Client` + `InMemoryTransport` already exercise server construction/tool listing; an additional manual `node packages/mcp-server/out/mcp-server.js` stdio startup check is cheap and recommended.
- Confirm the `NPM Audit Gate` required check is green on the PR head SHA (required for merge; also satisfies the modified-lockfile review posture).

### Residual risk / follow-ups

- **Consumers of the published `@danmoisan/drm-copilot-mcp` package are not protected by these overrides.** npm `overrides` apply only at the installing project's root; a consumer installing the package resolves the SDK's own `@hono/node-server ^1.19.9` again. Impact is limited because the shipped `out/mcp-server.js` is a self-contained bundle that never loads the package. Follow-up: track upstream `modelcontextprotocol/typescript-sdk` for a release that bumps to `@hono/node-server ^2` or drops the unused dependency, then remove the local overrides.
- The SDK 1.29.0 hono dependencies are declared-but-unused in the shipped artifact (section 2); an upstream issue report is a reasonable, optional follow-up.
- `EBADENGINE` warning for `@hono/node-server` 2.x on Node < 20 installs (cosmetic; see section 4 caveats).
- Future advisories against the same override-pinned floors will require the same floor-raise pattern; the overrides blocks are the single point of maintenance.

## 7. Files to Touch (for atomic-planner scoping)

| Manifest | Files | Change |
|---|---|---|
| `.` (root) | `package.json` | `overrides`: add `@hono/node-server: ^2.0.5`; recommended floor raises (`fast-uri ^3.1.4`, `hono ^4.12.27`, `c8.brace-expansion ^5.0.7`) |
| `.` (root) | `package-lock.json` | regenerate (`npm install` + `npm audit fix`): `@hono/node-server` 2.0.x, `fast-uri` 3.1.4, `hono` 4.12.27, `brace-expansion` 5.0.7 and 2.1.2, `body-parser` 2.3.0 |
| `extensions/drm-copilot/` | `package.json` | same overrides changes as root |
| `extensions/drm-copilot/` | `package-lock.json` | regenerate: `@hono/node-server` 2.0.x, `fast-uri` 3.1.4, `hono` 4.12.27, `brace-expansion` 5.0.7 and 2.1.2 |
| `packages/mcp-server/` | `package.json` | `overrides`: add `@hono/node-server: ^2.0.5`; recommended floor raises (`fast-uri ^3.1.4`, `hono ^4.12.27`) |
| `packages/mcp-server/` | `package-lock.json` | regenerate: `@hono/node-server` 2.0.x, `fast-uri` 3.1.4, `hono` 4.12.27 |

No source files require changes. No workflow file changes are required (`.github/workflows/_npm-audit-gate.yml` is correct as-is; the failure is in the dependency trees, not the gate).

Working-tree caveat for the planner: the root `package.json`/`package-lock.json` were already locally modified (uncommitted) when this research was captured, on observed branch `chore/npm-upgrade`. Reconcile that in-progress work with this plan before task execution to avoid double-applying or clobbering changes.

## 8. Behavior Semantics

- Success condition: `npm ci && npm audit --audit-level=moderate` exits 0 in all three manifest directories on the runner (Node 20), turning the three matrix legs of the `NPM Audit Gate` required check green.
- Failure conditions to guard: (1) lock/manifest desync — the workflow's `npm ci` fails if `package-lock.json` is not regenerated after the `package.json` overrides edit; (2) a new advisory published between fix and merge (re-run audit at PR time); (3) partial application — fixing only some manifests leaves the check red because the matrix legs are independent but all feed one required check.
- Ordering: edit `package.json` overrides first, then regenerate the lock, per manifest; the two files must land in the same commit per manifest to keep `npm ci` green at every commit.

## 9. Testing Implications

No production TypeScript changes are involved, so no new tests are required. The strategy relies on existing suites as regression evidence: extension Jest unit tests (including the `InMemoryTransport`-based MCP server tests, which exercise the SDK surface actually used), `tsc` typecheck, and esbuild bundle builds in both `extensions/drm-copilot` and `packages/mcp-server`. The audit gate itself is the acceptance test. A stdio startup smoke check of `packages/mcp-server/out/mcp-server.js` is recommended as manual verification since no automated integration test covers the packaged binary.

## Automation Feasibility

Fully automatable. Remediation consists entirely of repository-local edits (`package.json` overrides) and deterministic npm commands (`npm install`, `npm audit fix`, `npm ci`, `npm audit`), followed by existing build/test scripts. No third-party UI or portal interaction, no credential provisioning, and no manual registry action is required. The only human-judgment step is reconciling the pre-existing uncommitted root manifest changes noted above.

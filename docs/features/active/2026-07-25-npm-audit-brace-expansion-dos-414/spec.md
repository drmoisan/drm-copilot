# 2026-07-25-npm-audit-brace-expansion-dos-414 (Spec)

- **Issue:** #414
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25T21-00
- **Status:** Ready for Planning
- **Version:** 0.3

## Context
- The `NPM Audit Gate` jobs for the repository root (`.`) and `extensions/drm-copilot` fail at `--audit-level=moderate` because a newly published high-severity advisory for `brace-expansion` (GHSA-mh99-v99m-4gvg) declares the vulnerable range as `<=5.0.7`, which invalidates the `^5.0.7` override floor that issue #397 committed on 2026-07-22.
- Advisory detail: "DoS via unbounded expansion length causing an out-of-memory process crash"; CWE-400, CWE-770; CVSS 7.5 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`); vulnerable range `<=5.0.7`; only patched release `5.0.8`.
- Observed environment(s): GitHub Actions `ubuntu-latest` runner (CI, Node.js 20); reproduced locally on Windows 11 with Node.js v24.14.0 / npm 11.9.0.
- Impact and severity: **Blocker.** The gate fails on `main` itself (the failing input is the live npm advisory database, not any diff), so every branch inherits a red `NPM Audit Gate` on its next run. There is no runtime user impact — `brace-expansion` arrives only through developer tooling (`minimatch`/`glob` under ESLint, Jest, and `c8`), not through any shipped runtime path.
- First observed: CI run `30164280177` (2026-07-25) failed `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)`; the `packages/mcp-server` leg passed.

## Repro & Evidence
- Steps to reproduce:
  1. Check out `main` at `73b3f2a2` (no branch changes required — the failing input is the live npm advisory database, not any diff).
  2. Run `npm audit --audit-level=moderate` in the repository root. It exits non-zero with 22 high-severity advisory paths.
  3. Run the same command in `extensions/drm-copilot`. It also exits non-zero.
  4. Run the same command in `packages/mcp-server`. It exits 0 with `found 0 vulnerabilities`.
- Expected vs actual: expected all three `NPM Audit Gate` matrix jobs (`.`, `extensions/drm-copilot`, `packages/mcp-server`) to exit 0 at `--audit-level=moderate`; actual is two of three jobs failing. A local `npm audit --json` at the root reports `{"info":0,"low":0,"moderate":0,"high":22,"critical":0,"total":22}` — all 22 paths attributable to the single GHSA-mh99-v99m-4gvg advisory.
- Logs:

```text
metadata: {"info":0,"low":0,"moderate":0,"high":22,"critical":0,"total":22}
severity: high isDirect: false
nodes: ["node_modules/brace-expansion","node_modules/minimatch/node_modules/brace-expansion"]
range: "<=5.0.7"
effects: ["minimatch"]
fixAvailable: {"name":"jest","version":"25.0.0","isSemVerMajor":true}
```

Note: the `fixAvailable` version in this captured log reflects the live advisory database at capture time and drifts over time; the stable fact is that the suggestion is a breaking major downgrade of jest.

Lockfile-resolved versions of the flagged nodes (two per affected root):

```text
root: node_modules/brace-expansion                        -> 5.0.7   (flagged)
root: node_modules/minimatch/node_modules/brace-expansion -> 2.1.2   (flagged)
ext:  node_modules/brace-expansion                        -> 5.0.7   (flagged)
ext:  node_modules/glob/node_modules/brace-expansion      -> 2.1.2   (flagged)
```

- Frequency: deterministic — `npm audit` reads the committed lockfile against the live advisory database, so every run against the current lockfiles fails identically across all branches.
- Full remediation analysis: `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/research/2026-07-25T10-45-brace-expansion-ghsa-mh99-remediation-research.md`. A fail-before baseline (`npm audit` exit 1, 22 high) is captured under `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/` before the manifest edit.

## Scope & Non-Goals
- In scope: exactly 4 files — `package.json` (root, `overrides` block), `package-lock.json` (root, regenerated), `extensions/drm-copilot/package.json` (`overrides` block), `extensions/drm-copilot/package-lock.json` (regenerated).
- Out of scope / non-goals: no source-code changes; no workflow changes (`.github/workflows/_npm-audit-gate.yml`, `npm-audit-gate.yml`, and `ci.yml` are correct as-is); no changes to `packages/mcp-server` (its tree contains zero `brace-expansion`, `minimatch`, or `glob` nodes and reports `found 0 vulnerabilities` — it passes because the package family is absent, not because of its `overrides` block, and a defensive pre-pin would be dead configuration that npm cannot validate).
- Explicitly excluded: any change to branch protection or required-check configuration. The research artifact records a recommendation to keep the three `NPM Audit Gate` legs required; that is a reported recommendation only and is explicitly out of scope for this change.
- Prohibited remediation path: `npm audit fix --force`. Its `fixAvailable` suggestion is a breaking major downgrade of jest (the exact suggested version drifts with the live advisory database) and must not be used.

## Root Cause Analysis
- Confirmed root cause: this is not a code regression and is not caused by any branch. The same lockfiles passed the same gate on `main` earlier on 2026-07-25 (runs `30129056914` and `30126891939`, all three npm audit jobs `success`). The changed input is the live npm advisory database: GHSA-mh99-v99m-4gvg declares the vulnerable range `<=5.0.7`, which covers both resolved `brace-expansion` nodes in each affected tree (`5.0.7` hoisted; `2.1.2` nested under `minimatch` at root and under `glob` in the extension).
- Why the #397 override cannot fix this: issue #397 (CLOSED 2026-07-22T13:25:37Z) committed `"c8": { "brace-expansion": "^5.0.7" }` into the root and extensions `overrides`. That entry is now insufficient on two independent axes: (1) the `^5.0.7` floor is below the only patched release `5.0.8`, and (2) its `c8` scope does not cover the `minimatch`-nested (root) / `glob`-nested (extension) node. This spec supersedes that entry; it is a new defect, not a reopening of #397.
- No patched legacy line exists: `5.0.8` is `latest` and the only release above the vulnerable range. The maintenance dist-tags (`maintenance-v1: 1.1.16`, `maintenance-v2: 2.1.2`, `maintenance-v3: 3.0.2`) are all inside `<=5.0.7`, so there is no patched 1.x/2.x/3.x/4.x release. The nested `2.1.2` node therefore cannot be remediated within `minimatch@9`'s declared `^2.0.2` range; a plain lockfile refresh has no effect.
- The critical compatibility constraint (orchestrator-verified against the published tarballs): `brace-expansion@2.1.2` exports a callable default (`module.exports = expandTop`). `brace-expansion@5.0.8` has no default export — only the named `exports.expand` with `__esModule: true`. `minimatch@9.0.9` declares `brace-expansion: ^2.0.2` and consumes it as a default import (`__importDefault(require('brace-expansion'))` then `(0, brace_expansion_1.default)(pattern)`); under 5.0.8 that resolves to `undefined` and throws `TypeError`. A `brace-expansion`-only override is therefore unsafe. The break would be latent rather than immediate: minimatch 9 reaches that call only for brace-containing patterns (for example `**/*.{ts,js}`), so simple globs would keep working while jest/glob/mocha brace globs fail.
- Why the paired override is safe: `minimatch@10.2.5` declares `brace-expansion: ^5.0.5` and calls the named export `(0, brace_expansion_1.expand)(pattern, { max: options.braceExpandMax })`. Its `engines.node` is `18 || 20 || >=22` (CI Node 20 satisfied). It exports every name its forced consumers use (`Minimatch`, `escape`, `unescape`, `GLOBSTAR`, and the named `minimatch` function) and still honors the `dot` and `windowsPathsNoEscape` options. The only minimatch-9 consumers are `glob@10.5.0` (declares `^9.0.4`; present in both affected roots) and `mocha@11.7.6` (declares `^9.0.5`; root only). minimatch 10.x is already proven in-tree: `glob@13.0.6` (under `@vscode/test-cli` and `c8`) declares `minimatch ^10.2.2`, and six nested `minimatch@10.2.5` nodes already resolve in the root lockfile.

## Proposed Fix

### Design summary (what changes where):
Add paired unscoped `overrides` entries to both affected manifests — `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"` — and delete the now-superseded `"c8": { "brace-expansion": "^5.0.7" }` block from each. Then regenerate each affected `package-lock.json` via `npm install` in that root (not `npm audit fix --force`). The unscoped `minimatch` rule eliminates `minimatch@9.0.9` (the sole consumer of the 2.x default-export API) from both trees, which makes the unscoped `brace-expansion` floor safe; the `^5.0.8` floor then clears the advisory for every remaining node. `packages/mcp-server` is untouched.

### Boundaries and invariants to preserve:
- `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` remain byte-identical.
- No direct-dependency version changes; the `overrides` mechanism only.
- All affected nodes are dev-dependency subtree only (`dev: true` in both lockfiles); the runtime dependency `@modelcontextprotocol/sdk` consumes neither `minimatch` nor `brace-expansion`.

### Dependencies or blocked work:
None. Fully self-contained dependency-manifest change; the two affected roots are independent npm projects and can be regenerated and verified per root in either order.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `package.json` (root): in `overrides`, add `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"`; delete the `"c8": { "brace-expansion": "^5.0.7" }` block. All other entries are unchanged.
- `extensions/drm-copilot/package.json`: same `overrides` edit.
- `package-lock.json` (root) and `extensions/drm-copilot/package-lock.json`: regenerate via `npm install` in each root. If npm retains stale resolved nodes despite the override change, delete `node_modules` in that root and re-run `npm install`.
- Disposition of the `c8` scoped block: removed, not retained. With an unscoped `brace-expansion` rule present, the scoped rule is redundant (the unscoped floor is higher), and because scoped rules take precedence inside the `c8` subtree, retaining the stale `^5.0.7` floor would leave a second, lower floor a future reader must reason about. `c8`'s own chain (`glob@13 -> minimatch@10.2.x -> brace-expansion ^5.0.5`) resolves to `5.0.8` under the unscoped rule.

#### Functions/classes/CLI commands impacted:
None — no source code is touched. The forced `minimatch` 9→10 bump moves the module loaded by `glob@10.5.0` (jest 30.4.x reporters/config/runtime, `test-exclude@7.0.2`) and by `mocha@11.7.6` (root only).

#### Data flow and validation changes:
None.

#### Error handling and logging updates:
None.

#### Rollback/feature-flag considerations (if applicable):
Trivial rollback: revert the `overrides` edits and the two lockfiles (4 files); no other coupling. Note that rollback restores the failing audit state.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
N/A — dependency manifests only. Post-regeneration lockfile assertions (deterministic, greppable): no `minimatch` node at `9.0.9` and no `brace-expansion` node at `2.1.2` or `5.0.7` remains in either affected lockfile; a single hoisted `node_modules/brace-expansion` at `5.0.8` per tree.

#### Required configuration keys and defaults:
N/A.

#### Backward-compatibility expectations:
- `minimatch` 10.0.0's only breaking change relative to 9.x is the Node 20/22 engine requirement (10.1/10.2 are additive: `magicalBraces`, `braceExpandMax`, `makeRe` fixes). CI runs Node 20; local development runs Node 24.
- `glob@10.5.0` consumes only `Minimatch`, `escape`, `unescape`, and `GLOBSTAR` from minimatch; `mocha@11.7.6` consumes the named `minimatch` function with `{ dot, windowsPathsNoEscape }`. All are present and unchanged in `minimatch@10.2.5` (orchestrator-verified against the published tarballs).
- `brace-expansion@5.0.8` is dual-published (`main: ./dist/commonjs/index.js` with an `exports` map carrying both `import` and `require` conditions), so CJS `require('brace-expansion')` from minimatch/glob resolves; `engines.node` is `20 || >=22`, satisfied by CI Node 20 and local Node 24.

#### Performance constraints (latency/throughput/memory):
N/A.

## Assumptions, Constraints, Dependencies
- Assumptions: the orchestrator-verified export-shape and consumption-surface findings (recorded in `artifacts/orchestration/orchestrator-state.json`, `orchestrator_independent_verification`) hold for the versions npm resolves at regeneration time; no minimatch consumer below `^9.x` exists in either lockfile (exhaustively checked — every declared range is `^9.0.4`/`^9.0.5` or `^10.2.x`).
- Constraints: no new dependencies; existing `overrides` mechanism only; `npm audit fix --force` prohibited; `packages/mcp-server` untouched.
- External dependencies: npm registry availability during `npm install`; the live npm advisory database (a future advisory covering `<=5.0.8` cannot be prevented by any override operator — the weekly scheduled `NPM Audit Gate` run, Mondays 07:00 UTC, is the detection mechanism for that scenario).

## Data / API / Config Impact
- No user-facing or API changes.
- No data or migration considerations.
- No logging/telemetry updates.
- No CLI flag or config schema changes.

## Test Strategy
- Regression tests to add or update: none — no production logic changed (unit-test policy scopes tests to units of behavior; this change is dependency resolution only). The `NPM Audit Gate` CI check is the regression test for this fix.
- Baseline (fail-before) evidence: capture `npm audit --audit-level=moderate` output (exit 1, 22 high) in root and extension before the manifest edit, under `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/`.
- Toolchain commands to run after regeneration (`npm ci` first in each root; these are the actual `scripts` entries, and they exercise the forced `minimatch` 9→10 path through jest and test-exclude; mocha's `minimatch` consumption path is verified directly, per the `test:integration` qualification below):
  - Root: `npm run format:check`, `npm run lint`, `npm run typecheck`, `npm run test:unit:coverage`. `npm run test:integration` (`vscode-test`) is not a runnable gate in this repository — no `.vscode-test.{json,js,cjs,mjs}` config exists, so `@vscode/test-cli` exits 1 before starting a runner, both locally and on CI, and no workflow invokes it. Run it only to confirm the post-change output is identical to the recorded pre-edit baseline failure, and verify mocha's forced `minimatch` consumption path directly instead (resolve `minimatch` from mocha's resolution root and exercise a brace-containing pattern with the options mocha passes).
  - `extensions/drm-copilot`: `npm run lint`, `npm run typecheck`, `npm run compile`, `npm run test:coverage`.
  - `packages/mcp-server`: `npm ci` and `npm run build` (confirms the untouched lockfile still installs; no test script exists in this root).
  - All three roots: `npm audit --audit-level=moderate` must exit 0.
- Lockfile assertions (greppable): no `minimatch@9.0.9` node and no `brace-expansion` node at `2.1.2` or `5.0.7` in either affected lockfile; `packages/mcp-server/package-lock.json` byte-identical.
- Manual validation: confirm all three `NPM Audit Gate` jobs succeed on the branch head via `gh run view <id> --json jobs`.
- Evidence recording: capture `Command:` / `EXIT_CODE:` / `Output Summary:` for each verification command under `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/`.

## Acceptance Criteria
- [x] `npm audit --audit-level=moderate` exits 0 in the repository root (`.`).
- [x] `npm audit --audit-level=moderate` exits 0 in `extensions/drm-copilot`.
- [x] `npm audit --audit-level=moderate` exits 0 in `packages/mcp-server` (regression guard — it passes today and must continue to pass).
- [x] No `brace-expansion` node resolving to a version `<=5.0.7` (specifically `2.1.2` or `5.0.7`) remains in `package-lock.json` or `extensions/drm-copilot/package-lock.json` (verify by grep for `node_modules/brace-expansion` entries and their `"version"` fields).
- [x] No `minimatch@9.x` node remains in `package-lock.json` or `extensions/drm-copilot/package-lock.json` (verify by grep for `"version": "9.` under `minimatch` nodes).
- [x] The `"c8": { "brace-expansion": "^5.0.7" }` override block is removed from both `package.json` and `extensions/drm-copilot/package.json`, and both manifests carry unscoped `"brace-expansion": "^5.0.8"` and `"minimatch": "^10.2.5"` overrides.
- [x] Root toolchain passes with baseline-parity qualifications: `npm run lint` and `npm run typecheck` exit 0 in the repository root; `npm run format:check` either exits 0 or produces output identical to the recorded pre-edit baseline (the same two pre-existing fixture failures — `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json` and `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json` — which are byte-identical to `origin/main`), proving the change introduced no new formatting failure; root unit-test coverage meets >=85% line / >=75% branch measured via the rootDir-free jest invocation that avoids the worktree `.claude` glob-escape artifact (the `npm run test:unit:coverage` script reports `No tests found` under this worktree path — an artifact of the worktree location, not a repository defect). `npm run test:integration` (`vscode-test`) is not a runnable gate in this repository — no `.vscode-test.{json,js,cjs,mjs}` config exists, so `@vscode/test-cli` exits 1 before starting a runner, both locally and on CI, and no workflow invokes it. For that command it is sufficient that the post-change output is identical to the recorded pre-edit baseline failure, and that mocha's forced `minimatch` consumption path is verified directly instead.
- [x] Extension toolchain passes: `npm run lint`, `npm run typecheck`, and `npm run compile` exit 0 in `extensions/drm-copilot`; extension unit-test coverage meets >=85% line / >=75% branch measured via the rootDir-free jest invocation that avoids the worktree `.claude` glob-escape artifact, with the worktree-path artifact documented in the evidence (the `npm run test:coverage` script reports `No tests found` under this worktree path — an artifact of the worktree location, not a repository defect).
- [x] All three `NPM Audit Gate` jobs succeed on the branch head SHA, verified via `gh run view <id> --json jobs`.
- [x] `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` are unmodified (`git diff --name-only main...HEAD` lists no `packages/mcp-server` paths).
- [x] The change set (`git diff --name-only main...HEAD`), after excluding paths under `docs/features/` and `artifacts/orchestration/` (feature documentation and the orchestration checkpoint), contains exactly four files: `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`.

## Risks & Mitigations
- **Primary risk — forced `minimatch` 9→10 major bump.** The unscoped `"minimatch": "^10.2.5"` override forces `glob@10.5.0` (declares `^9.0.4`) and `mocha@11.7.6` (declares `^9.0.5`, root only) onto a major version outside their declared ranges. Evidence that this is safe: (1) the only breaking change in minimatch 10.0.0 relative to 9.x is the Node 20/22 engine requirement, which CI (Node 20) and local (Node 24) satisfy; (2) orchestrator-verified inspection of the published tarballs confirms `minimatch@10.2.5` exports every name the forced consumers use (`Minimatch`, `escape`, `unescape`, `GLOBSTAR`, named `minimatch`) and still honors the `dot` and `windowsPathsNoEscape` options that mocha passes; (3) minimatch 10.x is already proven in-tree — `glob@13.0.6` under `@vscode/test-cli` and `c8` declares `minimatch ^10.2.2`, and six nested `minimatch@10.2.5` nodes already resolve in the root lockfile. Mitigation: the full toolchain matrix in Test Strategy (jest with coverage, vscode-test/mocha integration run, eslint, tsc) exercises the bumped path in both roots before merge.
- **Risk — latent breakage if only the `brace-expansion` override were applied.** `minimatch@9.0.9` would throw `TypeError` on brace-containing patterns only, so simple smoke checks could pass while `**/*.{ts,js}`-style globs fail later. Mitigation: the fix pairs the `minimatch` override so no minimatch-9 node survives; the lockfile assertion "no `minimatch@9.x` node" makes regression greppable.
- **Risk — stale-node retention after the override edit.** npm can retain a satisfying existing lockfile entry despite a new override. Mitigation: delete `node_modules` in the affected root and re-run `npm install`; the greppable lockfile assertions catch any residue.
- **Risk — a future advisory expands beyond `5.0.8`.** #397's floor failed because the advisory range expanded to include the then-latest release; no override operator can prevent a recurrence. Mitigation: the caret `^5.0.8` adopts any future patch via lockfile regeneration without a manifest edit, and the weekly scheduled `NPM Audit Gate` run (Mondays 07:00 UTC) is the detection mechanism.
- **Risk — future dependency requires `minimatch >= 11`.** Mitigation: npm fails resolution loudly at install time when an override forces a downgrade below a direct range; revisit the unscoped rule at that point.

## Rollout & Follow-up
- Release/rollout: single PR from `bug/npm-audit-brace-expansion` into `main`; confirm all three `NPM Audit Gate` legs green on the PR head SHA before merge. One remediation PR clears the identical deterministic failure on all other branches. No phased rollout needed.
- Post-fix monitoring: the weekly scheduled `NPM Audit Gate` run (Mondays 07:00 UTC) plus the manifest-path PR trigger provide ongoing advisory detection, including for the currently-clean `packages/mcp-server` tree.
- Follow-up (out of scope here): the repository root defines `test:integration` as `vscode-test`, but no `.vscode-test.{json,js,cjs,mjs}` configuration exists anywhere in the repository, `tsconfig.vscode-test.json` is absent, and no workflow invokes the script, so the command fails before starting a runner. This missing root `vscode-test` configuration is a separate pre-existing defect to be reported as a potential issue; it is out of scope for #414.
- Follow-up (out of scope here): two additional pre-existing conditions surfaced by the Phase 0 gate baseline are separate pre-existing defects to be filed, each out of scope for #414. Condition A: root `npm run format:check` exits 1 on `main` itself — Prettier flags `tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json` and `tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json`, which are byte-identical to `origin/main` (verified: `git diff --name-only origin/main -- tests/fixtures/discovery_schemas/` is empty). Condition B: the jest coverage scripts report `No tests found` when the worktree path contains the `.claude` dot-directory (jest renders the separator before the dot-directory as a backslash, which the glob matcher consumes as an escape); this is an artifact of the worktree location, would not reproduce on a CI runner or a normal checkout, and the suites are green under a rootDir-free invocation of the same binary and config.
- Follow-up (out of scope here): the required-check question — whether the three `NPM Audit Gate` legs should remain required, or whether the every-PR audit leg in `ci.yml` should move to the path-scoped + scheduled standalone workflow if advisory-day blockage becomes frequent — is a reported recommendation only (research artifact, section 7). Branch protection is not modified by this change.
- Links: issue #414 (<https://github.com/drmoisan/drm-copilot/issues/414>); predecessor issue #397 (superseded `c8`-scoped override); advisory <https://github.com/advisories/GHSA-mh99-v99m-4gvg>; research artifact `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/research/2026-07-25T10-45-brace-expansion-ghsa-mh99-remediation-research.md`.

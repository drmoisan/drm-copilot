# Research: Remediation of brace-expansion GHSA-mh99-v99m-4gvg (issue #414)

Timestamp: 2026-07-25T10-45
Branch: bug/npm-audit-brace-expansion (base: main)
Advisory: GHSA-mh99-v99m-4gvg — brace-expansion DoS via unbounded expansion (high, CVSS 7.5, CWE-400/CWE-770). Vulnerable range: `<=5.0.7`. Only fixed release: `5.0.8`.
Objective: `npm audit --audit-level=moderate` exits 0 in `.`, `extensions/drm-copilot`, and `packages/mcp-server`.

## Method Note (evidence provenance)

No shell commands were executed in this research session: `node_modules` is absent in all
three roots of this worktree and the research toolset was read-only. All findings derive
from (a) direct parsing of the committed `package-lock.json` files (lockfileVersion 3
contains the full resolved graph, so `npm ls` was unnecessary), and (b) fetches of the
published package contents from the npm registry/unpkg CDN. Each evidence item below
records `Source:` and `Observation:` in place of `Command:`/`EXIT_CODE:`; the executor
plan must capture `Command:`/`EXIT_CODE:`/`Output Summary:` when it runs the regeneration
and verification commands.

## 1. Dependency Graph (verified from lockfiles)

### Root (`package-lock.json`)

Two flagged nodes and their complete dependent chains:

`node_modules/brace-expansion` @ **5.0.7** (flagged; `<=5.0.7`):
- Consumed by every `minimatch@10.2.5` node, each declaring `"brace-expansion": "^5.0.5"`:
  - `node_modules/@eslint/config-array/node_modules/minimatch` (lock line 638)
  - `node_modules/@typescript-eslint/typescript-estree/node_modules/minimatch` (line 1732)
  - `node_modules/@vscode/test-cli/node_modules/minimatch` (line 2197)
  - `node_modules/c8/node_modules/minimatch` (line 2810)
  - `node_modules/eslint/node_modules/minimatch` (line 3578)
  - `node_modules/test-exclude/node_modules/minimatch` (line 6970)
- Upstream of those: `eslint@10.7.0` (`minimatch ^10.2.4`), `@eslint/config-array`
  (`^10.2.4`), `@typescript-eslint/typescript-estree` (`^10.2.2`), `@vscode/test-cli`
  (`glob ^13.0.6`, `minimatch ^10.2.5`), `c8@11.0.0` (`glob ^13.0.6`, `minimatch ^10.2.2`),
  `test-exclude@7.0.2` (`minimatch ^10.2.2`), `glob@13.0.6` (`minimatch ^10.2.2`).

`node_modules/minimatch/node_modules/brace-expansion` @ **2.1.2** (flagged; `<=5.0.7`):
- Sole dependent: `node_modules/minimatch` @ **9.0.9**, declaring `"brace-expansion": "^2.0.2"` (line 5534–5541). **This range excludes 5.x.**
- Dependents of `minimatch@9.0.9`:
  - `glob@10.5.0` (`"minimatch": "^9.0.4"`, line 4098) — itself depended on by
    `@jest/reporters@30.4.1` (`glob ^10.5.0`, line 1063), `jest-config@30.4.x`
    (`glob ^10.5.0`, line 4707), `jest-runtime@30.4.x` (`glob ^10.5.0`, line 5039),
    `mocha@11.7.6` (`glob ^10.4.5`, line 5593), `test-exclude@7.0.2` (`glob ^10.4.1`,
    line 6963).
  - `mocha@11.7.6` directly (`"minimatch": "^9.0.5"`, line 5598).

Exhaustive range check: every `"minimatch": "..."` declaration in the root lockfile is
`^10.2.2`/`^10.2.4`/`^10.2.5` except the two `^9.x` entries above (glob@10.5.0, mocha).
No `^3`, `^5`, or non-caret minimatch ranges exist.

### `extensions/drm-copilot` (`package-lock.json`)

`node_modules/brace-expansion` @ **5.0.7** (flagged): consumed by hoisted
`minimatch@10.2.5` (`^5.0.5`, line 5421–5428) serving eslint/typescript-eslint/test-exclude
consumers (`^10.2.2`/`^10.2.4`).

`node_modules/glob/node_modules/brace-expansion` @ **2.1.2** (flagged): sole dependent is
`node_modules/glob/node_modules/minimatch` @ **9.0.9** (`"brace-expansion": "^2.0.2"`,
line 4146–4153), which serves `glob@10.5.0` (`"minimatch": "^9.0.4"`, line 4111).
`glob@10.5.0` dependents: jest 30.4.x packages (`glob ^10.5.0`, lines 1515/4661/4967) and
`test-exclude@7.0.2` (`glob ^10.4.1`, line 6511). No mocha in this tree. The only `^9.x`
minimatch range is glob@10.5.0's.

### `packages/mcp-server` (`package-lock.json`)

Source: Grep for `brace-expansion|minimatch` over the lockfile.
Observation: zero matches. No `brace-expansion`, `minimatch`, or `glob` node exists.
Audit passes because the package family is absent, not because of any override.

### Nodes an unscoped brace-expansion override would forcibly major-bump

Exactly one node per affected root: `minimatch@9.0.9` (range `^2.0.2`), forced from
`brace-expansion@2.1.2` to `5.0.8`. All other consumers (`minimatch@10.2.5`) already
declare `^5.0.5`, for which 5.0.8 is an in-range patch.

## 2. API Compatibility of a Forced brace-expansion@5.0.8 (highest-risk question)

Verdict: **UNSAFE under minimatch@9; SAFE under minimatch@10.** Forcing 5.0.8 beneath
`minimatch@9.0.9` breaks its brace expansion at runtime. Evidence:

- `brace-expansion@2.1.2` (`index.js`, unpkg): plain CommonJS function export —
  `module.exports = expandTop;` where `expandTop(str, options)` is the expansion function.
- `brace-expansion@5.0.8` (`dist/commonjs/index.js`, unpkg): tshy/tsc output with
  `Object.defineProperty(exports, "__esModule", { value: true });` and **named export
  only**: `exports.expand = expand;` (plus `exports.EXPANSION_MAX`,
  `exports.EXPANSION_MAX_LENGTH`). **No default export.** The ESM build
  (`dist/esm/index.js`) likewise exports only `export function expand(...)` and two
  consts — **no `export default`.**
- `minimatch@9.0.9` (`dist/commonjs/index.js`, unpkg) consumes it as a **default import**:
  `const brace_expansion_1 = __importDefault(require("brace-expansion"));` then
  `return (0, brace_expansion_1.default)(pattern);`. The `__importDefault` helper returns
  the module unchanged when `__esModule` is true — so with 5.0.8,
  `brace_expansion_1.default` is `undefined` and the call throws
  `TypeError: brace_expansion_1.default is not a function`. The ESM build's
  `import expand from 'brace-expansion'` fails at module-link time for the same reason
  (no default export).
- Failure mode is **latent, not immediate**: minimatch 9's `braceExpand` short-circuits
  when the pattern contains no `{...}`, so simple patterns keep working and the break
  surfaces only on brace-containing globs (e.g. `**/*.{ts,js}`) inside jest, glob, and
  mocha. This makes the unscoped brace-expansion override, on its own, a silent breakage
  risk rather than a fail-fast one.
- `minimatch@10.2.5` (`dist/commonjs/index.js`, unpkg) consumes the **named export**:
  `const brace_expansion_1 = require("brace-expansion");` then
  `(0, brace_expansion_1.expand)(pattern, { max: options.braceExpandMax });`. This is why
  minimatch 10.2.x declares `brace-expansion ^5.0.5` and why the existing hoisted
  5.0.7 node already works in both trees today.

Conclusion: option (a) as literally stated (unscoped `brace-expansion ^5.0.8` alone) is
rejected. The safe fix must first eliminate `minimatch@9.0.9` from both trees.

## 3. Remediation Option Comparison

### (b) Plain lockfile refresh — rejected

`minimatch@9.0.9` pins `brace-expansion ^2.0.2`; no fixed release exists inside that range
(all 1.x/2.x/3.x maintenance releases are `<=5.0.7` and vulnerable). Regeneration cannot
change the resolved major without a manifest-level instruction. No effect on the audit.

### (c) Direct-dependency upgrades — rejected (unavailable upstream)

- `jest-config@latest` = 30.4.2 (already in tree) still declares `"glob": "^10.5.0"`
  (npm registry, fetched 2026-07-25).
- `mocha@latest` = 11.7.6 (already in tree) still declares `"glob": "^10.4.5"` and
  `"minimatch": "^9.0.5"` (npm registry, fetched 2026-07-25).
No published upstream versions remove the `glob@10 -> minimatch@9 -> brace-expansion@2`
chain. `npm audit`'s own `fixAvailable` is a jest major DOWNGRADE to 25.0.0 and must not
be used.

### (a′) RECOMMENDED: paired unscoped overrides `minimatch ^10.2.5` + `brace-expansion ^5.0.8`

Force every minimatch node to 10.2.5 (which consumes the 5.x named export), then floor
brace-expansion at the fixed 5.0.8. After this, no consumer of the 2.x default-export API
remains in either tree, so the forced brace-expansion bump is safe.

Compatibility evidence for the forced `minimatch 9.0.9 -> 10.2.5` bump (only `glob@10.5.0`
and root `mocha@11.7.6` are out-of-range consumers):

- minimatch changelog (isaacs/minimatch, `changelog.md`): the only breaking change in
  10.0.0 relative to 9.x is "Require node 20 or 22 and higher". 10.1/10.2 are additive
  (`magicalBraces`, `braceExpandMax`, `makeRe` fixes). CI runs Node 20; local is Node 24.
- `glob@10.5.0` consumption surface (unpkg, `dist/commonjs/`): `index.js` re-exports
  `escape`/`unescape` from minimatch; `glob.js` uses `new minimatch_1.Minimatch(p, mmo)`
  with options `dot, matchBase, nobrace, nocase, nocaseMagicOnly, nocomment, noext,
  nonegate, optimizationLevel, platform, windowsPathsNoEscape, debug` — all present in
  minimatch 10 (glob 13.0.6, already working in both trees against minimatch@10.2.5 +
  brace-expansion@5.0.7, is the same codebase lineage consuming the same surface;
  `glob@latest` (13.0.6) declares `minimatch ^10.2.2`).
- `mocha@11.7.6` consumption surface (unpkg, `lib/cli/watch-run.js`): named import
  `const { minimatch } = require('minimatch')`, called as
  `minimatch(filePath, globPath, { dot: true, windowsPathsNoEscape: true })`. The named
  `minimatch` export and both options exist unchanged in 10.x. `lib/cli/lookup-files.js`
  uses `glob.sync`/`glob.hasMagic` only (glob itself is not being bumped).

Engine note: `brace-expansion@5.0.8` declares `engines.node: "20 || >=22"` and
`minimatch@10.2.5` declares `"18 || 20 || >=22"`. The audit gate and extension-test
workflows pin Node 20 (`actions/setup-node` `node-version: "20"`); local development is
Node 24.14.0. No environment in scope runs Node 18 for these dev-only trees.

Blast radius: dev-dependency subtree only (`dev: true` on every affected node in both
lockfiles). Runtime dependency `@modelcontextprotocol/sdk` does not consume minimatch or
brace-expansion in either lockfile graph.

#### Exact manifest edits

Root `package.json` — replace the current `overrides` block with (literal JSON; removes
the now-redundant `c8` scope, adds two unscoped entries):

```json
"overrides": {
  "diff": "^8.0.3",
  "serialize-javascript": "^7.0.5",
  "fast-uri": "^3.1.4",
  "hono": "^4.12.27",
  "ip-address": "^10.2.0",
  "qs": "^6.15.2",
  "@babel/core": "^7.29.6",
  "js-yaml": "^4.2.0",
  "@hono/node-server": "^2.0.5",
  "brace-expansion": "^5.0.8",
  "minimatch": "^10.2.5",
  "babel-plugin-istanbul": {
    "test-exclude": "^7.0.2"
  }
}
```

`extensions/drm-copilot/package.json` — replace the current `overrides` block with:

```json
"overrides": {
  "fast-uri": "^3.1.4",
  "hono": "^4.12.27",
  "ip-address": "^10.2.0",
  "qs": "^6.15.2",
  "@babel/core": "^7.29.6",
  "js-yaml": "^4.2.0",
  "@hono/node-server": "^2.0.5",
  "brace-expansion": "^5.0.8",
  "minimatch": "^10.2.5",
  "babel-plugin-istanbul": {
    "test-exclude": "^7.0.2"
  }
}
```

`packages/mcp-server/package.json` — no change (see section 6).

Disposition of the existing `"c8": { "brace-expansion": "^5.0.7" }` entry: **remove it**
in both manifests. With an unscoped `brace-expansion` rule present, the scoped rule is
redundant (the unscoped floor is higher) and, because scoped rules take precedence inside
the `c8` subtree, retaining the stale `^5.0.7` floor there only adds a second place a
future reader must reason about. c8's own chain (`glob@13 -> minimatch@10.2.x ->
brace-expansion ^5.0.5`) resolves to 5.0.8 under the unscoped rule.

#### Exact regeneration command sequence (per root, in `.` then `extensions/drm-copilot`)

```powershell
# after editing package.json overrides
npm install            # re-resolves with new overrides, rewrites package-lock.json and node_modules
npm audit --audit-level=moderate   # must exit 0
```

If npm retains stale resolved nodes despite the override change (a known npm behavior
when a satisfying lockfile entry already exists), force full re-resolution:

```powershell
Remove-Item node_modules -Recurse -Force -ErrorAction SilentlyContinue
npm install
npm audit --audit-level=moderate
```

Post-regeneration lockfile assertions (deterministic, greppable):
- No `"version": "9.0.9"` minimatch node and no `brace-expansion` node at `2.1.2` or
  `5.0.7` remains in either lockfile.
- A single hoisted `node_modules/brace-expansion` at `5.0.8` (with
  `balanced-match@4.x`) per tree.
- `packages/mcp-server/package-lock.json` is byte-identical (untouched).

### Rejected alternatives (summary)

- (a) Unscoped `brace-expansion ^5.0.8` alone: breaks `minimatch@9.0.9` (default-import
  vs named-export mismatch, section 2). Rejected.
- (b) Lockfile refresh only: cannot escape `^2.0.2`. Rejected.
- (c) Direct-dependency upgrades: latest jest/mocha still declare the vulnerable chain.
  Rejected as unavailable.
- Scoped variant (`"glob": {"minimatch": "^10.2.5"}` + `"mocha": {...}` + unscoped
  brace-expansion): functionally equivalent here but more rules to maintain and easier to
  miss a future `^9.x` consumer; the unscoped minimatch rule is safe because the lockfiles
  contain no minimatch consumer below `^9.x`. Rejected in favor of the simpler unscoped pair.
- Unscoped `"glob": "^13"` override: forces a two-major glob bump under jest with a larger
  untested API surface (engines, iterator API changes) for no additional audit benefit.
  Rejected.
- `npm audit fix --force`: downgrades jest to 25.0.0. Prohibited by the delegation and
  rejected.

## 4. Durability

- **Survives `npm install`:** yes. `overrides` are enforced at every resolution; a
  developer or CI `npm ci`/`npm install` cannot silently reintroduce `2.1.2`/`5.0.7`
  while the rules exist. The lockfile assertions above make regressions greppable.
- **Survives the next advisory-database update:** conditionally. #397's `^5.0.7` floor
  failed because the advisory range later expanded to include the then-latest 5.0.7 —
  a data change, not an install change. No override operator can immunize against a future
  advisory covering `<=5.0.8`. The caret `^5.0.8` is still the correct operator: if
  5.0.9+ ships, a lockfile regeneration (or `npm update brace-expansion`) adopts it with
  no manifest edit, whereas an exact pin would guarantee a second manifest change. The
  weekly scheduled `npm Audit Gate` run (Mondays 07:00 UTC) is the detection mechanism for
  that scenario and is already in place.
- **Structural improvement over #397:** the failure mode this time was not the floor value
  but the *scope* (`c8`-only) plus an unfixable `^2.0.2` pin at `minimatch@9`. The
  recommended fix removes the 2.x line from both trees entirely, so a future advisory
  against the 1.x–4.x lines can no longer flag these trees at all.
- **Maintenance note:** the unscoped `"minimatch": "^10.2.5"` rule should be revisited if
  a future dependency requires `minimatch >= 11`; npm will surface the conflict at
  install time (an override forcing a downgrade below a direct range fails resolution
  loudly rather than silently).

## 5. Toolchain Risk and Minimum Verification Set

Commands most exposed to the forced `minimatch 9 -> 10` bump (all read from `package.json`
scripts; TypeScript rule file `.claude/rules/typescript.md` defines the format -> lint ->
type-check -> test order):

Highest exposure (consume the changed `glob@10.5.0 -> minimatch` path):
- Root `npm run test:unit` / `test:unit:coverage` (jest 30.4.x: `@jest/reporters`,
  `jest-config`, `jest-runtime` all glob through the bumped node; coverage additionally
  exercises `test-exclude@7.0.2`).
- Root `npm run test:integration` (`vscode-test`: `@vscode/test-cli` + `mocha@11.7.6`;
  mocha is the only direct `minimatch ^9.0.5` consumer).
- Extension `npm run test` / `test:coverage` (jest via the extension tree's bumped node).

Lower exposure (minimatch path unchanged at 10.2.5; only brace-expansion 5.0.7 -> 5.0.8
patch): root/extension `npm run lint` (eslint), `npm run format:check` (prettier — no
glob dependency in chain), `npm run typecheck`/`compile` (tsc/esbuild).

Minimum verification set proving no breakage (run after `npm ci` in each root):
1. Root: `npm run format:check`, `npm run lint`, `npm run typecheck`,
   `npm run test:unit:coverage`, `npm run test:integration`.
2. Extension: `npm run lint`, `npm run typecheck`, `npm run compile`,
   `npm run test:coverage`.
3. mcp-server: `npm ci` + `npm run build` (confirms the untouched lockfile still installs;
   no test script exists in this root).
4. All three roots: `npm audit --audit-level=moderate` exit 0.
CI equivalents: `NPM Audit Gate` (three matrix legs, Node 20, runs `npm ci` first — this
also proves lockfile/manifest sync) and `drm-copilot Extension Tests` (windows + ubuntu,
Node 20). Record each command per the evidence schema
(`Command:`/`EXIT_CODE:`/`Output Summary:`) under
`docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/`.

## 6. `packages/mcp-server` Handling

Recommendation: **leave untouched.** Verified: its lockfile contains no `brace-expansion`,
`minimatch`, or `glob` node, and its dependency tree (`@modelcontextprotocol/sdk` +
`esbuild`) has no path to them. A defensive override would be dead configuration that npm
cannot exercise or validate; when a future dependency someday introduces the package, a
blind pre-pinned floor could be wrong for that consumer's import style — section 2 shows
exactly how a range-only view of compatibility breaks (named vs default export). The
weekly scheduled audit gate plus the manifest-path PR trigger already provide the
regression detection for that future event. Zero blast radius today outweighs speculative
protection.

## 7. Required-Check Status and Recommendation

Observed configuration (files only; live branch protection is not readable from the repo):
- `.github/workflows/ci.yml` runs job `npm-audit-gate` (display name `NPM Audit Gate`)
  via `_npm-audit-gate.yml` on **every** push/PR to `main`/`development` — not only
  manifest-touching PRs.
- `.github/workflows/npm-audit-gate.yml` additionally runs the same reusable workflow on
  PRs touching `**/package.json` / `**/package-lock.json` / the two workflow files, on a
  weekly cron (Mon 07:00 UTC), and on dispatch.
- Documentary evidence that the gate is already a required check: issue #397 artifacts
  record verification via `gh pr checks 398 --required` that "all required checks,
  including all three `NPM Audit Gate` legs" were green
  (`docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/spec.md`,
  acceptance line "`NPM Audit Gate` required check is green on the PR head SHA").

Recommendation: **keep the three `NPM Audit Gate` legs required; do not add new required
checks.** Rationale: the repository's quality posture treats supply-chain gates as
blocking, and #397/#414 demonstrate the remediation loop completes within a day.
Tradeoff acknowledged: because ci.yml runs the audit on every PR, a newly published
third-party advisory can block unrelated PRs. Two mitigations already exist and should be
relied on rather than weakening the gate: (1) the Monday scheduled run usually surfaces
new advisories on a non-PR path first, creating a dedicated remediation issue before
unrelated PRs are affected; (2) `npm audit` reads the committed lockfile, so the failure
is deterministic and identical across PRs — one remediation PR (like this one) clears all
of them. If advisory-day blockage becomes frequent, the proportionate adjustment is to
move the every-PR audit leg out of `ci.yml` and rely on the path-scoped + scheduled
standalone workflow, not to demote the check from required. No configuration change is
made or requested by this research.

## 8. Behavior Semantics

- Success: `npm ci && npm audit --audit-level=moderate` exits 0 in all three roots on
  Node 20; root and extension lockfiles contain exactly one `brace-expansion` node each,
  at `>=5.0.8`; no `minimatch` node below 10.x remains; mcp-server artifacts unchanged.
- Failure conditions to guard: lockfile/manifest desync (gate's `npm ci` fails);
  partial application (matrix legs are independent — fixing one root leaves the check
  red); a new advisory published between fix and merge (re-run audit at PR time);
  stale-node retention after override edit (use the delete-and-reinstall fallback and the
  greppable lockfile assertions).
- Ordering: edit both manifests before regenerating either lockfile is not required —
  the two roots are independent npm projects; regenerate and verify per root.

## 9. Requirements Mapping (proposed change set)

| File | Change |
|---|---|
| `package.json` (root) | Replace `overrides` block as specified in section 3 (add unscoped `brace-expansion ^5.0.8` + `minimatch ^10.2.5`; delete `c8` scoped block) |
| `package-lock.json` (root) | Regenerated by `npm install`; assert no 9.0.9/2.1.2/5.0.7 nodes |
| `extensions/drm-copilot/package.json` | Same overrides edit |
| `extensions/drm-copilot/package-lock.json` | Regenerated; same assertions |
| `packages/mcp-server/**` | Unchanged |

## 10. Testing Implications

No production code changes; no new unit tests are warranted (test policy scopes unit
tests to units of behavior, and the change is dependency resolution only). Verification is
the toolchain matrix in section 5 plus the audit exit-code gate, with evidence recorded
under `evidence/qa-gates/` per the evidence schema. A fail-before artifact is available
cheaply: capture `npm audit --audit-level=moderate` output (exit 1, 22 high) in root and
extension before the manifest edit, under `evidence/baseline/`.

## 11. Automation Feasibility

Fully automatable. The remediation consists of deterministic JSON edits to two committed
manifests, lockfile regeneration via `npm install`, and exit-code-verifiable gates
(`npm audit`, jest, eslint, tsc, esbuild, vscode-test). No third-party UI, credential
issuance, or human approval step is involved anywhere in the change or its verification;
the only human-gated step is the ordinary PR merge.

## Sources Consulted

- `package-lock.json` (root), `extensions/drm-copilot/package-lock.json`,
  `packages/mcp-server/package-lock.json` — direct parse (line numbers cited above).
- `package.json` in all three roots.
- unpkg (published package contents): `brace-expansion@2.1.2/index.js`,
  `brace-expansion@5.0.8/package.json`, `brace-expansion@5.0.8/dist/commonjs/index.js`,
  `brace-expansion@5.0.8/dist/esm/index.js`, `minimatch@9.0.9/dist/commonjs/index.js`,
  `minimatch@10.2.5/dist/commonjs/index.js`, `glob@10.5.0/dist/commonjs/index.js`,
  `glob@10.5.0/dist/commonjs/glob.js`, `mocha@11.7.6/lib/cli/lookup-files.js`,
  `mocha@11.7.6/lib/cli/watch-run.js`.
- npm registry metadata: `jest-config@latest` (30.4.2), `mocha@latest` (11.7.6),
  `glob@latest` (13.0.6).
- github.com/isaacs/minimatch `changelog.md` (10.x breaking-change entries).
- Repo: `.github/workflows/ci.yml`, `npm-audit-gate.yml`, `_npm-audit-gate.yml`,
  `_drm-copilot-extension-tests.yml`, `.claude/rules/typescript.md`,
  `docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/` (spec, research).

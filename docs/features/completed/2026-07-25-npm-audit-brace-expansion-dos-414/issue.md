# npm-audit-brace-expansion-dos (Issue #414)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-audit-brace-expansion-dos/ (Issue #414)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #414
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/414
- Last Updated: 2026-07-25
- Work Mode: full-bug

## Summary

The `NPM Audit Gate` jobs for the repository root (`.`) and `extensions/drm-copilot` fail at `--audit-level=moderate` because a newly published high-severity advisory for `brace-expansion` (GHSA-mh99-v99m-4gvg) declares the vulnerable range as `<=5.0.7`, which invalidates the `^5.0.7` override floor that issue #397 committed on 2026-07-22.

## Environment

- OS/version: GitHub Actions `ubuntu-latest` runner (CI, Node.js 20); reproduced locally on Windows 11 with Node.js v24.14.0 / npm 11.9.0.
- Python version: not applicable (npm dependency-manifest defect).
- Command/flags used: `npm audit --audit-level=moderate` in each package root; `npm audit --json` for advisory detail.
- Data source or fixture: `package-lock.json` at `.` and `extensions/drm-copilot` on `main` at `73b3f2a2`.

## Steps to Reproduce

1. Check out `main` at `73b3f2a2` (no branch changes required — the failing input is the live npm advisory database, not any diff).
2. Run `npm audit --audit-level=moderate` in the repository root. It exits non-zero with 22 high-severity advisory paths.
3. Run the same command in `extensions/drm-copilot`. It also exits non-zero.
4. Run the same command in `packages/mcp-server`. It exits 0 with `found 0 vulnerabilities`.

## Expected Behavior

All three `NPM Audit Gate` matrix jobs (`.`, `extensions/drm-copilot`, `packages/mcp-server`) exit 0 at `--audit-level=moderate`.

## Actual Behavior

Two of three jobs fail. CI run `30164280177` failed `NPM Audit Gate / npm audit (.)` and `NPM Audit Gate / npm audit (extensions/drm-copilot)`; `packages/mcp-server` passed. A local `npm audit --json` at the root reports `{"info":0,"low":0,"moderate":0,"high":22,"critical":0,"total":22}`, all 22 paths attributable to a single advisory:

- `brace-expansion` — "DoS via unbounded expansion length causing an out-of-memory process crash"
- <https://github.com/advisories/GHSA-mh99-v99m-4gvg>
- CWE-400, CWE-770; CVSS 7.5 (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`)
- Vulnerable range: `<=5.0.7`

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```text
metadata: {"info":0,"low":0,"moderate":0,"high":22,"critical":0,"total":22}
severity: high isDirect: false
nodes: ["node_modules/brace-expansion","node_modules/minimatch/node_modules/brace-expansion"]
range: "<=5.0.7"
effects: ["minimatch"]
fixAvailable: {"name":"jest","version":"25.0.0","isSemVerMajor":true}
```

Lockfile-resolved versions of the two flagged nodes:

```text
root: node_modules/brace-expansion                        -> 5.0.7   (flagged)
root: node_modules/minimatch/node_modules/brace-expansion -> 2.1.2   (flagged)
ext:  node_modules/brace-expansion                        -> 5.0.7   (flagged)
ext:  node_modules/glob/node_modules/brace-expansion      -> 2.1.2   (flagged)
```

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Rationale: the gate fails on `main` itself, so every branch inherits a red `NPM Audit Gate`. There is no runtime user impact — `brace-expansion` arrives only through developer tooling (`minimatch`/`glob` under ESLint, Jest, and `c8`), not through any shipped runtime path.

## Suspected Cause / Notes

- Not caused by any recent branch. The same lockfiles passed the same gate on `main` earlier the same day (runs `30129056914` and `30126891939`, all three npm audit jobs `success`). The changed input is the advisory database.
- Issue #397 (CLOSED 2026-07-22T13:25:37Z) previously remediated a *different* set of npm advisories and committed `"c8": { "brace-expansion": "^5.0.7" }` into the `overrides` block of the root and `extensions/drm-copilot` manifests. The new advisory's `<=5.0.7` range makes that floor insufficient, so this is a new defect rather than a regression of #397's work.
- The published version list shows `5.0.8` as `latest` and the only release above the vulnerable range. The maintenance dist-tags (`maintenance-v1: 1.1.16`, `maintenance-v2: 2.1.2`, `maintenance-v3: 3.0.2`) are all `<=5.0.7` and therefore all still flagged; **there is no patched 1.x/2.x/3.x/4.x line**.
- Consequence: the existing `c8`-scoped override cannot fix this, because the second flagged node is nested under `minimatch` (root) / `glob` (extensions), outside the `c8` scope. Remediation must reach every `brace-expansion` node in the tree.
- `npm audit`'s own `fixAvailable` suggests downgrading `jest` to `25.0.0` (`isSemVerMajor: true`). That is not a viable remediation; `npm audit fix --force` must not be used.
- Compatibility signal for a global pin: `brace-expansion@5.0.8` is dual-published — `"main": "./dist/commonjs/index.js"` with an `exports` map carrying both `import` and `require` conditions — so a CJS `require('brace-expansion')` from `minimatch`/`glob` still resolves. Its `engines` field is `"node": "20 || >=22"`, which both CI (Node 20) and local (Node 24) satisfy.
- `packages/mcp-server` passes because it has **no** `brace-expansion` node in its tree at all, not because of its `overrides` block (which contains `fast-uri`, `hono`, `ip-address`, `qs`, `@hono/node-server` and no `brace-expansion` entry).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: none — dependency-manifest change only, no source modules affected.
- [ ] Integration scenario to retest: full toolchain in each affected root (ESLint, Jest, `tsc`, extension build) because the lockfile refresh moves `minimatch`/`glob`/`c8` transitives that the tooling loads.
- [ ] Manual verification notes: run `npm audit --audit-level=moderate` in **each** of `.`, `extensions/drm-copilot`, and `packages/mcp-server` and confirm exit 0 in all three; then confirm all three `NPM Audit Gate` jobs succeed on the branch via `gh run view <id> --json jobs`.

Candidate remediations to evaluate on blast radius and durability:

1. Promote the existing `c8`-scoped `brace-expansion` override to an unscoped `overrides` entry pinning `^5.0.8` in the root and `extensions/drm-copilot` manifests, then regenerate each lockfile. Follows the established `overrides` precedent already present in all three manifests.
2. Plain lockfile refresh only. Expected to be insufficient for the `minimatch`/`glob`-nested `2.1.2` node, because the parent's declared range does not admit 5.x.
3. Direct-dependency upgrades that pull fixed transitives. Highest blast radius; `npm audit`'s suggested `jest@25.0.0` downgrade is a regression, not an upgrade.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

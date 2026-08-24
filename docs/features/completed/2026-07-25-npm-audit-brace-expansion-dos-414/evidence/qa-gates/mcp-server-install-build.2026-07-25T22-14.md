# mcp-server Untouched-Lockfile Install Check (#414, [P5-T7])

Timestamp: 2026-07-25T22-14

Purpose: confirm the untouched `packages/mcp-server` lockfile still installs and builds cleanly after the root and extension trees were regenerated. No test script exists in this root.

## Command 1 — `npm ci`

Command: `npm ci` (working directory: `packages/mcp-server`)
EXIT_CODE: 0

```text
added 95 packages, and audited 96 packages in 3s

30 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

`npm ci` fails hard on manifest/lockfile drift, so exit 0 proves `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` remain in sync — they were never edited. No `glob` deprecation warning appears here because this tree contains no `glob`, `minimatch`, or `brace-expansion` node, which is why the root passed the audit gate before this change.

## Command 2 — `npm run build`

Command: `npm run build` (working directory: `packages/mcp-server`)
EXIT_CODE: 0

```text
> @danmoisan/drm-copilot-mcp@1.0.19 build
> node esbuild-mcp-server.cjs
```

## No-Modification Confirmation

Command: `git status --porcelain packages/mcp-server` (working directory: repository root)
EXIT_CODE: 0

```text
(no output — zero modified or untracked committed paths under packages/mcp-server)
```

The install and build wrote only git-ignored artifacts (`node_modules/`, bundle output). No committed file under `packages/mcp-server` was modified, so `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` remain byte-identical to `main`, as `spec.md` requires.

Output Summary: PASS on both commands. `npm ci` exits 0 in `packages/mcp-server`, installing 95 packages and auditing 96 with `found 0 vulnerabilities`, proving the untouched lockfile is still valid and in sync with its manifest. `npm run build` exits 0. `git status --porcelain packages/mcp-server` returns no output afterward, confirming no committed file in that root was modified by the check.

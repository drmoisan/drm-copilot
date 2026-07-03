# AC Verification

## AC1 — `packages/mcp-server/` publishable package.json

Status: PASS
Supporting artifact: `packages/mcp-server/package.json`
Verification: `node -e "const p=require('./packages/mcp-server/package.json');process.exit(p.name==='@danmoisan/drm-copilot-mcp'&&p.version==='0.0.1'&&p.bin['drm-copilot-mcp']==='./out/mcp-server.js'&&p.files.includes('out/mcp-server.js')&&p.files.includes('resources')&&p.engines.node==='>=18.0.0'&&p.type==='commonjs'?0:1)"` — EXIT 0.

## AC2 — `out/mcp-server.js` starts with `#!/usr/bin/env node`

Status: PASS
Supporting artifact: `packages/mcp-server/out/mcp-server.js`
Verification: `Get-Content packages/mcp-server/out/mcp-server.js -TotalCount 1` — output: `#!/usr/bin/env node`.

## AC3 — npm pack tarball includes `out/mcp-server.js` and `resources/` tree; excludes test sources

Status: PASS
Supporting artifact: `artifacts/evidence/post-change/npm-pack-listing.md`
Verification: `tar -tzf packages/mcp-server/danmoisan-drm-copilot-mcp-0.0.1.tgz` — `package/out/mcp-server.js` present; `package/resources/` entries present; 0 `.ts` files; 0 `esbuild-mcp-server.cjs` entries.

## AC4 — Top-level MIT LICENSE at repo root

Status: PASS
Supporting artifact: `LICENSE`
Verification: `Test-Path LICENSE` → True; `Select-String 'MIT License' LICENSE` → match; `Select-String 'Dan Moisan' LICENSE` → match.

## AC5 — `.github/workflows/publish-mcp-npm.yml` present with correct trigger, dependency, NPM_TOKEN, and publish command

Status: PASS
Supporting artifact: `.github/workflows/publish-mcp-npm.yml`
Verification: `Select-String 'mcp-server-v'` → match; `needs: drm-copilot-extension-tests` → match; `NPM_TOKEN` → match; `npm publish --access public` → match; YAML valid.

## AC6 — `packages/mcp-server/README.md` documents installation, config snippet, and runtime prerequisites

Status: PASS
Supporting artifact: `packages/mcp-server/README.md`
Verification: `Select-String 'npx -y @danmoisan/drm-copilot-mcp'` → match; `"command": "npx"` → match; `Node >=18` → match; `Python 3` → match.

## AC7 — Package version equals extensions/drm-copilot/package.json version

Status: PASS
Supporting artifact: `packages/mcp-server/package.json`, `extensions/drm-copilot/package.json`
Verification: Both have version `0.0.1`.

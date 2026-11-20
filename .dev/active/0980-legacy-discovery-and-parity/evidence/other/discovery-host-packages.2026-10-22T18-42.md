# Discovery host packages (P10-T2)

Timestamp: 2026-10-22T18-42
Command: node SCRATCH/issue-980-p10t2-build.cjs (npm run compile in extensions/drm-copilot; npx --yes @vscode/vsce package --allow-missing-repository --skip-license --out SCRATCH/stage/drm-copilot.vsix; npm run build in packages/mcp-server; npm pack --pack-destination SCRATCH/stage), then poetry run python -I SCRATCH/issue-980-p10t2-inspect.py
EXIT_CODE: 0 (build), 0 (inspection, DEFECTS=0)
Output Summary: Both distributables were built from the regenerated bundles into SCRATCH/stage and inspected without extraction.

## VSIX (extension 1.1.22)

- File: `drm-copilot.vsix`, 795 files, 3,077,451 bytes, SHA-256 `d7ad4748cd8936cc4f35d065958987d503085f24e9e32df98d8b150cef6a4ee7`.
- `vsce` tree: claude-customizations 304 files, codex-and-agents-customizations 289 files, customizations 135 files (now including `.github/hooks`, the four role agents and the sixteen skills), config 3, feature-templates 11, lib 14 (codex-routing and the eleven shared discovery helpers), powershell 12, templates 15.
- Closure: all 58 required native entries present (shared helpers under `lib/discovery-validation` and the Claude bundle including `DiscoveryValidation.psm1`, the six GitHub hook files, five Claude hooks, five Codex hooks, the four roles on each host, the routing config on both roots, `settings.json`, `config.toml`, the setup templates and the PoshQC module); 0 Python, bytecode or `__pycache__` entries; no `resources/scripts` tree; `extension/out/mcp-server.js` present and free of any `require("vscode")` (host module shimmed).

## Standalone MCP package (@danmoisan/drm-copilot-mcp 1.1.22)

- File: `danmoisan-drm-copilot-mcp-1.1.22.tgz`, 789 files, 1,862,240 bytes, SHA-256 `3681c32cf89a3f8e9a01768e4ffa67d886bbe79d651052cc64ab9ac763464218`.
- `prepack.cjs` copied the extension resources with the Python-source and root-`scripts` exclusions unchanged; `files` is `out/mcp-server.js` and `resources`.
- Closure: all 58 required native entries present under `package/resources/`; 0 Python entries; `package/out/mcp-server.js` present, built from the same `extensions/drm-copilot/src/mcp-server.ts` entry, free of `require("vscode")`, and carrying the explicit wheel requirement `drm_copilot_discovery-2.0.0-py3-none-any.whl` and the gateway module `drm_copilot_discovery.gateway` in its runtime messages.

## Packaging allowlists

- No change to `packages/mcp-server/prepack.cjs` or `extensions/drm-copilot/.vscodeignore` was needed: every newly mapped non-Python resource (GitHub hooks and registration, Claude and Codex discovery hooks, shared helpers, routing config, templates) is admitted by both, and both keep the explicit `**/*.py` and root `scripts` exclusions. The contract is now pinned by `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` and the extended `mcp-server-prepack.test.ts`.
- The worktree carries no build residue: `extensions/drm-copilot/out`, `packages/mcp-server/{out,resources}`, `*.vsix` and `*.tgz` are gitignored and the staged artifacts live only under SCRATCH.

## Notes

- Python business logic is not copied into either package; the Python engine ships separately as the discovery wheel (P10-T3) and the TypeScript gateway client names that wheel explicitly.
- The `vsixmanifest` `PackageManifest Version="2.0.0"` attribute is the manifest schema version; the extension version is 1.1.22 from `package.json`.

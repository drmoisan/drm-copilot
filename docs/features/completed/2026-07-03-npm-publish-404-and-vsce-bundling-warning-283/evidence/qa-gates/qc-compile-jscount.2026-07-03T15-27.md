# QC — Post-Change Compile and JS File Count

Timestamp: 2026-07-03T15-27
Command: `npm --prefix extensions/drm-copilot run compile` then `(Get-ChildItem -Path extensions/drm-copilot/out -Filter *.js -Recurse | Measure-Object).Count` (equivalent: `find extensions/drm-copilot/out -name "*.js" | wc -l`)
EXIT_CODE: 0

Output Summary: `tsc -p ./ --noEmit && npm run bundle:extension && npm run bundle:mcp-server` completed successfully. Post-change `.js` file count under `extensions/drm-copilot/out`: 2 (`out/extension.js` and `out/mcp-server.js`, both confirmed present). Compared to the Phase 0 baseline of 128, this is a reduction of 126 files (128 -> 2), materially smaller and eliminating the per-source-file unbundled layout that produced the `vsce package` bundling warning.

## Note on mid-execution discovery and fix

During this task, `npm run compile` initially failed with `Could not resolve "out/mcp-server.js"` because the pre-existing `esbuild-mcp-server.cjs` bundled from `out/mcp-server.js` (a file previously produced by `tsc -p ./` in emit mode). Changing `compile`/`build` to `tsc -p ./ --noEmit` per P1-T4/P1-T5 means `tsc` no longer emits any `.js` file, so that entry point could never resolve. This was a mechanical consequence of the plan's own prescribed script change, not a new independent feature. The fix applied: `extensions/drm-copilot/esbuild-mcp-server.cjs`'s `entryPoints` was changed from `["out/mcp-server.js"]` to `["src/mcp-server.ts"]`, mirroring the same source-direct bundling pattern the plan already specifies for `esbuild-extension.cjs`. No other behavior of `esbuild-mcp-server.cjs` (bundle/platform/target/outfile/plugins) was changed. This file was not named in the approved plan's task list; it is flagged here for reviewer awareness per the atomic-executor escalation protocol.

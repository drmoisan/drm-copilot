# Discovery host packages rebuild on the final tree (P14-T12)

Timestamp: 2026-10-29T12-26
Task: [P14-T12] Rebuild the distributables with the corrected runtime and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-packages.sh (the P10-T2 sequence: npm run compile in extensions/drm-copilot; npx --yes @vscode/vsce package --allow-missing-repository --skip-license --out SCRATCH/stage/drm-copilot.vsix; npm run build in packages/mcp-server; npm pack --pack-destination SCRATCH/stage); node run-jest.cjs test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts (in extensions/drm-copilot)
EXIT_CODE: 0 (compile), 0 (vsce), 0 (mcp-server build), 0 (npm pack), 0 (Jest 2 suites, 14 passed)
Output Summary: Both distributables were rebuilt from the final sources into SCRATCH/stage. Neither contains a Python, bytecode or `__pycache__` entry (0 matches in each listing), so no Python business logic is copied into the host packages. The packaging contract suites pass unchanged (2 suites, 14 tests).

## VSIX (extension 1.1.22)

- File: `drm-copilot.vsix`, 800 files, 3,120,731 bytes, SHA-256 `efe92788da4fe743f4ee46f41edc38407c11e4f5de1e7085fc5dcc22dad73fbc`.
- Python entries: 0.

## Standalone MCP package (@danmoisan/drm-copilot-mcp 1.1.22)

- File: `danmoisan-drm-copilot-mcp-1.1.22.tgz`, 794 entries, 1,889,604 bytes, SHA-256 `ca38e6fb63a2295c2d40c7a3bfcd32d3f69575fa0fe6ce67f37283899d36dbca`.
- Python entries: 0.

## Notes

- Each package holds five more entries than the P12-T11 build (795 to 800 and 789 to 794). Phase 14 adds no file to either package (it edits the existing brief only), and the Phase 13 commits add no packaged file, so by elimination the added entries come from files the rebase onto main absorbed; the entry lists were not diffed. The packaging allowlists (`packages/mcp-server/prepack.cjs`, `extensions/drm-copilot/.vscodeignore`) are not changed by Phase 14.
- The npm prepack step regenerated the gitignored copies under `packages/mcp-server/resources/`. The three execution-environment copies there (`customizations/.github`, `claude-customizations/.claude`, `codex-and-agents-customizations/.agents`) each have SHA-256 `82b744fab7fcbab437f38bf7b37f9537887e5d65292dc6146df7dcc096342c76`, equal to the six P14-T5 copies.
- Supersedes the P12-T12 digests (VSIX `bc33e805…`, npm `7cc66e5e…`).

Result: PASS

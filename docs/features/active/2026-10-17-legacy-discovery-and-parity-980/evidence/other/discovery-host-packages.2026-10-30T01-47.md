# Discovery host packages rebuild on the remediated tree (P16-T6)

Timestamp: 2026-10-30T01-47
Task: [P16-T6] Rebuild the distributables and re-verify the installed runtime.
Command: sh SCRATCH/issue-980-p12t11-packages.sh (the P10-T2 sequence: npm run compile in extensions/drm-copilot; npx --yes @vscode/vsce package --allow-missing-repository --skip-license --out SCRATCH/stage/drm-copilot.vsix; npm run build in packages/mcp-server; npm pack --pack-destination SCRATCH/stage); node run-jest.cjs test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts (in extensions/drm-copilot); sh SCRATCH/issue-980-p16t6-inspect.sh (SCRATCH/issue-980-p10t2-inspect.py)
EXIT_CODE: 0 (compile), 0 (vsce), 0 (mcp-server build), 0 (npm pack), 0 (Jest 2 suites, 14 passed), 0 (package inspection, DEFECTS=0)
Output Summary: Both distributables were rebuilt from the remediated sources into SCRATCH/stage. Neither contains a Python, bytecode or `__pycache__` entry (`python=0` in each inspection), so no Python business logic is copied into the host packages; every required entry is present (`required=58 missing=0`) and the bundled MCP server entry exists in both. The packaging contract suites pass unchanged (2 suites, 14 tests).

## VSIX (extension 1.1.23)

- File: `drm-copilot.vsix`, 809 files, 3,152,544 bytes, SHA-256 `c9eda59dcc170b2572168594286df72cd293ae39f62ab61ee5910dbfd3a5f88a`.
- Python entries: 0. `vsix_bundle_requires_vscode=False`.

## Standalone MCP package (@danmoisan/drm-copilot-mcp 1.1.23)

- File: `danmoisan-drm-copilot-mcp-1.1.23.tgz`, 803 entries, 1,903,411 bytes, SHA-256 `6c04864ea2e9b45ed2248ef4e29424d4c6a0cb8dff3333c18bf6ffe8bd74a56d`.
- Python entries: 0. `npm_bundle_requires_vscode=False`; the bundle names the wheel and the gateway module.

## Notes

- The package versions moved from 1.1.22 to 1.1.23 because the rebase onto main brought the version bump; the P14-T12 tarball `danmoisan-drm-copilot-mcp-1.1.22.tgz` is superseded and was removed from SCRATCH/stage before the inspection so the inspection reads the 1.1.23 tarball.
- Each package holds nine more entries than the P14-T12 build (800 to 809 and 794 to 803): the three new PowerShell helper modules in two bundles (six), the three `discovery-capability-sentinel` agent files, and files absorbed from main, minus the stray `DiscoveryValidation.psm1` copy that P15-T22 removed from the Codex shared library; the entry lists were not diffed.
- The npm prepack step regenerated the gitignored copies under `packages/mcp-server/resources/`. The three execution-environment copies there (`customizations/.github`, `claude-customizations/.claude`, `codex-and-agents-customizations/.agents`) each have SHA-256 `372462e37d65440ef81cedf44b012ff574ee2b717ba09928d2e09ee4b7436072`, equal to the six P15-T21 copies.
- Supersedes the P14-T12 digests (VSIX `efe92788…`, npm `ca38e6fb…`).

Result: PASS

Timestamp: 2026-03-13T20-29
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/publish-sideloaded-extension.ps1 -Force
EXIT_CODE: 0
Output Summary:
- Publish completed successfully and installed `artifacts/vsix/drm-copilot-20260313-202956.vsix`.
- The previous `npm audit` warning is resolved; the publish run no longer reports any vulnerabilities.
- The previous `vsce` warning about missing `.vscodeignore` / `files` metadata is resolved.
- The packaged VSIX no longer includes development-only folders such as `artifacts/`, `coverage/`, `src/`, or `test/`.
- The packaged VSIX now includes the expected runtime surface only: `package.json`, `README.md`, `out/**`, and `resources/**`.
- Remaining install output is limited to the package install line `added 398 packages in 4s` from `npm ci`.

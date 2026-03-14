Timestamp: 2026-03-13T20-26
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/publish-sideloaded-extension.ps1 -Force
EXIT_CODE: 0
Output Summary:
- Publish task completed and produced a VSIX, but npm install emitted deprecated package warnings for `inflight@1.0.6`, `glob@7.2.3`, and `glob@10.5.0`.
- `npm audit` reported 1 high severity vulnerability: `flatted < 3.4.0` through `eslint -> file-entry-cache -> flat-cache -> flatted`.
- `vsce` warned that neither `.vscodeignore` nor a `files` property was present in `extensions/drm-copilot/package.json`.
- The packaged VSIX included development-only content such as `artifacts/`, `coverage/`, `src/`, and `test/`.
- The task still installed `artifacts/vsix/drm-copilot-20260313-202423.vsix` successfully.

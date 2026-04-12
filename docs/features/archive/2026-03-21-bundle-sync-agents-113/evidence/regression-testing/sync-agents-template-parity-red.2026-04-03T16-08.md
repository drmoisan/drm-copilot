Timestamp: 2026-04-03T16-08
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Output Summary:
- Focused Pester run failed as expected.
- Newly added failing scenario: `Bundled sync-agents template matches the repo-root script exactly`.
- The bundled template path `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` did not exist.

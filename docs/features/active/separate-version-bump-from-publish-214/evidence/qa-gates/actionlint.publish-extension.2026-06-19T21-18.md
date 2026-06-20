# actionlint — publish-extension.yml

- **Timestamp:** 2026-06-19T21-18
- **Command:** `actionlint .github/workflows/publish-extension.yml`
- **actionlint version:** 1.7.11 (go1.25.7, windows/amd64)
- **EXIT_CODE:** 0
- **Output Summary:** Zero findings. No syntax, expression, shellcheck, or schema diagnostics reported for `.github/workflows/publish-extension.yml`. The workflow declares `on: push: tags: ['v*']` and `on: workflow_dispatch:`, and the Marketplace publish step is gated with `if: github.event_name == 'push'`, mirroring `.github/workflows/publish-mcp-npm.yml`.

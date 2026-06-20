# actionlint — publish-extension.yml

- **Timestamp:** 2026-06-19T21-18
- **Command:** `actionlint .github/workflows/publish-extension.yml`
- **actionlint version:** 1.7.11 (go1.25.7, windows/amd64)
- **EXIT_CODE:** 0
- **Output Summary:** Zero findings. No syntax, expression, shellcheck, or schema diagnostics reported for `.github/workflows/publish-extension.yml`.

## Workflow trigger/gate notes

- Triggers: `push: tags: ['v*']`, `workflow_dispatch:`, and `pull_request:` path-filtered to `extensions/drm-copilot/**` and `.github/workflows/publish-extension.yml`.
- The `pull_request` trigger was added so the workflow produces a green branch-head run in PR context, satisfying `modified-workflow-needs-green-run` for a new tag-triggered workflow that GitHub will not dispatch before it lands on the default branch.
- The Marketplace publish step is gated with `if: startsWith(github.ref, 'refs/tags/v')`, so it runs only on `v*` tag pushes and never on `pull_request` or `workflow_dispatch` events. PR-context runs exercise checkout/install/build/package without consuming a Marketplace version.

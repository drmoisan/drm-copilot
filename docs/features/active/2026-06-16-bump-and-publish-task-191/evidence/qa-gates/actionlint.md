# Final QC — actionlint (GitHub Actions)

Timestamp: 2026-06-17T00-18
Command: actionlint .github/workflows/publish-mcp-npm.yml
EXIT_CODE: 0

Output Summary:
actionlint reported zero findings for the amended workflow `.github/workflows/publish-mcp-npm.yml`. The `on:` block now contains both the unchanged `push: tags: - "mcp-server-v*"` trigger and the added `workflow_dispatch:` trigger. The `Publish to npm` step carries `if: github.event_name == 'push'`, which guards the publish so a `workflow_dispatch` verification run exercises the changed steps (build/prepack/install plus the publish step's preconditions) without publishing. The job-level `permissions: { id-token: write, contents: read }` block on the `publish` job and the publish step `run: npm publish --provenance --access public` are valid and unchanged. The `NODE_AUTH_TOKEN` env is preserved. No deliberately-failing nested `pwsh` command is present in the workflow, so `.claude/rules/ci-workflows.md` exit-code handling has no applicable construct to remediate.

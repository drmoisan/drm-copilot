# Final QC — actionlint (GitHub Actions)

Timestamp: 2026-06-16T20-37
Command: actionlint .github/workflows/publish-mcp-npm.yml
actionlint version: 1.7.11
EXIT_CODE: 0
Output Summary: actionlint reported zero findings for the amended workflow `.github/workflows/publish-mcp-npm.yml`. The job-level `permissions: { id-token: write, contents: read }` block on the `publish` job and the changed publish step `npm publish --provenance --access public` are valid. The existing `NODE_AUTH_TOKEN` env is preserved. No deliberately-failing nested `pwsh` command is present in the workflow, so `.claude/rules/ci-workflows.md` exit-code handling has no applicable construct to remediate.

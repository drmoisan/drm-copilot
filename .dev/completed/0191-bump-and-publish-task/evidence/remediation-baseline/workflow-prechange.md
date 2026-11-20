# Pre-change Workflow State — publish-mcp-npm.yml (Remediation Baseline, Issue #191)

Timestamp: 2026-06-17T00-18
Command: git show HEAD:.github/workflows/publish-mcp-npm.yml
EXIT_CODE: 0

Output Summary:
- `on:` block (lines 3-6): `push:` with `tags:` containing the single entry `- "mcp-server-v*"`. No `workflow_dispatch` trigger is present. No other trigger is present.
- `publish` job `permissions:` block (lines 34-36): `id-token: write` and `contents: read`. Unchanged baseline values.
- `Publish to npm` step (lines 56-60):
  - `working-directory: packages/mcp-server`
  - `run: npm publish --provenance --access public`
  - `env.NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`
  - No `if:` condition on this step in the pre-change state.

Baseline assertions for later comparison (P1-T3):
- Pre-change `on:` is `push: tags: mcp-server-v*` only; no `workflow_dispatch`.
- Pre-change publish job retains `permissions: { id-token: write, contents: read }`.
- Pre-change publish step retains `npm publish --provenance --access public`.

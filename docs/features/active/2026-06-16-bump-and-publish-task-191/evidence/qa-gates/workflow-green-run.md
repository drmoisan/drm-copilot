# Green Workflow Run — publish-mcp-npm.yml (F1, Issue #191)

Timestamp: 2026-06-17T00-18
Recorded by: orchestrator (post-dispatch)

## Result (orchestrator-populated)

- Workflow: Publish MCP Server to npm (`.github/workflows/publish-mcp-npm.yml`)
- Event: `workflow_dispatch`
- Head SHA: `7803ffc9282d6172e59bf0baafe10c3ca7005d97`
- Run ID: `27657801156`
- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/27657801156
- Conclusion: success

## Publish-safety verification

The `workflow_dispatch` run exercised the changed job (`Publish to npm`) and its
job-level `permissions` (`id-token: write`, `contents: read`) without performing
an irreversible publish. Per the dispatch run's job/step results:

- `Publish to npm` job: success
  - Checkout repository: success
  - Set up Node.js: success
  - Install MCP server dependencies: success
  - Copy resources (prepack): success
  - Build MCP server bundle: success
  - **Publish to npm: skipped** (guarded by `if: github.event_name == 'push'`)
- Extension Tests (ubuntu-latest): success
- Extension Tests (windows-latest): success

No `npm publish` executed; no `mcp-server-v*` tag was pushed; no artifact was
published. This satisfies the Do-Not-Do constraint that verification must not
produce an immutable Marketplace/npm release.

## Head-SHA / branch-head reconciliation

The green run was obtained against branch head `7803ffc9282d6172e59bf0baafe10c3ca7005d97`,
which was the value of `git rev-parse HEAD` at dispatch time. The only commit
made after this run is this evidence-recording commit, which modifies sole this
file (and the plan checkbox/checkpoint); it does not change
`.github/workflows/publish-mcp-npm.yml`. Reviewers can confirm the workflow is
unchanged since the green-run SHA with:

```
git diff 7803ffc9282d6172e59bf0baafe10c3ca7005d97 HEAD -- .github/workflows/publish-mcp-npm.yml
```

which is expected to report no differences.

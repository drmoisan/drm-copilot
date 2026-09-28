# Branch-head dispatch run — `publish-mcp-npm.yml`

Timestamp: 2026-08-26T08-17

Command: `gh workflow run publish-mcp-npm.yml --ref bug/tag-push-can-silently-skip-npm-publish-526`

EXIT_CODE: 0

## What this artifact settles, and what it does not

This artifact resolves the **`modified-workflow-needs-green-run` policy rule** (feature-review
finding B2 / remediation input R2) for `.github/workflows/publish-mcp-npm.yml`. It does **not**
satisfy **AC18**. The two are distinct claims and are recorded separately here so that neither is
read as the other.

- The policy rule accepts a green `workflow_dispatch` run against the branch head. That is what this
  artifact records, and the rule is therefore satisfied for this workflow.
- AC18's text requires a green run "produced by the new `pull_request` trigger". This run was
  produced by `workflow_dispatch`, not by `pull_request`, so AC18 remains **unchecked** and is
  settled only once the pull request exists and its `pull_request`-triggered run completes.

Recording a dispatch run as satisfying AC18 would assert more than the evidence supports. That is
the same defect class the review raised against AC21, so it is avoided explicitly here.

## Observed run

- Workflow: `.github/workflows/publish-mcp-npm.yml`
- Run URL: `https://github.com/drmoisan/drm-copilot/actions/runs/32946866360`
- Run ID: `32946866360`
- Trigger: `workflow_dispatch`
- Head SHA: `5cb5224a6062213cf6694f16871b61dbf1759da2`
- Branch: `bug/tag-push-can-silently-skip-npm-publish-526`
- Run Conclusion: `success`

Head-SHA correspondence was verified rather than assumed: `git rev-parse HEAD` returned
`5cb5224a6062213cf6694f16871b61dbf1759da2` immediately before dispatch, and the run reports the
identical `headSha`. The run therefore covers the branch head, not an earlier commit.

## Per-step conclusions in the `Publish to npm` job

| Step | Conclusion |
| --- | --- |
| Set up job | success |
| Checkout repository | success |
| Set up Node.js | success |
| Upgrade npm for trusted publishing | success |
| Install MCP server dependencies | success |
| Copy resources (prepack) | success |
| Build MCP server bundle | success |
| Verify tag version matches the mcp-server manifest | **skipped** |
| Publish to npm | **skipped** |
| Verify the published version resolves on the registry | **skipped** |
| Post Set up Node.js | success |
| Post Checkout repository | success |
| Complete job | success |

Job conclusion: `success`. The two `Extension Tests` matrix jobs also concluded `success`.

## Why no version number was consumed

All three tag-dependent steps carry the guard
`if: startsWith(github.ref, 'refs/tags/mcp-server-v')`. On a `workflow_dispatch` against a branch,
`github.ref` is `refs/heads/bug/tag-push-can-silently-skip-npm-publish-526`, which matches none of
them. All three skipped, as the table above shows observed rather than predicted.

This is the behaviour the ref-guard design exists to produce, and it is the reason the run is safe to
issue before the pull request opens: the publish step cannot fire, so no npm version number can be
consumed by this verification.

The publish job itself still executed, because its `needs` was satisfied — which is precisely why
the version-equality step and the registry poll had to be ref-guarded too. An unguarded equality
step would have failed on the absent tag ref, and an unguarded poll would have queried a version the
skipped publish step never published. Either would have made this green run unobtainable.

## `verify-published-releases.yml` — still deferred, and forced

No dispatch is possible for the second workflow. `gh run list --workflow=verify-published-releases.yml`
returns `HTTP 404: workflow verify-published-releases.yml not found on the default branch`, because
the file is new on this branch and `workflow_dispatch` resolves workflows from the default branch.

Its `pull_request` trigger produces the branch-head run once the pull request is opened. Expected
conclusion `success` with the sweep step skipped by `if: github.event_name != 'pull_request'`.

- Workflow: `.github/workflows/verify-published-releases.yml`
- Run URL: `DEFERRED`
- Run Conclusion: `DEFERRED`
- Deferred owner: `pr-author` / orchestrator post-PR CI monitoring
- Deferred invocation: `gh run view RUN_IDENTIFIER --json conclusion`, with the concrete integer run
  identifier substituted once the pull request exists.

## Output Summary

The `modified-workflow-needs-green-run` rule is satisfied for `publish-mcp-npm.yml` by run
32946866360: conclusion `success` against head SHA `5cb5224a`, with the version-equality, publish,
and registry-poll steps all observed `skipped`, so no version number was consumed. The same rule
remains forced-deferred for `verify-published-releases.yml`, which cannot be dispatched because it
does not exist on the default branch; its `pull_request` trigger settles it once the PR opens. AC18
stays unchecked: it requires a `pull_request`-triggered run, and this run was `workflow_dispatch`.

# tag-push-can-silently-skip-npm-publish (Issue #526)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/tag-push-can-silently-skip-npm-publish/ (Issue #526)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #526
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/526
- Last Updated: 2026-08-23
- Work Mode: full-bug

## Summary

Pushing an `mcp-server-v*` tag does not reliably start `publish-mcp-npm.yml`. It has failed at least
twice, producing no workflow run at all, so the release completed with nothing published and no
error anywhere. Version 1.0.25 additionally shipped a Codex configuration pinning an npm package
version that did not exist, which broke the Codex MCP integration for that release.

## Environment

- OS/version: GitHub Actions hosted runners; tags pushed from Windows 11
- Python version: not applicable
- Command/flags used: `git push origin mcp-server-v<version>`
- Data source or fixture: `.github/workflows/publish-mcp-npm.yml`, tags `mcp-server-v1.0.12` and `mcp-server-v1.0.25`

## Steps to Reproduce

Not reliably reproducible on demand — it is intermittent, which is the core difficulty. The observed
occurrences:

1. Push `mcp-server-v<version>` to origin, in both known cases close in time to a sibling `v<version>` tag push.
2. Observe that `gh run list --workflow=publish-mcp-npm.yml` contains no run for that tag.
3. Observe that `npm view @danmoisan/drm-copilot-mcp versions` omits that version.

## Expected Behavior

Every pushed `mcp-server-v*` tag starts `publish-mcp-npm.yml`, which publishes that version to npm.
If a publish does not happen, the release fails visibly.

## Actual Behavior

Two versions are missing from the registry with no corresponding workflow run:

- `npm view @danmoisan/drm-copilot-mcp versions` returns `..., 1.0.23, 1.0.24, 1.0.26, 1.0.27, 1.1.0` — **1.0.25 is absent**, directly observed 2026-08-23.
- **1.0.12 is likewise absent**, and `gh run list --workflow=publish-mcp-npm.yml` has runs for `mcp-server-v1.0.26` and `mcp-server-v1.0.24` but none for `mcp-server-v1.0.25`.

Both tags exist. Nothing reported an error. The release appeared to succeed.

### The consequence for 1.0.25 was a shipped, broken integration

At tag `v1.0.25`, both `.codex/config.toml` copies pinned `@danmoisan/drm-copilot-mcp@1.0.25`, which
correctly matched that release's manifest. That version was never published, so for anyone on
extension 1.0.25 the Codex MCP server launch — `npx -y @danmoisan/drm-copilot-mcp@1.0.25` — failed
outright. This shipped from 2026-08-15 until 1.0.26 on 2026-08-17. Verified by reading the pin at
the tag and comparing against the registry.

`v1.0.12` predates the Codex configuration, so it has no pin impact; only the registry gap applies.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `git cat-file blob v1.0.25:.codex/config.toml | grep -o 'drm-copilot-mcp@[0-9.]*'` yields `drm-copilot-mcp@1.0.25`, while that version is absent from `npm view @danmoisan/drm-copilot-mcp versions --json`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High for two reasons. A release can complete with nothing published and no signal, and when the
Codex pin references the unpublished version the shipped artifact is broken for every user of that
release. The affected version numbers are also unrecoverable: npm permanently reserves a version
number once used, so 1.0.25 can never be published under that number.

## Suspected Cause / Notes

Unknown, and that is the main thing this issue needs to resolve. Both known occurrences involved two
tags pushed in close succession (`v<version>` and `mcp-server-v<version>`), which suggests GitHub
Actions may not start a workflow for every ref when several are pushed together — but that is a
hypothesis, not a finding, and it has not been confirmed.

Relevant mechanics:

- The publish step is `if: github.event_name == 'push'` (`.github/workflows/publish-mcp-npm.yml:61`), so **a `workflow_dispatch` re-run cannot recover a missed publish** — it builds and skips. Recovery requires deleting and re-pushing the tag, which is why a silent miss is expensive to discover late.
- Publishing uses npm trusted publishing via OIDC (`id-token: write`, `npm publish --provenance`). No `NPM_TOKEN` is used, despite `README.md:402` claiming otherwise, so token expiry is not a candidate cause.
- Mitigation already proven to work: on the 1.1.0 release the two tags were pushed **sequentially**, confirming each workflow had started before pushing the next. Both fired. The extension run took three polls to appear, so a single immediate check would have been inconclusive.

This is also why the Codex pin test specified in issue #522 is insufficient on its own: it asserts
the pin equals the manifest version, and at 1.0.25 that assertion held while the artifact was
broken. #522 has been amended with a criterion requiring the pinned version to resolve on the
registry after publish.

## Proposed Fix / Validation Ideas

- [x] Add a post-publish verification step that fails loudly: after the tags are pushed, assert that a workflow run exists for each tag and that the expected version is retrievable from the registry (`npm view @danmoisan/drm-copilot-mcp version`) and from the Marketplace. Allow for propagation delay — the Marketplace lagged roughly five to eight minutes on 1.1.0 — by polling rather than checking once.
- [x] Make `Invoke-ReleaseTagPush.ps1` push the two tags sequentially and confirm each run has started before pushing the next, rather than pushing both and returning. This is the mitigation that worked manually for 1.1.0.
- [ ] Investigate the root cause of the missing runs, using the two known occurrences. If multiple-ref pushes are confirmed as the trigger, the sequential push above is the fix rather than a workaround.
- [x] Add the registry-resolution check for the Codex pin, so a pin naming an unpublished version cannot ship. Coordinate with issue #522 so the guard is implemented once.
- [x] Manual verification notes: do not treat a green workflow run as proof of publication. On a pull request the extension workflow's publish step is skipped while the job still reports success, so the *step* conclusion and the registry must both be checked.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

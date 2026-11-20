# npm-publish-verify-window-too-short (Issue #723)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-publish-verify-window-too-short/ (Issue #723)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #723
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/723
- Last Updated: 2026-09-27
## Summary

The "Verify the published version resolves on the registry" step in `.github/workflows/publish-mcp-npm.yml` polls for only 3 minutes (18 attempts x 10 s). npm took about 4 minutes to make `@danmoisan/drm-copilot-mcp@1.1.12` resolvable, so run #71 failed after a successful publish. Its error message also states, incorrectly, that "the tag push did not publish".

## Environment

- OS/version: ubuntu-latest GitHub runner, pwsh step
- Python version: n/a
- Command/flags used: tag push `mcp-server-v1.1.12` (run 36290027128, workflow run #71)
- Data source or fixture: the npm registry, with trusted publishing (OIDC + `--provenance`)

## Steps to Reproduce

1. Push an `mcp-server-v*` tag.
2. The "Publish to npm" step succeeds (02:59:26-02:59:32Z on 2026-09-27).
3. The verify step polls 02:59:32-03:02:38Z and fails.
4. `npm view @danmoisan/drm-copilot-mcp time` shows `1.1.12` recorded at 03:03:40Z, about 62 s after the verify step gave up.

## Expected Behavior

The verify step tolerates normal registry propagation latency. When it does time out, its message says the version was not yet visible, not that nothing was published.

## Actual Behavior

The run went red after a successful publish. The run cannot simply be re-run, because re-publishing an existing version fails. The false failure also appears to have stopped the operator from pushing the paired extension tag `v1.1.12`, so the VS Code extension 1.1.12 was never published.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `##[error]@danmoisan/drm-copilot-mcp@1.1.12 did not resolve within 18 attempts; the tag push did not publish.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

A fixed 3-minute window. 1.1.11 resolved in about 1.5 minutes, so the window passed until now by margin, not by design. OIDC/provenance publishes may add registry-side processing latency (unverified).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: widen the window to at least 10 minutes with backoff (for example 10 s growing to 60 s); keep the `$LASTEXITCODE` reset.
- [ ] Integration scenario to retest: the next `mcp-server-v*` release goes green.
- [ ] Manual verification notes: reword the timeout error to "not yet resolvable after N minutes; the publish step succeeded — check the registry before re-running (re-publishing an existing version fails)". Consider checking the publish step's own output as the primary success signal and making resolution a warning-level check. Update the release runbook/memory: a red verify step after a green publish step is not a failed release, and the paired extension tag still needs pushing.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

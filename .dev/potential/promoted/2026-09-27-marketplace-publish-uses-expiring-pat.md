# marketplace-publish-uses-expiring-pat (Issue #724)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/marketplace-publish-uses-expiring-pat/ (Issue #724)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #724
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/724
- Last Updated: 2026-09-27
## Summary

`.github/workflows/publish-extension.yml` publishes to the VS Code Marketplace with a long-lived Azure DevOps PAT (`vsce publish --pat ${{ secrets.VSCE_PAT }}`). The PAT expires silently. The v1.1.12 release failed on 2026-09-27 with "Access Denied: The Personal Access Token used has expired". `VSCE_PAT` was last set on 2026-06-21.

## Environment

- OS/version: ubuntu-latest GitHub runner
- Python version: n/a
- Command/flags used: tag push `v1.1.12` → "Publish Extension to VS Code Marketplace" (run 36315990899), step 7
- Data source or fixture: repository secret `VSCE_PAT`

## Steps to Reproduce

1. Let the Azure DevOps PAT stored in `VSCE_PAT` pass its expiry date.
2. Push a `v*` release tag.
3. `vsce package` succeeds; `vsce publish` fails with AccessCheckException "The Personal Access Token used has expired".

## Expected Behavior

Marketplace publishing does not depend on a credential that silently expires between releases.

## Actual Behavior

The release fails at the publish step. Recovery requires a human to mint a new PAT in the Azure DevOps UI, reset the secret, and re-run. Nothing warns before expiry.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `{"message":"Access Denied: The Personal Access Token used has expired.","typeKey":"AccessCheckException"}` — `You're using an expired Personal Access Token, please get a new PAT.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Each lapse blocks the extension release until a human intervenes. The npm side already moved off long-lived tokens to OIDC trusted publishing (see #712).

## Suspected Cause / Notes

A long-lived PAT with a fixed maximum lifetime. The npm workflow's migration to OIDC is the in-repo precedent.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: switch to Microsoft Entra ID workload-identity federation. Use `azure/login` with GitHub OIDC (`id-token: write`), then `npx @vscode/vsce publish --azure-credential`, with the Entra service principal added as a Marketplace publisher member. Remove `VSCE_PAT` once proven. Needs a human-exception runbook for the one-time Azure and Marketplace setup.
- [ ] Integration scenario to retest: the next `v*` tag publishes with no PAT secret present.
- [ ] Manual verification notes: until the migration lands, add a scheduled workflow, or a step in the release workflow, that warns when `VSCE_PAT` is older than roughly 80 days (secret `updated_at` via the API).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

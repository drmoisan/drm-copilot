# bump-and-publish-task (Issue #191)

- Date captured: 2026-06-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bump-and-publish-task/ (Issue #191)

- Issue: #191
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/191
- Last Updated: 2026-06-16
- Work Mode: minor-audit

## Problem / Why

Publishing a new release currently requires two separate, manually coordinated
actions: the VS Code Marketplace publish (the existing "Publish: Marketplace
VSIX (patch + tag)" task, which bumps the extension patch version, builds,
packages, publishes, and tags) and the npm publish of the MCP server (which is
triggered only by manually creating and pushing a `mcp-server-v*` git tag).
There is no single task that releases both artifacts together, so the two
package versions can drift and a release can be partially completed.

## Proposed Behavior

Add a single VS Code task that, in one confirmed run:

1. Patch-bumps both `extensions/drm-copilot/package.json` and
   `packages/mcp-server/package.json` (smallest possible increment), keeping
   the two packages on a shared release cadence.
2. Publishes the extension to the VS Code Marketplace via the existing
   `scripts/powershell/Publish-DrmCopilotExtension.ps1` path.
3. Triggers the npm publish by creating and pushing a `mcp-server-v<version>`
   tag, which fires the existing `.github/workflows/publish-mcp-npm.yml`
   workflow (tag-trigger model; no local npm token required).
4. Is gated behind the same explicit `yes`/`no` confirmation input as the
   current Marketplace task, because Marketplace and npm versions are immutable.

Additionally, add npm provenance (`npm publish --provenance` plus
`id-token: write`) to `.github/workflows/publish-mcp-npm.yml` so the published
npm package carries a verifiable build attestation.

Certificate-based local signing is explicitly out of scope: the Marketplace
signs distributed extensions itself, and the meaningful npm supply-chain
measure is provenance, which is keyless and CI-based.

## Acceptance Criteria

- [x] A new VS Code task patch-bumps both package manifests in one run.
- [x] The task publishes the extension to the Marketplace via the existing script.
- [x] The task creates and pushes a `mcp-server-v<version>` tag to trigger npm publish.
- [x] The task is gated behind a `yes`/`no` confirmation input.
- [x] The npm workflow publishes with `--provenance`.
- [x] Pester tests cover the new release script's guard and orchestration logic.

## Constraints & Risks

- Marketplace and npm versions are immutable; an incorrect bump cannot be undone.
- The new script must not push commits or tags unless confirmation is provided.
- The npm publish remains CI-driven; the task's responsibility ends at pushing the tag.
- No certificate signing is in scope.

## Test Conditions to Consider

- [ ] Unit coverage: confirmation-token guard rejects non-`yes` tokens.
- [ ] Unit coverage: both manifests are patch-bumped to the expected versions.
- [ ] Unit coverage: the `mcp-server-v<version>` tag name is derived correctly.
- [ ] Negative: missing publish script is reported, not silently ignored.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bump-and-publish-task/` folder from the template
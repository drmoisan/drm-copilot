# Definition-of-Done Absence-Invariant Checks (Issue #214)

Timestamp: 2026-06-19T21-18

Scope: the four changed/new scripts.
- scripts/powershell/Publish-DrmCopilotExtension.ps1
- scripts/dev-tools/Invoke-FullRelease.ps1
- scripts/dev-tools/Invoke-MarketplacePublish.ps1
- scripts/dev-tools/Invoke-ReleaseTagPush.ps1

## Invariant 1 — No local task both bumps a tracked manifest and publishes/pushes a publish tag

- The two PR-opener scripts (Invoke-FullRelease.ps1, Invoke-MarketplacePublish.ps1) bump
  manifests but only commit and open a PR (gh pr create); they do not upload to the
  Marketplace and do not push any tag (see Invariants 3 and 4).
- Invoke-ReleaseTagPush.ps1 pushes tags but performs NO version bump (it only reads merged
  versions via Get-NpmVersion and derives tag names).
- Publish-DrmCopilotExtension.ps1 neither bumps nor uploads nor tags (Invariant 2).
- SATISFIED. No single script combines a manifest bump with a publish/tag push.

## Invariant 2 — vsce publish / npm version / git tag absent from Publish-DrmCopilotExtension.ps1

Command: Grep pattern `vsce publish|npm version|git tag` in
scripts/powershell/Publish-DrmCopilotExtension.ps1
Result: 0 matches.
SATISFIED.

## Invariant 3 — Invoke-FullRelease.ps1 never publishes or tags

Command: Grep pattern `vsce publish|Invoke-PublishScript|'tag'|git tag|push.*origin.*v` in
scripts/dev-tools/Invoke-FullRelease.ps1
Result: 0 matches.
SATISFIED. The script bumps both manifests, commits, and runs `gh pr create --base main`
only.

## Invariant 3b — Invoke-MarketplacePublish.ps1 never publishes or tags

Command: Grep pattern `vsce publish|Invoke-PublishScript|'tag'|git tag|push.*origin.*v` in
scripts/dev-tools/Invoke-MarketplacePublish.ps1
Result: 0 matches.
SATISFIED. The script bumps only the extension manifest, commits, and runs
`gh pr create --base main` only.

## Invariant 4 — Invoke-ReleaseTagPush.ps1 is the sole script that pushes v* / mcp-server-v*

Command: Grep pattern `'push', 'origin'|push origin` across scripts/**/*.ps1
Result: single match — scripts/dev-tools/Invoke-ReleaseTagPush.ps1:197
  `$push = Invoke-GitExe -GitArgs @('push', 'origin', $entry.Tag)`
The pushed tags are derived by Get-ExtensionTagName (v<version>) and Get-McpServerTagName
(mcp-server-v<version>).
SATISFIED. No other script pushes a tag.

## Overall determination

All four absence invariants SATISFIED. Bump (PR-gated) and publish (post-merge, CI
tag-triggered) are separated across the four scripts. No script both bumps a tracked manifest
and publishes/pushes a publish tag.
